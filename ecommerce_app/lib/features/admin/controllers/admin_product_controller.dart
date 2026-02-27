// lib/features/admin/controllers/admin_product_controller.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio;
import 'package:ecommerce_app/core/network/api_client.dart';
import 'package:ecommerce_app/features/admin/models/product_model.dart';
import 'package:get/get.dart';

class AdminProductController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  var isLoading = false.obs;
  var products = <ProductModel>[].obs;
  var selectedImages = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  // ── IMAGE UPLOAD ──────────────────────────────────────────────────────────

  Future<List<String>?> uploadMultipleImages(List<File> imageFiles) async {
    try {
      dio.FormData formData = dio.FormData();
      for (var file in imageFiles) {
        formData.files.add(MapEntry(
          'images',
          await dio.MultipartFile.fromFile(file.path,
              filename: file.path.split('/').last),
        ));
      }

      final response =
          await _apiClient.dio.post('/upload/multiple', data: formData);
      if (response.statusCode == 200 && response.data['success']) {
        return List<String>.from(response.data['imageUrls']);
      }
      return null;
    } on dio.DioException catch (e) {
      print("Multi Upload Error: ${e.response?.data}");
      return null;
    }
  }

  // ── FETCH ─────────────────────────────────────────────────────────────────

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.get('/products');

      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> productData = response.data['data'];
        products.value =
            productData.map((json) => ProductModel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      Get.snackbar('Error', 'Failed to fetch products');
      print(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  // ── CREATE ────────────────────────────────────────────────────────────────

  Future<bool> addProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _apiClient.dio.post('/products', data: productData);

      if (response.statusCode == 201 && response.data['success']) {
        products.add(ProductModel.fromJson(response.data['data']));
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

  // ── UPDATE ────────────────────────────────────────────────────────────────
  // We accept a plain Map so the screen decides which fields changed.
  // This keeps the controller flexible — it doesn't assume which fields
  // the edit screen exposes.

  Future<bool> updateProduct(
      String id, Map<String, dynamic> updatedData) async {
    try {
      isLoading.value = true;
      final response =
          await _apiClient.dio.put('/products/$id', data: updatedData);

      if (response.statusCode == 200 && response.data['success']) {
        // Update the local list in-place so the dashboard reflects changes
        // immediately without a full refetch.
        final updatedProduct = ProductModel.fromJson(response.data['data']);
        final index = products.indexWhere((p) => p.id == id);
        if (index != -1) {
          products[index] = updatedProduct;
          products.refresh();
        }
        return true;
      }
      return false;
    } on DioException catch (e) {
      Get.snackbar(
          'Error', e.response?.data['message'] ?? 'Failed to update product');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────

  Future<void> deleteProduct(String id) async {
    try {
      final response = await _apiClient.dio.delete('/products/$id');
      if (response.statusCode == 200) {
        products.removeWhere((product) => product.id == id);
        Get.snackbar('Success', 'Product deleted');
      }
    } on DioException catch (e) {
      Get.snackbar(
          'Error', e.response?.data['message'] ?? 'Failed to delete product');
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      dio.FormData formData = dio.FormData.fromMap({
        'image': await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _apiClient.dio.post('/upload', data: formData);

      if (response.statusCode == 200 && response.data is Map) {
        if (response.data['success'] == true) {
          return response.data['file'];
        }
      }
      return null;
    } on dio.DioException catch (e) {
      print("Upload Error: ${e.response?.statusCode} - ${e.response?.data}");
      Get.snackbar('Upload Failed', 'Could not upload image');
      return null;
    }
  }
}