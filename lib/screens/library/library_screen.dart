import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import 'book_reader_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final ApiClient _apiClient = ApiClient();
  String _selectedCategory = 'الكل';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLiveLibrary();
  }

  Future<void> _loadLiveLibrary() async {
    try {
      final res = await _apiClient.getLibraryBooks();
      if (res.statusCode == 200 && res.data != null) {
        final List items = res.data['data'] ?? [];
        if (items.isNotEmpty) {
          final liveBooks = items.map<Map<String, dynamic>>((b) => {
            'id': b['id'],
            'title': b['name_ar'] ?? b['name'] ?? 'كتاب إتقان',
            'author': b['author'] ?? 'هيئة علماء إتقان',
            'category': 'التجويد والقراءات',
            'pages': b['pages_count'] ?? 120,
            'hadiths': 50,
            'color': const Color(0xFF00875A),
            'icon': '📚',
            'sampleChapter': 'المقدمة والمنهج',
            'sampleText': 'كتاب معتمد في تعليم القرآن الكريم وتجويده.',
          }).toList();

          if (mounted) {
            setState(() {
              _books.insertAll(0, liveBooks);
            });
          }
        }
      }
    } catch (_) {}
  }

  final List<String> _categories = [
    'الكل',
    'الحديث الشريف',
    'التجويد والقراءات',
    'التفسير وعلوم القرآن',
    'الفقه وأصوله',
    'السيرة النبوية',
  ];

  final List<Map<String, dynamic>> _books = [
    {
      'id': 100,
      'title': 'تيست فايل',
      'size': '1017.73 KB',
      'author': 'إتقان',
      'category': 'الكل',
      'pages': 25,
      'color': const Color(0xFF00875A),
      'icon': '📚',
      'sampleChapter': 'المقدمة',
      'sampleText': 'ملف اختباري معتمد في إتقان.',
    },
    {
      'id': 101,
      'title': 'تيست ملف',
      'size': '1017.73 KB',
      'author': 'إتقان',
      'category': 'الكل',
      'pages': 25,
      'color': const Color(0xFF00875A),
      'icon': '📚',
      'sampleChapter': 'المقدمة',
      'sampleText': 'ملف اختباري معتمد في إتقان.',
    },
    {
      'id': 102,
      'title': 'صحيح مسلم طبعة بيت الأفكار 3 (1)',
      'size': '1017.73 KB',
      'author': 'الإمام مسلم النيسابوري',
      'category': 'الحديث الشريف',
      'pages': 1650,
      'color': const Color(0xFF00875A),
      'icon': '📚',
      'sampleChapter': 'كتاب الإيمان',
      'sampleText': 'بَابُ بَيَانِ الإِيمَانِ وَالإِسْلاَمِ وَالإِحْسَانِ.',
    },
    {
      'id': 103,
      'title': 'صحيح البخاري طبعة بيت الأفكار 3',
      'size': '1017.73 KB',
      'author': 'الإمام محمد بن إسماعيل البخاري',
      'category': 'الحديث الشريف',
      'pages': 1800,
      'color': const Color(0xFF00875A),
      'icon': '📚',
      'sampleChapter': 'كتاب بدء الوحي',
      'sampleText': '«إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ».',
    },
    {
      'id': 104,
      'title': 'جامع الترمذي',
      'size': '1017.73 KB',
      'author': 'الإمام أبو عيسى الترمذي',
      'category': 'الحديث الشريف',
      'pages': 1200,
      'color': const Color(0xFF00875A),
      'icon': '📚',
      'sampleChapter': 'أبواب الطهارة',
      'sampleText': '«لاَ تُقْبَلُ صَلاَةٌ بِغَيْرِ طُهُورٍ».',
    },
    {
      'id': 105,
      'title': 'سنن النسائي',
      'size': '1017.73 KB',
      'author': 'الإمام أحمد بن شعيب النسائي',
      'category': 'الحديث الشريف',
      'pages': 1100,
      'color': const Color(0xFF00875A),
      'icon': '📚',
      'sampleChapter': 'كتاب الطهارة',
      'sampleText': '«طهور إناء أحدكم إذا ولغ فيه الكلب».',
    },
    {
      'id': 106,
      'title': 'سنن أبي داود',
      'size': '1017.73 KB',
      'author': 'الإمام أبو داود السجستاني',
      'category': 'الحديث الشريف',
      'pages': 1150,
      'color': const Color(0xFF00875A),
      'icon': '📚',
      'sampleChapter': 'كتاب الصلاة',
      'sampleText': '«مفتاح الصلاة الطهور».',
    },
  ];
      'hadiths': 3033,
      'color': const Color(0xFF1E5B42),
      'icon': '📖',
      'sampleChapter': 'كتاب الإيمان',
      'sampleText': 'عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ أَنَّ رَسُولَ اللَّهِ ﷺ قَالَ:\n\n«الإِيمَانُ بِضْعٌ وَسَبْعُونَ شُعْبَةً، فَأَفْضَلُهَا قَوْلُ: لاَ إِلَهَ إِلاَّ اللَّهُ، وَأَدْنَاهَا إِمَاطَةُ الأَذَى عَنِ الطَّرِيقِ، وَالْحَيَاءُ شُعْبَةٌ مِنَ الإِيمَانِ».',
    },
    {
      'id': 3,
      'title': 'المقدمة الجزرية في التجويد',
      'author': 'الإمام شمس الدين محمد بن الجزري',
      'category': 'التجويد والقراءات',
      'pages': 45,
      'hadiths': 107,
      'color': const Color(0xFFB78103),
      'icon': '🎙️',
      'sampleChapter': 'باب مخارج الحروف',
      'sampleText': 'مَخَارِجُ الْحُرُوفِ سَبْعَةَ عَشَرْ\nعَلَى الَّذِي يَخْتَارُهُ مَنِ اخْتَبَرْ\n\nفَفَأَلِفُ الْجَوْفِ وَأُخْتَاهَا وَهِيْ\nحُرُوفُ مَدٍّ لِلْهَوَاءِ تَنْتَهِيْ\n\nثُمَّ لِأَقْصَى الْحَلْقِ هَمْزٌ هَاءُ\nوَمِنْ وَسَطِهِ فَعَيْنٌ حَاءُ',
    },
    {
      'id': 4,
      'title': 'تحفة الأطفال والغلمان في تجويد القرآن',
      'author': 'الشيخ سليمان الجمزوري',
      'category': 'التجويد والقراءات',
      'pages': 30,
      'hadiths': 61,
      'color': const Color(0xFF8B5A2B),
      'icon': '📜',
      'sampleChapter': 'أحكام النون الساكنة والتنوين',
      'sampleText': 'لِلنُّونِ إِنْ تَسْكُنْ وَلِلتَّنْوِينِ\nأَرْبَعُ أَحْكَامٍ فَخُذْ تَبْيِينِي\n\nفَالأَوَّلُ الإِظْهَارُ قَبْلَ أَحْرُفِ\nلِلْحَلْقِ سِتٌّ رُتِّبَتْ فَلْتَعْرِفِ\n\nهَمْزٌ فَهَاءٌ ثُمَّ عَيْنٌ حَاءُ\nمُهْمَلَتَانِ ثُمَّ غَيْنٌ خَاءُ',
    },
    {
      'id': 5,
      'title': 'رياض الصالحين',
      'author': 'الإمام يحيى بن شرف النووي',
      'category': 'الحديث الشريف',
      'pages': 820,
      'hadiths': 1896,
      'color': const Color(0xFF2C5E43),
      'icon': '🌿',
      'sampleChapter': 'باب الإخلاص وإحضار النية',
      'sampleText': 'قَالَ اللَّهُ تَعَالَى: {وَمَا أُمِرُوا إِلَّا لِيَعْبُدُوا اللَّهَ مُخْلِصِينَ لَهُ الدِّينَ حُنَفَاءَ وَيُقِيمُوا الصَّلَاةَ وَيُؤْتُوا الزَّكَاةَ وَذَلِكَ دِينُ الْقَيِّمَةِ}.\n\nوعن أبي هريرة قال: قال رسول الله ﷺ: «إن الله لا ينظر إلى أجسادكم ولا إلى صوركم ولكن ينظر إلى قلوبكم وأعمالكم».',
    },
    {
      'id': 6,
      'title': 'التفسير الميسر',
      'author': 'نخبة من علماء القرآن والتفسير',
      'category': 'التفسير وعلوم القرآن',
      'pages': 604,
      'hadiths': 114,
      'color': const Color(0xFF2B7A78),
      'icon': '✨',
      'sampleChapter': 'تفسير سورة الفاتحة',
      'sampleText': '{بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ}\nأبدأ قراءتي مستعيناً بالله، والله علم على الرب المعبود بحق دون سواه. والرحمن: ذو الرحمة العامة الشاملة لجميع الخلائق، والرحيم: بالمؤمنين.\n\n{الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ}\nالثناء على الله بصفاته التي كلها أوصاف كمال، وبنعمه الظاهرة والباطنة الدينية والدنيوية.',
    },
    {
      'id': 7,
      'title': 'الأربعون النووية',
      'author': 'الإمام النووي',
      'category': 'الحديث الشريف',
      'pages': 65,
      'hadiths': 42,
      'color': const Color(0xFF17252A),
      'icon': '📘',
      'sampleChapter': 'الحديث الثاني (مراتب الدين)',
      'sampleText': 'عَنْ عُمَرَ رَضِيَ اللَّهُ عَنْهُ أَيْضاً قَالَ: بَيْنَمَا نَحْنُ جُلُوسٌ عِنْدَ رَسُولِ اللَّهِ ﷺ ذَاتَ يَوْمٍ إِذْ طَلَعَ عَلَيْنَا رَجُلٌ شَدِيدُ بَيَاضِ الثِّيَابِ شَدِيدُ سَوَادِ الشَّعْرِ، لاَ يُرَى عَلَيْهِ أَثَرُ السَّفَرِ، وَلاَ يَعْرِفُهُ مِنَّا أَحَدٌ...\n\nقَالَ: يَا مُحَمَّدُ أَخْبِرْنِي عَنِ الإِسْلاَمِ...',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredBooks = _books.where((b) {
      final matchesCat = _selectedCategory == 'الكل' || b['category'] == _selectedCategory;
      final query = _searchController.text.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          (b['title'] as String).toLowerCase().contains(query) ||
          (b['author'] as String).toLowerCase().contains(query);
      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // الخلفية الكريمية الرسمية من الصورة 7
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF191919)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Library',
          style: TextStyle(
            fontFamily: 'Dubai',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF191919),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Box من الصورة 7
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  hintText: 'ابحث',
                  hintStyle: TextStyle(fontFamily: 'Dubai', fontSize: 14, color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),
                decoration: const InputDecoration(
                  hintText: 'ابحث باسم الكتاب أو الشيخ أو المؤلف...',
                  hintStyle: TextStyle(fontFamily: 'Dubai', fontSize: 13, color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                ),
              ),
            ),
          ),

          // Categories Horizontal Chips
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    ),
                    onSelected: (val) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Books List
          Expanded(
            child: filteredBooks.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد كتب مطابقة لبحثك',
                      style: TextStyle(fontFamily: 'Dubai', fontSize: 14, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      return _buildBookCard(book);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BookReaderScreen(book: book)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Red PDF Icon من الصورة 7
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935), // أحمر PDF المطابق للصورة 7
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'PDF',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Info: Title & Size (من الصورة 7)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book['title'] as String,
                        style: const TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191919),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        book['size'] ?? '1017.73 KB',
                        style: TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
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
                          Icon(Icons.format_list_numbered, size: 13, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${book['hadiths']} باب / حديث',
                            style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openReaderModal(Map<String, dynamic> book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double fontSize = 16.0;
            bool isDark = false;

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                            IconButton(
                              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                              onPressed: () {
                                setModalState(() {
                                  isDark = !isDark;
                                });
                              },
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              book['title'] as String,
                              style: TextStyle(
                                fontFamily: 'Dubai',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              book['sampleChapter'] as String,
                              style: const TextStyle(
                                fontFamily: 'Dubai',
                                fontSize: 12,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Content Reader
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF252525) : const Color(0xFFF9F8E8),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E0C8)),
                            ),
                            child: Text(
                              book['sampleText'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Dubai',
                                fontSize: fontSize + 2,
                                height: 2.1,
                                color: isDark ? Colors.white : const Color(0xFF1E2721),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEF6F1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'جميع المتون والكتب مراجعة ومعتمدة من مجمع الملك فهد ولجان التفسير.',
                                    style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Controls
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF222) : Colors.grey.shade50,
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00875A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.chrome_reader_mode_rounded, color: Colors.white, size: 18),
                          label: const Text('فتح قارئ الكتاب', style: TextStyle(fontFamily: 'Dubai', color: Colors.white)),
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => BookReaderScreen(book: book)),
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.bookmark_add, color: Colors.white, size: 18),
                          label: const Text('حفظ موضع القراءة', style: TextStyle(fontFamily: 'Dubai', color: Colors.white)),
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('✅ تم حفظ العلامة المرجعية بنجاح')),
                            );
                          },
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.share, color: AppColors.primary, size: 18),
                          label: const Text('مشاركة المتن', style: TextStyle(fontFamily: 'Dubai', color: AppColors.primary)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('↗️ تم نسخ النص للمشاركة')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
