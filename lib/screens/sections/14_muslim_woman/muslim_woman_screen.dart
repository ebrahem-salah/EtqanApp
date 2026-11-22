import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MuslimWomanScreen extends StatefulWidget {
  const MuslimWomanScreen({super.key});

  @override
  State<MuslimWomanScreen> createState() => _MuslimWomanScreenState();
}

class _MuslimWomanScreenState extends State<MuslimWomanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'أحكام المرأة المسلمة',
    'آداب وسير الصالحات',
    'أعمال وبركات البيت المسلم',
  ];

  final List<Map<String, dynamic>> _ahkam = [
    {
      'title': 'فقه الطهارة والصلوات للمرأة',
      'desc': 'أحكام الحيض والنفاس والاستحاضة، وقضاء الصوم والصلاة وما يحل ويحرم بأسلوب فقهي ميسر وموثق.',
      'scholar': 'نخبة من الداعيات وفقهاء الأمة',
      'icon': '🌸',
    },
    {
      'title': 'أحكام الحجاب والزينة واللباس الشرعي',
      'desc': 'ضوابط اللباس الشرعي للمرأة أمام المحارم والأجانب، وأحكام عمليات التجميل المعاصرة وفق الضوابط الشرعية.',
      'scholar': 'فتاوى معتمدة من دور الإفتاء',
      'icon': '🧕',
    },
    {
      'title': 'فقه الأسرة وحقوق الزوجين في الإسلام',
      'desc': 'المعاشرة بالمعروف، المودة والرحمة، حل الخلافات الزوجية، وحقوق كل من الزوج والزوجة والأبناء.',
      'scholar': 'د. خديجة بنت علي',
      'icon': '🏡',
    },
  ];

  final List<Map<String, dynamic>> _manners = [
    {
      'title': 'أم المؤمنين خديجة بنت خويلد رضي الله عنها',
      'desc': 'سيدة نساء العالمين، وبذلها لنصرة النبي ﷺ، وبشارة جبريل لها ببيت في الجنة من قصب لا صخب فيه ولا نصب.',
      'icon': '⭐',
    },
    {
      'title': 'أم المؤمنين عائشة الصديقة رضي الله عنها',
      'desc': 'فقيهة الأمة ومفتية الصحابة، وأكثر النساء رواية للحديث النبوي الشريف وذكاءً وعفافاً.',
      'icon': '📜',
    },
    {
      'title': 'خلق الحياء والعفة والستر في حياة المسلمة',
      'desc': 'كيف كان الحياء زينة الصحابيات الصالحات وكيف يترجم في العصر الرقمي والتعامل مع وسائل التواصل.',
      'icon': '💎',
    },
  ];

  final List<Map<String, dynamic>> _homeWorks = [
    {
      'title': 'تنظيم الوقت الإيماني لربة المنزل',
      'desc': 'كيف تجعل المسلمة أعمال الطهي والتنظيف ورعاية الأطفال عبادة مأجورة بالنية الصالحة والاستغفار وسماع القرآن أثناء العمل.',
      'icon': '⏱️',
    },
    {
      'title': 'غرس حب القرآن في قلوب الأبناء داخل البيت',
      'desc': 'خطوات عملية لتحويل البيت إلى روضة قرآنية: جلسة التلاوة اليومية، مكافأة الحفظ، والقصص النبوي قبل النوم.',
      'icon': '🌱',
    },
    {
      'title': 'بركات البيت المسلم وحمايته من الشياطين',
      'desc': 'قراءة سورة البقرة في البيت، أذكار الدخول والخروج، وإخراج الصور والتماثيل والمنكرات لتحل الملائكة والسكينة.',
      'icon': '🕊️',
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
          'المرأة المسلمة',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 18),
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
          _buildCardsList(_ahkam),
          _buildCardsList(_manners),
          _buildCardsList(_homeWorks),
        ],
      ),
    );
  }

  Widget _buildCardsList(List<Map<String, dynamic>> list) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final item = list[idx];
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text(item['icon'] ?? '🌸', style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['title'],
                      style: const TextStyle(fontFamily: 'Dubai', fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item['desc'],
                style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade700, height: 1.4),
              ),
              if (item.containsKey('scholar')) ...[
                const SizedBox(height: 8),
                Text(
                  'المشرف: ${item['scholar']}',
                  style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00875A)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
