// lib/features/admin/screens/edit_product_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/admin_product_controller.dart';
import '../models/product_model.dart';

class EditProductScreen extends StatelessWidget {
  EditProductScreen({Key? key}) : super(key: key);

  // The product to edit is passed via Get.arguments — same pattern as
  // ProductDetailsScreen. No constructor props means the route system works
  // without changes.
  final ProductModel product = Get.arguments as ProductModel;
  final AdminProductController controller = Get.find<AdminProductController>();

  final _formKey = GlobalKey<FormState>();

  // Pre-fill controllers with existing product data.
  late final nameCtrl = TextEditingController(text: product.name);
  late final descCtrl = TextEditingController(text: product.description);
  late final priceCtrl =
      TextEditingController(text: product.price.toStringAsFixed(2));
  late final stockCtrl =
      TextEditingController(text: product.stock.toString());

  late final RxString selectedCategory = product.category.obs;

  final List<String> categories = [
    'Electronics',
    'Clothing',
    'Books',
    'Home',
    'Other'
  ];

  // Tracks newly selected local images.
  // If empty on submit → keep existing images from server.
  // If non-empty → upload new images and replace existing.
  final RxList<File> newImages = <File>[].obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImages() async {
    final List<XFile> picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      newImages.value = picked.take(5).map((x) => File(x.path)).toList();
    }
  }

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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        title: const Text(
          'Edit Product',
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
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

                    // ── IMAGE SECTION ───────────────────────────────────────
                    // Two states:
                    // 1. No new images picked → show existing images from server.
                    // 2. New images picked → show those as a preview with a
                    //    "replace" badge so the admin knows what will be uploaded.
                    GestureDetector(
                      onTap: pickImages,
                      child: Obx(() {
                        final hasNewImages = newImages.isNotEmpty;
                        final displayImages = hasNewImages
                            ? null // will show File images
                            : product.images.isNotEmpty
                                ? product.images
                                : [product.imageUrl];

                        return Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF18181B),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: hasNewImages
                                  ? Colors.white.withOpacity(0.5)
                                  : const Color(0xFF27272A),
                              width: hasNewImages ? 1.5 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Image list
                              hasNewImages
                                  ? ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.all(8),
                                      itemCount: newImages.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.file(
                                              newImages[index],
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.all(8),
                                      itemCount: displayImages!.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              displayImages[index],
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                width: 120,
                                                height: 120,
                                                color:
                                                    const Color(0xFF27272A),
                                                child: const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                              // "Change images" overlay tap hint at bottom-right
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.edit,
                                          color: Colors.white, size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                        hasNewImages
                                            ? 'New images selected'
                                            : 'Tap to change',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ).animate().fade().slideY(begin: 0.1),

                    const SizedBox(height: 28),

                    // ── FORM FIELDS ──────────────────────────────────────────
                    _buildTextField('Product Name', nameCtrl)
                        .animate()
                        .fade(delay: 100.ms)
                        .slideY(begin: 0.1),
                    const SizedBox(height: 16),
                    _buildTextField('Description', descCtrl, lines: 3)
                        .animate()
                        .fade(delay: 150.ms)
                        .slideY(begin: 0.1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField('Price (\$)', priceCtrl,
                              isNumber: true),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child:
                              _buildTextField('Stock', stockCtrl, isNumber: true),
                        ),
                      ],
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
                    const SizedBox(height: 16),

                    Obx(() => DropdownButtonFormField<String>(
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
                              .map((cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ))
                              .toList(),
                          onChanged: (val) => selectedCategory.value = val!,
                        )).animate().fade(delay: 250.ms).slideY(begin: 0.1),
                  ],
                ),
              ),
            ),
          ),

          // ── SUBMIT BUTTON ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.only(
                left: 24, right: 24, bottom: 40, top: 20),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: Obx(
                () => controller.isLoading.value
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Colors.white))
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
                          if (!_formKey.currentState!.validate()) return;

                          try {
                            controller.isLoading.value = true;

                            // ── IMAGE HANDLING ────────────────────────────
                            // If the admin picked new images, upload them.
                            // If not, reuse the existing URLs — no upload cost.
                            String imageUrl = product.imageUrl;
                            List<String> images = product.images;

                            if (newImages.isNotEmpty) {
                              final uploaded =
                                  await controller.uploadMultipleImages(
                                      newImages);
                              if (uploaded == null || uploaded.isEmpty) {
                                Get.snackbar('Error',
                                    'Image upload failed. Try again.');
                                return;
                              }
                              imageUrl = uploaded.first;
                              images = uploaded;
                            }

                            final success = await controller.updateProduct(
                              product.id,
                              {
                                'name': nameCtrl.text.trim(),
                                'description': descCtrl.text.trim(),
                                'price': double.tryParse(priceCtrl.text.trim()) ?? product.price,
                                'stock': int.tryParse(stockCtrl.text.trim()) ?? product.stock,
                                'category': selectedCategory.value,
                                'imageUrl': imageUrl,
                                'images': images,
                              },
                            );

                            if (success) {
                              Get.back();
                              Get.snackbar(
                                'Updated',
                                'Product saved successfully',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.white,
                                colorText: Colors.black,
                              );
                            }
                          } finally {
                            controller.isLoading.value = false;
                          }
                        },
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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