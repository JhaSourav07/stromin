// lib/features/orders/screens/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/order_controller.dart';

class OrdersScreen extends StatelessWidget {
  OrdersScreen({Key? key}) : super(key: key);

  final OrderController controller = Get.put(OrderController());

  // Refined colors for Dark Mode
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return const Color(0xFFF59E0B); // Amber
      case 'processing': return const Color(0xFF3B82F6); // Blue
      case 'shipped': return const Color(0xFF8B5CF6); // Purple
      case 'delivered': return const Color(0xFF10B981); // Emerald Green
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Icons.hourglass_empty;
      case 'processing': return Icons.autorenew;
      case 'shipped': return Icons.local_shipping_outlined;
      case 'delivered': return Icons.check_circle_outline;
      default: return Icons.receipt_long;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        title: const Text('Order History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (controller.myOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long, size: 60, color: Color(0xFF27272A)),
                const SizedBox(height: 16),
                const Text('No orders yet.', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ).animate().fade().scale(),
          );
        }

        return RefreshIndicator(
          color: Colors.black,
          backgroundColor: Colors.white,
          onRefresh: () => controller.fetchMyOrders(),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: controller.myOrders.length,
            itemBuilder: (context, index) {
              final order = controller.myOrders[index];
              final date = DateTime.tryParse(order.createdAt)?.toLocal().toString().split('.')[0] ?? order.createdAt;
              final statusColor = _getStatusColor(order.status);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF27272A), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Order ID & Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${order.id.substring(order.id.length - 6).toUpperCase()}', 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getStatusIcon(order.status), color: statusColor, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                order.status, 
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Color(0xFF27272A), height: 1),
                    ),
                    
                    // Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Date', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(date, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Items', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('${order.totalItems}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Total Footer
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF09090B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          Text(
                            '\$${order.totalPrice.toStringAsFixed(2)}', 
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              // The staggered entrance animation
              .animate()
              .fade(duration: 400.ms, delay: (index * 100).ms)
              .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
            },
          ),
        );
      }),
    );
  }
}