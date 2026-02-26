// lib/features/admin/screens/add_product_screen.dart
import 'dart:io';
import 'package:ecommerce_app/features/admin/controllers/admin_product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatelessWidget {
  AddProductScreen({Key? key}) : super(key: key);

  final AdminProductController controller = Get.find<AdminProductController>();
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final stockCtrl = TextEditingController();

  final RxString selectedCategory = 'Electronics'.obs;
  final List<String> categories = [
    'Electronics',
    'Clothing',
    'Books',
    'Home',
    'Other',
  ];

  // Image Picker instance
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      controller.selectedImage.value = File(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reset selected image when entering screen
    controller.selectedImage.value = null;

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- IMAGE PICKER UI ---
              GestureDetector(
                onTap: pickImage,
                child: Obx(() {
                  final imageFile = controller.selectedImage.value;
                  return Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(imageFile, fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.grey,
                              ),
                              Text(
                                'Tap to select image',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // --- TEXT FIELDS ---
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: priceCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: stockCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Stock',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: selectedCategory.value,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (val) => selectedCategory.value = val!,
                ),
              ),
              const SizedBox(height: 30),

              // --- SUBMIT BUTTON ---
              // --- SUBMIT BUTTON ---
              Obx(
                () => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (controller.selectedImage.value == null) {
                              Get.snackbar(
                                'Missing Image',
                                'Please select a product image',
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            try {
                              controller.isLoading.value = true;

                              print("1. Starting image upload...");
                              String? cloudUrl = await controller.uploadImage(
                                controller.selectedImage.value!,
                              );
                              print("2. Image upload finished. URL: $cloudUrl");

                              if (cloudUrl == null) {
                                print("Error: Cloud URL is null.");
                                controller.isLoading.value = false;
                                return;
                              }

                              print("3. Parsing text fields...");
                              // SAFE PARSING: If it fails, it falls back to 0.0 or 0 instead of crashing
                              final parsedPrice =
                                  double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                              final parsedStock =
                                  int.tryParse(stockCtrl.text.trim()) ?? 0;
                              print(
                                "Parsed Price: $parsedPrice, Parsed Stock: $parsedStock",
                              );

                              print("4. Sending product data to backend...");
                              final success = await controller.addProduct({
                                'name': nameCtrl.text.trim(),
                                'description': descCtrl.text.trim(),
                                'price': parsedPrice,
                                'stock': parsedStock,
                                'category': selectedCategory.value,
                                'imageUrl': cloudUrl,
                              });

                              print("5. Backend responded. Success: $success");

                              if (success) {
                                Get.back();
                                Get.snackbar(
                                  'Success',
                                  'Product added successfully',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              }
                            } catch (e, stacktrace) {
                              print("!!! CRASH CAUGHT !!!");
                              print(e.toString());
                              print(stacktrace.toString());
                              Get.snackbar(
                                'Error',
                                'Something went wrong processing the data',
                              );
                            } finally {
                              controller.isLoading.value = false;
                            }
                          }
                        },
                        child: const Text(
                          'Save Product',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
