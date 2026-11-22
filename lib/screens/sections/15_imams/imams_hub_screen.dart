import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ImamsHubScreen extends StatefulWidget {
  const ImamsHubScreen({super.key});

  @override
  State<ImamsHubScreen> createState() => _ImamsHubScreenState();
}

class _ImamsHubScreenState extends State<ImamsHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _imamsList = [
    {
      'id': 'imam_1',
      'name': 'الشيخ القارئ عبد الرحمن المصري',
      'age': '32 عاماً',
      'quran': 'حافظ للقرآن الكريم ومجاز بالقراءات العشر الصغرى',
      'experience': '8 سنوات إمامة في مساجد القاهرة والرياض',
      'preferredCity': 'الرياض / جدة / مكة',
      'hasAudioSample': true,
      'audioTitle': 'تلاوة خاشعة من سورة مريم',
      'status': 'متاح للعمل فوراً',
    },
    {
      'id': 'imam_2',
      'name': 'الشيخ معاذ بن يوسف الشامي',
      'age': '28 عاماً',
      'quran': 'خريج كلية الشريعة، حافظ للقرآن برواية حفص وشعبة',
      'experience': '5 سنوات إمامة وتراويح وخطابة الجمعة',
      'preferredCity': 'دبي / الشارقة / أبوظبي',
      'hasAudioSample': true,
      'audioTitle': 'تلاوة من سورة طه بالترتيل الحجازي',
      'status': 'متاح للعمل فوراً',
    },
  ];

  final List<Map<String, dynamic>> _muazzinsList = [
    {
      'id': 'muazzin_1',
      'name': 'المؤذن عاصم عبد الله الحربي',
      'age': '26 عاماً',
      'experience': 'صوت ندي متقن لمقامات الأذان المكي والمدني',
      'preferredCity': 'المدينة المنورة / مكة المكرمة',
      'hasAudioSample': true,
      'audioTitle': 'أذان الفجر بالمقام الحجازي الخاشع',
      'status': 'متاح للعمل',
    },
    {
      'id': 'muazzin_2',
      'name': 'المؤذن بلال مصطفى رضوان',
      'age': '30 عاماً',
      'experience': '7 سنوات مؤذن رسمي، معرفة دقيقة بمواقيت الصلاة والتقويم',
      'preferredCity': 'الرياض / الدمام',
      'hasAudioSample': true,
      'audioTitle': 'أذان الظهر بمقام البيات والجهركاه',
      'status': 'متاح للعمل',
    },
  ];

  final List<Map<String, dynamic>> _mosqueJobVacancies = [
    {
      'title': 'مطلوب إمام راتب وخطيب جمعة',
      'mosque': 'جامع التقوى الكبير - حي النرجس، الرياض',
      'benefits': 'سكن مستقل مؤثث + راتب مجزٍ + تذاكر سنوية',
      'req': 'حفظ القرآن كاملاً وحسن الصوت وإجادة الخطابة',
    },
    {
      'title': 'مطلوب مؤذن رسمي متفرغ',
      'mosque': 'مسجد الفرقان - الشارقة، الإمارات',
      'benefits': 'سكن للمؤذن + مكافأة شهرية مجزية',
      'req': 'نداوة الصوت والالتزام الدقيق بمواعيد الأذان والإقامة',
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

  void _showJobApplicationDialog(BuildContext context, String role) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final cityController = TextEditingController();

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
                    const Icon(Icons.mosque_rounded, color: Color(0xFF00875A)),
                    const SizedBox(width: 8),
                    Text('تقديم طلب وظيفة: $role', style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const Divider(height: 20),
                const Text('الاسم الثلاثي:', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'اكتب اسمك الكامل',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('رقم الهاتف للتواصل (مع كود الدولة):', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+966...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('المدينة أو الدولة المستهدفة للعمل:', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: cityController,
                  decoration: InputDecoration(
                    hintText: 'مثال: الرياض، دبي، القاهرة...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00875A),
                    side: const BorderSide(color: Color(0xFF00875A)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم فتح مسجل الصوت لتسجيل نموذج التلاوة/الأذان.'), backgroundColor: Color(0xFF00875A)),
                    );
                  },
                  icon: const Icon(Icons.mic_rounded, size: 20),
                  label: const Text('تسجيل أو رفع نموذج صوتي (تلاوة/أذان)', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(height: 18),
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
                          content: Text('تم إرسال طلبك وسيرتك الذاتية بنجاح إلى منصة توظيف المساجد!'),
                          backgroundColor: Color(0xFF00875A),
                        ),
                      );
                    },
                    child: const Text('إرسال الطلب واعتماده', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white)),
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
          'الأئمة والمؤذنون',
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
            Tab(text: 'أئمة يطلبون عملاً'),
            Tab(text: 'مؤذنون يطلبون عملاً'),
            Tab(text: 'وظائف المساجد الشاغرة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Imams
          _buildProfilesList(_imamsList, isImam: true),
          // 2. Muazzins
          _buildProfilesList(_muazzinsList, isImam: false),
          // 3. Vacancies
          _buildVacanciesList(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00875A),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _showJobApplicationDialog(context, 'إمام مسجد'),
                icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 18),
                label: const Text('أنا إمام أبحث عن عمل', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00875A),
                  side: const BorderSide(color: Color(0xFF00875A)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _showJobApplicationDialog(context, 'مؤذن مسجد'),
                icon: const Icon(Icons.volume_up_rounded, size: 18),
                label: const Text('أنا مؤذن أبحث عن عمل', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilesList(List<Map<String, dynamic>> list, {required bool isImam}) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final p = list[idx];
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
                  Text(p['name'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 15, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
                    child: Text(p['status'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00875A))),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (isImam)
                Text(p['quran'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Color(0xFF00875A), fontWeight: FontWeight.bold)),
              Text('الخبرة: ${p['experience']}', style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade700)),
              Text('المدن المفضلة: ${p['preferredCity']}', style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade600)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_fill, color: Color(0xFF00875A), size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(p['audioTitle'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const Text('استماع للنموذج', style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Color(0xFF00875A), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVacanciesList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _mosqueJobVacancies.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final v = _mosqueJobVacancies[idx];
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
              Text(v['title'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF00875A))),
              const SizedBox(height: 4),
              Text(v['mosque'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('الشروط: ${v['req']}', style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade700)),
              Text('المزايا: ${v['benefits']}', style: const TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Color(0xFFB78103), fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00875A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إرسال ملفك الشخصي لإدارة المسجد لتحديد موعد المقابلة الصوتية.'), backgroundColor: Color(0xFF00875A)),
                    );
                  },
                  child: const Text('التقدم للوظيفة وإرسال الملف', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
