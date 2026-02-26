// lib/features/admin/controllers/admin_order_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../orders/models/order_model.dart'; // Reusing our customer order model

class AdminOrderController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  var isLoading = false.obs;
  var allOrders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllOrders();
  }

  Future<void> fetchAllOrders() async {
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.get('/orders');
      
      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> orderData = response.data['data'];
        allOrders.value = orderData.map((json) => OrderModel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      Get.snackbar('Error', 'Failed to load store orders');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await _apiClient.dio.put('/orders/$orderId/status', data: {
        'status': newStatus
      });

      if (response.statusCode == 200 && response.data['success']) {
        // Update the local list so the UI changes instantly without re-fetching everything
        int index = allOrders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          // We trigger a re-fetch to keep it simple and ensure data integrity, 
          // or we can manually update the item. Let's just refetch for safety.
          fetchAllOrders(); 
          Get.snackbar('Success', 'Order marked as $newStatus', backgroundColor: const Color(0xFF4CAF50), colorText: const Color(0xFFFFFFFF));
        }
      }
    } on DioException catch (e) {
      Get.snackbar('Error', 'Failed to update status');
    }
  }
}