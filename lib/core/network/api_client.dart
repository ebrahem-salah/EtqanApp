import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_config.dart';

/// Etqan Production API Client
/// Connects to Laravel 12.5 Backend on VPS / Domain
class ApiClient {
  static String get baseUrl => AppConfig.apiBaseUrl;
  static String get serverStorageUrl => AppConfig.storageBaseUrl;
  
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

  /// Post a new comment on a video
  Future<Response> postVideoComment(int videoId, String comment) async {
    return await dio.post('/videos/$videoId/comments', data: {
      'comment': comment,
    });
  }

  /// Like / Unlike a video comment
  Future<Response> toggleCommentLike(int videoId, int commentId) async {
    return await dio.post('/videos/$videoId/comments/$commentId/like');
  }

  /// Like / Unlike a video
  Future<Response> toggleLikeVideo(int videoId) async {
    return await dio.post('/videos/$videoId/like');
  }

  /// Upload / create new Reel video
  Future<Response> createVideo({
    required String description,
    String? videoUrl,
    dynamic videoFile,
  }) async {
    if (videoFile != null) {
      final formData = FormData.fromMap({
        'description': description,
        'video': videoFile,
      });
      return await dio.post('/videos', data: formData);
    }
    return await dio.post('/videos', data: {
      'description': description,
      if (videoUrl != null) 'video_url': videoUrl,
    });
  }

  /// Upload a local video file with real progress tracking (compressed to 720p)
  Future<Response> uploadVideoFile({
    required File file,
    required String description,
    void Function(int sent, int total)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'description': description,
      'video': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    return await dio.post(
      '/videos',
      data: formData,
      onSendProgress: (sent, total) {
        if (onProgress != null && total > 0) onProgress(sent, total);
      },
      options: Options(
        // رفع الفيديوهات قد يأخذ وقتاً أطول — timeout 5 دقائق
        sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 2),
      ),
    );
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

  /// Create new recitation class / circle
  Future<Response> createClass({
    required String name,
    required int categoryId,
    int? subCategoryId,
    required String startTime,
    int maxStudents = 20,
    String type = 'free',
    double price = 0.0,
    bool isPrivate = false,
    bool allowRecording = false,
    String? imageUrl,
  }) async {
    return await dio.post('/classes', data: {
      'name': name,
      'category_id': categoryId,
      if (subCategoryId != null) 'sub_category_id': subCategoryId,
      'start_time': startTime,
      'max_students': maxStudents,
      'type': type,
      'price': price,
      'is_private': isPrivate,
      'allow_recording': allowRecording,
      if (imageUrl != null) 'image': imageUrl,
    });
  }

  /// Toggle follow / friend
  Future<Response> toggleFriend(int userId) async {
    return await dio.post('/friends/toggle-follow', data: {
      'user_id': userId,
      'friend_id': userId,
    });
  }

  /// Get my friends list
  Future<Response> getMyFriends() async {
    return await dio.get('/friends/my-friends');
  }

  /// Delete class
  Future<Response> deleteClass(int classId) async {
    return await dio.delete('/classes/$classId');
  }

  /// Update user profile
  Future<Response> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? countryCode,
    String? avatar,
  }) async {
    return await dio.post('/profile', data: {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (countryCode != null) 'country_code': countryCode,
      if (avatar != null) 'avatar': avatar,
    });
  }

  /// Change password
  Future<Response> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await dio.post('/profile/change-password', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': confirmPassword,
    });
  }

  /// Delete account
  Future<Response> deleteAccount() async {
    return await dio.delete('/profile');
  }

  /// Get current authenticated user's uploaded videos
  Future<Response> getMyVideos() async {
    return await dio.get('/my-videos');
  }

  /// Get user videos
  Future<Response> getUserVideos(int userId) async {
    return await dio.get('/users/$userId/videos');
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

  /// Get specific class details
  Future<Response> getClassDetails(int classId) async {
    return await dio.get('/classes/$classId');
  }

  /// End class / circle with optional recording URL
  Future<Response> endClass(int classId, {String? recordUrl}) async {
    return await dio.post('/classes/$classId/end', data: {
      if (recordUrl != null) 'record_url': recordUrl,
    });
  }

  /// Upload or save class recording
  Future<Response> saveClassRecording(int classId, {String? recordUrl, String? filePath}) async {
    if (filePath != null) {
      final formData = FormData.fromMap({
        'recording': await MultipartFile.fromFile(filePath, filename: 'session_$classId.mp4'),
      });
      return await dio.post('/classes/$classId/recording', data: formData);
    } else {
      return await dio.post('/classes/$classId/recording', data: {
        if (recordUrl != null) 'record_url': recordUrl,
      });
    }
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

  /// Generate randomized Quran competition questions for student
  Future<Response> generateCompetitionQuestions({
    required int competitionId,
    required int studentId,
    int scopeJuz = 30,
    int questionCount = 10,
    int versesCount = 10,
  }) async {
    return await dio.post('/competitions/$competitionId/generate-questions', data: {
      'student_id': studentId,
      'scope_juz': scopeJuz,
      'question_count': questionCount,
      'verses_count': versesCount,
    });
  }

  /// Get generated questions for a student in a competition
  Future<Response> getStudentCompetitionQuestions({
    required int competitionId,
    required int studentId,
  }) async {
    return await dio.get('/competitions/$competitionId/student/$studentId/questions');
  }

  /// Submit rubric evaluation with error & hesitation deductions
  Future<Response> submitCompetitionEvaluation({
    required int competitionId,
    required int studentId,
    required List<Map<String, dynamic>> evaluations,
  }) async {
    return await dio.post('/competitions/$competitionId/submit-evaluation', data: {
      'student_id': studentId,
      'evaluations': evaluations,
    });
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

  /// List Supervisors
  Future<Response> getSupervisors() async {
    return await dio.get('/supervisors');
  }

  /// Get Sheikhs of a Supervisor
  Future<Response> getSupervisorSheikhs(int supervisorId) async {
    return await dio.get('/supervisors/$supervisorId/sheikhs');
  }

  // ================= 9. NOTIFICATIONS, FAQS & SUPPORT =================

  /// System notifications
  Future<Response> getNotifications() async {
    return await dio.get('/notifications');
  }

  /// Frequently Asked Questions
  Future<Response> getFaqs() async {
    return await dio.get('/faqs');
  }

  /// Get volunteer types / categories
  Future<Response> getVolunteerTypes() async {
    return await dio.get('/volunteer-types');
  }

  /// Submit volunteer request
  Future<Response> submitVolunteerRequest(Map<String, dynamic> data) async {
    return await dio.post('/volunteer-requests', data: data);
  }

  /// Get student appreciations
  Future<Response> getStudentAppreciations(int userId) async {
    return await dio.get('/students/$userId/appreciations');
  }

  /// Send appreciation
  Future<Response> sendAppreciation(int classId, Map<String, dynamic> data) async {
    return await dio.post('/classes/$classId/appreciations', data: data);
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
