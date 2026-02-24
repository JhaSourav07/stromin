// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late Dio dio;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptors
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Read token from secure storage before sending request
        final token = await secureStorage.read(key: AppConstants.tokenKey);
        
        // If token exists, inject it into the headers
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options); // Continue with request
      },
      onError: (DioException e, handler) {
        // Global error handling (e.g., if token expires and returns 401)
        if (e.response?.statusCode == 401) {
          // In a real app, you might trigger a logout function here via GetX
          print("Unauthorized. Token might be expired.");
        }
        return handler.next(e);
      },
    ));
  }
}