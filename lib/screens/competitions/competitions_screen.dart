import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import 'widgets/competition_exam_sheet.dart';

class CompetitionsScreen extends StatefulWidget {
  const CompetitionsScreen({super.key});

  @override
  State<CompetitionsScreen> createState() => _CompetitionsScreenState();
}

class _CompetitionsScreenState extends State<CompetitionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;

  // قائمة المسابقات من قاعدة بيانات وتصميم الصورة 16
  final List<Map<String, dynamic>> _competitions = [
    {
      'id': 101,
      'title': 'مسابقة المجد',
      'date': '02:35PM - 25/10/2026',
      'duration': '00:10:00',
      'subscribers_count': 1,
      'max_subscribers': 5,
      'status': 'finished', // finished, ongoing, waiting
      'sheikh_name': 'sheikh saad ali',
      'sheikh_avatar': '',
      'institution_name': 'مؤسسة التعاون',
    },
    {
      'id': 102,
      'title': 'مسابقة العمالقة',
      'date': '02:15PM - 25/10/2026',
      'duration': '00:10:00',
      'subscribers_count': 1,
      'max_subscribers': 5,
      'status': 'finished',
      'sheikh_name': 'saad ali',
      'sheikh_avatar': '',
      'institution_name': 'مؤسسة التعاون',
    },
    {
      'id': 103,
      'title': 'Moahmed test',
      'date': '12:45AM - 11/04/2026',
      'duration': '00:15:00',
      'subscribers_count': 0,
      'max_subscribers': 15,
      'status': 'finished',
      'sheikh_name': 'شيخ محمد',
      'sheikh_avatar': '',
      'institution_name': 'مؤسسة محمد التعليمية',
    },
    {
      'id': 104,
      'title': 'مسابقة حفظ جزء عم للناشئة',
      'date': '06:00PM - 21/11/2026',
      'duration': '00:20:00',
      'subscribers_count': 3,
      'max_subscribers': 10,
      'status': 'ongoing',
      'sheikh_name': 'الشيخ عبد الله السويسي',
      'sheikh_avatar': '',
      'institution_name': 'مؤسسة إتقان العالمية',
    },
    {
      'id': 105,
      'title': 'مسابقة فرسان التجويد الكبرى',
      'date': '08:00PM - 22/11/2026',
      'duration': '00:30:00',
      'subscribers_count': 2,
      'max_subscribers': 8,
      'status': 'waiting',
      'sheikh_name': 'الشيخ أحمد نور الدين',
      'sheikh_avatar': '',
      'institution_name': 'مؤسسة إتقان العالمية',
    },
  ];

  @override
  void initState() {
    super.initState();
    // 3 Tabs matching Screenshot 16: المنتهية (0) | الجارية (1) | في الانتظار (2)
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _shareCompetition(Map<String, dynamic> comp) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ رابط ${comp['title']} بنجاح للمشاركة! 📋',
            style: const TextStyle(fontFamily: 'Dubai')),
        backgroundColor: const Color(0xFF00875A),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openCompetitionExam(Map<String, dynamic> comp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CompetitionExamSheet(
        competitionId: comp['id'] ?? 1,
        studentId: 1,
        studentName: 'الطالب المتسابق',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // الخلفية الكريمية الرسمية من الصورة 16
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
          'المسابقات',
          style: TextStyle(
            fontFamily: 'Dubai',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191919),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // 3 Tabs matching Screenshot 16: [المنتهية] [الجارية] [في الانتظار]
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF00875A), // اللون الأخضر التفاعلي من الصورة 16
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black87,
              labelStyle: const TextStyle(
                fontFamily: 'Dubai',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Dubai',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'المنتهية'),
                Tab(text: 'الجارية'),
                Tab(text: 'في الانتظار'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // محتوى التابات
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCompetitionsList('finished'),
                _buildCompetitionsList('ongoing'),
                _buildCompetitionsList('waiting'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitionsList(String filterStatus) {
    final list = _competitions.where((c) => c['status'] == filterStatus).toList();

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'لا توجد مسابقات في هذا القسم حالياً',
              style: TextStyle(
                fontFamily: 'Dubai',
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final comp = list[index];
        return _buildCompetitionCard(comp);
      },
    );
  }

  // بطاقة المسابقة المتطابقة بكسل ببكسل مع الصورة 16 (Screenshot 16)
  Widget _buildCompetitionCard(Map<String, dynamic> comp) {
    final isFinished = comp['status'] == 'finished';
    final isOngoing = comp['status'] == 'ongoing';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Row: Share Button (left) & Date/Time (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Share Button (دائرة بمحيط رمادي وأيقونة خضراء)
              GestureDetector(
                onTap: () => _shareCompetition(comp),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                  ),
                  child: const Center(
                    child: Icon(Icons.share_outlined, color: Color(0xFF00875A), size: 18),
                  ),
                ),
              ),

              // Date & Time
              Text(
                comp['date'],
                style: TextStyle(
                  fontFamily: 'Dubai',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // 2. Competition Title
          Text(
            comp['title'],
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Dubai',
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191919),
            ),
          ),

          const SizedBox(height: 6),

          // 3. Duration Row: الساعة + مدة المسابقة
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'مدة المسابقة: ${comp['duration']}',
                style: const TextStyle(
                  fontFamily: 'Dubai',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191919),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF191919)),
            ],
          ),

          const SizedBox(height: 12),

          // 4. Badges Row: [انتهت] (left) & [المشتركين 1 / 5] (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                  color: isFinished
                      ? const Color(0xFFEEEEEE)
                      : (isOngoing ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isFinished ? 'انتهت' : (isOngoing ? 'جارية الان' : 'في الانتظار'),
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isFinished
                        ? Colors.grey.shade600
                        : (isOngoing ? const Color(0xFF00875A) : Colors.orange.shade800),
                  ),
                ),
              ),

              // Subscribers Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  children: [
                    Text(
                      'المشتركين ${comp['subscribers_count']} / ${comp['max_subscribers']}',
                      style: const TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00875A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.person_outline, size: 16, color: Color(0xFF00875A)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 5. Bottom Row: [مؤسسة التعاون] (left) & Sheikh Name + Avatar (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Institution Pill (left)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF81C784)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.business_rounded, size: 15, color: Color(0xFF00875A)),
                    const SizedBox(width: 6),
                    Text(
                      comp['institution_name'],
                      style: const TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00875A),
                      ),
                    ),
                  ],
                ),
              ),

              // Sheikh Info (right)
              GestureDetector(
                onTap: () => _openCompetitionExam(comp),
                child: Row(
                  children: [
                    Text(
                      comp['sheikh_name'],
                      style: const TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191919),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                      ),
                      child: const Center(
                        child: Icon(Icons.person, color: Colors.grey, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
