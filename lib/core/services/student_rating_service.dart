import '../network/api_client.dart';

class StudentRatingSummary {
  final double averageOutOf10;
  final int percentage;
  final double starsOutOf5;
  final int evaluatedCount;
  final int thankCount;
  final int warningCount;
  final String gradeLabel;
  final List<Map<String, dynamic>> records;

  const StudentRatingSummary({
    required this.averageOutOf10,
    required this.percentage,
    required this.starsOutOf5,
    required this.evaluatedCount,
    required this.thankCount,
    required this.warningCount,
    required this.gradeLabel,
    required this.records,
  });

  static const empty = StudentRatingSummary(
    averageOutOf10: 0.0,
    percentage: 0,
    starsOutOf5: 0.0,
    evaluatedCount: 0,
    thankCount: 0,
    warningCount: 0,
    gradeLabel: 'لم يُقيّم بعد',
    records: [],
  );
}

/// خدمة حساب التقييم العام التراكمي للطالب من تقييماته الحقيقية في السيرفر
class StudentRatingService {
  StudentRatingService._();
  static final StudentRatingService instance = StudentRatingService._();

  final ApiClient _apiClient = ApiClient();

  Future<StudentRatingSummary> fetchStudentRating(
    int userId, {
    double fallbackServerRating = 0.0,
  }) async {
    final res = await _apiClient.getStudentAppreciations(userId);
    if (res.statusCode == 200 && res.data != null) {
      final List raw = res.data['data'] is List ? res.data['data'] : [];
      return computeFromList(raw, fallbackServerRating: fallbackServerRating);
    }
    return StudentRatingSummary.empty;
  }

  StudentRatingSummary computeFromList(
    List rawItems, {
    double fallbackServerRating = 0.0,
  }) {
    if (rawItems.isEmpty) {
      if (fallbackServerRating > 0) {
        final double normalized = fallbackServerRating <= 5.0
            ? fallbackServerRating * 2.0
            : (fallbackServerRating <= 10.0 ? fallbackServerRating : fallbackServerRating / 10.0);
        return StudentRatingSummary(
          averageOutOf10: normalized,
          percentage: (normalized * 10).round().clamp(0, 100),
          starsOutOf5: (normalized / 2.0).clamp(0.0, 5.0),
          evaluatedCount: 0,
          thankCount: 0,
          warningCount: 0,
          gradeLabel: _labelForScore(normalized),
          records: const [],
        );
      }
      return StudentRatingSummary.empty;
    }

    int thanks = 0;
    int warnings = 0;
    double sum = 0.0;
    final List<Map<String, dynamic>> parsed = [];

    for (final item in rawItems) {
      if (item is! Map) continue;
      final String type = (item['type'] ?? 'thank').toString();
      final String msg = (item['message'] ?? '').toString();
      final double? parsedScore = extractScore10(msg);
      final double effectiveScore = parsedScore ?? (type == 'warning' ? 6.0 : 9.5);

      if (type == 'warning') {
        warnings++;
      } else {
        thanks++;
      }
      sum += effectiveScore;

      parsed.add({
        'id': item['id'],
        'class_id': item['class_id'],
        'student_id': item['student_id'],
        'type': type,
        'message': msg,
        'score': effectiveScore,
        'has_numeric_score': parsedScore != null,
        'created_at': (item['created_at'] ?? '').toString(),
        'sheikh_name': item['class']?['creator']?['name']?.toString() ??
            item['sheikh']?['name']?.toString() ??
            'شيخ الحلقة',
        'circle_name': item['class']?['name']?.toString() ?? 'حلقة رقم ${item['class_id'] ?? ''}',
      });
    }

    parsed.sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));

    final double avg = parsed.isEmpty ? 0.0 : (sum / parsed.length);
    return StudentRatingSummary(
      averageOutOf10: avg,
      percentage: (avg * 10).round().clamp(0, 100),
      starsOutOf5: (avg / 2.0).clamp(0.0, 5.0),
      evaluatedCount: parsed.length,
      thankCount: thanks,
      warningCount: warnings,
      gradeLabel: parsed.isEmpty ? 'لم يُقيّم بعد' : _labelForScore(avg),
      records: parsed,
    );
  }

  static double? extractScore10(String message) {
    final m = RegExp(r'(\d+(?:\.\d+)?)\s*/\s*10').firstMatch(message);
    if (m == null) return null;
    final v = double.tryParse(m.group(1) ?? '');
    if (v == null) return null;
    return v.clamp(0.0, 10.0);
  }

  static String _labelForScore(double score10) {
    if (score10 >= 9.0) return 'ممتاز 🌟';
    if (score10 >= 8.0) return 'جيد جداً مرتفع 👏';
    if (score10 >= 7.0) return 'جيد جداً 👍';
    if (score10 >= 6.0) return 'مقبول ⚠️';
    return 'يحتاج متابعة 📖';
  }
}
