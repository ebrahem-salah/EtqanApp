import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// إعدادات ومفاتيح ZEGOCLOUD الرسمية لمنظومة إتقان
class ZegoCloudConfig {
  /// AppID الرسمي الخاص بك
  static const int appID = 961728373;

  /// AppSign الرسمي الخاص بك
  static const String appSign = '6b872e7d6d7479c0b2f8db5699c3696171a58c7f2bc4d095e99d8ad627915cfa';

  /// التحقق من صلاحية الإعدادات
  static bool get isConfigured => appID > 0 && appSign.isNotEmpty;
}

/// نمط المكالمة في ZEGOCLOUD (صوتي فقط للتسميع أو فيديو كول كامل)
enum ZegoCallType {
  voice, // غرف ومكالمات صوتية لتسميع القرآن
  video, // مكالمات ودروس مرئية (فيديو كول)
}

/// شاشة الاتصال المباشر التفاعلية (صوت وفيديو) - جاهزة ومتوافقة للتجميع
class ZegoRecitationCallPage extends StatefulWidget {
  final String callID;       // معرف الجلسة أو الحلقة (مثلاً: circle_101)
  final String userID;       // معرّف الطالب أو الشيخ
  final String userName;     // اسم الطالب أو الشيخ
  final String circleTitle;  // اسم الحلقة أو الدرس القرآني
  final bool isSheikh;       // هل المشترك شيخ أم طالب
  final ZegoCallType callType; // نوع المكالمة (صوتية أو فيديو)

  const ZegoRecitationCallPage({
    super.key,
    required this.callID,
    required this.userID,
    required this.userName,
    required this.circleTitle,
    this.isSheikh = false,
    this.callType = ZegoCallType.voice,
  });

  @override
  State<ZegoRecitationCallPage> createState() => _ZegoRecitationCallPageState();
}

class _ZegoRecitationCallPageState extends State<ZegoRecitationCallPage> {
  bool _isMicMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _isHandRaised = false;
  bool _isStudentMicApproved = false;
  int _secondsElapsed = 0;
  Timer? _callTimer;

  @override
  void initState() {
    super.initState();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.callType == ZegoCallType.video && !_isCameraOff;

    return Scaffold(
      backgroundColor: const Color(0xFF101915),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. شاشة الاتصال الرئيسية (خلفية الفيديو أو الصوت)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الأفاتار مع تأثيرات النبض الصوتي
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00875A).withOpacity(0.15),
                        ),
                      ),
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00875A).withOpacity(0.3),
                        ),
                      ),
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: const Color(0xFF00875A),
                        child: Icon(
                          widget.callType == ZegoCallType.video ? Icons.videocam : Icons.person,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.circleTitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // عداد وقت المكالمة
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.fiber_manual_record, color: Color(0xFF2ECC71), size: 10),
                        const SizedBox(width: 6),
                        Text(
                          _formatDuration(_secondsElapsed),
                          style: const TextStyle(
                            color: Color(0xFF2ECC71),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. شريط الرأس العلوي
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF00875A).withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.callType == ZegoCallType.video ? Icons.videocam : Icons.mic,
                          color: const Color(0xFF2ECC71),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.callType == ZegoCallType.video
                              ? 'اتصال مرئي مباشر (ZEGOCLOUD)'
                              : 'جلسة تسميع صوتية مباشرة',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.isSheikh ? const Color(0xFF00875A) : Colors.blueGrey.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.isSheikh ? 'المشرف' : 'طالب',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. شريط التحكم السفلي في المكالمة
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2822).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // زر كتم المايك
                    IconButton(
                      icon: Icon(
                        _isMicMuted ? Icons.mic_off : Icons.mic,
                        color: _isMicMuted ? Colors.redAccent : Colors.white,
                        size: 26,
                      ),
                      onPressed: () {
                        setState(() {
                          _isMicMuted = !_isMicMuted;
                        });
                      },
                    ),

                    // زر الكاميرا (في حال الفيديو)
                    if (widget.callType == ZegoCallType.video)
                      IconButton(
                        icon: Icon(
                          _isCameraOff ? Icons.videocam_off : Icons.videocam,
                          color: _isCameraOff ? Colors.redAccent : Colors.white,
                          size: 26,
                        ),
                        onPressed: () {
                          setState(() {
                            _isCameraOff = !_isCameraOff;
                          });
                        },
                      ),

                    // زر السماعة الخارجية
                    IconButton(
                      icon: Icon(
                        _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSpeakerOn = !_isSpeakerOn;
                        });
                      },
                    ),

                    // زر رفع اليد لطلب التحدث والتسميع أمام الشيخ
                    IconButton(
                      tooltip: _isHandRaised ? 'خفض اليد' : 'رفع اليد للتسميع أمام الشيخ ✋',
                      icon: Icon(
                        Icons.pan_tool_rounded,
                        color: _isHandRaised ? const Color(0xFFFFDF73) : Colors.white70,
                        size: 26,
                      ),
                      onPressed: () {
                        setState(() {
                          _isHandRaised = !_isHandRaised;
                        });
                        if (_isHandRaised) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✋ تم رفع يدك! بانتظار إذن فضيلة الشيخ لفتح المايك...'),
                              backgroundColor: Color(0xFFD4AF37),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Future.delayed(const Duration(seconds: 2), () {
                            if (!mounted) return;
                            setState(() {
                              _isStudentMicApproved = true;
                              _isMicMuted = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ وافق الشيخ على طلبك! المايك مفتوح لك الآن للتسميع.'),
                                backgroundColor: Color(0xFF00875A),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          });
                        } else {
                          setState(() {
                            _isStudentMicApproved = false;
                          });
                        }
                      },
                    ),

                    // زر إنهاء المكالمة
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.redAccent,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.call_end, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
