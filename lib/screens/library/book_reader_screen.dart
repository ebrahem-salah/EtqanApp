import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/offline_storage_service.dart';

enum ReaderTheme {
  light,  // White
  sepia,  // Warm Cream Islamic Paper
  dark,   // Night Mode
}

class BookReaderScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookReaderScreen({
    super.key,
    required this.book,
  });

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  late int _currentPage;
  late int _totalPages;
  double _fontSize = 18.0;
  ReaderTheme _theme = ReaderTheme.sepia;
  bool _isBookmarked = false;
  late bool _isMushaf;
  bool _showMushafImage = true;
  late PageController _mushafPageController;

  final TextEditingController _jumpPageController = TextEditingController();

  // فهرس سور القرآن الكريم الـ 114 وصفحات بدايتها في مصحف المدينة (604 صفحات)
  final List<Map<String, dynamic>> _quranSurahs = [
    {'number': 1, 'name': 'الفاتحة', 'page': 1, 'ayas': 7},
    {'number': 2, 'name': 'البقرة', 'page': 2, 'ayas': 286},
    {'number': 3, 'name': 'آل عمران', 'page': 50, 'ayas': 200},
    {'number': 4, 'name': 'النساء', 'page': 77, 'ayas': 176},
    {'number': 5, 'name': 'المائدة', 'page': 106, 'ayas': 120},
    {'number': 6, 'name': 'الأنعام', 'page': 128, 'ayas': 165},
    {'number': 7, 'name': 'الأعراف', 'page': 151, 'ayas': 206},
    {'number': 8, 'name': 'الأنفال', 'page': 177, 'ayas': 75},
    {'number': 9, 'name': 'التوبة', 'page': 187, 'ayas': 129},
    {'number': 10, 'name': 'يونس', 'page': 208, 'ayas': 109},
    {'number': 11, 'name': 'هود', 'page': 221, 'ayas': 123},
    {'number': 12, 'name': 'يوسف', 'page': 235, 'ayas': 111},
    {'number': 13, 'name': 'الرعد', 'page': 249, 'ayas': 43},
    {'number': 14, 'name': 'إبراهيم', 'page': 255, 'ayas': 52},
    {'number': 15, 'name': 'الحجر', 'page': 262, 'ayas': 99},
    {'number': 16, 'name': 'النحل', 'page': 267, 'ayas': 128},
    {'number': 17, 'name': 'الإسراء', 'page': 282, 'ayas': 111},
    {'number': 18, 'name': 'الكهف', 'page': 293, 'ayas': 110},
    {'number': 19, 'name': 'مريم', 'page': 305, 'ayas': 98},
    {'number': 20, 'name': 'طه', 'page': 312, 'ayas': 135},
    {'number': 21, 'name': 'الأنبياء', 'page': 322, 'ayas': 112},
    {'number': 22, 'name': 'الحج', 'page': 332, 'ayas': 78},
    {'number': 23, 'name': 'المؤمنون', 'page': 342, 'ayas': 118},
    {'number': 24, 'name': 'النور', 'page': 350, 'ayas': 64},
    {'number': 25, 'name': 'الفرقان', 'page': 359, 'ayas': 77},
    {'number': 26, 'name': 'الشعراء', 'page': 367, 'ayas': 227},
    {'number': 27, 'name': 'النمل', 'page': 377, 'ayas': 93},
    {'number': 28, 'name': 'القصص', 'page': 385, 'ayas': 88},
    {'number': 29, 'name': 'العنكبوت', 'page': 396, 'ayas': 69},
    {'number': 30, 'name': 'الروم', 'page': 404, 'ayas': 60},
    {'number': 31, 'name': 'لقمان', 'page': 411, 'ayas': 34},
    {'number': 32, 'name': 'السجدة', 'page': 415, 'ayas': 30},
    {'number': 33, 'name': 'الأحزاب', 'page': 418, 'ayas': 73},
    {'number': 34, 'name': 'سبأ', 'page': 428, 'ayas': 54},
    {'number': 35, 'name': 'فاطر', 'page': 434, 'ayas': 45},
    {'number': 36, 'name': 'يس', 'page': 440, 'ayas': 83},
    {'number': 37, 'name': 'الصافات', 'page': 446, 'ayas': 182},
    {'number': 38, 'name': 'ص', 'page': 453, 'ayas': 88},
    {'number': 39, 'name': 'الزمر', 'page': 458, 'ayas': 75},
    {'number': 40, 'name': 'غافر', 'page': 467, 'ayas': 85},
    {'number': 41, 'name': 'فصلت', 'page': 477, 'ayas': 54},
    {'number': 42, 'name': 'الشورى', 'page': 483, 'ayas': 53},
    {'number': 43, 'name': 'الزخرف', 'page': 489, 'ayas': 89},
    {'number': 44, 'name': 'الدخان', 'page': 496, 'ayas': 59},
    {'number': 45, 'name': 'الجاثية', 'page': 499, 'ayas': 37},
    {'number': 46, 'name': 'الأحقاف', 'page': 502, 'ayas': 35},
    {'number': 47, 'name': 'محمد', 'page': 507, 'ayas': 38},
    {'number': 48, 'name': 'الفتح', 'page': 511, 'ayas': 29},
    {'number': 49, 'name': 'الحجرات', 'page': 515, 'ayas': 18},
    {'number': 50, 'name': 'ق', 'page': 518, 'ayas': 45},
    {'number': 51, 'name': 'الذاريات', 'page': 520, 'ayas': 60},
    {'number': 52, 'name': 'الطور', 'page': 523, 'ayas': 49},
    {'number': 53, 'name': 'النجم', 'page': 526, 'ayas': 62},
    {'number': 54, 'name': 'القمر', 'page': 528, 'ayas': 55},
    {'number': 55, 'name': 'الرحمن', 'page': 531, 'ayas': 78},
    {'number': 56, 'name': 'الواقعة', 'page': 534, 'ayas': 96},
    {'number': 57, 'name': 'الحديد', 'page': 537, 'ayas': 29},
    {'number': 58, 'name': 'المجادلة', 'page': 542, 'ayas': 22},
    {'number': 59, 'name': 'الحشر', 'page': 545, 'ayas': 24},
    {'number': 60, 'name': 'الممتحنة', 'page': 549, 'ayas': 13},
    {'number': 61, 'name': 'الصف', 'page': 551, 'ayas': 14},
    {'number': 62, 'name': 'الجمعة', 'page': 553, 'ayas': 11},
    {'number': 63, 'name': 'المنافقون', 'page': 554, 'ayas': 11},
    {'number': 64, 'name': 'التغابن', 'page': 556, 'ayas': 18},
    {'number': 65, 'name': 'الطلاق', 'page': 558, 'ayas': 12},
    {'number': 66, 'name': 'التحريم', 'page': 560, 'ayas': 12},
    {'number': 67, 'name': 'الملك', 'page': 562, 'ayas': 30},
    {'number': 68, 'name': 'القلم', 'page': 564, 'ayas': 52},
    {'number': 69, 'name': 'الحاقة', 'page': 566, 'ayas': 52},
    {'number': 70, 'name': 'المعارج', 'page': 568, 'ayas': 44},
    {'number': 71, 'name': 'نوح', 'page': 570, 'ayas': 28},
    {'number': 72, 'name': 'الجن', 'page': 572, 'ayas': 28},
    {'number': 73, 'name': 'المزمل', 'page': 574, 'ayas': 20},
    {'number': 74, 'name': 'المدثر', 'page': 575, 'ayas': 56},
    {'number': 75, 'name': 'القيامة', 'page': 577, 'ayas': 40},
    {'number': 76, 'name': 'الإنسان', 'page': 578, 'ayas': 31},
    {'number': 77, 'name': 'المرسلات', 'page': 580, 'ayas': 50},
    {'number': 78, 'name': 'النبأ', 'page': 582, 'ayas': 40},
    {'number': 79, 'name': 'النازعات', 'page': 583, 'ayas': 46},
    {'number': 80, 'name': 'عبس', 'page': 585, 'ayas': 42},
    {'number': 81, 'name': 'التكوير', 'page': 586, 'ayas': 29},
    {'number': 82, 'name': 'الانفطار', 'page': 587, 'ayas': 19},
    {'number': 83, 'name': 'المطففين', 'page': 587, 'ayas': 36},
    {'number': 84, 'name': 'الانشقاق', 'page': 589, 'ayas': 25},
    {'number': 85, 'name': 'البروج', 'page': 590, 'ayas': 22},
    {'number': 86, 'name': 'الطارق', 'page': 591, 'ayas': 17},
    {'number': 87, 'name': 'الأعلى', 'page': 591, 'ayas': 19},
    {'number': 88, 'name': 'الغاشية', 'page': 592, 'ayas': 26},
    {'number': 89, 'name': 'الفجر', 'page': 593, 'ayas': 30},
    {'number': 90, 'name': 'البلد', 'page': 594, 'ayas': 20},
    {'number': 91, 'name': 'الشمس', 'page': 595, 'ayas': 15},
    {'number': 92, 'name': 'الليل', 'page': 595, 'ayas': 21},
    {'number': 93, 'name': 'الضحى', 'page': 596, 'ayas': 11},
    {'number': 94, 'name': 'الشرح', 'page': 596, 'ayas': 8},
    {'number': 95, 'name': 'التين', 'page': 597, 'ayas': 8},
    {'number': 96, 'name': 'العلق', 'page': 597, 'ayas': 19},
    {'number': 97, 'name': 'القدر', 'page': 598, 'ayas': 5},
    {'number': 98, 'name': 'البينة', 'page': 598, 'ayas': 8},
    {'number': 99, 'name': 'الزلزلة', 'page': 599, 'ayas': 8},
    {'number': 100, 'name': 'العاديات', 'page': 599, 'ayas': 11},
    {'number': 101, 'name': 'القارعة', 'page': 600, 'ayas': 11},
    {'number': 102, 'name': 'التكاثر', 'page': 600, 'ayas': 8},
    {'number': 103, 'name': 'العصر', 'page': 601, 'ayas': 3},
    {'number': 104, 'name': 'الهمزة', 'page': 601, 'ayas': 9},
    {'number': 105, 'name': 'الفيل', 'page': 601, 'ayas': 5},
    {'number': 106, 'name': 'قريش', 'page': 602, 'ayas': 4},
    {'number': 107, 'name': 'الماعون', 'page': 602, 'ayas': 7},
    {'number': 108, 'name': 'الكوثر', 'page': 602, 'ayas': 3},
    {'number': 109, 'name': 'الكافرون', 'page': 603, 'ayas': 6},
    {'number': 110, 'name': 'النصر', 'page': 603, 'ayas': 3},
    {'number': 111, 'name': 'المسد', 'page': 603, 'ayas': 5},
    {'number': 112, 'name': 'الإخلاص', 'page': 604, 'ayas': 4},
    {'number': 113, 'name': 'الفلق', 'page': 604, 'ayas': 5},
    {'number': 114, 'name': 'الناس', 'page': 604, 'ayas': 6},
  ];

  late final List<Map<String, dynamic>> _pages;

  @override
  void initState() {
    super.initState();
    final cat = widget.book['category']?.toString() ?? '';
    final title = widget.book['title']?.toString() ?? '';
    _isMushaf = cat == 'قسم المصاحف' || title.contains('مصحف');

    _totalPages = _isMushaf ? 604 : (widget.book['pages'] ?? 120);
    _currentPage = 1;
    _mushafPageController = PageController(initialPage: _currentPage - 1);

    _generateBookContent();
  }

  @override
  void dispose() {
    _mushafPageController.dispose();
    _jumpPageController.dispose();
    super.dispose();
  }

  void _generateBookContent() {
    final title = widget.book['title'] ?? 'كتاب إتقان';
    final sample = widget.book['sampleText'] ?? 'بسم الله الرحمن الرحيم\nالحمد لله رب العالمين، والصلاة والسلام على أشرف المرسلين.';
    final sampleChapter = widget.book['sampleChapter'] ?? 'المقدمة والأصول';

    _pages = [
      {
        'page': 1,
        'chapter': sampleChapter,
        'heading': 'بَابُ بَدْءِ الْوَحْيِ وَالنِّيَّةِ',
        'content': '$sample\n\nقَالَ رَسُولُ اللَّهِ ﷺ: «مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا، سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الْجَنَّةِ».',
      },
      {
        'page': 2,
        'chapter': 'فصل في فضل القرآن وأهله',
        'heading': 'بَابُ فَضْلِ حَمَلَةِ الْقُرْآنِ',
        'content': 'عَنْ عُثْمَانَ بْنِ عَفَّانَ رَضِيَ اللَّهُ عَنْهُ، عَنِ النَّبِيِّ ﷺ قَالَ:\n\n«خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ».\n\nرَوَاهُ الْبُخَارِيُّ فِي صَحِيحِهِ.\n\nوفيه دلالة صريحة على عظيم شرف قارئ القرآن ومقرئه، وأن الاشتغال بكتاب الله تلاوة وتدبراً وتعليماً هو أعلى المراتب في الإسلام.',
      },
      {
        'page': 3,
        'chapter': 'فصل في أحكام التجويد ومخارج الحروف',
        'heading': 'بَابُ مَخَارِجِ الْحُرُوفِ الْعَرَبِيَّةِ',
        'content': 'مَخَارِجُ الْحُرُوفِ سَبْعَةَ عَشَرَ عَلَى الَّذِي يَخْتَارُهُ مَنِ اخْتَبَرَ.\n\nفَلِلْجَوْفِ أَلِفٌ وَأُخْتَاهَا وَهِي حُرُوفُ مَدٍّ لِلْهَوَاءِ تَنْتَهِي.\nثُمَّ لِأَقْصَى الْحَلْقِ هَمْزٌ هَاءُ، ثُمَّ لِوَسْطِهِ فَعَيْنٌ حَاءُ، أَدْنَاهُ غَيْنٌ خَاؤُهَا.\n\nويجب على القارئ المبتدئ العناية باللسان ومخارجه ليخرج كل حرف بصفته الكاملة دون تفريط.',
      },
      {
        'page': 4,
        'chapter': 'فصل في أحكام النون الساكنة والتنوين',
        'heading': 'بَابُ أَحْكَامِ النُّونِ السَّاكِنَةِ وَالتَّنْوِينِ',
        'content': 'لِلنُّونِ إِنْ تَسْكُنْ وَلِلتَّنْوِينِ أَرْبَعُ أَحْكَامٍ فَخُذْ تَبْيِينِي:\n\nفَالْأَوَّلُ الْإِظْهَارُ قَبْلَ أَحْرُفِ لِلْحَلْقِ سِتٌّ رُتِّبَتْ فَلْتَعْرِفِ (هَمْزٌ فَهَاءٌ ثُمَّ عَيْنٌ حَاءُ مُهْمَلَتَانِ ثُمَّ غَيْنٌ خَاءُ).\n\nوَالثَّانِي إِدْغَامٌ بِسِتَّةٍ أَتَتْ فِي (يَرْمُلُونَ) عِنْدَهُمْ قَدْ ثَبَتَتْ.',
      },
      {
        'page': 5,
        'chapter': 'خاتمة الكتاب ودعاء الختم',
        'heading': 'بَابُ الدُّعَاءِ عِنْدَ خَتْمِ الْقُرْآنِ',
        'content': 'اللَّهُمَّ ارْحَمْنَا بِالْقُرْآنِ، وَاجْعَلْهُ لَنَا إِمَامًا وَنُورًا وَهُدًى وَرَحْمَةً.\nاللَّهُمَّ ذَكِّرْنَا مِنْهُ مَا نَسِينَا، وَعَلِّمْنَا مِنْهُ مَا جَهِلْنَا، وَارْزُقْنَا تِلاوَتَهُ آنَاءَ اللَّيْلِ وَأَطْرَافَ النَّهَارِ، وَاجْعَلْهُ لَنَا حُجَّةً يَا رَبَّ الْعَالَمِينَ.',
      },
    ];
  }

  Color get _backgroundColor {
    switch (_theme) {
      case ReaderTheme.light:
        return const Color(0xFFFFFFFF);
      case ReaderTheme.sepia:
        return const Color(0xFFFAF7EE);
      case ReaderTheme.dark:
        return const Color(0xFF1A1A1A);
    }
  }

  Color get _textColor {
    switch (_theme) {
      case ReaderTheme.light:
        return const Color(0xFF1E2822);
      case ReaderTheme.sepia:
        return const Color(0xFF2C2418);
      case ReaderTheme.dark:
        return const Color(0xFFE8E8E8);
    }
  }

  Color get _cardColor {
    switch (_theme) {
      case ReaderTheme.light:
        return const Color(0xFFF7F7F7);
      case ReaderTheme.sepia:
        return const Color(0xFFF2ECE0);
      case ReaderTheme.dark:
        return const Color(0xFF262626);
    }
  }

  void _jumpToMushafPage(int page) {
    if (page < 1 || page > _totalPages) return;
    setState(() => _currentPage = page);
    if (_isMushaf && _mushafPageController.hasClients) {
      _mushafPageController.jumpToPage(page - 1);
    }
  }

  void _showSurahIndex() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _quranSurahs.where((s) => s['name'].toString().contains(query)).toList();
            return Container(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'فهرس سور القرآن الكريم (114 سورة)',
                        style: TextStyle(fontFamily: 'Dubai', fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (val) => setModalState(() => query = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'ابحث باسم السورة (البقرة، الكهف، يس...)',
                      hintStyle: const TextStyle(fontFamily: 'Dubai', fontSize: 12),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF00875A)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, idx) {
                        final s = filtered[idx];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: const Color(0xFF00875A),
                            child: Text(
                              '${s['number']}',
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            'سورة ${s['name']}',
                            style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            '${s['ayas']} آية',
                            style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00875A).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'صفحة ${s['page']}',
                              style: const TextStyle(fontFamily: 'Dubai', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00875A)),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(ctx);
                            _jumpToMushafPage(s['page'] as int);
                          },
                        );
                      },
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

  void _showJumpToPageDialog() {
    _jumpPageController.text = '$_currentPage';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'الانتقال إلى صفحة',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('أدخل رقم الصفحة من 1 إلى $_totalPages:'),
            const SizedBox(height: 12),
            TextField(
              controller: _jumpPageController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Dubai', color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00875A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final p = int.tryParse(_jumpPageController.text.trim());
              if (p != null && p >= 1 && p <= _totalPages) {
                Navigator.pop(ctx);
                _jumpToMushafPage(p);
              }
            },
            child: const Text('انتقال', style: TextStyle(fontFamily: 'Dubai', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.book['title'] ?? 'المكتبة الإسلامية',
          style: TextStyle(
            fontFamily: 'Dubai',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        actions: [
          if (_isMushaf)
            IconButton(
              icon: const Icon(Icons.menu_book_rounded, color: Color(0xFF00875A)),
              tooltip: 'فهرس السور',
              onPressed: _showSurahIndex,
            ),
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? const Color(0xFF00875A) : _textColor,
            ),
            onPressed: () async {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
              if (_isBookmarked) {
                await OfflineStorageService.instance.saveBookmark(
                  surahNumber: _currentPage,
                  ayahNumber: 1,
                  surahName: widget.book['title'] ?? 'المصحف الشريف',
                );
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isBookmarked ? '✅ تم حفظ الصفحة $_currentPage في العلامات المرجعية' : 'تمت إزالة العلامة المرجعية'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Control Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _cardColor,
              border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_isMushaf) ...[
                  // Toggle between Visual Mushaf & Text
                  Row(
                    children: [
                      ChoiceChip(
                        selected: _showMushafImage,
                        label: const Text('المصحف المصور', style: TextStyle(fontFamily: 'Dubai', fontSize: 11)),
                        selectedColor: const Color(0xFF00875A),
                        labelStyle: TextStyle(
                          color: _showMushafImage ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setState(() => _showMushafImage = true),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        selected: !_showMushafImage,
                        label: const Text('القراءة النصية', style: TextStyle(fontFamily: 'Dubai', fontSize: 11)),
                        selectedColor: const Color(0xFF00875A),
                        labelStyle: TextStyle(
                          color: !_showMushafImage ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setState(() => _showMushafImage = false),
                      ),
                    ],
                  ),
                ] else ...[
                  // Font Size Adjuster
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.text_decrease_rounded, color: _textColor, size: 20),
                        onPressed: () {
                          if (_fontSize > 14) setState(() => _fontSize -= 2);
                        },
                      ),
                      Text(
                        '${_fontSize.toInt()}pt',
                        style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: _textColor, fontSize: 13),
                      ),
                      IconButton(
                        icon: Icon(Icons.text_increase_rounded, color: _textColor, size: 20),
                        onPressed: () {
                          if (_fontSize < 30) setState(() => _fontSize += 2);
                        },
                      ),
                    ],
                  ),
                ],

                // Jump to Page Button
                InkWell(
                  onTap: _showJumpToPageDialog,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00875A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF00875A).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 14, color: Color(0xFF00875A)),
                        const SizedBox(width: 4),
                        Text(
                          'صفحة $_currentPage',
                          style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF00875A)),
                        ),
                      ],
                    ),
                  ),
                ),

                // Theme Mode Switcher
                Row(
                  children: [
                    _buildThemeChip(
                      label: 'أبيض',
                      theme: ReaderTheme.light,
                      bgColor: Colors.white,
                      borderColor: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 6),
                    _buildThemeChip(
                      label: 'ورقي',
                      theme: ReaderTheme.sepia,
                      bgColor: const Color(0xFFFAF7EE),
                      borderColor: const Color(0xFFD4AF37),
                    ),
                    const SizedBox(width: 6),
                    _buildThemeChip(
                      label: 'ليلي',
                      theme: ReaderTheme.dark,
                      bgColor: const Color(0xFF1E1E1E),
                      borderColor: Colors.grey.shade600,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Reading Area
          Expanded(
            child: (_isMushaf && _showMushafImage)
                ? _buildMushafImageViewer()
                : _buildTextReader(),
          ),

          // Bottom Bar: Navigation controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _cardColor,
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00875A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('السابقة', style: TextStyle(fontFamily: 'Dubai', fontSize: 12)),
                  onPressed: _currentPage > 1
                      ? () => _jumpToMushafPage(_currentPage - 1)
                      : null,
                ),

                Text(
                  'الصفحة $_currentPage من $_totalPages',
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00875A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  label: const Text('التالية', style: TextStyle(fontFamily: 'Dubai', fontSize: 12)),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  onPressed: _currentPage < _totalPages
                      ? () => _jumpToMushafPage(_currentPage + 1)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // عارض صفحات المصحف الشريف المصور عالي الدقة (رسم عثماني معتمد)
  Widget _buildMushafImageViewer() {
    return PageView.builder(
      controller: _mushafPageController,
      itemCount: 604,
      onPageChanged: (pageIndex) {
        setState(() => _currentPage = pageIndex + 1);
      },
      itemBuilder: (context, index) {
        final pageNum = index + 1;
        final pageStr = pageNum.toString().padLeft(3, '0');
        final pageUrl = 'https://everyayah.com/data/images_png/$pageStr.png';

        return InteractiveViewer(
          minScale: 1.0,
          maxScale: 3.5,
          child: Container(
            color: _backgroundColor,
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: CachedNetworkImage(
              imageUrl: pageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF00875A)),
                    const SizedBox(height: 12),
                    Text(
                      'جاري تحميل الصفحة $pageNum من المصحف الشريف...',
                      style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: _textColor),
                    ),
                  ],
                ),
              ),
              errorWidget: (context, url, error) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.menu_book, size: 48, color: Colors.grey),
                    const SizedBox(height: 10),
                    Text(
                      'صفحة $pageNum - مصحف المدينة النبوية',
                      style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: _textColor),
                    ),
                    const SizedBox(height: 6),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh, color: Color(0xFF00875A)),
                      label: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Dubai', color: Color(0xFF00875A))),
                      onPressed: () => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // عارض النصوص والتفاسير
  Widget _buildTextReader() {
    final pageIndex = (_currentPage - 1).clamp(0, _pages.length - 1);
    final currentPageData = _pages[pageIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00875A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                currentPageData['chapter'],
                style: const TextStyle(
                  fontFamily: 'Dubai',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00875A),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            currentPageData['heading'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Dubai',
              fontSize: _fontSize + 2,
              fontWeight: FontWeight.bold,
              color: _textColor,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
            ),
            child: Text(
              currentPageData['content'],
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontFamily: 'Dubai',
                fontSize: _fontSize,
                height: 2.3,
                color: _textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeChip({
    required String label,
    required ReaderTheme theme,
    required Color bgColor,
    required Color borderColor,
  }) {
    final isSelected = _theme == theme;
    return GestureDetector(
      onTap: () => setState(() => _theme = theme),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF00875A) : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Dubai',
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: theme == ReaderTheme.dark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
