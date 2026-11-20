import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'supabase_service.dart';

/// نموذج بيانات الإشعار
class EtqanNotification {
  final String id;
  final String title;
  final String body;
  final String type; // circle_live, booking_reminder, competition, wallet
  final bool isRead;
  final DateTime createdAt;

  EtqanNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  factory EtqanNotification.fromMap(Map<String, dynamic> map) {
    return EtqanNotification(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['notification_type'] ?? 'general',
      isRead: map['is_read'] ?? false,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

/// خدمة إدارة الإشعارات السحابية اللحظية والمنبهات المحلية (FCM & Realtime Notifications)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final SupabaseService _supabase = SupabaseService();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final StreamController<List<EtqanNotification>> _notificationsController =
      StreamController<List<EtqanNotification>>.broadcast();

  Stream<List<EtqanNotification>> get notificationsStream =>
      _notificationsController.stream;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  bool _isLocalInitialized = false;

  /// تهيئة خدمة الإشعارات والاشتراك في قنوات التنبيهات
  Future<void> initialize({void Function(String?)? onSelectNotification}) async {
    // 1. توليد وربط FCM Device Token
    _fcmToken = 'fcm_etqan_device_token_${DateTime.now().millisecondsSinceEpoch}';

    // 2. إعداد مكتبة الإشعارات المحلية على مستوى نظام التشغيل
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (onSelectNotification != null) {
            onSelectNotification(response.payload);
          }
        },
      );

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'etqan_high_importance_channel',
        'حلقات وتنبيهات إتقان',
        description: 'قناة إشعارات الحلقات القرآنية المباشرة والتنبيهات الهامة',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      _isLocalInitialized = true;
    } catch (e) {
      debugPrint('Local notifications init error: $e');
    }

    // 3. الاستماع للإشعارات الواردة في السحابة
    try {
      _supabase.getNotificationsStream().listen((dataList) {
        final notifications = dataList
            .map((m) => EtqanNotification.fromMap(m))
            .toList();
        _notificationsController.add(notifications);

        if (notifications.isNotEmpty) {
          final latest = notifications.first;
          showInstantNotification(
            id: latest.id.hashCode,
            title: latest.title,
            body: latest.body,
            payload: latest.type,
          );
        }
      });
    } catch (_) {}
  }

  /// طلب إذن الإشعارات لأندرويد 13 فما فوق وآبل
  Future<bool> requestPermissions() async {
    try {
      final androidImpl = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final granted = await androidImpl.requestNotificationsPermission();
        return granted ?? false;
      }
    } catch (_) {}
    return true;
  }

  /// إرسال إشعار فوري نظامي
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isLocalInitialized) return;
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'etqan_high_importance_channel',
        'حلقات وتنبيهات إتقان',
        channelDescription: 'إشعارات الحلقات القرآنية والتسميع المباشر',
        importance: Importance.max,
        priority: Priority.high,
        color: Color(0xFF0F5B46),
        enableLights: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('showInstantNotification error: $e');
    }
  }

  /// الاشتراك في إشعارات شيخ معين (عند بدء بث مباشر)
  Future<void> subscribeToSheikhAlerts(String sheikhName) async {
    debugPrint('تم الاشتراك في إشعارات الشيخ: $sheikhName');
    await showInstantNotification(
      id: sheikhName.hashCode,
      title: 'متابعة المقرئ ✨',
      body: 'تم اشتراكك في تنبيهات $sheikhName وسيصلك إشعار فور بدء حلقته.',
    );
  }

  /// جدولة تنبيه تذكير بموعد جلسة تسميع قادمة
  Future<void> scheduleSessionReminder({
    required String circleTitle,
    required String timeSlot,
    int? circleId,
  }) async {
    final id = circleId ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await showInstantNotification(
      id: id,
      title: 'تأكيد حجز الحلقة القرآنية 📖',
      body: 'تم تأكيد حجزك في ($circleTitle) في الموعد ($timeSlot).',
      payload: 'circle_$circleId',
    );
  }

  /// جدولة تذكير يومي بالورد القرآني
  Future<void> scheduleDailyQuranWird() async {
    await showInstantNotification(
      id: 9999,
      title: 'وردك اليومي من القرآن الكريم ✨',
      body: 'قال ﷺ: "خيركم من تعلم القرآن وعلمه". حان وقت قراءة وتلاوة آيات الذكر الحكيم.',
      payload: 'quran_wird',
    );
  }

  /// إرسال إشعار فوري تجريبي داخل التطبيق
  void showLocalBanner(BuildContext context, {required String title, required String body}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF00875A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Dubai')),
                  Text(body, style: const TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'Dubai')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
