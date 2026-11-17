import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../call/live_recitation_room.dart';
import '../evaluation/evaluation_rubric_screen.dart';

class SheikhDashboardScreen extends StatefulWidget {
  const SheikhDashboardScreen({super.key});

  @override
  State<SheikhDashboardScreen> createState() => _SheikhDashboardScreenState();
}

class _SheikhDashboardScreenState extends State<SheikhDashboardScreen> {
  final List<Map<String, dynamic>> _todaySessions = [
    {
      'id': 'sess_1',
      'studentName': 'أحمد عبد المنعم موسى',
      'surah': 'حلقة سورة البقرة وتصحيح التلاوة',
      'time': '04:00 PM - اليوم',
      'mode': 'voice',
      'status': 'جارية الآن 🔴',
      'isLive': true,
      'avatar': '👨‍🎓',
    },
    {
      'id': 'sess_2',
      'studentName': 'عمر بن عبد العزيز المصري',
      'surah': 'حلقة إتقان سورة آل عمران والمدود',
      'time': '05:30 PM - اليوم',
      'mode': 'video',
      'status': 'مجدولة',
      'isLive': false,
      'avatar': '🧑‍🎓',
    },
    {
      'id': 'sess_3',
      'studentName': 'ياسين خالد الكندري',
      'surah': 'اختبار مسابقة فرسان إتقان (15 جزءاً)',
      'time': '07:00 PM - اليوم',
      'mode': 'video',
      'status': 'مجدولة',
      'isLive': false,
      'avatar': '👨',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
            tooltip: 'تنبيهات الطلاب',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔔 لديك 3 حجوزات جديدة بانتظار التأكيد')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 2.5),
                    ),
                    child: const Center(
                      child: Text('👳‍♂️', style: TextStyle(fontSize: 34)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'فضيلة الشيخ عبد الله السويسي',
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'إجازة بالسند المتصل برواية حفص عن عاصم',
                          style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'مشرف معتمد لدى منظومة إتقان العالمية',
                          style: TextStyle(fontFamily: 'Dubai', fontSize: 10, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Statistics Grid (4 Key Metrics)
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard('1,240', 'ساعة تدريس', Icons.timer, AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard('184', 'طالباً معتمداً', Icons.people_alt, const Color(0xFF2B7A78)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard('⭐ 4.9', 'تقييم الطلاب', Icons.star, const Color(0xFFB78103)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard('3,400', 'نقطة مستحقة', Icons.account_balance_wallet, const Color(0xFF1E5B42)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Today's Live Sessions Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'جلسات التسميع المباشرة لليوم:',
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191919),
                  ),
                ),
                Text('3 جلسات', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),

            // Sessions List
            ..._todaySessions.map((sess) {
              final isLive = sess['isLive'] == true;
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
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(sess['avatar'] as String, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Text(
                              sess['studentName'] as String,
                              style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
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
                      sess['surah'] as String,
                      style: const TextStyle(fontFamily: 'Dubai', fontSize: 13, color: Color(0xFF444444)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'الموعد: ${sess['time']} • النمط: ${sess['mode'] == 'voice' ? '🎙️ غرفة صوتية 48kHz' : '📹 فيديو كول'}',
                      style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),

                    // Action Buttons for Sheikh
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLive ? AppColors.primary : const Color(0xFF191919),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.mic, color: Colors.white, size: 18),
                            label: Text(
                              isLive ? 'دخول غرفة التسميع المباشرة' : 'بدء الجلسة في موعدها',
                              style: const TextStyle(fontFamily: 'Dubai', color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LiveRecitationRoom(
                                    roomId: sess['id'] as String,
                                    circleTitle: sess['surah'] as String,
                                    isSheikh: true,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Icon(Icons.workspace_premium, color: AppColors.primary, size: 18),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EvaluationRubricScreen(
                                  studentName: sess['studentName'] as String,
                                  sheikhName: 'الشيخ عبد الله السويسي',
                                  surahTested: sess['surah'] as String,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
        ],
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
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
