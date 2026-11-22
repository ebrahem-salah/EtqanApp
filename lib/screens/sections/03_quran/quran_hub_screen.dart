import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../call/live_recitation_room.dart';
import '../dialogs/create_section_session_dialog.dart';

class QuranHubScreen extends StatefulWidget {
  final String? initialSubSection;
  const QuranHubScreen({super.key, this.initialSubSection});

  @override
  State<QuranHubScreen> createState() => _QuranHubScreenState();
}

class _QuranHubScreenState extends State<QuranHubScreen> {
  late String _selectedSub;

  final List<Map<String, dynamic>> _subSections = [
    {
      'title': 'المقرأة',
      'icon': '📖',
      'badge': 'مقارئ مستمرة',
      'desc': 'مقارئ جماعية لتلاوة القرآن آناء الليل وأطراف النهار بإشراف كبار المقرئين.',
    },
    {
      'title': 'المدارسة',
      'icon': '🤝',
      'badge': 'تدبر وتفاهم',
      'desc': 'مجالس المدارسة القرآنية وتدبر معاني الآيات واستخراج اللطائف والهدايات.',
    },
    {
      'title': 'الحفظ (الصغار)',
      'icon': '👶',
      'badge': 'براعم القرآن',
      'desc': 'منهج تحفيظ ميسر للصغار مع التحفيز والمتابعة اليومية والتلقين المباشر.',
    },
    {
      'title': 'الحفظ (الكبار)',
      'icon': '🧔',
      'badge': 'مسارات منهجية',
      'desc': 'مسارات حفظ مرنة للكبار بنظام ربع حزب أو نصف حزب أسبوعياً مع التسميع.',
    },
    {
      'title': 'المراجعة (ثلاثون جزء)',
      'icon': '🔄',
      'badge': 'تثبيت الحفظ',
      'desc': 'مسار مراجعة وتثبيت القرآن الكريم كاملاً مقسماً على الأجزاء الثلاثين.',
    },
    {
      'title': 'المراجعة (فمي بشوق)',
      'icon': '✨',
      'badge': 'التحزيب النبوي',
      'desc': 'المراجعة الأسبوعية على طريقة الصحابة (فمي بشوق): الفاتحة، المائدة، يونس، بني إسرائيل، الشعراء، الصافات، والمفصل.',
    },
    {
      'title': 'التجويد',
      'icon': '🎵',
      'badge': 'تصحيح المخارج',
      'desc': 'حلقات تصحيح التلاوة العملية وتطبيق أحكام النون والميم والمدود والصفات.',
    },
    {
      'title': 'علوم القرآن',
      'icon': '📜',
      'badge': 'معارف الوحي',
      'desc': 'أسباب النزول، الوقف والابتداء، المكي والمدني، عد الآي ورسم المصحف.',
    },
    {
      'title': 'القراءات العشر',
      'icon': '🌟',
      'badge': 'الصغرى والكبرى',
      'desc': 'حلقات الجمع والإفراد للقراءات العشر المتواترة من طريقي الشاطبية والدرة.',
    },
    {
      'title': 'المقامات الصوتية',
      'icon': '🎙️',
      'badge': 'تحسين الصوت',
      'desc': 'تعليم أصول الأداء الصوتي والمقامات القرآنية (بيات، رست، نهاوند، سيكاه، صبا، حجاز) المنضبطة بالتجويد.',
    },
    {
      'title': 'التفسير',
      'icon': '💡',
      'badge': 'معاني الآيات',
      'desc': 'حلقات تفسير وتدبر كلام الله عز وجل مع نخبة من أساتذة التفسير المعتمدين.',
    },
    {
      'title': 'القراءة بالإسناد',
      'icon': '📜',
      'badge': 'الإجازة والسند',
      'desc': 'عرض القرآن الكريم كاملاً غيباً لنيل الإجازة بالسند المتصل إلى رسول الله ﷺ.',
    },
  ];

  // Dummy active circles mapped to subsections
  final List<Map<String, dynamic>> _circles = [
    {
      'id': 'q_1',
      'title': 'مقرأة ترتيل سورة النساء وتصحيح التلاوة',
      'sub': 'المقرأة',
      'sheikh': 'فضيلة الشيخ أحمد عبد المنعم',
      'students': '18 / 25',
      'isLive': true,
      'viewers': 148,
    },
    {
      'id': 'q_2',
      'title': 'حلقة مدارسة وتدبر سورة يس والواقعة',
      'sub': 'المدارسة',
      'sheikh': 'د. عبد الله المصلح',
      'students': '12 / 20',
      'isLive': true,
      'viewers': 89,
    },
    {
      'id': 'q_3',
      'title': 'حلقة تحفيظ جزء عم للأطفال بالرسم العثماني',
      'sub': 'الحفظ (الصغار)',
      'sheikh': 'المقرئ الشيخ عمر خالد',
      'students': '15 / 15',
      'isLive': false,
      'viewers': 0,
    },
    {
      'id': 'q_4',
      'title': 'ختمة فمي بشوق الأسبوعية - حزب سورة يونس',
      'sub': 'المراجعة (فمي بشوق)',
      'sheikh': 'الشيخ محمد سعيد نور',
      'students': '22 / 30',
      'isLive': true,
      'viewers': 110,
    },
    {
      'id': 'q_5',
      'title': 'مجلس إقراء برواية ورش عن نافع من طريق الأزرق',
      'sub': 'القراءات العشر',
      'sheikh': 'المقرئ الشيخ مصطفى الهواري',
      'students': '8 / 10',
      'isLive': true,
      'viewers': 64,
    },
    {
      'id': 'q_6',
      'title': 'مجلس عرض القرآن بالسند المتصل برواية حفص',
      'sub': 'القراءة بالإسناد',
      'sheikh': 'فضيلة الشيخ د. أيمن سويد',
      'students': '5 / 6',
      'isLive': true,
      'viewers': 220,
    },
    {
      'id': 'q_7',
      'title': 'دورة أداء مقام الرست والنهاوند في التلاوة',
      'sub': 'المقامات الصوتية',
      'sheikh': 'المنشد والمقرئ محمود التوني',
      'students': '30 / 40',
      'isLive': false,
      'viewers': 0,
    },
  ];

  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _selectedSub = widget.initialSubSection ?? 'المقرأة';
    _loadLiveBackendCircles();
  }

  Future<void> _loadLiveBackendCircles() async {
    try {
      final res = await _apiClient.getClasses();
      if (res.statusCode == 200 && res.data != null) {
        final List items = res.data['data'] ?? [];
        if (items.isNotEmpty) {
          final liveList = items.map<Map<String, dynamic>>((item) {
            final sheikh = item['sheikh'] ?? item['creator'] ?? {};
            final sheikhName = sheikh['name'] ?? 'الشيخ عبد الله الرويلي';
            final isOngoing = item['status'] == 'ongoing' || item['is_ongoing'] == true;
            return {
              'id': 'backend_${item['id']}',
              'title': item['name'] ?? 'مقرأة قرآنية حية ومباشرة',
              'sub': item['category']?['name'] ?? 'المقرأة',
              'sheikh': sheikhName,
              'students': '${item['students_count'] ?? 1} / ${item['capacity'] ?? 30}',
              'isLive': isOngoing,
              'viewers': item['views_count'] ?? 85,
            };
          }).toList();

          if (mounted) {
            setState(() {
              _circles.insertAll(0, liveList);
            });
          }
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final filteredCircles = _circles.where((c) {
      if (_selectedSub == 'الكل') return true;
      return c['sub'] == _selectedSub;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'القرآن الكريم',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'إنشاء حلقة جديدة',
            onPressed: () {
              CreateSectionSessionDialog.show(
                context,
                initialSection: 'القرآن الكريم',
                initialSubSection: _selectedSub,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Subsections Horizontal Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: _subSections.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isAll = _selectedSub == 'الكل';
                    return FilterChip(
                      selected: isAll,
                      label: const Text('جميع الفروع (11)', style: TextStyle(fontFamily: 'Dubai', fontSize: 12)),
                      selectedColor: const Color(0xFF00875A),
                      labelStyle: TextStyle(
                        fontFamily: 'Dubai',
                        color: isAll ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => setState(() => _selectedSub = 'الكل'),
                    );
                  }
                  final sub = _subSections[index - 1];
                  final isSelected = _selectedSub == sub['title'];
                  return FilterChip(
                    selected: isSelected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(sub['icon'] ?? '📖', style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(sub['title'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 12)),
                      ],
                    ),
                    selectedColor: const Color(0xFF00875A),
                    labelStyle: TextStyle(
                      fontFamily: 'Dubai',
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => setState(() => _selectedSub = sub['title']),
                  );
                },
              ),
            ),
          ),

          // Header description for selected subsection
          if (_selectedSub != 'الكل') ...[
            Builder(builder: (context) {
              final currentSub = _subSections.firstWhere((s) => s['title'] == _selectedSub, orElse: () => _subSections.first);
              return Container(
                margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  children: [
                    Text(currentSub['icon'], style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentSub['title'],
                            style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF00875A)),
                          ),
                          Text(
                            currentSub['desc'],
                            style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Circles List
          Expanded(
            child: filteredCircles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text(
                          'لا توجد حلقات جارية حالياً في $_selectedSub',
                          style: const TextStyle(fontFamily: 'Dubai', fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00875A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            CreateSectionSessionDialog.show(
                              context,
                              initialSection: 'القرآن الكريم',
                              initialSubSection: _selectedSub == 'الكل' ? 'المقرأة' : _selectedSub,
                            );
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'كن أول من ينشئ حلقة هنا',
                            style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: filteredCircles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final circle = filteredCircles[index];
                      return _buildCircleCard(circle);
                    },
                  ),
          ),
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
        onPressed: () {
          CreateSectionSessionDialog.show(
            context,
            initialSection: 'القرآن الكريم',
            initialSubSection: _selectedSub == 'الكل' ? 'المقرأة' : _selectedSub,
          );
        },
      ),
    );
  }

  Widget _buildCircleCard(Map<String, dynamic> circle) {
    final bool isLive = circle['isLive'] == true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isLive ? Border.all(color: const Color(0xFFE53935).withOpacity(0.4), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Section Badge & Live Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00875A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    circle['sub'],
                    style: const TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00875A),
                    ),
                  ),
                ),
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: Colors.white, size: 8),
                        const SizedBox(width: 4),
                        Text(
                          'مباشر (${circle['viewers']})',
                          style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              circle['title'],
              style: const TextStyle(
                fontFamily: 'Dubai',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191919),
              ),
            ),
            const SizedBox(height: 6),

            // Sheikh Name
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  circle['sheikh'],
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.group_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  circle['students'],
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLive ? const Color(0xFFE53935) : const Color(0xFF00875A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LiveRecitationRoom(
                        roomId: circle['id'],
                        circleTitle: circle['title'],
                        isSheikh: false,
                      ),
                    ),
                  );
                },
                icon: Icon(isLive ? Icons.play_arrow_rounded : Icons.login_rounded, color: Colors.white),
                label: Text(
                  isLive ? 'انضم للبث المباشر الآن' : 'دخول قاعة الحلقة',
                  style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
