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
  final CartController cartController =
      Get.put(CartController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── APP BAR ───────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.95),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Discover',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.receipt_long_outlined,
                    color: theme.colorScheme.primary.withOpacity(0.8),
                    size: 26),
                onPressed: () => Get.toNamed('/my-orders'),
              ),
              _buildCartIcon(theme),
              IconButton(
                icon: Icon(Icons.logout,
                    color: theme.colorScheme.primary.withOpacity(0.7)),
                onPressed: () => authController.logout(),
              ),
              const SizedBox(width: 10),
            ],
          ),

          // ── SEARCH BAR ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Obx(() => TextField(
                    controller: shopController.searchController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: const TextStyle(color: Color(0xFF71717A)),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Color(0xFF52525B), size: 22),
                      suffixIcon: shopController.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: Color(0xFF52525B), size: 20),
                              onPressed: shopController.clearSearch,
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFF18181B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: Color(0xFF27272A), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: Color(0xFF27272A), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: Colors.white, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  )),
            ).animate().fade(duration: 400.ms),
          ),

          // ── CATEGORY CHIPS ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 56,
              child: Obx(() {
                // FIXED: Read the observable synchronously here so GetX tracks it!
                final currentCategory = shopController.selectedCategory.value;

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  itemCount: shopController.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = shopController.categories[index];
                    
                    // Use the synchronously read value
                    final isSelected = currentCategory == category;

                    return GestureDetector(
                      onTap: () => shopController.selectCategory(category),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF18181B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF27272A),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),

          // ── PRODUCT GRID ───────────────────────────────────────────────────
          Obx(() {
            if (shopController.isLoading.value) {
              return SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(
                        color: theme.colorScheme.primary)),
              );
            }

            final filtered = shopController.filteredProducts;

            if (shopController.products.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Text('No products available.',
                          style: theme.textTheme.bodyLarge)
                      .animate()
                      .fade()
                      .scale(),
                ),
              );
            }

            if (filtered.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded,
                          size: 60, color: Color(0xFF27272A)),
                      const SizedBox(height: 16),
                      const Text('No results found',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        'Try a different search or category',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4), fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          shopController.clearSearch();
                          shopController.selectCategory('All');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF18181B),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: const Color(0xFF27272A)),
                          ),
                          child: const Text('Clear filters',
                              style: TextStyle(color: Colors.white)),
                        ),
                      )
                    ],
                  ).animate().fade().scale(),
                ),
              );
            }

            return SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = filtered[index];

                    return GestureDetector(
                      onTap: () =>
                          Get.toNamed('/product-details', arguments: product),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF27272A), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Hero(
                                tag: 'product_image_${product.id}',
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                  child: Image.network(
                                    product.imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                        child: Icon(Icons.broken_image,
                                            color: Colors.grey)),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color:
                                                  theme.colorScheme.primary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product.category,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '\$${product.price.toStringAsFixed(0)}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color:
                                                    theme.colorScheme.primary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () => cartController
                                              .addToCart(product),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.add,
                                                color: isDark
                                                    ? Colors.black
                                                    : Colors.white,
                                                size: 18),
                                          ),
                                        ).animate().scale(
                                            duration: 200.ms,
                                            curve: Curves.easeInOut),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fade(duration: 500.ms, delay: (index * 80).ms)
                        .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 500.ms,
                            curve: Curves.easeOutQuad);
                  },
                  childCount: filtered.length,
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
            Icon(Icons.shopping_bag_outlined,
                color: theme.colorScheme.primary, size: 28),
            Obx(() {
              if (cartController.itemCount == 0) return const SizedBox.shrink();
              return Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    border: Border.all(
                        color: theme.scaffoldBackgroundColor, width: 1.5),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    cartController.itemCount.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold),
                  ),
                )
                    .animate(key: ValueKey(cartController.itemCount))
                    .scale(duration: 200.ms)
                    .then()
                    .shake(),
              );
            }),
          ],
        ),
      ),
    );
  }
}