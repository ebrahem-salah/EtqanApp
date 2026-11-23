import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../competitions/widgets/competition_exam_sheet.dart';
import '../dialogs/create_section_session_dialog.dart';

class CompetitionsExpandedScreen extends StatefulWidget {
  const CompetitionsExpandedScreen({super.key});

  @override
  State<CompetitionsExpandedScreen> createState() => _CompetitionsExpandedScreenState();
}

class _CompetitionsExpandedScreenState extends State<CompetitionsExpandedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _onlineCompetitions = [
    {
      'id': 101,
      'title': 'مسابقة إتقان الكبرى لحفظ القرآن الكريم وتجويده (أونلاين)',
      'type': 'قرآن كريم',
      'mode': 'أونلاين',
      'prize': '50,000 ريال جوائز',
      'participants': '2,450 متسابق',
      'deadline': 'ينتهي بعد 5 أيام',
      'isLiveTesting': true,
      'badge': 'مسابقة القرآن',
      'icon': '📖',
    },
    {
      'id': 102,
      'title': 'مسابقة حفظ الأربعين النووية والمتون الحديثية (أونلاين)',
      'type': 'سنة نبوية',
      'mode': 'أونلاين',
      'prize': '25,000 ريال جوائز',
      'participants': '1,120 متسابق',
      'deadline': 'ينتهي بعد 12 يوماً',
      'isLiveTesting': false,
      'badge': 'مسابقة السنة',
      'icon': '📜',
    },
    {
      'id': 103,
      'title': 'مسابقة مزامير إتقان لحسن الصوت والتلاوة (تصفيات صوتية)',
      'type': 'قرآن كريم',
      'mode': 'أونلاين',
      'prize': '30,000 ريال جوائز',
      'participants': '890 متسابق',
      'deadline': 'تصفيات جارية الآن',
      'isLiveTesting': true,
      'badge': 'مسابقة القرآن',
      'icon': '🎙️',
    },
  ];

  final List<Map<String, dynamic>> _offlineCompetitions = [
    {
      'id': 'comp_off_1',
      'title': 'المسابقة الميدانية لحفظ القرآن كاملاً بمكة المكرمة',
      'type': 'قرآن كريم',
      'location': 'جامع الراجحي - مكة المكرمة',
      'prize': '100,000 ريال جوائز',
      'date': '15 شعبان 1447هـ',
      'badge': 'مسابقة ميدانية',
    },
    {
      'id': 'comp_off_2',
      'title': 'الملتقى التنافسي لحفاظ الحديث الشريف بالمدينة النبوية',
      'type': 'سنة نبوية',
      'location': 'قاعة المؤتمرات بالجامعة الإسلامية',
      'prize': '60,000 ريال جوائز',
      'date': '20 شعبان 1447هـ',
      'badge': 'سنة نبوية',
    },
  ];

  // لوحة المتصدرين الرسمية (Leaderboard) للمتسابقين الأوائل
  final List<Map<String, dynamic>> _leaderboard = [
    {
      'rank': 1,
      'name': 'عبد الرحمن بن خالد العتيبي',
      'avatar': '👑',
      'score': '99.5%',
      'points': 2480,
      'badge': 'المركز الأول 🥇',
      'color': const Color(0xFFD4AF37),
      'branch': 'القرآن كاملاً',
    },
    {
      'rank': 2,
      'name': 'فاطمة الزهراء الشناوي',
      'avatar': '🥈',
      'score': '98.75%',
      'points': 2390,
      'badge': 'المركز الثاني 🥈',
      'color': const Color(0xFF9E9E9E),
      'branch': 'عشرون جزءاً',
    },
    {
      'rank': 3,
      'name': 'عمر بن عبد العزيز الهلالي',
      'avatar': '🥉',
      'score': '98.25%',
      'points': 2310,
      'badge': 'المركز الثالث 🥉',
      'color': const Color(0xFFCD7F32),
      'branch': 'القرآن كاملاً',
    },
    {
      'rank': 4,
      'name': 'إبراهيم صلاح (أنت)',
      'avatar': '⭐',
      'score': '97.5%',
      'points': 2240,
      'badge': 'المستوى الممتاز',
      'color': const Color(0xFF00875A),
      'branch': 'الأربعين النووية',
    },
    {
      'rank': 5,
      'name': 'أنس بن مالك الكردي',
      'avatar': '👤',
      'score': '96.0%',
      'points': 2180,
      'badge': 'مرتبة الشرف',
      'color': const Color(0xFF1E88E5),
      'branch': 'عشرة أجزاء',
    },
    {
      'rank': 6,
      'name': 'مريم أحمد عبد الله',
      'avatar': '👤',
      'score': '95.5%',
      'points': 2110,
      'badge': 'مرتبة الشرف',
      'color': const Color(0xFF00875A),
      'branch': 'مزامير إتقان',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showRegisterOfflineDialog(BuildContext context, Map<String, dynamic> comp) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: Color(0xFF00875A)),
                  const SizedBox(width: 8),
                  const Text('التسجيل بالمسابقة الميدانية', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const Divider(height: 20),
              Text(comp['title'], style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF00875A))),
              const SizedBox(height: 8),
              Text('المقر والمدينة: ${comp['location']}', style: const TextStyle(fontFamily: 'Dubai', fontSize: 12)),
              const SizedBox(height: 14),
              const Text('سيتم إصدار رقم الجلوس وبطاقة المتسابق وتأكيد موعد المثول أمام لجنة التحكيم الميدانية.', style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.black54)),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00875A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎉 تم تسجيلك بنجاح! صدرت بطاقة المتسابق ورقم الجلوس في قسم الشهادات.'),
                        backgroundColor: Color(0xFF00875A),
                      ),
                    );
                  },
                  child: const Text('تأكيد التسجيل وإصدار بطاقة المتسابق', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'المسابقات الدينية ولوحة الشرف',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'مسابقات أونلاين 🌐'),
            Tab(text: 'لوحة المتصدرين 🏆'),
            Tab(text: 'مسابقات ميدانية 🏛️'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOnlineList(),
          _buildLeaderboardView(),
          _buildOfflineList(),
        ],
      ),
    );
  }

  Widget _buildOnlineList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _onlineCompetitions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, idx) {
        final c = _onlineCompetitions[idx];
        final bool isLive = c['isLiveTesting'] == true;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isLive ? Border.all(color: const Color(0xFF00875A), width: 1.5) : null,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFF00875A).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(c['badge'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00875A))),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(8)),
                    child: Text('🏆 ${c['prize']}', style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF57F17))),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(c['title'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(c['participants'], style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(width: 14),
                  const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(c['deadline'], style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00875A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => CompetitionExamSheet(
                        competitionId: c['id'] as int,
                        studentId: 1,
                        studentName: 'إبراهيم صلاح',
                        onEvaluationSubmitted: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎉 تم احتساب نتيجتك وإضافتها لرصيد نقاطك ولوحة المتصدرين!'),
                              backgroundColor: Color(0xFF00875A),
                            ),
                          );
                          _tabController.animateTo(1);
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 18),
                  label: const Text('بدء الاختبار التفاعلي أونلاين', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // تبويب لوحة الشرف والمتصدرين
  Widget _buildLeaderboardView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Top 3 Podium
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F5B46), Color(0xFF00875A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: const Color(0xFF00875A).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              const Text(
                '🏆 متصدرو مسابقات إتقان لهذا الأسبوع',
                style: TextStyle(fontFamily: 'Dubai', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 2nd Place
                  _buildPodiumItem(rank: '2', name: 'فاطمة الزهراء', points: '2,390', medal: '🥈', height: 80, color: const Color(0xFFB0BEC5)),
                  // 1st Place
                  _buildPodiumItem(rank: '1', name: 'عبد الرحمن خالد', points: '2,480', medal: '👑', height: 110, color: const Color(0xFFFFD700)),
                  // 3rd Place
                  _buildPodiumItem(rank: '3', name: 'عمر عبد العزيز', points: '2,310', medal: '🥉', height: 65, color: const Color(0xFFCD7F32)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Leaderboard Ranking List
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
          child: Text(
            'قائمة ترتيب المتسابقين الكلية',
            style: TextStyle(fontFamily: 'Dubai', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
          ),
        ),
        ..._leaderboard.map((item) {
          final isUser = item['name'].toString().contains('أنت');
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFFE8F5E9) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isUser ? const Color(0xFF00875A) : const Color(0xFFE8E8DC), width: isUser ? 1.5 : 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF00875A) : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${item['rank']}',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item['name'],
                            style: TextStyle(
                              fontFamily: 'Dubai',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isUser ? const Color(0xFF00875A) : const Color(0xFF191919),
                            ),
                          ),
                          if (isUser) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.stars_rounded, color: Color(0xFF00875A), size: 16),
                          ],
                        ],
                      ),
                      Text(
                        '${item['branch']} • الدرجة: ${item['score']}',
                        style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item['points']} نقطة',
                      style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF00875A)),
                    ),
                    Text(
                      item['badge'],
                      style: const TextStyle(fontFamily: 'Dubai', fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPodiumItem({
    required String rank,
    required String name,
    required String points,
    required String medal,
    required double height,
    required Color color,
  }) {
    return Column(
      children: [
        Text(medal, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
        Text('$points نقطة', style: const TextStyle(fontFamily: 'Dubai', fontSize: 10, color: Colors.white70)),
        const SizedBox(height: 6),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            border: Border.all(color: color, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            rank,
            style: TextStyle(fontFamily: 'Dubai', fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _offlineCompetitions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, idx) {
        final c = _offlineCompetitions[idx];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(8)),
                    child: Text(c['badge'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF283593))),
                  ),
                  Text('🏆 ${c['prize']}', style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF57F17))),
                ],
              ),
              const SizedBox(height: 10),
              Text(c['title'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(c['location'], style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF283593),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showRegisterOfflineDialog(context, c),
                  icon: const Icon(Icons.assignment_turned_in_outlined, color: Colors.white, size: 18),
                  label: const Text('التسجيل الميداني وحجز موعد الاختبار', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
