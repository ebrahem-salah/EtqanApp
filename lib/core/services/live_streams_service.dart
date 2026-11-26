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

  LiveStreamsService._internal();

  final List<LiveStreamItem> _activeStreams = [];
  List<LiveStreamItem> get activeStreams => List.unmodifiable(_activeStreams);

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
