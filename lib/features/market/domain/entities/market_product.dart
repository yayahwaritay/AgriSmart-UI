import 'package:flutter/foundation.dart';

/// "₦12,500" — naira with thousands separators. Single place to change if
/// the marketplace ever localises its currency.
String formatNaira(double amount) {
  final digits = amount.toStringAsFixed(0);
  final grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '₦$grouped';
}

/// What a [MarketProduct] is sold as. `produce` is a harvested crop listed
/// by a farmer; the other two are farm inputs.
enum ProductCategory {
  seeds('Seeds'),
  fertilizer('Fertilizer'),
  produce('Harvest');

  const ProductCategory(this.label);

  final String label;
}

/// A listing on the AgriSmart marketplace — seeds, fertilizer, or a
/// harvested crop offered by a farmer.
@immutable
class MarketProduct {
  const MarketProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.seller,
    required this.emoji,
    required this.description,
  });

  final String id;
  final String name;
  final ProductCategory category;

  /// Price in naira for one [unit].
  final double price;

  /// What one purchase quantity means, e.g. "25 kg bag" or "crate".
  final String unit;

  final String seller;
  final String emoji;
  final String description;

  String get priceLabel => formatNaira(price);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MarketProduct && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
