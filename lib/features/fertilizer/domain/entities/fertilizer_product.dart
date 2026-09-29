import 'package:flutter/foundation.dart';

import 'fertilizer_enums.dart';
import 'json_read.dart';

/// `GET /fertilizer/products` — a fertilizer the farmer might have. Check
/// [hasPrice] rather than `pricePerBag > 0`.
@immutable
class FertilizerProduct {
  const FertilizerProduct({
    required this.id,
    required this.name,
    required this.type,
    required this.nitrogenPercent,
    required this.phosphatePercent,
    required this.potashPercent,
    required this.sulphurPercent,
    required this.zincPercent,
    required this.bagSizeKg,
    required this.pricePerBag,
    required this.hasPrice,
    required this.currency,
    required this.notes,
  });

  final String id;
  final String name;
  final ProductType type;
  final double nitrogenPercent;
  final double phosphatePercent;
  final double potashPercent;
  final double sulphurPercent;
  final double zincPercent;
  final double bagSizeKg;
  final double pricePerBag;
  final bool hasPrice;
  final String currency;
  final String notes;

  factory FertilizerProduct.fromJson(Map<String, dynamic> json) {
    return FertilizerProduct(
      id: readString(json, 'id'),
      name: readString(json, 'name'),
      type: ProductType.fromJson(json['type']),
      nitrogenPercent: readDouble(json, 'nitrogenPercent'),
      phosphatePercent: readDouble(json, 'phosphatePercent'),
      potashPercent: readDouble(json, 'potashPercent'),
      sulphurPercent: readDouble(json, 'sulphurPercent'),
      zincPercent: readDouble(json, 'zincPercent'),
      bagSizeKg: readDouble(json, 'bagSizeKg'),
      pricePerBag: readDouble(json, 'pricePerBag'),
      hasPrice: readBool(json, 'hasPrice'),
      currency: readString(json, 'currency'),
      notes: readString(json, 'notes'),
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is FertilizerProduct && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
