import 'package:dio/dio.dart';
import 'package:ecommerce_app/core/network/api_client.dart';
import 'package:ecommerce_app/features/auth/models/product_model.dart';
import 'package:get/get.dart';

class AdminProductController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  var isLoading = false.obs;
  var products = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.get('/products');
      
      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> productData = response.data['data'];
        products.value = productData.map((json) => ProductModel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      Get.snackbar('Error', 'Failed to fetch products');
      print(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _apiClient.dio.post('/products', data: productData);
      
      if (response.statusCode == 201 && response.data['success']) {
        products.add(ProductModel.fromJson(response.data['data']));
        // Get.snackbar('Success', 'Product added successfully');
        return true;
      }
      return false;
    } on DioException catch (e) {
      Get.snackbar('Error', e.response?.data['message'] ?? 'Failed to add product');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final response = await _apiClient.dio.delete('/products/$id');
      if (response.statusCode == 200) {
        // Remove from local list to update UI
        products.removeWhere((product) => product.id == id);
        Get.snackbar('Success', 'Product deleted');
      }
    } on DioException catch (e) {
      Get.snackbar('Error', e.response?.data['message'] ?? 'Failed to delete product');
    }
  }



}