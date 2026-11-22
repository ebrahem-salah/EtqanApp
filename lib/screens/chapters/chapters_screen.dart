import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../call/live_recitation_room.dart';
import '../sections/sections_hub_screen.dart';
import '../sections/dialogs/create_section_session_dialog.dart';
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

class ChaptersScreen extends StatefulWidget {
  const ChaptersScreen({super.key});

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  int _selectedCategoryIndex = 2; // Default to Holy Quran (القرآن الكريم)
  final ApiClient _apiClient = ApiClient();
  final List<Map<String, dynamic>> _liveClasses = [];

  // الأقسام الـ 16 الرئيسية والفرعية الشاملة للتطبيق
  final List<Map<String, dynamic>> _sectionsConfig = [
    {
      'title': 'المكتبة الإلكترونية',
      'icon': '📚',
      'badge': 'أولاً',
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
      'badge': 'ثانياً',
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
      'badge': 'ثالثاً',
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
        {'title': 'القراءة بالإسناد المتصل', 'icon': '🏅', 'desc': 'ختمات الإجازة بالسند المتصل إلى النبي ﷺ'},
      ],
      'hubBuilder': (BuildContext ctx) => const QuranHubScreen(),
    },
    {
      'title': 'مقرأة إهداء الثواب',
      'icon': '🤲',
      'badge': 'رابعاً',
      'subs': [
        {'title': 'ختمات إهداء الثواب للمتوفين', 'icon': '🕊️', 'desc': 'تلاوة وإهداء ثوابها لأموات المسلمين'},
        {'title': 'ختمات الشفاء للمرضى', 'icon': '🌿', 'desc': 'رقية ودعاء بنية الشفاء والعافية'},
        {'title': 'إهداء الثواب للوالدين', 'icon': '❤️', 'desc': 'بر الوالدين حيين وميتين ونيل رضاهما'},
        {'title': 'المقارئ المباشرة للختمات (30 جزء)', 'icon': '🕋', 'desc': 'توزيع الأجزاء وحجز الحصص في الختمة'},
      ],
      'hubBuilder': (BuildContext ctx) => const IhdaaThawabScreen(),
    },
    {
      'title': 'السنة النبوية',
      'icon': '📜',
      'badge': 'خامساً',
      'subs': [
        {'title': 'الحفظ (الصغار)', 'icon': '🧒', 'desc': 'الأربعون النووية وقصار الأحاديث النبوية'},
        {'title': 'الحفظ (الكبار)', 'icon': '📚', 'desc': 'عمدة الأحكام وبلوغ المرام ورياض الصالحين'},
        {'title': 'علوم الحديث ومصطلحه', 'icon': '🔍', 'desc': 'الجرح والتعديل وتخريج الأحاديث وبيان درجتها'},
        {'title': 'شروح الأحاديث النبوية', 'icon': '📖', 'desc': 'فتح الباري وشرح النووي على صحيح مسلم'},
        {'title': 'الإقراء لكتب السنة', 'icon': '🎙️', 'desc': 'قراءة وسماع الكتب التسعة والمصنفات'},
        {'title': 'القراءة بالإسناد المتصل', 'icon': '📜', 'desc': 'رواية الحديث بالسند المتصل إلى رسول الله ﷺ'},
      ],
      'hubBuilder': (BuildContext ctx) => const SunnahHubScreen(),
    },
    {
      'title': 'الدورات العلمية',
      'icon': '🎓',
      'badge': 'سادساً',
      'subs': [
        {'title': 'الدورات العلمية العامة', 'icon': '🌐', 'desc': 'دورات مجانية مفتوحة لعموم المسلمين في العلوم الشرعية'},
        {'title': 'الدورات العلمية الخاصة', 'icon': '🔒', 'desc': 'دورات متقدمة وشهادات تخصصية وإجازات مكثفة'},
      ],
      'hubBuilder': (BuildContext ctx) => const CoursesHubScreen(),
    },
    {
      'title': 'علوم أخرى',
      'icon': '🌟',
      'badge': 'سابعاً',
      'subs': [
        {'title': 'علم الفقه الإسلامي', 'icon': '⚖️', 'desc': 'العبادات، المعاملات، وفقه النوازل المعاصرة'},
        {'title': 'السيرة النبوية والتاريخ', 'icon': '🕌', 'desc': 'سيرة الحبيب المصطفى ﷺ وخلفائه الراشدين'},
        {'title': 'العقيدة الإسلامية', 'icon': '🛡️', 'desc': 'أصول الإيمان والتوحيد الخالص ودفع الشبهات'},
        {'title': 'الرقائق وأعمال القلوب', 'icon': '💧', 'desc': 'تزكية النفس، الإخلاص، ومحاسبة الذات'},
      ],
      'hubBuilder': (BuildContext ctx) => const OtherSciencesScreen(),
    },
    {
      'title': 'الفتاوى الشرعية',
      'icon': '🕌',
      'badge': 'ثامناً',
      'subs': [
        {'title': 'فتاوى دار الإفتاء الإلكترونية', 'icon': '🏛️', 'desc': 'فتاوى معتمدة وموثقة من كبار العلماء والمجامع'},
        {'title': 'فتاوى واستشارات مباشرة', 'icon': '🔴', 'desc': 'تواصل حي ومباشر مع المشايخ والمفتين'},
        {'title': 'فتاوى مؤرشفة ومصنفة', 'icon': '📁', 'desc': 'محرك بحث متقدم في آلاف الفتاوى الشرعية الموثوقة'},
      ],
      'hubBuilder': (BuildContext ctx) => const FatwasHubScreen(),
    },
    {
      'title': 'الرقية الشرعية',
      'icon': '🌿',
      'badge': 'تاسعاً',
      'subs': [
        {'title': 'جلسات الرقية المباشرة', 'icon': '🔴', 'desc': 'رقية حية مباشرة مع الرقاة المعتمدين والمشايخ'},
        {'title': 'الراقي د. محمد كمال بو حسين', 'icon': '👨‍⚕️', 'desc': 'حجز استشارة خاصة ورقية موجهة ومتابعة للحالات'},
        {'title': 'الراقي د. أحمد عبد المنعم', 'icon': '🎙️', 'desc': 'صوتيات رقية شرعية وبرامج علاجية وقائية'},
      ],
      'hubBuilder': (BuildContext ctx) => const RuqyahHubScreen(),
    },
    {
      'title': 'المسابقات الدينية',
      'icon': '🏆',
      'badge': 'عاشراً',
      'subs': [
        {'title': 'مسابقات أونلاين تفاعلية', 'icon': '⚡', 'desc': 'اختبارات لحظية، لوحة متصدرين، وجوائز قيمة'},
        {'title': 'مسابقات أوفلاين وحضورية', 'icon': '📍', 'desc': 'مواعيد وتفاصيل المسابقات بالمساجد والمراكز'},
        {'title': 'مسابقات القرآن الكريم', 'icon': '📖', 'desc': 'مسابقات الحفظ والتلاوة والصوت الحسن'},
        {'title': 'مسابقات السنة النبوية', 'icon': '📜', 'desc': 'مسابقات حفظ المتون والأحاديث الشريفة'},
      ],
      'hubBuilder': (BuildContext ctx) => const CompetitionsExpandedScreen(),
    },
    {
      'title': 'الشهادات والإجازات العلمية',
      'icon': '🎖️',
      'badge': 'الحادي عشر',
      'subs': [
        {'title': 'سجل الإجازات بالسند المتصل', 'icon': '📜', 'desc': 'إجازات معتمدة متصلة السند بالرسول ﷺ مع QR'},
        {'title': 'شهادات اجتياز الدورات', 'icon': '🎓', 'desc': 'شهادات رسمية بالدرجة والتقدير قابلة للتحميل'},
        {'title': 'التحقق الرقمي من الإجازة', 'icon': '✅', 'desc': 'فحص رمز QR ومطابقة السجل الرقمي الموثق'},
      ],
      'hubBuilder': (BuildContext ctx) => const CertificatesHubScreen(),
    },
    {
      'title': 'الإذاعات الإسلامية',
      'icon': '📻',
      'badge': 'الثاني عشر',
      'subs': [
        {'title': 'إذاعة القرآن الكريم - القاهرة', 'icon': '🎙️', 'desc': 'بث مباشر عالي الجودة 24/7 دون انقطاع'},
        {'title': 'إذاعة القرآن الكريم - مكة المكرمة', 'icon': '🕋', 'desc': 'تلاوات الحرم المكي الشريف والصلوات'},
        {'title': 'إذاعة القرآن الكريم - الرياض', 'icon': '🇸🇦', 'desc': 'برامج إذاعية وتلاوات خاشعة لكبار القراء'},
        {'title': 'إذاعة القرآن الكريم - الشارقة', 'icon': '🇦🇪', 'desc': 'إذاعة الشارقة العطرة للقرآن الكريم'},
        {'title': 'إذاعة كبار القراء المتواصلة', 'icon': '🎧', 'desc': 'عبد الباسط، المنشاوي، الحصري، ومصطفى إسماعيل'},
      ],
      'hubBuilder': (BuildContext ctx) => const RadiosExpandedScreen(),
    },
    {
      'title': 'الطفل المسلم',
      'icon': '🧒',
      'badge': 'الثالث عشر',
      'subs': [
        {'title': 'قصص الأنبياء والصالحين', 'icon': '📖', 'desc': 'قصص مرسومة ومروية بأسلوب مشوق للأطفال'},
        {'title': 'الآداب والأخلاق الإسلامية', 'icon': '🌱', 'desc': 'آداب الطعام، بر الوالدين، السلام، والصدق'},
        {'title': 'أحاديث وأذكار الصغار', 'icon': '⭐', 'desc': 'أذكار الصباح والمساء واليوم والليلة مبسطة'},
      ],
      'hubBuilder': (BuildContext ctx) => const MuslimChildScreen(),
    },
    {
      'title': 'المرأة المسلمة',
      'icon': '🧕',
      'badge': 'الرابع عشر',
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
      'badge': 'الخامس عشر',
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
      'badge': 'السادس عشر',
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

  @override
  Widget build(BuildContext context) {
    final currentSection = _sectionsConfig[_selectedCategoryIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBF4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.8,
        title: const Text(
          'الأقسام والحلقات (16 قسماً)',
          style: TextStyle(
            color: Color(0xFF191919),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Dubai',
          ),
        ),
        centerTitle: false,
        actions: [
          // زر استعراض شبكة الأقسام الـ 16 كاملة
          TextButton.icon(
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
              'شبكة الأقسام ▦',
              style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0E0D0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Color(0xFF00875A), size: 22),
            ),
            onPressed: () {
              CreateSectionSessionDialog.show(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
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
            child: Column(
              children: [
                Expanded(
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
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
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
                          child: Row(
                            children: [
                              Text(sec['icon'], style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  sec['title'],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : const Color(0xFF333333),
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontFamily: 'Dubai',
                                    height: 1.25,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Floating Action Button (+) Create Circle
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTap: () {
                      CreateSectionSessionDialog.show(context);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00875A),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00875A).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Left Side: Subcategories & Live Classes for Selected Section
          Expanded(
            child: _buildSectionDetails(currentSection),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDetails(Map<String, dynamic> section) {
    final List subs = section['subs'] as List;

    // Header banner for live classes from Backend API
    Widget? liveHeader;
    if (_liveClasses.isNotEmpty) {
      final firstLive = _liveClasses.first;
      final sheikhName = firstLive['sheikh']?['name'] ?? firstLive['creator']?['name'] ?? 'الشيخ عبد الله الرويلي';
      final circleName = firstLive['name'] ?? 'مقرأة إتقان لتصحيح التلاوة وتدبر سورة البقرة';
      final isOngoing = firstLive['status'] == 'ongoing' || firstLive['is_ongoing'] == true;

      liveHeader = Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isOngoing ? Border.all(color: const Color(0xFFE53935).withOpacity(0.5), width: 1.5) : null,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: Colors.white, size: 6),
                      SizedBox(width: 4),
                      Text('🔴 مباشر الآن', style: TextStyle(fontFamily: 'Dubai', fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Text('الشيخ: $sheikhName', style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00875A))),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              circleName,
              style: const TextStyle(fontFamily: 'Dubai', fontSize: 13, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _openRoom(circleName),
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                label: const Text('دخول المقرأة المباشرة الآن', style: TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (liveHeader != null) liveHeader,

        // Top Section Hero Card
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F5B46), Color(0xFF00875A)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00875A).withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      section['badge'],
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Dubai'),
                    ),
                  ),
                  Text(section['icon'], style: const TextStyle(fontSize: 24)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                section['title'],
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Dubai'),
              ),
              const SizedBox(height: 4),
              Text(
                'يحتوي على ${subs.length} فروع ومسارات متخصصة',
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, fontFamily: 'Dubai'),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  final builder = section['hubBuilder'] as Widget Function(BuildContext);
                  Navigator.of(context).push(MaterialPageRoute(builder: (c) => builder(c)));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'فتح شاشة القسم المتخصصة بالتفصيل',
                        style: TextStyle(color: Color(0xFF00875A), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Dubai'),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF00875A), size: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Subcategories List with Direct Entry
        ...subs.map((sub) {
          final subMap = sub as Map<String, dynamic>;
          final subTitle = subMap['title'] as String;
          final subIcon = subMap['icon'] as String;
          final subDesc = subMap['desc'] as String;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E5D5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Circular Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(subIcon, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),

                // Title & Description
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
                const SizedBox(width: 8),

                // Action: Start / Enter Live Room
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00875A),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: const Size(60, 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    _openRoom('حلقة: ${section['title']} - $subTitle');
                  },
                  child: const Text(
                    'دخول',
                    style: TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
