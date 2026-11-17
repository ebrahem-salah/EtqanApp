import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'https://etqan.site/api';
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
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Global error handling
          return handler.next(error);
        },
      ),
    );
  }

  // Auth Endpoints
  Future<Response> login(String emailOrPhone, String password) async {
    return await dio.post('/v1/auth/login', data: {
      'login': emailOrPhone,
      'password': password,
    });
  }

  Future<Response> register(Map<String, dynamic> userData) async {
    return await dio.post('/v1/auth/register', data: userData);
  }

  // Circles / Sessions
  Future<Response> getCircles({String? categoryId, String? gender}) async {
    return await dio.get('/v1/circles', queryParameters: {
      if (categoryId != null) 'category_id': categoryId,
      if (gender != null) 'gender': gender,
    });
  }

  // Zego Token Generator for session
  Future<Response> getZegoToken(String roomId, String userId) async {
    return await dio.post('/v1/zego/token', data: {
      'room_id': roomId,
      'user_id': userId,
    });
  }

  // Library & Broadcasts
  Future<Response> getLibraryBooks() async {
    return await dio.get('/v1/library');
  }

  Future<Response> getBroadcasts() async {
    return await dio.get('/v1/broadcasts');
  }
}
