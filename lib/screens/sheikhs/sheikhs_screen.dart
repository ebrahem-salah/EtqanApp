import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../profile/user_profile_screen.dart';

class SheikhsScreen extends StatefulWidget {
  const SheikhsScreen({super.key});

  @override
  State<SheikhsScreen> createState() => _SheikhsScreenState();
}

class _SheikhsScreenState extends State<SheikhsScreen> {
  final ApiClient _apiClient = ApiClient();
  String _searchQuery = '';
  bool _isSearchOpen = false;
  bool _isLoading = false;

  List<Map<String, dynamic>> _liveSheikhs = [];

  final List<Map<String, dynamic>> _fallbackSheikhs = [
    {
      'id': 1,
      'name': 'etqan app',
      'institution': 'مؤسسة التعاون',
      'institution_logo': null,
      'friends': 1,
      'videos': 0,
      'episodes': 0,
      'is_following': false,
      'avatar': null,
    },
    {
      'id': 2,
      'name': 'أحمد',
      'institution': 'مؤسسة إتقان التجريب...',
      'institution_logo': null,
      'friends': 3,
      'videos': 0,
      'episodes': 2,
      'is_following': false,
      'avatar': null,
    },
    {
      'id': 3,
      'name': 'hemdan',
      'institution': 'مؤسسة إتقان التجريبية',
      'institution_logo': null,
      'friends': 3,
      'videos': 0,
      'episodes': 0,
      'is_following': false,
      'avatar': null,
    },
    {
      'id': 4,
      'name': 'sheikh saad ali',
      'institution': 'مؤسسة النور والقرآن',
      'institution_logo': null,
      'friends': 5,
      'videos': 2,
      'episodes': 4,
      'is_following': false,
      'avatar': null,
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
            final inst = s['institution'] ?? {};
            return {
              'id': s['id'] ?? user['id'] ?? 1,
              'name': user['name'] ?? s['name'] ?? 'فضيلة الشيخ المقرئ',
              'institution': inst['name'] ?? 'مؤسسة إتقان القرآنية',
              'institution_logo': inst['image_url'],
              'friends': s['friends_count'] ?? s['followers_count'] ?? 1,
              'videos': s['videos_count'] ?? 0,
              'episodes': s['classes_count'] ?? 0,
              'is_following': s['is_following'] ?? false,
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

  Future<void> _toggleFriend(Map<String, dynamic> sheikh) async {
    final bool current = sheikh['is_following'] == true;
    setState(() {
      sheikh['is_following'] = !current;
      sheikh['friends'] = (sheikh['friends'] ?? 0) + (!current ? 1 : -1);
      if (sheikh['friends'] < 0) sheikh['friends'] = 0;
    });

    try {
      await _apiClient.toggleFriend(sheikh['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !current
                  ? 'تمت إضافة الشيخ ${sheikh['name']} إلى الأصدقاء'
                  : 'تمت إزالة المتابعة للشيخ ${sheikh['name']}',
              style: const TextStyle(fontFamily: 'Dubai'),
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final list = _liveSheikhs.where((s) {
      final name = s['name'].toString().toLowerCase();
      final inst = s['institution'].toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || inst.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // الخلفية الكريمية الرسمية
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar matching the exact screenshot (media_1795163147266_149a2aad.jpg)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Notification Bell Button
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none, color: Color(0xFF191919), size: 22),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Search Button
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isSearchOpen ? Icons.close : Icons.search,
                            color: const Color(0xFF191919),
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() {
                              _isSearchOpen = !_isSearchOpen;
                              if (!_isSearchOpen) _searchQuery = '';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'الشيوخ',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191919),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar (if opened)
            if (_isSearchOpen)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                child: TextField(
                  autofocus: true,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن شيخ أو مؤسسة...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 6),

            // Sheikhs List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : RefreshIndicator(
                      onRefresh: _loadLiveSheikhs,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final sheikh = list[index];
                          final isFollowing = sheikh['is_following'] == true;

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => UserProfileScreen(
                                    userName: sheikh['name'] ?? 'فضيلة الشيخ',
                                    episodesCount: sheikh['episodes'] ?? 0,
                                    videosCount: sheikh['videos'] ?? 0,
                                    friendsCount: sheikh['friends'] ?? 0,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFEEEEEE), width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Row 1: Left Friend Button, Center Info, Right Avatar
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Action button: Green square +👤
                                      GestureDetector(
                                        onTap: () => _toggleFriend(sheikh),
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: isFollowing
                                                ? const Color(0xFF2E7D32)
                                                : const Color(0xFF00875A),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            isFollowing ? Icons.check : Icons.person_add_alt_1_outlined,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Center: Name & Institution Badge
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              sheikh['name'],
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontFamily: 'Dubai',
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF191919),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            // Institution pill badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE8F5E9),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    sheikh['institution'],
                                                    style: const TextStyle(
                                                      fontFamily: 'Dubai',
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFF00875A),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    width: 22,
                                                    height: 22,
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFF00875A),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.mosque_outlined,
                                                      size: 13,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Right: Sheikh Avatar
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: const Color(0xFFF9ECC9),
                                        backgroundImage: sheikh['avatar'] != null
                                            ? NetworkImage(sheikh['avatar'])
                                            : null,
                                        child: sheikh['avatar'] == null
                                            ? const Icon(
                                                Icons.person,
                                                size: 34,
                                                color: Color(0xFF8D6E63),
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),

                                  // Divider
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12.0),
                                    child: Divider(
                                      color: Color(0xFFF0F0F0),
                                      thickness: 1,
                                      height: 1,
                                    ),
                                  ),

                                  // Row 2: 3 Stats Columns (الحلقات، الفيديوهات، الاصدقاء)
                                  Row(
                                    children: [
                                      // الحلقات
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              '${sheikh['episodes']}',
                                              style: const TextStyle(
                                                fontFamily: 'Dubai',
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF191919),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'الحلقات',
                                              style: TextStyle(
                                                fontFamily: 'Dubai',
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 30,
                                        color: const Color(0xFFEEEEEE),
                                      ),

                                      // الفيديوهات
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              '${sheikh['videos']}',
                                              style: const TextStyle(
                                                fontFamily: 'Dubai',
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF191919),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'الفيديوهات',
                                              style: TextStyle(
                                                fontFamily: 'Dubai',
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 30,
                                        color: const Color(0xFFEEEEEE),
                                      ),

                                      // الاصدقاء
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              '${sheikh['friends']}',
                                              style: const TextStyle(
                                                fontFamily: 'Dubai',
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF191919),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'الاصدقاء',
                                              style: TextStyle(
                                                fontFamily: 'Dubai',
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
