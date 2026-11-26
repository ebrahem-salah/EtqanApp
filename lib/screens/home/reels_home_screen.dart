import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/network/api_client.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/share_service.dart';
import '../../core/services/reels_preload_manager.dart';
import '../../core/services/live_streams_service.dart';
import '../competitions/competitions_screen.dart';
import '../profile/user_profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../call/live_recitation_room.dart';
import '../sections/sections_hub_screen.dart';
import '../sections/dialogs/create_section_session_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/services/user_videos_service.dart';
import '../../core/utils/app_feedback.dart';
import 'add_video_screen.dart';

class ReelsHomeScreen extends StatefulWidget {
  final bool isActive;
  const ReelsHomeScreen({super.key, this.isActive = true});

  @override
  State<ReelsHomeScreen> createState() => _ReelsHomeScreenState();
}

class _ReelsHomeScreenState extends State<ReelsHomeScreen> with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  final ApiClient _apiClient = ApiClient();
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isOverlayVisible = true;

  // Real Dynamic Reels fetched strictly from Backend API
  final List<Map<String, dynamic>> _reels = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    LiveStreamsService.instance.addListener(_onLiveStreamsChanged);
    UserVideosService.instance.changeNotifier.addListener(_onLiveStreamsChanged);
    _loadLiveVideos();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      ReelsPreloadManager.instance.pauseAll();
    } else if (state == AppLifecycleState.resumed && widget.isActive) {
      ReelsPreloadManager.instance.resumeIndex(_currentIndex);
    }
  }

  @override
  void didUpdateWidget(covariant ReelsHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isActive && oldWidget.isActive) {
      ReelsPreloadManager.instance.pauseAll();
    } else if (widget.isActive && !oldWidget.isActive) {
      ReelsPreloadManager.instance.resumeIndex(_currentIndex);
    }
  }

  void _onLiveStreamsChanged() {
    if (mounted) _loadLiveVideos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    LiveStreamsService.instance.removeListener(_onLiveStreamsChanged);
    UserVideosService.instance.changeNotifier.removeListener(_onLiveStreamsChanged);
    _pageController.dispose();
    ReelsPreloadManager.instance.disposeAll();
    super.dispose();
  }

  void _navigateTo(Widget page) {
    ReelsPreloadManager.instance.pauseAll();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    ).then((_) {
      if (mounted && widget.isActive) {
        ReelsPreloadManager.instance.resumeIndex(_currentIndex);
      }
    });
  }

  Future<void> _loadLiveVideos() async {
    setState(() => _isLoading = true);
    final List<Map<String, dynamic>> combined = [];

    // 1. Fetch live broadcasts from local service AND ongoing classes from server
    final Set<String> seenLiveRooms = {};
    final liveStreams = LiveStreamsService.instance.activeStreams;
    for (final stream in liveStreams) {
      seenLiveRooms.add(stream.roomId);
      combined.add({
        'id': stream.id,
        'isLive': true,
        'roomId': stream.roomId,
        'userName': stream.sheikhName,
        'userRole': 'بث مباشر • ${stream.sectionName} (${stream.subSectionName})',
        'isVolunteer': false,
        'timeAgo': 'مباشر الآن',
        'avatar': stream.sheikhAvatar ?? 'assets/images/profile.png',
        'caption': stream.title,
        'likes': stream.viewerCount * 3,
        'comments': stream.viewerCount,
        'shares': 12,
        'isLiked': false,
        'video_path': '',
        'sectionName': stream.sectionName,
        'subSectionName': stream.subSectionName,
        'viewerCount': stream.viewerCount,
      });
    }

    // Fetch ongoing live classes from server so broadcasts appear to ALL users
    try {
      final clsRes = await _apiClient.getClasses();
      if (clsRes.statusCode == 200 && clsRes.data != null) {
        final List items = clsRes.data['data'] ?? [];
        for (final cls in items) {
          final isOngoing = cls['is_ongoing'] == true || cls['status'] == 'ongoing';
          final isPrivate = cls['is_private'] == true;
          if (!isOngoing || isPrivate) continue;
          final classId = cls['id'] is int ? cls['id'] as int : int.tryParse('${cls['id']}');
          if (classId == null) continue;
          final rId = 'room_srv_$classId';
          if (seenLiveRooms.contains(rId)) continue;
          seenLiveRooms.add(rId);

          final sheikhObj = cls['sheikh'] ?? cls['creator']?['user'] ?? cls['creator'];
          final rawName = sheikhObj?['name']?.toString() ?? '';
          final sheikhName = (rawName.isNotEmpty && !rawName.contains('???')) ? rawName : 'الشيخ المقرئ';
          final catName = cls['category']?['name']?.toString() ?? 'حلقة قرآنية';
          final studentsCount = int.tryParse('${cls['students_count'] ?? 1}') ?? 1;
          final capacity = int.tryParse('${cls['capacity'] ?? cls['max_students'] ?? 30}') ?? 30;

          combined.add({
            'id': 'srv_$classId',
            'classRoomId': classId,
            'isLive': true,
            'roomId': rId,
            'userName': sheikhName,
            'userRole': 'بث مباشر • $catName',
            'isVolunteer': false,
            'timeAgo': 'مباشر الآن',
            'avatar': sheikhObj?['avatar_url'] ?? 'assets/images/profile.png',
            'caption': cls['name']?.toString() ?? 'بث مباشر مبارك',
            'likes': studentsCount * 2,
            'comments': studentsCount,
            'shares': 1,
            'isLiked': false,
            'video_path': '',
            'viewerCount': studentsCount,
            'capacity': capacity,
          });
        }
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'جلب الحلقات المباشرة', e);
      }
    }

    // 2. Fetch locally added user videos (especially YouTube links and local uploads)
    await UserVideosService.instance.init();
    final userVideos = UserVideosService.instance.videos;
    for (final uv in userVideos) {
      combined.add(Map<String, dynamic>.from(uv));
    }

    try {
      final res = await _apiClient.getVideos();
      if (res.statusCode == 200 && res.data != null) {
        final List items = res.data['data'] ?? [];
        if (items.isNotEmpty) {
          final liveReels = items.map<Map<String, dynamic>>((item) {
            final user = item['user'] ?? {};
            return {
              'id': item['id'] ?? 1,
              'isLive': false,
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
              'video_path': item['video_url'] ?? '',
            };
          }).toList();
          combined.addAll(liveReels);
        }
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'تحميل مقاطع الفيديو', e);
      }
    }

    if (mounted) {
      setState(() {
        _reels.clear();
        _reels.addAll(combined);
        _isLoading = false;
      });
      final videoPaths = _reels
          .map((r) => (r['isLive'] == true || r['isYouTube'] == true)
              ? ''
              : (r['video_path']?.toString() ?? ''))
          .toList();
      ReelsPreloadManager.instance.setVideos(videoPaths);
      ReelsPreloadManager.instance.preloadAdjacentReels(_currentIndex);
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
    _navigateTo(
      UserProfileScreen(
        userName: reel['userName'],
        userAvatar: reel['avatar'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<AuthProvider>(context).currentUser?.role ?? UserRole.student;
    final canUploadVideo = userRole != UserRole.student;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00875A)),
        ),
      );
    }

    if (_reels.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF141414),
        body: SafeArea(
          child: Stack(
            children: [
              // Top Bar with Bell, Search, Add Video
              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildHeaderCircleBtn(
                          icon: Icons.notifications_none_rounded,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildHeaderCircleBtn(
                          icon: Icons.search_rounded,
                          onTap: () => _showSearchScreen(context),
                        ),
                        if (canUploadVideo) ...[
                          const SizedBox(width: 8),
                          _buildHeaderCircleBtn(
                            icon: Icons.video_call_rounded,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AddVideoScreen()),
                            ).then((_) => _loadLiveVideos()),
                          ),
                        ],
                      ],
                    ),
                    const Text(
                      'إتقان',
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Empty Content
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.videocam_outlined, size: 38, color: Colors.white54),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'لا توجد مقاطع تلاوة حالياً',
                        style: TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'كن أول من يشارك تلاوة خاشعة على منصة إتقان',
                        style: TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 13,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00875A),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AddVideoScreen()),
                          ).then((_) => _loadLiveVideos());
                        },
                        icon: const Icon(Icons.add, color: Colors.white, size: 18),
                        label: const Text(
                          'إضافة فيديو جديد',
                          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                  // Real Autoplaying Video Item or Live Stream Card or YouTube Reel
                  reel['isLive'] == true
                      ? _buildLiveStreamReelItem(reel)
                      : (reel['isYouTube'] == true
                          ? YouTubeReelPlayerItem(
                              youtubeId: reel['youtubeId']?.toString() ?? '',
                              thumbnail: reel['thumbnail']?.toString(),
                              isCurrent: isCurrent,
                              isActive: widget.isActive,
                              onTap: () {
                                setState(() {
                                  _isOverlayVisible = !_isOverlayVisible;
                                });
                              },
                            )
                          : ReelVideoPlayerItem(
                              index: index,
                              videoPath: reel['video_path'],
                              isCurrent: isCurrent,
                              isActive: widget.isActive,
                              onTap: () {
                                setState(() {
                                  _isOverlayVisible = !_isOverlayVisible;
                                });
                              },
                            )),

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
                                if (reel['id'] != null && reel['id'] is int) {
                                  await _apiClient.toggleLikeVideo(reel['id']);
                                }
                              } catch (e) {
                                if (mounted) {
                                  AppFeedback.showError(context, 'الإعجاب بالفيديو', e);
                                }
                              }
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
                                          Flexible(
                                            child: Text(
                                              reel['userName'] ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                                          ),
                                          const SizedBox(width: 8),
                                          if (reel['isVolunteer'] == true)
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
                                          Flexible(
                                            child: Text(
                                              reel['userRole'] ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.85),
                                                fontSize: 11,
                                                fontFamily: 'Dubai',
                                                shadows: const [
                                                  Shadow(color: Colors.black, blurRadius: 3),
                                                ],
                                              ),
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

          // 5. Top Header Bar (Clean Layout Matching Image 6)
          if (_isOverlayVisible)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Header Action Buttons (Bell, Search, Add Video)
                    Row(
                      children: [
                        // 1. Notification Bell
                        _buildHeaderCircleBtn(
                          icon: Icons.notifications_none_rounded,
                          onTap: () {
                            _navigateTo(const NotificationsScreen());
                          },
                        ),
                        const SizedBox(width: 10),
                        // 2. Search
                        _buildHeaderCircleBtn(
                          icon: Icons.search_rounded,
                          onTap: () {
                            _showSearchScreen(context);
                          },
                        ),
                        if (canUploadVideo) ...[
                          const SizedBox(width: 10),
                          // 3. Add Video (Black circle with white border and green + matching Image 6)
                          GestureDetector(
                            onTap: () {
                              _navigateTo(const AddVideoScreen());
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.75),
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: Center(
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF00875A),
                                  ),
                                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Right: Clear Gold Competitions Button (Matching Image 6)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CompetitionsScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.only(left: 14, right: 4, top: 4, bottom: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFB5892E)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.emoji_events_rounded,
                                  color: Color(0xFFD4AF37),
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'المسابقات',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Dubai',
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                              size: 18,
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

  Widget _buildLiveStreamReelItem(Map<String, dynamic> reel) {
    return Container(
      color: const Color(0xFF0A1813),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Islamic Background Ambient Glow
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE53935).withOpacity(0.2),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          // Live Broadcast Content Card
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(74.0, 0, 24.0, 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glowing Live Avatar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE53935), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE53935).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.white24,
                      backgroundImage: reel['avatar'].toString().startsWith('assets/')
                          ? AssetImage(reel['avatar']) as ImageProvider
                          : NetworkImage(reel['avatar']),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🔴 Live Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE53935).withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, color: Colors.white, size: 8),
                        const SizedBox(width: 6),
                        Text(
                          'بث مباشر حي • ${reel['viewerCount']} مشاهد',
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Animated Live Audio Equalizer Bars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(14, (i) {
                      final heights = [14.0, 26.0, 38.0, 18.0, 32.0, 44.0, 28.0, 16.0, 36.0, 24.0, 30.0, 20.0, 40.0, 22.0];
                      return Container(
                        width: 4,
                        height: heights[i % heights.length],
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00875A),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),

                  // Section Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00875A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF00875A).withOpacity(0.4)),
                    ),
                    child: Text(
                      reel['userRole'] ?? 'بث مباشر',
                      style: const TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF66BB6A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Live Broadcast Title
                  Text(
                    reel['caption'] ?? 'بث مباشر مبارك',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Direct Join Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 6,
                    ),
                    onPressed: () {
                      final int? cId = reel['classRoomId'] is int
                          ? reel['classRoomId'] as int
                          : int.tryParse('${reel['classRoomId'] ?? ''}');
                      final isSheikh = (Provider.of<AuthProvider>(context, listen: false).currentUser?.role ?? UserRole.student) != UserRole.student;
                      _navigateTo(
                        LiveRecitationRoom(
                          roomId: reel['roomId'] ?? (cId != null ? 'room_srv_$cId' : 'room_${reel['id']}'),
                          circleTitle: reel['caption'] ?? 'بث مباشر بإتقان',
                          isSheikh: isSheikh,
                          classRoomId: cId,
                          sheikhName: reel['userName']?.toString(),
                          subscribersCount: reel['viewerCount'] is int ? reel['viewerCount'] as int : 1,
                          capacity: reel['capacity'] is int ? reel['capacity'] as int : 30,
                        ),
                      );
                    },
                    icon: const Icon(Icons.sensors_rounded, color: Colors.white, size: 20),
                    label: const Text(
                      'انضم للبث المباشر الآن (تحدث واستمع)',
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  Widget _buildYouTubeReelItem(Map<String, dynamic> reel) {
    final thumb = reel['thumbnail'] ??
        (reel['youtubeId'] != null
            ? 'https://img.youtube.com/vi/${reel['youtubeId']}/hqdefault.jpg'
            : '');

    return GestureDetector(
      onTap: () {
        setState(() {
          _isOverlayVisible = !_isOverlayVisible;
        });
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background High-Res YouTube Thumbnail
            if (thumb.toString().isNotEmpty)
              CachedNetworkImage(
                imageUrl: thumb.toString(),
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00875A)),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.video_library_rounded, size: 64, color: Colors.white38),
                ),
              )
            else
              const Center(
                child: Icon(Icons.video_library_rounded, size: 64, color: Colors.white38),
              ),

            // Ambient dark gradient for text legibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // Centered YouTube Play Button & Badge
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000), // Official YouTube Red
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF0000).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ondemand_video_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'فيديو يوتيوب مسجل في المنصة',
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  // Comments Bottom Sheet matching Image 4 exactly with Safe Area & Clean Modern Design
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
      {
        'id': 2,
        'name': 'عبد الرحمن القحطاني',
        'time': 'منذ ساعتين',
        'text': 'ما شاء الله تبارك الله، تلاوة ندية خاشعة تشرح الصدور، نفع الله بكم.',
        'avatar': 'assets/images/profile.png',
        'likes': 8,
        'isLiked': true,
      },
      {
        'id': 3,
        'name': 'أحمد إبراهيم',
        'time': 'منذ يوم',
        'text': 'جزاكم الله خيراً يا شيخنا الفاضل وزادكم الله توفيقاً وإتقاناً.',
        'avatar': 'assets/images/profile.png',
        'likes': 3,
        'isLiked': false,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // 1. Sleek circular close button centered at top (Matching Image 4)
              const SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F2F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Color(0xFF65676B), size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 2. Centered Title (التعليقات)
              const Center(
                child: Text(
                  'التعليقات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Dubai',
                    color: Color(0xFF1E2822),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.8, color: Color(0xFFEEEEEE)),

              // 3. Comments List (Flat clean layout without double border or nested boxes - Matching Image 4)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: comments.length,
                  itemBuilder: (context, i) {
                    final c = comments[i];
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User Avatar on Right
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFFE8F5E9),
                              backgroundImage: c['avatar'].toString().startsWith('assets/')
                                  ? AssetImage(c['avatar']) as ImageProvider
                                  : NetworkImage(c['avatar']),
                            ),
                            const SizedBox(width: 12),

                            // User Info and Comment text (Clean with NO grey box around it)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      fontFamily: 'Dubai',
                                      color: Color(0xFF1E2822),
                                    ),
                                  ),
                                  Text(
                                    c['time'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'Dubai',
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    c['text'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Dubai',
                                      color: Color(0xFF2D3748),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Heart & Likes on far Left
                            Column(
                              mainAxisSize: MainAxisSize.min,
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
                                    c['isLiked'] ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    color: c['isLiked'] ? Colors.redAccent : Colors.grey.shade400,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${c['likes']}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                    fontFamily: 'Dubai',
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

              // 4. Bottom Input Bar with Phone Navigation Inset Safe Guard (Matching Image 4)
              Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom +
                      MediaQuery.of(context).padding.bottom +
                      12,
                  top: 10,
                  left: 16,
                  right: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200, width: 0.8)),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      // Single Pill Input without double border or nested box
                      Expanded(
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade400, width: 1.0),
                          ),
                          child: Center(
                            child: TextField(
                              controller: commentController,
                              style: const TextStyle(fontFamily: 'Dubai', fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'اكتب تعليق',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  fontFamily: 'Dubai',
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (text) {
                                final trimmed = text.trim();
                                if (trimmed.isNotEmpty) {
                                  setModalState(() {
                                    comments.add({
                                      'id': comments.length + 1,
                                      'name': 'أنت',
                                      'time': 'الآن',
                                      'text': trimmed,
                                      'avatar': 'assets/images/profile.png',
                                      'likes': 0,
                                      'isLiked': false,
                                    });
                                    reel['comments'] = (reel['comments'] ?? 0) + 1;
                                  });
                                  setState(() {});
                                  _apiClient.postVideoComment(reel['id'], trimmed);
                                  commentController.clear();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Solid Circular Green Send Button (Left in RTL - Matching Image 4)
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
                              reel['comments'] = (reel['comments'] ?? 0) + 1;
                            });
                            setState(() {});
                            _apiClient.postVideoComment(reel['id'], text);
                            commentController.clear();
                          }
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00875A),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          ),
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
    ).then((_) {
      if (mounted && widget.isActive) {
        ReelsPreloadManager.instance.resumeIndex(_currentIndex);
      }
    });
  }

  // مشغل ملء الشاشة الأفقي المطابق للصورة 3 (Screenshot 3)
  void _showFullscreenPlayer(BuildContext context, Map<String, dynamic> reel) {
    ReelsPreloadManager.instance.pauseAll();
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
    ).then((_) {
      if (mounted && widget.isActive) {
        ReelsPreloadManager.instance.resumeIndex(_currentIndex);
      }
    });
  }

  // شاشة البحث المطابقة بكسل ببكسل للصورة 17 (Screenshot 17)
  void _showSearchScreen(BuildContext context) {
    ReelsPreloadManager.instance.pauseAll();
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
    ).then((_) {
      if (mounted && widget.isActive) {
        ReelsPreloadManager.instance.resumeIndex(_currentIndex);
      }
    });
  }
}

/// Dedicated Video Player Item for Auto-play and Loop
class ReelVideoPlayerItem extends StatefulWidget {
  final int index;
  final String videoPath;
  final bool isCurrent;
  final bool isActive;
  final VoidCallback onTap;

  const ReelVideoPlayerItem({
    super.key,
    required this.index,
    required this.videoPath,
    required this.isCurrent,
    this.isActive = true,
    required this.onTap,
  });

  @override
  State<ReelVideoPlayerItem> createState() => _ReelVideoPlayerItemState();
}

class _ReelVideoPlayerItemState extends State<ReelVideoPlayerItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorReason = '';
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _controller = await ReelsPreloadManager.instance.getControllerForPath(widget.videoPath);
      _ownsController = false;
      final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
      if (widget.isCurrent && widget.isActive && isCurrentRoute && mounted) {
        await _controller!.setVolume(1.0);
        await _controller!.play();
      } else {
        await _controller!.setVolume(0.0);
        await _controller!.pause();
      }
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (_) {
      try {
        final path = widget.videoPath;
        if (path.startsWith('http://') || path.startsWith('https://')) {
          _controller = VideoPlayerController.networkUrl(Uri.parse(path));
        } else if (File(path).existsSync() || path.startsWith('/') || path.contains('\\')) {
          _controller = VideoPlayerController.file(File(path));
        } else {
          _controller = VideoPlayerController.asset(path);
        }
        _ownsController = true;
        await _controller!.initialize();
        _controller!.setLooping(true);
        final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
        if (widget.isCurrent && widget.isActive && isCurrentRoute && mounted) {
          await _controller!.setVolume(1.0);
          await _controller!.play();
        } else {
          await _controller!.setVolume(0.0);
          await _controller!.pause();
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
            _errorReason = e.toString();
          });
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant ReelVideoPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller != null && _isInitialized) {
      final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
      final shouldPlay = widget.isCurrent && widget.isActive && isCurrentRoute;
      final wasPlaying = oldWidget.isCurrent && oldWidget.isActive;
      if (shouldPlay && !wasPlaying) {
        _controller!.setVolume(1.0);
        _controller!.play();
      } else if (!shouldPlay && wasPlaying) {
        _controller!.setVolume(0.0);
        _controller!.pause();
      }
    }
  }

  @override
  void deactivate() {
    try {
      _controller?.setVolume(0.0);
      _controller?.pause();
    } catch (_) {}
    super.deactivate();
  }

  @override
  void dispose() {
    try {
      _controller?.setVolume(0.0);
      _controller?.pause();
      if (_ownsController) {
        _controller?.dispose();
      }
    } catch (_) {}
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 54),
              const SizedBox(height: 12),
              const Text(
                'تعذر تشغيل الفيديو',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Dubai'),
              ),
              if (_errorReason.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  _errorReason,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60, fontSize: 11, fontFamily: 'Dubai'),
                ),
              ],
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

/// مشغل تفاعلي حقيقي لفيديوهات اليوتيوب داخل الريلز (يدعم التشغيل والتحكم التلقائي بالصوت)
class YouTubeReelPlayerItem extends StatefulWidget {
  final String youtubeId;
  final String? thumbnail;
  final bool isCurrent;
  final bool isActive;
  final VoidCallback onTap;

  const YouTubeReelPlayerItem({
    super.key,
    required this.youtubeId,
    this.thumbnail,
    required this.isCurrent,
    this.isActive = true,
    required this.onTap,
  });

  @override
  State<YouTubeReelPlayerItem> createState() => _YouTubeReelPlayerItemState();
}

class _YouTubeReelPlayerItemState extends State<YouTubeReelPlayerItem> {
  YoutubePlayerController? _ytController;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _initYouTube();
  }

  void _initYouTube() {
    if (widget.youtubeId.isEmpty) return;
    _ytController = YoutubePlayerController(
      initialVideoId: widget.youtubeId,
      flags: YoutubePlayerFlags(
        autoPlay: widget.isCurrent && widget.isActive,
        mute: false,
        loop: true,
        hideControls: true,
        disableDragSeek: true,
        showLiveFullscreenButton: false,
      ),
    )..addListener(_onPlayerStateChange);
  }

  void _onPlayerStateChange() {
    if (mounted && _ytController != null) {
      if (_ytController!.value.isReady && !_isPlayerReady) {
        setState(() => _isPlayerReady = true);
      }
    }
  }

  @override
  void didUpdateWidget(covariant YouTubeReelPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_ytController != null) {
      final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
      final shouldPlay = widget.isCurrent && widget.isActive && isCurrentRoute;
      final wasPlaying = oldWidget.isCurrent && oldWidget.isActive;
      if (shouldPlay && !wasPlaying) {
        _ytController!.unMute();
        _ytController!.play();
      } else if (!shouldPlay && wasPlaying) {
        _ytController!.mute();
        _ytController!.pause();
      }
    }
  }

  @override
  void deactivate() {
    try {
      _ytController?.mute();
      _ytController?.pause();
    } catch (_) {}
    super.deactivate();
  }

  @override
  void dispose() {
    try {
      _ytController?.mute();
      _ytController?.pause();
      _ytController?.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thumb = widget.thumbnail ??
        (widget.youtubeId.isNotEmpty
            ? 'https://img.youtube.com/vi/${widget.youtubeId}/hqdefault.jpg'
            : '');

    if (_ytController == null || widget.youtubeId.isEmpty) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.video_library_rounded, size: 64, color: Colors.white38),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        widget.onTap();
        if (_ytController != null) {
          if (_ytController!.value.isPlaying) {
            _ytController!.pause();
          } else {
            _ytController!.play();
          }
          setState(() {});
        }
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // مشغل اليوتيوب الحقيقي في كامل مساحة الشاشة
            Center(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: YoutubePlayer(
                    controller: _ytController!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: const Color(0xFF00875A),
                    progressColors: const ProgressBarColors(
                      playedColor: Color(0xFF00875A),
                      handleColor: Color(0xFF00875A),
                    ),
                    onReady: () {
                      if (mounted) setState(() => _isPlayerReady = true);
                    },
                  ),
                ),
              ),
            ),

            // شاشة تحميل وغلاف احتياطي قبل بدء بث الفيديو
            if (!_isPlayerReady && thumb.isNotEmpty)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: thumb,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00875A)),
                  ),
                ),
              ),

            // أيقونة إيقاف مؤقت عند الضغط
            if (_ytController != null && !_ytController!.value.isPlaying && _isPlayerReady)
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
      ),
    );
  }
}
