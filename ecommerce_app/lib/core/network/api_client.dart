// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late Dio dio;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  static bool _isLoggingOut = false;

  static VoidCallback? onUnauthorized;


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
      onError: (DioException e, handler) async {
        // Global error handling (e.g., if token expires and returns 401)
        if (e.response?.statusCode == 401) {
          if (!_isLoggingOut) {
            _isLoggingOut = true;

            // Fire the callback that AuthController registered.
            // If for some reason it hasn't been registered yet (e.g., a
            // request fires before AuthController.onInit runs), we do nothing
            // — the null-safe call handles that gracefully.
            onUnauthorized?.call();

            // Reset the flag after a short delay so future login sessions
            // aren't permanently locked. Without this, after re-login any
            // new 401 (e.g., a password-change invalidating old tokens) would
            // be silently swallowed.
            await Future.delayed(const Duration(seconds: 2));
            _isLoggingOut = false;
          }

          // Reject instead of next() — the screen that made this request no
          // longer exists after logout, so passing the error downstream would
          // trigger snackbars on a blank navigator stack.
          return handler.reject(e);
        }
        return handler.next(e);
      },
    ));
  }
}