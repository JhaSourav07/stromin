// lib/features/cart/controllers/cart_controller.dart
import 'package:dio/dio.dart';
import 'package:ecommerce_app/core/network/api_client.dart';
import 'package:ecommerce_app/features/admin/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/cart_item_model.dart';

class CartController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // Observable list of cart items
  var cartItems = <CartItemModel>[].obs;
  var isCheckingOut = false.obs;

  // Computed property: Automatically calculates grand total whenever cartItems changes
  double get grandTotal =>
      cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  // Computed property: Total number of items in the cart (for a badge icon)
  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  
  
  void addToCart(ProductModel product) {
    // Check if product is already in the cart
    int index = cartItems.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      // If it exists, just increase the quantity
      cartItems[index].quantity++;
      cartItems.refresh(); // GetX will update the UI
      Get.snackbar(
        'Cart Updated',
        '${product.name} quantity increased',
        duration: const Duration(seconds: 1),
      );
    } else {
      // If it's new, add it to the list
      cartItems.add(CartItemModel(product: product));
      Get.snackbar(
        'Added to Cart',
        '${product.name} added successfully',
        duration: const Duration(seconds: 1),
      );
    }
  }

  void removeFromCart(String productId) {
    cartItems.removeWhere((item) => item.product.id == productId);
  }

  void increaseQuantity(String productId) {
    int index = cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      cartItems[index].quantity++;
      cartItems.refresh();
    }
  }

  void decreaseQuantity(String productId) {
    int index = cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
        cartItems.refresh();
      } else {
        // If it's 1 and they decrease, remove it completely
        removeFromCart(productId);
      }
    }
  }

  void clearCart() {
    cartItems.clear();
  }

  
  Future<bool> placeOrder(String shippingAddress) async {
    if (cartItems.isEmpty) return false;

    try {
      isCheckingOut.value = true;
      
      // 1. Format the cart items to match our Node.js Order model exactly
      List<Map<String, dynamic>> orderItemsMap = cartItems.map((item) => {
        'name': item.product.name,
        'qty': item.quantity,
        'price': item.product.price,
        'product': item.product.id,
      }).toList();

      // 2. Send to backend
      final response = await _apiClient.dio.post('/orders', data: {
        'orderItems': orderItemsMap,
        'shippingAddress': shippingAddress,
        'totalPrice': grandTotal,
      });

      if (response.statusCode == 201 && response.data['success']) {
        clearCart(); // Empty the cart on success
        Get.snackbar('Success', 'Order placed successfully!', 
            snackPosition: SnackPosition.TOP, backgroundColor: Colors.green, colorText: Colors.white);
        return true;
      }
      return false;
    } on DioException catch (e) {
      Get.snackbar('Checkout Failed', e.response?.data['message'] ?? 'An error occurred');
      return false;
    } finally {
      isCheckingOut.value = false;
    }
  }
  
  

}
