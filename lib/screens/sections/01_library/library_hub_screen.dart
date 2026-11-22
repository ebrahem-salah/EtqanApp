import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../library/book_reader_screen.dart';

class LibraryHubScreen extends StatefulWidget {
  final String? initialCategory;
  const LibraryHubScreen({super.key, this.initialCategory});

  @override
  State<LibraryHubScreen> createState() => _LibraryHubScreenState();
}

class _LibraryHubScreenState extends State<LibraryHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _tabs = [
    'قسم المصاحف',
    'كتب التفسير',
    'كتب الحديث',
    'التجويد',
    'علوم أخرى',
  ];

  final List<Map<String, dynamic>> _books = [
    // قسم المصاحف
    {
      'id': 101,
      'title': 'مصحف المدينة النبوية (برواية حفص)',
      'author': 'مجمع الملك فهد لطباعة المصحف الشريف',
      'category': 'قسم المصاحف',
      'pages': 604,
      'color': const Color(0xFF00875A),
      'icon': '📖',
      'sampleChapter': 'سورة الفاتحة والبقرة',
      'sampleText': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ (1) الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ (2) الرَّحْمَٰنِ الرَّحِيمِ (3) مَالِكِ يَوْمِ الدِّينِ (4) إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ (5) اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ (6) صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ (7)',
    },
    {
      'id': 102,
      'title': 'مصحف التجويد الملون مع أحكام التلاوة',
      'author': 'دار المعرفة - دمشق',
      'category': 'قسم المصاحف',
      'pages': 604,
      'color': const Color(0xFF1E88E5),
      'icon': '📖',
      'sampleChapter': 'مقدمة أحكام الترميز اللوني',
      'sampleText': 'الأحمر للغنن والمدود اللازمة، الأخضر للمدود الجائزة، الأزرق للقلقلة، والرمادي للحروف التي لا تلفظ.',
    },
    {
      'id': 103,
      'title': 'مصحف القراءات العشر المتواترة',
      'author': 'هيئة كبار المقرئين بالأزهر الشريف',
      'category': 'قسم المصاحف',
      'pages': 620,
      'color': const Color(0xFF8E24AA),
      'icon': '📖',
      'sampleChapter': 'أصول القراء العشرة ورواتهم',
      'sampleText': 'قراءة نافع، ابن كثير، أبو عمرو، ابن عامر، عاصم، حمزة، الكسائي، أبو جعفر، يعقوب، وخلف العاشر.',
    },

    // كتب التفسير
    {
      'id': 201,
      'title': 'تفسير القرآن العظيم (تفسير ابن كثير)',
      'author': 'الحافظ عماد الدين إسماعيل بن كثير',
      'category': 'كتب التفسير',
      'pages': 2100,
      'color': const Color(0xFFD4AF37),
      'icon': '📜',
      'sampleChapter': 'تفسير سورة الإخلاص',
      'sampleText': '«قُلْ هُوَ اللَّهُ أَحَدٌ» أَيْ: هُوَ الْوَاحِدُ الأَحَدُ الَّذِي لَا نَظِيرَ لَهُ، وَلَا وَزِيرَ، وَلَا نِدَّ لَهُ، وَلَا شَبِيهَ، وَلَا كُفْءَ، وَلَا يُطْلَقُ هَذَا اللَّفْظُ عَلَى أَحَدٍ فِي الإِثْبَاتِ إِلا عَلَى اللَّهِ عَزَّ وَجَلَّ.',
    },
    {
      'id': 202,
      'title': 'تيسير الكريم الرحمن في تفسير كلام المنان',
      'author': 'الشيخ عبد الرحمن بن ناصر السعدي',
      'category': 'كتب التفسير',
      'pages': 1050,
      'color': const Color(0xFF2E7D32),
      'icon': '📜',
      'sampleChapter': 'سورة يوسف - آيات العبرة والتمكين',
      'sampleText': 'هذه القصة من أحسن القصص لاشتمالها على التنقل من حال إلى حال، ومن محنة إلى منحة، ومن ذل إلى عز.',
    },
    {
      'id': 203,
      'title': 'التفسير الميسر',
      'author': 'نخبة من أساتذة التفسير بمجمع الملك فهد',
      'category': 'كتب التفسير',
      'pages': 604,
      'color': const Color(0xFF00796B),
      'icon': '📜',
      'sampleChapter': 'تفسير سورة الكهف',
      'sampleText': 'بيان أسباب النزول ودلالات قصة أصحاب الكهف وموسى مع الخضر وذي القرنين بأسلوب موجز وسهل.',
    },

    // كتب الحديث
    {
      'id': 301,
      'title': 'صحيح البخاري (الجامع المسند الصحيح)',
      'author': 'الإمام محمد بن إسماعيل البخاري',
      'category': 'كتب الحديث',
      'pages': 1800,
      'color': const Color(0xFF00875A),
      'icon': '📚',
      'sampleChapter': 'كتاب بدء الوحي',
      'sampleText': 'عَنْ عُمَرَ بْنِ الْخَطَّابِ رَضِيَ اللَّهُ عَنْهُ قَالَ: سَمِعْتُ رَسُولَ اللَّهِ ﷺ يَقُولُ:\n«إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى».',
    },
    {
      'id': 302,
      'title': 'صحيح مسلم (المسند الصحيح المختصر)',
      'author': 'الإمام مسلم بن الحجاج النيسابوري',
      'category': 'كتب الحديث',
      'pages': 1650,
      'color': const Color(0xFF1565C0),
      'icon': '📚',
      'sampleChapter': 'كتاب الإيمان - حديث جبريل',
      'sampleText': '«الإِسْلامُ أَنْ تَشْهَدَ أَنْ لا إِلَهَ إِلا اللَّهُ وَأَنَّ مُحَمَّدًا رَسُولُ اللَّهِ، وَتُقِيمَ الصَّلاةَ، وَتُؤْتِيَ الزَّكَاةَ، وَتَصُومَ رَمَضَانَ، وَتَحُجَّ الْبَيْتَ إِنِ اسْتَطَعْتَ إِلَيْهِ سَبِيلاً».',
    },
    {
      'id': 303,
      'title': 'رياض الصالحين من كلام سيد المرسلين',
      'author': 'الإمام يحيى بن شرف النووي',
      'category': 'كتب الحديث',
      'pages': 720,
      'color': const Color(0xFFD84315),
      'icon': '📚',
      'sampleChapter': 'باب الإخلاص وإحضار النية',
      'sampleText': 'عن أبي هريرة رضي الله عنه قال: قال رسول الله ﷺ: «إن الله لا ينظر إلى أجسادكم ولا إلى صوركم ولكن ينظر إلى قلوبكم وأعمالكم».',
    },

    // التجويد
    {
      'id': 401,
      'title': 'متن تحفة الأطفال والغلمان في تجويد القرآن',
      'author': 'الشيخ سليمان الجمزوري',
      'category': 'التجويد',
      'pages': 48,
      'color': const Color(0xFF6A1B9A),
      'icon': '🎵',
      'sampleChapter': 'أحكام النون الساكنة والتنوين',
      'sampleText': 'لِلنُّونِ إِنْ تَسْكُنْ وَلِلتَّنْوِينِ\nأَرْبَعُ أَحْكَامٍ فَخُذْ تَبْيِينِي\nفَالأَوَّلُ الإِظْهَارُ قَبْلَ أَحْرُفِ\nلِلْحَلْقِ سِتٌّ رُتِّبَتْ فَلْتَعْرِفِ',
    },
    {
      'id': 402,
      'title': 'المقدمة الجزرية في علم التجويد',
      'author': 'الإمام شمس الدين محمد بن الجزري',
      'category': 'التجويد',
      'pages': 64,
      'color': const Color(0xFF303F9F),
      'icon': '🎵',
      'sampleChapter': 'باب مخارج الحروف',
      'sampleText': 'مَخَارِجُ الحُرُوفِ سَبْعَةَ عَشَرْ\nعَلَى الَّذِي يَخْتَارُهُ مَنِ اخْتَبَرْ\nفَلِلْفَمِ أَلِفٌ وَأُخْتَاهَا وَهِي\nحُرُوفُ مَدٍّ لِلْهَوَاءِ تَنْتَهِي',
    },
    {
      'id': 403,
      'title': 'غاية المريد في علم التجويد',
      'author': 'الشيخ عطية قابل نصر',
      'category': 'التجويد',
      'pages': 310,
      'color': const Color(0xFF00695C),
      'icon': '🎵',
      'sampleChapter': 'أحكام الوقف والابتداء والروم والإشمام',
      'sampleText': 'دراسة تطبيقية مفصلة مع الأمثلة الصوتية والرسوم التوضيحية لمخارج الحروف وصفاتها.',
    },

    // علوم أخرى
    {
      'id': 501,
      'title': 'الرحيق المختوم (بحث في السيرة النبوية)',
      'author': 'صفي الرحمن المباركفوري',
      'category': 'علوم أخرى',
      'pages': 520,
      'color': const Color(0xFFC2185B),
      'icon': '🌟',
      'sampleChapter': 'الهجرة النبوية الشريفة إلى المدينة',
      'sampleText': 'خطة الهجرة وتضحية علي بن أبي طالب والصحبة المباركة مع أبي بكر الصديق في غار ثور.',
    },
    {
      'id': 502,
      'title': 'مباحث في علوم القرآن',
      'author': 'الشيخ مناع القطان',
      'category': 'علوم أخرى',
      'pages': 440,
      'color': const Color(0xFF4527A0),
      'icon': '🌟',
      'sampleChapter': 'نزول القرآن الكريم وأسباب النزول والمكي والمدني',
      'sampleText': 'مفهوم الوحي وأنواعه، وجمع القرآن في عهد أبي بكر وعثمان رضي الله عنهما.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    if (widget.initialCategory != null) {
      final idx = _tabs.indexOf(widget.initialCategory!);
      if (idx != -1) _tabController.index = idx;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'المكتبة الإلكترونية',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'ابحث في المصاحف، كتب التفسير، الحديث، التجويد...',
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
          ),

          // Tabs Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((category) {
                final filtered = _books.where((b) {
                  final matchCat = b['category'] == category;
                  if (_searchQuery.isEmpty) return matchCat;
                  final matchQuery = b['title'].toString().contains(_searchQuery) ||
                      b['author'].toString().contains(_searchQuery);
                  return matchCat && matchQuery;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text(
                          'لا توجد نتائج في $category',
                          style: TextStyle(fontFamily: 'Dubai', fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final book = filtered[index];
                    return _buildBookCard(book);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    final Color color = book['color'] as Color;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BookReaderScreen(book: book),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Book Icon Badge
                Container(
                  width: 58,
                  height: 76,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      book['icon'] ?? '📖',
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Book Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book['title'],
                        style: const TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191919),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book['author'],
                        style: TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${book['pages']} صفحة',
                              style: TextStyle(
                                fontFamily: 'Dubai',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'قراءة وتصفح',
                            style: TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00875A),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF00875A)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
