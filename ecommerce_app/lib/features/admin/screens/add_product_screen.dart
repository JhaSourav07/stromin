// lib/features/admin/screens/add_product_screen.dart
import 'package:ecommerce_app/features/auth/controllers/admin_product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddProductScreen extends StatelessWidget {
  AddProductScreen({Key? key}) : super(key: key);

  final AdminProductController controller = Get.find<AdminProductController>();
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final stockCtrl = TextEditingController();

  // Default category
  final RxString selectedCategory = 'Electronics'.obs;
  final List<String> categories = [
    'Electronics',
    'Clothing',
    'Books',
    'Home',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: stockCtrl,
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: selectedCategory.value,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (val) => selectedCategory.value = val!,
                ),
              ),
              const SizedBox(height: 30),
              Obx(
                () => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              // 1. Safe parsing: .trim() removes accidental white spaces
                              final price = double.parse(priceCtrl.text.trim());
                              final stock = int.parse(stockCtrl.text.trim());

                              print("--- SENDING DATA TO BACKEND ---");

                              // 2. Await the controller
                              final success = await controller.addProduct({
                                'name': nameCtrl.text.trim(),
                                'description': descCtrl.text.trim(),
                                'price': price,
                                'stock': stock,
                                'category': selectedCategory.value,
                                'imageUrl': 'https://via.placeholder.com/150',
                              });

                              print("--- SUCCESS RESULT: $success ---");

                              if (success) {
                                // 1. Close the screen FIRST
                                Get.back();

                                // 2. Show the snackbar AFTER we are back on the Dashboard
                                Get.snackbar(
                                  'Success',
                                  'Product added successfully',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              } else {
                                print("Backend returned false.");
                              }
                            } catch (e) {
                              // 4. Catch parsing errors (e.g. typing "10a" in the price field)
                              print("--- UI CRASHED: $e ---");
                              Get.snackbar(
                                'Invalid Input',
                                'Please make sure Price and Stock contain only numbers.',
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                              );
                            }
                          }
                        },
                        child: const Text('Save Product'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
