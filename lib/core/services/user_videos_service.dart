import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserVideosService {
  UserVideosService._();
  static final UserVideosService instance = UserVideosService._();

  static const String _videosKey = 'user_uploaded_videos_v1';
  final List<Map<String, dynamic>> _videos = [];
  bool _isLoaded = false;

  final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);

  Future<void> init() async {
    if (_isLoaded) return;
    try {
      final sp = await SharedPreferences.getInstance();
      final str = sp.getString(_videosKey);
      if (str != null) {
        final List list = jsonDecode(str);
        _videos.clear();
        _videos.addAll(list.map((e) => Map<String, dynamic>.from(e)));
      }
      _isLoaded = true;
    } catch (_) {}
  }

  List<Map<String, dynamic>> get videos => List.unmodifiable(_videos);

  String? extractYouTubeId(String url) {
    if (!url.contains('youtu')) return null;
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      } else if (uri.host.contains('youtube.com')) {
        if (uri.pathSegments.contains('shorts')) {
          return uri.pathSegments[uri.pathSegments.indexOf('shorts') + 1];
        }
        return uri.queryParameters['v'];
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveVideo({
    required String description,
    required String videoUrl,
    String? localFilePath,
  }) async {
    await init();
    final newId = DateTime.now().millisecondsSinceEpoch;
    final ytId = extractYouTubeId(videoUrl);

    final item = {
      'id': newId,
      'isLive': false,
      'isYouTube': ytId != null,
      'youtubeId': ytId,
      'userName': 'أنت (مستخدم إتقان)',
      'userRole': 'ناشر محتوى',
      'isVolunteer': false,
      'timeAgo': 'الآن',
      'avatar': 'assets/images/profile.png',
      'caption': description,
      'likes': 1,
      'comments': 0,
      'shares': 0,
      'isLiked': false,
      'video_path': videoUrl,
      'local_file_path': localFilePath,
      'thumbnail': ytId != null
          ? 'https://img.youtube.com/vi/$ytId/hqdefault.jpg'
          : null,
      'created_at': DateTime.now().toIso8601String(),
    };

    _videos.insert(0, item);
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_videosKey, jsonEncode(_videos));
    } catch (_) {}

    changeNotifier.value++;
  }
}
