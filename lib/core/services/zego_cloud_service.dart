import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
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

/// صفحة الاتصال المباشر المتكاملة (صوت وفيديو) باستخدام ZEGOCLOUD
class ZegoRecitationCallPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // تكوين المكالمة بناءً على النوع (صوتي أو مرئي)
    final config = (callType == ZegoCallType.video)
        ? (ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          ..audioVideoViewConfig.showCameraStateOnView = true
          ..audioVideoViewConfig.showMicrophoneStateOnView = true
          ..bottomMenuBarConfig.buttons = [
            ZegoCallMenuBarButtonName.toggleCameraButton,
            ZegoCallMenuBarButtonName.toggleMicrophoneButton,
            ZegoCallMenuBarButtonName.switchCameraButton,
            ZegoCallMenuBarButtonName.switchAudioOutputButton,
            ZegoCallMenuBarButtonName.hangUpButton,
          ])
        : (ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
          ..audioVideoViewConfig.showCameraStateOnView = false
          ..audioVideoViewConfig.showMicrophoneStateOnView = true
          ..bottomMenuBarConfig.buttons = [
            ZegoCallMenuBarButtonName.toggleMicrophoneButton,
            ZegoCallMenuBarButtonName.switchAudioOutputButton,
            ZegoCallMenuBarButtonName.hangUpButton,
          ]);

    config.onHangUp = () => Navigator.of(context).pop();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ZEGOCLOUD Prebuilt Widget
            ZegoUIKitPrebuiltCall(
              appID: ZegoCloudConfig.appID,
              appSign: ZegoCloudConfig.appSign,
              userID: userID,
              userName: userName,
              callID: callID,
              config: config,
            ),

            // Top Header Bar
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00875A).withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          circleTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              callType == ZegoCallType.video ? Icons.videocam : Icons.mic,
                              color: const Color(0xFF2ECC71),
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              callType == ZegoCallType.video
                                  ? 'فيديو كول فائق الدقة (ZEGOCLOUD)'
                                  : 'غرفة صوتية فائقة النقاء (ZEGOCLOUD)',
                              style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSheikh ? const Color(0xFF00875A) : Colors.blueGrey.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isSheikh ? 'المشرف (الشيخ)' : 'طالب',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
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
