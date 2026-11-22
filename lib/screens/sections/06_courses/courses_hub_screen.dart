import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../call/live_recitation_room.dart';
import '../dialogs/create_section_session_dialog.dart';

class CoursesHubScreen extends StatefulWidget {
  const CoursesHubScreen({super.key});

  @override
  State<CoursesHubScreen> createState() => _CoursesHubScreenState();
}

class _CoursesHubScreenState extends State<CoursesHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _publicCourses = [
    {
      'id': 'c_pub_1',
      'title': 'الدورة التأصيلية في علم التجويد ومخارج الحروف',
      'instructor': 'فضيلة الشيخ المقرئ د. أحمد عيسى المعصراوي',
      'duration': '12 محاضرة (مباشرة ومسجلة)',
      'studentsCount': 850,
      'isLiveNow': true,
      'badge': 'دورة عامة مجانية',
      'icon': '🎓',
    },
    {
      'id': 'c_pub_2',
      'title': 'دورة مدخل إلى علوم الحديث ومناهج المحدثين',
      'instructor': 'أ.د. عبد الباري الأنصاري',
      'duration': '8 محاضرات',
      'studentsCount': 620,
      'isLiveNow': false,
      'badge': 'دورة عامة مجانية',
      'icon': '📜',
    },
    {
      'id': 'c_pub_3',
      'title': 'دورة فقه الصلاة وأحكام الطهارة الميسرة',
      'instructor': 'الشيخ د. عبد العزيز الفوزان',
      'duration': '10 محاضرات',
      'studentsCount': 1200,
      'isLiveNow': false,
      'badge': 'دورة عامة مجانية',
      'icon': '🕌',
    },
  ];

  final List<Map<String, dynamic>> _privateCourses = [
    {
      'id': 'c_priv_1',
      'title': 'الدبلوم المكثف في القراءات العشر الكبرى وتوجيهها',
      'instructor': 'هيئة كبار المقرئين بالأزهر والحرمين',
      'duration': '6 أشهر (متابعة أسبوعية فردية)',
      'studentsCount': 25,
      'maxStudents': 30,
      'isLiveNow': true,
      'badge': 'دورة علمية خاصة',
      'price': 'اشتراك خاص',
      'icon': '🌟',
    },
    {
      'id': 'c_priv_2',
      'title': 'برنامج الإقراء المتصل لكتب السنة الستة مع السند',
      'instructor': 'المحدث العلامة د. محمد الحسن الددو',
      'duration': '3 أشهر (مجالس سماع يومية)',
      'studentsCount': 40,
      'maxStudents': 50,
      'isLiveNow': false,
      'badge': 'دورة علمية خاصة',
      'price': 'اشتراك خاص',
      'icon': '🏆',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          'الدورات العلمية',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'إنشاء دورة علمية',
            onPressed: () {
              CreateSectionSessionDialog.show(
                context,
                initialSection: 'الدورات العلمية',
                initialSubSection: _tabController.index == 0 ? 'الدورات العلمية العامة' : 'الدورات العلمية الخاصة',
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
          labelStyle: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'الدورات العلمية العامة (مفتوحة)'),
            Tab(text: 'الدورات العلمية الخاصة (مكثفة)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCoursesList(_publicCourses, isPrivate: false),
          _buildCoursesList(_privateCourses, isPrivate: true),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.video_call_rounded),
        label: const Text('بث محاضرة دورة في الريلز', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold)),
        onPressed: () {
          CreateSectionSessionDialog.show(
            context,
            initialSection: 'الدورات العلمية',
            initialSubSection: _tabController.index == 0 ? 'الدورات العلمية العامة' : 'الدورات العلمية الخاصة',
          );
        },
      ),
    );
  }

  Widget _buildCoursesList(List<Map<String, dynamic>> list, {required bool isPrivate}) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final course = list[index];
        final bool isLive = course['isLiveNow'] == true;

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
                      color: isPrivate ? const Color(0xFFD4AF37).withOpacity(0.15) : const Color(0xFF00875A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      course['badge'],
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isPrivate ? const Color(0xFFB78103) : const Color(0xFF00875A),
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
                      child: const Row(
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 7),
                          SizedBox(width: 4),
                          Text('محاضرة حية الآن', style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                course['title'],
                style: const TextStyle(fontFamily: 'Dubai', fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'المحاضر: ${course['instructor']}',
                style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(course['duration'], style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade600)),
                  const Spacer(),
                  const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${course['studentsCount']} دارس', style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade600)),
                ],
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
                          roomId: course['id'],
                          circleTitle: course['title'],
                          isSheikh: false,
                        ),
                      ),
                    );
                  },
                  icon: Icon(isLive ? Icons.play_arrow_rounded : Icons.school_outlined, color: Colors.white),
                  label: Text(
                    isLive ? 'حضور البث المباشر للمحاضرة' : 'الالتحاق بالدورة وعرض المنهاج',
                    style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
