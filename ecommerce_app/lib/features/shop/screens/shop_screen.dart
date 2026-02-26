// lib/features/shop/screens/shop_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/shop_controller.dart';
import '../../cart/controllers/cart_controller.dart';

class ShopScreen extends StatelessWidget {
  ShopScreen({Key? key}) : super(key: key);

  final AuthController authController = Get.find<AuthController>();
  final ShopController shopController = Get.put(ShopController());
  final CartController cartController = Get.put(CartController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    // Grab the current theme data
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Discover', 
                // Color inherits automatically now
                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.receipt_long_outlined, color: theme.colorScheme.primary.withOpacity(0.8), size: 26),
                onPressed: () => Get.toNamed('/my-orders'),
              ),
              _buildCartIcon(theme),
              IconButton(
                icon: Icon(Icons.logout, color: theme.colorScheme.primary.withOpacity(0.7)),
                onPressed: () => authController.logout(),
              ),
              const SizedBox(width: 10),
            ],
          ),

          Obx(() {
            if (shopController.isLoading.value) {
              return SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
              );
            }

            if (shopController.products.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Text('No products available.', style: theme.textTheme.bodyLarge).animate().fade().scale(),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = shopController.products[index];
                    
                    return GestureDetector(
                      onTap: () => Get.toNamed('/product-details', arguments: product),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color, // Uses the charcoal color
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF27272A), width: 1), // Subtle premium border
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Hero(
                                tag: 'product_image_${product.id}',
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  child: Image.network(
                                    product.imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.primary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product.category,
                                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '\$${product.price.toStringAsFixed(0)}',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () => cartController.addToCart(product),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              // Invert button colors for dark mode
                                              color: isDark ? Colors.white : Colors.black,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.add, color: isDark ? Colors.black : Colors.white, size: 18),
                                          ),
                                        ).animate().scale(duration: 200.ms, curve: Curves.easeInOut),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fade(duration: 500.ms, delay: (index * 100).ms).slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutQuad);
                  },
                  childCount: shopController.products.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCartIcon(ThemeData theme) {
    return GestureDetector(
      onTap: () => Get.toNamed('/cart'),
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, color: theme.colorScheme.primary, size: 28),
            Obx(() {
              if (cartController.itemCount == 0) return const SizedBox.shrink();
              return Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    border: Border.all(color: theme.scaffoldBackgroundColor, width: 1.5),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    cartController.itemCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ).animate(key: ValueKey(cartController.itemCount)).scale(duration: 200.ms).then().shake(),
              );
            }),
          ],
        ),
      ),
    );
  }
}