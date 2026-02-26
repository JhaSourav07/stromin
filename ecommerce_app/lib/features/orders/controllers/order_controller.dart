// lib/features/orders/controllers/order_controller.dart
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/order_model.dart';

class OrderController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  var isLoading = false.obs;
  var myOrders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyOrders();
  }

  Future<void> fetchMyOrders() async {
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.get('/orders/myorders');
      
      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> orderData = response.data['data'];
        myOrders.value = orderData.map((json) => OrderModel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      Get.snackbar('Error', 'Failed to fetch order history');
      print(e.message);
    } finally {
      isLoading.value = false;
    }
  }
}