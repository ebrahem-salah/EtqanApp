import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../call/live_recitation_room.dart';
import '../dialogs/create_section_session_dialog.dart';

class SunnahHubScreen extends StatefulWidget {
  final String? initialSubSection;
  const SunnahHubScreen({super.key, this.initialSubSection});

  @override
  State<SunnahHubScreen> createState() => _SunnahHubScreenState();
}

class _SunnahHubScreenState extends State<SunnahHubScreen> {
  late String _selectedSub;

  final List<Map<String, dynamic>> _subSections = [
    {
      'title': 'الحفظ (الصغار)',
      'icon': '👶',
      'desc': 'حفظ الأربعين النووية وجوامع الكلم النبوي الشريف للناشئة مع شرح المعاني.',
    },
    {
      'title': 'الحفظ (الكبار)',
      'icon': '🧔',
      'desc': 'مسارات حفظ عمدة الأحكام، بلوغ المرام، ومتون الحديث المعتمدة.',
    },
    {
      'title': 'علوم الحديث',
      'icon': '📜',
      'desc': 'مصطلح الحديث، المنظومة البيقونية، نزهة النظر، الجرح والتعديل، وعلل الحديث.',
    },
    {
      'title': 'شروح الأحاديث',
      'icon': '💡',
      'desc': 'مجالس شرح صحيح البخاري ومسلم وسنن أبي داود والترمذي والنسائي وابن ماجه.',
    },
    {
      'title': 'الإقراء لكتب السنة',
      'icon': '📚',
      'desc': 'مجالس سماع وقراءة الكتب الستة والمساند والموطأ مع كبار المحدثين.',
    },
    {
      'title': 'القراءة بالإسناد',
      'icon': '🌟',
      'desc': 'مجالس الرواية والسماع بالإسناد المتصل العالي إلى رسول الله ﷺ.',
    },
  ];

  final List<Map<String, dynamic>> _sunnahCircles = [
    {
      'id': 's_1',
      'title': 'مجلس سماع وإقراء صحيح البخاري بالسند المتصل',
      'sub': 'القراءة بالإسناد',
      'scholar': 'العلامة المحدث د. عبد الكريم الخضير',
      'students': '45 / 50',
      'isLive': true,
      'viewers': 310,
    },
    {
      'id': 's_2',
      'title': 'شرح كتاب الإيمان من صحيح مسلم',
      'sub': 'شروح الأحاديث',
      'scholar': 'فضيلة الشيخ د. عثمان الخميس',
      'students': '80 / 100',
      'isLive': true,
      'viewers': 520,
    },
    {
      'id': 's_3',
      'title': 'حفظ الأربعين النووية للبراعم - الحديث الخامس عشر',
      'sub': 'الحفظ (الصغار)',
      'scholar': 'الشيخ محمد سعيد إبراهيم',
      'students': '20 / 20',
      'isLive': false,
      'viewers': 0,
    },
    {
      'id': 's_4',
      'title': 'دراسة المنظومة البيقونية في علم مصطلح الحديث',
      'sub': 'علوم الحديث',
      'scholar': 'د. حمزة المليباري',
      'students': '32 / 40',
      'isLive': false,
      'viewers': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedSub = widget.initialSubSection ?? 'شروح الأحاديث';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _sunnahCircles.where((c) {
      if (_selectedSub == 'الكل') return true;
      return c['sub'] == _selectedSub;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'السنة النبوية الشريفة',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'إنشاء مجلس حديث',
            onPressed: () {
              CreateSectionSessionDialog.show(
                context,
                initialSection: 'السنة النبوية',
                initialSubSection: _selectedSub == 'الكل' ? 'شروح الأحاديث' : _selectedSub,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Subsections horizontal filter
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
                      label: const Text('جميع الفروع (6)', style: TextStyle(fontFamily: 'Dubai', fontSize: 12)),
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
                        Text(sub['icon'] ?? '📜', style: const TextStyle(fontSize: 12)),
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

          // Circles list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book, size: 48, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text(
                          'لا توجد مجالس حالية في $_selectedSub',
                          style: const TextStyle(fontFamily: 'Dubai', fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00875A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            CreateSectionSessionDialog.show(
                              context,
                              initialSection: 'السنة النبوية',
                              initialSubSection: _selectedSub == 'الكل' ? 'شروح الأحاديث' : _selectedSub,
                            );
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'إنشاء مجلس جديد',
                            style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final bool isLive = item['isLive'] == true;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: isLive ? Border.all(color: const Color(0xFFE53935).withOpacity(0.5), width: 1.5) : null,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                    item['sub'],
                                    style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00875A)),
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
                                        const Icon(Icons.circle, color: Colors.white, size: 7),
                                        const SizedBox(width: 4),
                                        Text(
                                          'بث مباشر (${item['viewers']})',
                                          style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item['title'],
                              style: const TextStyle(fontFamily: 'Dubai', fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'المحدث: ${item['scholar']} • الطلاب: ${item['students']}',
                              style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 12),
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
                                        roomId: item['id'],
                                        circleTitle: item['title'],
                                        isSheikh: false,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(isLive ? Icons.play_arrow_rounded : Icons.login_rounded, color: Colors.white),
                                label: Text(
                                  isLive ? 'الانضمام لمجلس السماع المباشر' : 'دخول المجلس',
                                  style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('إنشاء مجلس حديث / بث مباشر', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold)),
        onPressed: () {
          CreateSectionSessionDialog.show(
            context,
            initialSection: 'السنة النبوية',
            initialSubSection: _selectedSub == 'الكل' ? 'شروح الأحاديث' : _selectedSub,
          );
        },
      ),
    );
  }
}
