import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/quran_uthmani_service.dart';
import '../../../core/utils/app_feedback.dart';

/// نافذة المحتوى التعليمي في الحلقة: المصحف العثماني (مع التفسير الميسر) + الكتب والشروحات (مع تظليل السطور ومرفقات الشرح)
class RoomMushafSheet extends StatefulWidget {
  final int initialTabIndex; // 0: المصحف, 1: الكتب والشروحات
  final int initialSurah;
  final String? initialBookTitle;
  final String? initialBookChapter;
  final String? initialBookText;
  final int? initialHighlightedLine;
  final bool isSheikh;
  final bool initialAllowedForStudents;
  final ValueChanged<int> onSurahChanged;
  final void Function(String title, String chapter, String text, int? highlightedLine)? onLibrarySynced;
  final Future<void> Function()? onShareAttachment;
  final ValueChanged<bool> onToggleAllowForStudents;

  const RoomMushafSheet({
    super.key,
    this.initialTabIndex = 0,
    required this.initialSurah,
    this.initialBookTitle,
    this.initialBookChapter,
    this.initialBookText,
    this.initialHighlightedLine,
    required this.isSheikh,
    required this.initialAllowedForStudents,
    required this.onSurahChanged,
    this.onLibrarySynced,
    this.onShareAttachment,
    required this.onToggleAllowForStudents,
  });

  @override
  State<RoomMushafSheet> createState() => _RoomMushafSheetState();
}

class _RoomMushafSheetState extends State<RoomMushafSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient _apiClient = ApiClient();

  // حالة المصحف + التفسير الميسر
  late int _selectedSurah;
  late bool _allowedForStudents;
  double _fontSize = 20.0;
  bool _isLoadingSurah = true;
  String? _surahError;
  List<Map<String, dynamic>> _ayahs = [];
  Map<int, String> _tafsirMap = {};
  int? _selectedAyahNum;
  String? _selectedAyahText;
  String? _selectedAyahTafsir;
  bool _isLoadingTafsir = false;
  final List<TapGestureRecognizer> _ayahRecognizers = [];

  // حالة الكتب والشروحات وتظليل الفقرة الحالية
  bool _isLoadingBooks = false;
  late List<Map<String, String>> _books;
  int _selectedBookIndex = 0;
  int? _highlightedLine;

  static const List<Map<String, String>> _defaultBooks = [
    {
      'title': 'المقدمة الجزرية في التجويد',
      'chapter': 'باب مخارج الحروف',
      'text': 'مَخَارِجُ الْحُرُوفِ سَبْعَةَ عَشَرْ — عَلَى الَّذِي يَخْتَارُهُ مَنِ اخْتَبَرْ\nفَأَلِفُ الْجَوْفِ وَأُخْتَاهَا وَهِيْ — حُرُوفُ مَدٍّ لِلْهَوَاءِ تَنْتَهِيْ\nثُمَّ لِأَقْصَى الْحَلْقِ هَمْزٌ هَاءُ — وَمِنْ وَسَطِهِ فَعَيْنٌ حَاءُ',
    },
    {
      'title': 'تحفة الأطفال والغلمان',
      'chapter': 'أحكام النون الساكنة والتنوين',
      'text': 'لِلنُّونِ إِنْ تَسْكُنْ وَلِلتَّنْوِينِ — أَرْبَعُ أَحْكَامٍ فَخُذْ تَبْيِينِي\nفَالأَوَّلُ الإِظْهَارُ قَبْلَ أَحْرُفِ — لِلْحَلْقِ سِتٌّ رُتِّبَتْ فَلْتَعْرِفِ\nهَمْزٌ فَهَاءٌ ثُمَّ عَيْنٌ حَاءُ — مُهْمَلَتَانِ ثُمَّ غَيْنٌ خَاءُ',
    },
    {
      'title': 'الأربعون النووية',
      'chapter': 'الحديث الأول: الأعمال بالنيات',
      'text': 'عَنْ أَمِيرِ الْمُؤْمِنِينَ أَبِي حَفْصٍ عُمَرَ بْنِ الْخَطَّابِ رَضِيَ اللَّهُ عَنْهُ قَالَ: سَمِعْتُ رَسُولَ اللَّهِ ﷺ يَقُولُ:\n«إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى، فَمَنْ كَانَتْ هِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ فَهِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ، وَمَنْ كَانَتْ هِجْرَتُهُ لِدُنْيَا يُصِيبُهَا أَوِ امْرَأَةٍ يَنْكِحُهَا فَهِجْرَتُهُ إِلَى مَا هَاجَرَ إِلَيْهِ».',
    },
    {
      'title': 'رياض الصالحين',
      'chapter': 'باب الإخلاص وإحضار النية',
      'text': 'قَالَ اللَّهُ تَعَالَى: {وَمَا أُمِرُوا إِلَّا لِيَعْبُدُوا اللَّهَ مُخْلِصِينَ لَهُ الدِّينَ حُنَفَاءَ وَيُقِيمُوا الصَّلَاةَ وَيُؤْتُوا الزَّكَاةَ وَذَلِكَ دِينُ الْقَيِّمَةِ}.\nوَعَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ قَالَ: قَالَ رَسُولُ اللَّهِ ﷺ: «إِنَّ اللَّهَ لَا يَنْظُرُ إِلَى أَجْسَادِكُمْ وَلَا إِلَى صُوَرِكُمْ، وَلَكِنْ يَنْظُرُ إِلَى قُلُوبِكُمْ وَأَعْمَالِكُمْ».',
    },
    {
      'title': 'التفسير الميسر',
      'chapter': 'تفسير سورة الفاتحة',
      'text': '{بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ}\nأبدأ قراءتي مستعيناً بالله، والله علم على الرب المعبود بحق دون سواه. والرحمن: ذو الرحمة العامة الشاملة لجميع الخلائق، والرحيم: بالمؤمنين.\n{الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ}\nالثناء على الله بصفاته التي كلها أوصاف كمال، وبنعمه الظاهرة والباطنة.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
    _selectedSurah = widget.initialSurah.clamp(1, 114);
    _allowedForStudents = widget.initialAllowedForStudents;
    _highlightedLine = widget.initialHighlightedLine;
    _books = List<Map<String, String>>.from(_defaultBooks);

    if (widget.initialBookTitle != null && widget.initialBookTitle!.isNotEmpty) {
      final idx = _books.indexWhere((b) => b['title'] == widget.initialBookTitle);
      if (idx >= 0) {
        _selectedBookIndex = idx;
      } else {
        _books.insert(0, {
          'title': widget.initialBookTitle!,
          'chapter': widget.initialBookChapter ?? 'شرح الشيخ',
          'text': widget.initialBookText ?? '',
        });
        _selectedBookIndex = 0;
      }
    }

    _loadSurah(_selectedSurah);
    _loadServerBooks();
  }

  void _disposeRecognizers() {
    for (final r in _ayahRecognizers) {
      r.dispose();
    }
    _ayahRecognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSurah(int surahNum) async {
    setState(() {
      _selectedSurah = surahNum;
      _isLoadingSurah = true;
      _surahError = null;
      _selectedAyahNum = null;
      _selectedAyahText = null;
      _selectedAyahTafsir = null;
      _tafsirMap = {};
    });
    try {
      final list = await QuranUthmaniService.instance.getSurahAyahs(surahNum);
      if (mounted) {
        setState(() {
          _ayahs = list;
          _isLoadingSurah = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSurah = false;
          _surahError = AppFeedback.formatError(e);
        });
      }
    }
  }

  Future<void> _showAyahTafsir(int ayahNum, String ayahText) async {
    setState(() {
      _selectedAyahNum = ayahNum;
      _selectedAyahText = ayahText;
      _selectedAyahTafsir = _tafsirMap[ayahNum];
      _isLoadingTafsir = _tafsirMap[ayahNum] == null;
    });

    if (_tafsirMap.isEmpty) {
      try {
        final tMap = await QuranUthmaniService.instance.getSurahTafsir(_selectedSurah);
        if (mounted) {
          setState(() {
            _tafsirMap = tMap;
            _selectedAyahTafsir = tMap[ayahNum] ?? 'التفسير غير متوفر لهذه الآية';
            _isLoadingTafsir = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _selectedAyahTafsir = 'تعذر جلب التفسير: ${AppFeedback.formatError(e)}';
            _isLoadingTafsir = false;
          });
        }
      }
    }
  }

  Future<void> _loadServerBooks() async {
    setState(() => _isLoadingBooks = true);
    try {
      final res = await _apiClient.getLibraryBooks();
      if (res.statusCode == 200 && res.data != null && mounted) {
        final List items = res.data['data'] is List ? res.data['data'] : [];
        if (items.isNotEmpty) {
          final List<Map<String, String>> fetched = [];
          for (final b in items) {
            final title = (b['name_ar'] ?? b['title'] ?? b['name'] ?? '').toString().trim();
            if (title.isEmpty) continue;
            if (_books.any((existing) => existing['title'] == title)) continue;
            fetched.add({
              'title': title,
              'chapter': (b['author'] ?? b['category'] ?? 'مكتبة إتقان').toString(),
              'text': (b['description'] ?? b['content'] ?? 'كتاب معتمد في مكتبة إتقان — اشرح الفقرات وتابع مع الطلاب.').toString(),
            });
          }
          if (fetched.isNotEmpty) {
            setState(() => _books.addAll(fetched));
          }
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingBooks = false);
  }

  Future<void> _openCustomLessonDialog() async {
    final titleCtrl = TextEditingController();
    final chapterCtrl = TextEditingController(text: 'شرح الدرس');
    final textCtrl = TextEditingController();

    final created = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'إضافة شرح أو نص درس للحلقة 📝',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'اسم الكتاب أو الدرس',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: chapterCtrl,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'الباب أو العنوان الفرعي',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: textCtrl,
                maxLines: 5,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'النص أو الحديث أو الأبيات (كل سطر فقرة قابلة للتظليل)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Dubai', color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00875A)),
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty || textCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, {
                'title': titleCtrl.text.trim(),
                'chapter': chapterCtrl.text.trim().isEmpty ? 'شرح الشيخ' : chapterCtrl.text.trim(),
                'text': textCtrl.text.trim(),
              });
            },
            child: const Text('عرض ومزامنة', style: TextStyle(fontFamily: 'Dubai', color: Colors.white)),
          ),
        ],
      ),
    );

    if (created != null && mounted) {
      setState(() {
        _books.insert(0, created);
        _selectedBookIndex = 0;
        _highlightedLine = 0;
      });
      widget.onLibrarySynced?.call(
        created['title']!,
        created['chapter']!,
        created['text']!,
        0,
      );
      AppFeedback.showSuccess(context, 'تم عرض "${created['title']}" ومزامنته للطلاب');
    }
  }

  MushafSurahMeta get _currentMeta => QuranUthmaniService.allSurahsMeta.firstWhere(
        (s) => s.number == _selectedSurah,
        orElse: () => QuranUthmaniService.allSurahsMeta.first,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 42,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
          ),

          // تبويبا المحتوى: المصحف العثماني | الكتب والشروحات
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: const Color(0xFF00875A),
                borderRadius: BorderRadius.circular(11),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black87,
              labelStyle: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 12.5),
              tabs: const [
                Tab(text: 'المصحف العثماني 📖'),
                Tab(text: 'الكتب والشروحات 📚'),
              ],
            ),
          ),

          // شريط تحكم الشيخ الحصري في فتح/قفل المحتوى للطلاب
          if (widget.isSheikh)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _allowedForStudents ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _allowedForStudents ? const Color(0xFF00875A) : Colors.orange,
                ),
              ),
              child: Row(
                children: [
                  Switch.adaptive(
                    value: _allowedForStudents,
                    activeColor: const Color(0xFF00875A),
                    onChanged: (val) {
                      setState(() => _allowedForStudents = val);
                      widget.onToggleAllowForStudents(val);
                    },
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _allowedForStudents
                          ? 'المصحف والكتب مفتوحة للطلاب الآن'
                          : 'المصحف والكتب مقفولة عن الطلاب (وضع التسميع)',
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: _allowedForStudents ? const Color(0xFF00875A) : Colors.deepOrange.shade800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'تصغير الخط',
                    icon: const Icon(Icons.text_decrease_rounded, size: 18, color: Color(0xFF00875A)),
                    onPressed: () {
                      if (_fontSize > 14) setState(() => _fontSize -= 2);
                    },
                  ),
                  IconButton(
                    tooltip: 'تكبير الخط',
                    icon: const Icon(Icons.text_increase_rounded, size: 18, color: Color(0xFF00875A)),
                    onPressed: () {
                      if (_fontSize < 30) setState(() => _fontSize += 2);
                    },
                  ),
                ],
              ),
            ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMushafTab(),
                _buildBooksTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMushafTab() {
    final surahs = QuranUthmaniService.allSurahsMeta;
    final currentMeta = _currentMeta;

    _disposeRecognizers();
    final List<InlineSpan> ayahSpans = [];
    for (final a in _ayahs) {
      final int numInSurah = int.tryParse('${a['numberInSurah'] ?? 1}') ?? 1;
      String txt = (a['text'] ?? '').toString();
      if (_selectedSurah != 1 && _selectedSurah != 9 && numInSurah == 1) {
        txt = txt.replaceFirst(
          RegExp(r'^بِسْمِ\s+ٱ?للَّهِ\s+ٱ?لرَّحْمَٰنِ\s+ٱ?لرَّحِيمِ\s*'),
          '',
        );
      }
      final rec = TapGestureRecognizer()..onTap = () => _showAyahTafsir(numInSurah, txt);
      _ayahRecognizers.add(rec);
      final bool isSelected = _selectedAyahNum == numInSurah;
      ayahSpans.add(
        TextSpan(
          text: '$txt ﴿$numInSurah﴾ ',
          recognizer: rec,
          style: TextStyle(
            fontFamily: 'Dubai',
            fontSize: _fontSize,
            height: 2.15,
            color: isSelected ? const Color(0xFF005F3F) : const Color(0xFF191919),
            backgroundColor: isSelected ? const Color(0xFFD3EADB) : null,
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              if (widget.isSheikh)
                TextButton.icon(
                  onPressed: () {
                    widget.onSurahChanged(_selectedSurah);
                    AppFeedback.showSuccess(context, 'تم إرسال موضع ${currentMeta.name} للطلاب');
                  },
                  icon: const Icon(Icons.sync_rounded, size: 16, color: Color(0xFF00875A)),
                  label: const Text('مزامنة للجميع', style: TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00875A).withOpacity(0.35)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedSurah,
                      isExpanded: true,
                      alignment: AlignmentDirectional.centerEnd,
                      items: surahs.map((s) {
                        return DropdownMenuItem<int>(
                          value: s.number,
                          child: Text(
                            '${s.number}. ${s.name} (${s.ayahsCount})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Dubai', fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val == null) return;
                        _loadSurah(val);
                        if (widget.isSheikh) widget.onSurahChanged(val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 6),
        Expanded(
          child: _isLoadingSurah
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00875A)))
              : _surahError != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('تعذر تحميل السورة: $_surahError', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Dubai', color: Colors.red)),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00875A)),
                              onPressed: () => _loadSurah(_selectedSurah),
                              child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Dubai', color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00875A).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${currentMeta.name} • ${currentMeta.revelationType} • ${currentMeta.ayahsCount} آية',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Dubai',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF00875A),
                                  ),
                                ),
                                const Text(
                                  'اضغط على أي آية لعرض التفسير الميسر فوراً 💡',
                                  style: TextStyle(fontFamily: 'Dubai', fontSize: 10.5, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedSurah != 1 && _selectedSurah != 9)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Dubai',
                                  fontSize: _fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E2822),
                                ),
                              ),
                            ),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text.rich(
                              TextSpan(children: ayahSpans),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
        // بطاقة التفسير الميسر السفلية عند اختيار آية
        if (_selectedAyahNum != null)
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 165),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F5),
              border: const Border(top: BorderSide(color: Color(0xFF00875A), width: 1.5)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _selectedAyahNum = null),
                        child: const Icon(Icons.close, size: 18, color: Colors.grey),
                      ),
                      Text(
                        'التفسير الميسر — آية $_selectedAyahNum',
                        style: const TextStyle(
                          fontFamily: 'Dubai',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF00875A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (_isLoadingTafsir)
                    const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00875A))))
                  else
                    Text(
                      _selectedAyahTafsir ?? _selectedAyahText ?? '',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontFamily: 'Dubai', fontSize: 13, height: 1.7, color: Color(0xFF1E2822)),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBooksTab() {
    final safeIdx = _selectedBookIndex.clamp(0, _books.length - 1);
    final selectedBook = _books[safeIdx];
    final lines = (selectedBook['text'] ?? '')
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              if (widget.isSheikh) ...[
                IconButton(
                  tooltip: 'إرسال صورة/ورقة شرح من الجهاز',
                  icon: const Icon(Icons.attach_file_rounded, color: Color(0xFF00875A)),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await widget.onShareAttachment?.call();
                  },
                ),
                IconButton(
                  tooltip: 'إضافة نص درس مخصص',
                  icon: const Icon(Icons.post_add_rounded, color: Color(0xFF00875A)),
                  onPressed: _openCustomLessonDialog,
                ),
                TextButton.icon(
                  onPressed: () {
                    widget.onLibrarySynced?.call(
                      selectedBook['title'] ?? '',
                      selectedBook['chapter'] ?? '',
                      selectedBook['text'] ?? '',
                      _highlightedLine,
                    );
                    AppFeedback.showSuccess(context, 'تم عرض "${selectedBook['title']}" للطلاب');
                  },
                  icon: const Icon(Icons.sync_rounded, size: 16, color: Color(0xFF00875A)),
                  label: const Text('مزامنة', style: TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00875A).withOpacity(0.35)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: safeIdx,
                      isExpanded: true,
                      alignment: AlignmentDirectional.centerEnd,
                      items: List.generate(_books.length, (i) {
                        return DropdownMenuItem<int>(
                          value: i,
                          child: Text(
                            _books[i]['title'] ?? 'كتاب',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Dubai', fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        );
                      }),
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() {
                          _selectedBookIndex = val;
                          _highlightedLine = null;
                        });
                        if (widget.isSheikh) {
                          final b = _books[val];
                          widget.onLibrarySynced?.call(
                            b['title'] ?? '',
                            b['chapter'] ?? '',
                            b['text'] ?? '',
                            null,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isLoadingBooks)
          const LinearProgressIndicator(color: Color(0xFF00875A), minHeight: 2),
        const Divider(height: 6),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00875A).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      selectedBook['title'] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Dubai',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF00875A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedBook['chapter'] ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade700),
                    ),
                    if (widget.isSheikh)
                      const Text(
                        'اضغط على أي فقرة أو بيت لتظليله ومزامنته أمام الطلاب 👆',
                        style: TextStyle(fontFamily: 'Dubai', fontSize: 10.5, color: Colors.grey),
                      ),
                  ],
                ),
              ),
              ...List.generate(lines.length, (idx) {
                final bool isHighlighted = _highlightedLine == idx;
                return GestureDetector(
                  onTap: widget.isSheikh
                      ? () {
                          final next = isHighlighted ? null : idx;
                          setState(() => _highlightedLine = next);
                          widget.onLibrarySynced?.call(
                            selectedBook['title'] ?? '',
                            selectedBook['chapter'] ?? '',
                            selectedBook['text'] ?? '',
                            next,
                          );
                        }
                      : null,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isHighlighted ? const Color(0xFFFFF8DC) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isHighlighted ? const Color(0xFF00875A) : Colors.grey.shade200,
                        width: isHighlighted ? 1.6 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isHighlighted)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              '👈 موضع الشرح الحالي',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily: 'Dubai',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00875A),
                              ),
                            ),
                          ),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            lines[idx],
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: _fontSize - 2,
                              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                              height: 1.9,
                              color: isHighlighted ? const Color(0xFF005F3F) : const Color(0xFF191919),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
