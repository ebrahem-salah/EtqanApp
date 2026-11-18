import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'zego_cloud_service.dart';

/// خدمة توليد وتوثيق توكنات ZEGOCLOUD الديناميكية وإدارة الصوت في الخلفية
class ZegoTokenService {
  static final ZegoTokenService _instance = ZegoTokenService._internal();
  factory ZegoTokenService() => _instance;
  ZegoTokenService._internal();

  /// توليد توكن ديناميكي محلي آمن متوافق مع معيار ZEGOCLOUD Token04
  /// [appID]: معرّف التطبيق
  /// [userID]: معرّف المستخدم (الطالب أو الشيخ)
  /// [secret]: مفتاح التوقيع (32 بايت)
  /// [effectiveTimeInSeconds]: مدة صلاحية التوكن بالثواني (افتراضياً 3600 ثانية = ساعة)
  /// [roomId]: معرّف غرفة التسميع أو الحلقة المباشرة
  static String generateToken04({
    required int appID,
    required String userID,
    required String secret,
    int effectiveTimeInSeconds = 3600,
    String? roomId,
  }) {
    final createTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expireTime = createTime + effectiveTimeInSeconds;
    final nonce = Random().nextInt(2147483647);

    // حمولة الصلاحيات (Privileges: 1=Login, 2=Publish stream)
    final payloadMap = {
      'room_id': roomId ?? '',
      'privilege': {
        '1': 1, // Can login room
        '2': 1, // Can publish stream
      },
      'stream_id_list': <String>[],
    };

    final payloadJson = jsonEncode(payloadMap);

    // بناء رسالة التوقيع للتشفير عبر HMAC-SHA256
    final messageBytes = utf8.encode(
      '$appID$userID$nonce$expireTime$payloadJson',
    );
    final keyBytes = utf8.encode(secret);

    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(messageBytes);
    final signature = base64Encode(digest.bytes);

    // تجميع التوكن بصيغة Base64 نهائية
    final tokenMap = {
      'ver': 4,
      'app_id': appID,
      'user_id': userID,
      'nonce': nonce,
      'ctime': createTime,
      'expire': expireTime,
      'payload': payloadJson,
      'signature': signature,
    };

    final tokenJson = jsonEncode(tokenMap);
    return '04${base64Encode(utf8.encode(tokenJson))}';
  }

  /// توليد توكن سريع باستخدام الإعدادات الرسمية لمنظومة إتقان
  static String generateEtqanSessionToken({
    required String userID,
    required String roomId,
    int durationHours = 2,
  }) {
    return generateToken04(
      appID: ZegoCloudConfig.appID,
      userID: userID,
      secret: ZegoCloudConfig.appSign,
      effectiveTimeInSeconds: durationHours * 3600,
      roomId: roomId,
    );
  }

  /// إعدادات الصوت في الخلفية (Background Audio & Wakelock)
  /// لضمان استمرار سماع التسميع وحلقة القرآن حتى في حال إغلاق أو قفل شاشة الهاتف
  static Map<String, dynamic> getBackgroundAudioConfig() {
    return {
      'enableBackgroundAudio': true,
      'keepAliveWhenScreenOff': true,
      'audioFocusMode': 'focusGainTransientMayDuck', // خفض الأصوات الأخرى مع استمرار التلاوة
      'bluetoothHeadsetSupport': true,
      'echoCancellation': true, // إلغاء صدى الصوت لضمان نقاء قراءة القرآن
      'noiseSuppression': true, // حجب الضوضاء المحيطة
    };
  }
}
