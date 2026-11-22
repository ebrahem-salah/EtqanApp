import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'live_streams_service.dart';

class UserChaptersService {
  UserChaptersService._();
  static final UserChaptersService instance = UserChaptersService._();

  static const String _ongoingKey = 'user_ongoing_chapters_v1';
  static const String _finishedKey = 'user_finished_chapters_v1';

  final List<Map<String, dynamic>> _ongoing = [];
  final List<Map<String, dynamic>> _finished = [];
  bool _isLoaded = false;

  final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);

  Future<void> init() async {
    if (_isLoaded) return;
    try {
      final sp = await SharedPreferences.getInstance();
      final ongoingStr = sp.getString(_ongoingKey);
      if (ongoingStr != null) {
        final List list = jsonDecode(ongoingStr);
        _ongoing.clear();
        _ongoing.addAll(list.map((e) => Map<String, dynamic>.from(e)));
      }

      final finishedStr = sp.getString(_finishedKey);
      if (finishedStr != null) {
        final List list = jsonDecode(finishedStr);
        _finished.clear();
        _finished.addAll(list.map((e) => Map<String, dynamic>.from(e)));
      }
      _isLoaded = true;
    } catch (_) {}
  }

  List<Map<String, dynamic>> get ongoingChapters => List.unmodifiable(_ongoing);
  List<Map<String, dynamic>> get finishedChapters => List.unmodifiable(_finished);

  Future<void> createChapter({
    required String name,
    required String mainCategory,
    required String subCategory,
    required String startTime,
    required int maxStudents,
    required bool isPaid,
    required double price,
    required bool isPrivate,
    required bool allowRecording,
    required bool showInReelsAsLive,
    String? supervisorName,
  }) async {
    await init();
    final newId = DateTime.now().millisecondsSinceEpoch;
    final roomId = 'room_custom_$newId';
    final supervisor = supervisorName ?? 'فضيلة الشيخ (منشئ الحلقة)';

    final chapterMap = {
      'id': newId,
      'roomId': roomId,
      'title': name,
      'name': name,
      'mainCategory': mainCategory,
      'subCategory': subCategory,
      'supervisor': supervisor,
      'time': startTime,
      'starts_at': startTime,
      'subscribers': '1 / $maxStudents',
      'maxStudents': maxStudents,
      'isPaid': isPaid,
      'price': price,
      'isPrivate': isPrivate,
      'allowRecording': allowRecording,
      'showInReelsAsLive': showInReelsAsLive,
      'created_at': DateTime.now().toIso8601String(),
      'status': 'ongoing',
    };

    _ongoing.insert(0, chapterMap);
    await _saveToStorage();

    // If marked to appear in reels as live broadcast
    if (showInReelsAsLive) {
      LiveStreamsService.instance.registerStream(
        LiveStreamItem(
          id: newId,
          roomId: roomId,
          title: name,
          sheikhName: supervisor,
          sectionName: mainCategory,
          subSectionName: subCategory,
          viewerCount: 1,
          startedAt: DateTime.now(),
        ),
      );
    }

    changeNotifier.value++;
  }

  Future<void> endAndSaveChapter({
    required String roomId,
    required String title,
    String? durationFormatted,
    String? recordUrl,
  }) async {
    await init();
    
    // Find in ongoing or create finished entry
    Map<String, dynamic>? chapter;
    for (int i = 0; i < _ongoing.length; i++) {
      if (_ongoing[i]['roomId'] == roomId || _ongoing[i]['title'] == title) {
        chapter = _ongoing.removeAt(i);
        break;
      }
    }

    chapter ??= {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'supervisor': 'أنت (منشئ الحلقة)',
      'time': DateTime.now().toString().substring(0, 16),
      'subscribers': '1 / 20',
      'avatar': null,
    };

    chapter['is_finished'] = true;
    chapter['status'] = 'completed';
    chapter['duration'] = durationFormatted ?? '00:15:30';
    chapter['record_url'] = recordUrl ?? 'https://backup.qurango.net/radio/tarteel';
    chapter['saved_at'] = DateTime.now().toIso8601String();

    _finished.insert(0, chapter);
    await _saveToStorage();

    // Remove from live streams if it was active
    final liveId = chapter['id'] is int ? chapter['id'] as int : null;
    if (liveId != null) {
      LiveStreamsService.instance.removeStream(liveId);
    }

    changeNotifier.value++;
  }

  Future<void> _saveToStorage() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_ongoingKey, jsonEncode(_ongoing));
      await sp.setString(_finishedKey, jsonEncode(_finished));
    } catch (_) {}
  }
}
