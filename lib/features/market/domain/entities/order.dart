import 'package:flutter/foundation.dart';

import 'market_product.dart';
import 'payment_method.dart';

/// Fulfillment status — don't confuse with [PaymentStatus] (money), which
/// is a separate field on [Order].
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

enum PaymentStatus {
  pending,
  confirmed,
  paid;

  static PaymentStatus fromJson(String value) {
    return PaymentStatus.values.firstWhere((s) => s.name == value, orElse: () => PaymentStatus.pending);
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
    required this.paymentMethod,
    required this.paymentStatus,
    this.holdExpiresAt,
    this.checkoutSessionId,
  });

  final String id;
  final String userId;
  final List<OrderLine> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;

  /// Only set for `unpaidHold` orders — the 24-hour price/stock hold expiry.
  /// The backend auto-cancels the order (flips [status] to `cancelled`) once
  /// this passes; there's no reminder/extension flow.
  final DateTime? holdExpiresAt;

  /// Only set for `monimeOnline` orders — pair with
  /// `GET /checkout/sessions/{id}` to check payment progress.
  final String? checkoutSessionId;

  String get totalLabel => formatNaira(totalAmount);

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as List<dynamic>).map((e) => OrderLine.fromJson(e as Map<String, dynamic>)).toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: OrderStatus.fromJson(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      paymentMethod: PaymentMethod.fromJson(json['paymentMethod'] as String),
      paymentStatus: PaymentStatus.fromJson(json['paymentStatus'] as String),
      holdExpiresAt: json['holdExpiresAt'] != null ? DateTime.parse(json['holdExpiresAt'] as String) : null,
      checkoutSessionId: json['checkoutSessionId'] as String?,
    );
  }
}
