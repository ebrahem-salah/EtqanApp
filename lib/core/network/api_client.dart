import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Etqan Production API Client
/// Connects to Laravel 12.5 Backend on https://www.etqan.site/api/v1
class ApiClient {
  static const String baseUrl = 'https://www.etqan.site/api/v1';
  static const String serverStorageUrl = 'https://www.etqan.site/storage';
  
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Language': 'ar',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('auth_token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {}
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Global error handling and logging
          return handler.next(error);
        },
      ),
    );
  }

  // ================= 1. AUTHENTICATION =================
  
  /// Login via phone & country_code (e.g. +966, 0501111111)
  Future<Response> login({
    required String countryCode,
    required String phone,
    required String password,
  }) async {
    final response = await dio.post('/login', data: {
      'country_code': countryCode,
      'phone': phone,
      'password': password,
    });

    if (response.statusCode == 200 && response.data != null) {
      final token = response.data['data']?['token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token.toString());
      }
    }
    return response;
  }

  /// Register student / sheikh
  Future<Response> register({
    required String userType, // 'student' or 'sheikh'
    required String name,
    required String countryCode,
    required String phone,
    required String email,
    required String password,
    String? gender,
  }) async {
    return await dio.post('/register', data: {
      'user_type': userType,
      'name': name,
      'country_code': countryCode,
      'phone': phone,
      'email': email,
      'password': password,
      if (gender != null) 'gender': gender,
    });
  }

  /// User profile
  Future<Response> getProfile() async {
    return await dio.get('/profile');
  }

  /// Logout
  Future<Response> logout() async {
    final res = await dio.post('/auth/logout');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    return res;
  }

  // ================= 2. VIDEOS & REELS FEED =================

  /// Get public video reels
  Future<Response> getVideos({int page = 1}) async {
    return await dio.get('/videos', queryParameters: {'page': page});
  }

  /// Get single video details
  Future<Response> getVideoDetails(int videoId) async {
    return await dio.get('/videos/$videoId');
  }

  /// Get comments for a video
  Future<Response> getVideoComments(int videoId) async {
    return await dio.get('/videos/$videoId/comments');
  }

  /// Like / Unlike a video
  Future<Response> toggleLikeVideo(int videoId) async {
    return await dio.post('/videos/$videoId/like');
  }

  // ================= 3. CATEGORIES & LEARNING LEVELS =================

  /// Get 124 Quran categories (Noorani, Quran Hifz, Ahda' Thawab, Sunnah/Fiqh)
  Future<Response> getCategories() async {
    return await dio.get('/categories');
  }

  // ================= 4. CLASSES & RECITATION CIRCLES =================

  /// List available classes / circles
  Future<Response> getClasses({int? categoryId, int page = 1}) async {
    return await dio.get('/classes', queryParameters: {
      if (categoryId != null) 'category_id': categoryId,
      'page': page,
    });
  }

  /// Classes created by user
  Future<Response> getMyClasses() async {
    return await dio.get('/classes/my-classes');
  }

  /// Classes joined by user
  Future<Response> getMyJoinedClasses() async {
    return await dio.get('/classes/my-joined-classes');
  }

  /// Join a free class
  Future<Response> joinClass(int classId) async {
    return await dio.post('/classes/$classId/join');
  }

  /// Leave a class
  Future<Response> leaveClass(int classId) async {
    return await dio.post('/classes/$classId/leave');
  }

  /// Get class group chat messages
  Future<Response> getClassMessages(int classId, {int page = 1}) async {
    return await dio.get('/classes/$classId/messages', queryParameters: {'page': page});
  }

  /// Send message inside class
  Future<Response> sendClassMessage(int classId, String text) async {
    return await dio.post('/classes/$classId/messages', data: {'text': text});
  }

  /// Get recitation scoring & appreciations
  Future<Response> getClassAppreciations(int classId) async {
    return await dio.get('/classes/$classId/appreciations');
  }

  // ================= 5. GOLDEN COMPETITIONS =================

  /// List active competitions
  Future<Response> getCompetitions() async {
    return await dio.get('/competitions');
  }

  /// Get competition participants and leaderboard
  Future<Response> getCompetitionParticipants(int competitionId) async {
    return await dio.get('/competitions/$competitionId/participants');
  }

  /// Join competition (student)
  Future<Response> joinCompetition(int competitionId) async {
    return await dio.post('/competitions/$competitionId/join');
  }

  /// Calculate competition rankings
  Future<Response> calculateCompetitionRankings(int competitionId) async {
    return await dio.post('/competitions/$competitionId/calculate-rankings');
  }

  // ================= 6. BROADCASTS & RADIOS =================

  /// Quran & Hadith 24/7 radio broadcasts
  Future<Response> getBroadcasts({int page = 1}) async {
    return await dio.get('/broadcasts', queryParameters: {'page': page});
  }

  // ================= 7. LIBRARY & MATERIALS =================

  /// Quranic books & educational documents
  Future<Response> getLibraryBooks({int page = 1}) async {
    return await dio.get('/library', queryParameters: {'page': page});
  }

  // ================= 8. SHEIKHS & SUPERVISORS =================

  /// List certified Sheikhs
  Future<Response> getSheikhs() async {
    return await dio.get('/sheikhs');
  }

  // ================= 9. NOTIFICATIONS & FAQS =================

  /// System notifications
  Future<Response> getNotifications() async {
    return await dio.get('/notifications');
  }

  /// Frequently Asked Questions
  Future<Response> getFaqs() async {
    return await dio.get('/faqs');
  }

  // ================= 10. WALLET & PAYMENTS (Official API) =================

  /// Get user's wallet balance and transactions from /my-wallet
  Future<Response> getMyWallet({int page = 1, int perPage = 20}) async {
    return await dio.get('/my-wallet', queryParameters: {
      'page': page,
      'per_page': perPage,
    });
  }

  /// Add balance to wallet (recharge)
  Future<Response> addWalletBalance({
    required int userId,
    required double amount,
    String? description,
    String? referenceNo,
  }) async {
    return await dio.post('/users/$userId/wallet/add', data: {
      'amount': amount,
      'description': description ?? 'شحن رصيد المحفظة',
      if (referenceNo != null) 'reference_no': referenceNo,
    });
  }

  /// Deduct balance from wallet (booking / paid session)
  Future<Response> deductWalletBalance({
    required int userId,
    required double amount,
    String? description,
  }) async {
    return await dio.post('/users/$userId/wallet/deduct', data: {
      'amount': amount,
      'description': description ?? 'خصم حجز جلسة مدفوعة',
    });
  }
}
