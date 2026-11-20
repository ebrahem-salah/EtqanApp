import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/network/api_client.dart';
import '../../core/services/share_service.dart';
import '../../core/services/reels_preload_manager.dart';
import '../competitions/competitions_screen.dart';
import '../profile/user_profile_screen.dart';
import '../notifications/notifications_screen.dart';
import 'add_video_screen.dart';

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
      'userName': 'Fahd saad',
      'userRole': 'إمام مسجد',
      'isVolunteer': true,
      'timeAgo': 'منذ 7 شهر',
      'avatar': 'assets/images/profile.png',
      'caption': 'تحفه ما شاء الله - تلاوة مباركة خاشعة',
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
    ReelsPreloadManager.instance.setVideos(_reels.map((r) => r['video_path'] as String).toList());
    ReelsPreloadManager.instance.preloadAdjacentReels(0);
    _loadLiveVideos();
  }

  @override
  void dispose() {
    _pageController.dispose();
    ReelsPreloadManager.instance.disposeAll();
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
            ReelsPreloadManager.instance.setVideos(_reels.map((r) => r['video_path'] as String).toList());
            ReelsPreloadManager.instance.preloadAdjacentReels(_currentIndex);
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

  void _openUserProfile(Map<String, dynamic> reel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          userName: reel['userName'],
          userAvatar: reel['avatar'],
        ),
      ),
    );
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
              ReelsPreloadManager.instance.preloadAdjacentReels(index);
            },
            itemBuilder: (context, index) {
              final reel = _reels[index];
              final isCurrent = index == _currentIndex;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Real Autoplaying Video Item with 0ms Preloading Cache
                  ReelVideoPlayerItem(
                    index: index,
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

                  // 2. Left Floating Action Controls (Heart, Comment, Fullscreen, Native Share)
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

                          // Comment (Matching Image 1)
                          _buildActionIcon(
                            icon: Icons.chat_bubble_outline_rounded,
                            color: Colors.white,
                            label: reel['comments'].toString(),
                            onTap: () => _showCommentsSheet(context, reel),
                          ),
                          const SizedBox(height: 16),

                          // Expand / Fullscreen من الصورة 3
                          _buildActionIcon(
                            icon: Icons.crop_free_rounded,
                            color: Colors.white,
                            label: '',
                            onTap: () {
                              _showFullscreenPlayer(context, reel);
                            },
                          ),
                          const SizedBox(height: 16),

                          // Share (Native Share Sheet - Matching Image 2)
                          _buildActionIcon(
                            icon: Icons.near_me_outlined,
                            color: Colors.white,
                            label: '',
                            onTap: () {
                              final textToShare = '${reel['caption']}\nhttps://etqan.site/videos/${reel['id']}';
                              ShareService.shareText(
                                text: textToShare,
                                title: 'Share text',
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

                  // 4. Bottom Sheikh Info (Tapping opens Profile Screen - Matching Images 4 & 5)
                  if (_isOverlayVisible)
                    Positioned(
                      bottom: 24,
                      right: 16,
                      left: 75,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => _openUserProfile(reel),
                            child: Row(
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
                    // Left: 3 Circular Buttons (Bell, Search, Add Video directly!)
                    Row(
                      children: [
                        // 1. Notification Bell من الصورة 2
                        _buildHeaderCircleBtn(
                          icon: Icons.notifications_none_rounded,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        // 2. Search من الصورة 2 و 17
                        _buildHeaderCircleBtn(
                          icon: Icons.search_rounded,
                          onTap: () {
                            _showSearchScreen(context);
                          },
                        ),
                        const SizedBox(width: 8),
                        // 3. Circular Add Button with Green Rings: Navigates DIRECTLY to AddVideoScreen (Image 3)
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AddVideoScreen()),
                            );
                          },
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

  // Exact Comments Modal Matching Image 1
  void _showCommentsSheet(BuildContext context, Map<String, dynamic> reel) {
    final commentController = TextEditingController();
    final List<Map<String, dynamic>> comments = [
      {
        'id': 1,
        'name': 'Fahd saad',
        'time': 'منذ شهر',
        'text': 'السلام عليكم',
        'avatar': 'assets/images/profile.png',
        'likes': 1,
        'isLiked': false,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.70,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // 1. Top Close Button ✕ (Centered grey circular badge - Image 1)
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 8),

              // Title: التعليقات (Matching Image 1)
              const Text(
                'التعليقات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Dubai',
                  color: Color(0xFF1E2822),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Comments List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: comments.length,
                  itemBuilder: (context, i) {
                    final c = comments[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left: Heart outline with count (Image 1)
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    c['isLiked'] = !c['isLiked'];
                                    if (c['isLiked']) {
                                      c['likes'] += 1;
                                    } else {
                                      c['likes'] -= 1;
                                    }
                                  });
                                },
                                child: Icon(
                                  c['isLiked'] ? Icons.favorite : Icons.favorite_border_rounded,
                                  color: c['isLiked'] ? Colors.redAccent : Colors.grey,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${c['likes']}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                              ),
                            ],
                          ),
                          const Spacer(),

                          // Right: User info & Comment Text (Image 1)
                          Expanded(
                            flex: 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          c['name'],
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        Text(
                                          c['time'],
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: AssetImage(c['avatar']),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(right: 50.0),
                                  child: Text(
                                    c['text'],
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF1E2822),
                                      fontFamily: 'Dubai',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // 3. Bottom Comment Input Bar (Matching Image 1)
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                  top: 8,
                  left: 16,
                  right: 16,
                ),
                child: Row(
                  children: [
                    // Green circular send button on far left
                    GestureDetector(
                      onTap: () {
                        final text = commentController.text.trim();
                        if (text.isNotEmpty) {
                          setModalState(() {
                            comments.add({
                              'id': comments.length + 1,
                              'name': 'أنت',
                              'time': 'الآن',
                              'text': text,
                              'avatar': 'assets/images/profile.png',
                              'likes': 0,
                              'isLiked': false,
                            });
                            reel['comments'] += 1;
                          });
                          setState(() {});
                          _apiClient.postVideoComment(reel['id'], text);
                          commentController.clear();
                        }
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00875A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Rounded comment input container
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey.shade300, width: 1.2),
                        ),
                        child: TextField(
                          controller: commentController,
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                            hintText: 'اكتب تعليق',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontFamily: 'Dubai',
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onSubmitted: (_) {
                            final text = commentController.text.trim();
                            if (text.isNotEmpty) {
                              setModalState(() {
                                comments.add({
                                  'id': comments.length + 1,
                                  'name': 'أنت',
                                  'time': 'الآن',
                                  'text': text,
                                  'avatar': 'assets/images/profile.png',
                                  'likes': 0,
                                  'isLiked': false,
                                });
                                reel['comments'] += 1;
                              });
                              setState(() {});
                              _apiClient.postVideoComment(reel['id'], text);
                              commentController.clear();
                            }
                          },
                        ),
                      ),
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

  // مشغل ملء الشاشة الأفقي المطابق للصورة 3 (Screenshot 3)
  void _showFullscreenPlayer(BuildContext context, Map<String, dynamic> reel) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (ctx) {
        bool isPlaying = true;
        return StatefulBuilder(
          builder: (ctx, setPlayerState) => Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                // Mock Video Player Background
                Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: Colors.black87,
                      child: const Center(
                        child: Icon(Icons.videocam_rounded, size: 70, color: Colors.white24),
                      ),
                    ),
                  ),
                ),

                // Close Button X (Top Left) من الصورة 3
                Positioned(
                  top: 40,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ),
                ),

                // Center Pause/Play Button (دائرة بيضاء وزر إيقاف مؤقت) من الصورة 3
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setPlayerState(() {
                        isPlaying = !isPlaying;
                      });
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black45,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Icon(
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Timeline Scrubber (00:07 / 00:57) من الصورة 3
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      const Text(
                        '00:07',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 0.14,
                            minHeight: 4,
                            backgroundColor: Colors.white30,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00875A)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '00:57',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // شاشة البحث المطابقة بكسل ببكسل للصورة 17 (Screenshot 17)
  void _showSearchScreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFFCFBE8), // الخلفية الكريمية الرسمية من الصورة 17
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Header: Title 'بحث' and Back Button من الصورة 17
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF191919)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const Text(
                    'بحث',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191919),
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search Input Container من الصورة 17
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const TextField(
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: '...ابحث بالاسم',
                    hintStyle: TextStyle(fontFamily: 'Dubai', color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
            ),

            const Expanded(
              child: Center(
                child: Text(
                  'اكتب اسم القارئ أو السورة للبحث الفوري',
                  style: TextStyle(fontFamily: 'Dubai', color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dedicated Video Player Item for Auto-play and Loop
class ReelVideoPlayerItem extends StatefulWidget {
  final int index;
  final String videoPath;
  final bool isCurrent;
  final VoidCallback onTap;

  const ReelVideoPlayerItem({
    super.key,
    required this.index,
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
      _controller = await ReelsPreloadManager.instance.getControllerForIndex(widget.index);
      if (widget.isCurrent && mounted) {
        await _controller!.setVolume(1.0);
        await _controller!.play();
      }
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (_) {
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
        _controller!.setVolume(1.0);
        _controller!.play();
      } else if (!widget.isCurrent && oldWidget.isCurrent) {
        _controller!.pause();
      }
    }
  }

  @override
  void dispose() {
    // Note: VideoPlayerController lifecycle is kept hot by ReelsPreloadManager
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
