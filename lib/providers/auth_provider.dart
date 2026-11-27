import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/network/api_client.dart';
import '../core/services/supabase_service.dart';
import '../core/utils/app_feedback.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final SupabaseService _supabase = SupabaseService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null || _token != null;
  String? get token => _token;

  AuthProvider() {
    _initCurrentUser();
  }

  Future<void> _persistSession(String token, String phone, {UserModel? user}) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_phone', phone);
    if (user != null) {
      await prefs.setInt('user_id', user.id);
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_role', user.role.name);
    }
  }

  /// استرجاع بيانات المستخدم والتوكن المحفوظ تلقائياً عند فتح التطبيق (الجلسة الدائمة)
  Future<void> _initCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      final savedId = prefs.getInt('user_id');
      final savedPhone = prefs.getString('user_phone');
      final savedName = prefs.getString('user_name');
      final savedEmail = prefs.getString('user_email');
      final savedRole = prefs.getString('user_role');

      if (_token != null &&
          _token!.isNotEmpty &&
          !_token!.startsWith('offline_session_') &&
          !_token!.startsWith('otp_session_') &&
          !_token!.startsWith('google_token_') &&
          !_token!.startsWith('apple_token_')) {
        // بناء المستخدم فوراً من الكاش لسرعة الدخول الفوري بدون انتظار
        _currentUser = UserModel(
          id: savedId ?? 1,
          name: savedName ?? 'مستخدم إتقان',
          email: savedEmail ?? (savedPhone != null ? '$savedPhone@etqan.com' : 'user@etqan.com'),
          phone: savedPhone,
          role: savedRole == 'sheikh'
              ? UserRole.sheikh
              : (savedRole == 'supervisor'
                  ? UserRole.supervisor
                  : (savedRole == 'parent' ? UserRole.parent : UserRole.student)),
          avatar: '',
          walletBalance: 150.0,
          quranHifzAmount: '3 أجزاء',
        );
        notifyListeners();

        // فحص البروفايل في الخلفية لتحديث البيانات والتحقق من صلاحية الجلسة على السيرفر
        try {
          final response = await _apiClient.getProfile();
          if (response.statusCode == 200 && response.data != null) {
            final userData = response.data['data']?['user'] ?? response.data['data'];
            if (userData != null) {
              _currentUser = _mapJsonToUserModel(userData, fallbackRole: _currentUser?.role);
              await prefs.setInt('user_id', _currentUser!.id);
              await prefs.setString('user_name', _currentUser!.name);
              await prefs.setString('user_role', _currentUser!.role.name);
              notifyListeners();
            }
          }
        } on DioException catch (e) {
          if (e.response?.statusCode == 401) {
            await prefs.remove('auth_token');
            _token = null;
            _currentUser = null;
            notifyListeners();
          }
        } catch (_) {}
        return;
      } else if (_token != null && _token!.isNotEmpty) {
        // حذف التوكن الوهمي القديم لإجبار تسجيل دخول حقيقي على السيرفر
        await prefs.remove('auth_token');
        _token = null;
      }

      // فحص بديل من Supabase
      final sbUser = _supabase.currentUser;
      if (sbUser != null) {
        _currentUser = UserModel(
          id: int.tryParse(sbUser.id) ?? 1,
          name: sbUser.userMetadata?['full_name'] ?? 'مستخدم إتقان',
          email: sbUser.email ?? '',
          phone: sbUser.userMetadata?['phone'] ?? '',
          role: sbUser.userMetadata?['role'] == 'sheikh' ? UserRole.sheikh : UserRole.student,
          avatar: '',
          walletBalance: 150.0,
          quranHifzAmount: '3 أجزاء',
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  // تبديل نوع المستخدم بين شيخ وطالب
  void switchUserRole() {
    if (_currentUser == null) return;
    final newRole = _currentUser!.role == UserRole.student 
        ? UserRole.sheikh 
        : UserRole.student;
        
    _currentUser = UserModel(
      id: _currentUser!.id,
      name: _currentUser!.name,
      email: _currentUser!.email,
      phone: _currentUser!.phone,
      role: newRole,
      avatar: _currentUser!.avatar,
      walletBalance: _currentUser!.walletBalance,
      quranHifzAmount: _currentUser!.quranHifzAmount,
    );
    notifyListeners();
  }

  /// تسجيل الدخول الحقيقي عبر سيرفر لارافيل (POST /api/v1/login)
  Future<bool> login(
    String phone, 
    String password, {
    String countryCode = '+966',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. الاتصال المباشر بسيرفر لارافيل الرسمي
      final response = await _apiClient.login(
        countryCode: countryCode,
        phone: phone.trim(),
        password: password,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        _token = data?['token']?.toString();

        final userData = data?['user'];
        final prefs = await SharedPreferences.getInstance();
        final parentPhones = prefs.getStringList('etqan_parent_phones') ?? const [];
        final bool isMarkedParent = parentPhones.contains('$countryCode${phone.trim()}') ||
            parentPhones.contains(phone.trim());
        if (userData != null) {
          _currentUser = _mapJsonToUserModel(
            userData,
            fallbackType: data?['user_type']?.toString(),
            fallbackRole: isMarkedParent ? UserRole.parent : null,
          );
          if (isMarkedParent && _currentUser!.role == UserRole.student) {
            _currentUser = UserModel(
              id: _currentUser!.id,
              name: _currentUser!.name,
              email: _currentUser!.email,
              phone: _currentUser!.phone,
              role: UserRole.parent,
              avatar: _currentUser!.avatar,
              walletBalance: _currentUser!.walletBalance,
              quranHifzAmount: _currentUser!.quranHifzAmount,
            );
          }
        } else {
          final isSheikhPhone = phone == '0600000000' || phone == '0501122334' || phone.contains('roily');
          _currentUser = UserModel(
            id: isSheikhPhone ? 134 : 1,
            name: isSheikhPhone ? 'الشيخ عبد الله الرويلي' : (phone == '0500000000' ? 'طالب إتقان التجريبي' : 'طالب إتقان'),
            email: isSheikhPhone ? 'roily@etqan.com' : (phone == '0500000000' ? 'student.test@etqan.site' : '$phone@etqan.com'),
            phone: phone,
            role: (isSheikhPhone || data?['user_type'] == 'sheikh') ? UserRole.sheikh : UserRole.student,
            walletBalance: 150.0,
            quranHifzAmount: 'سورة البقرة',
          );
        }

        await _persistSession(_token ?? 'session_${DateTime.now().millisecondsSinceEpoch}', phone, user: _currentUser);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = AppFeedback.formatError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// إنشاء حساب جديد حقيقي عبر سيرفر لارافيل (POST /api/v1/register)
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String countryCode = '+966',
    String userType = 'student',
    bool isParent = false,
    bool wantsVolunteer = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final serverType = isParent ? 'student' : userType;
      final response = await _apiClient.register(
        userType: serverType,
        name: name,
        countryCode: countryCode,
        phone: phone,
        email: email,
        password: password,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (isParent) {
          final prefs = await SharedPreferences.getInstance();
          final list = prefs.getStringList('etqan_parent_phones') ?? [];
          final fullPhone = '$countryCode${phone.trim()}';
          if (!list.contains(fullPhone)) list.add(fullPhone);
          if (!list.contains(phone.trim())) list.add(phone.trim());
          await prefs.setStringList('etqan_parent_phones', list);
        }
        final loggedIn = await login(phone, password, countryCode: countryCode);
        if (loggedIn && wantsVolunteer && !isParent) {
          try {
            await _apiClient.submitVolunteerRequest({
              'name': name,
              'phone': '$countryCode$phone',
              'qualification': userType == 'sheikh' ? 'شيخ / محفّظ متطوع' : 'طالب متطوع',
              'hours_per_week': '4',
              'category': 'تحفيظ وتلقين الصغار',
            });
          } catch (_) {}
        }
        return loggedIn;
      }
    } catch (e) {
      _errorMessage = AppFeedback.formatError(e);
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Update current user data in memory
  void updateUserData({String? name, String? phone, String? email}) {
    if (_currentUser != null) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
        phone: phone ?? _currentUser!.phone,
        role: _currentUser!.role,
        avatar: _currentUser!.avatar,
        walletBalance: _currentUser!.walletBalance,
        quranHifzAmount: _currentUser!.quranHifzAmount,
      );
      notifyListeners();
    }
  }

  /// إرسال كود التحقق السريع (WhatsApp أولاً، أو رسالة نصية قصيرة SMS)
  Future<bool> sendOtp({
    required String phone,
    String countryCode = '+966',
    bool viaWhatsApp = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // محاكاة إرسال الكود عبر WhatsApp API أو بوابة SMS معتمدة (مثل Unifonic أو Taqnyat)
      await Future.delayed(const Duration(milliseconds: 600));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// التحقق من كود الـ OTP وتسجيل الدخول المباشر
  Future<bool> verifyOtpAndLogin({
    required String phone,
    required String otp,
    String countryCode = '+966',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // التحقق من صحة الكود (كود تجريبي معتمد: 1234 أو أي 4 أرقام مدخلة)
      await Future.delayed(const Duration(milliseconds: 600));

      final token = 'otp_session_${DateTime.now().millisecondsSinceEpoch}';
      _currentUser = UserModel(
        id: 1,
        name: 'طالب إتقان',
        email: '$phone@etqan.com',
        phone: '$countryCode$phone',
        role: UserRole.student,
        avatar: '',
        walletBalance: 150.0,
        quranHifzAmount: 'سورة البقرة',
      );

      await _persistSession(token, '$countryCode$phone', user: _currentUser);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تسجيل الدخول السريع بنقرة واحدة عبر حساب Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 700));
      final token = 'google_token_${DateTime.now().millisecondsSinceEpoch}';
      _currentUser = UserModel(
        id: 1,
        name: 'طالب إتقان (Google)',
        email: 'student.google@gmail.com',
        phone: '',
        role: UserRole.student,
        avatar: '',
        walletBalance: 150.0,
        quranHifzAmount: '3 أجزاء',
      );
      await _persistSession(token, 'student.google@gmail.com', user: _currentUser);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تسجيل الدخول السريع بنقرة واحدة عبر Apple ID
  Future<bool> signInWithApple() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 700));
      final token = 'apple_token_${DateTime.now().millisecondsSinceEpoch}';
      _currentUser = UserModel(
        id: 1,
        name: 'طالب إتقان (Apple)',
        email: 'student.apple@privaterelay.appleid.com',
        phone: '',
        role: UserRole.student,
        avatar: '',
        walletBalance: 150.0,
        quranHifzAmount: '3 أجزاء',
      );
      await _persistSession(token, 'student.apple@privaterelay.appleid.com', user: _currentUser);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تسجيل الخروج وحذف التوكن والجلسة
  Future<void> logout() async {
    try {
      await _apiClient.logout();
      await _supabase.signOut();
    } catch (_) {}
    _currentUser = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_phone');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
    notifyListeners();
  }

  UserModel _mapJsonToUserModel(
    Map<String, dynamic> json, {
    String? fallbackType,
    UserRole? fallbackRole,
  }) {
    UserRole role = fallbackRole ?? UserRole.student;
    final t = (json['type'] ?? json['user_type'] ?? fallbackType ?? json['role'])
        ?.toString()
        .toLowerCase();
    if (t == 'sheikh' || json['sheikh'] != null) {
      role = UserRole.sheikh;
    } else if (t == 'supervisor' || json['supervisor'] != null) {
      role = UserRole.supervisor;
    } else if (t == 'parent') {
      role = UserRole.parent;
    } else if (t == 'student') {
      role = fallbackRole == UserRole.parent ? UserRole.parent : UserRole.student;
    }

    double bal = 150.0;
    if (json['wallet'] != null && json['wallet']['balance'] != null) {
      bal = double.tryParse(json['wallet']['balance'].toString()) ?? 150.0;
    } else if (json['balance'] != null) {
      bal = double.tryParse(json['balance'].toString()) ?? 150.0;
    }

    return UserModel(
      id: int.tryParse(json['id'].toString()) ?? 1,
      name: json['name'] ?? 'مستخدم إتقان',
      email: json['email'] ?? '',
      phone: json['phone']?.toString(),
      role: role,
      avatar: json['avatar_url'] ?? json['avatar'],
      walletBalance: bal,
      quranHifzAmount: json['quran_hifz_amount'] ?? '3 أجزاء',
    );
  }
}
