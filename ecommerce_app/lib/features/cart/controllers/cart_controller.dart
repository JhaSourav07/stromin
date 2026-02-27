// lib/features/cart/controllers/cart_controller.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:ecommerce_app/core/network/api_client.dart';
import 'package:ecommerce_app/features/admin/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

class CartController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  var cartItems = <CartItemModel>[].obs;
  var isCheckingOut = false.obs;

  static const String _cartKey = 'persisted_cart';

  double get grandTotal =>
      cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  // ── LIFECYCLE ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // Load persisted cart before the user sees the screen.
    // This runs once when CartController is first registered (app start).
    _loadCart();
  }

  // ── PERSISTENCE ───────────────────────────────────────────────────────────
  // We use SharedPreferences (not FlutterSecureStorage) because cart data
  // is not sensitive — it's just product IDs and quantities. Secure storage
  // is reserved for auth tokens.
  //
  // We store the cart as a JSON string: a list of CartItemModel.toJson() maps.

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          jsonEncode(cartItems.map((item) => item.toJson()).toList());
      await prefs.setString(_cartKey, encoded);
    } catch (e) {
      // Persistence failure should never crash the app or block the user.
      // The cart still works in-memory; it just won't survive restart.
      print('Cart save failed: $e');
    }
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cartKey);

      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw);
        cartItems.value = decoded
            .map((json) => CartItemModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // If the persisted data is corrupt (e.g., after an app update changes
      // the model structure), wipe it and start fresh rather than crashing.
      print('Cart load failed, clearing: $e');
      await _clearPersistedCart();
    }
  }

  Future<void> _clearPersistedCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  // ── CART MUTATIONS ────────────────────────────────────────────────────────
  // Every mutation calls _saveCart() so disk is always in sync with memory.

  void addToCart(ProductModel product) {
    int index = cartItems.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      cartItems[index].quantity++;
      cartItems.refresh();
      Get.snackbar(
        'Cart Updated',
        '${product.name} quantity increased',
        duration: const Duration(seconds: 1),
      );
    } else {
      cartItems.add(CartItemModel(product: product));
      Get.snackbar(
        'Added to Cart',
        '${product.name} added successfully',
        duration: const Duration(seconds: 1),
      );
    }

    _saveCart();
  }

  void removeFromCart(String productId) {
    cartItems.removeWhere((item) => item.product.id == productId);
    _saveCart();
  }

  void increaseQuantity(String productId) {
    int index = cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      cartItems[index].quantity++;
      cartItems.refresh();
      _saveCart();
    }
  }

  void decreaseQuantity(String productId) {
    int index = cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
        cartItems.refresh();
      } else {
        cartItems.removeAt(index);
      }
      _saveCart();
    }
  }

  void clearCart() {
    cartItems.clear();
    _saveCart();
  }

  // ── CHECKOUT ──────────────────────────────────────────────────────────────

  Future<bool> placeOrder(String shippingAddress) async {
    if (cartItems.isEmpty) return false;

    try {
      isCheckingOut.value = true;

      List<Map<String, dynamic>> orderItemsMap = cartItems
          .map((item) => {
                'name': item.product.name,
                'qty': item.quantity,
                'price': item.product.price,
                'product': item.product.id,
              })
          .toList();

      final response = await _apiClient.dio.post('/orders', data: {
        'orderItems': orderItemsMap,
        'shippingAddress': shippingAddress,
        'totalPrice': grandTotal,
      });

      if (response.statusCode == 201 && response.data['success']) {
        clearCart(); // This also saves the now-empty cart to disk.
        Get.snackbar(
          'Success',
          'Order placed successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } on DioException catch (e) {
      Get.snackbar('Checkout Failed',
          e.response?.data['message'] ?? 'An error occurred');
      return false;
    } finally {
      isCheckingOut.value = false;
    }
  }
}