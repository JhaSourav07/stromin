import 'package:dio/dio.dart';
import 'package:ecommerce_app/core/network/api_client.dart';
import 'package:ecommerce_app/features/admin/models/product_model.dart';
import 'package:get/get.dart';

class ShopController extends GetxController{
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
        products.value = productData
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }
    } on DioException catch (e) {
      Get.snackbar('Error', 'Failed to fetch products');
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}