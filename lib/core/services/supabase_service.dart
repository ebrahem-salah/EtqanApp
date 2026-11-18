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

  /// إرسال رمز التحقق OTP إلى رقم الجوال
  Future<void> signInWithOtp({required String phone}) async {
    await auth.signInWithOtp(
      phone: phone,
    );
  }

  /// التحقق من رمز OTP المدخل من قبل المستخدم وتسجيل الدخول
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) async {
    return await auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  /// بث حي لمقاطع الريلز والمواعظ (Realtime Reels Stream)
  Stream<List<Map<String, dynamic>>> getReelsStream() {
    return client
        .from('reels')
        .stream(primaryKey: ['id'])
        .order('id', ascending: true);
  }

  /// جلب مقاطع الريلز دفعة واحدة
  Future<List<Map<String, dynamic>>> getReels() async {
    final response = await client
        .from('reels')
        .select()
        .order('id', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// بث حي للحلقات الجارية والقادمة (Realtime Live Circles Stream)
  Stream<List<Map<String, dynamic>>> getLiveCirclesStream() {
    return client
        .from('circles')
        .stream(primaryKey: ['id'])
        .order('start_time', ascending: true);
  }

  /// جلب كافة الأقسام الرئيسية والمناهج الفرعية من السحابة
  Future<List<Map<String, dynamic>>> getCategoriesWithSubcategories() async {
    final response = await client
        .from('categories')
        .select('*, subcategories(*)')
        .order('sort_order', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// حجز جلسة تسميع جديدة مع الشيخ وتخزينها في السحابة
  Future<Map<String, dynamic>> createBooking({
    required String studentName,
    required String sheikhName,
    required String circleTitle,
    required String timeSlot,
    required String roomId,
    String? notes,
  }) async {
    final data = {
      'student_name': studentName,
      'sheikh_name': sheikhName,
      'circle_title': circleTitle,
      'time_slot': timeSlot,
      'room_id': roomId,
      'status': 'confirmed',
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    };
    final res = await client.from('circle_bookings').insert(data).select().single();
    return res;
  }

  /// جلب حجوزات الطالب المسجلة
  Future<List<Map<String, dynamic>>> getStudentBookings(String studentName) async {
    final response = await client
        .from('circle_bookings')
        .select()
        .eq('student_name', studentName)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// بث الإشعارات الحية للمستخدم
  Stream<List<Map<String, dynamic>>> getNotificationsStream() {
    return client
        .from('push_notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  /// تسجيل معاملة مالية أو شحن محفظة
  Future<void> recordWalletTransaction({
    required double amount,
    required int points,
    required String paymentMethod,
    required String transactionType,
    String? referenceNumber,
  }) async {
    await client.from('wallet_transactions').insert({
      'amount': amount,
      'points_credited': points,
      'payment_method': paymentMethod,
      'transaction_type': transactionType,
      'status': 'completed',
      'reference_number': referenceNumber ?? 'TXN_${DateTime.now().millisecondsSinceEpoch}',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// تسجيل تقييم تلاوة الطالب وإصدار الشهادة
  Future<Map<String, dynamic>> submitEvaluation({
    required String studentName,
    required String sheikhName,
    required int correctScore,
    required int fluencyScore,
    required int tajweedScore,
    required int stopsScore,
  }) async {
    final totalPercentage = correctScore + fluencyScore + tajweedScore + stopsScore;
    final certCode = 'ETQAN-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final data = {
      'student_name': studentName,
      'sheikh_name': sheikhName,
      'correct_score': correctScore,
      'fluency_score': fluencyScore,
      'tajweed_score': tajweedScore,
      'stops_score': stopsScore,
      'total_percentage': totalPercentage,
      'grade_tier': totalPercentage >= 90 ? 'ممتاز مرتفع' : totalPercentage >= 80 ? 'جيد جداً' : 'جيد',
      'certificate_code': certCode,
      'created_at': DateTime.now().toIso8601String(),
    };

    return await client.from('evaluations').insert(data).select().single();
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
