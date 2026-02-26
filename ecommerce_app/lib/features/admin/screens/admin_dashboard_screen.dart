// lib/features/admin/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/admin_product_controller.dart';

class AdminDashboardScreen extends StatelessWidget {
  AdminDashboardScreen({Key? key}) : super(key: key);

  final AuthController authController = Get.find<AuthController>();
  final AdminProductController productController = Get.put(AdminProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        title: const Text('Store Management', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.local_shipping_outlined, color: Colors.white),
            onPressed: () => Get.toNamed('/admin-orders'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () => authController.logout(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        onPressed: () => Get.toNamed('/add-product'),
        icon: const Icon(Icons.add),
        label: const Text('New Product', style: TextStyle(fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
      body: Obx(() {
        if (productController.isLoading.value && productController.products.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (productController.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 80, color: Color(0xFF27272A)),
                const SizedBox(height: 16),
                const Text('Your store is empty', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Add some products to start selling.', style: TextStyle(color: Colors.grey)),
              ],
            ).animate().fade().scale(),
          );
        }

        return RefreshIndicator(
          color: Colors.black,
          backgroundColor: Colors.white,
          onRefresh: () => productController.fetchProducts(),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100), // Padding for FAB
            itemCount: productController.products.length,
            itemBuilder: (context, index) {
              final product = productController.products[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF18181B), // Charcoal
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF27272A), width: 1),
                ),
                child: Row(
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        product.imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 70, height: 70, color: const Color(0xFF27272A),
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
                            product.name,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}  •  Stock: ${product.stock}',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    // Delete Action
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () {
                        Get.defaultDialog(
                          title: 'Delete Product',
                          titleStyle: const TextStyle(color: Colors.white),
                          backgroundColor: const Color(0xFF18181B),
                          middleText: 'Are you sure you want to delete this?',
                          middleTextStyle: const TextStyle(color: Colors.grey),
                          textConfirm: 'Delete',
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.redAccent,
                          textCancel: 'Cancel',
                          cancelTextColor: Colors.white,
                          onConfirm: () {
                            productController.deleteProduct(product.id);
                            Get.back(); // close dialog
                          }
                        );
                      },
                    ),
                  ],
                ),
              )
              .animate()
              .fade(duration: 400.ms, delay: (index * 50).ms)
              .slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
            },
          ),
        );
      }),
    );
  }
}