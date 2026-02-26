// lib/features/admin/screens/admin_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/admin_order_controller.dart';

class AdminOrdersScreen extends StatelessWidget {
  AdminOrdersScreen({Key? key}) : super(key: key);

  final AdminOrderController controller = Get.put(AdminOrderController());
  final List<String> statuses = ['Pending', 'Processing', 'Shipped', 'Delivered'];

  // Premium status colors
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
        title: const Text('Manage Orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allOrders.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (controller.allOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox_outlined, size: 80, color: Color(0xFF27272A)),
                const SizedBox(height: 16),
                const Text('No orders yet', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('When customers buy, orders appear here.', style: TextStyle(color: Colors.grey)),
              ],
            ).animate().fade().scale(),
          );
        }

        return RefreshIndicator(
          color: Colors.black,
          backgroundColor: Colors.white,
          onRefresh: () => controller.fetchAllOrders(),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: controller.allOrders.length,
            itemBuilder: (context, index) {
              final order = controller.allOrders[index];
              final date = DateTime.tryParse(order.createdAt)?.toLocal().toString().split('.')[0] ?? order.createdAt;
              final statusColor = _getStatusColor(order.status);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF27272A), width: 1),
                ),
                // We wrap ExpansionTile in a Theme to remove those ugly default borders it creates
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.grey,
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Icon(_getStatusIcon(order.status), color: statusColor, size: 20),
                    ),
                    title: Text(
                      'Order #${order.id.substring(order.id.length - 6).toUpperCase()}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '\$${order.totalPrice.toStringAsFixed(2)}  •  $date',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: Color(0xFF27272A), width: 1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Shipping Address', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 6),
                            Text(order.shippingAddress, style: const TextStyle(color: Colors.white, fontSize: 14)),
                            
                            const SizedBox(height: 24),
                            
                            const Text('Update Status', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 10),
                            
                            // Premium Dropdown
                            DropdownButtonFormField<String>(
                              value: order.status,
                              dropdownColor: const Color(0xFF18181B),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              icon: const Icon(Icons.expand_more, color: Colors.grey),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF09090B),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF27272A), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF27272A), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.white, width: 1),
                                ),
                              ),
                              items: statuses.map((status) => DropdownMenuItem(
                                value: status,
                                child: Row(
                                  children: [
                                    Icon(_getStatusIcon(status), color: _getStatusColor(status), size: 16),
                                    const SizedBox(width: 10),
                                    Text(status),
                                  ],
                                ),
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
                  ),
                ),
              )
              // The staggered slide-in animation
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