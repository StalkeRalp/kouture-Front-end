import 'product_model.dart';

class OrderModel {
  final String id;
  final String clientId;
  final String tailorId;
  final String? productId;
  final String? productName;
  final String status;
  final double price;
  final String paymentStatus;
  final String? deliveryAddress;
  final List<OrderItemModel> items;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.clientId,
    required this.tailorId,
    this.productId,
    this.productName,
    required this.status,
    required this.price,
    this.paymentStatus = 'pending',
    this.deliveryAddress,
    this.items = const [],
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      clientId: json['client_id'],
      tailorId: json['tailor_id'],
      productId: json['product_id'],
      productName: json['product_name'],
      status: json['status'] ?? 'pending',
      price: (json['price'] ?? 0).toDouble(),
      paymentStatus: json['payment_status'] ?? 'pending',
      deliveryAddress: json['delivery_address'],
      items: json['order_items'] != null
          ? List<OrderItemModel>.from(
              (json['order_items'] as List).map((x) => OrderItemModel.fromJson(x)))
          : [],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'tailor_id': tailorId,
      'product_id': productId,
      'product_name': productName,
      'status': status,
      'price': price,
      'payment_status': paymentStatus,
      'delivery_address': deliveryAddress,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class OrderItemModel {
  final String id;
  final String? productId;
  final String productNameAtPurchase;
  final double priceAtPurchase;
  final int quantity;
  final String? size;
  final String? color;

  OrderItemModel({
    required this.id,
    this.productId,
    required this.productNameAtPurchase,
    required this.priceAtPurchase,
    required this.quantity,
    this.size,
    this.color,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      productId: json['product_id'],
      productNameAtPurchase: json['product_name_at_purchase'] ?? '',
      priceAtPurchase: (json['price_at_purchase'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      size: json['size'],
      color: json['color'],
    );
  }
}
