import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../call/live_recitation_room.dart';
import '../booking/circle_booking_screen.dart';

class ChaptersScreen extends StatefulWidget {
  const ChaptersScreen({super.key});

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  int _selectedCategoryIndex = 1; // Default to القرآن الكريم

  final List<String> _categories = [
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

  final Map<int, List<Map<String, String>>> _subCategories = {
    0: [
      {'title': 'المستوى الأول', 'level': '1'},
      {'title': 'المستوى الثاني', 'level': '2'},
      {'title': 'المستوى الثالث', 'level': '3'},
    ],
    1: [
      {'title': 'الحفظ', 'icon': '📖'},
      {'title': 'المراجعة', 'icon': '🔄'},
      {'title': 'التجويد', 'icon': '🎙️'},
      {'title': 'المدارسة', 'icon': '👥'},
      {'title': 'المقرأة', 'icon': '🕌'},
      {'title': 'علوم القرآن', 'icon': '📜'},
      {'title': 'القراءات العشر', 'icon': '✨'},
      {'title': 'المقامات الصوتية', 'icon': '🎵'},
      {'title': 'التفسير', 'icon': '📖'},
      {'title': 'القراءات', 'icon': '📜'},
    ],
    2: [
      {'title': 'رجال', 'icon': '👨'},
      {'title': 'نساء', 'icon': '👩'},
    ],
    3: [
      {'title': 'الحفظ', 'icon': '📖'},
      {'title': 'علوم الحديث', 'icon': '📚'},
      {'title': 'شروح الأحاديث', 'icon': '🖋️'},
      {'title': 'الإقراء لكتب السنة', 'icon': '📜'},
      {'title': 'القراءة بالإسناد', 'icon': '🔗'},
    ],
    4: [
      {'title': 'الفقه', 'icon': '⚖️'},
      {'title': 'تيست', 'icon': '📷'},
      {'title': 'السيرة', 'icon': '🌴'},
      {'title': 'العقيدة', 'icon': '🕋'},
      {'title': 'الرقائق', 'icon': '🤍'},
    ],
    5: [
      {'title': 'فتاوى دار الإفتاء', 'icon': '🏛️'},
      {'title': 'فتاوى مباشرة', 'icon': '🔴'},
      {'title': 'فتاوى مؤرشفة', 'icon': '🗄️'},
    ],
    6: [
      {'title': 'رقية مباشرة', 'icon': '🤲'},
      {'title': 'د. محمد كمال', 'icon': '👤'},
      {'title': 'د. أحمد عبد المنعم', 'icon': '👤'},
    ],
    7: [
      {'title': 'قصص الأطفال', 'icon': '🦒'},
      {'title': 'آداب', 'icon': '⭐'},
      {'title': 'أحاديث وأذكار', 'icon': '📿'},
    ],
    8: [
      {'title': 'أحكام', 'icon': '📖'},
      {'title': 'آداب', 'icon': '🌸'},
      {'title': 'أعمال منزلية', 'icon': '🏡'},
    ],
    9: [
      {'title': 'فقه العبادات', 'icon': '⚖️'},
      {'title': 'فقه المعاملات', 'icon': '💼'},
    ],
    10: [
      {'title': 'مدائح نبوية', 'icon': '🎙️'},
      {'title': 'ابتهالات الفجر', 'icon': '🌅'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final subCats = _subCategories[_selectedCategoryIndex] ?? [];

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
          Container(
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
        ],
      ),
      body: Row(
        children: [
          // Left Area: Subcategories Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              itemCount: subCats.length,
              itemBuilder: (context, index) {
                final item = subCats[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LiveRecitationRoom(
                          roomId: 'circle_${item['title']}',
                          circleTitle: 'حلقة ${item['title']}',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item['icon'] ?? '🕌', style: const TextStyle(fontSize: 36)),
                        const SizedBox(height: 8),
                        Text(
                          item['title'] ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
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
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Text(
                      _categories[index],
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
          // Open Add Circle
        },
      ),
    );
  }
}
