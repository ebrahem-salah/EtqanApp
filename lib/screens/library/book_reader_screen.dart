import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

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
  int _currentPage = 1;
  late int _totalPages;
  double _fontSize = 18.0;
  ReaderTheme _theme = ReaderTheme.sepia;
  bool _isBookmarked = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late final List<Map<String, dynamic>> _pages;

  @override
  void initState() {
    super.initState();
    _totalPages = widget.book['pages'] ?? 120;
    _generateBookContent();
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  void _showTableOfContents() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'فهرس الأبواب والفصول',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: _textColor),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  itemCount: _pages.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = _pages[index];
                    final isCurrent = p['page'] == _currentPage;
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: isCurrent ? const Color(0xFF00875A) : Colors.grey.shade300,
                        child: Text(
                          '${p['page']}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCurrent ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      title: Text(
                        p['chapter'],
                        style: TextStyle(
                          fontFamily: 'Dubai',
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          color: isCurrent ? const Color(0xFF00875A) : _textColor,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        p['heading'],
                        style: TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _currentPage = p['page'];
                        });
                        Navigator.pop(ctx);
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
  }

  @override
  Widget build(BuildContext context) {
    final currentPageData = _pages.firstWhere(
      (p) => p['page'] == _currentPage,
      orElse: () => _pages.first,
    );

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
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? const Color(0xFF00875A) : _textColor,
            ),
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isBookmarked ? '✅ تم حفظ الصفحة في العلامات المرجعية' : 'تمت إزالة العلامة المرجعية'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.list_alt_rounded, color: _textColor),
            tooltip: 'فهرس الكتاب',
            onPressed: _showTableOfContents,
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Control Toolbar: Font Size & Themes
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _cardColor,
              border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                      label: 'كريمي',
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

          // Main Reading Canvas
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Chapter Header
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

                  // Heading
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

                  // Reading Body
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
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Bottom Navigation Bar: Previous, Page Info Slider, Next
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _cardColor,
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Page Button
                IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: _currentPage > 1 ? const Color(0xFF00875A) : Colors.grey),
                  onPressed: _currentPage > 1
                      ? () => setState(() => _currentPage--)
                      : null,
                ),

                // Page Number Indicator
                Text(
                  'الصفحة $_currentPage من ${_pages.length}',
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),

                // Next Page Button
                IconButton(
                  icon: Icon(Icons.arrow_forward_rounded, color: _currentPage < _pages.length ? const Color(0xFF00875A) : Colors.grey),
                  onPressed: _currentPage < _pages.length
                      ? () => setState(() => _currentPage++)
                      : null,
                ),
              ],
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
          borderRadius: BorderRadius.circular(14),
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
            fontWeight: FontWeight.bold,
            color: theme == ReaderTheme.dark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
