import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';

class ReelsHomeScreen extends StatefulWidget {
  const ReelsHomeScreen({super.key});

  @override
  State<ReelsHomeScreen> createState() => _ReelsHomeScreenState();
}

class _ReelsHomeScreenState extends State<ReelsHomeScreen> {
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _reels = [
    {
      'sheikh': 'د / عبد الله الرويلي',
      'avatar': 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=150',
      'caption': 'من اعظم اسباب تجعلك سعيداً في الحياه',
      'likes': 234,
      'comments': 45,
      'isFollowing': false,
      'isLiked': false,
      'video_path': 'assets/videos/onboarding_video_1.mp4',
    },
    {
      'sheikh': 'د / مصطفي حسني',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      'caption': 'فضل قراءة وتدبر سورة الكهف يوم الجمعة وسر نورها',
      'likes': 852,
      'comments': 112,
      'isFollowing': true,
      'isLiked': false,
      'video_path': 'assets/videos/onboarding_video_2.mp4',
    },
    {
      'sheikh': 'د / محمد المطر',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      'caption': 'تصحيح مخرج حرف الضاد والظاء وأشهر الأخطاء الشائعة',
      'likes': 419,
      'comments': 63,
      'isFollowing': false,
      'isLiked': false,
      'video_path': 'assets/videos/onboarding_video_1.mp4',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _reels.length,
        itemBuilder: (context, index) {
          final reel = _reels[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Video Background Placeholder / Simulated Video Feed
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
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        reel['sheikh'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Subtle Gradient Shadow Overlays
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
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Top Bar: Sheikh Info & Follow Button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Follow Button (Green pill)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            reel['isFollowing'] = !reel['isFollowing'];
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: reel['isFollowing'] ? Colors.white24 : AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                          elevation: 0,
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          reel['isFollowing'] ? 'متابع' : 'متابعة',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Sheikh Name & Avatar
                      Row(
                        children: [
                          Text(
                            reel['sheikh'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.person, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Left Floating Interaction Buttons (Like, Comment, Share)
              Positioned(
                bottom: 60,
                left: 16,
                child: Column(
                  children: [
                    _floatingAction(
                      icon: reel['isLiked'] ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      iconColor: reel['isLiked'] ? Colors.redAccent : Colors.white,
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
                    const SizedBox(height: 18),
                    _floatingAction(
                      icon: Icons.chat_bubble_outline_rounded,
                      iconColor: Colors.white,
                      label: reel['comments'].toString(),
                      onTap: () => _showCommentsBottomSheet(context, reel),
                    ),
                    const SizedBox(height: 18),
                    _floatingAction(
                      icon: Icons.send_rounded,
                      iconColor: Colors.white,
                      label: '',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('↗️ تم نسخ رابط المقطع للمشاركة'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // 5. Bottom Video Caption
              Positioned(
                bottom: 24,
                right: 16,
                left: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reel['caption'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _floatingAction({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 30),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context, Map<String, dynamic> reel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 380,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التعليقات (${reel['comments']})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: const [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFFE8F5E9),
                        child: Icon(Icons.person, color: Color(0xFF00875A)),
                      ),
                      title: Text('أحمد سمير', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('جزاكم الله خير الجزاء يا شيخنا ونفع بكم'),
                      trailing: Text('منذ ساعتين', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFFE8F5E9),
                        child: Icon(Icons.person, color: Color(0xFF00875A)),
                      ),
                      title: Text('عبد الرحمن خالد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('ما شاء الله تبارك الله، تلاوة خاشعة وشرح متقن'),
                      trailing: Text('منذ 4 ساعات', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'أضف تعليقاً طيباً...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: Color(0xFF00875A)),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم نشر تعليقك بنجاح')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
