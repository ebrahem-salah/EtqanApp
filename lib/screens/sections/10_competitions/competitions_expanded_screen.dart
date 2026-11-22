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
      'id': 'comp_on_1',
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
      'id': 'comp_on_2',
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
      'id': 'comp_on_3',
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
      'title': 'مسابقة الملك سلمان المحلية لحفظ القرآن (حضوري - الرياض ومكة)',
      'type': 'قرآن كريم',
      'mode': 'أوفلاين حضوري',
      'prize': '150,000 ريال وجوائز كبرى',
      'location': 'مركز الملك عبد العزيز للمؤتمرات',
      'deadline': 'التسجيل متاح حتى نهاية الشهر',
      'badge': 'حضوري - قرآن',
      'icon': '🏛️',
    },
    {
      'id': 'comp_off_2',
      'title': 'المسابقة الدولية لحفظ وقراءة صحيح البخاري (حضوري)',
      'type': 'سنة نبوية',
      'mode': 'أوفلاين حضوري',
      'prize': '80,000 ريال',
      'location': 'جامع الإمام البخاري - القاهرة',
      'deadline': 'التسجيل مفتوح',
      'badge': 'حضوري - سنة',
      'icon': '🕌',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                  Text('التسجيل بالمسابقة الحضورية', style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 16)),
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
                        content: Text('تم تسجيلك بنجاح! تم إصدار بطاقة المتسابق ورقم الجلوس في قسم الشهادات.'),
                        backgroundColor: Color(0xFF00875A),
                      ),
                    );
                  },
                  child: const Text('تأكيد التسجيل وإصدار رقم الجلوس', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white)),
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
          'المسابقات الدينية (قرآن وسنة)',
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
          labelStyle: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'مسابقات أونلاين (قرآن/سنة)'),
            Tab(text: 'مسابقات أوفلاين حضورية'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOnlineList(),
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
                  const Spacer(),
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
                        competitionId: c['id'],
                        competitionTitle: c['title'],
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
