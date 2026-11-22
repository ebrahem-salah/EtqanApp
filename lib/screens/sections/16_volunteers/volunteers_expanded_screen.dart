import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class VolunteersExpandedScreen extends StatefulWidget {
  const VolunteersExpandedScreen({super.key});

  @override
  State<VolunteersExpandedScreen> createState() => _VolunteersExpandedScreenState();
}

class _VolunteersExpandedScreenState extends State<VolunteersExpandedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _dawahOpportunities = [
    {
      'title': 'التطوع في تحفيظ القرآن الكريم للصغار والبراعم',
      'hours': '3 ساعات أسبوعياً',
      'tasks': 'متابعة تسميع جزء عم وتبارك عبر الغرف الصوتية وتشجيع الأطفال.',
      'icon': '📖',
      'volunteersJoined': 64,
    },
    {
      'title': 'الإشراف التربوي على الحلقات القرآنية وتنظيم المواعيد',
      'hours': '4 ساعات أسبوعياً',
      'tasks': 'تنظيم الطلاب وضبط الحضور والغياب والتنسيق مع المقرئين.',
      'icon': '📋',
      'volunteersJoined': 42,
    },
    {
      'title': 'تصحيح التلاوة للمسلمين الجدد والناطقين بغير العربية',
      'hours': 'ساعتان أسبوعياً',
      'tasks': 'التدريب على مخارج الحروف الأساسية وقراءة سورة الفاتحة.',
      'icon': '🌐',
      'volunteersJoined': 38,
    },
  ];

  final List<Map<String, dynamic>> _technicalOpportunities = [
    {
      'title': 'التطوع في البرمجة وتطوير تطبيق إتقان (Flutter / Laravel)',
      'hours': 'مرن (حسب المهام البرمجية)',
      'tasks': 'تطوير الميزات وإصلاح الثغرات وتحسين سرعة تشغيل البثوث المباشرة.',
      'icon': '💻',
      'volunteersJoined': 28,
    },
    {
      'title': 'التصميم الجرافيكي وتجهيز بنرات المنصة والمسابقات',
      'hours': 'مرن',
      'tasks': 'تصميم بطاقات الآيات والأحاديث وبوسترات الدورات والشهادات.',
      'icon': '🎨',
      'volunteersJoined': 35,
    },
    {
      'title': 'مونتاج وهندسة الصوت لتلاوات الشيوخ ومقاطع الريلز',
      'hours': 'مرن',
      'tasks': 'تنقية الصوت وإخراج مقاطع التلاوة القصيرة ونشرها بالمنصة.',
      'icon': '🎙️',
      'volunteersJoined': 49,
    },
    {
      'title': 'الترجمة الإسلامية لمعاني القرآن والواجهات (الإنجليزية/الفرنسية)',
      'hours': 'ساعتان أسبوعياً',
      'tasks': 'ترجمة تفاسير الآيات الميسرة وقوائم التطبيق لنشر الخير عالمياً.',
      'icon': '🌍',
      'volunteersJoined': 22,
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

  void _showJoinVolunteerDialog(BuildContext context, String title, String field) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final expCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.volunteer_activism, color: Color(0xFF00875A)),
                    const SizedBox(width: 8),
                    const Text('الانضمام لفريق المتطوعين', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const Divider(height: 20),
                Text('المهمة: $title', style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF00875A))),
                Text('المجال: $field', style: const TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                const Text('الاسم الثلاثي:', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'اكتب اسمك الكريم',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('رقم الهاتف والواتساب:', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+966...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('نبذة عن خبرتك أو مهاراتك:', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                TextField(
                  controller: expCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'مثال: حافظ لـ 15 جزء / مبرمج فلاتر سنتين / مصمم...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00875A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('بارك الله فيك وجزاك خيراً! تم تسجيل طلب تطوعك وسيتواصل معك مشرف القسم.'),
                          backgroundColor: Color(0xFF00875A),
                        ),
                      );
                    },
                    child: const Text('تأكيد الانضمام لفريق التطوع', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
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
          'المتطوعون (التطوع في المنصة)',
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
            Tab(text: 'متطوع في مجال الدعوة'),
            Tab(text: 'متطوع في المجال الفني والتقني'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOppsList(_dawahOpportunities, 'مجال الدعوة والقرآن'),
          _buildOppsList(_technicalOpportunities, 'المجال الفني والتقني'),
        ],
      ),
    );
  }

  Widget _buildOppsList(List<Map<String, dynamic>> list, String field) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final item = list[idx];
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
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00875A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text(item['icon'] ?? '🤝', style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['title'],
                      style: const TextStyle(fontFamily: 'Dubai', fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(item['tasks'], style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade700, height: 1.4)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(item['hours'], style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade600)),
                  const Spacer(),
                  const Icon(Icons.group_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${item['volunteersJoined']} متطوع منضم', style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00875A))),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00875A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showJoinVolunteerDialog(context, item['title'], field),
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                  label: const Text('التطوع في هذه المهمة ونيل الأجر', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
