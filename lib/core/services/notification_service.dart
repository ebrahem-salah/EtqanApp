import 'dart:async';
import 'package:flutter/material.dart';
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

/// خدمة إدارة الإشعارات السحابية اللحظية (FCM & Realtime Notifications)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final SupabaseService _supabase = SupabaseService();
  final StreamController<List<EtqanNotification>> _notificationsController =
      StreamController<List<EtqanNotification>>.broadcast();

  Stream<List<EtqanNotification>> get notificationsStream =>
      _notificationsController.stream;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// تهيئة خدمة الإشعارات والاشتراك في قنوات التنبيهات
  Future<void> initialize() async {
    // محاكاة استخراج FCM Device Token وربطه مع حساب المستخدم
    _fcmToken = 'fcm_etqan_device_token_${DateTime.now().millisecondsSinceEpoch}';

    // الاستماع للإشعارات الواردة في السحابة
    _supabase.getNotificationsStream().listen((dataList) {
      final notifications = dataList
          .map((m) => EtqanNotification.fromMap(m))
          .toList();
      _notificationsController.add(notifications);
    });
  }

  /// الاشتراك في إشعارات شيخ معين (عند بدء بث مباشر)
  Future<void> subscribeToSheikhAlerts(String sheikhName) async {
    // اشتراك في قناة التنبيهات الخاصة بالشيخ
    debugPrint('تم الاشتراك في إشعارات الشيخ: $sheikhName');
  }

  /// جدولة تنبيه تذكير بموعد جلسة تسميع قادمة
  Future<void> scheduleSessionReminder({
    required String circleTitle,
    required String timeSlot,
  }) async {
    debugPrint('تم جدولة تذكير قبل موعد جلسة ($circleTitle) بالوقت ($timeSlot)');
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(body, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void dispose() {
    _notificationsController.close();
  }
}
