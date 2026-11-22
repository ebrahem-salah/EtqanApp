import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// مدير الكاشينج والتحميل المسبق لمقاطع ريلز القرآن (Preloading & Instant Playback)
class ReelsPreloadManager {
  ReelsPreloadManager._();
  static final ReelsPreloadManager instance = ReelsPreloadManager._();

  // خريطة الكاش للمشغلات الجاهزة للعمل فوراً
  final Map<String, VideoPlayerController> _controllerCache = {};

  // قائمة الروابط المرتبة
  List<String> _videoUrls = [];

  /// تهيئة قائمة الفيديوهات
  void setVideos(List<String> urls) {
    _videoUrls = urls;
  }

  /// الحصول على مشغل فيديو جاهز أو تهيئته فوراً
  Future<VideoPlayerController> getControllerForIndex(int index) async {
    if (index < 0 || index >= _videoUrls.length) {
      throw Exception('Index out of range');
    }

    final path = _videoUrls[index];

    // 1. إذا كان المشغل مهيأ مسبقاً في الكاش، نرجعه مباشرة (تشغيل فوري 0ms)
    if (_controllerCache.containsKey(path) && _controllerCache[path]!.value.isInitialized) {
      return _controllerCache[path]!;
    }

    // 2. إذا لم يكن مهيأ، نقوم بتهيئته وتخزينه
    final controller = _createController(path);
    await controller.initialize();
    controller.setLooping(true);
    _controllerCache[path] = controller;

    return controller;
  }

  /// التحميل المسبق للفيديو التالي والسابق لضمان سرعة التمرير
  void preloadAdjacentReels(int currentIndex) {
    // تحميل الفيديو التالي مسبقاً في الخلفية
    if (currentIndex + 1 < _videoUrls.length) {
      _preloadIndex(currentIndex + 1);
    }

    // إبقاء الفيديو السابق في الكاش للرجوع الفوري
    if (currentIndex - 1 >= 0) {
      _preloadIndex(currentIndex - 1);
    }

    // تنظيف المشغلات البعيدة لتوفير الذاكرة RAM
    _cleanDistantControllers(currentIndex);
  }

  Future<void> _preloadIndex(int index) async {
    final path = _videoUrls[index];
    if (_controllerCache.containsKey(path)) return;

    try {
      final controller = _createController(path);
      await controller.initialize();
      controller.setLooping(true);
      // كتم الصوت مؤقتاً أثناء التحميل المسبق بالخلفية
      await controller.setVolume(0.0);
      _controllerCache[path] = controller;
      debugPrint('تم التحميل المسبق بنجاح للريل: $path');
    } catch (e) {
      debugPrint('فشل التحميل المسبق للريل $path: $e');
    }
  }

  VideoPlayerController _createController(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return VideoPlayerController.networkUrl(Uri.parse(path));
    } else {
      return VideoPlayerController.asset(path);
    }
  }

  /// تحرير الذاكرة من المشغلات البعيدة عن الموضع الحالي
  void _cleanDistantControllers(int currentIndex) {
    final keepIndices = {currentIndex - 1, currentIndex, currentIndex + 1};
    final keepUrls = keepIndices
        .where((i) => i >= 0 && i < _videoUrls.length)
        .map((i) => _videoUrls[i])
        .toSet();

    final urlsToRemove = _controllerCache.keys.where((url) => !keepUrls.contains(url)).toList();

    for (final url in urlsToRemove) {
      _controllerCache[url]?.dispose();
      _controllerCache.remove(url);
      debugPrint('تم تحرير كاش الفيديو البعيد لتوفير الذاكرة: $url');
    }
  }

  /// إيقاف تشغيل كافة الفيديوهات المحملة في الكاش لمنع استمرار الصوت بالخلفية
  void pauseAll() {
    for (final controller in _controllerCache.values) {
      try {
        if (controller.value.isPlaying) {
          controller.pause();
        }
      } catch (_) {}
    }
  }

  /// استئناف تشغيل فيديو محدد
  void resumeIndex(int index) {
    if (index >= 0 && index < _videoUrls.length) {
      final path = _videoUrls[index];
      if (_controllerCache.containsKey(path)) {
        try {
          _controllerCache[path]?.setVolume(1.0);
          _controllerCache[path]?.play();
        } catch (_) {}
      }
    }
  }

  /// إيقاف وتفريغ كافة الفيديوهات عند مغادرة شاشة الريلز
  void disposeAll() {
    for (final controller in _controllerCache.values) {
      try {
        controller.pause();
        controller.dispose();
      } catch (_) {}
    }
    _controllerCache.clear();
  }
}
