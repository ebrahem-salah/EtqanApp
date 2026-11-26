import 'package:flutter/material.dart';
import '../../screens/call/live_recitation_room.dart';
import '../../screens/competitions/competitions_screen.dart';

/// خدمة إدارة الروابط العميقة والذكية (Deep Links & Universal Links)
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// إنشاء رابط مشاركة ذكي للحلقة القرآنية
  static String getCircleShareLink(int circleId, {String? circleTitle}) {
    final titleParam = circleTitle != null ? Uri.encodeComponent(circleTitle) : 'حلقة_قرآنية';
    return 'https://www.etqan.site/circle/$circleId?title=$titleParam';
  }

  /// إنشاء نص جاهز للمشاركة عبر واتساب وتطبيقات التواصل
  static String getCircleShareText({
    required int circleId,
    required String circleTitle,
    required String sheikhName,
  }) {
    final link = getCircleShareLink(circleId, circleTitle: circleTitle);
    return '''📖 دعوة للانضمام إلى $circleTitle
بإشراف فضيلة الشيخ: $sheikhName

اضغط على الرابط للدخول المباشر للحلقة في تطبيق إتقان:
$link
''';
  }

  /// تحليل وتوجيه الرابط عند النقر عليه من خارج التطبيق
  void handleIncomingUri(Uri uri) {
    debugPrint('معالجة الرابط العميق الوارد: $uri');

    // 1. معالجة روابط الحلقات (etqan://circle/110 أو https://www.etqan.site/circle/110)
    if (uri.pathSegments.contains('circle') || uri.host == 'circle') {
      int? circleId;
      if (uri.host == 'circle') {
        circleId = int.tryParse(uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '');
      } else {
        final index = uri.pathSegments.indexOf('circle');
        if (index != -1 && index + 1 < uri.pathSegments.length) {
          circleId = int.tryParse(uri.pathSegments[index + 1]);
        }
      }

      if (circleId != null && circleId > 0) {
        final circleTitle = uri.queryParameters['title'] ?? 'حلقة الإتقان المباشرة';
        _navigateToCircle(circleId, circleTitle);
        return;
      }
    }

    // 2. معالجة روابط المسابقات (etqan://competition/5 أو https://www.etqan.site/competition/5)
    if (uri.pathSegments.contains('competition') || uri.host == 'competition') {
      _navigateToCompetitions();
      return;
    }
  }

  /// التنقل المباشر لغرفة التلاوة
  void _navigateToCircle(int circleId, String circleTitle) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveRecitationRoom(
          roomId: 'room_srv_$circleId',
          classRoomId: circleId,
          circleTitle: circleTitle,
        ),
      ),
    );
  }

  /// التنقل المباشر للمسابقات
  void _navigateToCompetitions() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CompetitionsScreen(),
      ),
    );
  }
}
