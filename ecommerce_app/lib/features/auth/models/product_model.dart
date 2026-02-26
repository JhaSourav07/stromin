// lib/features/admin/models/product_model.dart

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int stock;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.stock,
    required this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '', // MongoDB uses _id
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      // Ensure price is parsed as double even if it's an int in JSON
      price: (json['price'] ?? 0).toDouble(), 
      category: json['category'] ?? 'Other',
      stock: json['stock'] ?? 0,
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
    );
  }
}