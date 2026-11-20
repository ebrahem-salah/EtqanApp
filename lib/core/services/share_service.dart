import 'package:flutter/services.dart';

class ShareService {
  static const MethodChannel _channel = MethodChannel('com.etqan.app/share');

  static Future<void> shareText({required String text, String title = 'Share text'}) async {
    try {
      await _channel.invokeMethod('shareText', {
        'text': text,
        'title': title,
      });
    } catch (_) {}
  }
}
