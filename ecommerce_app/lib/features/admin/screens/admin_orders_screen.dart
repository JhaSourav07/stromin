// lib/features/admin/screens/admin_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_order_controller.dart';

class AdminOrdersScreen extends StatelessWidget {
  AdminOrdersScreen({Key? key}) : super(key: key);

  final AdminOrderController controller = Get.put(AdminOrderController());
  final List<String> statuses = ['Pending', 'Processing', 'Shipped', 'Delivered'];

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
      appBar: AppBar(title: const Text('Manage Orders')),
      body: Obx(() {
        if (controller.isLoading.value && controller.allOrders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.allOrders.isEmpty) {
          return const Center(child: Text('No orders found.'));
        }

        return ListView.builder(
          itemCount: controller.allOrders.length,
          itemBuilder: (context, index) {
            final order = controller.allOrders[index];
            final date = DateTime.tryParse(order.createdAt)?.toLocal().toString().split('.')[0] ?? order.createdAt;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ExpansionTile(
                title: Text('Order: ${order.id.substring(order.id.length - 6).toUpperCase()}'),
                subtitle: Text('Total: \$${order.totalPrice.toStringAsFixed(2)} | Date: $date'),
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(order.status).withOpacity(0.2),
                  child: Icon(Icons.receipt, color: _getStatusColor(order.status)),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Shipping Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(order.shippingAddress),
                        const SizedBox(height: 15),
                        const Text('Update Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        DropdownButtonFormField<String>(
                          value: order.status,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: statuses.map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          )).toList(),
                          onChanged: (newStatus) {
                            if (newStatus != null && newStatus != order.status) {
                              controller.updateOrderStatus(order.id, newStatus);
                            }
                          },
                        ),
                      ],
                    ),
                  )
                ],
              )
            );
          },
        );
      }),
    );
  }
}