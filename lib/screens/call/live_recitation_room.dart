import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/services/deep_link_service.dart';
import '../../core/services/exam_lock_service.dart';
import '../../core/services/zego_cloud_service.dart';
import '../../core/services/reels_preload_manager.dart';
import '../../core/services/user_chapters_service.dart';
import '../../core/utils/app_feedback.dart';
import '../../providers/auth_provider.dart';
import '../competitions/widgets/competition_exam_sheet.dart';
import '../student/student_record_screen.dart';
import 'widgets/room_mushaf_sheet.dart';

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

class _LiveRecitationRoomState extends State<LiveRecitationRoom> with WidgetsBindingObserver {
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

  // بيانات المشتركين وتقييم كل طالب أثناء التسميع
  List<Map<String, dynamic>> _enrolledStudents = [];
  final Map<int, Map<String, dynamic>> _studentEvaluations = {};
  final Map<int, DateTime> _raisedHands = {};
  final Map<int, int> _studentViolations = {};
  int? _activeEvalStudentId;
  String? _activeEvalStudentName;
  int _evalMajorErrors = 0;
  int _evalHesitations = 0;
  int _evalTajweedNotes = 0;
  String _evalCustomNote = '';
  String _evalNextHomework = '';
  bool _isSavingEval = false;
  int _studentTurnSeconds = 0;

  // صلاحيات الغرفة والمصحف والكتب ومنع الغش (بيد الشيخ)
  bool _allowStudentsMushaf = false;
  bool _manualMushafOverride = false;
  int _syncedMushafSurah = 19;
  int _syncedContentTab = 0; // 0: المصحف, 1: الكتب والشروحات
  String? _syncedBookTitle;
  String? _syncedBookChapter;
  String? _syncedBookText;
  int? _syncedHighlightedLine;
  bool _strictExamMode = false;
  bool _isMushafSheetOpen = false;
  DateTime? _backgroundLeftAt;
  int _studentAppLeaveCount = 0;
  static const String _cmdPrefix = '__ETQAN_CMD__:';

  // Drag position for Floating Window (PiP mode)
  Offset _pipPosition = const Offset(100, 150);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ReelsPreloadManager.instance.pauseAll();
    _applyAutoPresetForCircleText(widget.circleTitle);
    _initUserName();
    _initZegoRTC();
    _startTimer();
    _joinAndLoadRoomData();
  }

  /// الضبط التلقائي حسب نوع الحلقة (تسميع/مسابقة => مصحف مقفول | تلاوة/نورانية/كتب => مفتوح تلقائياً)
  void _applyAutoPresetForCircleText(String titleOrCategory) {
    if (_manualMushafOverride) return;
    final t = titleOrCategory.toLowerCase();
    final isExamOrMemorize = t.contains('حفظ') ||
        t.contains('تسميع') ||
        t.contains('مسابقة') ||
        t.contains('اختبار') ||
        t.contains('مراجعة');
    final isBooksOrLesson = t.contains('كتاب') ||
        t.contains('كتب') ||
        t.contains('شرح') ||
        t.contains('فقه') ||
        t.contains('حديث') ||
        t.contains('سنة') ||
        t.contains('سيرة') ||
        t.contains('جزرية') ||
        t.contains('نورانية');
    final isOpenReading = isBooksOrLesson ||
        t.contains('تلاوة') ||
        t.contains('تصحيح') ||
        t.contains('قراءة') ||
        t.contains('تلقين') ||
        t.contains('تجويد') ||
        t.contains('تفسير');

    if (t.contains('مسابقة') || t.contains('اختبار')) {
      _allowStudentsMushaf = false;
    } else if (isOpenReading && !isExamOrMemorize) {
      _allowStudentsMushaf = true;
      if (isBooksOrLesson) _syncedContentTab = 1;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed || widget.isSheikh) return;
    final bool shouldMonitor = _strictExamMode || _isCallActive || _isStudentMicApproved;
    if (!shouldMonitor) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _backgroundLeftAt = DateTime.now();
      _studentAppLeaveCount++;
      _sendRoomCommand({
        'cmd': 'student_left_app',
        'user_id': _currentUserId,
        'name': _currentUserName,
        'count': _studentAppLeaveCount,
      });
    } else if (state == AppLifecycleState.resumed && _backgroundLeftAt != null) {
      final elapsedSec = DateTime.now().difference(_backgroundLeftAt!).inSeconds;
      _backgroundLeftAt = null;
      if (elapsedSec >= 2 && mounted) {
        _sendRoomCommand({
          'cmd': 'student_returned_app',
          'user_id': _currentUserId,
          'name': _currentUserName,
          'seconds': elapsedSec,
          'count': _studentAppLeaveCount,
        });
        AppFeedback.showError(
          context,
          'تحذير المراقبة',
          'تم رصد خروجك من التطبيق لمدة $elapsedSec ثانية وإبلاغ الشيخ بذلك (المخالفة رقم $_studentAppLeaveCount)',
        );
      }
    }
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
    await _loadServerAppreciations();
    await _loadServerMessages();
    _messagesPollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _loadServerMessages(isPoll: true);
    });
  }

  Future<void> _loadClassDetails({bool silent = false}) async {
    if (widget.classRoomId == null || _isDisposed) return;
    try {
      final res = await _apiClient.getClassDetails(widget.classRoomId!);
      if (res.statusCode == 200 && res.data != null && mounted && !_isDisposed) {
        final data = res.data['data'];
        if (data is Map<String, dynamic>) {
          final sheikhObj = data['sheikh'] ?? data['creator']?['user'] ?? data['creator'];
          final sName = sheikhObj?['name']?.toString();
          final List rawStudents = data['students'] is List ? data['students'] : [];
          final parsedStudents = rawStudents.map<Map<String, dynamic>>((s) {
            final userObj = s['user'] is Map ? s['user'] : {};
            final int? sid = int.tryParse('${s['id'] ?? userObj['id'] ?? ''}');
            final int? uid = int.tryParse('${userObj['id'] ?? s['user_id'] ?? s['id'] ?? ''}');
            final studentName = (userObj['name'] ?? s['name'] ?? 'طالب').toString();
            return {
              'student_id': sid,
              'user_id': uid,
              'name': studentName,
              'avatar_url': userObj['avatar_url'],
              'code': s['code']?.toString() ?? '',
              'general_rating': s['general_rating'] ?? s['overall_rating'] ?? 0,
              'session_rating': s['session_rating'],
            };
          }).where((s) => s['student_id'] != null).toList();

          final int srvCount = int.tryParse('${data['students_count'] ?? parsedStudents.length}') ??
              parsedStudents.length;
          final int liveConnected = 1 + _remoteUsers.length;

          setState(() {
            if (sName != null && sName.isNotEmpty && !sName.contains('???')) {
              _displaySheikhName = sName;
            }
            final catName = data['category']?['name']?.toString() ?? '';
            if (catName.isNotEmpty && !_manualMushafOverride) {
              _applyAutoPresetForCircleText('${widget.circleTitle} $catName');
            }
            _enrolledStudents = parsedStudents;
            _subscribersCount = srvCount > liveConnected ? srvCount : liveConnected;
            if (data['capacity'] != null) {
              _capacity = int.tryParse('${data['capacity']}') ?? _capacity;
            }
          });
        }
      }
    } catch (e) {
      if (!silent && mounted && !_isDisposed) {
        AppFeedback.showError(context, 'جلب تفاصيل الحلقة', e);
      }
    }
  }

  Future<void> _loadServerAppreciations() async {
    if (widget.classRoomId == null || _isDisposed) return;
    try {
      final res = await _apiClient.getClassAppreciations(widget.classRoomId!);
      if (res.statusCode == 200 && res.data != null && mounted && !_isDisposed) {
        final List items = res.data['data'] ?? [];
        setState(() {
          for (final item in items) {
            final int? sid = int.tryParse('${item['student_id'] ?? ''}');
            if (sid == null) continue;
            final String msg = item['message']?.toString() ?? '';
            final String status = msg.contains('[غياب]')
                ? 'absent'
                : (msg.contains('[لم يُسمّع]') ? 'not_recited' : 'present');
            _studentEvaluations[sid] = {
              'student_id': sid,
              'type': item['type']?.toString() ?? 'thank',
              'message': msg,
              'attendance_status': status,
              'scoreText': _extractScoreFromMessage(msg),
              'savedOnServer': true,
            };
          }
        });
      }
    } catch (_) {}
  }

  String _extractScoreFromMessage(String msg) {
    if (msg.contains('[غياب]')) return 'غائب ❌';
    if (msg.contains('[لم يُسمّع]')) return 'لم يُسمّع ⚠️';
    final match = RegExp(r'(\d+(?:\.\d+)?)\s*/\s*10').firstMatch(msg);
    if (match != null) return '${match.group(1)}/10';
    return 'تم التقييم';
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
              'image_url': (msg['image_url'] ?? '').toString(),
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
          if (_activeEvalStudentId != null) {
            _studentTurnSeconds++;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    ExamLockService.instance.setSecureScreen(false);
    ExamLockService.instance.stopLockTask();
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

  List<Map<String, dynamic>> _getMergedParticipantsList() {
    final List<Map<String, dynamic>> list = [];
    final Set<int> seenUserIds = {};
    final Set<String> seenNames = {};

    bool isOnlineByIdsOrName(int? uid, String name) {
      if (_currentUserId != null && uid == _currentUserId) return true;
      for (final entry in _remoteUsers.entries) {
        if (uid != null && entry.key.startsWith('u_${uid}_')) return true;
        if (name.isNotEmpty && entry.value.trim() == name.trim()) return true;
      }
      return false;
    }

    for (final s in _enrolledStudents) {
      final int? sid = s['student_id'] as int?;
      final int? uid = s['user_id'] as int?;
      final String name = (s['name'] ?? 'طالب').toString();
      if (uid != null) seenUserIds.add(uid);
      seenNames.add(name.trim());
      list.add({
        'student_id': sid,
        'user_id': uid,
        'name': name,
        'isOnline': isOnlineByIdsOrName(uid, name),
        'handRaised': (uid != null && _raisedHands.containsKey(uid)) ||
            (sid != null && _raisedHands.containsKey(sid)),
        'raisedAt': _raisedHands[uid] ?? _raisedHands[sid],
        'violations': _studentViolations[uid] ?? _studentViolations[sid] ?? 0,
        'evaluation': sid != null ? _studentEvaluations[sid] : null,
      });
    }

    // أي متصل عبر Zego لم يظهر بعد في students من السيرفر
    for (final entry in _remoteUsers.entries) {
      int? parsedUid;
      final match = RegExp(r'^u_(\d+)_').firstMatch(entry.key);
      if (match != null) parsedUid = int.tryParse(match.group(1)!);
      final name = entry.value.isNotEmpty ? entry.value : 'مشارك';
      if (parsedUid != null && seenUserIds.contains(parsedUid)) continue;
      if (seenNames.contains(name.trim())) continue;
      seenNames.add(name.trim());
      list.add({
        'student_id': parsedUid,
        'user_id': parsedUid,
        'name': name,
        'isOnline': true,
        'handRaised': parsedUid != null && _raisedHands.containsKey(parsedUid),
        'raisedAt': parsedUid != null ? _raisedHands[parsedUid] : null,
        'violations': parsedUid != null ? (_studentViolations[parsedUid] ?? 0) : 0,
        'evaluation': parsedUid != null ? _studentEvaluations[parsedUid] : null,
      });
    }

    // وضع الطالب الحالي إن لم يكن مضافاً بعد
    if (_currentUserId != null && !seenUserIds.contains(_currentUserId)) {
      list.insert(0, {
        'student_id': _currentUserId,
        'user_id': _currentUserId,
        'name': _currentUserName,
        'isOnline': true,
        'handRaised': _isHandRaised,
        'raisedAt': _raisedHands[_currentUserId],
        'violations': _studentAppLeaveCount,
        'evaluation': _studentEvaluations[_currentUserId],
      });
    }

    // ترتيب القائمة: رافعو الأيدي ✋ أولاً بالترتيب الزمني ثم المتصلون ثم الباقون
    list.sort((a, b) {
      final bool ha = a['handRaised'] == true;
      final bool hb = b['handRaised'] == true;
      if (ha != hb) return ha ? -1 : 1;
      if (ha && hb) {
        final da = a['raisedAt'] as DateTime?;
        final db = b['raisedAt'] as DateTime?;
        if (da != null && db != null) return da.compareTo(db);
      }
      final bool oa = a['isOnline'] == true;
      final bool ob = b['isOnline'] == true;
      if (oa != ob) return oa ? -1 : 1;
      return 0;
    });

    return list;
  }

  Future<void> _sendRoomCommand(Map<String, dynamic> cmd) async {
    try {
      await ZegoExpressEngine.instance.sendBroadcastMessage(
        widget.roomId,
        '$_cmdPrefix${jsonEncode(cmd)}',
      );
    } catch (_) {}
  }

  void _handleRoomCommand(Map<String, dynamic> cmd, String senderName) {
    if (!mounted || _isDisposed) return;
    final String type = (cmd['cmd'] ?? '').toString();
    switch (type) {
      case 'hand_raise':
        final int? uid = int.tryParse('${cmd['user_id'] ?? ''}');
        final bool raised = cmd['raised'] == true;
        final String name = (cmd['name'] ?? senderName).toString();
        setState(() {
          if (uid != null) {
            if (raised) {
              _raisedHands[uid] = DateTime.now();
            } else {
              _raisedHands.remove(uid);
            }
          }
        });
        if (widget.isSheikh && raised) {
          AppFeedback.showSuccess(context, '✋ الطالب $name يرفع يده لطلب التسميع');
        }
        break;

      case 'mic_permission':
        final int? targetUid = int.tryParse('${cmd['target_user_id'] ?? ''}');
        final bool approved = cmd['approved'] == true;
        if (!widget.isSheikh && targetUid != null && targetUid == _currentUserId) {
          setState(() {
            _isStudentMicApproved = approved;
            _isMicMuted = !approved;
            if (approved) _isHandRaised = false;
          });
          try {
            ZegoExpressEngine.instance.muteMicrophone(_isMicMuted);
          } catch (_) {}
          if (approved) {
            AppFeedback.showSuccess(context, '🎙️ أذن لك الشيخ بالتسميع الآن — المايك مفتوح');
          } else {
            AppFeedback.showError(context, 'صلاحية الصوت', 'تم كتم المايك من قِبل الشيخ');
          }
        }
        break;

      case 'mute_all':
        if (!widget.isSheikh) {
          setState(() {
            _isStudentMicApproved = false;
            _isMicMuted = true;
          });
          try {
            ZegoExpressEngine.instance.muteMicrophone(true);
          } catch (_) {}
          AppFeedback.showSuccess(context, '🔇 قام الشيخ بكتم جميع الطلاب للاستماع');
        }
        break;

      case 'mushaf_lock':
        final bool allowed = cmd['allowed'] == true;
        final int surah = int.tryParse('${cmd['surah'] ?? _syncedMushafSurah}') ?? _syncedMushafSurah;
        if (!widget.isSheikh) {
          setState(() {
            _allowStudentsMushaf = allowed;
            _syncedMushafSurah = surah.clamp(1, 114);
            if (cmd.containsKey('tab')) {
              _syncedContentTab = int.tryParse('${cmd['tab'] ?? 0}') ?? 0;
            }
          });
          if (!allowed && _isMushafSheetOpen && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            AppFeedback.showError(context, 'قفل المحتوى', 'أغلق الشيخ المصحف والكتب عن الطلاب الآن للتسميع غيباً');
          }
        }
        break;

      case 'library_sync':
        if (!widget.isSheikh) {
          final bool allowed = cmd['allowed'] == true;
          final int? hl = int.tryParse('${cmd['highlighted_line'] ?? ''}');
          setState(() {
            _allowStudentsMushaf = allowed;
            _syncedContentTab = 1;
            _syncedBookTitle = cmd['title']?.toString();
            _syncedBookChapter = cmd['chapter']?.toString();
            _syncedBookText = cmd['text']?.toString();
            _syncedHighlightedLine = hl;
          });
          if (allowed && _syncedBookTitle != null && hl == null) {
            AppFeedback.showSuccess(context, '📚 فتح الشيخ شرح: $_syncedBookTitle');
          }
        }
        break;

      case 'strict_mode':
        final bool enabled = cmd['enabled'] == true;
        if (!widget.isSheikh) {
          setState(() {
            _strictExamMode = enabled;
            if (enabled) {
              _allowStudentsMushaf = false;
              _isPipMode = false;
              _isScreenSharing = false;
            }
          });
          ExamLockService.instance.setSecureScreen(enabled);
          if (enabled) {
            ExamLockService.instance.startLockTask();
            if (_isMushafSheetOpen && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            AppFeedback.showError(
              context,
              'وضع المراقبة المشدد 🔒',
              'فعّل الشيخ وضع التسميع المشدد: يُمنع مغادرة التطبيق أو فتح المصحف',
            );
          } else {
            ExamLockService.instance.stopLockTask();
            AppFeedback.showSuccess(context, 'تم إنهاء وضع المراقبة المشدد');
          }
        }
        break;

      case 'student_left_app':
        final int? uid = int.tryParse('${cmd['user_id'] ?? ''}');
        final int cnt = int.tryParse('${cmd['count'] ?? 1}') ?? 1;
        final String name = (cmd['name'] ?? senderName).toString();
        if (widget.isSheikh) {
          if (uid != null) setState(() => _studentViolations[uid] = cnt);
          AppFeedback.showError(context, 'تنبيه مراقبة', '⚠️ الطالب $name غادر شاشة التطبيق الآن (مخالفة $cnt)');
        }
        break;

      case 'student_returned_app':
        final int secs = int.tryParse('${cmd['seconds'] ?? 0}') ?? 0;
        final String name = (cmd['name'] ?? senderName).toString();
        if (widget.isSheikh) {
          AppFeedback.showError(context, 'عودة الطالب', '⚠️ عاد الطالب $name بعد الخروج لمدة $secs ثانية');
        }
        break;

      case 'student_camera_off':
        final String name = (cmd['name'] ?? senderName).toString();
        if (widget.isSheikh) {
          AppFeedback.showError(context, 'تنبيه الكاميرا', '📷 أغلق الطالب $name الكاميرا أثناء دوره');
        }
        break;

      case 'student_eval_result':
        final int? targetUid = int.tryParse('${cmd['target_user_id'] ?? ''}');
        final String scoreText = (cmd['score'] ?? '').toString();
        if (!widget.isSheikh && targetUid != null && targetUid == _currentUserId) {
          AppFeedback.showSuccess(context, '🌟 اعتمد الشيخ تقييم تلاوتك: $scoreText');
        }
        break;
    }
  }

  void _toggleHandRaise() {
    setState(() => _isHandRaised = !_isHandRaised);
    _sendRoomCommand({
      'cmd': 'hand_raise',
      'user_id': _currentUserId,
      'name': _currentUserName,
      'raised': _isHandRaised,
    });
    AppFeedback.showSuccess(
      context,
      _isHandRaised ? '✋ تم رفع يدك لطلب التسميع عند الشيخ' : 'تم خفض اليد',
    );
  }

  void _toggleStudentsMushaf([bool? forceVal]) {
    final next = forceVal ?? !_allowStudentsMushaf;
    setState(() {
      _manualMushafOverride = true;
      _allowStudentsMushaf = next;
    });
    _sendRoomCommand({
      'cmd': 'mushaf_lock',
      'allowed': next,
      'surah': _syncedMushafSurah,
    });
    AppFeedback.showSuccess(
      context,
      next ? '📖 تم فتح المصحف للطلاب' : '🔒 تم قفل المصحف عن الطلاب للتسميع غيباً',
    );
  }

  void _toggleStrictMode([bool? forceVal]) {
    final next = forceVal ?? !_strictExamMode;
    setState(() {
      _strictExamMode = next;
      if (next) _allowStudentsMushaf = false;
    });
    _sendRoomCommand({'cmd': 'strict_mode', 'enabled': next});
    AppFeedback.showSuccess(
      context,
      next ? '🔒 تم تفعيل وضع المراقبة المشدد للطلاب' : 'تم إيقاف وضع المراقبة المشدد',
    );
  }

  void _muteAllStudents() {
    _sendRoomCommand({'cmd': 'mute_all'});
    AppFeedback.showSuccess(context, '🔇 تم إرسال أمر كتم جميع الطلاب');
  }

  Future<void> _openRoomMushaf() async {
    if (!widget.isSheikh && (!_allowStudentsMushaf || _strictExamMode)) {
      AppFeedback.showError(
        context,
        'المحتوى مقفول 🔒',
        'قام الشيخ بإغلاق المصحف والكتب عن الطلاب أثناء التسميع غيباً',
      );
      return;
    }
    _isMushafSheetOpen = true;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RoomMushafSheet(
        initialTabIndex: _syncedContentTab,
        initialSurah: _syncedMushafSurah,
        initialBookTitle: _syncedBookTitle,
        initialBookChapter: _syncedBookChapter,
        initialBookText: _syncedBookText,
        initialHighlightedLine: _syncedHighlightedLine,
        isSheikh: widget.isSheikh,
        initialAllowedForStudents: _allowStudentsMushaf,
        onSurahChanged: (surahNum) {
          setState(() {
            _syncedContentTab = 0;
            _syncedMushafSurah = surahNum;
          });
          if (widget.isSheikh) {
            _sendRoomCommand({
              'cmd': 'mushaf_lock',
              'allowed': _allowStudentsMushaf,
              'surah': surahNum,
              'tab': 0,
            });
          }
        },
        onLibrarySynced: (title, chapter, text, hl) {
          setState(() {
            _syncedContentTab = 1;
            _syncedBookTitle = title;
            _syncedBookChapter = chapter;
            _syncedBookText = text;
            _syncedHighlightedLine = hl;
          });
          if (widget.isSheikh) {
            _sendRoomCommand({
              'cmd': 'library_sync',
              'allowed': _allowStudentsMushaf,
              'title': title,
              'chapter': chapter,
              'text': text,
              'highlighted_line': hl,
            });
          }
        },
        onShareAttachment: _pickChatAttachment,
        onToggleAllowForStudents: (allowed) => _toggleStudentsMushaf(allowed),
      ),
    );
    _isMushafSheetOpen = false;
  }

  double get _currentEvalScore {
    final s = 10.0 - (_evalMajorErrors * 1.0) - (_evalHesitations * 0.5) - (_evalTajweedNotes * 0.25);
    return s < 0 ? 0.0 : s;
  }

  void _startEvaluatingStudent(Map<String, dynamic> student) {
    final int? sid = student['student_id'] as int?;
    final int? uid = student['user_id'] as int? ?? sid;
    final String name = (student['name'] ?? 'طالب').toString();
    if (sid == null) {
      AppFeedback.showError(context, 'تحديد الطالب', 'لا يوجد معرف للطالب على السيرفر بعد');
      return;
    }
    setState(() {
      _activeEvalStudentId = sid;
      _activeEvalStudentName = name;
      _studentTurnSeconds = 0;
      if (uid != null) _raisedHands.remove(uid);
      _raisedHands.remove(sid);
      final existing = _studentEvaluations[sid];
      _evalMajorErrors = existing?['majorErrors'] as int? ?? 0;
      _evalHesitations = existing?['hesitations'] as int? ?? 0;
      _evalTajweedNotes = existing?['tajweedNotes'] as int? ?? 0;
      _evalCustomNote = existing?['notes']?.toString() ?? '';
      _evalNextHomework = existing?['homework']?.toString() ?? '';
    });
    _sendRoomCommand({
      'cmd': 'mic_permission',
      'target_user_id': uid,
      'approved': true,
    });
  }

  Future<void> _showEvalNoteDialog() async {
    final noteCtrl = TextEditingController(text: _evalCustomNote);
    final hwCtrl = TextEditingController(text: _evalNextHomework);
    final res = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'ملاحظات والمقرر القادم — ${_activeEvalStudentName ?? ''}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 15),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: noteCtrl,
                maxLines: 2,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'ملاحظات الشيخ والتجويد (اختياري)',
                  hintStyle: const TextStyle(fontFamily: 'Dubai', fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: hwCtrl,
                maxLines: 2,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'المقرر القادم / الواجب (مثال: البقرة ١-٢٠)',
                  hintStyle: const TextStyle(fontFamily: 'Dubai', fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Dubai', color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00875A)),
            onPressed: () => Navigator.pop(ctx, {
              'note': noteCtrl.text.trim(),
              'homework': hwCtrl.text.trim(),
            }),
            child: const Text('حفظ', style: TextStyle(fontFamily: 'Dubai', color: Colors.white)),
          ),
        ],
      ),
    );
    if (res != null && mounted) {
      setState(() {
        _evalCustomNote = res['note'] ?? '';
        _evalNextHomework = res['homework'] ?? '';
      });
    }
  }

  Future<void> _saveActiveStudentEvaluation() async {
    final int? sid = _activeEvalStudentId;
    final String studentName = _activeEvalStudentName ?? 'طالب';
    if (sid == null || _isSavingEval) return;

    final double score = _currentEvalScore;
    final String summary =
        'التقييم: ${score.toStringAsFixed(1)}/10 | أخطاء جلية: $_evalMajorErrors | تلعثم: $_evalHesitations | تجويد: $_evalTajweedNotes'
        '${_evalCustomNote.isNotEmpty ? ' | ملاحظات: $_evalCustomNote' : ''}'
        '${_evalNextHomework.isNotEmpty ? ' | المقرر القادم: $_evalNextHomework' : ''}';

    setState(() => _isSavingEval = true);
    bool savedOnServer = false;
    if (widget.classRoomId != null) {
      try {
        await _apiClient.sendAppreciation(widget.classRoomId!, {
          'appreciations': [
            {
              'student_id': sid,
              'type': score >= 7.0 ? 'thank' : 'warning',
              'message': summary,
            }
          ],
        });
        savedOnServer = true;
      } catch (e) {
        if (mounted) {
          AppFeedback.showError(context, 'حفظ تقييم الطالب على السيرفر', e);
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _isSavingEval = false;
      _studentEvaluations[sid] = {
        'student_id': sid,
        'name': studentName,
        'score': score,
        'scoreText': '${score.toStringAsFixed(1)}/10',
        'majorErrors': _evalMajorErrors,
        'hesitations': _evalHesitations,
        'tajweedNotes': _evalTajweedNotes,
        'notes': _evalCustomNote,
        'homework': _evalNextHomework,
        'message': summary,
        'savedOnServer': savedOnServer,
      };
      if (savedOnServer) {
        _activeEvalStudentId = null;
        _activeEvalStudentName = null;
        _evalMajorErrors = 0;
        _evalHesitations = 0;
        _evalTajweedNotes = 0;
        _evalCustomNote = '';
        _evalNextHomework = '';
      }
    });

    if (savedOnServer) {
      _sendRoomCommand({
        'cmd': 'student_eval_result',
        'target_user_id': sid,
        'score': '${score.toStringAsFixed(1)}/10',
        'summary': summary,
      });
      setState(() => _studentTurnSeconds = 0);
      AppFeedback.showSuccess(
        context,
        'تم حفظ تقييم $studentName (${score.toStringAsFixed(1)}/10) — يمكنك اختيار الطالب التالي',
      );
    }
  }

  String _buildAttendanceMessage(String status) {
    if (status == 'absent') {
      return '[غياب] تغيّب الطالب عن حضور حلقة (${widget.circleTitle}) اليوم — يرجى متابعة ولي الأمر';
    }
    return '[لم يُسمّع] حضر الطالب حلقة (${widget.circleTitle}) ولم يُسمّع المقرر المطلوب — يرجى متابعة ولي الأمر';
  }

  Future<void> _markStudentAttendance(Map<String, dynamic> student, String status) async {
    final int? sid = student['student_id'] as int?;
    final String studentName = (student['name'] ?? 'طالب').toString();
    if (sid == null) {
      AppFeedback.showError(context, 'تسجيل الحضور', 'لا يوجد معرف للطالب على السيرفر بعد');
      return;
    }

    final String msg = _buildAttendanceMessage(status);
    final String badgeText = status == 'absent' ? 'غائب ❌' : 'لم يُسمّع ⚠️';
    bool savedOnServer = false;

    if (widget.classRoomId != null) {
      try {
        await _apiClient.sendAppreciation(widget.classRoomId!, {
          'appreciations': [
            {
              'student_id': sid,
              'type': 'warning',
              'message': msg,
            }
          ],
        });
        savedOnServer = true;
      } catch (e) {
        if (mounted) AppFeedback.showError(context, 'حفظ سجل الحضور والغياب', e);
      }
    }

    if (!mounted) return;
    setState(() {
      _studentEvaluations[sid] = {
        'student_id': sid,
        'name': studentName,
        'attendance_status': status,
        'type': 'warning',
        'message': msg,
        'scoreText': badgeText,
        'savedOnServer': savedOnServer,
      };
      if (_activeEvalStudentId == sid) {
        _activeEvalStudentId = null;
        _activeEvalStudentName = null;
      }
    });

    if (savedOnServer) {
      _sendRoomCommand({
        'cmd': 'student_eval_result',
        'target_user_id': sid,
        'score': badgeText,
        'summary': msg,
      });
      AppFeedback.showSuccess(
        context,
        status == 'absent'
            ? 'تم تسجيل غياب $studentName وإرسال تنبيه لولي الأمر ❌'
            : 'تم تسجيل أن $studentName لم يُسمّع وإرسال تنبيه لولي الأمر ⚠️',
      );
    }
  }

  Future<void> _batchRecordUnmarkedAttendance(List<Map<String, dynamic>> targets) async {
    if (targets.isEmpty || widget.classRoomId == null) return;
    final List<Map<String, dynamic>> payload = [];
    for (final s in targets) {
      final int? sid = s['student_id'] as int?;
      if (sid == null) continue;
      final String status = s['isOnline'] == true ? 'not_recited' : 'absent';
      final String msg = _buildAttendanceMessage(status);
      payload.add({
        'student_id': sid,
        'type': 'warning',
        'message': msg,
      });
      _studentEvaluations[sid] = {
        'student_id': sid,
        'name': (s['name'] ?? 'طالب').toString(),
        'attendance_status': status,
        'type': 'warning',
        'message': msg,
        'scoreText': status == 'absent' ? 'غائب ❌' : 'لم يُسمّع ⚠️',
        'savedOnServer': true,
      };
    }
    if (payload.isEmpty) return;
    try {
      await _apiClient.sendAppreciation(widget.classRoomId!, {
        'appreciations': payload,
      });
    } catch (_) {}
  }

  Future<void> _showParticipantsAndEvaluateSheet() async {
    await _loadClassDetails(silent: true);
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final participants = _getMergedParticipantsList();
            return Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.72),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00875A)),
                        onPressed: () async {
                          await _loadClassDetails(silent: true);
                          await _loadServerAppreciations();
                          if (ctx.mounted) setSheetState(() {});
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'المشتركون في الحلقة (${participants.length} / $_capacity)',
                            style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'متصل بالبث الآن: ${1 + _remoteUsers.length} | تم تقييمهم: ${_studentEvaluations.length}',
                            style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  if (widget.isSheikh) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: [
                          ActionChip(
                            avatar: Icon(
                              _allowStudentsMushaf ? Icons.menu_book_rounded : Icons.lock_outline,
                              size: 16,
                              color: _allowStudentsMushaf ? const Color(0xFF00875A) : Colors.deepOrange,
                            ),
                            label: Text(
                              _allowStudentsMushaf ? 'المصحف مفتوح للطلاب' : 'المصحف مقفول عن الطلاب',
                              style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              _toggleStudentsMushaf();
                              setSheetState(() {});
                            },
                          ),
                          ActionChip(
                            avatar: Icon(
                              Icons.security_rounded,
                              size: 16,
                              color: _strictExamMode ? Colors.red : Colors.grey.shade700,
                            ),
                            label: Text(
                              _strictExamMode ? 'وضع المراقبة: مُفعّل' : 'تفعيل المراقبة المشددة',
                              style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              _toggleStrictMode();
                              setSheetState(() {});
                            },
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.volume_off_rounded, size: 16, color: Colors.black87),
                            label: const Text(
                              'كتم جميع الطلاب',
                              style: TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            onPressed: _muteAllStudents,
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (participants.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: Text(
                        'لا يوجد مشتركين منضمين لهذه الحلقة حتى الآن',
                        style: TextStyle(fontFamily: 'Dubai', fontSize: 13, color: Colors.grey.shade600),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: participants.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, idx) {
                          final student = participants[idx];
                          final int? sid = student['student_id'] as int?;
                          final String name = (student['name'] ?? 'طالب').toString();
                          final bool isOnline = student['isOnline'] == true;
                          final bool handRaised = student['handRaised'] == true;
                          final int violations = student['violations'] as int? ?? 0;
                          final eval = student['evaluation'] as Map<String, dynamic>?;
                          final bool isCurrentlyEvaluating = sid != null && sid == _activeEvalStudentId;

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isCurrentlyEvaluating
                                  ? const Color(0xFFE8F5E9)
                                  : (handRaised ? const Color(0xFFFFF8E1) : const Color(0xFFFAFAFA)),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isCurrentlyEvaluating
                                    ? const Color(0xFF00875A)
                                    : (handRaised ? Colors.amber.shade700 : Colors.grey.shade200),
                              ),
                            ),
                            child: Row(
                              children: [
                                if (widget.isSheikh)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isCurrentlyEvaluating
                                              ? const Color(0xFF005F3F)
                                              : const Color(0xFF00875A),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          minimumSize: Size.zero,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(bCtx);
                                          _startEvaluatingStudent(student);
                                        },
                                        child: Text(
                                          isCurrentlyEvaluating
                                              ? 'يسمّع الآن'
                                              : (eval != null ? 'تقييم التلاوة' : 'فتح المايك والتقييم'),
                                          style: const TextStyle(
                                            fontFamily: 'Dubai',
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (sid != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                await _markStudentAttendance(student, 'absent');
                                                if (ctx.mounted) setSheetState(() {});
                                              },
                                              borderRadius: BorderRadius.circular(8),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: eval?['attendance_status'] == 'absent'
                                                      ? Colors.red.shade600
                                                      : Colors.red.shade50,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.red.shade300),
                                                ),
                                                child: Text(
                                                  'غائب ❌',
                                                  style: TextStyle(
                                                    fontFamily: 'Dubai',
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: eval?['attendance_status'] == 'absent'
                                                        ? Colors.white
                                                        : Colors.red.shade700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            InkWell(
                                              onTap: () async {
                                                await _markStudentAttendance(student, 'not_recited');
                                                if (ctx.mounted) setSheetState(() {});
                                              },
                                              borderRadius: BorderRadius.circular(8),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: eval?['attendance_status'] == 'not_recited'
                                                      ? Colors.orange.shade700
                                                      : Colors.orange.shade50,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.orange.shade300),
                                                ),
                                                child: Text(
                                                  'لم يُسمّع ⚠️',
                                                  style: TextStyle(
                                                    fontFamily: 'Dubai',
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: eval?['attendance_status'] == 'not_recited'
                                                        ? Colors.white
                                                        : Colors.orange.shade900,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: sid == null
                                        ? null
                                        : () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => StudentRecordScreen(
                                                  studentId: sid,
                                                  studentName: name,
                                                ),
                                              ),
                                            );
                                          },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${handRaised ? '✋ ' : ''}$name',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Dubai',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      const SizedBox(height: 2),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 2,
                                        alignment: WrapAlignment.end,
                                        children: [
                                          if (violations > 0)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade50,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '⚠️ خروج: $violations',
                                                style: TextStyle(
                                                  fontFamily: 'Dubai',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red.shade700,
                                                ),
                                              ),
                                            ),
                                          if (eval != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: eval['attendance_status'] == 'absent'
                                                    ? Colors.red.shade50
                                                    : (eval['attendance_status'] == 'not_recited'
                                                        ? Colors.orange.shade50
                                                        : const Color(0xFFD3EADB)),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                eval['attendance_status'] == 'absent' ||
                                                        eval['attendance_status'] == 'not_recited'
                                                    ? '${eval['scoreText']}'
                                                    : '${eval['scoreText'] ?? 'تم التقييم'} ✓',
                                                style: TextStyle(
                                                  fontFamily: 'Dubai',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: eval['attendance_status'] == 'absent'
                                                      ? Colors.red.shade700
                                                      : (eval['attendance_status'] == 'not_recited'
                                                          ? Colors.orange.shade900
                                                          : const Color(0xFF00875A)),
                                                ),
                                              ),
                                            ),
                                          Text(
                                            isOnline ? 'متصل بالبث الآن 🟢' : 'مسجل بالحلقة',
                                            style: TextStyle(
                                              fontFamily: 'Dubai',
                                              fontSize: 11,
                                              color: isOnline ? const Color(0xFF00875A) : Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                ),
                                const SizedBox(width: 10),
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFF00875A).withOpacity(0.12),
                                  child: Text(
                                    name.isNotEmpty ? String.fromCharCode(name.runes.first) : 'ط',
                                    style: const TextStyle(
                                      fontFamily: 'Dubai',
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00875A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLiveStudentEvaluationOverlay({bool darkTheme = true}) {
    final score = _currentEvalScore;
    final Color scoreColor = score >= 9.0
        ? const Color(0xFF00C48C)
        : (score >= 7.0 ? const Color(0xFFFFB300) : const Color(0xFFFF5252));

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: darkTheme ? const Color(0xEE181A1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: darkTheme ? const Color(0xFF00875A).withOpacity(0.75) : const Color(0xFF00875A),
          width: 1.3,
        ),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // السطر العلوي: اسم الطالب + الدرجة اللحظية + ملاحظة + إغلاق
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _activeEvalStudentId = null),
                child: Icon(Icons.close, size: 18, color: darkTheme ? Colors.white60 : Colors.grey),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showEvalNoteDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _evalCustomNote.isNotEmpty
                        ? const Color(0xFF00875A).withOpacity(0.25)
                        : (darkTheme ? Colors.white12 : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_note_rounded, size: 15, color: darkTheme ? Colors.white : Colors.black87),
                      const SizedBox(width: 2),
                      Text(
                        'ملاحظة',
                        style: TextStyle(fontFamily: 'Dubai', fontSize: 10, color: darkTheme ? Colors.white : Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: _showParticipantsAndEvaluateSheet,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          'يسمّع الآن: ${_activeEvalStudentName ?? ''} (${_formatCallTimer(_studentTurnSeconds)})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: darkTheme ? Colors.white : const Color(0xFF191919),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.swap_horiz_rounded, size: 16, color: scoreColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: scoreColor, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  '${score.toStringAsFixed(1)}/10',
                  style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // أزرار اللمس السريع الثلاثة
          Row(
            children: [
              _buildQuickRubricChip(
                label: 'خطأ (-1)',
                count: _evalMajorErrors,
                color: const Color(0xFFE53935),
                darkTheme: darkTheme,
                onTap: () => setState(() => _evalMajorErrors++),
                onUndo: _evalMajorErrors > 0 ? () => setState(() => _evalMajorErrors--) : null,
              ),
              const SizedBox(width: 6),
              _buildQuickRubricChip(
                label: 'تلعثم (-0.5)',
                count: _evalHesitations,
                color: const Color(0xFFFB8C00),
                darkTheme: darkTheme,
                onTap: () => setState(() => _evalHesitations++),
                onUndo: _evalHesitations > 0 ? () => setState(() => _evalHesitations--) : null,
              ),
              const SizedBox(width: 6),
              _buildQuickRubricChip(
                label: 'تجويد (-0.25)',
                count: _evalTajweedNotes,
                color: const Color(0xFF1E88E5),
                darkTheme: darkTheme,
                onTap: () => setState(() => _evalTajweedNotes++),
                onUndo: _evalTajweedNotes > 0 ? () => setState(() => _evalTajweedNotes--) : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00875A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isSavingEval ? null : _saveActiveStudentEvaluation,
              icon: _isSavingEval
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
              label: Text(
                _isSavingEval ? 'جاري الحفظ...' : 'اعتماد وحفظ التقييم (${score.toStringAsFixed(1)}/10)',
                style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRubricChip({
    required String label,
    required int count,
    required Color color,
    required bool darkTheme,
    required VoidCallback onTap,
    required VoidCallback? onUndo,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(darkTheme ? 0.22 : 0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.75)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (onUndo != null)
                GestureDetector(
                  onTap: onUndo,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: darkTheme ? Colors.black38 : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.remove, size: 12, color: darkTheme ? Colors.white : color),
                  ),
                )
              else
                const SizedBox(width: 14),
              Expanded(
                child: Text(
                  '$label${count > 0 ? ' ($count)' : ''}',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: darkTheme ? Colors.white : color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _endSessionPrompt() {
    final unmarkedStudents = _getMergedParticipantsList()
        .where((s) => s['student_id'] != null && s['user_id'] != _currentUserId && s['evaluation'] == null)
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إنهاء الحلقة والتسميع', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold)),
        content: Text(
          unmarkedStudents.isNotEmpty
              ? 'تم تقييم ${_studentEvaluations.length} طالب.\nيوجد ${unmarkedStudents.length} طالب مشترك لم يُسمّع أو لم يحضر بعد — يمكنك تسجيلهم تلقائياً وإرسال تنبيه لولي الأمر قبل إنهاء الحلقة.'
              : (_studentEvaluations.isNotEmpty
                  ? 'تم حفظ سجل وتقييم ${_studentEvaluations.length} طالب في هذه الحلقة.\nهل ترغب في إنهاء الحلقة الآن وحفظ التسجيل؟'
                  : (_isRecording
                      ? 'هل ترغب في إنهاء الحلقة، وتدوين تقييم الطالب (الأخطاء والتلعثم)، وحفظ التسجيل؟'
                      : 'هل ترغب في إنهاء جلسة التسميع أو تقييم طالب قبل الخروج؟')),
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Dubai'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Dubai')),
          ),
          if (unmarkedStudents.isNotEmpty)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
              onPressed: () async {
                Navigator.pop(ctx);
                await _batchRecordUnmarkedAttendance(unmarkedStudents);
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
                  AppFeedback.showSuccess(
                    context,
                    'تم تسجيل حضور/غياب غير المقيّمين (${unmarkedStudents.length}) وإشعار أولياء الأمور ثم إنهاء الحلقة',
                  );
                  Navigator.pop(context);
                }
              },
              child: Text(
                'رصد غياب غير المقيّمين (${unmarkedStudents.length}) وإنهاء 📢',
                style: const TextStyle(fontFamily: 'Dubai', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          if (_studentEvaluations.isNotEmpty)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00875A)),
              onPressed: () async {
                Navigator.pop(ctx);
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
                  AppFeedback.showSuccess(
                    context,
                    'تم إنهاء الحلقة وحفظ تقييمات (${_studentEvaluations.length}) طلاب',
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('إنهاء الحلقة وحفظ السجل', style: TextStyle(fontFamily: 'Dubai', color: Colors.white, fontWeight: FontWeight.bold)),
            )
          else if (unmarkedStudents.isEmpty)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00875A)),
              onPressed: () async {
                Navigator.pop(ctx);
                await _showRecitationEvaluationSheet();
              },
              child: const Text('تقييم طالب وإنهاء', style: TextStyle(fontFamily: 'Dubai', color: Colors.white, fontWeight: FontWeight.bold)),
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
        if (!mounted || _isDisposed || roomID != widget.roomId) return;
        setState(() {
          for (var u in userList) {
            if (updateType == ZegoUpdateType.Add) {
              _remoteUsers[u.userID] = u.userName;
            } else {
              _remoteUsers.remove(u.userID);
            }
          }
          final int liveConnected = 1 + _remoteUsers.length;
          if (liveConnected > _subscribersCount) {
            _subscribersCount = liveConnected;
          }
        });
        _loadClassDetails(silent: true);
        if (widget.isSheikh && updateType == ZegoUpdateType.Add) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (!mounted || _isDisposed) return;
            _sendRoomCommand({
              'cmd': 'mushaf_lock',
              'allowed': _allowStudentsMushaf,
              'surah': _syncedMushafSurah,
              'tab': _syncedContentTab,
            });
            if (_syncedContentTab == 1 && _syncedBookTitle != null) {
              _sendRoomCommand({
                'cmd': 'library_sync',
                'allowed': _allowStudentsMushaf,
                'title': _syncedBookTitle,
                'chapter': _syncedBookChapter ?? '',
                'text': _syncedBookText ?? '',
                'highlighted_line': _syncedHighlightedLine,
              });
            }
            if (_strictExamMode) {
              _sendRoomCommand({'cmd': 'strict_mode', 'enabled': true});
            }
          });
        }
      };

      // استقبال رسائل الدردشة الفورية والأوامر الحية عبر ZEGOCLOUD
      ZegoExpressEngine.onIMRecvBroadcastMessage = (roomID, messageList) {
        if (!mounted || _isDisposed || roomID != widget.roomId) return;
        bool addedChat = false;
        for (var msg in messageList) {
          final senderName = msg.fromUser.userName.isNotEmpty ? msg.fromUser.userName : 'مشارك';
          final rawMsg = msg.message;
          if (rawMsg.startsWith(_cmdPrefix)) {
            try {
              final decoded = jsonDecode(rawMsg.substring(_cmdPrefix.length));
              if (decoded is Map<String, dynamic>) {
                _handleRoomCommand(decoded, senderName);
              }
            } catch (_) {}
            continue;
          }
          final alreadyExists = _messages.any(
            (m) => m['sender'] == senderName && m['message'] == rawMsg,
          );
          if (!alreadyExists) {
            final now = TimeOfDay.now();
            setState(() {
              _messages.add({
                'sender': senderName,
                'role': 'remote',
                'message': rawMsg,
                'time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                'isMe': false,
              });
            });
            addedChat = true;
          }
        }
        if (addedChat) _scrollToBottom();
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

  // إرفاق صورة أو ملف شرح ورفعه للسيرفر ليظهر لكل المشاركين
  Future<void> _pickChatAttachment() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'pdf'],
      );
      if (res == null || res.files.isEmpty) return;
      final picked = res.files.first;
      final path = picked.path;
      final name = picked.name;
      final isImage = RegExp(r'\.(png|jpe?g|webp)$', caseSensitive: false).hasMatch(name);

      if (widget.classRoomId != null && path != null && isImage) {
        AppFeedback.showSuccess(context, 'جاري رفع مرفق الشرح "$name"...');
        await _apiClient.sendClassAttachment(
          widget.classRoomId!,
          filePath: path,
          message: '📎 مرفق شرح: $name',
        );
        await _loadServerMessages();
        if (mounted) AppFeedback.showSuccess(context, 'تم إرسال المرفق للجميع ✅');
      } else {
        final msgText = '📎 مرفق شرح: $name';
        try {
          await ZegoExpressEngine.instance.sendBroadcastMessage(widget.roomId, msgText);
        } catch (_) {}
        if (widget.classRoomId != null) {
          await _apiClient.sendClassMessage(widget.classRoomId!, msgText);
          await _loadServerMessages();
        }
        if (mounted && !isImage) {
          AppFeedback.showSuccess(context, 'تم إرسال إشعار الملف في الشات (السيرفر يدعم عرض الصور مباشرة)');
        }
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'إرسال المرفق', e);
      }
    }
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
    return PopScope(
      canPop: !(_strictExamMode && !widget.isSheikh),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _strictExamMode && !widget.isSheikh) {
          AppFeedback.showError(
            context,
            'وضع التسميع المشدد 🔒',
            'لا يمكن الخروج من الغرفة أثناء التسميع المشدد إلا بعد إنهاء الشيخ للوضع',
          );
        }
      },
      child: Scaffold(
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

                if (widget.isSheikh && _activeEvalStudentId != null && (!_isCallActive || _isPipMode))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: _buildLiveStudentEvaluationOverlay(darkTheme: false),
                  ),

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
                                      if ((msg['image_url'] ?? '').toString().isNotEmpty) ...[
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            msg['image_url'].toString(),
                                            width: 200,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                      ],
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

            // 4. النافذة العائمة (موقوفة عند تفعيل الوضع المشدد)
            if (_isCallActive && _isPipMode && (!(_strictExamMode && !widget.isSheikh)))
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

          // السطر الثاني: شارة المشتركين (قابلة للضغط لعرض قائمة الطلاب) + أزرار المشاركة والتقييم والاتصال
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: _showParticipantsAndEvaluateSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8F5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF00875A)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_alt_outlined, color: Color(0xFF00875A), size: 15),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'المشتركين $_subscribersCount / $_capacity',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 11.5,
                              color: Color(0xFF00875A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF00875A), size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isSheikh) ...[
                    _buildCircularTopAction(
                      icon: Icons.fact_check_outlined,
                      color: const Color(0xFF00875A),
                      onTap: _showParticipantsAndEvaluateSheet,
                    ),
                    const SizedBox(width: 6),
                    _buildCircularTopAction(
                      icon: Icons.menu_book_rounded,
                      color: _allowStudentsMushaf ? const Color(0xFF00875A) : Colors.deepOrange,
                      onTap: _openRoomMushaf,
                    ),
                    const SizedBox(width: 6),
                  ] else ...[
                    _buildCircularTopAction(
                      icon: Icons.back_hand_rounded,
                      color: _isHandRaised ? Colors.amber.shade800 : const Color(0xFF191919),
                      onTap: _toggleHandRaise,
                    ),
                    const SizedBox(width: 6),
                  ],
                  _buildCircularTopAction(
                    icon: Icons.share_outlined,
                    color: const Color(0xFF00875A),
                    onTap: _shareChapter,
                  ),
                  if (widget.isSheikh) ...[
                    const SizedBox(width: 6),
                    _buildCircularTopAction(
                      icon: Icons.power_settings_new,
                      color: const Color(0xFF191919),
                      onTap: _endSessionPrompt,
                    ),
                  ],
                  const SizedBox(width: 6),
                  _buildCircularTopAction(
                    icon: Icons.call_outlined,
                    color: const Color(0xFF191919),
                    onTap: () => _startCallPublish(video: false),
                  ),
                  const SizedBox(width: 6),
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
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Icon(icon, color: color, size: 18),
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
                      // أزرار المشاركة والتحكم السريع (الشيخ: قفل المصحف + الوضع المشدد | الطالب: شارة المراقبة)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _shareChapter,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.share_outlined, color: Colors.white, size: 18),
                            ),
                          ),
                          if (widget.isSheikh) ...[
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _toggleStudentsMushaf(),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _allowStudentsMushaf ? const Color(0xFF00875A) : Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _allowStudentsMushaf ? Colors.white70 : Colors.orange,
                                  ),
                                ),
                                child: Icon(
                                  _allowStudentsMushaf ? Icons.menu_book_rounded : Icons.lock_outline,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _toggleStrictMode(),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _strictExamMode ? Colors.red.shade700 : Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const Icon(Icons.security_rounded, color: Colors.white, size: 18),
                              ),
                            ),
                          ] else if (_strictExamMode) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade700.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '🔒 مراقبة مشددة',
                                style: TextStyle(
                                  fontFamily: 'Dubai',
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
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

                      // Attendees Pill (تفتح قائمة المشتركين والتقييم) + End Call X
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _showParticipantsAndEvaluateSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'المشتركين $_subscribersCount • متصل ${1 + _remoteUsers.length}',
                                    style: const TextStyle(
                                      fontFamily: 'Dubai',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.people_alt_outlined, color: Color(0xFF00C48C), size: 14),
                                ],
                              ),
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

                // لوحة التقييم الحي فوق الفيديو (للشيخ عند اختيار طالب) أو زر اختيار الطالب للتسميع
                if (widget.isSheikh && _activeEvalStudentId != null)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: _buildLiveStudentEvaluationOverlay(darkTheme: true),
                  )
                else ...[
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
                  if (widget.isSheikh)
                    Positioned(
                      bottom: 10,
                      right: 14,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00875A),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _showParticipantsAndEvaluateSheet,
                        icon: const Icon(Icons.fact_check_outlined, size: 16, color: Colors.white),
                        label: Text(
                          'تقييم طالب (${_studentEvaluations.length})',
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),

          // Bottom Action Controls Bar (محجّم للطالب، وكامل الصلاحيات للشيخ)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: const Color(0xFF131518),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. Chat toggle (مقيد في الوضع المشدد للطالب)
                _buildCallBottomAction(
                  icon: Icons.chat_bubble_outline_rounded,
                  isActive: false,
                  onTap: () {
                    if (_strictExamMode && !widget.isSheikh) {
                      AppFeedback.showError(
                        context,
                        'الوضع المشدد 🔒',
                        'لا يمكن تصغير الفيديو أثناء التسميع المشدد',
                      );
                      return;
                    }
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

                // 3. Camera toggle (ينبه الشيخ إذا أغلق الطالب الكاميرا في الوضع المشدد أو أثناء دوره)
                _buildCallBottomAction(
                  icon: _isCameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                  isActive: _isCameraOn && !_isVoiceOnly,
                  activeColor: const Color(0xFF00875A),
                  onTap: () async {
                    setState(() {
                      _isVoiceOnly = false;
                      _isCameraOn = !_isCameraOn;
                    });
                    if (!widget.isSheikh && !_isCameraOn && (_strictExamMode || _isStudentMicApproved)) {
                      _sendRoomCommand({
                        'cmd': 'student_camera_off',
                        'user_id': _currentUserId,
                        'name': _currentUserName,
                      });
                    }
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

                // 4. Quran / Mushaf Uthmani (114 سورة - يتحكم الشيخ في فتحه وقفله للطالب)
                if (widget.isSheikh || (_allowStudentsMushaf && !_strictExamMode))
                  _buildCallBottomAction(
                    icon: Icons.menu_book_rounded,
                    isActive: widget.isSheikh && _allowStudentsMushaf,
                    activeColor: const Color(0xFF00875A),
                    onTap: _openRoomMushaf,
                  )
                else
                  _buildCallBottomAction(
                    icon: Icons.lock_outline_rounded,
                    isActive: false,
                    onTap: _openRoomMushaf,
                  ),

                // 5. Hand Raise ✋ (للطالب لطلب الدور للتسميع)
                if (!widget.isSheikh)
                  _buildCallBottomAction(
                    icon: Icons.back_hand_rounded,
                    isActive: _isHandRaised,
                    activeColor: Colors.amber.shade800,
                    onTap: _toggleHandRaise,
                  ),

                // 6-8. أدوات الشيخ الحصرية: مشاركة الشاشة، PiP، والتسجيل
                if (widget.isSheikh) ...[
                  _buildCallBottomAction(
                    icon: Icons.desktop_windows_outlined,
                    isActive: _isScreenSharing,
                    activeColor: Colors.blueAccent,
                    onTap: () {
                      setState(() => _isScreenSharing = !_isScreenSharing);
                    },
                  ),
                  _buildCallBottomAction(
                    icon: Icons.picture_in_picture_alt_outlined,
                    isActive: false,
                    onTap: () {
                      setState(() => _isPipMode = true);
                    },
                  ),
                  _buildCallBottomAction(
                    icon: _isRecording ? Icons.stop_circle_rounded : Icons.fiber_manual_record_rounded,
                    isActive: _isRecording,
                    activeColor: Colors.redAccent,
                    onTap: _toggleRecording,
                  ),
                ],
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
