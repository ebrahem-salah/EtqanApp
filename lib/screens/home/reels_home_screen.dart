import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../competitions/competitions_screen.dart';

class ReelsHomeScreen extends StatefulWidget {
  const ReelsHomeScreen({super.key});

  @override
  State<ReelsHomeScreen> createState() => _ReelsHomeScreenState();
}

class _ReelsHomeScreenState extends State<ReelsHomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _reels = [
    {
      'id': 1,
      'userName': 'مريم مستخدمت',
      'userRole': 'إمام مسجد',
      'isVolunteer': true,
      'timeAgo': 'منذ 7 شهر',
      'avatar': 'assets/images/profile.png',
      'caption': 'تحفه ما شاء الله',
      'likes': 4,
      'comments': 5,
      'shares': 2,
      'isLiked': false,
      'video_path': 'assets/videos/onboarding_video_1.mp4',
    },
    {
      'id': 2,
      'userName': 'Ahmed',
      'userRole': 'إمام مسجد',
      'isVolunteer': true,
      'timeAgo': 'منذ 21 يوم',
      'avatar': 'assets/images/welcome_sheikh_illustration.png',
      'caption': 'اعمل ما تحب',
      'likes': 0,
      'comments': 0,
      'shares': 1,
      'isLiked': false,
      'video_path': 'assets/videos/onboarding_video_2.mp4',
    },
    {
      'id': 3,
      'userName': 'د / عبد الله الرويلي',
      'userRole': 'مشرف مقرأة',
      'isVolunteer': false,
      'timeAgo': 'منذ شهر',
      'avatar': 'assets/images/profile.png',
      'caption': 'من اعظم اسباب تجعلك سعيداً في الحياه',
      'likes': 234,
      'comments': 45,
      'shares': 18,
      'isLiked': true,
      'video_path': 'assets/videos/onboarding_video_1.mp4',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Vertical PageView for Reels
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _reels.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final reel = _reels[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Video Background Simulation / Feed
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.grey.shade900,
                          Colors.black,
                          Colors.grey.shade900,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 46,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            reel['userName'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Overlay gradient for readability
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.55),
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // 2. Left Floating Interaction Column (Heart, Comment, Expand, Share)
                  Positioned(
                    bottom: 65,
                    left: 16,
                    child: Column(
                      children: [
                        // Like / Heart
                        _buildActionIcon(
                          icon: reel['isLiked'] ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: reel['isLiked'] ? Colors.redAccent : Colors.white,
                          label: reel['likes'].toString(),
                          onTap: () {
                            setState(() {
                              reel['isLiked'] = !reel['isLiked'];
                              if (reel['isLiked']) {
                                reel['likes'] += 1;
                              } else {
                                reel['likes'] -= 1;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // Comment
                        _buildActionIcon(
                          icon: Icons.chat_bubble_outline_rounded,
                          color: Colors.white,
                          label: reel['comments'].toString(),
                          onTap: () => _showCommentsSheet(context, reel),
                        ),
                        const SizedBox(height: 16),
                        // Expand / Fullscreen
                        _buildActionIcon(
                          icon: Icons.crop_free_rounded,
                          color: Colors.white,
                          label: '',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('⛶ وضع ملء الشاشة الكامل')),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // Share
                        _buildActionIcon(
                          icon: Icons.near_me_outlined,
                          color: Colors.white,
                          label: '',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('↗️ تم نسخ رابط المقطع للمشاركة')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // 3. Bottom Sheikh Info (Matching Image 1 & 2)
                  Positioned(
                    bottom: 24,
                    right: 16,
                    left: 75,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar + Name + Badges Row
                        Row(
                          children: [
                            // Sheikh Avatar
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white24,
                              child: const Icon(Icons.person, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        reel['userName'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (reel['isVolunteer'])
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00875A),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'متطوع',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(width: 6),
                                      Text(
                                        reel['userRole'],
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    reel['timeAgo'],
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Caption Text
                        Text(
                          reel['caption'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // 4. Top Header Bar (Matching Image 1 & 2 Exactly)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: 3 Circular Buttons (Bell, Search, Double-Ring Add)
                  Row(
                    children: [
                      // 1. Notification Bell
                      _buildHeaderCircleBtn(
                        icon: Icons.notifications_none_rounded,
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      // 2. Search
                      _buildHeaderCircleBtn(
                        icon: Icons.search_rounded,
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      // 3. Circular Add Button with Green Rings
                      GestureDetector(
                        onTap: () => _showAddOptions(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.4),
                            border: Border.all(color: const Color(0xFF00875A), width: 1.5),
                          ),
                          child: Center(
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF00875A), width: 1.5),
                              ),
                              child: const Icon(Icons.add, color: Color(0xFF00875A), size: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Right: Gold Competitions Button (< المسابقات)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CompetitionsScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE2B755), Color(0xFFB78103)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: Icon(Icons.emoji_events, color: Color(0xFFB78103), size: 18),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'المسابقات >',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCircleBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.4),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCommentsSheet(BuildContext context, Map<String, dynamic> reel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'التعليقات (${reel['comments']})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              const Expanded(
                child: Center(
                  child: Text('لا توجد تعليقات إضافية حالياً'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('إضافة محتوى جديد', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.videocam, color: Color(0xFF00875A)),
                title: const Text('رفع فيديو تعليمي / Reel'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.groups, color: Colors.blue),
                title: const Text('إنشاء حلقة قرآنية جديدة'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
