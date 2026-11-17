import 'package:supabase_flutter/supabase_flutter.dart';

/// إعدادات ومفاتيح الربط مع سحابة Supabase الخاصة بمنظومة إتقان
class SupabaseConfig {
  static const String url = 'https://ngokeoqlimctcjkbmgtn.supabase.co';
  static const String anonKey = 'sb_publishable_vkDauPHxs9FyPOUziJkq4g_5JS2Md8o';
}

/// خدمة إدارة قواعد البيانات والمصادقة مع Supabase
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  /// العميل المباشر لـ Supabase
  SupabaseClient get client => Supabase.instance.client;

  /// خدمة المصادقة الرسمية
  GoTrueClient get auth => client.auth;

  /// المستخدم الحالي المسجل دخوله
  User? get currentUser => auth.currentUser;

  /// التحقق من حالة تسجيل الدخول
  bool get isAuthenticated => currentUser != null;

  /// تسجيل مستخدم جديد (طالب أو شيخ)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    String role = 'student',
  }) async {
    return await auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': name,
        'phone': phone,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// تسجيل الدخول برقم الجوال وكلمة المرور
  Future<AuthResponse> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    return await auth.signInWithPassword(
      phone: phone,
      password: password,
    );
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    await auth.signOut();
  }

  /// استعادة كلمة المرور عبر البريد
  Future<void> resetPasswordForEmail(String email) async {
    await auth.resetPasswordForEmail(email);
  }
}
