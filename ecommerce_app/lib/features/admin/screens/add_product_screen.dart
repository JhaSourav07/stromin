// lib/features/admin/screens/add_product_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/admin_product_controller.dart';

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

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      // Limit to 5 images to prevent payload issues
      final limitedImages = images.take(5).toList();
      controller.selectedImages.value = limitedImages
          .map((img) => File(img.path))
          .toList();
    }
  }

  // Premium Text Field Builder
  Widget _buildTextField(
    String label,
    TextEditingController textController, {
    bool isNumber = false,
    int lines = 1,
  }) {
    return TextFormField(
      controller: textController,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      maxLines: lines,
      validator: (v) => v!.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF18181B),
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
    // Clear previously selected images when opening the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectedImages.clear();
    });

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        title: const Text(
          'New Product',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- MULTI-IMAGE PICKER GALLERY ---
                    GestureDetector(
                      onTap: pickImages,
                      child: Obx(() {
                        final images = controller.selectedImages;
                        return Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF18181B),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF27272A),
                              width: 2,
                            ),
                          ),
                          child: images.isNotEmpty
                              ? ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.all(8),
                                  itemCount: images.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          images[index],
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Tap to select up to 5 images',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                        );
                      }),
                    ).animate().fade().slideY(begin: 0.1),

                    const SizedBox(height: 30),

                    // --- TEXT FIELDS ---
                    _buildTextField(
                      'Product Name',
                      nameCtrl,
                    ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Description',
                      descCtrl,
                      lines: 3,
                    ).animate().fade(delay: 150.ms).slideY(begin: 0.1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'Price (\$)',
                            priceCtrl,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            'Stock',
                            stockCtrl,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
                    const SizedBox(height: 16),

                    // --- CATEGORY DROPDOWN ---
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: selectedCategory.value,
                        dropdownColor: const Color(0xFF18181B),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF18181B),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: categories
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => selectedCategory.value = val!,
                      ),
                    ).animate().fade(delay: 250.ms).slideY(begin: 0.1),
                  ],
                ),
              ),
            ),
          ),

          // --- SUBMIT BUTTON BOTTOM BAR ---
          Container(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: 40,
              top: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  const Color(0xFF09090B),
                  const Color(0xFF09090B).withOpacity(0.0),
                ],
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: Obx(
                () => controller.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (controller.selectedImages.isEmpty) {
                              Get.snackbar(
                                'Missing Images',
                                'Please select at least one image',
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                              return;
                            }
                            try {
                              controller.isLoading.value = true;

                              // Upload the array of images
                              List<String>? cloudUrls = await controller
                                  .uploadMultipleImages(
                                    controller.selectedImages,
                                  );
                              if (cloudUrls == null || cloudUrls.isEmpty)
                                throw Exception('Upload failed');

                              final parsedPrice =
                                  double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                              final parsedStock =
                                  int.tryParse(stockCtrl.text.trim()) ?? 0;

                              final success = await controller.addProduct({
                                'name': nameCtrl.text.trim(),
                                'description': descCtrl.text.trim(),
                                'price': parsedPrice,
                                'stock': parsedStock,
                                'category': selectedCategory.value,
                                'imageUrl':
                                    cloudUrls[0], // Make the first image the main thumbnail
                                'images':
                                    cloudUrls, // Pass the whole array for the gallery
                              });

                              if (success) {
                                Get.back();
                                Get.snackbar(
                                  'Success',
                                  'Product published',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.white,
                                  colorText: Colors.black,
                                );
                              }
                            } catch (e) {
                              Get.snackbar('Error', 'Something went wrong');
                            } finally {
                              controller.isLoading.value = false;
                            }
                          }
                        },
                        child: const Text(
                          'Publish Product',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ).animate().fade(delay: 300.ms).slideY(begin: 0.5),
          ),
        ],
      ),
    );
  }
}
