import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../dialogs/create_section_session_dialog.dart';

class NouraniaHubScreen extends StatefulWidget {
  const NouraniaHubScreen({super.key});

  @override
  State<NouraniaHubScreen> createState() => _NouraniaHubScreenState();
}

class _NouraniaHubScreenState extends State<NouraniaHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedLessonIndex = 0;
  bool _isPlayingAudio = false;
  String _activeLetter = 'أ';

  final List<String> _levels = [
    'المستوى الأول (الحروف المفردة)',
    'المستوى الثاني (المركبة والمدود)',
    'المستوى الثالث (أحكام التجويد)',
  ];

  final List<String> _letters = [
    'أ', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر',
    'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ع', 'غ', 'ف',
    'ق', 'ك', 'ل', 'م', 'ن', 'هـ', 'و', 'ي'
  ];

  final List<Map<String, dynamic>> _level1Lessons = [
    {
      'title': 'الدرس الأول: الحروف الهجائية المفردة',
      'desc': 'التعرف على أسماء الحروف ومخارجها الصحيحة من الحلق واللسان والشفتين.',
      'count': '28 حرفاً',
      'icon': '🔤',
    },
    {
      'title': 'الدرس الثاني: الحركات الثلاث (الفتحة، الكسرة، الضمة)',
      'desc': 'نطق الحرف بالحركة دون زيادة زمنية لمنع تولد حروف المد.',
      'count': '84 حالة صوتية',
      'icon': '🗣️',
    },
    {
      'title': 'الدرس الثالث: التنوين (تنوين الفتح، الكسر، الضم)',
      'desc': 'نطق نون التنوين الساكنة وصلاً لا وقفاً بطريقة القاعدة النورانية.',
      'count': '28 صوتاً',
      'icon': '✨',
    },
  ];

  final List<Map<String, dynamic>> _level2Lessons = [
    {
      'title': 'الدرس الرابع: الحروف الهجائية المركبة',
      'desc': 'أشكال الحروف في أول الكلمة ووسطها وآخرها والتمييز بين المتشابهات.',
      'count': '42 تركيباً',
      'icon': '🧩',
    },
    {
      'title': 'الدرس الخامس: حروف المد الثلاثة وحروف اللين',
      'desc': 'الألف الساكنة المفتوح ما قبلها، والواو والياء الساكنتان وتطبيق المد الطبيعي حركتين.',
      'count': '18 تدريباً',
      'icon': '〰️',
    },
    {
      'title': 'الدرس السادس: السكون وتدريبات الوصل',
      'desc': 'نطق الحرف الساكن بالاعتماد على الحرف المتحرك قبله مع بيان القلقلة والهمس.',
      'count': '35 كلمة نموذجية',
      'icon': '⚓',
    },
  ];

  final List<Map<String, dynamic>> _level3Lessons = [
    {
      'title': 'الدرس السابع: الشدة وأحكام الحرف المشدد',
      'desc': 'تفكيك الحرف المشدد إلى ساكن ومتحرك مع إعطاء الغنة في النون والميم المشددتين.',
      'count': '30 تدريباً',
      'icon': '⚡',
    },
    {
      'title': 'الدرس الثامن: أحكام النون الساكنة والتنوين عملياً',
      'desc': 'تطبيق الإظهار والإدغام والإقلاب والإخفاء عبر تهجي القاعدة النورانية المعتمد.',
      'count': '40 مثالاً قرآنياً',
      'icon': '📜',
    },
    {
      'title': 'الدرس التاسع: أحكام المدود ورسم المصحف',
      'desc': 'المد المتصل، المنفصل، العارض للسكون، والمد اللازم الكلمي والحرفي.',
      'count': 'ختام النورانية',
      'icon': '🎓',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _levels.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _playLetter(String letter) {
    setState(() {
      _activeLetter = letter;
      _isPlayingAudio = true;
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _isPlayingAudio = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'القاعدة النورانية وتعليم الحروف',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'إنشاء حلقة نورانية',
            onPressed: () {
              CreateSectionSessionDialog.show(
                context,
                initialSection: 'تعليم الحروف والقاعدة النورانية',
                initialSubSection: 'المستوى الأول (الحروف المفردة)',
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _levels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Letter Audio Sound Board
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.volume_up_rounded, color: Color(0xFF00875A), size: 20),
                        const SizedBox(width: 6),
                        const Text(
                          'لوحة نطق مخارج الحروف:',
                          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    if (_isPlayingAudio)
                      Row(
                        children: [
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00875A)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'نطق حرف ($_activeLetter)...',
                            style: const TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Color(0xFF00875A), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _letters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, idx) {
                      final l = _letters[idx];
                      final isSelected = _activeLetter == l;
                      return InkWell(
                        onTap: () => _playLetter(l),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 44,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF00875A) : const Color(0xFFF1F8E9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF00875A) : const Color(0xFFC8E6C9),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              l,
                              style: TextStyle(
                                fontFamily: 'Dubai',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Levels View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLessonsList(_level1Lessons, 'المستوى الأول: الحروف المفردة وحركاتها'),
                _buildLessonsList(_level2Lessons, 'المستوى الثاني: الحروف المركبة والمدود'),
                _buildLessonsList(_level3Lessons, 'المستوى الثالث: أحكام التجويد العملية'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00875A),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            CreateSectionSessionDialog.show(
              context,
              initialSection: 'تعليم الحروف والقاعدة النورانية',
              initialSubSection: _levels[_tabController.index],
            );
          },
          icon: const Icon(Icons.video_call_rounded, color: Colors.white),
          label: const Text(
            'حجز أو بدء حلقة نورانية مباشرة مع شيخ مجاز',
            style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonsList(List<Map<String, dynamic>> lessons, String levelSubtitle) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Level Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00875A), Color(0xFF00695C)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.school_rounded, color: Colors.white, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      levelSubtitle,
                      style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'منهج معتمد ومصرح به من كبار قراء العالم الإسلامي',
                      style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        ...lessons.asMap().entries.map((entry) {
          final idx = entry.key;
          final lesson = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(lesson['icon'] ?? '📖', style: const TextStyle(fontSize: 22)),
                ),
              ),
              title: Text(
                lesson['title'],
                style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(lesson['desc'], style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      lesson['count'],
                      style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00875A)),
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF00875A)),
              onTap: () {
                _showLessonDetailModal(context, lesson);
              },
            ),
          );
        }),
      ],
    );
  }

  void _showLessonDetailModal(BuildContext context, Map<String, dynamic> lesson) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(lesson['icon'] ?? '📖', style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    lesson['title'],
                    style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(lesson['desc'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 13, height: 1.5)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00875A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  CreateSectionSessionDialog.show(
                    context,
                    initialSection: 'تعليم الحروف والقاعدة النورانية',
                    initialSubSection: lesson['title'],
                  );
                },
                icon: const Icon(Icons.play_circle_outline, color: Colors.white),
                label: const Text(
                  'بدء التدريب الفوري على هذا الدرس',
                  style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
