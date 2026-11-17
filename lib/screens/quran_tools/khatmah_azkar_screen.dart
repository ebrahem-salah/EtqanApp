import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class KhatmahAzkarScreen extends StatefulWidget {
  const KhatmahAzkarScreen({super.key});

  @override
  State<KhatmahAzkarScreen> createState() => _KhatmahAzkarScreenState();
}

class _KhatmahAzkarScreenState extends State<KhatmahAzkarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Khatmah Tracker State
  int _currentKhatmahPage = 235; // Page out of 604
  final int _totalPages = 604;
  int _streakDays = 14;
  bool _isTodayWirdCompleted = false;

  // Tasbeeh State
  int _tasbeehCount = 33;
  int _tasbeehTotal = 132;
  String _selectedZikr = 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ';

  final List<String> _zikrOptions = [
    'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ',
    'لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ',
    'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
    'سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلاَ إِلَهَ إِلاَّ اللَّهُ',
  ];

  // Azkar List
  final List<Map<String, dynamic>> _azkar = [
    {
      'title': 'آية الكرسي',
      'text': 'اللَّهُ لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ...',
      'virtue': 'من قرأها حين يصبح أجير من الجن حتى يمسي',
      'targetCount': 1,
      'currentCount': 1,
    },
    {
      'title': 'سيد الاستغفار',
      'text': 'اللَّهُمَّ أَنْتَ رَبِّي لاَ إِلَهَ إِلاَّ أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ...',
      'virtue': 'من قالها موقناً بها حين يمسي ومات من ليلته دخل الجنة',
      'targetCount': 1,
      'currentCount': 1,
    },
    {
      'title': 'التسبيح والتحميد',
      'text': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ: عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ',
      'virtue': 'تعدل أجوراً عظيمة من العبادة والذكر',
      'targetCount': 3,
      'currentCount': 3,
    },
    {
      'title': 'الصلاة الإبراهيمية',
      'text': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ...',
      'virtue': 'من صلى عليَّ صلاة صلى الله عليه بها عشراً',
      'targetCount': 10,
      'currentCount': 7,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'الورد اليومي والأذكار والقبلة',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.menu_book, size: 20), text: 'ختمة القرآن'),
            Tab(icon: Icon(Icons.fingerprint, size: 20), text: 'الأذكار والسبحة'),
            Tab(icon: Icon(Icons.explore, size: 20), text: 'الصلاة والقبلة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKhatmahTab(),
          _buildTasbeehTab(),
          _buildPrayerQiblaTab(),
        ],
      ),
    );
  }

  // 1. TAB: الورد والختمة
  Widget _buildKhatmahTab() {
    final progress = _currentKhatmahPage / _totalPages;
    final currentJuz = (_currentKhatmahPage / 20).ceil();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Streaks Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB78103), Color(0xFFD4AF37)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB78103).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سلسلة التزام متصلة: $_streakDays يوماً!',
                        style: const TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191919),
                        ),
                      ),
                      const Text(
                        'أحب الأعمال إلى الله أدومها وإن قل. واصل وردك اليومي.',
                        style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Color(0xFF2C2C2C)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Khatmah Progress Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E0C8)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'خطة الختمة الحالية (شهرية)',
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191919),
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE5E5D5),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'أنت في الجزء $currentJuz من 30',
                      style: const TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'صفحة $_currentKhatmahPage من 604',
                      style: const TextStyle(fontFamily: 'Dubai', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Today's Wird Target Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _isTodayWirdCompleted ? const Color(0xFFEEF7F1) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _isTodayWirdCompleted ? AppColors.primary : const Color(0xFFE2E0C8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.today, color: AppColors.primary, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'ورد اليوم المحدد:',
                          style: TextStyle(fontFamily: 'Dubai', fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: _isTodayWirdCompleted ? AppColors.primary : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isTodayWirdCompleted ? 'مكتمل ✓' : 'قيد الإنجاز',
                        style: TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _isTodayWirdCompleted ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'سورة يوسف (من آية 1 إلى آية 52)',
                  style: TextStyle(fontFamily: 'Dubai', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                ),
                const Text(
                  'الصفحات: 235 - 241 (6 صفحات اليوم)',
                  style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTodayWirdCompleted ? Colors.grey : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(_isTodayWirdCompleted ? Icons.check_circle : Icons.done_all, color: Colors.white),
                  label: Text(
                    _isTodayWirdCompleted ? 'تم إتمام قراءة ورد اليوم بنجاح ✓' : 'تأكيد إتمام قراءة ورد اليوم',
                    style: const TextStyle(fontFamily: 'Dubai', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onPressed: () {
                    setState(() {
                      _isTodayWirdCompleted = !_isTodayWirdCompleted;
                      if (_isTodayWirdCompleted) {
                        _currentKhatmahPage += 6;
                        _streakDays += 1;
                      } else {
                        _currentKhatmahPage -= 6;
                        _streakDays -= 1;
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isTodayWirdCompleted
                              ? '🎉 هنيئاً لك! تم تسجيل إتمام ورد اليوم وزيادة سلسلة الالتزام.'
                              : 'تم التراجع عن إتمام الورد.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. TAB: الأذكار والسبحة
  Widget _buildTasbeehTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Smart Tasbeeh Dial
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00875A), Color(0xFF005F3F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              children: [
                // Dropdown of Zikr
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedZikr,
                      dropdownColor: const Color(0xFF005F3F),
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gold),
                      isExpanded: true,
                      style: const TextStyle(fontFamily: 'Dubai', color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      items: _zikrOptions.map((z) {
                        return DropdownMenuItem(value: z, child: Text(z, textAlign: TextAlign.right));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedZikr = val;
                            _tasbeehCount = 0;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tasbeeh Counter Circle Button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _tasbeehCount++;
                      _tasbeehTotal++;
                    });
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: AppColors.gold, width: 4),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_tasbeehCount',
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const Text(
                            'المس للتسبيح',
                            style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Reset & Total Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'إجمالي تسبيحات اليوم: $_tasbeehTotal',
                      style: const TextStyle(fontFamily: 'Dubai', color: Colors.white, fontSize: 13),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: AppColors.gold),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('تصفير', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold)),
                      onPressed: () {
                        setState(() {
                          _tasbeehCount = 0;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Azkar List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'أذكار الصباح والمساء المأثورة:',
                style: TextStyle(fontFamily: 'Dubai', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
              ),
              Text('4 أذكار', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),

          // Azkar Cards
          ..._azkar.map((zk) {
            final isDone = zk['currentCount'] >= zk['targetCount'];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDone ? AppColors.primary : const Color(0xFFE2E0C8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        zk['title'] as String,
                        style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDone ? AppColors.primary : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${zk['currentCount']} / ${zk['targetCount']}',
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isDone ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    zk['text'] as String,
                    style: const TextStyle(fontFamily: 'Dubai', fontSize: 13, height: 1.7, color: Color(0xFF333333)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '✨ الفضل: ${zk['virtue']}',
                    style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Color(0xFFB78103)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 3. TAB: الصلاة والقبلة
  Widget _buildPrayerQiblaTab() {
    final prayers = [
      {'name': 'الفجر', 'time': '04:52 AM', 'passed': true},
      {'name': 'الشروق', 'time': '06:18 AM', 'passed': true},
      {'name': 'الظهر', 'time': '11:45 AM', 'passed': true},
      {'name': 'العصر', 'time': '02:48 PM', 'passed': false, 'next': true},
      {'name': 'المغرب', 'time': '05:04 PM', 'passed': false},
      {'name': 'العشاء', 'time': '06:34 PM', 'passed': false},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Next Prayer Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00875A), Color(0xFF004D33)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('الصلاة القادمة:', style: TextStyle(fontFamily: 'Dubai', color: Colors.white70, fontSize: 12)),
                    SizedBox(height: 2),
                    Text('صلاة العصر (02:48 PM)', style: TextStyle(fontFamily: 'Dubai', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 4),
                    Text('متبقي: 01 ساعة و24 دقيقة', style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Icon(Icons.mosque, color: Colors.white, size: 48),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Prayer Times Grid
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E0C8)),
            ),
            child: Column(
              children: prayers.map((p) {
                final isNext = p['next'] == true;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: isNext ? const Color(0xFFEEF6F1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isNext ? Icons.notifications_active : Icons.access_time,
                            size: 18,
                            color: isNext ? AppColors.primary : Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            p['name'] as String,
                            style: TextStyle(
                              fontFamily: 'Dubai',
                              fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                              color: isNext ? AppColors.primary : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        p['time'] as String,
                        style: TextStyle(
                          fontFamily: 'Dubai',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isNext ? AppColors.primary : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Qibla Compass Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E0C8)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('بوصلة اتجاه القبلة:', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('136° جنوب شرق (مكة المكرمة)', style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),

                // Compass Visual
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 3),
                    color: const Color(0xFFFAF9EE),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: const [
                      Positioned(top: 8, child: Text('ش', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                      Positioned(bottom: 8, child: Text('ج', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                      Positioned(left: 8, child: Text('غ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                      Positioned(right: 8, child: Text('ق', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                      // Kaaba Icon Indicator
                      Positioned(
                        bottom: 24,
                        right: 28,
                        child: Text('🕋', style: TextStyle(fontSize: 28)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'وجه هاتفك باتجاه الكعبة المشرفة بدقة متناهية وفق حساس البوصلة',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
