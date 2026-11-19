import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/network/api_client.dart';
import '../competitions/competitions_screen.dart';

class ReelsHomeScreen extends StatefulWidget {
  const ReelsHomeScreen({super.key});

  @override
  State<ReelsHomeScreen> createState() => _ReelsHomeScreenState();
}

class _ReelsHomeScreenState extends State<ReelsHomeScreen> {
  final PageController _pageController = PageController();
  final ApiClient _apiClient = ApiClient();
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isOverlayVisible = true;

  final List<Map<String, dynamic>> _reels = [
    {
      'id': 1,
      'userName': 'مريم مستخدمت',
      'userRole': 'إمام مسجد',
      'isVolunteer': true,
      'timeAgo': 'منذ 7 شهر',
      'avatar': 'assets/images/profile.png',
      'caption': 'تحفه ما شاء الله - تلاوة خاشعة',
      'likes': 4,
      'comments': 5,
      'shares': 2,
      'isLiked': false,
      'video_path': 'assets/videos/onboarding_video_1.mp4',
    },
    {
      'id': 2,
      'userName': 'الشيخ أحمد نور',
      'userRole': 'إمام مسجد ومقرئ',
      'isVolunteer': true,
      'timeAgo': 'منذ 21 يوم',
      'avatar': 'assets/images/welcome_sheikh_illustration.png',
      'caption': 'اعمل ما تحب - قراءة من سورة مريم',
      'likes': 18,
      'comments': 3,
      'shares': 4,
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
  void initState() {
    super.initState();
    _loadLiveVideos();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadLiveVideos() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.getVideos();
      if (res.statusCode == 200 && res.data != null) {
        final List items = res.data['data'] ?? [];
        if (items.isNotEmpty) {
          final liveReels = items.map<Map<String, dynamic>>((item) {
            final user = item['user'] ?? {};
            return {
              'id': item['id'] ?? 1,
              'userName': user['name'] ?? 'مستخدم إتقان',
              'userRole': user['type'] == 'Sheikh' ? 'قارئ ومقرئ' : (user['is_volunteer'] == true ? 'متطوع' : 'طالب علم'),
              'isVolunteer': user['is_volunteer'] == true,
              'timeAgo': 'جديد',
              'avatar': user['avatar_url'] ?? 'assets/images/profile.png',
              'caption': item['description'] ?? 'تلاوة قرآنية مباركة',
              'likes': item['likes_count'] ?? 0,
              'comments': item['comments_count'] ?? 0,
              'shares': 1,
              'isLiked': item['is_liked'] == true,
              'video_path': item['video_url'] ?? 'assets/videos/onboarding_video_1.mp4',
            };
          }).toList();

          if (mounted) {
            setState(() {
              _reels.clear();
              _reels.addAll(liveReels);
              _isLoading = false;
            });
            return;
          }
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _nextReel() {
    if (_currentIndex < _reels.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevReel() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Vertical PageView for Reels with Real Video Playback
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
              final isCurrent = index == _currentIndex;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Real Autoplaying Video Item
                  ReelVideoPlayerItem(
                    videoPath: reel['video_path'],
                    isCurrent: isCurrent,
                    onTap: () {
                      setState(() {
                        _isOverlayVisible = !_isOverlayVisible;
                      });
                    },
                  ),

                  // Overlay gradient for contrast
                  if (_isOverlayVisible)
                    Positioned.fill(
                      child: IgnorePointer(
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
                    ),

                  // 2. Left Floating Action Controls (Heart, Comment, Fullscreen, Share)
                  if (_isOverlayVisible)
                    Positioned(
                      bottom: 75,
                      left: 16,
                      child: Column(
                        children: [
                          // Like / Heart
                          _buildActionIcon(
                            icon: reel['isLiked'] ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: reel['isLiked'] ? Colors.redAccent : Colors.white,
                            label: reel['likes'].toString(),
                            onTap: () async {
                              setState(() {
                                reel['isLiked'] = !reel['isLiked'];
                                if (reel['isLiked']) {
                                  reel['likes'] += 1;
                                } else {
                                  reel['likes'] -= 1;
                                }
                              });
                              try {
                                if (reel['id'] != null) {
                                  await _apiClient.toggleLikeVideo(reel['id']);
                                }
                              } catch (_) {}
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
                              setState(() {
                                _isOverlayVisible = !_isOverlayVisible;
                              });
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
                                const SnackBar(
                                  content: Text('↗️ تم نسخ رابط المقطع للمشاركة'),
                                  backgroundColor: Color(0xFF00875A),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                  // 3. Flip Controls (Up / Down Arrow Buttons)
                  if (_isOverlayVisible)
                    Positioned(
                      bottom: 120,
                      right: 16,
                      child: Column(
                        children: [
                          if (_currentIndex > 0)
                            GestureDetector(
                              onTap: _prevReel,
                              child: Container(
                                width: 34,
                                height: 34,
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white, size: 22),
                              ),
                            ),
                          if (_currentIndex < _reels.length - 1)
                            GestureDetector(
                              onTap: _nextReel,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 22),
                              ),
                            ),
                        ],
                      ),
                    ),

                  // 4. Bottom Sheikh Info
                  if (_isOverlayVisible)
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
                                backgroundImage: reel['avatar'].toString().startsWith('assets/')
                                    ? AssetImage(reel['avatar']) as ImageProvider
                                    : NetworkImage(reel['avatar']),
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
                                            fontFamily: 'Dubai',
                                            shadows: [
                                              Shadow(color: Colors.black, blurRadius: 4),
                                            ],
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
                                            shadows: const [
                                              Shadow(color: Colors.black, blurRadius: 3),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      reel['timeAgo'],
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
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
                              fontFamily: 'Dubai',
                              shadows: [
                                Shadow(color: Colors.black87, blurRadius: 5),
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

          // 5. Top Header Bar (Matching Image 1 & 2 Exactly)
          if (_isOverlayVisible)
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
                          onTap: () {
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
                        // 2. Search
                        _buildHeaderCircleBtn(
                          icon: Icons.search_rounded,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🔍 البحث في مقاطع التلاوة والريلز'),
                                backgroundColor: Color(0xFF00875A),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
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
                                width: 28,
                                height: 28,
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFAA771C)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/badg_gold.png',
                              height: 18,
                              errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '< المسابقات',
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.35),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text(
              'إضافة محتوى جديد',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Dubai'),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.video_call, color: Color(0xFF00875A))),
              title: const Text('نشر مقطع تلاوة (Reel)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('شارك تلاوتك القرآنية مع مجتمع إتقان'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('📹 ميزة رفع المقاطع متاحة للمقرئين المعتمدين')),
                );
              },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFFFF8E1), child: Icon(Icons.add_circle_outline, color: Color(0xFFD4AF37))),
              title: const Text('إنشاء حلقة تسميع جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('افتح مجلساً تعليمياً مباشراً للطلاب'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🎙️ تم إرسال طلب فتح حلقة جديدة للمشرف')),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showCommentsSheet(BuildContext context, Map<String, dynamic> reel) {
    final commentController = TextEditingController();
    final List<String> dummyComments = [
      'ما شاء الله تبارك الله، تلاوة مباركة خاشعة 🤲',
      'زادك الله علماً ونفع بك الأمة يا شيخنا 🌿',
      'أحسنتم، نفع الله بكم ونفعنا بما سمعنا ✨',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.65,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التعليقات (${dummyComments.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Dubai'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: dummyComments.length,
                  itemBuilder: (context, i) => ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(Icons.person, color: Color(0xFF00875A)),
                    ),
                    title: Text(dummyComments[i], style: const TextStyle(fontSize: 13, height: 1.4)),
                    subtitle: const Text('منذ ساعتين', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'أضف تعليقاً مباركاً...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: Color(0xFF00875A)),
                      onPressed: () {
                        if (commentController.text.trim().isNotEmpty) {
                          setModalState(() {
                            dummyComments.add(commentController.text.trim());
                            reel['comments'] += 1;
                          });
                          setState(() {});
                          commentController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dedicated Video Player Item for Auto-play and Loop
class ReelVideoPlayerItem extends StatefulWidget {
  final String videoPath;
  final bool isCurrent;
  final VoidCallback onTap;

  const ReelVideoPlayerItem({
    super.key,
    required this.videoPath,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  State<ReelVideoPlayerItem> createState() => _ReelVideoPlayerItemState();
}

class _ReelVideoPlayerItemState extends State<ReelVideoPlayerItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      if (widget.videoPath.startsWith('http://') || widget.videoPath.startsWith('https://')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
      } else {
        _controller = VideoPlayerController.asset(widget.videoPath);
      }

      await _controller!.initialize();
      _controller!.setLooping(true);
      if (widget.isCurrent && mounted) {
        _controller!.play();
      }
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (_) {
      // Fallback to local asset video if network fails
      try {
        _controller?.dispose();
        _controller = VideoPlayerController.asset('assets/videos/onboarding_video_1.mp4');
        await _controller!.initialize();
        _controller!.setLooping(true);
        if (widget.isCurrent && mounted) {
          _controller!.play();
        }
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant ReelVideoPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller != null && _isInitialized) {
      if (widget.isCurrent && !oldWidget.isCurrent) {
        _controller!.play();
      } else if (!widget.isCurrent && oldWidget.isCurrent) {
        _controller!.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_outline, color: Colors.white38, size: 64),
              SizedBox(height: 12),
              Text(
                'مقطع تلاوة قرآنية مباركة',
                style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Dubai'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF00875A)),
        ),
      );
    }

    final isPlaying = _controller!.value.isPlaying;

    return GestureDetector(
      onTap: () {
        _togglePlayPause();
        widget.onTap();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: _controller!.value.size.width > 0 ? _controller!.value.size.width : 1080,
              height: _controller!.value.size.height > 0 ? _controller!.value.size.height : 1920,
              child: VideoPlayer(_controller!),
            ),
          ),

          // Central Play Indicator when Paused
          if (!isPlaying)
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
