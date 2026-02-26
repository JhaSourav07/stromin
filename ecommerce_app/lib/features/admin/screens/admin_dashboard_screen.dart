// lib/features/admin/screens/admin_dashboard_screen.dart
import 'package:ecommerce_app/features/auth/controllers/admin_product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class AdminDashboardScreen extends StatelessWidget {
  AdminDashboardScreen({Key? key}) : super(key: key);

  final AuthController authController = Get.find<AuthController>();
  final AdminProductController productController = Get.put(AdminProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          )
        ],
      ),
      body: Obx(() {
        if (productController.isLoading.value && productController.products.isEmpty) {
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
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(product.imageUrl),
                  backgroundColor: Colors.transparent,
                ),
                title: Text(product.name),
                subtitle: Text('\$${product.price.toStringAsFixed(2)} - Stock: ${product.stock}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => productController.deleteProduct(product.id),
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
}