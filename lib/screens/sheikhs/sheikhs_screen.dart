import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../booking/circle_booking_screen.dart';

class SheikhsScreen extends StatefulWidget {
  const SheikhsScreen({super.key});

  @override
  State<SheikhsScreen> createState() => _SheikhsScreenState();
}

class _SheikhsScreenState extends State<SheikhsScreen> {
  final ApiClient _apiClient = ApiClient();
  String _searchQuery = '';
  int _selectedFilter = 0;
  bool _isLoading = false;

  final List<String> _filters = ['الكل', 'المعتمدون', 'الأعلى تقييماً', 'المتاحون الآن'];

  List<Map<String, dynamic>> _liveSheikhs = [];

  final List<Map<String, dynamic>> _fallbackSheikhs = [
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
      'institution': 'جمعية تحفيظ القرآن',
      'friends': 88,
      'videos': 12,
      'episodes': 34,
      'rating': 4.8,
      'is_following': false,
      'specialty': 'القاعدة النورانية والأطفال',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadLiveSheikhs();
  }

  Future<void> _loadLiveSheikhs() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.getSheikhs();
      if (res.statusCode == 200 && res.data != null) {
        final List items = res.data['data'] ?? [];
        if (items.isNotEmpty) {
          _liveSheikhs = items.map<Map<String, dynamic>>((s) {
            final user = s['user'] ?? {};
            return {
              'id': s['id'] ?? 1,
              'name': user['name'] ?? s['name'] ?? 'فضيلة الشيخ المقرئ',
              'institution': s['institution']?['name'] ?? 'مؤسسة إتقان القرآنية',
              'friends': s['students_count'] ?? 120,
              'videos': s['videos_count'] ?? 10,
              'episodes': s['classes_count'] ?? 35,
              'rating': 4.9,
              'is_following': false,
              'specialty': s['specialization'] ?? 'تحفيظ وتجويد القرآن الكريم',
              'avatar': user['avatar_url'],
            };
          }).toList();
        }
      }
    } catch (_) {}

    if (_liveSheikhs.isEmpty) {
      _liveSheikhs = List.from(_fallbackSheikhs);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _liveSheikhs.where((s) {
      final name = s['name'].toString().toLowerCase();
      final specialty = s['specialty'].toString().toLowerCase();
      final inst = s['institution'].toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || specialty.contains(q) || inst.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF8),
      appBar: AppBar(
        title: const Text('الشيوخ والمعلمون'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLiveSheikhs,
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
                  child: FilterChip(
                    label: Text(_filters[index]),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedFilter = index);
                    },
                    selectedColor: AppColors.primary.withOpacity(0.15),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Sheikhs List
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final sheikh = list[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: const Color(0xFFE8F5E9),
                                  child: const Text('👳‍♂️', style: TextStyle(fontSize: 26)),
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
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified, color: AppColors.primary, size: 16),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        sheikh['institution'],
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        sheikh['specialty'],
                                        style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => CircleBookingScreen(
                                          sheikhName: sheikh['name'],
                                          circleTitle: 'جلسة خاصة: ${sheikh['specialty']}',
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('حجز جلسة', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStat('⭐ التقييم', '${sheikh['rating']}'),
                                _buildStat('👥 الطلاب', '${sheikh['friends']}'),
                                _buildStat('🎥 التلاوات', '${sheikh['videos']}'),
                                _buildStat('🕌 الحلقات', '${sheikh['episodes']}'),
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

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
      ],
    );
  }
}
