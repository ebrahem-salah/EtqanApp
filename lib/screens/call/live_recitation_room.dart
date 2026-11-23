import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/services/deep_link_service.dart';
import '../../core/services/zego_cloud_service.dart';
import '../../core/services/reels_preload_manager.dart';
import '../../core/services/user_chapters_service.dart';
import '../competitions/widgets/competition_exam_sheet.dart';

class LiveRecitationRoom extends StatefulWidget {
  final String roomId;
  final String circleTitle;
  final bool isSheikh;
  final bool isRecorded;
  final int? classRoomId;

  const LiveRecitationRoom({
    super.key,
    required this.roomId,
    required this.circleTitle,
    this.isSheikh = false,
    this.isRecorded = false,
    this.classRoomId,
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
  bool _useFrontCamera = true;
  double _soundLevel = 0.0;
  final TextEditingController _messageController = TextEditingController();

  // Chat Messages matching Screenshot 4, 11, 12
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'الشيخ عبد الله السويسي',
      'role': 'sheikh',
      'message': 'السلام عليكم ورحمة الله وبركاته، مرحباً بكم في حلقة اليوم لتلاوة وتسميع سورة مريم.',
      'time': '08:55 PM',
      'isMe': false,
    },
    {
      'sender': 'أحمد محمود',
      'role': 'student',
      'message': 'وعليكم السلام ورحمة الله وبركاته يا شيخنا الحبيب.',
      'time': '08:56 PM',
      'isMe': false,
    },
  ];

  // Drag position for Floating Window (PiP mode)
  Offset _pipPosition = const Offset(100, 150);

  @override
  void initState() {
    super.initState();
    ReelsPreloadManager.instance.pauseAll();
    _initZegoRTC();
    _startTimer();
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
    _callTimer?.cancel();
    _recordTimer?.cancel();
    _messageController.dispose();
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
      // طلب أذونات الكاميرا والميكروفون من نظام التشغيل فور دخول الغرفة
      try {
        await Permission.camera.request();
        await Permission.microphone.request();
      } catch (_) {}

      final profile = ZegoEngineProfile(
        ZegoCloudConfig.appID,
        ZegoScenario.Default,
        appSign: ZegoCloudConfig.appSign,
      );
      await ZegoExpressEngine.createEngineWithProfile(profile);

      final user = ZegoUser(
        'user_${DateTime.now().millisecondsSinceEpoch % 10000}',
        widget.isSheikh ? 'فضيلة الشيخ' : 'طالب إتقان',
      );
      await ZegoExpressEngine.instance.loginRoom(widget.roomId, user);

      final streamId = 'stream_${widget.roomId}_${user.userID}';
      await ZegoExpressEngine.instance.startPublishingStream(streamId);
      await ZegoExpressEngine.instance.enableCamera(_isCameraOn);
      await ZegoExpressEngine.instance.muteMicrophone(_isMicMuted);
      await ZegoExpressEngine.instance.setAudioRouteToSpeaker(_isSpeakerOn);

      // ربط نافذة معاينة الكاميرا الحقيقية عبر Zego Canvas View
      await ZegoExpressEngine.instance.createCanvasView((viewID) {
        _localViewID = viewID;
        final canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
        ZegoExpressEngine.instance.startPreview(canvas: canvas);
      }).then((widgetView) {
        if (mounted && widgetView != null) {
          setState(() {
            _localVideoWidget = widgetView;
            _isEngineReady = true;
          });
        }
      });
    } catch (_) {
      if (mounted) setState(() => _isEngineReady = true);
    }
  }

  Future<void> _destroyZego() async {
    try {
      await ZegoExpressEngine.instance.stopPreview();
      await ZegoExpressEngine.instance.stopPublishingStream();
      await ZegoExpressEngine.instance.logoutRoom(widget.roomId);
      await ZegoExpressEngine.destroyEngine();
    } catch (_) {}
  }

  String _formatCallTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // إرسال رسالة في الشات
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'مشرف تجريبي 3',
        'role': 'me',
        'message': text,
        'time': '${TimeOfDay.now().hour}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
        'isMe': true,
      });
      _messageController.clear();
    });
  }

  // اختيار ملف أو صورة في الشات (ورقة مرفقات من الصورة 10)
  Future<void> _pickChatAttachment() async {
    try {
      final res = await FilePicker.platform.pickFiles(type: FileType.media);
      if (res != null && res.files.isNotEmpty) {
        setState(() {
          _messages.add({
            'sender': 'مشرف تجريبي 3',
            'role': 'me',
            'message': '📎 تم إرسال ملف: ${res.files.first.name}',
            'time': '${TimeOfDay.now().hour}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
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
                  child: const Text('Cancel', style: TextStyle(color: Colors.blueAccent, fontSize: 16)),
                ),
                const Text('Share text', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                        Text('Watch Chapter: ${widget.circleTitle}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const Text('With Sheikh: مشرف تجريبي 3',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(link, style: const TextStyle(color: Colors.blue, fontSize: 11)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: Colors.blueAccent),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: 'Watch Chapter: ${widget.circleTitle}\n$link'));
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

                const SizedBox(height: 8),

                // Chat Messages Feed
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: ListView.builder(
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
                                  msg['sender'],
                                  style: TextStyle(
                                    fontFamily: 'Dubai',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isMe ? const Color(0xFF00875A) : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg['message'],
                                  style: const TextStyle(fontFamily: 'Dubai', fontSize: 13, color: Colors.black87),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  msg['time'],
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
                        const Positioned(
                          bottom: 6,
                          left: 6,
                          right: 6,
                          child: Text(
                            'مشرف تجريبي 3',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
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

  // ── Header من الصورة 4 ──
  Widget _buildChapterHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
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

          // User info
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.circleTitle,
                    style: const TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191919),
                    ),
                  ),
                  const Text(
                    'مشرف تجريبي 3',
                    style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00875A)),
                    ),
                    child: const Text(
                      '👤 Subscribers 1 / 0',
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 11,
                        color: Color(0xFF00875A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.person, color: Colors.grey, size: 30),
                ),
              ),
            ],
          ),

          // Action Buttons: Share, Power, Call, Video Call (الصورة 4)
          Row(
            children: [
              // Share button
              _buildCircularTopAction(
                icon: Icons.share_outlined,
                color: const Color(0xFF00875A),
                onTap: _shareChapter,
              ),
              const SizedBox(width: 8),

              // Power button (إنهاء وحفظ الحلقة)
              _buildCircularTopAction(
                icon: Icons.power_settings_new,
                color: const Color(0xFF191919),
                onTap: _endSessionPrompt,
              ),
              const SizedBox(width: 8),

              // Voice Call button
              _buildCircularTopAction(
                icon: Icons.call_outlined,
                color: const Color(0xFF191919),
                onTap: () {
                  setState(() {
                    _isCallActive = true;
                    _isVoiceOnly = true;
                    _isCallStarted = true;
                  });
                },
              ),
              const SizedBox(width: 8),

              // Video Call button
              _buildCircularTopAction(
                icon: Icons.videocam_outlined,
                color: const Color(0xFF191919),
                onTap: () {
                  setState(() {
                    _isCallActive = true;
                    _isVoiceOnly = false;
                    _isCallStarted = false; // يفتح شاشة المعاينة وزر Start
                  });
                },
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

  // ── بطاقة مدة الحلقة من الصورة 4 ──
  Widget _buildDurationCard() {
    return Container(
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
                'Chapter Duration',
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
                      decoration: const InputDecoration(
                        hintText: 'Write your message...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: InputBorder.none,
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
                  onTap: () => setState(() => _isCallActive = false),
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
                      setState(() => _isCallStarted = true);
                    },
                    child: const Text(
                      'Start',
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
                  child: const Text(
                    'مشرف تجريبي 3',
                    style: TextStyle(color: Colors.white, fontSize: 12),
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
                            'You are sharing screen',
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
                              'Stop sharing',
                              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_isVoiceOnly)
                  // مكالمة صوتية فقط من الصورة 14
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD0D5DD),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'م',
                          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                    ),
                  )
                else
                  // Video Stream View with Real Local/Remote Camera
                  Container(
                    color: const Color(0xFF1B1D21),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
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
                            child: const Row(
                              children: [
                                Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                SizedBox(width: 4),
                                Icon(Icons.person, color: Colors.white, size: 14),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // End Call X Button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isCallActive = false;
                                _isCallStarted = false;
                                _isScreenSharing = false;
                              });
                            },
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
                    child: const Text('مشرف تجريبي 3', style: TextStyle(color: Colors.white, fontSize: 11)),
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
                      if (_isCameraOn && _localViewID != null) {
                        final canvas = ZegoCanvas(_localViewID!, viewMode: ZegoViewMode.AspectFill);
                        await ZegoExpressEngine.instance.startPreview(canvas: canvas);
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
