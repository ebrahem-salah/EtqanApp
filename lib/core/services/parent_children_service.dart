import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'student_rating_service.dart';

class LinkedChildItem {
  final int studentId;
  final String name;
  final String code;

  const LinkedChildItem({
    required this.studentId,
    required this.name,
    required this.code,
  });

  factory LinkedChildItem.fromJson(Map<String, dynamic> json) {
    final sid = int.tryParse('${json['student_id'] ?? 0}') ?? 0;
    return LinkedChildItem(
      studentId: sid,
      name: (json['name'] ?? 'طالب #$sid').toString(),
      code: (json['code'] ?? 'ETQ-$sid').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'name': name,
        'code': code,
      };
}

/// خدمة ربط حساب الوالد بأطفاله ومتابعة تقييمهم وحضورهم وغيابهم وإشعاراته
class ParentChildrenService {
  ParentChildrenService._();
  static final ParentChildrenService instance = ParentChildrenService._();

  static const String _storagePrefix = 'etqan_parent_children_v1_';
  static const String _alertSeenPrefix = 'etqan_parent_seen_alert_v1_';

  static String buildFollowCode(int studentId) => 'ETQ-$studentId';

  static int? parseStudentId(String input) {
    final cleaned = input.trim().toUpperCase().replaceAll('ETQ-', '').replaceAll('#', '');
    final id = int.tryParse(cleaned);
    if (id != null && id > 0) return id;
    final digits = RegExp(r'\d+').firstMatch(cleaned)?.group(0);
    if (digits != null) {
      final parsed = int.tryParse(digits);
      if (parsed != null && parsed > 0) return parsed;
    }
    return null;
  }

  Future<List<LinkedChildItem>> getChildren(int parentUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_storagePrefix$parentUserId');
    if (raw == null || raw.isEmpty) return [];
    try {
      final List list = jsonDecode(raw);
      return list
          .map((e) => LinkedChildItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .where((c) => c.studentId > 0)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addChild(
    int parentUserId, {
    required int studentId,
    String? name,
  }) async {
    final list = await getChildren(parentUserId);
    final code = buildFollowCode(studentId);
    final cleanName = (name != null && name.trim().isNotEmpty) ? name.trim() : 'الابن ($code)';
    final idx = list.indexWhere((c) => c.studentId == studentId);
    if (idx >= 0) {
      list[idx] = LinkedChildItem(studentId: studentId, name: cleanName, code: code);
    } else {
      list.add(LinkedChildItem(studentId: studentId, name: cleanName, code: code));
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_storagePrefix$parentUserId',
      jsonEncode(list.map((c) => c.toJson()).toList()),
    );
  }

  Future<void> removeChild(int parentUserId, int studentId) async {
    final list = await getChildren(parentUserId);
    list.removeWhere((c) => c.studentId == studentId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_storagePrefix$parentUserId',
      jsonEncode(list.map((c) => c.toJson()).toList()),
    );
  }

  /// إطلاق إشعار محلي لولي الأمر عند رصد غياب جديد أو عدم تسميع للطفل
  Future<bool> checkAndNotifyNewAlert({
    required int parentUserId,
    required LinkedChildItem child,
    required StudentRatingSummary summary,
  }) async {
    final alert = summary.latestAlert;
    if (alert == null) return false;

    final String alertKey = '${alert['id'] ?? ''}_${alert['created_at'] ?? ''}';
    if (alertKey.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    final seenKey = '$_alertSeenPrefix${parentUserId}_${child.studentId}';
    final lastSeen = prefs.getString(seenKey);
    if (lastSeen == alertKey) return false;

    await prefs.setString(seenKey, alertKey);
    final status = alert['attendance_status']?.toString() ?? '';
    final String title = status == 'absent'
        ? '🚨 تنبيه غياب: ${child.name}'
        : '⚠️ تنبيه عدم تسميع: ${child.name}';
    final String body = (alert['message'] ?? 'يرجى متابعة حضور الابن في الحلقة').toString();

    await NotificationService().showInstantNotification(
      id: 7000 + child.studentId,
      title: title,
      body: body,
    );
    return true;
  }
}
