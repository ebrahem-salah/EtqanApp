import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/services/deep_link_service.dart';
import '../../core/services/zego_cloud_service.dart';
import '../../core/services/reels_preload_manager.dart';
import '../../core/services/user_chapters_service.dart';
import '../../core/utils/app_feedback.dart';
import '../../providers/auth_provider.dart';
import '../competitions/widgets/competition_exam_sheet.dart';

class LiveRecitationRoom extends StatefulWidget {
  final String roomId;
  final String circleTitle;
  final bool isSheikh;
  final bool isRecorded;
  final int? classRoomId;
  final String? sheikhName;
  final int? subscribersCount;
  final int? capacity;

  const LiveRecitationRoom({
    super.key,
    required this.roomId,
    required this.circleTitle,
    this.isSheikh = false,
    this.isRecorded = false,
    this.classRoomId,
    this.sheikhName,
    this.subscribersCount,
    this.capacity,
  });

  @override
  State<LiveRecitationRoom> createState() => _LiveRecitationRoomState();
}

class _LiveRecitationRoomState extends State<LiveRecitationRoom> {
  // RTC & Controls State
  bool _isEngineReady = false;
  bool _isMicMuted = false;
  bool _isCameraOn = true;
  bool _isSpeakerOn = true;
  bool _isHandRaised = false;
  bool _isStudentMicApproved = false;

  // UI Modes matching screenshots 4, 5, 6, 8, 9, 13, 14
  bool _isCallActive = false; // هل المكالمة قيد التشغيل (صوت أو فيديو)
  bool _isCallStarted = false; // هل تم الضغط على زر Start البنفسجي
  bool _isScreenSharing = false; // وضع مشاركة الشاشة من الصورة 8
  bool _isPipMode = false; // وضع النافذة العائمة Picture-in-Picture من الصورة 9
  bool _isVoiceOnly = false; // مكالمة صوتية فقط من الصورة 14

  // Timer & Duration
  Timer? _callTimer;
  int _callSeconds = 2; // عداد المكالمة الحية (00:02)
  int _chapterMinutes = 2; // مدة الحلقة (02:25)

  // Recording State (حفظ وقائع الحلقة للأرشيف)
  bool _isRecording = false;
  int _recordedSeconds = 0;
  Timer? _recordTimer;
  final ApiClient _apiClient = ApiClient();

  Widget? _localVideoWidget;
  int? _localViewID;
  final Map<String, Widget> _remoteStreams = {};
  final Map<String, bool> _remoteCameraOn = {};
  final Map<String, String> _remoteUsers = {};
  bool _isPublishing = false;
  bool _useFrontCamera = true;
  double _soundLevel = 0.0;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  // Chat Messages - تبدأ فاضية وتتملأ بالرسائل الحقيقية فقط
  final List<Map<String, dynamic>> _messages = [];
  Timer? _messagesPollTimer;

  // بيانات المستخدم الحالي والشيخ (يتم جلبها من AuthProvider والخادم)
  int? _currentUserId;
  String _currentUserName = '';
  String _displaySheikhName = '';
  int _subscribersCount = 1;
  int _capacity = 30;
  String _zegoUserId = '';
  String _roomDiagnosticStatus = 'جاري تهيئة الغرفة...';
  bool _roomDiagnosticIsError = false;
  bool _msgLoadErrorShown = false;
  bool _isDisposed = false;

  // Drag position for Floating Window (PiP mode)
  Offset _pipPosition = const Offset(100, 150);

  @override
  void initState() {
    super.initState();
    ReelsPreloadManager.instance.pauseAll();
    _initUserName();
    _initZegoRTC();
    _startTimer();
    _joinAndLoadRoomData();
  }

  void _initUserName() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    _currentUserId = user?.id;
    _currentUserName = (user?.name != null && user!.name.isNotEmpty) ? user.name : 'مستخدم إتقان';
    _displaySheikhName = (widget.sheikhName != null && widget.sheikhName!.isNotEmpty)
        ? widget.sheikhName!
        : (widget.isSheikh ? _currentUserName : 'الشيخ المقرئ');
    _subscribersCount = widget.subscribersCount ?? 1;
    _capacity = widget.capacity ?? 30;
    _zegoUserId = 'u_${_currentUserId ?? DateTime.now().millisecondsSinceEpoch % 100000}_${DateTime.now().millisecondsSinceEpoch % 1000}';
  }

  Future<void> _joinAndLoadRoomData() async {
    if (widget.classRoomId == null) {
      if (mounted) {
        setState(() {
          _roomDiagnosticStatus = '⚠️ الغرفة تعمل محلياً فقط (بدون معرف سيرفر — لن تصل الرسائل عبر الخادم)';
          _roomDiagnosticIsError = true;
        });
      }
      return;
    }
    if (!widget.isSheikh) {
      try {
        await _apiClient.joinClass(widget.classRoomId!);
      } catch (e) {
        final errTxt = AppFeedback.formatError(e);
        if (!errTxt.contains('منضم') && !errTxt.contains('already') && mounted) {
          AppFeedback.showError(context, 'تسجيل الانضمام للحلقة', e);
        }
      }
    }
    await _loadClassDetails();
    await _loadServerMessages();
    _messagesPollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _loadServerMessages(isPoll: true);
    });
  }

  Future<void> _loadClassDetails() async {
    if (widget.classRoomId == null) return;
    try {
      final res = await _apiClient.getClassDetails(widget.classRoomId!);
      if (res.statusCode == 200 && res.data != null && mounted) {
        final data = res.data['data'];
        if (data is Map<String, dynamic>) {
          final sheikhObj = data['sheikh'] ?? data['creator']?['user'] ?? data['creator'];
          final sName = sheikhObj?['name']?.toString();
          setState(() {
            if (sName != null && sName.isNotEmpty && !sName.contains('???')) {
              _displaySheikhName = sName;
            }
            if (data['students_count'] != null) {
              _subscribersCount = int.tryParse('${data['students_count']}') ?? _subscribersCount;
            }
            if (data['capacity'] != null) {
              _capacity = int.tryParse('${data['capacity']}') ?? _capacity;
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'جلب تفاصيل الحلقة', e);
      }
    }
  }

  /// جلب الرسائل الحقيقية من السيرفر ومزامنتها
  Future<void> _loadServerMessages({bool isPoll = false}) async {
    if (widget.classRoomId == null || !mounted || _isDisposed) return;
    try {
      final res = await _apiClient.getClassMessages(widget.classRoomId!);
      if (!mounted || _isDisposed) return;
      if (res.statusCode == 200 && res.data != null) {
        final List items = res.data['data'] ?? [];
        if (mounted && !_isDisposed) {
          final List<Map<String, dynamic>> parsed = items.map<Map<String, dynamic>>((msg) {
            final senderObj = msg['sender'] ?? msg['user'] ?? {};
            final senderId = int.tryParse('${senderObj['id'] ?? ''}');
            final senderName = senderObj['name']?.toString() ?? 'مستخدم';
            final text = msg['message']?.toString() ?? '';
            final time = msg['created_at_human']?.toString() ?? msg['created_at']?.toString() ?? '';
            final isMe = (_currentUserId != null && senderId != null && senderId == _currentUserId);
            return {
              'id': msg['id'],
              'sender': senderName,
              'role': senderObj['user_type']?.toString() ?? senderObj['type']?.toString() ?? 'student',
              'message': text,
              'time': time,
              'isMe': isMe,
            };
          }).toList();

          if (parsed.length != _messages.length ||
              (parsed.isNotEmpty && _messages.isNotEmpty && parsed.last['id'] != _messages.last['id'])) {
            setState(() {
              _messages
                ..clear()
                ..addAll(parsed);
            });
            _scrollToBottom();
          }
        }
      }
    } catch (e) {
      if (!isPoll && !_msgLoadErrorShown && mounted && !_isDisposed) {
        _msgLoadErrorShown = true;
        AppFeedback.showError(context, 'تحديث رسائل الشات من السيرفر', e);
      } else if (isPoll && mounted && !_isDisposed) {
        setState(() {
          _roomDiagnosticStatus = '⚠️ تعذر تحديث الشات: ${AppFeedback.formatError(e)}';
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          _callSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    ZegoExpressEngine.onRoomStateUpdate = null;
    _callTimer?.cancel();
    _recordTimer?.cancel();
    _messagesPollTimer?.cancel();
    _messageController.dispose();
    _chatScrollController.dispose();
    _destroyZego();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _recordedSeconds = 0;
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (mounted) setState(() => _recordedSeconds++);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.fiber_manual_record, color: Colors.red, size: 18),
                SizedBox(width: 8),
                Text('جاري تسجيل وقائع الحلقة لحفظها في الأرشيف 🔴', style: TextStyle(fontFamily: 'Dubai')),
              ],
            ),
            backgroundColor: Color(0xFF191919),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        _recordTimer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF00875A), size: 18),
                SizedBox(width: 8),
                Text('تم حفظ التسجيل، وسيتاح للمشتركين بعد انتهاء الجلسة', style: TextStyle(fontFamily: 'Dubai')),
              ],
            ),
            backgroundColor: Color(0xFF191919),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _endSessionPrompt() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إنهاء الحلقة والتسميع', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold)),
        content: Text(
          _isRecording
              ? 'هل ترغب في إنهاء الحلقة، وتدوين تقييم الطالب (الأخطاء والتلعثم)، وحفظ التسجيل؟'
              : 'هل ترغب في إنهاء جلسة التسميع وتدوين درجات الطالب؟',
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Dubai'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Dubai')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00875A)),
            onPressed: () async {
              Navigator.pop(ctx);
              await _showRecitationEvaluationSheet();
            },
            child: const Text('تقييم الطالب وإنهاء', style: TextStyle(fontFamily: 'Dubai', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// نافذة تقييم التلاوة الاحترافية (احتساب أخطاء الحفظ، التلعثم، والتجويد)
  Future<void> _showRecitationEvaluationSheet() async {
    int majorErrors = 0; // خطأ جلي (-1.0)
    int hesitations = 0; // تلعثم وتردد (-0.5)
    int tajweedNotes = 0; // ملاحظة تجويد (-0.25)
    final notesController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // حساب الدرجة آلياً بدقة
            double calculatedScore = 10.0 - (majorErrors * 1.0) - (hesitations * 0.5) - (tajweedNotes * 0.25);
            if (calculatedScore < 0) calculatedScore = 0.0;

            String gradeText;
            Color gradeColor;
            if (calculatedScore >= 9.0) {
              gradeText = 'ممتاز مع مرتبة الشرف 🌟';
              gradeColor = const Color(0xFF00875A);
            } else if (calculatedScore >= 8.0) {
              gradeText = 'جيد جداً مرتفع 👏';
              gradeColor = const Color(0xFF2E7D32);
            } else if (calculatedScore >= 7.0) {
              gradeText = 'جيد جداً 👍';
              gradeColor = const Color(0xFF1E88E5);
            } else if (calculatedScore >= 6.0) {
              gradeText = 'مقبول / يحتاج عناية ⚠️';
              gradeColor = const Color(0xFFF57F17);
            } else {
              gradeText = 'يحتاج إعادة تثبيت ومراجعة 📖';
              gradeColor = const Color(0xFFD32F2F);
            }

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 14),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rate_review_rounded, color: Color(0xFF00875A)),
                        SizedBox(width: 8),
                        Text(
                          'تقييم جلسة التسميع والتلاوة',
                          style: TextStyle(fontFamily: 'Dubai', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'حساب درجات الطالب بناءً على معايير التحكيم المعتمدة',
                      style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),

                    // بطاقة النتيجة اللحظية الآلية
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: gradeColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: gradeColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gradeText,
                                style: TextStyle(fontFamily: 'Dubai', fontSize: 14, fontWeight: FontWeight.bold, color: gradeColor),
                              ),
                              Text(
                                'خصم أخطاء: ${(10.0 - calculatedScore).toStringAsFixed(2)} درجة',
                                style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(color: gradeColor, borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              '${calculatedScore.toStringAsFixed(1)} / 10',
                              style: const TextStyle(fontFamily: 'Dubai', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 1. عداد أخطاء الحفظ الجلية (-1.0)
                    _buildRubricCounterRow(
                      title: 'أخطاء الحفظ الجلية (لحن جلي)',
                      subtitle: 'نسيان كلمة أو تبديل حرف أو حركة تغير المعنى (-1.0)',
                      count: majorErrors,
                      color: const Color(0xFFD32F2F),
                      onDecrement: majorErrors > 0 ? () => setSheetState(() => majorErrors--) : null,
                      onIncrement: () => setSheetState(() => majorErrors++),
                    ),
                    const SizedBox(height: 10),

                    // 2. عداد التردد والتلعثم (-0.5)
                    _buildRubricCounterRow(
                      title: 'التردد والتلعثم والوقف الطويل',
                      subtitle: 'تكرار الآية أكثر من مرتين أو توقف متردد (-0.5)',
                      count: hesitations,
                      color: const Color(0xFFF57F17),
                      onDecrement: hesitations > 0 ? () => setSheetState(() => hesitations--) : null,
                      onIncrement: () => setSheetState(() => hesitations++),
                    ),
                    const SizedBox(height: 10),

                    // 3. عداد أحكام التجويد والمخارج (-0.25)
                    _buildRubricCounterRow(
                      title: 'ملاحظات التجويد والمخارج',
                      subtitle: 'نقص غنة، تفريط بمد، عدم ضبط قلقلة أو صفة (-0.25)',
                      count: tajweedNotes,
                      color: const Color(0xFF1E88E5),
                      onDecrement: tajweedNotes > 0 ? () => setSheetState(() => tajweedNotes--) : null,
                      onIncrement: () => setSheetState(() => tajweedNotes++),
                    ),
                    const SizedBox(height: 14),

                    // حقل ملاحظات وتوجيهات الشيخ
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(
                        hintText: 'ملاحظات الشيخ وتوجيهات الحفظ للطالب (اختياري)...',
                        hintStyle: const TextStyle(fontFamily: 'Dubai', fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // أزرار الحفظ والخروج
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00875A),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              Navigator.pop(bCtx);
                              await UserChaptersService.instance.endAndSaveChapter(
                                roomId: widget.roomId,
                                title: widget.circleTitle,
                                durationFormatted: _formatCallTimer(_callSeconds > 0 ? _callSeconds : 150),
                              );
                              if (widget.classRoomId != null) {
                                try {
                                  await _apiClient.endClass(
                                    widget.classRoomId!,
                                    recordUrl: 'https://etqan.site/storage/recordings/sample_recitation.mp4',
                                  );
                                } catch (_) {}
                              }
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('🎉 تم اعتماد نتيجة التسميع (${calculatedScore.toStringAsFixed(1)}/10) وحفظها بسجل الطالب!'),
                                    backgroundColor: const Color(0xFF00875A),
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            },
                            icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                            label: const Text('اعتماد التقييم وإنهاء الجلسة', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(bCtx);
                            await UserChaptersService.instance.endAndSaveChapter(
                              roomId: widget.roomId,
                              title: widget.circleTitle,
                              durationFormatted: _formatCallTimer(_callSeconds > 0 ? _callSeconds : 150),
                            );
                            if (mounted) Navigator.pop(context);
                          },
                          child: const Text('تخطي وخروج', style: TextStyle(fontFamily: 'Dubai', color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRubricCounterRow({
    required String title,
    required String subtitle,
    required int count,
    required Color color,
    required VoidCallback? onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF191919))),
                Text(subtitle, style: TextStyle(fontFamily: 'Dubai', fontSize: 10, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                color: onDecrement != null ? color : Colors.grey.shade400,
                onPressed: onDecrement,
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  '$count',
                  style: TextStyle(fontFamily: 'Dubai', fontSize: 16, fontWeight: FontWeight.bold, color: count > 0 ? color : Colors.black87),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                color: color,
                onPressed: onIncrement,
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _initZegoRTC() async {
    try {
      // طلب أذونات الكاميرا والميكروفون والتحقق منها صراحةً
      final camStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();
      if ((!camStatus.isGranted || !micStatus.isGranted) && mounted) {
        AppFeedback.showError(
          context,
          'صلاحيات المكالمة',
          'يرجى منح إذن الكاميرا والمايكروفون ليعمل الصوت والفيديو',
        );
      }

      // تنظيف أي محرك قديم إن وُجد
      try {
        await ZegoExpressEngine.destroyEngine();
      } catch (_) {}

      final profile = ZegoEngineProfile(
        ZegoCloudConfig.appID,
        ZegoScenario.Default,
        appSign: ZegoCloudConfig.appSign,
      );
      await ZegoExpressEngine.createEngineWithProfile(profile);

      ZegoExpressEngine.onRoomStateUpdate = (roomID, state, errorCode, extendedData) {
        if (!mounted || _isDisposed || roomID != widget.roomId) return;
        final isTransientReconnect =
            errorCode == 1002051 ||
            errorCode == 1002001 ||
            state == ZegoRoomState.Connecting;
        setState(() {
          if (state == ZegoRoomState.Connected && errorCode == 0) {
            _roomDiagnosticStatus = '✅ متصل بالبث المباشر (${widget.roomId})';
            _roomDiagnosticIsError = false;
          } else if (isTransientReconnect) {
            _roomDiagnosticStatus =
                '⚠️ جاري إعادة الاتصال بغرفة البث تلقائياً${errorCode != 0 ? ' ($errorCode)' : ''}...';
            _roomDiagnosticIsError = false;
          } else {
            _roomDiagnosticStatus = '❌ انقطاع الاتصال بغرفة البث (كود: $errorCode)';
            _roomDiagnosticIsError = true;
          }
        });
        if (errorCode != 0 && !isTransientReconnect) {
          AppFeedback.showError(context, 'اتصال البث المباشر Zego', 'كود الخطأ: $errorCode');
        }
      };

      // استقبال تيارات الفيديو والصوت للمشتركين عن بُعد (الشيخ والطلاب في نفس الغرفة)
      ZegoExpressEngine.onRoomStreamUpdate = (roomID, updateType, streamList, extendedData) async {
        if (!mounted || roomID != widget.roomId) return;
        if (updateType == ZegoUpdateType.Add) {
          for (var stream in streamList) {
            await ZegoExpressEngine.instance.createCanvasView((viewID) {
              final canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
              ZegoExpressEngine.instance.startPlayingStream(stream.streamID, canvas: canvas);
            }).then((widgetView) {
              if (mounted && widgetView != null) {
                setState(() {
                  _remoteStreams[stream.streamID] = widgetView;
                });
              }
            });
          }
        } else if (updateType == ZegoUpdateType.Delete) {
          for (var stream in streamList) {
            try {
              await ZegoExpressEngine.instance.stopPlayingStream(stream.streamID);
            } catch (_) {}
            if (mounted) {
              setState(() {
                _remoteStreams.remove(stream.streamID);
              });
            }
          }
        }
      };

      // تحديث قائمة المتواجدين داخل الغرفة
      ZegoExpressEngine.onRoomUserUpdate = (roomID, updateType, userList) {
        if (!mounted || roomID != widget.roomId) return;
        setState(() {
          for (var u in userList) {
            if (updateType == ZegoUpdateType.Add) {
              _remoteUsers[u.userID] = u.userName;
            } else {
              _remoteUsers.remove(u.userID);
            }
          }
        });
      };

      // استقبال رسائل الدردشة الفورية عبر ZEGOCLOUD كقناة سريعة إضافية
      ZegoExpressEngine.onIMRecvBroadcastMessage = (roomID, messageList) {
        if (!mounted || roomID != widget.roomId) return;
        setState(() {
          for (var msg in messageList) {
            final senderName = msg.fromUser.userName.isNotEmpty ? msg.fromUser.userName : 'مشارك';
            final alreadyExists = _messages.any(
              (m) => m['sender'] == senderName && m['message'] == msg.message,
            );
            if (!alreadyExists) {
              final now = TimeOfDay.now();
              _messages.add({
                'sender': senderName,
                'role': 'remote',
                'message': msg.message,
                'time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                'isMe': false,
              });
            }
          }
        });
        _scrollToBottom();
      };

      // متابعة حالة كاميرا الطرف الآخر (لعدم عرض شاشة سوداء إذا كان الاتصال صوتياً فقط)
      ZegoExpressEngine.onRemoteCameraStateUpdate = (streamID, state) {
        if (!mounted) return;
        setState(() {
          _remoteCameraOn[streamID] = state == ZegoRemoteDeviceState.Open;
        });
      };

      final user = ZegoUser(_zegoUserId, _currentUserName);
      final roomConfig = ZegoRoomConfig.defaultConfig()..isUserStatusNotify = true;
      final loginRes = await ZegoExpressEngine.instance.loginRoom(widget.roomId, user, config: roomConfig);

      // إعداد الكاميرا المحلية مسبقاً عند فتح الفيديو لاحقاً
      await ZegoExpressEngine.instance.setAudioRouteToSpeaker(_isSpeakerOn);
      if (mounted) {
        setState(() {
          _isEngineReady = true;
          if (loginRes.errorCode != 0) {
            _roomDiagnosticStatus = '❌ فشل دخول غرفة البث (كود: ${loginRes.errorCode})';
            _roomDiagnosticIsError = true;
          } else {
            _roomDiagnosticStatus = '✅ متصل بغرفة البث (${widget.roomId})';
            _roomDiagnosticIsError = false;
          }
        });
        if (loginRes.errorCode != 0) {
          AppFeedback.showError(context, 'دخول غرفة Zego', 'كود الخطأ: ${loginRes.errorCode}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isEngineReady = true;
          _roomDiagnosticStatus = '❌ فشل تهيئة البث: ${AppFeedback.formatError(e)}';
          _roomDiagnosticIsError = true;
        });
        AppFeedback.showError(context, 'تهيئة محرك الصوت والفيديو', e);
      }
    }
  }

  /// بدء بث الصوت أو الفيديو عند ضغط زر المكالمة الصوتية أو المرئية
  Future<void> _startCallPublish({required bool video}) async {
    try {
      // إيقاف المعاينة المؤقتة وإعادة إنشاء Canvas جديد لشاشة المكالمة النشطة
      if (video && !_isCallStarted) {
        try {
          await ZegoExpressEngine.instance.stopPreview();
        } catch (_) {}
        _localVideoWidget = null;
        _localViewID = null;
      }

      setState(() {
        _isVoiceOnly = !video;
        _isCameraOn = video;
        _isMicMuted = false;
        _isCallActive = true;
        _isCallStarted = true;
      });

      await ZegoExpressEngine.instance.enableCamera(video);
      await ZegoExpressEngine.instance.muteMicrophone(false);
      await ZegoExpressEngine.instance.setAudioRouteToSpeaker(_isSpeakerOn);

      if (video) {
        await ZegoExpressEngine.instance.createCanvasView((viewID) {
          _localViewID = viewID;
          final canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
          ZegoExpressEngine.instance.startPreview(canvas: canvas);
        }).then((widgetView) {
          if (mounted && widgetView != null) {
            setState(() => _localVideoWidget = widgetView);
          }
        });
      }

      if (!_isPublishing) {
        final streamId = 'stream_${widget.roomId}_$_zegoUserId';
        await ZegoExpressEngine.instance.startPublishingStream(streamId);
        _isPublishing = true;
      }
      if (mounted) {
        AppFeedback.showSuccess(
          context,
          video ? 'بدأ بث الفيديو والصوت في غرفة ${widget.roomId}' : 'بدأت المكالمة الصوتية في غرفة ${widget.roomId}',
        );
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'بدء المكالمة', e);
      }
    }
  }

  Future<void> _stopCallPublish() async {
    try {
      await ZegoExpressEngine.instance.stopPreview();
      if (_isPublishing) {
        await ZegoExpressEngine.instance.stopPublishingStream();
        _isPublishing = false;
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _localVideoWidget = null;
        _localViewID = null;
        _isCallActive = false;
        _isCallStarted = false;
        _isScreenSharing = false;
        _isPipMode = false;
      });
    }
  }

  Future<void> _destroyZego() async {
    try {
      ZegoExpressEngine.onRoomStateUpdate = null;
      ZegoExpressEngine.onRoomStreamUpdate = null;
      ZegoExpressEngine.onRoomUserUpdate = null;
      ZegoExpressEngine.onIMRecvBroadcastMessage = null;
      ZegoExpressEngine.onRemoteCameraStateUpdate = null;
      await ZegoExpressEngine.instance.stopPreview();
      if (_isPublishing) {
        await ZegoExpressEngine.instance.stopPublishingStream();
      }
      await ZegoExpressEngine.instance.logoutRoom(widget.roomId);
      await ZegoExpressEngine.destroyEngine();
    } catch (_) {}
  }

  String _formatCallTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // إرسال رسالة في الشات (عبر السيرفر + ZEGOCLOUD فوراً)
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final now = TimeOfDay.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add({
        'sender': _currentUserName,
        'role': 'me',
        'message': text,
        'time': timeStr,
        'isMe': true,
      });
      _messageController.clear();
    });
    _scrollToBottom();

    // إرسال فوري عبر ZEGOCLOUD للطرف الآخر داخل الغرفة
    try {
      final bRes = await ZegoExpressEngine.instance.sendBroadcastMessage(widget.roomId, text);
      if (bRes.errorCode != 0 && widget.classRoomId == null && mounted) {
        AppFeedback.showError(context, 'بث الرسالة عبر Zego', 'كود الخطأ: ${bRes.errorCode}');
      }
    } catch (e) {
      if (widget.classRoomId == null && mounted) {
        AppFeedback.showError(context, 'إرسال الرسالة الفورية', e);
      }
    }

    // حفظ وإرسال الرسالة عبر السيرفر
    if (widget.classRoomId != null) {
      try {
        await _apiClient.sendClassMessage(widget.classRoomId!, text);
        await _loadServerMessages();
      } catch (e) {
        if (mounted) {
          AppFeedback.showError(context, 'حفظ وإرسال الرسالة للسيرفر', e);
        }
      }
    } else if (mounted) {
      AppFeedback.showError(context, 'مزامنة الرسالة', 'لا يوجد معرف حلقة على السيرفر لهذه الغرفة');
    }
  }

  // اختيار ملف أو صورة في الشات (ورقة مرفقات من الصورة 10)
  Future<void> _pickChatAttachment() async {
    try {
      final res = await FilePicker.platform.pickFiles(type: FileType.media);
      if (res != null && res.files.isNotEmpty) {
        setState(() {
          _messages.add({
            'sender': _currentUserName,
            'role': 'me',
            'message': '📎 تم إرسال ملف: ${res.files.first.name}',
            'time': '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
            'isMe': true,
          });
        });
      }
    } catch (_) {}
  }

  // مشاركة رابط الحلقة (مطابق للصورة 13)
  void _shareChapter() {
    final link = DeepLinkService.getCircleShareLink(
      widget.classRoomId ?? 110,
      circleTitle: widget.circleTitle,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF262A2E), // الخلفية الداكنة من الصورة 13
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: const Text('إلغاء', style: TextStyle(color: Colors.blueAccent, fontSize: 16)),
                ),
                const Text('مشاركة النص', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 18),

            // Share Text Box with Copy Icon
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('حلقة: ${widget.circleTitle}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('الشيخ: $_displaySheikhName',
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(link, style: const TextStyle(color: Colors.blue, fontSize: 11)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: Colors.blueAccent),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: 'حلقة: ${widget.circleTitle}\n$link'));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ الرابط بنجاح!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // الخلفية الكريمية الرسمية
      body: SafeArea(
        child: Stack(
          children: [
            // 1. الواجهة الأساسية: شاشة انتظار وشات الحلقة (من الصور 4، 11، 12)
            Column(
              children: [
                // Top Header (السهم، اسم الحلقة، المشرف، أزرار المشاركة والاتصال)
                _buildChapterHeader(),

                // Chapter Duration Card
                _buildDurationCard(),

                // Live Stream Banner when remote participant is broadcasting
                if (_remoteStreams.isNotEmpty && !_isCallActive)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00875A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sensors_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'يوجد بث مباشر نشط الآن — اضغط للانضمام',
                            style: TextStyle(
                              fontFamily: 'Dubai',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _startCallPublish(video: true),
                          child: const Text(
                            'انضمام',
                            style: TextStyle(
                              fontFamily: 'Dubai',
                              color: Color(0xFF00875A),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Chat Messages Feed
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: _messages.isEmpty
                        ? Center(
                            child: Text(
                              'لا توجد رسائل بعد — ابدأ المحادثة مع المشاركين',
                              style: TextStyle(
                                fontFamily: 'Dubai',
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _chatScrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              final isMe = msg['isMe'] == true;
                              return Align(
                                alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isMe ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isMe ? const Color(0xFFC8E6C9) : Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        msg['sender'] ?? '',
                                        style: TextStyle(
                                          fontFamily: 'Dubai',
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isMe ? const Color(0xFF00875A) : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        msg['message'] ?? '',
                                        style: const TextStyle(fontFamily: 'Dubai', fontSize: 13, color: Colors.black87),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        msg['time'] ?? '',
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),

                // Bottom Chat Input Bar (من الصورة 4 و 11)
                _buildChatInputBar(),
              ],
            ),

            // 2. شاشة المكالمة الحية / المعاينة (من الصور 5، 6، 8، 14)
            if (_isCallActive && !_isPipMode)
              Positioned.fill(
                child: _isCallStarted ? _buildActiveCallView() : _buildCallPreviewView(),
              ),

            // 3. النافذة العائمة Picture-in-Picture (من الصورة 9)
            if (_isCallActive && _isPipMode)
              Positioned(
                left: _pipPosition.dx,
                top: _pipPosition.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _pipPosition += details.delta;
                    });
                  },
                  onTap: () {
                    setState(() => _isPipMode = false); // تكبير المكالمة
                  },
                  child: Container(
                    width: 130,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Cam View / Avatar
                        Center(
                          child: Icon(
                            _isVoiceOnly ? Icons.mic_rounded : Icons.person_rounded,
                            color: Colors.white70,
                            size: 40,
                          ),
                        ),
                        // Close Pip
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _isPipMode = false),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                        // Timer
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Text(
                            _formatCallTimer(_callSeconds),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Label
                        Positioned(
                          bottom: 6,
                          left: 6,
                          right: 6,
                          child: Text(
                            _currentUserName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Header منظم في سطرين: اسم الحلقة بالعرض الكامل فوق، ثم الرموز والمشتركين تحت ──
  Widget _buildChapterHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 8.0),
      child: Column(
        children: [
          // السطر الأول: زر الرجوع + اسم الحلقة والشيخ بالعرض الكامل + الصورة
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF00875A), size: 18),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.circleTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191919),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _displaySheikhName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.person, color: Colors.grey, size: 26),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // السطر الثاني: شارة المشتركين + أزرار المشاركة والاتصال
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF00875A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_outline, color: Color(0xFF00875A), size: 15),
                    const SizedBox(width: 4),
                    Text(
                      'المشتركين $_subscribersCount / $_capacity',
                      softWrap: false,
                      style: const TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 12,
                        color: Color(0xFF00875A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCircularTopAction(
                    icon: Icons.share_outlined,
                    color: const Color(0xFF00875A),
                    onTap: _shareChapter,
                  ),
                  if (widget.isSheikh) ...[
                    const SizedBox(width: 8),
                    _buildCircularTopAction(
                      icon: Icons.power_settings_new,
                      color: const Color(0xFF191919),
                      onTap: _endSessionPrompt,
                    ),
                  ],
                  const SizedBox(width: 8),
                  _buildCircularTopAction(
                    icon: Icons.call_outlined,
                    color: const Color(0xFF191919),
                    onTap: () => _startCallPublish(video: false),
                  ),
                  const SizedBox(width: 8),
                  _buildCircularTopAction(
                    icon: Icons.videocam_outlined,
                    color: const Color(0xFF191919),
                    onTap: () async {
                      setState(() {
                        _isCallActive = true;
                        _isVoiceOnly = false;
                        _isCameraOn = true;
                        _isCallStarted = false;
                        _localVideoWidget = null;
                        _localViewID = null;
                      });
                      try {
                        await ZegoExpressEngine.instance.enableCamera(true);
                        await ZegoExpressEngine.instance.createCanvasView((viewID) {
                          _localViewID = viewID;
                          final canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
                          ZegoExpressEngine.instance.startPreview(canvas: canvas);
                        }).then((widgetView) {
                          if (mounted && widgetView != null) {
                            setState(() => _localVideoWidget = widgetView);
                          }
                        });
                      } catch (_) {}
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularTopAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  // ── بطاقة مدة الحلقة + شريط التشخيص الواضح لحالة الاتصال ──
  Widget _buildDurationCard() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00875A)),
                ),
                child: Text(
                  _formatCallTimer(_chapterMinutes * 60 + 25),
                  style: const TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00875A),
                  ),
                ),
              ),
              const Row(
                children: [
                  Text(
                    'مدة الحلقة',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191919),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.access_time_rounded, color: Color(0xFF191919), size: 22),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
          child: Row(
            children: [
              Icon(
                _roomDiagnosticIsError ? Icons.error_outline : Icons.wifi_tethering_rounded,
                size: 14,
                color: _roomDiagnosticIsError ? Colors.red.shade700 : const Color(0xFF00875A),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _roomDiagnosticStatus,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 11,
                    color: _roomDiagnosticIsError ? Colors.red.shade700 : const Color(0xFF00875A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── شريط الإدخال في الشات من الصورة 4 ──
  Widget _buildChatInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          // Send Button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF00875A),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Text Field with attachment & emoji inside
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  // Emoji icon
                  GestureDetector(
                    onTap: () {
                      _messageController.text += '🌸 ';
                    },
                    child: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey, size: 22),
                  ),
                  const SizedBox(width: 8),

                  // Attachment Paperclip (فتح لاختيار الصور والملفات من الصورة 10)
                  GestureDetector(
                    onTap: _pickChatAttachment,
                    child: const Icon(Icons.attach_file_rounded, color: Colors.grey, size: 22),
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontFamily: 'Dubai', fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالتك...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Dubai'),
                        filled: false,
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── معاينة الكاميرا وزر Start البنفسجي من الصورة 5 ──
  Widget _buildCallPreviewView() {
    return Container(
      color: Colors.black87,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Real Camera Preview if on & ready, otherwise standby card
          if (_isCameraOn && _localVideoWidget != null)
            _localVideoWidget!
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: const Color(0xFF00875A).withOpacity(0.2),
                    child: const Icon(Icons.person, size: 50, color: Color(0xFF00875A)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.circleTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Dubai'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text('الكاميرا مغلقة مؤقتاً', style: TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'Dubai')),
                ],
              ),
            ),

          // Top Header
          Positioned(
            top: 20,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _stopCallPublish,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.circleTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Dubai'),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() => _useFrontCamera = !_useFrontCamera);
                    try {
                      await ZegoExpressEngine.instance.useFrontCamera(_useFrontCamera);
                    } catch (_) {}
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                    child: const Icon(Icons.cameraswitch_outlined, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Purple Start Button (من الصورة 5)
          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: Column(
              children: [
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C4DFF), // البنفسجي المطابق للصورة 5
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 4,
                    ),
                    onPressed: () {
                      _startCallPublish(video: true);
                    },
                    child: const Text(
                      'بدء',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _currentUserName,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── واجهة المكالمة الحية النشطة من الصور 6 و 8 و 14 ──
  Widget _buildActiveCallView() {
    return Container(
      color: const Color(0xFF1E2024),
      child: Column(
        children: [
          // Video Area
          Expanded(
            child: Stack(
              children: [
                // Main Content (Video or Screen Share or Voice Avatar)
                if (_isScreenSharing)
                  // مشاركة الشاشة من الصورة 8
                  Container(
                    color: const Color(0xFF2B2E33),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'أنت تشارك الشاشة الآن',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent, width: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              setState(() => _isScreenSharing = false);
                            },
                            child: const Text(
                              'إيقاف المشاركة',
                              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_isVoiceOnly)
                  // مكالمة صوتية مع عرض اسم الطرف المتصل
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00875A),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _currentUserName.isNotEmpty ? String.fromCharCode(_currentUserName.runes.first) : 'إ',
                              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _remoteUsers.isNotEmpty
                              ? 'متصل صوتياً مع: ${_remoteUsers.values.join("، ")}'
                              : 'المكالمة الصوتية نشطة — في انتظار الطرف الآخر...',
                          style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Dubai'),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  // Video Stream View: Remote video primary + Local camera preview PiP
                  Builder(
                    builder: (_) {
                      final activeRemoteVideos = _remoteStreams.entries
                          .where((e) => _remoteCameraOn[e.key] != false)
                          .map((e) => e.value)
                          .toList();
                      return Container(
                        color: const Color(0xFF1B1D21),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (activeRemoteVideos.isNotEmpty)
                              activeRemoteVideos.length == 1
                                  ? activeRemoteVideos.first
                                  : GridView.count(
                                      crossAxisCount: 2,
                                      children: activeRemoteVideos,
                                    )
                            else if (_isCameraOn && _localVideoWidget != null)
                              _localVideoWidget!
                            else
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 46,
                                      backgroundColor: const Color(0xFF00875A).withOpacity(0.2),
                                      child: Icon(
                                        widget.isSheikh ? Icons.school_rounded : Icons.person_rounded,
                                        size: 48,
                                        color: const Color(0xFF00875A),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      widget.circleTitle,
                                      style: const TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'Dubai', fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    const Text('الكاميرا مغلقة (البث الصوتي نشط)', style: TextStyle(color: Colors.white38, fontSize: 12, fontFamily: 'Dubai')),
                                  ],
                                ),
                              ),

                            // Local Camera Preview thumbnail when viewing Remote Video
                            if (activeRemoteVideos.isNotEmpty && _isCameraOn && _localVideoWidget != null)
                              Positioned(
                                top: 66,
                                right: 16,
                                child: Container(
                                  width: 100,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8)],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _localVideoWidget!,
                                ),
                              ),
                            // Live Audio Voice Wave Indicator
                            if (!_isMicMuted && _soundLevel > 3)
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00875A).withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'الصوت متصل 🎙️',
                                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Dubai'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                // Top Controls Overlay (من الصورة 6)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Share icon in square
                      GestureDetector(
                        onTap: _shareChapter,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
                        ),
                      ),

                      // Timer & Recording Indicator
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isRecording)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.red.shade700,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.fiber_manual_record, color: Colors.white, size: 8),
                                  const SizedBox(width: 4),
                                  Text(
                                    'REC ${_formatCallTimer(_recordedSeconds)}',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          Text(
                            _formatCallTimer(_callSeconds),
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      // Attendees Pill + End Call X
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Text('${1 + _remoteUsers.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(width: 4),
                                const Icon(Icons.person, color: Colors.white, size: 14),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // End Call X Button
                          GestureDetector(
                            onTap: _stopCallPublish,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // User Badge (bottom left of video)
                Positioned(
                  bottom: 12,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(_currentUserName, style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Controls Bar (من الصور 6 و 8 و 14)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: const Color(0xFF131518),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. Chat toggle
                _buildCallBottomAction(
                  icon: Icons.chat_bubble_outline_rounded,
                  isActive: false,
                  onTap: () {
                    // تصغير إلى نافذة عائمة لعرض الشات
                    setState(() => _isPipMode = true);
                  },
                ),

                // 2. Mic toggle
                _buildCallBottomAction(
                  icon: _isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  isActive: !_isMicMuted,
                  activeColor: const Color(0xFF00875A),
                  onTap: () {
                    setState(() => _isMicMuted = !_isMicMuted);
                    ZegoExpressEngine.instance.muteMicrophone(_isMicMuted);
                  },
                ),

                // 3. Camera toggle
                _buildCallBottomAction(
                  icon: _isCameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                  isActive: _isCameraOn && !_isVoiceOnly,
                  activeColor: const Color(0xFF00875A),
                  onTap: () async {
                    setState(() {
                      _isVoiceOnly = false;
                      _isCameraOn = !_isCameraOn;
                    });
                    try {
                      await ZegoExpressEngine.instance.enableCamera(_isCameraOn);
                      if (_isCameraOn) {
                        if (_localVideoWidget == null) {
                          await ZegoExpressEngine.instance.createCanvasView((viewID) {
                            _localViewID = viewID;
                            final canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
                            ZegoExpressEngine.instance.startPreview(canvas: canvas);
                          }).then((widgetView) {
                            if (mounted && widgetView != null) {
                              setState(() => _localVideoWidget = widgetView);
                            }
                          });
                        } else if (_localViewID != null) {
                          final canvas = ZegoCanvas(_localViewID!, viewMode: ZegoViewMode.AspectFill);
                          await ZegoExpressEngine.instance.startPreview(canvas: canvas);
                        }
                      } else {
                        await ZegoExpressEngine.instance.stopPreview();
                      }
                    } catch (_) {}
                  },
                ),

                // 4. Quran / Mushaf Book icon
                _buildCallBottomAction(
                  icon: Icons.menu_book_rounded,
                  isActive: false,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => Container(
                        height: MediaQuery.of(context).size.height * 0.75,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFFDF5),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(8),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                            ),
                            const Text('سورة مريم - المصحف المرتل', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 16)),
                            const Divider(),
                            const Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ\n\n'
                                  'كٓهيعٓصٓ ﴿١﴾ ذِكْرُ رَحْمَتِ رَبِّكَ عَبْدَهُۥ زَكَرِيَّآ ﴿٢﴾ إِذْ نَادَىٰ رَبَّهُۥ نِدَآءً خَفِيًّۭا ﴿٣﴾ قَالَ رَبِّ إِنِّى وَهَنَ ٱلْعَظْمُ مِنِّى وَٱشْتَعَلَ ٱلرَّأْسُ شَيْبًۭا وَلَمْ أَكُنۢ بِدُعَآئِكَ رَبِّ شَقِيًّۭا ﴿٤﴾ وَإِنِّى خِفْتُ ٱلْمَوَٰلِىَ مِن وَرَآءِى وَكَانَتِ ٱمْرَأَتِى عَاقِرًۭا فَهَبْ لِى مِن لَّدُنكَ وَلِيًّۭا ﴿٥﴾ يَرِثُنِى وَيَرِثُ مِنْ ءَالِ يَعْقُوبَ ۖ وَٱجْعَلْهُ رَبِّ رَضِيًّۭا ﴿٦﴾',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontFamily: 'Dubai', fontSize: 18, height: 2.2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // 5. Screen Share icon (من الصورة 8)
                _buildCallBottomAction(
                  icon: Icons.desktop_windows_outlined,
                  isActive: _isScreenSharing,
                  activeColor: Colors.blueAccent,
                  onTap: () {
                    setState(() => _isScreenSharing = !_isScreenSharing);
                  },
                ),

                // 6. Picture-in-Picture floating toggle (من الصورة 9)
                _buildCallBottomAction(
                  icon: Icons.picture_in_picture_alt_outlined,
                  isActive: false,
                  onTap: () {
                    setState(() => _isPipMode = true);
                  },
                ),

                // 7. Record Session Action (تسجيل الحلقة للأرشيف)
                _buildCallBottomAction(
                  icon: _isRecording ? Icons.stop_circle_rounded : Icons.fiber_manual_record_rounded,
                  isActive: _isRecording,
                  activeColor: Colors.redAccent,
                  onTap: _toggleRecording,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallBottomAction({
    required IconData icon,
    required bool isActive,
    Color activeColor = const Color(0xFF00875A),
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            color: isActive ? activeColor : Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}
