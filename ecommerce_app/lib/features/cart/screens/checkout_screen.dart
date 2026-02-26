// lib/features/cart/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/cart_controller.dart';

class CheckoutScreen extends StatelessWidget {
  CheckoutScreen({Key? key}) : super(key: key);

  final CartController cartController = Get.find<CartController>();
  final _formKey = GlobalKey<FormState>();

  // Individual controllers for a premium form feel
  final streetCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final zipCtrl = TextEditingController();

  // Helper for premium dark mode text fields
  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isHalf = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      validator: (value) => value!.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        filled: true,
        fillColor: const Color(0xFF18181B), // Dark charcoal
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        title: const Text('Shipping Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Where are we sending this?',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ).animate().fade().slideX(begin: -0.1),
                    const SizedBox(height: 30),
                    
                    _buildTextField('Street Address', Icons.location_on_outlined, streetCtrl)
                        .animate().fade(delay: 100.ms).slideY(begin: 0.1),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(child: _buildTextField('City', Icons.location_city_outlined, cityCtrl)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('Zip Code', Icons.markunread_mailbox_outlined, zipCtrl)),
                      ],
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
                    
                    const SizedBox(height: 40),
                    
                    // Order Summary Box
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF27272A), width: 1),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal', style: TextStyle(color: Colors.grey, fontSize: 16)),
                              Text('\$${cartController.grandTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Premium Shipping', style: TextStyle(color: Colors.grey, fontSize: 16)),
                              Text('Free', style: TextStyle(color: Colors.greenAccent, fontSize: 16)),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Divider(color: Color(0xFF27272A)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('\$${cartController.grandTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),
                  ],
                ),
              ),
            ),
          ),
          
          // Checkout Button Area
          Container(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40, top: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [const Color(0xFF09090B), const Color(0xFF09090B).withOpacity(0.0)],
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: Obx(() => cartController.isCheckingOut.value
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Combine the fields into one string for the backend
                          String fullAddress = '${streetCtrl.text.trim()}, ${cityCtrl.text.trim()} ${zipCtrl.text.trim()}';
                          
                          bool success = await cartController.placeOrder(fullAddress);
                          if (success) {
                            // Pop back to the shop screen after successful order
                            Get.until((route) => Get.currentRoute == '/customer-home');
                          }
                        }
                      },
                      child: const Text('Confirm & Pay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    )),
            ).animate().fade(delay: 400.ms).slideY(begin: 0.5),
          ),
        ],
      ),
    );
  }
}