import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MuslimChildScreen extends StatefulWidget {
  const MuslimChildScreen({super.key});

  @override
  State<MuslimChildScreen> createState() => _MuslimChildScreenState();
}

class _MuslimChildScreenState extends State<MuslimChildScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['قصص القرآن والسيرة', 'آداب الطفل المسلم', 'أحاديث وأذكار البراعم'];

  final List<Map<String, dynamic>> _stories = [
    {
      'title': 'قصة سفينة نوح عليه السلام والحيوانات',
      'desc': 'كيف صنع نبي الله نوح السفينة بأمر الله، وحمل فيها من كل زوجين اثنين، ونجاة المؤمنين.',
      'lesson': 'طاعة الله والصبر على الحق',
      'icon': '🚢',
      'color': const Color(0xFF0288D1),
    },
    {
      'title': 'قصة نبي الله يوسف عليه السلام والقميص',
      'desc': 'رؤيا يوسف الصغير، وبئر الإخوة، وصبره في مصر حتى مكنه الله وأصبح عزيز مصر.',
      'lesson': 'حسن الظن بالله والعفو عند المقدرة',
      'icon': '👑',
      'color': const Color(0xFF7B1FA2),
    },
    {
      'title': 'قصة أصحاب الأخدود والغلام المؤمن',
      'desc': 'شجاعة الغلام الذكي وإيمانه القوي الذي جعل أهل المدينة جميعاً يشهدون أن لا إله إلا الله.',
      'lesson': 'الثبات على الإيمان والشجاعة',
      'icon': '🌟',
      'color': const Color(0xFFF57C00),
    },
  ];

  final List<Map<String, dynamic>> _manners = [
    {
      'title': 'أدب الطعام والشراب',
      'detail': '«يَا غُلامُ، سَمِّ اللَّهَ، وَكُلْ بِيَمِينِكَ، وَكُلْ مِمَّا يَلِيكَ»',
      'icon': '🍎',
      'badge': 'سنة نبوية',
    },
    {
      'title': 'بر الوالدين والإحسان إليهما',
      'detail': 'خفض الجناح وطاعتهما بالمعروف، وتقبيل أيديهما والدعاء لهما: «رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا»',
      'icon': '❤️',
      'badge': 'أعظم القربات',
    },
    {
      'title': 'إفشاء السلام والابتسامة',
      'detail': '«تبسّمك في وجه أخيك صدقة»، والبدء بسلام الإسلام: «السلام عليكم ورحمة الله وبركاته»',
      'icon': '😊',
      'badge': 'أخلاق نبوية',
    },
    {
      'title': 'الصدق والأمانة',
      'detail': '«عليكم بالصدق؛ فإن الصدق يهدي إلى البر»، وكان النبي ﷺ يلقب في صغره بالصادق الأمين.',
      'icon': '💎',
      'badge': 'صفات المؤمن',
    },
  ];

  final List<Map<String, dynamic>> _adhkar = [
    {
      'title': 'دعاء الاستيقاظ من النوم',
      'text': '«الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ»',
      'icon': '☀️',
    },
    {
      'title': 'دعاء النوم',
      'text': '«بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي وَبِكَ أَرْفَعُهُ، إِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ»',
      'icon': '🌙',
    },
    {
      'title': 'أذكار الصباح والمساء للبراعم',
      'text': '«أَصْبَحْنَا عَلَى فِطْرَةِ الإِسْلامِ، وَعَلَى كَلِمَةِ الإِخْلاصِ، وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ ﷺ»',
      'icon': '✨',
    },
    {
      'title': 'دعاء دخول وخروج المنزل',
      'text': '«بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ، وَلا حَوْلَ وَلا قُوَّةَ إِلا بِاللَّهِ»',
      'icon': '🏡',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
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
          'الطفل المسلم (قصص، آداب، أذكار)',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Stories
          _buildStoriesView(),
          // 2. Manners
          _buildMannersView(),
          // 3. Adhkar
          _buildAdhkarView(),
        ],
      ),
    );
  }

  Widget _buildStoriesView() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _stories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, idx) {
        final story = _stories[idx];
        final Color col = story['color'] as Color;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: col.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(story['icon'] ?? '📖', style: const TextStyle(fontSize: 26))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      story['title'],
                      style: const TextStyle(fontFamily: 'Dubai', fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                story['desc'],
                style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade700, height: 1.4),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: Color(0xFF00875A)),
                    const SizedBox(width: 4),
                    Text(
                      'العبرة: ${story['lesson']}',
                      style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00875A)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMannersView() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _manners.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final m = _manners[idx];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: Text(m['icon'], style: const TextStyle(fontSize: 30)),
            title: Text(m['title'], style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(m['detail'], style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade700)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdhkarView() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _adhkar.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final a = _adhkar[idx];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(a['icon'], style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(a['title'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF00875A))),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                a['text'],
                style: const TextStyle(fontFamily: 'Dubai', fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }
}
