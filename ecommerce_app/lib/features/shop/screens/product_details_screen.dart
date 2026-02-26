// lib/features/shop/screens/product_details_screen.dart
import 'package:ecommerce_app/features/auth/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../cart/controllers/cart_controller.dart';

class ProductDetailsScreen extends StatelessWidget {
  ProductDetailsScreen({Key? key}) : super(key: key);

  final CartController cartController = Get.find<CartController>();
  
  // We receive the product object passed from the ShopScreen
  final ProductModel product = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: Stack(
        children: [
          // 1. The Hero Image Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Hero(
              tag: 'product_image_${product.id}',
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF18181B),
                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                ),
              ),
            ),
          ),
          
          // 2. A subtle gradient overlay so the white text pops against any image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    const Color(0xFF09090B).withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          // 3. The Details Bottom Sheet
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF09090B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27272A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold),
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                  
                  const SizedBox(height: 16),
                  
                  // Title & Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(color: Colors.white, fontSize: 28, height: 1.2, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '\$${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ).animate().fade(delay: 400.ms),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        product.description,
                        style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.6),
                      ),
                    ),
                  ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
          
          // 4. Floating Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ),
            ),
          ),
          
          // 5. Floating "Add to Cart" Bar
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.5),
              ),
              onPressed: () {
                cartController.addToCart(product);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 22),
                  SizedBox(width: 10),
                  Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ).animate().fade(delay: 600.ms).slideY(begin: 0.5, curve: Curves.easeOutBack),
          ),
        ],
      ),
    );
  }
}