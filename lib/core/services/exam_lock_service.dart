import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// خدمة حماية التسميع والمسابقات ومنع الغش في Android (تثبيت الشاشة + منع التصوير)
class ExamLockService {
  ExamLockService._();
  static final ExamLockService instance = ExamLockService._();

  static const MethodChannel _channel = MethodChannel('com.etqan.app/kiosk');

  Future<bool> startLockTask() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final res = await _channel.invokeMethod<bool>('startLockTask');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> stopLockTask() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final res = await _channel.invokeMethod<bool>('stopLockTask');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isLockTaskActive() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final res = await _channel.invokeMethod<bool>('isLockTaskActive');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> setSecureScreen(bool enabled) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod('setSecureScreen', {'enabled': enabled});
    } catch (_) {}
  }
}
