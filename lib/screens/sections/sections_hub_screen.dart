import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'dialogs/create_section_session_dialog.dart';
import '01_library/library_hub_screen.dart';
import '02_nourania/nourania_hub_screen.dart';
import '03_quran/quran_hub_screen.dart';
import '04_ihdaa_thawab/ihdaa_thawab_screen.dart';
import '05_sunnah/sunnah_hub_screen.dart';
import '06_courses/courses_hub_screen.dart';
import '07_other_sciences/other_sciences_screen.dart';
import '08_fatwas/fatwas_hub_screen.dart';
import '09_ruqyah/ruqyah_hub_screen.dart';
import '10_competitions/competitions_expanded_screen.dart';
import '11_certificates/certificates_hub_screen.dart';
import '12_radios/radios_expanded_screen.dart';
import '13_muslim_child/muslim_child_screen.dart';
import '14_muslim_woman/muslim_woman_screen.dart';
import '15_imams/imams_hub_screen.dart';
import '16_volunteers/volunteers_expanded_screen.dart';

class SectionsHubScreen extends StatefulWidget {
  const SectionsHubScreen({super.key});

  @override
  State<SectionsHubScreen> createState() => _SectionsHubScreenState();
}

class _SectionsHubScreenState extends State<SectionsHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _sections = [
    {
      'id': 1,
      'title': 'المكتبة الإلكترونية',
      'icon': '📚',
      'subCount': '5 فروع',
      'subs': ['قسم المصاحف', 'كتب التفسير', 'كتب الحديث', 'التجويد', 'علوم أخرى'],
      'color': const Color(0xFF00875A),
      'screenBuilder': (BuildContext ctx) => const LibraryHubScreen(),
    },
    {
      'id': 2,
      'title': 'القاعدة النورانية وتعليم الحروف',
      'icon': '🔤',
      'subCount': '3 مستويات',
      'subs': ['المستوى الأول (المفردة)', 'المستوى الثاني (المركبة)', 'المستوى الثالث (أحكام التجويد)'],
      'color': const Color(0xFF1E88E5),
      'screenBuilder': (BuildContext ctx) => const NouraniaHubScreen(),
    },
    {
      'id': 3,
      'title': 'القرآن الكريم',
      'icon': '📖',
      'subCount': '11 فرعاً',
      'subs': ['الحفظ (صغار/كبار)', 'المراجعة (30 جزء)', 'فمي بشوق', 'التجويد', 'المقرأة', 'المدارسة', 'القراءات العشر', 'المقامات', 'الإسناد'],
      'color': const Color(0xFF00796B),
      'screenBuilder': (BuildContext ctx) => const QuranHubScreen(),
    },
    {
      'id': 4,
      'title': 'مقرأة إهداء الثواب',
      'icon': '🤲',
      'subCount': 'مستقل للثواب',
      'subs': ['إهداء للمتوفين', 'للمرضى', 'للوالدين', 'مقارئ الختمات'],
      'color': const Color(0xFF5D4037),
      'screenBuilder': (BuildContext ctx) => const IhdaaThawabScreen(),
    },
    {
      'id': 5,
      'title': 'السنة النبوية',
      'icon': '📜',
      'subCount': '5 فروع',
      'subs': ['الحفظ (صغار/كبار)', 'علوم الحديث', 'شروح الأحاديث', 'الإقراء', 'القراءة بالإسناد'],
      'color': const Color(0xFFD84315),
      'screenBuilder': (BuildContext ctx) => const SunnahHubScreen(),
    },
    {
      'id': 6,
      'title': 'الدورات العلمية',
      'icon': '🎓',
      'subCount': 'عامة وخاصة',
      'subs': ['الدورات العلمية العامة', 'الدورات العلمية الخاصة'],
      'color': const Color(0xFF6A1B9A),
      'screenBuilder': (BuildContext ctx) => const CoursesHubScreen(),
    },
    {
      'id': 7,
      'title': 'علوم أخرى',
      'icon': '🌟',
      'subCount': '4 علوم',
      'subs': ['الفقه', 'السيرة النبوية', 'العقيدة', 'الرقائق'],
      'color': const Color(0xFF2E7D32),
      'screenBuilder': (BuildContext ctx) => const OtherSciencesScreen(),
    },
    {
      'id': 8,
      'title': 'الفتاوى',
      'icon': '🕌',
      'subCount': '3 أقسام',
      'subs': ['دار الإفتاء الإلكترونية', 'فتاوى مباشرة (بث حي)', 'فتاوى مؤرشفة'],
      'color': const Color(0xFF37474F),
      'screenBuilder': (BuildContext ctx) => const FatwasHubScreen(),
    },
    {
      'id': 9,
      'title': 'الرقية الشرعية',
      'icon': '🛡️',
      'subCount': 'مباشرة ومعالجون',
      'subs': ['رقية مباشرة', 'د. محمد كمال بو حسين', 'د. أحمد عبد المنعم'],
      'color': const Color(0xFF00695C),
      'screenBuilder': (BuildContext ctx) => const RuqyahHubScreen(),
    },
    {
      'id': 10,
      'title': 'المسابقات الدينية',
      'icon': '🏆',
      'subCount': 'أونلاين وأوفلاين',
      'subs': ['مسابقات القرآن أونلاين/أوفلاين', 'مسابقات السنة أونلاين/أوفلاين'],
      'color': const Color(0xFFF57F17),
      'screenBuilder': (BuildContext ctx) => const CompetitionsExpandedScreen(),
    },
    {
      'id': 11,
      'title': 'الشهادات والإجازات',
      'icon': '📜',
      'subCount': 'توثيق رسمي',
      'subs': ['إجازات بالسند المتصل', 'شهادات القرآن والسنة', 'شهادات النورانية والدورات'],
      'color': const Color(0xFFD4AF37),
      'screenBuilder': (BuildContext ctx) => const CertificatesHubScreen(),
    },
    {
      'id': 12,
      'title': 'الإذاعات الإسلامية',
      'icon': '📻',
      'subCount': 'بث مباشر',
      'subs': ['إذاعة القاهرة', 'مكة المكرمة', 'الرياض', 'إذاعة الحديث', 'كبار القراء'],
      'color': const Color(0xFF1565C0),
      'screenBuilder': (BuildContext ctx) => const RadiosExpandedScreen(),
    },
    {
      'id': 13,
      'title': 'الطفل المسلم',
      'icon': '👶',
      'subCount': '3 أقسام',
      'subs': ['قصص القرآن والسيرة', 'آداب الطفل المسلم', 'أحاديث وأذكار البراعم'],
      'color': const Color(0xFF0288D1),
      'screenBuilder': (BuildContext ctx) => const MuslimChildScreen(),
    },
    {
      'id': 14,
      'title': 'المرأة المسلمة',
      'icon': '🧕',
      'subCount': '3 أقسام',
      'subs': ['أحكام المرأة', 'آداب وسير الصالحات', 'أعمال وبركات البيت'],
      'color': const Color(0xFFC2185B),
      'screenBuilder': (BuildContext ctx) => const MuslimWomanScreen(),
    },
    {
      'id': 15,
      'title': 'الأئمة والمؤذنون',
      'icon': '🕌',
      'subCount': 'توظيف المساجد',
      'subs': ['إمام يبحث عن عمل', 'مؤذن يبحث عن عمل', 'فرص ووظائف المساجد'],
      'color': const Color(0xFF4527A0),
      'screenBuilder': (BuildContext ctx) => const ImamsHubScreen(),
    },
    {
      'id': 16,
      'title': 'المتطوعون',
      'icon': '🤝',
      'subCount': 'دعوي وفني',
      'subs': ['متطوع في مجال الدعوة', 'متطوع في المجال الفني والتقني'],
      'color': const Color(0xFF2E7D32),
      'screenBuilder': (BuildContext ctx) => const VolunteersExpandedScreen(),
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _sections.where((s) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final titleMatch = s['title'].toString().toLowerCase().contains(q);
      final subsMatch = (s['subs'] as List).any((sub) => sub.toString().toLowerCase().contains(q));
      return titleMatch || subsMatch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'أقسام منصة إتقان (16 قسماً)',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'إنشاء حلقة / جلسة بث مباشر',
            onPressed: () {
              CreateSectionSessionDialog.show(context);
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Search & Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Live Banner Alert
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFFE53935).withOpacity(0.95), const Color(0xFFC62828)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFE53935).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sensors_rounded, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🔴 بث مباشر مستمر في مقاطع الريلز',
                                style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                              ),
                              Text(
                                'أي حلقة أو مقرأة أو رقية تبدأ تظهر فوراً لجميع المستخدمين في الريلز',
                                style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFC62828),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => CreateSectionSessionDialog.show(context),
                          child: const Text('ابدأ بثك', style: TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Search Field
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'ابحث في الأقسام الـ 16 (مقرأة، سنة، فتاوى، رقية، نورانية...)',
                      hintStyle: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade500),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF00875A)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'الأقسام الرئيسية الشاملة للتطبيق:',
                    style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF191919)),
                  ),
                ],
              ),
            ),
          ),

          // List of 16 Sections in Single Clean Rows (بدون صور مشتتة وكل قسم في صف مستقل)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final section = filtered[index];
                  final Color col = section['color'] as Color;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE8E8DC)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          final builder = section['screenBuilder'] as Widget Function(BuildContext);
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: builder),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: col.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    section['icon'] ?? '📖',
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            section['title'],
                                            style: const TextStyle(
                                              fontFamily: 'Dubai',
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF191919),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: col.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            section['subCount'],
                                            style: TextStyle(
                                              fontFamily: 'Dubai',
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: col,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      (section['subs'] as List).join(' • '),
                                      style: TextStyle(
                                        fontFamily: 'Dubai',
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: col),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'إنشاء حلقة / بث مباشر',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold),
        ),
        onPressed: () => CreateSectionSessionDialog.show(context),
      ),
    );
  }
}
