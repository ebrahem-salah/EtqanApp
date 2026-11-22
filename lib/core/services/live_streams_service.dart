import 'dart:async';
import 'package:flutter/foundation.dart';

class LiveStreamItem {
  final String id;
  final String title;
  final String sheikhName;
  final String? sheikhAvatar;
  final String sectionName;
  final String subSectionName;
  final int viewerCount;
  final String roomId;
  final bool isVideo;
  final DateTime startedAt;

  LiveStreamItem({
    required this.id,
    required this.title,
    required this.sheikhName,
    this.sheikhAvatar,
    required this.sectionName,
    required this.subSectionName,
    required this.viewerCount,
    required this.roomId,
    this.isVideo = true,
    required this.startedAt,
  });
}

class LiveStreamsService extends ChangeNotifier {
  static final LiveStreamsService _instance = LiveStreamsService._internal();
  factory LiveStreamsService() => _instance;
  static LiveStreamsService get instance => _instance;

  LiveStreamsService._internal() {
    _initializeDefaultStreams();
  }

  final List<LiveStreamItem> _activeStreams = [];
  List<LiveStreamItem> get activeStreams => List.unmodifiable(_activeStreams);

  void _initializeDefaultStreams() {
    _activeStreams.addAll([
      LiveStreamItem(
        id: 'live_1',
        title: 'مقرأة تصحيح تلاوة سورة النساء برواية حفص',
        sheikhName: 'فضيلة الشيخ أحمد عبد المنعم',
        sheikhAvatar: 'assets/images/profile.png',
        sectionName: 'القرآن الكريم',
        subSectionName: 'المقرأة',
        viewerCount: 148,
        roomId: 'room_quran_maqraa_101',
        isVideo: true,
        startedAt: DateTime.now().subtract(const Duration(minutes: 18)),
      ),
      LiveStreamItem(
        id: 'live_2',
        title: 'جلسة رقية شرعية عامة ومباشرة للتحصين والشفاء',
        sheikhName: 'الراقي د. محمد كمال بو حسين',
        sheikhAvatar: 'assets/images/profile.png',
        sectionName: 'الرقية الشرعية',
        subSectionName: 'رقية مباشرة',
        viewerCount: 230,
        roomId: 'room_ruqyah_direct_202',
        isVideo: true,
        startedAt: DateTime.now().subtract(const Duration(minutes: 35)),
      ),
      LiveStreamItem(
        id: 'live_3',
        title: 'مجلس الإجابة المباشرة عن فتاوى المعاملات والأسرة',
        sheikhName: 'فضيلة الشيخ د. سعد الشثري',
        sheikhAvatar: 'assets/images/profile.png',
        sectionName: 'الفتاوى',
        subSectionName: 'فتاوى مباشرة',
        viewerCount: 95,
        roomId: 'room_fatwa_live_303',
        isVideo: true,
        startedAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      LiveStreamItem(
        id: 'live_4',
        title: 'مقرأة إهداء الثواب لوالدي وأموات المسلمين (سورة يس والواقعة)',
        sheikhName: 'القارئ الشيخ عبد الله المصلح',
        sheikhAvatar: 'assets/images/profile.png',
        sectionName: 'مقرأة إهداء الثواب',
        subSectionName: 'إهداء الثواب',
        viewerCount: 78,
        roomId: 'room_ihdaa_thawab_404',
        isVideo: true,
        startedAt: DateTime.now().subtract(const Duration(minutes: 42)),
      ),
    ]);
  }

  void addLiveStream(LiveStreamItem item) {
    _activeStreams.removeWhere((s) => s.id == item.id);
    _activeStreams.insert(0, item);
    notifyListeners();
  }

  void removeLiveStream(String id) {
    _activeStreams.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void updateViewerCount(String id, int delta) {
    final idx = _activeStreams.indexWhere((s) => s.id == id);
    if (idx != -1) {
      final current = _activeStreams[idx];
      _activeStreams[idx] = LiveStreamItem(
        id: current.id,
        title: current.title,
        sheikhName: current.sheikhName,
        sheikhAvatar: current.sheikhAvatar,
        sectionName: current.sectionName,
        subSectionName: current.subSectionName,
        viewerCount: (current.viewerCount + delta).clamp(1, 99999),
        roomId: current.roomId,
        isVideo: current.isVideo,
        startedAt: current.startedAt,
      );
      notifyListeners();
    }
  }
}
