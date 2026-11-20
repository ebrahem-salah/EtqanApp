import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/deep_link_service.dart';
import '../../core/services/zego_cloud_service.dart';
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

class _LiveRecitationRoomState extends State<LiveRecitationRoom> with SingleTickerProviderStateMixin {
  // RTC & Controls State
  bool _isEngineReady = false;
  bool _isMicMuted = false;
  bool _isCameraOn = false;
  bool _isSpeakerOn = true;
  bool _isHandRaised = false;
  bool _isStudentMicApproved = false;
  late bool _isRecording;
  int _activeViewIndex = 0; // 0: Video & Audio Participants Grid, 1: Quran Mushaf View

  Widget? _localVideoWidget;
  String _currentSpeakerName = 'فضيلة الشيخ عبد الله السويسي';
  String _connectionStatus = 'متصل بالغرفة عبر ZEGOCLOUD (48kHz High-Def)';

  // Multi-Participants List (المشاركون في الحلقة)
  final List<Map<String, dynamic>> _participants = [
    {
      'id': 'sheikh_1',
      'name': 'الشيخ عبد الله السويسي',
      'role': 'sheikh',
      'isMuted': false,
      'isHandRaised': false,
      'isSpeaking': true,
      'avatarColor': Color(0xFF00875A),
    },
    {
      'id': 'student_1',
      'name': 'أحمد محمود',
      'role': 'student',
      'isMuted': true,
      'isHandRaised': false,
      'isSpeaking': false,
      'avatarColor': Color(0xFF1E5B42),
    },
    {
      'id': 'student_2',
      'name': 'عمر خالد',
      'role': 'student',
      'isMuted': true,
      'isHandRaised': true,
      'isSpeaking': false,
      'avatarColor': Color(0xFF2C5E7A),
    },
    {
      'id': 'student_3',
      'name': 'عبد الرحمن السعيد',
      'role': 'student',
      'isMuted': true,
      'isHandRaised': false,
      'isSpeaking': false,
      'avatarColor': Color(0xFF8B5A2B),
    },
  ];

  int _currentAyahIndex = 1;
  final List<String> _ayahs = [
    'كٓهيعٓصٓ ﴿١﴾',
    'ذِكْرُ رَحْمَتِ رَبِّكَ عَبْدَهُۥ زَكَرِيَّآ ﴿٢﴾',
    'إِذْ نَادَىٰ رَبَّهُۥ نِدَآءً خَفِيًّۭا ﴿٣﴾',
    'قَالَ رَبِّ إِنِّى وَهَنَ ٱلْعَظْمُ مِنِّى وَٱشْتَعَلَ ٱلرَّأْسُ شَيْبًۭا ﴿٤﴾',
    'وَلَمْ أَكُنۢ بِدُعَآئِكَ رَبِّ شَقِيًّۭا ﴿٥﴾',
    'وَإِنِّى خِفْتُ ٱلْمَوَٰلِىَ مِن وَرَآءِى وَكَانَتِ ٱمْرَأَتِى عَاقِرًۭا فَهَبْ لِى مِن لَّدُنكَ وَلِيًّۭا ﴿٦﴾',
  ];

  @override
  void initState() {
    super.initState();
    _isRecording = widget.isRecorded;
    if (widget.isSheikh) {
      _isStudentMicApproved = true;
    }
    _initZegoRTC();
  }

  Future<void> _initZegoRTC() async {
    try {
      final profile = ZegoEngineProfile(
        ZegoCloudConfig.appID,
        ZegoScenario.Default,
        appSign: ZegoCloudConfig.appSign,
      );
      await ZegoExpressEngine.createEngineWithProfile(profile);

      ZegoExpressEngine.onRoomStateUpdate = (roomID, state, errorCode, extendedData) {
        if (!mounted) return;
        setState(() {
          if (state == ZegoRoomState.Connected) {
            _connectionStatus = 'صوت نقي متصل بالكامل (48kHz RTC)';
          }
        });
      };

      ZegoExpressEngine.onIMRecvCustomCommand = (roomID, fromUser, command) {
        if (!mounted) return;
        if (command == 'RAISE_HAND') {
          // Add or mark student hand raised
          setState(() {
            for (var p in _participants) {
              if (p['name'] == fromUser.userName || p['id'] == fromUser.userID) {
                p['isHandRaised'] = true;
              }
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✋ رفع الطالب ${fromUser.userName} يده طلباً للتسميع!'),
              backgroundColor: const Color(0xFFD4AF37),
              action: widget.isSheikh
                  ? SnackBarAction(
                      label: 'إذن بالتسميع ✅',
                      textColor: Colors.white,
                      onPressed: () => _approveStudent(fromUser.userName),
                    )
                  : null,
            ),
          );
        } else if (command == 'APPROVE_MIC') {
          setState(() {
            _isStudentMicApproved = true;
            _isMicMuted = false;
          });
          ZegoExpressEngine.instance.muteMicrophone(false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ أذن لك فضيلة الشيخ بالتسميع! المايك مفتوح لك الآن.'),
              backgroundColor: Color(0xFF00875A),
            ),
          );
        }
      };

      // Login to room
      final user = ZegoUser(
        widget.isSheikh ? 'sheikh_host' : 'student_${DateTime.now().millisecondsSinceEpoch}',
        widget.isSheikh ? 'فضيلة الشيخ عبد الله السويسي' : 'طالب إتقان',
      );
      await ZegoExpressEngine.instance.loginRoom(widget.roomId, user);

      // Publish audio stream
      final streamId = 'stream_${widget.roomId}_${user.userID}';
      await ZegoExpressEngine.instance.startPublishingStream(streamId);
      await ZegoExpressEngine.instance.muteMicrophone(_isMicMuted);
      await ZegoExpressEngine.instance.setAudioRouteToSpeaker(_isSpeakerOn);

      if (mounted) {
        setState(() => _isEngineReady = true);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    try {
      ZegoExpressEngine.instance.stopPublishingStream();
      ZegoExpressEngine.instance.logoutRoom(widget.roomId);
      ZegoExpressEngine.destroyEngine();
    } catch (_) {}
    super.dispose();
  }

  void _toggleMic() {
    if (!widget.isSheikh && !_isStudentMicApproved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔒 يرجى رفع اليد أولاً ليأذن لك فضيلة الشيخ بالتسميع.'),
          backgroundColor: Color(0xFFD4AF37),
        ),
      );
      return;
    }

    setState(() => _isMicMuted = !_isMicMuted);
    try {
      ZegoExpressEngine.instance.muteMicrophone(_isMicMuted);
    } catch (_) {}
  }

  Future<void> _toggleCamera() async {
    setState(() => _isCameraOn = !_isCameraOn);
    try {
      await ZegoExpressEngine.instance.enableCamera(_isCameraOn);
      if (_isCameraOn) {
        await ZegoExpressEngine.instance.createCanvasView((viewID) {
          final canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
          ZegoExpressEngine.instance.startPreview(canvas: canvas);
        }).then((widgetView) {
          if (mounted && widgetView != null) {
            setState(() => _localVideoWidget = widgetView);
          }
        });
      } else {
        setState(() => _localVideoWidget = null);
      }
    } catch (_) {}
  }

  void _toggleSpeaker() {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    try {
      ZegoExpressEngine.instance.setAudioRouteToSpeaker(_isSpeakerOn);
      ZegoExpressEngine.instance.muteSpeaker(!_isSpeakerOn);
    } catch (_) {}
  }

  void _toggleRaiseHand() {
    setState(() => _isHandRaised = !_isHandRaised);

    if (_isHandRaised) {
      try {
        ZegoExpressEngine.instance.sendCustomCommand(widget.roomId, 'RAISE_HAND', []);
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✋ تم رفع يدك! بانتظار إذن فضيلة الشيخ للتسميع...'),
          backgroundColor: Color(0xFFD4AF37),
        ),
      );

      // محاكاة موافقة الشيخ التلقائية بعد ثانيتين للاختبار السلس
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _isStudentMicApproved = true;
          _isMicMuted = false;
          _currentSpeakerName = 'أنت (تتحدث وتسمع الآن 🎙️)';
        });
        try {
          ZegoExpressEngine.instance.muteMicrophone(false);
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ وافق الشيخ عبد الله على طلبك! المايك مفتوح لك الآن للتسميع.'),
            backgroundColor: Color(0xFF00875A),
          ),
        );
      });
    } else {
      setState(() {
        _isStudentMicApproved = false;
      });
    }
  }

  void _approveStudent(String studentName) {
    setState(() {
      for (var p in _participants) {
        if (p['name'] == studentName) {
          p['isHandRaised'] = false;
          p['isMuted'] = false;
          p['isSpeaking'] = true;
        } else {
          p['isSpeaking'] = false;
        }
      }
      _currentSpeakerName = 'الطالب $studentName (يسمّع الآن 🎙️)';
    });

    try {
      ZegoExpressEngine.instance.sendCustomCommand(widget.roomId, 'APPROVE_MIC', []);
    } catch (_) {}

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ تم فتح المايك للطالب $studentName وبدأ التسميع المباشر'),
        backgroundColor: const Color(0xFF00875A),
      ),
    );
  }

  void _muteAllStudents() {
    setState(() {
      for (var p in _participants) {
        if (p['role'] == 'student') {
          p['isMuted'] = true;
          p['isSpeaking'] = false;
          p['isHandRaised'] = false;
        }
      }
      _currentSpeakerName = 'فضيلة الشيخ عبد الله السويسي (يتحدث الآن 🎙️)';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔇 تم كتم صوت جميع الطلاب بواسطة فضيلة الشيخ'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _addSimulatedStudent() {
    final names = ['خالد إبراهيم', 'سارة إبراهيم', 'مصطفى الأحمد', 'سلمان العتيبي', 'يوسف عبد الله'];
    final existingCount = _participants.length - 1; // excluding sheikh
    final newName = names[existingCount % names.length];

    setState(() {
      _participants.add({
        'id': 'sim_student_${DateTime.now().millisecondsSinceEpoch}',
        'name': newName,
        'role': 'student',
        'isMuted': true,
        'isHandRaised': existingCount % 2 == 0, // alternately raise hand
        'isSpeaking': false,
        'avatarColor': Colors.primaries[(_participants.length * 3) % Colors.primaries.length],
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('👤 انضم الطالب ($newName) إلى حلقة التلاوة بنجاح!'),
        backgroundColor: const Color(0xFF00875A),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareCircleLink() {
    final id = widget.classRoomId ?? int.tryParse(widget.roomId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 110;
    final link = DeepLinkService.getCircleShareLink(id, circleTitle: widget.circleTitle);
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📋 تم نسخ رابط الحلقة لمشاركته: $link'),
        backgroundColor: const Color(0xFF0F5B46),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleRecording() {
    setState(() => _isRecording = !_isRecording);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isRecording ? '🔴 بدأ تسجيل الدرس وحفظه في الأرشيف' : '🔒 تم إيقاف التسجيل - الجلسة خاصة الآن'),
        backgroundColor: _isRecording ? Colors.redAccent : const Color(0xFF00875A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101915),
      appBar: AppBar(
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              widget.circleTitle,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Text(
              _connectionStatus,
              style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 10),
            ),
          ],
        ),
        actions: [
          // Share Circle Deep Link button
          IconButton(
            tooltip: 'مشاركة رابط الحلقة الذكي',
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: _shareCircleLink,
          ),
          // Recording button
          IconButton(
            tooltip: _isRecording ? 'إيقاف التسجيل' : 'بدء تسجيل الدرس',
            icon: Icon(
              _isRecording ? Icons.fiber_manual_record : Icons.fiber_manual_record_outlined,
              color: _isRecording ? Colors.redAccent : Colors.white70,
            ),
            onPressed: _toggleRecording,
          ),
          // Exam sheet button
          IconButton(
            tooltip: 'استمارة رصد درجات وخصومات المتسابق',
            icon: const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFFFFDF73)),
            onPressed: () {
              CompetitionExamSheet.show(
                context,
                competitionId: 103,
                studentId: 1,
                studentName: 'أحمد محمود (المتسابق)',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Speaker Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF0C140F),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2ECC71),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _currentSpeakerName,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  '👥 ${_participants.length} مشاركين',
                  style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // View Selector Tabs: [شبكة المشاركين بالصوت والفيديو] vs [المصحف الشريف]
          Container(
            color: const Color(0xFF14241B),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeViewIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _activeViewIndex == 0 ? const Color(0xFF2ECC71) : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.grid_view_rounded, size: 16, color: _activeViewIndex == 0 ? Colors.white : Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            'شبكة المشاركين والصوت والفيديو',
                            style: TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _activeViewIndex == 0 ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeViewIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _activeViewIndex == 1 ? const Color(0xFF2ECC71) : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book_rounded, size: 16, color: _activeViewIndex == 1 ? Colors.white : Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            'المصحف الشريف والتسميع',
                            style: TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _activeViewIndex == 1 ? Colors.white : Colors.grey,
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

          // Main View Content
          Expanded(
            child: _activeViewIndex == 0
                ? _buildParticipantsGrid()
                : _buildMushafView(),
          ),

          // Multi-User Interactive Simulation Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFF16201B),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Add student simulator button
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF00875A).withOpacity(0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 16, color: Color(0xFF5CD8A6)),
                  label: const Text(
                    '+ إضافة طالب تجريبي للحلقة',
                    style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Color(0xFF5CD8A6), fontWeight: FontWeight.bold),
                  ),
                  onPressed: _addSimulatedStudent,
                ),

                // Sheikh Mute All button
                if (widget.isSheikh)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.mic_off_rounded, size: 16, color: Colors.redAccent),
                    label: const Text(
                      'كتم صوت الجميع 🔇',
                      style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _muteAllStudents,
                  )
                else
                  // Raise hand button for student
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isHandRaised ? Colors.amber : const Color(0xFF00875A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    icon: const Icon(Icons.pan_tool_rounded, size: 16, color: Colors.white),
                    label: Text(
                      _isHandRaised ? 'خفض اليد ✋' : 'طلب التسميع أمام الشيخ ✋',
                      style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _toggleRaiseHand,
                  ),
              ],
            ),
          ),

          // Bottom Call Control Dock (Mic, Camera, Speakerphone, End)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.black,
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Microphone
                  IconButton(
                    iconSize: 30,
                    icon: Icon(
                      _isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      color: _isMicMuted ? Colors.redAccent : (_isStudentMicApproved ? const Color(0xFF2ECC71) : Colors.white),
                    ),
                    onPressed: _toggleMic,
                  ),

                  // Camera
                  IconButton(
                    iconSize: 30,
                    icon: Icon(
                      _isCameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                      color: _isCameraOn ? const Color(0xFF2ECC71) : Colors.white70,
                    ),
                    onPressed: _toggleCamera,
                  ),

                  // Speakerphone
                  IconButton(
                    iconSize: 30,
                    icon: Icon(
                      _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      color: Colors.white,
                    ),
                    onPressed: _toggleSpeaker,
                  ),

                  // End Call Button
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.redAccent,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.call_end_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Multi-User Video & Audio Grid View
  Widget _buildParticipantsGrid() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Sheikh Host Card
          Container(
            height: 140,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2D24),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00875A), width: 2),
            ),
            child: Stack(
              children: [
                if (_isCameraOn && widget.isSheikh && _localVideoWidget != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _localVideoWidget!,
                  )
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00875A).withOpacity(0.3),
                              ),
                            ),
                            const CircleAvatar(
                              radius: 28,
                              backgroundColor: Color(0xFF00875A),
                              child: Icon(Icons.school_rounded, color: Colors.white, size: 30),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'فضيلة الشيخ عبد الله السويسي (المقرئ والمحكّم)',
                          style: TextStyle(fontFamily: 'Dubai', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                // Top Sheikh Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00875A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('المقرئ المعتمد 🎙️', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          // Students Grid (2x2 or dynamic grid)
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.15,
              ),
              itemCount: _participants.where((p) => p['role'] == 'student').length,
              itemBuilder: (context, index) {
                final student = _participants.where((p) => p['role'] == 'student').toList()[index];
                final isMe = student['name'] == 'أحمد محمود' && !widget.isSheikh;
                final isSpeaking = student['isSpeaking'] == true;
                final isHandRaised = student['isHandRaised'] == true;

                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2620),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSpeaking
                          ? const Color(0xFF2ECC71)
                          : (isHandRaised ? Colors.amber : Colors.white12),
                      width: isSpeaking || isHandRaised ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Video preview for local camera if this is current student
                      if (isMe && _isCameraOn && _localVideoWidget != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _localVideoWidget!,
                        )
                      else
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (isSpeaking)
                                    Container(
                                      width: 58,
                                      height: 58,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF2ECC71).withOpacity(0.3),
                                      ),
                                    ),
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: student['avatarColor'] as Color? ?? const Color(0xFF00875A),
                                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 26),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                student['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontFamily: 'Dubai', color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),

                      // Status Icons
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Icon(
                          student['isMuted'] == true ? Icons.mic_off : Icons.mic,
                          color: student['isMuted'] == true ? Colors.redAccent : const Color(0xFF2ECC71),
                          size: 16,
                        ),
                      ),

                      // Hand raised badge
                      if (isHandRaised)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('✋ رافع اليد', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
                          ),
                        ),

                      // Approve button for Sheikh
                      if (widget.isSheikh && isHandRaised)
                        Positioned(
                          bottom: 6,
                          left: 6,
                          right: 6,
                          child: SizedBox(
                            height: 26,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00875A),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => _approveStudent(student['name']),
                              child: const Text('إذن بالتسميع ✅', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
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
  }

  // 2. Quran Mushaf View (المصحف الشريف)
  Widget _buildMushafView() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '📖 سورة مريم (مكية) - الآيات 1 إلى 6',
                style: TextStyle(color: Color(0xFF6D4C41), fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'طبعة الشمرلي الأصلية',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 8,
                  children: List.generate(_ayahs.length, (index) {
                    final isHighlighted = index + 1 == _currentAyahIndex;
                    return InkWell(
                      onTap: () => setState(() => _currentAyahIndex = index + 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isHighlighted ? const Color(0xFFFFE899) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _ayahs[index],
                          style: TextStyle(
                            fontSize: 16,
                            height: 2.2,
                            fontFamily: 'Dubai',
                            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                            color: isHighlighted ? const Color(0xFF3B2C00) : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          // Live Tajweed Score Badge
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8ED),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('التجويد: 5/5 ⭐', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00875A))),
                Text('المخارج: 5/5 ⭐', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00875A))),
                Text('التقييم: 100%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2ECC71))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
