import 'package:flutter/foundation.dart';

import 'market_product.dart';

@immutable
class CartLine {
  const CartLine({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.unit,
    required this.quantity,
    required this.lineTotal,
    required this.sellerId,
    required this.sellerName,
    this.imageUrl,
  });

  final String productId;
  final String productName;
  final double unitPrice;
  final String unit;
  final int quantity;
  final double lineTotal;
  final String sellerId;
  final String sellerName;
  final String? imageUrl;

  String get unitPriceLabel => formatNaira(unitPrice);
  String get lineTotalLabel => formatNaira(lineTotal);

  factory CartLine.fromJson(Map<String, dynamic> json) {
    return CartLine(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      unit: json['unit'] as String,
      quantity: json['quantity'] as int,
      lineTotal: (json['lineTotal'] as num).toDouble(),
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

@immutable
class Cart {
  const Cart({required this.id, required this.items, required this.totalAmount});

  const Cart.empty() : id = '', items = const [], totalAmount = 0;

  final String id;
  final List<CartLine> items;
  final double totalAmount;

  String get totalLabel => formatNaira(totalAmount);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }
}
