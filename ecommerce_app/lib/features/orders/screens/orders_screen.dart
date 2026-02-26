// lib/features/orders/screens/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';

class OrdersScreen extends StatelessWidget {
  OrdersScreen({Key? key}) : super(key: key);

  final OrderController controller = Get.put(OrderController());

  // Helper to color-code the status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'Processing': return Colors.blue;
      case 'Shipped': return Colors.purple;
      case 'Delivered': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.myOrders.isEmpty) {
          return const Center(child: Text('You have no orders yet.', style: TextStyle(fontSize: 16)));
        }

        return ListView.builder(
          itemCount: controller.myOrders.length,
          itemBuilder: (context, index) {
            final order = controller.myOrders[index];
            // Format the date string a bit cleaner
            final date = DateTime.tryParse(order.createdAt)?.toLocal().toString().split('.')[0] ?? order.createdAt;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order ID: ${order.id.substring(order.id.length - 6).toUpperCase()}', 
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Text(order.status, style: TextStyle(color: _getStatusColor(order.status), fontWeight: FontWeight.bold, fontSize: 12)),
                        )
                      ],
                    ),
                    const Divider(),
                    Text('Date: $date', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 5),
                    Text('Items: ${order.totalItems}'),
                    const SizedBox(height: 5),
                    Text('Total: \$${order.totalPrice.toStringAsFixed(2)}', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}