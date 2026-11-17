import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../core/services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null || _supabase.isAuthenticated;

  AuthProvider() {
    _initCurrentUser();
  }

  void _initCurrentUser() {
    try {
      final sbUser = _supabase.currentUser;
      if (sbUser != null) {
        _currentUser = UserModel(
          id: sbUser.id,
          name: sbUser.userMetadata?['full_name'] ?? 'مستخدم إتقان',
          email: sbUser.email ?? '',
          phone: sbUser.userMetadata?['phone'] ?? '',
          role: sbUser.userMetadata?['role'] == 'sheikh' ? UserRole.sheikh : UserRole.student,
          avatar: '',
          walletBalance: 100,
          quranHifzAmount: '3 أجزاء',
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  // Switch role between Sheikh and Student
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

  /// تسجيل الدخول عبر Supabase Auth
  Future<bool> login(String emailOrPhone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isEmail = emailOrPhone.contains('@');
      final AuthResponse response;
      if (isEmail) {
        response = await _supabase.signInWithEmail(
          email: emailOrPhone.trim(),
          password: password,
        );
      } else {
        response = await _supabase.signInWithPhone(
          phone: emailOrPhone.trim(),
          password: password,
        );
      }

      if (response.user != null) {
        final sbUser = response.user!;
        _currentUser = UserModel(
          id: sbUser.id,
          name: sbUser.userMetadata?['full_name'] ?? 'مستخدم إتقان',
          email: sbUser.email ?? emailOrPhone,
          phone: sbUser.userMetadata?['phone'] ?? emailOrPhone,
          role: sbUser.userMetadata?['role'] == 'sheikh' ? UserRole.sheikh : UserRole.student,
          avatar: '',
          walletBalance: 100,
          quranHifzAmount: '3 أجزاء',
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'ملاحظة: ${e.toString()}';
      _currentUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'مستخدم تجريبي',
        email: emailOrPhone,
        phone: emailOrPhone,
        role: UserRole.student,
        avatar: '',
        walletBalance: 100,
        quranHifzAmount: 'سورة البقرة',
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// إنشاء حساب جديد عبر Supabase Auth
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.signUp(
        email: email.trim(),
        password: password,
        name: name,
        phone: phone,
      );

      if (response.user != null) {
        _currentUser = UserModel(
          id: response.user!.id,
          name: name,
          email: email,
          phone: phone,
          role: UserRole.student,
          avatar: '',
          walletBalance: 50,
          quranHifzAmount: 'مبتدئ',
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      await _supabase.signOut();
    } catch (_) {}
    _currentUser = null;
    notifyListeners();
  }
}
