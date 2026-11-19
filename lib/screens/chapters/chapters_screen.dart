import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
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
  int _selectedCategoryIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBF4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'الحلقات',
          style: TextStyle(
            color: Color(0xFF191919),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Dubai',
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0E0D0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
                ],
              ),
              child: const Icon(Icons.notifications_none_rounded, color: Colors.black87, size: 20),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔔 لا توجد إشعارات جديدة'),
                  backgroundColor: Color(0xFF00875A),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // 1. Right Side: Categories Rail (Matching Images Exactly)
          Container(
            width: 135,
            decoration: const BoxDecoration(
              color: Color(0xFFF4F4E6),
              border: Border(
                left: BorderSide(color: Color(0xFFE2E2CB), width: 1),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                    children: [
                      // Black Library Button (< المكتبة)
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LibraryScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.menu_book_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'المكتبة >',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Dubai',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Category Pills
                      ...List.generate(_categories.length, (index) {
                        final isSelected = _selectedCategoryIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF00875A) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF00875A) : const Color(0xFFDFDFC6),
                                width: 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF00875A).withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              _categories[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF555555),
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontFamily: 'Dubai',
                                height: 1.3,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Floating Action Button in Rail Bottom (+)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const AddChapterDialog(),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00875A),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00875A).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Main Content Area (Level Cards & Subcategories)
          Expanded(
            child: _buildSubcategoryContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryContent() {
    // 1. Noorani Qaida (3 Luxury Level Cards: 1, 2, 3)
    if (_selectedCategoryIndex == 0) {
      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildLuxuryLevelCard(
            badgeNumber: '1',
            title: 'الجزء الأول',
            subtitle: 'المستوى الأول',
            onTap: () => _openRoom('حلقة: القاعدة النورانية - الجزء الأول (المستوى الأول)'),
          ),
          const SizedBox(height: 12),
          _buildLuxuryLevelCard(
            badgeNumber: '2',
            title: 'الجزء الثاني',
            subtitle: 'المستوى الثاني',
            onTap: () => _openRoom('حلقة: القاعدة النورانية - الجزء الثاني (المستوى الثاني)'),
          ),
          const SizedBox(height: 12),
          _buildLuxuryLevelCard(
            badgeNumber: '3',
            title: 'الجزء الثالث',
            subtitle: 'المستوى الثالث',
            onTap: () => _openRoom('حلقة: القاعدة النورانية - الجزء الثالث (المستوى الثالث)'),
          ),
        ],
      );
    }

    // 2. Holy Quran (6 Photo Cards in 2-Column Grid)
    if (_selectedCategoryIndex == 1) {
      final quranCards = [
        {'title': 'الحفظ والإتقان', 'icon': '📖'},
        {'title': 'المراجعة والتثبيت', 'icon': '🔄'},
        {'title': 'التجويد ومخارج الحروف', 'icon': '🎙️'},
        {'title': 'التدارس والتدبر', 'icon': '✨'},
        {'title': 'المقرأة الجماعية', 'icon': '👥'},
        {'title': 'علوم القرآن والتفسير', 'icon': '📜'},
      ];

      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
        itemCount: quranCards.length,
        itemBuilder: (context, index) {
          final card = quranCards[index];
          return GestureDetector(
            onTap: () => _openRoom('حلقة: القرآن الكريم - ${card['title']}'),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E5D5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(card['icon']!, style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Text(
                      card['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Dubai',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF191919),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // 3. Other Islamic Tracks (Luxury Track Cards)
    final catName = _categories[_selectedCategoryIndex];
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildLuxuryLevelCard(
          badgeNumber: '★',
          title: catName,
          subtitle: 'جلسة تفاعلية مباشرة مع الشيخ',
          onTap: () => _openRoom('حلقة: $catName (جلسة تفاعلية)'),
        ),
        const SizedBox(height: 12),
        _buildLuxuryLevelCard(
          badgeNumber: '📖',
          title: 'مدارسة وتسميع: $catName',
          subtitle: 'حلقة إجازات وسند معتمد',
          onTap: () => _openRoom('حلقة: $catName (إجازات وسند)'),
        ),
      ],
    );
  }

  Widget _buildLuxuryLevelCard({
    required String badgeNumber,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E5D5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Dark Charcoal Banner
            Container(
              height: 98,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Color(0xFF252525), Color(0xFF0D140F)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00875A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2ECC71), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00875A).withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badgeNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Dubai',
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Subtitle Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(13)),
              ),
              alignment: Alignment.center,
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                  fontFamily: 'Dubai',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openRoom(String roomTitle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveRecitationRoom(
          roomId: 'circle_${roomTitle.hashCode}',
          circleTitle: roomTitle,
        ),
      ),
    );
  }
}
