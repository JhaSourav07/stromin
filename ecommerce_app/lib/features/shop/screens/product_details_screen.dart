// lib/features/shop/screens/product_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../admin/models/product_model.dart';
import '../../cart/controllers/cart_controller.dart';

class ProductDetailsScreen extends StatelessWidget {
  ProductDetailsScreen({Key? key}) : super(key: key);

  final CartController cartController = Get.find<CartController>();
  final ProductModel product = Get.arguments;

  final RxInt _currentImageIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    final List<String> displayImages = product.images.isNotEmpty
        ? product.images
        : [product.imageUrl];

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: Stack(
        children: [

          // ── 1. IMAGE CAROUSEL ────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Stack(
              children: [

                // PageView is the ONLY hit-testable widget in this Stack.
                // Every other child is wrapped in IgnorePointer so they
                // are purely visual — they paint but never consume touches.
                PageView.builder(
                  itemCount: displayImages.length,
                  physics: const ClampingScrollPhysics(),
                  onPageChanged: (index) => _currentImageIndex.value = index,
                  itemBuilder: (context, index) {
                    final imageWidget = Image.network(
                      displayImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF18181B),
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 50,
                        ),
                      ),
                    );

                    // Hero only on the first image — matches the grid card tag.
                    if (index == 0) {
                      return Hero(
                        tag: 'product_image_${product.id}',
                        child: imageWidget,
                      );
                    }
                    return imageWidget;
                  },
                ),

                // ── GRADIENT OVERLAY ────────────────────────────────────────
                // Root cause of the original bug:
                // A Container with BoxDecoration is fully hit-testable in
                // Flutter. This Positioned.fill was sitting above PageView
                // in the Stack's z-order and swallowing every horizontal drag
                // before PageView could claim it.
                // IgnorePointer makes it purely visual — zero touch response.
                IgnorePointer(
                  child: Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            const Color(0xFF09090B).withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── PAGINATION DOTS ─────────────────────────────────────────
                // Also IgnorePointer — decorative only.
                if (displayImages.length > 1)
                  IgnorePointer(
                    child: Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(displayImages.length, (index) {
                          return Obx(() {
                            final isActive =
                                _currentImageIndex.value == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              width: isActive ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          });
                        }),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── 2. DETAILS BOTTOM SHEET ──────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF09090B),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27272A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.2),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            height: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '\$${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  const Text(
                    'Description',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade(delay: 400.ms),

                  const SizedBox(height: 8),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        product.description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),

          // ── 3. BACK BUTTON ───────────────────────────────────────────────
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
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // ── 4. ADD TO CART BUTTON ────────────────────────────────────────
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.5),
              ),
              onPressed: () => cartController.addToCart(product),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Add to Cart',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
                .animate()
                .fade(delay: 600.ms)
                .slideY(begin: 0.5, curve: Curves.easeOutBack),
          ),
        ],
      ),
    );
  }
}