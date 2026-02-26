// lib/features/cart/controllers/cart_controller.dart
import 'package:ecommerce_app/features/auth/models/product_model.dart';
import 'package:get/get.dart';
import '../models/cart_item_model.dart';

class CartController extends GetxController {
  // Observable list of cart items
  var cartItems = <CartItemModel>[].obs;

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
}
