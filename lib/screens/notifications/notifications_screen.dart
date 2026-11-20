import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;

  // قائمة الإشعارات المطابقة بكسل ببكسل للصورة 19 (Screenshot 19)
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'حلقة جديدة',
      'body': 'تم بدء حلقة new',
      'time': 'PM 08:55 - 20/11/2026',
    },
    {
      'id': 2,
      'title': 'حلقة جديدة',
      'body': 'تم بدء حلقة تيست',
      'time': 'PM 07:32 - 17/11/2026',
    },
    {
      'id': 3,
      'title': 'حلقة جديدة',
      'body': 'تم بدء حلقة ت 1',
      'time': 'PM 04:02 - 16/11/2026',
    },
    {
      'id': 4,
      'title': 'حلقة جديدة',
      'body': 'تم بدء حلقة newwww',
      'time': 'AM 09:39 - 16/11/2026',
    },
    {
      'id': 5,
      'title': 'حلقة جديدة',
      'body': 'تم بدء حلقة new',
      'time': 'AM 09:38 - 16/11/2026',
    },
    {
      'id': 6,
      'title': 'إذاعة جديدة',
      'body': 'تم إضافة إذاعة جديدة',
      'time': 'AM 01:15 - 16/10/2026',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadLiveNotifications();
  }

  Future<void> _loadLiveNotifications() async {
    try {
      final res = await _apiClient.getNotifications();
      if (res.statusCode == 200 && res.data != null) {
        final List apiNotifs = res.data['data'] ?? [];
        if (apiNotifs.isNotEmpty) {
          final mapped = apiNotifs.map<Map<String, dynamic>>((n) {
            return {
              'id': n['id'],
              'title': n['title'] ?? 'حلقة جديدة',
              'body': n['message'] ?? n['body'] ?? 'تم بدء حلقة جديدة في إتقان',
              'time': n['created_at'] != null ? n['created_at'].toString().substring(0, 16) : 'مؤخراً',
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
  }

  void _deleteNotification(int id) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // الخلفية الكريمية الرسمية من الصورة 19
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF191919)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'الاشعارات',
          style: TextStyle(
            fontFamily: 'Dubai',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF191919),
          ),
        ),
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'لا توجد إشعارات حالياً',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bell icon outline on left
                      const Icon(Icons.notifications_none_rounded, color: Color(0xFF191919), size: 24),
                      const SizedBox(width: 10),

                      // Timestamp on left
                      Text(
                        notif['time'],
                        style: TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const Spacer(),

                      // Title & Subtitle on right
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            notif['title'],
                            style: const TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00875A), // أخضر مطابق للصورة 19
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif['body'],
                            style: const TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF191919),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Close 'X' Button on right
                      GestureDetector(
                        onTap: () => _deleteNotification(notif['id']),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.close, size: 14, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
