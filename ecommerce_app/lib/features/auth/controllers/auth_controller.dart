import 'package:dio/dio.dart';
import 'package:ecommerce_app/core/constants/app_constants.dart';
import 'package:ecommerce_app/core/network/api_client.dart';
import 'package:ecommerce_app/features/auth/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class AuthController extends GetxController{
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();


  var isLoading = false.obs;
  var currentUser = Rxn<UserModel>();

  @override
  void onInit(){
    super.onInit();
    checkAuthStatus();
  }


  Future<void> checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 1));

    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    if (token != null) {
       try{
        isLoading.value = true;

        final response = await _apiClient.dio.get('/auth/me');
        if(response.statusCode == 200 && response.data['success']){
          currentUser.value = UserModel.fromJson(response.data['user']);
          _routeUserBasedOnRole();
        }
       } catch (e) {
        // token might be expired or invalid, so we log out the user
        await logout();
       } finally {
        isLoading.value = false;
       }
    } else {
      Get.offAllNamed('/login'); // if no token, go to login
    }
  }

  Future<void> login(String email, String password) async {
    try{
      isLoading.value = true;
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if(response.statusCode == 200 && response.data['success']){
        final token = response.data['token'];
        await _secureStorage.write(key: AppConstants.tokenKey, value: token);
        currentUser.value = UserModel.fromJson(response.data['user']);
        _routeUserBasedOnRole();
      } 
      // else {
      //   Get.snackbar('Login Failed', response.data['message'] ?? 'Unknown error');
      // }
    } on DioException catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup(String name, String email, String password) async {
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.post('/auth/signup', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201 && response.data['success']) {
        final token = response.data['token'];
        await _secureStorage.write(key: AppConstants.tokenKey, value: token);
        currentUser.value = UserModel.fromJson(response.data['user']);
        _routeUserBasedOnRole();
      }
    } on DioException catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    currentUser.value = null;
    Get.offAllNamed('/login');
  }

  void _routeUserBasedOnRole(){
    if(currentUser.value?.role == 'admin'){
      Get.offAllNamed('/admin-home');
    } else {
      Get.offAllNamed('/customer-home');
    }
  }

  void _handleError(DioException e) {
    // 1. PRINT THE EXACT ERROR TO THE CONSOLE
    print("=== DIO ERROR ===");
    print("Type: ${e.type}");
    print("Message: ${e.message}");
    if (e.response != null) {
      print("Status Code: ${e.response?.statusCode}");
      print("Data: ${e.response?.data}");
    }
    print("=================");

    String message = 'An error occurred';
    if (e.response != null && e.response?.data != null) {
      // If the backend sent a specific error message (like "Invalid credentials")
      message = e.response?.data['message'] ?? message;
    } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      message = "Connection timed out. Is the server running?";
    } else if (e.type == DioExceptionType.connectionError) {
      message = "Cannot connect to server. Check your IP/URL.";
    }

    Get.snackbar(
      'Login Failed', 
      message, 
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }


}

