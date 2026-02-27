// lib/features/admin/screens/admin_dashboard_screen.dart
import 'package:ecommerce_app/features/admin/controllers/admin_product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class AdminDashboardScreen extends StatelessWidget {
  AdminDashboardScreen({Key? key}) : super(key: key);

  final AuthController authController = Get.find<AuthController>();
  final AdminProductController productController =
      Get.put(AdminProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_shipping),
            onPressed: () => Get.toNamed('/admin-orders'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() {
        if (productController.isLoading.value &&
            productController.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (productController.products.isEmpty) {
          return const Center(child: Text('No products found. Add some!'));
        }

        return ListView.builder(
          itemCount: productController.products.length,
          itemBuilder: (context, index) {
            final product = productController.products[index];

            return Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                // ── THUMBNAIL ─────────────────────────────────────────────
                leading: SizedBox(
                  width: 50,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),

                title: Text(product.name),
                subtitle: Text(
                  '\$${product.price.toStringAsFixed(2)} · Stock: ${product.stock}',
                ),

                // ── ACTIONS: edit + delete ─────────────────────────────────
                // We put both in a Row since ListTile.trailing only accepts
                // one widget. Both are icon-only to keep the row compact.
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit button — navigates to EditProductScreen with the
                    // full ProductModel as an argument.
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: Colors.blueGrey),
                      onPressed: () =>
                          Get.toNamed('/edit-product', arguments: product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _confirmDelete(context, product.id, product.name),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Get.toNamed('/add-product'),
      ),
    );
  }

  // Confirmation dialog before delete — prevents accidental taps.
  void _confirmDelete(BuildContext context, String id, String name) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF18181B),
        title: const Text('Delete Product',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "$name"? This cannot be undone.',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              productController.deleteProduct(id);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}