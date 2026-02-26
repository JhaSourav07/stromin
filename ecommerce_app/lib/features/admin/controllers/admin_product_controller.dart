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

  Future<List<String>?> uploadMultipleImages(List<File> imageFiles) async {
    try {
      dio.FormData formData = dio.FormData();
      
      // Add multiple files to the FormData under the same key 'images'
      for (var file in imageFiles) {
        formData.files.add(MapEntry(
          'images', // Must match upload.array('images') in Node.js
          await dio.MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        ));
      }

      final response = await _apiClient.dio.post('/upload/multiple', data: formData);
      
      if (response.statusCode == 200 && response.data['success']) {
        // Return the list of Cloudinary URLs
        return List<String>.from(response.data['imageUrls']);
      }
      return null;
    } on dio.DioException catch (e) {
      print("Multi Upload Error: ${e.response?.data}");
      return null;
    }
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
      print(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _apiClient.dio.post(
        '/products',
        data: productData,
      );

      if (response.statusCode == 201 && response.data['success']) {
        products.add(ProductModel.fromJson(response.data['data']));
        // Get.snackbar('Success', 'Product added successfully');
        return true;
      }
      return false;
    } on DioException catch (e) {
      Get.snackbar(
        'Error',
        e.response?.data['message'] ?? 'Failed to add product',
      );
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
      Get.snackbar(
        'Error',
        e.response?.data['message'] ?? 'Failed to delete product',
      );
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

      print("--- UPLOADING IMAGE ---");
      final response = await _apiClient.dio.post('/upload', data: formData);

      print("--- RAW BACKEND RESPONSE ---");
      print("Status Code: ${response.statusCode}");
      print("Data Type: ${response.data.runtimeType}");
      print("Data Payload: ${response.data}");
      print("----------------------------");

      if (response.statusCode == 200) {
        // If it parsed correctly as a Map
        if (response.data is Map) {
          if (response.data['success'] == true) {
            return response.data['file'];
          } else {
            print("Backend returned 200 but success flag is false!");
          }
        } else {
          print(
            "CRITICAL: Dio did not parse the response as JSON. It's a string.",
          );
        }
      }
      return null;
    } on dio.DioException catch (e) {
      print(
        "DioException Error: ${e.response?.statusCode} - ${e.response?.data}",
      );
      Get.snackbar('Upload Failed', 'Could not upload image');
      return null;
    } catch (e) {
      print("Standard Exception caught: $e");
      return null;
    }
  }
}
