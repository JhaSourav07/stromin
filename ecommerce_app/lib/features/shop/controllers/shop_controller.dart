// lib/features/shop/controllers/shop_controller.dart
import 'package:dio/dio.dart';
import 'package:ecommerce_app/core/network/api_client.dart';
import 'package:ecommerce_app/features/admin/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShopController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  var isLoading = false.obs;

  var products = <ProductModel>[].obs;

  // ── SEARCH & FILTER STATE ─────────────────────────────────────────────────
  var searchQuery = ''.obs;
  var selectedCategory = 'All'.obs;
  final TextEditingController searchController = TextEditingController();

  final List<String> categories = [
    'All',
    'Electronics',
    'Clothing',
    'Books',
    'Home',
    'Other',
  ];

  List<ProductModel> get filteredProducts {
    return products.where((product) {
      // Search matches name OR description (case-insensitive).
      final query = searchQuery.value.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);

      // Category 'All' always passes through.
      final matchesCategory = selectedCategory.value == 'All' ||
          product.category == selectedCategory.value;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchProducts();

    // Keep searchQuery in sync with the text field.
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

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
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }
}