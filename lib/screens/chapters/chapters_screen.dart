import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../call/live_recitation_room.dart';
import '../booking/circle_booking_screen.dart';
import '../library/library_screen.dart';
import 'add_chapter_dialog.dart';

class ChaptersScreen extends StatefulWidget {
  const ChaptersScreen({super.key});

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  final ApiClient _apiClient = ApiClient();
  int _selectedCategoryIndex = 0;
  bool _isLoading = false;

  List<Map<String, dynamic>> _liveCategories = [];
  List<Map<String, dynamic>> _liveClasses = [];

  final List<String> _fallbackCategories = [
    'تعليم الحروف والقاعدة النورانية',
    'القرآن الكريم',
    'مقرأة إهداء الثواب',
    'السنة النبوية',
    'علوم أخرى',
    'الفتاوى',
    'الرقية الشرعية',
    'الطفل المسلم',
    'المرأة المسلمة',
    'قسم الفقه',
    'قسم الابتهال',
  ];

  @override
  void initState() {
    super.initState();
    _loadCategoriesAndClasses();
  }

  Future<void> _loadCategoriesAndClasses() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch categories from Laravel API
      final catRes = await _apiClient.getCategories();
      if (catRes.statusCode == 200 && catRes.data != null) {
        final List cats = catRes.data['data'] ?? [];
        if (cats.isNotEmpty) {
          _liveCategories = cats.map<Map<String, dynamic>>((c) => {
            'id': c['id'],
            'name': c['name_ar'] ?? c['name'] ?? 'قسم',
            'children': c['children'] ?? [],
          }).toList();
        }
      }
    } catch (_) {}

    // Fallback if API offline
    if (_liveCategories.isEmpty) {
      _liveCategories = _fallbackCategories.asMap().entries.map((e) => {
        'id': e.key + 1,
        'name': e.value,
        'children': [],
      }).toList();
    }

    await _loadClassesForCategory(_liveCategories[_selectedCategoryIndex]['id']);
  }

  Future<void> _loadClassesForCategory(dynamic categoryId) async {
    setState(() => _isLoading = true);
    try {
      final classRes = await _apiClient.getClasses(categoryId: int.tryParse(categoryId.toString()));
      if (classRes.statusCode == 200 && classRes.data != null) {
        final List classes = classRes.data['data'] ?? [];
        _liveClasses = classes.map<Map<String, dynamic>>((cls) => {
          'id': cls['id'],
          'title': cls['name'] ?? 'مقرأة إتقان',
          'sheikh': cls['sheikh']?['user']?['name'] ?? 'الشيخ المقرئ',
          'type': cls['type'] ?? 'free',
          'is_paid': cls['is_paid'] == true || cls['price'] != null,
          'price': cls['price'] ?? 0,
          'icon': _getCategoryIcon(_selectedCategoryIndex),
        }).toList();
      }
    } catch (_) {}

    // Fallback classes if none from API
    if (_liveClasses.isEmpty) {
      _liveClasses = [
        {'id': 101, 'title': 'المستوى الأول - التهجي والنطق', 'sheikh': 'الشيخ أحمد نور', 'is_paid': false, 'price': 0, 'icon': '📖'},
        {'id': 102, 'title': 'المستوى الثاني - مخارج الحروف', 'sheikh': 'الشيخ عبد الله السويسي', 'is_paid': true, 'price': 35, 'icon': '🎙️'},
        {'id': 103, 'title': 'المستوى الثالث - الإتقان والرسم', 'sheikh': 'الشيخ سعد علي', 'is_paid': false, 'price': 0, 'icon': '✨'},
      ];
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String _getCategoryIcon(int index) {
    const icons = ['📖', '🕌', '👥', '📚', '🌴', '🏛️', '🤲', '⭐', '🌸', '⚖️', '🎙️'];
    if (index >= 0 && index < icons.length) return icons[index];
    return '🕌';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBF4),
      appBar: AppBar(
        title: const Text('الحلقات'),
        leading: IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CircleBookingScreen(
                    sheikhName: 'الشيخ عبد الله السويسي',
                    circleTitle: 'حلقة إتقان التجويد ومخارج الحروف',
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.calendar_month, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('حجز موعد', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Dubai', fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LibraryScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.menu_book, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text('المكتبة >', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Area: Classes Grid
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _liveClasses.length,
                    itemBuilder: (context, index) {
                      final item = _liveClasses[index];
                      final isPaid = item['is_paid'] == true;

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LiveRecitationRoom(
                                roomId: 'circle_${item['id']}',
                                circleTitle: item['title'] ?? 'حلقة التسميع',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item['icon'] ?? '🕌', style: const TextStyle(fontSize: 32)),
                              const SizedBox(height: 6),
                              Text(
                                item['title'] ?? '',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Dubai',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['sheikh'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isPaid ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isPaid ? '${item['price'] ?? 35} ر.س' : 'حلقة عامة مجانية',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isPaid ? const Color(0xFFE65100) : const Color(0xFF00875A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Right Area: Vertical Categories List
          Container(
            width: 140,
            color: const Color(0xFFF9F9F0),
            child: ListView.builder(
              itemCount: _liveCategories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;
                final cat = _liveCategories[index];

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                    _loadClassesForCategory(cat['id']);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Text(
                      cat['name'] ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: AppColors.primaryLight, size: 20),
        ),
        onPressed: () {
          AddChapterDialog.show(context);
        },
      ),
    );
  }
}
