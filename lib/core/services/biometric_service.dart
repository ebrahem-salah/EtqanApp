import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _localAuth = LocalAuthentication();

  static const String _keyBiometricEnabled = 'etqan_biometric_enabled';
  static const String _keySavedPhone = 'etqan_saved_phone';
  static const String _keySavedToken = 'etqan_saved_token';

  /// Check if hardware supports biometrics and has enrolled fingerprints / face
  Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canAuthenticateWithBiometrics || isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  /// Get list of available biometric types (fingerprint, face, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Check if user has opted in to biometric login
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  /// Enable or disable biometric login
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, enabled);
  }

  /// Save phone number and session token for quick biometric resume
  Future<void> saveUserSession(String phone, {String? token}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySavedPhone, phone);
    if (token != null) {
      await prefs.setString(_keySavedToken, token);
    }
  }

  /// Retrieve saved phone number
  Future<String?> getSavedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySavedPhone);
  }

  /// Clear saved credentials on logout
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBiometricEnabled);
    await prefs.remove(_keySavedPhone);
    await prefs.remove(_keySavedToken);
  }

  /// Trigger biometric authentication prompt
  Future<bool> authenticate({String? customReason}) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      return await _localAuth.authenticate(
        localizedReason: customReason ?? 'يرجى تأكيد بصمة الإصبع أو FaceID لتسجيل الدخول إلى تطبيق إتقان',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
