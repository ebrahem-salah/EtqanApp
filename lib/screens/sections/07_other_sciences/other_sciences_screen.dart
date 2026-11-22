import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../call/live_recitation_room.dart';
import '../dialogs/create_section_session_dialog.dart';

class OtherSciencesScreen extends StatefulWidget {
  final String? initialScience;
  const OtherSciencesScreen({super.key, this.initialScience});

  @override
  State<OtherSciencesScreen> createState() => _OtherSciencesScreenState();
}

class _OtherSciencesScreenState extends State<OtherSciencesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _sciences = ['الفقه', 'السيرة النبوية', 'العقيدة', 'الرقائق'];

  final List<Map<String, dynamic>> _lessons = [
    {
      'id': 'sci_1',
      'title': 'فقه المعاملات المالية المعاصرة وأحكام البيوع',
      'science': 'الفقه',
      'scholar': 'فضيلة الشيخ د. يوسف الشبيلي',
      'desc': 'أحكام التجارة الإلكترونية، الأسهم، المعاملات البنكية، والعملات الرقمية وفق موازين الشريعة.',
      'lessonsCount': '16 درساً',
      'isLive': true,
      'viewers': 165,
      'icon': '⚖️',
    },
    {
      'id': 'sci_2',
      'title': 'فقه الطهارة والصلاة الميسر للمسلمين الجدد والناشئة',
      'science': 'الفقه',
      'scholar': 'د. عبد الله بن منصور',
      'desc': 'بيان صفة وضوء وصلاة النبي ﷺ مع الأدلة والتطبيقات المرئية.',
      'lessonsCount': '10 دروس',
      'isLive': false,
      'viewers': 0,
      'icon': '🕌',
    },
    {
      'id': 'sci_3',
      'title': 'الرحيق المختوم: في سيرة خير الأنام ﷺ',
      'science': 'السيرة النبوية',
      'scholar': 'الشيخ د. عائض القرني',
      'desc': 'دراسة تفصيلية لحياة النبي ﷺ من المولد الشريف حتى الوفاة مع استنباط الدروس والعبر.',
      'lessonsCount': '24 مجلساً',
      'isLive': true,
      'viewers': 410,
      'icon': '📜',
    },
    {
      'id': 'sci_4',
      'title': 'شرح العقيدة الواسطية لشيخ الإسلام ابن تيمية',
      'science': 'العقيدة',
      'scholar': 'الشيخ صالح بن فوزان الفوزان',
      'desc': 'بيان منهج أهل السنة والجماعة في أسماء الله وصفاته واليوم الآخر والقدر.',
      'lessonsCount': '18 مجلساً',
      'isLive': false,
      'viewers': 0,
      'icon': '🛡️',
    },
    {
      'id': 'sci_5',
      'title': 'مدارج السالكين بين منازل إياك نعبد وإياك نستعين',
      'science': 'الرقائق',
      'scholar': 'د. محمد راتب النابلسي',
      'desc': 'رحلة إيمانية في تزكية النفس ومنازل الخشوع والتوبة والرضا والمحبة.',
      'lessonsCount': '30 حلقة',
      'isLive': true,
      'viewers': 290,
      'icon': '❤️',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sciences.length, vsync: this);
    if (widget.initialScience != null) {
      final idx = _sciences.indexOf(widget.initialScience!);
      if (idx != -1) _tabController.index = idx;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'علوم أخرى (الفقه، السيرة، العقيدة، الرقائق)',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'إنشاء مجلس علمي',
            onPressed: () {
              CreateSectionSessionDialog.show(
                context,
                initialSection: 'علوم أخرى',
                initialSubSection: _sciences[_tabController.index],
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _sciences.map((s) => Tab(text: s)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _sciences.map((science) {
          final items = _lessons.where((l) => l['science'] == science).toList();
          if (items.isEmpty) {
            return Center(
              child: Text('لا توجد مجالس حالياً في $science', style: const TextStyle(fontFamily: 'Dubai', color: Colors.grey)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final lesson = items[index];
              final bool isLive = lesson['isLive'] == true;

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
                            lesson['science'],
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
                                  'درس مباشر (${lesson['viewers']})',
                                  style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lesson['title'],
                      style: const TextStyle(fontFamily: 'Dubai', fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'المحاضر: ${lesson['scholar']} • ${lesson['lessonsCount']}',
                      style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lesson['desc'],
                      style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade700, height: 1.4),
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
                                roomId: lesson['id'],
                                circleTitle: lesson['title'],
                                isSheikh: false,
                              ),
                            ),
                          );
                        },
                        icon: Icon(isLive ? Icons.play_arrow_rounded : Icons.menu_book, color: Colors.white),
                        label: Text(
                          isLive ? 'الانضمام للبث المباشر للدرس' : 'الاستماع ومتابعة المنهج',
                          style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('إنشاء مجلس علمي / بث مباشر', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold)),
        onPressed: () {
          CreateSectionSessionDialog.show(
            context,
            initialSection: 'علوم أخرى',
            initialSubSection: _sciences[_tabController.index],
          );
        },
      ),
    );
  }
}
