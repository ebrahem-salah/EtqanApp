import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SheikhsScreen extends StatefulWidget {
  const SheikhsScreen({super.key});

  @override
  State<SheikhsScreen> createState() => _SheikhsScreenState();
}

class _SheikhsScreenState extends State<SheikhsScreen> {
  String _searchQuery = '';
  int _selectedFilter = 0;

  final List<String> _filters = ['الكل', 'المعتمدون', 'الأعلى تقييماً', 'المتاحون الآن'];

  final List<Map<String, dynamic>> _sheikhs = [
    {
      'id': 1,
      'name': 'الشيخ سعد علي',
      'institution': 'مؤسسة التعاون',
      'friends': 124,
      'videos': 15,
      'episodes': 48,
      'rating': 4.9,
      'is_following': false,
      'specialty': 'قراءات وتجويد',
    },
    {
      'id': 2,
      'name': 'الشيخ محمود القزاز',
      'institution': 'مؤسسة إتقان الخيرية',
      'friends': 310,
      'videos': 28,
      'episodes': 92,
      'rating': 5.0,
      'is_following': true,
      'specialty': 'مقارئ وإجازات',
    },
    {
      'id': 3,
      'name': 'الشيخ عبد الله السويسي',
      'institution': 'جمعية تحفيظ القرآن بالسويس',
      'friends': 88,
      'videos': 12,
      'episodes': 34,
      'rating': 4.8,
      'is_following': false,
      'specialty': 'القاعدة النورانية والأطفال',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF8),
      appBar: AppBar(
        title: const Text('الشيوخ والمعلمون'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'ابحث عن شيخ، تخصص، أو مؤسسة...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
          ),

          // Filters Row
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedFilter == index;
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ChoiceChip(
                    label: Text(_filters[index]),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Sheikh Cards List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sheikhs.length,
              itemBuilder: (context, index) {
                final sheikh = _sheikhs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header Row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                            child: const Icon(Icons.person, size: 32, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      sheikh['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        sheikh['institution'],
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      sheikh['specialty'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Follow Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: sheikh['is_following'] ? Colors.grey.shade200 : AppColors.primary,
                              foregroundColor: sheikh['is_following'] ? Colors.black87 : Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            ),
                            onPressed: () {
                              setState(() {
                                sheikh['is_following'] = !sheikh['is_following'];
                              });
                            },
                            child: Text(
                              sheikh['is_following'] ? 'متابع' : '+ متابعة',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      // Stats Row: Friends, Videos, Episodes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('الأصدقاء', '${sheikh['friends']}'),
                          _buildDivider(),
                          _buildStatItem('الفيديوهات', '${sheikh['videos']}'),
                          _buildDivider(),
                          _buildStatItem('الحلقات', '${sheikh['episodes']}'),
                          _buildDivider(),
                          _buildStatItem('التقييم', '⭐ ${sheikh['rating']}'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.grey.shade300,
    );
  }
}
