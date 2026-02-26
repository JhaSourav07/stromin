// lib/features/cart/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/cart_controller.dart';

class CartScreen extends StatelessWidget {
  CartScreen({Key? key}) : super(key: key);

  final CartController cartController = Get.find<CartController>();

  // Custom sleek button for the quantity stepper (+ / -)
  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF27272A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        title: const Text('Your Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.grey),
            onPressed: () {
              if (cartController.cartItems.isNotEmpty) {
                cartController.clearCart();
                Get.snackbar('Cart Cleared', 'All items removed', backgroundColor: Colors.white, colorText: Colors.black);
              }
            },
          )
        ],
      ),
      body: Obx(() {
        // --- EMPTY STATE ---
        if (cartController.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 80, color: Color(0xFF27272A)),
                const SizedBox(height: 20),
                const Text('Your cart is empty', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('Looks like you haven\'t added\nanything yet.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text('Start Shopping', style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ).animate().fade().scale(),
          );
        }

        // --- CART ITEMS LIST ---
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: cartController.cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartController.cartItems[index];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF18181B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF27272A), width: 1),
                    ),
                    child: Row(
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            item.product.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80, height: 80, color: const Color(0xFF27272A),
                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${item.product.price.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              
                              // Custom Quantity Stepper
                              Row(
                                children: [
                                  _buildQtyButton(Icons.remove, () => cartController.decreaseQuantity(item.product.id)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('${item.quantity}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                  _buildQtyButton(Icons.add, () => cartController.increaseQuantity(item.product.id)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Total Line Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${item.totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                  // Staggered slide-in animation from the right
                  .animate()
                  .fade(duration: 400.ms, delay: (index * 100).ms)
                  .slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
                },
              ),
            ),
            
            // --- CHECKOUT BOTTOM BAR ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF09090B),
                border: Border(top: BorderSide(color: Color(0xFF27272A), width: 1)),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Text(
                          '\$${cartController.grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () => Get.toNamed('/checkout'),
                      child: const Row(
                        children: [
                          Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().slideY(begin: 1.0, end: 0, duration: 400.ms, curve: Curves.easeOut),
          ],
        );
      }),
    );
  }
}