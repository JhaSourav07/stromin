class OrderModel {
  final String id;
  final double totalPrice;
  final String status;
  final String shippingAddress;
  final String createdAt;
  final int totalItems;

  OrderModel({
    required this.id,
    required this.totalPrice,
    required this.status,
    required this.shippingAddress,
    required this.createdAt,
    required this.totalItems,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Calculate total items from the orderItems array
    int itemsCount = 0;
    if (json['orderItems'] != null) {
      for (var item in json['orderItems']) {
        itemsCount += (item['qty'] as int);
      }
    }

    return OrderModel(
      id: json['_id'] ?? '',
      // Ensure safe parsing of large numbers
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'Pending',
      shippingAddress: json['shippingAddress'] ?? '',
      // We will parse the raw ISO string for simplicity right now
      createdAt: json['createdAt'] ?? '',
      totalItems: itemsCount,
    );
  }
}