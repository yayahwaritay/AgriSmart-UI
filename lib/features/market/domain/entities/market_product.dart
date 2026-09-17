import 'package:flutter/foundation.dart';

/// "₦12,500" — naira with thousands separators. Single place to change if
/// the marketplace ever localises its currency.
String formatNaira(double amount) {
  final digits = amount.toStringAsFixed(0);
  final grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return 'SLE$grouped';
}

/// A listing on the AgriSmart marketplace — seeds, fertilizer, or a
/// harvested crop offered by a farmer. Mirrors `MarketProductDto` from
/// README.mobile.md.
@immutable
class MarketProduct {
  const MarketProduct({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    required this.unit,
    required this.sellerId,
    required this.sellerName,
    required this.description,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String categoryId;
  final String categoryName;

  /// Price in naira for one [unit].
  final double price;

  /// What one purchase quantity means, e.g. "25 kg bag" or "crate".
  final String unit;

  final String sellerId;
  final String sellerName;
  final String description;
  final String? imageUrl;

  String get priceLabel => formatNaira(price);

  factory MarketProduct.fromJson(Map<String, dynamic> json) {
    return MarketProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String,
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MarketProduct && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
