import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/services/user_chapters_service.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../call/live_recitation_room.dart';
import '../sections/sections_hub_screen.dart';
import '../sections/01_library/library_hub_screen.dart';
import '../sections/02_nourania/nourania_hub_screen.dart';
import '../sections/03_quran/quran_hub_screen.dart';
import '../sections/04_ihdaa_thawab/ihdaa_thawab_screen.dart';
import '../sections/05_sunnah/sunnah_hub_screen.dart';
import '../sections/06_courses/courses_hub_screen.dart';
import '../sections/07_other_sciences/other_sciences_screen.dart';
import '../sections/08_fatwas/fatwas_hub_screen.dart';
import '../sections/09_ruqyah/ruqyah_hub_screen.dart';
import '../sections/10_competitions/competitions_expanded_screen.dart';
import '../sections/11_certificates/certificates_hub_screen.dart';
import '../sections/12_radios/radios_expanded_screen.dart';
import '../sections/13_muslim_child/muslim_child_screen.dart';
import '../sections/14_muslim_woman/muslim_woman_screen.dart';
import '../sections/15_imams/imams_hub_screen.dart';
import '../sections/16_volunteers/volunteers_expanded_screen.dart';
import 'add_chapter_screen.dart';
import 'section_circles_screen.dart';
import '../../core/constants/category_mapping.dart';

class ChaptersScreen extends StatefulWidget {
  const ChaptersScreen({super.key});

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  int _selectedCategoryIndex = 2; // Default: القرآن الكريم
  final ApiClient _apiClient = ApiClient();
  final List<Map<String, dynamic>> _liveClasses = [];

  // الأقسام الـ 16 الرئيسية والفرعية الشاملة للتطبيق بدون ترقيم أولاً/ثانياً
  final List<Map<String, dynamic>> _sectionsConfig = [
    {
      'title': 'المكتبة الإلكترونية',
      'icon': '📚',
      'subs': [
        {'title': 'قسم المصاحف', 'icon': '📖', 'desc': 'تصفح المصاحف المعتمدة والتلاوات المرتلة'},
        {'title': 'كتب التفسير', 'icon': '📜', 'desc': 'تفسير ابن كثير، الطبري، والسعدي'},
        {'title': 'كتب الحديث', 'icon': '🕌', 'desc': 'صحيح البخاري، مسلم، والسنن الأربعة'},
        {'title': 'أحكام التجويد', 'icon': '🎙️', 'desc': 'متون الجزرية، تحفة الأطفال والشروح'},
        {'title': 'علوم أخرى', 'icon': '✨', 'desc': 'أصول الفقه، السيرة، والتزكية الإسلامية'},
      ],
      'hubBuilder': (BuildContext ctx) => const LibraryHubScreen(),
    },
    {
      'title': 'تعليم الحروف والقاعدة النورانية',
      'icon': '🔤',
      'subs': [
        {'title': 'المستوى الأول: الحروف المفردة', 'icon': '1️⃣', 'desc': 'مخارج الحروف وصورها المفردة ونطقها'},
        {'title': 'المستوى الثاني: الحروف المركبة', 'icon': '2️⃣', 'desc': 'تركيب الحروف والمدود الطبيعية والحركات'},
        {'title': 'المستوى الثالث: أحكام التجويد', 'icon': '3️⃣', 'desc': 'الغنن، القلقلة، والإتقان العملي للتلاوة'},
        {'title': 'لوحة الحروف التفاعلية (28 حرفاً)', 'icon': '🔊', 'desc': 'استماع ونطق صحيح مباشر لكل حرف'},
      ],
      'hubBuilder': (BuildContext ctx) => const NouraniaHubScreen(),
    },
    {
      'title': 'القرآن الكريم',
      'icon': '📖',
      'subs': [
        {'title': 'الحفظ (الصغار)', 'icon': '👦', 'desc': 'تحفيظ متدرج للناشئة والأشبال مع المتابعة'},
        {'title': 'الحفظ (الكبار)', 'icon': '👨', 'desc': 'مسارات الحفظ المتقن والخطط المرنة للكبار'},
        {'title': 'المراجعة (ثلاثون جزء)', 'icon': '🔁', 'desc': 'تثبيت الأجزاء وتسميع كامل المصحف'},
        {'title': 'المراجعة (فمي بشوق)', 'icon': '🌟', 'desc': 'تقسيم الأحزاب بالسنة النبوية الشريفة'},
        {'title': 'التجويد ومخارج الحروف', 'icon': '🎙️', 'desc': 'ضبط الأحكام والتطبيق العملي الدقيق'},
        {'title': 'المدارسة والتدبر', 'icon': '💡', 'desc': 'مدارسة آيات الكتاب وفهم مقاصدها'},
        {'title': 'المقرأة الجماعية', 'icon': '👥', 'desc': 'تصحيح جماعي مباشر مع كبار الشيوخ'},
        {'title': 'علوم القرآن', 'icon': '📜', 'desc': 'الناسخ والمنسوخ وأسباب النزول والمكي والمدني'},
        {'title': 'القراءات العشر', 'icon': '✨', 'desc': 'القراءات الصغرى والكبرى ورواياتها'},
        {'title': 'المقامات الصوتية', 'icon': '🎵', 'desc': 'تحسين الصوت وتوظيف المقامات للخشوع'},
        {'title': 'التفسير القرآني', 'icon': '📚', 'desc': 'بيان معاني الآيات وغريب القرآن الكريم'},
        {'title': 'القراءة بالإسناد المتصل', 'icon': '🎖️', 'desc': 'ختمات الإجازة بالسند المتصل إلى النبي ﷺ'},
      ],
      'hubBuilder': (BuildContext ctx) => const QuranHubScreen(),
    },
    {
      'title': 'مقرأة إهداء الثواب',
      'icon': '🤲',
      'subs': [
        {'title': 'ختمة إهداء الوالدين', 'icon': '🤍', 'desc': 'حلقات إهداء ثواب التلاوة للوالدين براً ووفاءً'},
        {'title': 'ختمة إهداء المتوفين', 'icon': '🕊️', 'desc': 'جلسات ختم القرآن وإهداء أجرها لأموات المسلمين'},
        {'title': 'ختمة إهداء عامة', 'icon': '🌸', 'desc': 'قراءات تطوعية محتسبة الأجر عن الأمة'},
        {'title': 'إهداء المرضى وتفريج الكرب', 'icon': '🌿', 'desc': 'تلاوات استشفاء ودعاء بالشفاء العاجل'},
      ],
      'hubBuilder': (BuildContext ctx) => const IhdaaThawabScreen(),
    },
    {
      'title': 'السنة النبوية',
      'icon': '📜',
      'subs': [
        {'title': 'الحفظ (الصغار)', 'icon': '👦', 'desc': 'الأربعون النووية وقصار الأحاديث الشريفة'},
        {'title': 'الحفظ (الكبار)', 'icon': '👨', 'desc': 'رياض الصالحين وعمدة الأحكام والسنن'},
        {'title': 'علوم الحديث ومصطلحه', 'icon': '🔍', 'desc': 'دراسة السند والمتن والجرح والتعديل'},
        {'title': 'شروح الأحاديث النبوية', 'icon': '💡', 'desc': 'فتح الباري وشرح النووي على مسلم'},
        {'title': 'الإقراء لكتب السنة المعتمدة', 'icon': '📖', 'desc': 'مجالس السماع والإقراء لكتب الصحاح'},
        {'title': 'القراءة بالإسناد المتصل', 'icon': '🎖️', 'desc': 'مجالس الإسناد المتصل برواية الحديث الشريف'},
      ],
      'hubBuilder': (BuildContext ctx) => const SunnahHubScreen(),
    },
    {
      'title': 'الدورات العلمية',
      'icon': '🎓',
      'subs': [
        {'title': 'الدورات العلمية العامة', 'icon': '🌐', 'desc': 'محاضرات مفتوحة في العقيدة، التفسير، والفقه'},
        {'title': 'الدورات العلمية الخاصة', 'icon': '🔒', 'desc': 'دبلومات تأهيلية مكثفة واختبارات معتمدة'},
      ],
      'hubBuilder': (BuildContext ctx) => const CoursesHubScreen(),
    },
    {
      'title': 'علوم أخرى',
      'icon': '✨',
      'subs': [
        {'title': 'الفقه الإسلامي الميسر', 'icon': '⚖️', 'desc': 'فقه العبادات والمعاملات وفق المذاهب المعتبرة'},
        {'title': 'السيرة النبوية والتاريخ', 'icon': '🌙', 'desc': 'أيام النبوة والمغازي والدروس والعبر'},
        {'title': 'العقيدة الإسلامية الصافية', 'icon': '🛡️', 'desc': 'شروح العقيدة الواسطية وأصول الإيمان'},
        {'title': 'الرقائق والتزكية الإيمانية', 'icon': '💧', 'desc': 'أعمال القلوب، الخشوع، وتهذيب النفس'},
      ],
      'hubBuilder': (BuildContext ctx) => const OtherSciencesScreen(),
    },
    {
      'title': 'الفتاوى',
      'icon': '⚖️',
      'subs': [
        {'title': 'فتاوى دار الإفتاء الإلكترونية', 'icon': '🏛️', 'desc': 'فتاوى رسمية وموثقة في النوازل المعاصرة'},
        {'title': 'جلسات الفتاوى المباشرة', 'icon': '🎙️', 'desc': 'طرح الأسئلة وتلقي الإجابة فورياً من المفتين'},
        {'title': 'الفتاوى المؤرشفة والبحث', 'icon': '🗂️', 'desc': 'مكتبة فتاوى مصنفة حسب الأبواب الفقهية'},
      ],
      'hubBuilder': (BuildContext ctx) => const FatwasHubScreen(),
    },
    {
      'title': 'الرقية الشرعية',
      'icon': '🛡️',
      'subs': [
        {'title': 'جلسات رقية شرعية مباشرة', 'icon': '🔴', 'desc': 'بث حي لجلسات الرقية مع كبار الرقاة الثقات'},
        {'title': 'الراقي د. محمد كمال بو حسين', 'icon': '👨‍⚕️', 'desc': 'حلقات متخصصة وبرامج علاجية بالقرآن والسنة'},
        {'title': 'الراقي د. أحمد عبد المنعم', 'icon': '👨‍⚕️', 'desc': 'إرشادات الرقية والتحصينات النبوية المعتمدة'},
        {'title': 'أذكار الصباح والمساء والتحصين', 'icon': '🤲', 'desc': 'تحصينات يومية صوتية وتوجيهات شرعية'},
      ],
      'hubBuilder': (BuildContext ctx) => const RuqyahHubScreen(),
    },
    {
      'title': 'المسابقات الدينية',
      'icon': '🏆',
      'subs': [
        {'title': 'مسابقات القرآن الكريم أونلاين', 'icon': '💻', 'desc': 'اختبارات إلكترونية تفاعلية بجوائز فورية'},
        {'title': 'مسابقات القرآن الكريم أوفلاين', 'icon': '🕌', 'desc': 'مسابقات حضورية ومحافل سنوية معتمدة'},
        {'title': 'مسابقات السنة النبوية أونلاين', 'icon': '📜', 'desc': 'اختبارات حفظ المتون وشروح الأحاديث'},
        {'title': 'مسابقات السنة النبوية أوفلاين', 'icon': '🏅', 'desc': 'أولمبياد الحديث الشريف الحضوري'},
      ],
      'hubBuilder': (BuildContext ctx) => const CompetitionsExpandedScreen(),
    },
    {
      'title': 'الشهادات والإجازات',
      'icon': '🎖️',
      'subs': [
        {'title': 'إجازات القرآن الكريم المعتمدة', 'icon': '📜', 'desc': 'إسناد متصل مصدق وموثق لكافة القراءات'},
        {'title': 'شهادات الدورات العلمية', 'icon': '🎓', 'desc': 'شهادات اجتياز الدبلومات والمقررات'},
        {'title': 'إجازات السنة النبوية والأسانيد', 'icon': '✒️', 'desc': 'أسانيد سماع وإقراء الصحاح والسنن'},
      ],
      'hubBuilder': (BuildContext ctx) => const CertificatesHubScreen(),
    },
    {
      'title': 'الإذاعات الإسلامية',
      'icon': '📻',
      'subs': [
        {'title': 'إذاعة القرآن الكريم من القاهرة', 'icon': '🇪🇬', 'desc': 'تلاوات نادرة وبرامج التفسير والحديث'},
        {'title': 'إذاعة القرآن الكريم من مكة', 'icon': '🇸🇦', 'desc': 'صلوات وتلاوات الحرمين الشريفين مباشرة'},
        {'title': 'إذاعة القرآن الكريم من الرياض', 'icon': '🇸🇦', 'desc': 'قراءات خاشعة وبرامج تفاسير مستمرة'},
        {'title': 'إذاعات مشاهير القراء (المنشاوي، عبد الباسط، الحصري)', 'icon': '🎙️', 'desc': 'تلاوات متصلة للمصاحف المرتلة والمجودة'},
      ],
      'hubBuilder': (BuildContext ctx) => const RadiosExpandedScreen(),
    },
    {
      'title': 'الطفل المسلم',
      'icon': '👶',
      'subs': [
        {'title': 'قصص الأنبياء للصغار', 'icon': '📖', 'desc': 'قصص تفاعلية مشوقة بأسلوب تربوي مبسط'},
        {'title': 'آداب وأخلاق الطفل المسلم', 'icon': '🌱', 'desc': 'البر، الصدق، الأمانة، وآداب الطعام والمسجد'},
        {'title': 'أحاديث وأذكار الطفل اليومية', 'icon': '⭐', 'desc': 'حفظ الأذكار اليومية بالأناشيد الهادفة'},
      ],
      'hubBuilder': (BuildContext ctx) => const MuslimChildScreen(),
    },
    {
      'title': 'المرأة المسلمة',
      'icon': '🧕',
      'subs': [
        {'title': 'أحكام فقهية خاصة بالمرأة', 'icon': '⚖️', 'desc': 'أحكام الطهارة، الصلاة، الحج، والأسرة وتربية الأبناء'},
        {'title': 'آداب وسير أمهات المؤمنين', 'icon': '🌸', 'desc': 'خديجة، عائشة، والصحابيات القدوة الصالحة'},
        {'title': 'أعمال وبركات البيت المسلم', 'icon': '🏡', 'desc': 'تربية الأبناء، التكافل، والبركة في الرزق'},
      ],
      'hubBuilder': (BuildContext ctx) => const MuslimWomanScreen(),
    },
    {
      'title': 'الأئمة والمؤذنون',
      'icon': '🕌',
      'subs': [
        {'title': 'إمام يبحث عن عمل في الإمامة', 'icon': '📖', 'desc': 'استعراض سير القراء والأئمة للتعيين بالمساجد'},
        {'title': 'مؤذن يبحث عن عمل في الأذان', 'icon': '📢', 'desc': 'ملفات المؤذنين بأصواتهم الندية وتزكياتهم'},
        {'title': 'وظائف وإعلانات المساجد', 'icon': '🏛️', 'desc': 'مساجد ومراكز تطلب أئمة ومؤذنين بالرعاية'},
      ],
      'hubBuilder': (BuildContext ctx) => const ImamsHubScreen(),
    },
    {
      'title': 'المتطوعون في المنصة',
      'icon': '🤝',
      'subs': [
        {'title': 'متطوع في مجال الدعوة والإقراء', 'icon': '🕊️', 'desc': 'تقديم حصص تسميع وتدريس لوجه الله واحتساب الأجر'},
        {'title': 'متطوع في المجال الفني والتقني', 'icon': '💻', 'desc': 'المساهمة في البرمجة، التصميم، والإنتاج التقني'},
        {'title': 'بوابة تسجيل متطوع جديد', 'icon': '📝', 'desc': 'الانضمام لكوادر التطوع الرسمية بمنصة إتقان'},
      ],
      'hubBuilder': (BuildContext ctx) => const VolunteersExpandedScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadLiveClasses();
    UserChaptersService.instance.init();
    UserChaptersService.instance.changeNotifier.addListener(_onChaptersChanged);
  }

  @override
  void dispose() {
    UserChaptersService.instance.changeNotifier.removeListener(_onChaptersChanged);
    super.dispose();
  }

  void _onChaptersChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadLiveClasses() async {
    try {
      final resClass = await _apiClient.getClasses();
      if (resClass.statusCode == 200 && resClass.data != null) {
        final List items = resClass.data['data'] ?? [];
        if (items.isNotEmpty && mounted) {
          setState(() {
            _liveClasses.clear();
            _liveClasses.addAll(items.map((i) => Map<String, dynamic>.from(i)));
          });
        }
      }
    } catch (_) {}
  }

  void _openRoom(String roomTitle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveRecitationRoom(
          roomId: 'room_${DateTime.now().millisecondsSinceEpoch % 10000}',
          circleTitle: roomTitle,
          isSheikh: false,
        ),
      ),
    );
  }

  /// فتح شاشة القسم الفرعي (شاشة حلقات القسم الفرعي الحقيقية أو شاشة الأداة المتخصصة)
  void _openSubSectionHub(Map<String, dynamic> section, String subTitle) {
    final sectionTitle = section['title'] as String;
    final toolSections = {
      'المكتبة الإلكترونية',
      'المسابقات الدينية',
      'الشهادات والإجازات',
      'الإذاعات الإسلامية',
      'الأئمة والمؤذنون',
      'المتطوعون في المنصة',
    };

    if (toolSections.contains(sectionTitle) ||
        subTitle.contains('لوحة الحروف التفاعلية')) {
      final hubBuilder = section['hubBuilder'];
      if (hubBuilder != null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: hubBuilder),
        );
        return;
      }
    }

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => SectionCirclesScreen(
              mainSection: sectionTitle,
              subSection: subTitle,
            ),
          ),
        )
        .then((_) => _loadLiveClasses());
  }

  @override
  Widget build(BuildContext context) {
    final currentSection = _sectionsConfig[_selectedCategoryIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBF4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'الأقسام والحلقات',
          style: TextStyle(
            color: Color(0xFF191919),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Dubai',
          ),
        ),
        centerTitle: false,
        actions: [
          // زر استعراض شاشة كل الأقسام كاملة بدون زر + إضافي هنا لمنع التكرار
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00875A),
                backgroundColor: const Color(0xFFE8F5E9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SectionsHubScreen()),
                );
              },
              icon: const Icon(Icons.grid_view_rounded, size: 16),
              label: const Text(
                'الشبكة الشاملة',
                style: TextStyle(fontFamily: 'Dubai', fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      // زر واحد فقط وأساسي لإنشاء حلقة جديدة (متاح للشيوخ والمشرفين فقط)
      floatingActionButton: (Provider.of<AuthProvider>(context).currentUser?.role ?? UserRole.student) != UserRole.student
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF00875A),
              foregroundColor: Colors.white,
              elevation: 4,
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddChapterScreen()),
                );
                _loadLiveClasses();
              },
              child: const Icon(Icons.add, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Row(
        children: [
          // 1. Right Side: Categories Rail (16 Main Sections)
          Container(
            width: 140,
            decoration: const BoxDecoration(
              color: Color(0xFFF4F4E6),
              border: Border(
                left: BorderSide(color: Color(0xFFE2E2CB), width: 1),
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
              itemCount: _sectionsConfig.length,
              itemBuilder: (context, index) {
                final sec = _sectionsConfig[index];
                final isSelected = _selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00875A) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF00875A) : const Color(0xFFDFDFC6),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00875A).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        sec['title'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF222222),
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontFamily: 'Dubai',
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Left Side: Subcategories in Single Rows (بدون صور وبدون بانر مكرر وبدون كلمة دخول)
          Expanded(
            child: _buildSectionDetails(currentSection),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDetails(Map<String, dynamic> section) {
    final List subs = section['subs'] as List;
    final sectionTitle = section['title'] as String;

    // Filter user created chapters matching this section
    final userChapters = UserChaptersService.instance.ongoingChapters.where((c) {
      return (c['mainCategory'] ?? '') == sectionTitle;
    }).toList();

    // Filter live server classes matching this main section or any of its subsections
    final mainCatId = CategoryMapping.mainCategoryIds[sectionTitle];
    final serverClasses = _liveClasses.where((c) {
      final catObj = c['category'];
      final catName = catObj?['name']?.toString() ?? '';
      final catId = int.tryParse('${c['category_id'] ?? catObj?['id'] ?? ''}');
      final parentId = int.tryParse('${catObj?['parent_id'] ?? ''}');
      if (mainCatId != null && (catId == mainCatId || parentId == mainCatId)) {
        return true;
      }
      if (subs.any((s) => CategoryMapping.matchesClass(
            c,
            mainSection: sectionTitle,
            subSection: (s as Map<String, dynamic>)['title'] as String,
          ))) {
        return true;
      }
      return catName == sectionTitle || catName.contains(sectionTitle);
    }).toList();

    return RefreshIndicator(
      color: const Color(0xFF00875A),
      onRefresh: _loadLiveClasses,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        children: [
          // الحلقات المباشرة والمنشأة على السيرفر (تظهر للطلاب وجميع المستخدمين)
          if (serverClasses.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.live_tv_rounded, color: Color(0xFF00875A), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'الحلقات المتاحة في هذا القسم (${serverClasses.length})',
                    style: const TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00875A),
                    ),
                  ),
                ],
              ),
            ),
            ...serverClasses.map((cls) {
              final title = cls['name']?.toString() ?? 'حلقة تلاوة';
              final sheikhObj = cls['sheikh'] ?? cls['creator']?['user'] ?? cls['creator'];
              final rawSheikh = sheikhObj?['name']?.toString() ?? '';
              final sheikhName = (rawSheikh.isNotEmpty && !rawSheikh.contains('???')) ? rawSheikh : 'الشيخ المقرئ';
              final studentsCount = int.tryParse('${cls['students_count'] ?? 0}') ?? 0;
              final capacity = int.tryParse('${cls['capacity'] ?? cls['max_students'] ?? 30}') ?? 30;
              final startsAt = cls['starts_at']?.toString() ?? '';
              final classId = cls['id'] is int ? cls['id'] as int : int.tryParse('${cls['id']}');
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LiveRecitationRoom(
                        roomId: 'room_srv_${cls['id']}',
                        circleTitle: title,
                        isSheikh: (Provider.of<AuthProvider>(context, listen: false).currentUser?.role ?? UserRole.student) != UserRole.student,
                        classRoomId: classId,
                        sheikhName: sheikhName,
                        subscribersCount: studentsCount,
                        capacity: capacity,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00875A), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00875A),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontFamily: 'Dubai',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF1E2822),
                              ),
                            ),
                            Text(
                              'الشيخ: $sheikhName • المشاركون: $studentsCount${startsAt.isNotEmpty ? ' • $startsAt' : ''}',
                              style: TextStyle(
                                fontFamily: 'Dubai',
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF00875A), size: 14),
                    ],
                  ),
                ),
              );
            }),
            const Divider(height: 20),
          ],
        // إذا كان هناك حلقات منشأة من قبل المستخدم في هذا القسم تظهر كبطاقات مباشرة
        if (userChapters.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: Color(0xFF00875A), size: 16),
                const SizedBox(width: 4),
                Text(
                  'حلقاتك النشطة في هذا القسم (${userChapters.length})',
                  style: const TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00875A),
                  ),
                ),
              ],
            ),
          ),
          ...userChapters.map((ch) {
            return GestureDetector(
              onTap: () => _openRoom(ch['title']),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00875A), width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00875A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ch['title'],
                            style: const TextStyle(
                              fontFamily: 'Dubai',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF1E2822),
                            ),
                          ),
                          Text(
                            'المشرف: ${ch['supervisor']} • المشتركون: ${ch['subscribers']}',
                            style: TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF00875A), size: 14),
                  ],
                ),
              ),
            );
          }),
          const Divider(height: 20),
        ],

        // قائمة الفروع الفرعية (كل قسم فرعي في صف كامل لوحده بدون صور وبدون كلمة دخول)
        ...subs.map((sub) {
          final subMap = sub as Map<String, dynamic>;
          final subTitle = subMap['title'] as String;
          final subIcon = subMap['icon'] as String;
          final subDesc = subMap['desc'] as String;

          return GestureDetector(
            onTap: () => _openSubSectionHub(section, subTitle),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E8DC)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // عنوان القسم الفرعي ووصفه في صف مستقل بكامل العرض وبدون أي صور أو أيقونات مشتتة
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subTitle,
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF1E2822),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subDesc,
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // سهم التنقل الأنيق بدلاً من زر الدخول
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF00875A),
                    size: 14,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
      ),
    );
  }
}
