import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';

class QuranRadiosScreen extends StatefulWidget {
  const QuranRadiosScreen({super.key});

  @override
  State<QuranRadiosScreen> createState() => _QuranRadiosScreenState();
}

class _QuranRadiosScreenState extends State<QuranRadiosScreen> with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  late AnimationController _animController;
  int _currentStationIndex = 0;
  bool _isPlaying = true;
  double _volume = 0.8;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _loadLiveBroadcasts();
  }

  Future<void> _loadLiveBroadcasts() async {
    try {
      final res = await _apiClient.getBroadcasts();
      if (res.statusCode == 200 && res.data != null) {
        final List items = res.data['broadcasts']?['data'] ?? res.data['data'] ?? [];
        if (items.isNotEmpty) {
          final liveList = items.map<Map<String, dynamic>>((b) => {
            'id': b['id'],
            'name': b['name_ar'] ?? b['name'] ?? 'إذاعة إتقان',
            'city': 'البث المباشر المعتمد',
            'currentReciter': 'كبار القراء والمقرئين',
            'currentSurah': 'تلاوات خاشعة وتفسير مبارك',
            'frequency': 'بث سحابي عالي الدقة HD',
            'listeners': 'مستمعين مباشر',
            'streamUrl': b['stream_url'] ?? b['url'] ?? 'https://qurango.net/radio/tarateel',
            'badge': 'مباشر 🔴',
            'icon': '📻',
          }).toList();

          if (mounted) {
            setState(() {
              _stations.insertAll(0, liveList);
            });
          }
        }
      }
    } catch (_) {}
  }

  final List<Map<String, dynamic>> _stations = [
    {
      'id': 1,
      'name': 'إذاعة القرآن الكريم من القاهرة',
      'city': 'جمهورية مصر العربية',
      'currentReciter': 'الشيخ محمود خليل الحصري',
      'currentSurah': 'تلاوة مباركة من سورة طه',
      'frequency': '98.2 FM',
      'listeners': '1.8M مستمع مباشر',
      'streamUrl': 'https://qurango.net/radio/tarateel',
      'badge': 'البث الحي 🔴',
      'image': 'assets/images/auth_login_header_bg.png',
      'icon': '📻',
    },
    {
      'id': 2,
      'name': 'إذاعة الحرم المكي الشريف',
      'city': 'مكة المكرمة - المملكة العربية السعودية',
      'currentReciter': 'أئمة الحرم المكي',
      'currentSurah': 'صلاة التراويح وبث مباشر من صحن الطواف',
      'frequency': '90.0 FM',
      'listeners': '2.4M مستمع مباشر',
      'streamUrl': 'https://qurango.net/radio/makkah',
      'badge': 'الحرمين 🕋',
      'icon': '🕋',
    },
    {
      'id': 3,
      'name': 'إذاعة الشيخ عبد الباسط عبد الصمد',
      'city': 'المصحف المجود النادر',
      'currentReciter': 'صوت مكة الخالد',
      'currentSurah': 'تلاوة نادرة من سورة مريم وقصار السور',
      'frequency': 'بث رقمي HD',
      'listeners': '890k مستمع',
      'streamUrl': 'https://qurango.net/radio/abdulbasit_abdulsamad_mojawwad',
      'badge': 'مصحف مجود ✨',
      'icon': '🎙️',
    },
    {
      'id': 4,
      'name': 'إذاعة الشيخ محمد صديق المنشاوي',
      'city': 'المصحف المرتل الخاشع',
      'currentReciter': 'الصوت الباكي',
      'currentSurah': 'سورة يوسف كاملة برواية حفص عن عاصم',
      'frequency': 'بث رقمي HD',
      'listeners': '740k مستمع',
      'streamUrl': 'https://qurango.net/radio/mohammed_siddiq_alminshawi',
      'badge': 'مرتل 🌿',
      'icon': '📖',
    },
    {
      'id': 5,
      'name': 'إذاعة المصحف المعلم للأطفال',
      'city': 'تعليم التلاوة والترديد',
      'currentReciter': 'الشيخ الحصري مع ترديد الأطفال',
      'currentSurah': 'جزء عم وجزء تبارك للمبتدئين',
      'frequency': 'تعليمي 24h',
      'listeners': '520k مستمع',
      'streamUrl': 'https://qurango.net/radio/al_husary_moallim',
      'badge': 'تعليمي 🧒',
      'icon': '⭐',
    },
    {
      'id': 6,
      'name': 'إذاعة الفتاوى وتفسير آيات القرآن',
      'city': 'برامج حوارية وفتاوى على الهواء',
      'currentReciter': 'كبار علماء الأزهر الشريف وهيئة كبار العلماء',
      'currentSurah': 'تفسير ابن كثير وأسباب النزول',
      'frequency': 'حوارات مباشرة',
      'listeners': '310k مستمع',
      'streamUrl': 'https://qurango.net/radio/tafsir',
      'badge': 'علوم القرآن 📜',
      'icon': '⚖️',
    },
  ];

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _stations[_currentStationIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF131D17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'الإذاعات القرآنية المباشرة',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: 'مشاركة البث',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('↗️ تم نسخ رابط بث "${current['name']}"')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Hero Live Player Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E382A), Color(0xFF0F1E16)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Live indicator & frequency
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        border: Border.all(color: Colors.redAccent),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'بث حي ومباشر',
                            style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      current['frequency'] as String,
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Radio Icon / Logo with Equalizer animation
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Pulsing Circle
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Container(
                          width: 100 + (_isPlaying ? _animController.value * 15 : 0),
                          height: 100 + (_isPlaying ? _animController.value * 15 : 0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.15),
                          ),
                        );
                      },
                    ),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF005F3F)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          current['icon'] as String,
                          style: const TextStyle(fontSize: 42),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Station Title & Info
                Text(
                  current['name'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${current['currentReciter']} • ${current['currentSurah']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 13,
                    color: Color(0xFF90C2A7),
                  ),
                ),
                const SizedBox(height: 16),

                // Equalizer wave bars
                if (_isPlaying)
                  SizedBox(
                    height: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(16, (i) {
                        return AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            final factor = ((i * 3 + (_animController.value * 10)) % 10) / 10.0;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 3,
                              height: 6 + (factor * 18),
                              decoration: BoxDecoration(
                                color: i % 2 == 0 ? AppColors.gold : AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  )
                else
                  const Text(
                    'البث متوقف مؤقتاً',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                const SizedBox(height: 16),

                // Player Controls (Play / Pause, Prev, Next)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white, size: 30),
                      onPressed: () {
                        setState(() {
                          _currentStationIndex = (_currentStationIndex - 1 + _stations.length) % _stations.length;
                        });
                      },
                    ),
                    const SizedBox(width: 14),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPlaying = !_isPlaying;
                        });
                      },
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    IconButton(
                      icon: const Icon(Icons.skip_previous, color: Colors.white, size: 30),
                      onPressed: () {
                        setState(() {
                          _currentStationIndex = (_currentStationIndex + 1) % _stations.length;
                        });
                      },
                    ),
                  ],
                ),

                // Volume Slider
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.volume_down, color: Colors.grey, size: 18),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            activeTrackColor: AppColors.primaryLight,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: AppColors.gold,
                          ),
                          child: Slider(
                            value: _volume,
                            onChanged: (v) {
                              setState(() {
                                _volume = v;
                              });
                            },
                          ),
                        ),
                      ),
                      const Icon(Icons.volume_up, color: Colors.grey, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stations List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'قائمة الإذاعات المتاحة',
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${_stations.length} إذاعات مباشرة',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // Stations List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _stations.length,
              itemBuilder: (context, index) {
                final st = _stations[index];
                final isCurrent = index == _currentStationIndex;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isCurrent ? const Color(0xFF1E382A) : const Color(0xFF19251E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCurrent ? AppColors.primary : Colors.white10,
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        _currentStationIndex = index;
                        _isPlaying = true;
                      });
                    },
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isCurrent ? AppColors.primary : Colors.white10,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(st['icon'] as String, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    title: Text(
                      st['name'] as String,
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                        color: isCurrent ? AppColors.primaryLight : Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      '${st['city']} • ${st['listeners']}',
                      style: TextStyle(fontSize: 11, color: isCurrent ? Colors.white70 : Colors.grey),
                    ),
                    trailing: isCurrent && _isPlaying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                          ),
                        )
                      : Icon(
                          Icons.play_circle_fill,
                          color: isCurrent ? AppColors.primary : Colors.grey.shade600,
                          size: 28,
                        ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
