import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  late TabController _tabController;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'تأكيد حجز حلقة القرآن',
      'body': 'تم تأكيد موعد جلستك مع فضيلة الشيخ عبد الله السويسي اليوم الساعة 5:30 م.',
      'type': 'circle',
      'time': 'منذ 15 دقيقة',
      'is_read': false,
      'icon': Icons.calendar_month_rounded,
      'color': Color(0xFF00875A),
    },
    {
      'id': 2,
      'title': 'بدء تصفيات مسابقة إتقان الكبرى',
      'body': 'تم الإعلان عن جدول المسابقة القرآنية الكبرى. اختبر معلوماتك الآن واطّلع على قائمة الصدارة.',
      'type': 'competition',
      'time': 'منذ ساعتين',
      'is_read': false,
      'icon': Icons.emoji_events_rounded,
      'color': Color(0xFFD4AF37),
    },
    {
      'id': 3,
      'title': 'شهادة شكر وتقدير جديدة',
      'body': 'منحك فضيلة الشيخ شهادة تقدير لإتمامك حفظ سورة مريم وإتقان أحكام المدود.',
      'type': 'system',
      'time': 'منذ يوم',
      'is_read': true,
      'icon': Icons.workspace_premium_rounded,
      'color': Color(0xFF1E5B42),
    },
    {
      'id': 4,
      'title': 'إضافة رصيد للمحفظة',
      'body': 'تم شحن محفظتك بمبلغ 150.00 ر.س بنجاح. يمكنك الآن حجز الحلقات المدفوعة.',
      'type': 'system',
      'time': 'منذ يومين',
      'is_read': true,
      'icon': Icons.account_balance_wallet_rounded,
      'color': Color(0xFF00875A),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadLiveNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLiveNotifications() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.getNotifications();
      if (res.statusCode == 200 && res.data != null) {
        final List apiNotifs = res.data['data'] ?? [];
        if (apiNotifs.isNotEmpty) {
          final mapped = apiNotifs.map<Map<String, dynamic>>((n) {
            return {
              'id': n['id'],
              'title': n['title'] ?? 'إشعار إتقان',
              'body': n['message'] ?? n['body'] ?? '',
              'type': n['type'] ?? 'system',
              'time': n['created_at'] != null ? n['created_at'].toString().substring(0, 10) : 'مؤخراً',
              'is_read': n['read_at'] != null,
              'icon': Icons.notifications_active_rounded,
              'color': const Color(0xFF00875A),
            };
          }).toList();

          if (mounted) {
            setState(() {
              _notifications.insertAll(0, mapped);
            });
          }
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['is_read'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ تم تعيين جميع الإشعارات كمقروءة'),
        backgroundColor: Color(0xFF00875A),
      ),
    );
  }

  List<Map<String, dynamic>> _filterByType(String type) {
    if (type == 'all') return _notifications;
    return _notifications.where((n) => n['type'] == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFBE8),
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'مركز الإشعارات والتنبيهات',
          style: TextStyle(
            fontFamily: 'Dubai',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2822),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF00875A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'إرسال إشعار تجريبي فوري للنظام',
            icon: const Icon(Icons.notifications_active_outlined, color: Color(0xFF00875A), size: 22),
            onPressed: () async {
              await NotificationService().showInstantNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                title: 'تنبيه حلقة إتقان المباشرة 🎙️',
                body: 'بدأت الآن حلقة "تصحيح سورة مريم" مع فضيلة الشيخ عبد الله السويسي. اضغط للدخول.',
                payload: 'circle_110',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔔 تم إرسال إشعار فوري تجريبي لنظام هاتفك بنجاح!'),
                    backgroundColor: Color(0xFF00875A),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          TextButton.icon(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all_rounded, color: Color(0xFF00875A), size: 18),
            label: const Text(
              'تحديد الكل كمقروء',
              style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Color(0xFF00875A), fontWeight: FontWeight.bold),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00875A),
          indicatorWeight: 3,
          labelColor: const Color(0xFF00875A),
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'الحلقات'),
            Tab(text: 'المسابقات'),
            Tab(text: 'النظام'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00875A)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationsList(_filterByType('all')),
                _buildNotificationsList(_filterByType('circle')),
                _buildNotificationsList(_filterByType('competition')),
                _buildNotificationsList(_filterByType('system')),
              ],
            ),
    );
  }

  Widget _buildNotificationsList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'لا توجد إشعارات في هذا القسم',
              style: TextStyle(fontFamily: 'Dubai', fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final notif = items[index];
        final isRead = notif['is_read'] == true;
        final Color itemColor = notif['color'] as Color? ?? const Color(0xFF00875A);

        return Dismissible(
          key: Key('notif_${notif['id']}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
          ),
          onDismissed: (_) {
            setState(() {
              _notifications.removeWhere((n) => n['id'] == notif['id']);
            });
          },
          child: InkWell(
            onTap: () {
              setState(() {
                notif['is_read'] = true;
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isRead ? Colors.white : itemColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isRead ? Colors.grey.shade200 : itemColor.withOpacity(0.3),
                  width: isRead ? 1 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: itemColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(notif['icon'] as IconData? ?? Icons.notifications, color: itemColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notif['title'],
                                style: TextStyle(
                                  fontFamily: 'Dubai',
                                  fontSize: 14,
                                  fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                  color: const Color(0xFF1E2822),
                                ),
                              ),
                            ),
                            Text(
                              notif['time'],
                              style: TextStyle(
                                fontFamily: 'Dubai',
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notif['body'],
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isRead)
                    Container(
                      margin: const EdgeInsets.only(top: 4, right: 6),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: itemColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
