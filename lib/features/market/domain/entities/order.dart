import 'package:flutter/foundation.dart';

import 'market_product.dart';

enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled;

  static OrderStatus fromJson(String value) {
    return OrderStatus.values.firstWhere((s) => s.name == value, orElse: () => OrderStatus.pending);
  }
}

@immutable
class OrderLine {
  const OrderLine({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    required this.sellerId,
    required this.sellerName,
  });

  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
  final String sellerId;
  final String sellerName;

  factory OrderLine.fromJson(Map<String, dynamic> json) {
    return OrderLine(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
      lineTotal: (json['lineTotal'] as num).toDouble(),
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
    );
  }
}

@immutable
class Order {
  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final List<OrderLine> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;

  String get totalLabel => formatNaira(totalAmount);

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as List<dynamic>).map((e) => OrderLine.fromJson(e as Map<String, dynamic>)).toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: OrderStatus.fromJson(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
