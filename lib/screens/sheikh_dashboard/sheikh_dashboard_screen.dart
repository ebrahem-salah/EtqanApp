import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/app_feedback.dart';
import '../../providers/auth_provider.dart';
import '../call/live_recitation_room.dart';
import '../notifications/notifications_screen.dart';

class SheikhDashboardScreen extends StatefulWidget {
  const SheikhDashboardScreen({super.key});

  @override
  State<SheikhDashboardScreen> createState() => _SheikhDashboardScreenState();
}

class _SheikhDashboardScreenState extends State<SheikhDashboardScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  List<Map<String, dynamic>> _mySessions = [];

  @override
  void initState() {
    super.initState();
    _loadSheikhSessions();
  }

  Future<void> _loadSheikhSessions() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.getMyClasses();
      if (res.statusCode == 200 && res.data != null) {
        final List raw = res.data['data'] is List ? res.data['data'] : [];
        final parsed = raw.map<Map<String, dynamic>>((c) {
          final bool isFinished = c['is_finished'] == true || c['status'] == 'completed';
          final bool isLive = !isFinished && (c['is_ongoing'] == true || c['status'] == 'ongoing');
          return {
            'id': int.tryParse('${c['id'] ?? 0}') ?? 0,
            'title': (c['name'] ?? c['title'] ?? 'حلقة تلاوة').toString(),
            'time': (c['starts_at'] ?? '').toString(),
            'students_count': int.tryParse('${c['students_count'] ?? 0}') ?? 0,
            'capacity': int.tryParse('${c['capacity'] ?? 30}') ?? 30,
            'isLive': isLive,
            'isFinished': isFinished,
            'status': isFinished ? 'منتهية' : (isLive ? 'جارية الآن 🔴' : 'في الانتظار'),
          };
        }).toList();
        if (mounted) {
          setState(() => _mySessions = parsed);
        }
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'جلب حلقات الشيخ', e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final sheikhName = user?.name.isNotEmpty == true ? user!.name : 'فضيلة الشيخ';
    final int ongoingCount = _mySessions.where((s) => s['isFinished'] != true).length;
    final int finishedCount = _mySessions.where((s) => s['isFinished'] == true).length;
    final int totalStudents = _mySessions.fold<int>(0, (sum, s) => sum + ((s['students_count'] as int?) ?? 0));

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'لوحة تحكم الشيخ المقرئ',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'الإشعارات',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSheikhSessions,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sheikh Profile Hero Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00875A), Color(0xFF005F3F)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold, width: 2.5),
                      ),
                      child: const Center(
                        child: Icon(Icons.person, color: Color(0xFF00875A), size: 34),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sheikhName,
                            style: const TextStyle(
                              fontFamily: 'Dubai',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'مشرف ومُقرئ معتمد في منصة إتقان',
                            style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Statistics Grid (حقيقية من حلقات الشيخ)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard('$ongoingCount', 'حلقات جارية', Icons.sensors_rounded, AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard('$totalStudents', 'إجمالي المشتركين', Icons.people_alt, const Color(0xFF2B7A78)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard('$finishedCount', 'حلقات منتهية', Icons.check_circle_outline, const Color(0xFFB78103)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard('${_mySessions.length}', 'إجمالي الحلقات', Icons.menu_book_rounded, const Color(0xFF1E5B42)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'حلقاتي المسجلة على السيرفر:',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191919),
                    ),
                  ),
                  Text('${_mySessions.length} حلقة', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (_mySessions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    'لا توجد حلقات منشأة بعد — يمكنك إضافة حلقة من قائمة حلقاتي أو الأقسام',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Dubai', fontSize: 13, color: Colors.grey.shade600),
                  ),
                )
              else
                ..._mySessions.map((sess) {
                  final isLive = sess['isLive'] == true;
                  final int cid = sess['id'] as int? ?? 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isLive ? const Color(0xFFEEF7F1) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isLive ? AppColors.primary : const Color(0xFFE2E0C8),
                        width: isLive ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                sess['title'] as String,
                                style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isLive ? AppColors.primary : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                sess['status'] as String,
                                style: TextStyle(
                                  fontFamily: 'Dubai',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isLive ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'المشتركون: ${sess['students_count']} / ${sess['capacity']} • ${sess['time']}',
                          style: const TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLive ? AppColors.primary : const Color(0xFF191919),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.mic, color: Colors.white, size: 18),
                            label: const Text(
                              'دخول غرفة التسميع',
                              style: TextStyle(fontFamily: 'Dubai', color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LiveRecitationRoom(
                                    roomId: cid > 0 ? 'room_srv_$cid' : 'room_${sess['title'].hashCode}',
                                    circleTitle: sess['title'] as String,
                                    isSheikh: true,
                                    classRoomId: cid > 0 ? cid : null,
                                    sheikhName: sheikhName,
                                    subscribersCount: sess['students_count'] as int?,
                                    capacity: sess['capacity'] as int?,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String val, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E0C8)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  val,
                  style: TextStyle(fontFamily: 'Dubai', fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
                Text(label, style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
