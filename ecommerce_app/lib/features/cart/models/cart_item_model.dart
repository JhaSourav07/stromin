import 'package:ecommerce_app/features/auth/models/product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  // helper to get total price of the cart item
  double get totalPrice => product.price * quantity;
}