import 'package:flutter/foundation.dart';

import 'fertilizer_enums.dart';
import 'json_read.dart';
import 'nutrient_amounts.dart';

/// How the soil changed the rates — `result.soilAdjustment`.
@immutable
class SoilAdjustment {
  const SoilAdjustment({
    required this.mode,
    required this.nitrogenClass,
    required this.phosphorusClass,
    required this.potassiumClass,
    required this.nitrogenFactor,
    required this.phosphateFactor,
    required this.potashFactor,
  });

  final SoilMode mode;
  final NutrientClass nitrogenClass;
  final NutrientClass phosphorusClass;
  final NutrientClass potassiumClass;
  final double nitrogenFactor;
  final double phosphateFactor;
  final double potashFactor;

  factory SoilAdjustment.fromJson(Map<String, dynamic> json) {
    return SoilAdjustment(
      mode: SoilMode.fromJson(json['mode']),
      nitrogenClass: NutrientClass.fromJson(json['nitrogenClass']),
      phosphorusClass: NutrientClass.fromJson(json['phosphorusClass']),
      potassiumClass: NutrientClass.fromJson(json['potassiumClass']),
      nitrogenFactor: readDouble(json, 'nitrogenFactor'),
      phosphateFactor: readDouble(json, 'phosphateFactor'),
      potashFactor: readDouble(json, 'potashFactor'),
    );
  }
}

/// One shopping-list line — `result.products[]`.
@immutable
class ProductQuantity {
  const ProductQuantity({
    required this.productId,
    required this.name,
    required this.type,
    required this.quantityKg,
    required this.bagSizeKg,
    required this.bags,
    required this.bags50Kg,
    required this.pricePerBag,
    required this.hasPrice,
    required this.estimatedCost,
    required this.nutrientsSupplied,
  });

  final String productId;
  final String name;
  final ProductType type;
  final double quantityKg;
  final double bagSizeKg;

  /// Bags of this product's own [bagSizeKg].
  final double bags;

  /// Always counts 50 kg bags, rounded up to the nearest half.
  final double bags50Kg;
  final double pricePerBag;
  final bool hasPrice;

  /// Only meaningful when [hasPrice].
  final double estimatedCost;
  final NutrientAmounts nutrientsSupplied;

  /// True when the product's own bag isn't 50 kg, so [bags] differs from
  /// [bags50Kg] and should be shown too.
  bool get hasNonStandardBag => bagSizeKg > 0 && bagSizeKg != 50;

  factory ProductQuantity.fromJson(Map<String, dynamic> json) {
    return ProductQuantity(
      productId: readString(json, 'productId'),
      name: readString(json, 'name'),
      type: ProductType.fromJson(json['type']),
      quantityKg: readDouble(json, 'quantityKg'),
      bagSizeKg: readDouble(json, 'bagSizeKg'),
      bags: readDouble(json, 'bags'),
      bags50Kg: readDouble(json, 'bags50Kg'),
      pricePerBag: readDouble(json, 'pricePerBag'),
      hasPrice: readBool(json, 'hasPrice'),
      estimatedCost: readDouble(json, 'estimatedCost'),
      nutrientsSupplied: NutrientAmounts.fromJson(readMap(json, 'nutrientsSupplied')),
    );
  }
}

/// A product applied at one [ScheduleStage].
@immutable
class ScheduleProduct {
  const ScheduleProduct({
    required this.productId,
    required this.name,
    required this.quantityKg,
    required this.gramsPerPlant,
    required this.perPlantHint,
  });

  final String productId;
  final String name;
  final double quantityKg;
  final double gramsPerPlant;

  /// e.g. "about 1.5 level bottle caps per plant (1 cap ≈ 5 g)", or `""`
  /// for broadcast crops (rice, groundnut) with no plant population.
  final String perPlantHint;

  factory ScheduleProduct.fromJson(Map<String, dynamic> json) {
    return ScheduleProduct(
      productId: readString(json, 'productId'),
      name: readString(json, 'name'),
      quantityKg: readDouble(json, 'quantityKg'),
      gramsPerPlant: readDouble(json, 'gramsPerPlant'),
      perPlantHint: readString(json, 'perPlantHint'),
    );
  }
}

/// One step of "When to apply" — `result.schedule[]`.
@immutable
class ScheduleStage {
  const ScheduleStage({
    required this.stage,
    required this.daysAfterPlanting,
    required this.timing,
    required this.nutrients,
    required this.products,
  });

  final String stage;

  /// For perennials, days after the start of the rains ([timing] says so).
  final int daysAfterPlanting;
  final String timing;
  final NutrientAmounts nutrients;
  final List<ScheduleProduct> products;

  factory ScheduleStage.fromJson(Map<String, dynamic> json) {
    return ScheduleStage(
      stage: readString(json, 'stage'),
      daysAfterPlanting: readInt(json, 'daysAfterPlanting'),
      timing: readString(json, 'timing'),
      nutrients: NutrientAmounts.fromJson(readMap(json, 'nutrients')),
      products: readList(json, 'products', ScheduleProduct.fromJson),
    );
  }
}

/// `POST /fertilizer/calculate`'s response, and a saved record's `result`.
@immutable
class FertilizerResult {
  const FertilizerResult({
    required this.cropId,
    required this.crop,
    required this.areaHectares,
    required this.targetYieldTPerHa,
    required this.targetYieldCapped,
    required this.yieldBasis,
    required this.soilAdjustment,
    required this.nutrientRequirementPerHaKg,
    required this.nutrientRequirementKg,
    required this.selectionMode,
    required this.products,
    required this.nutrientsSupplied,
    required this.nutrientBalanceKg,
    required this.schedule,
    required this.plantCount,
    required this.totalEstimatedCost,
    required this.costComplete,
    required this.currency,
    required this.warnings,
    required this.notes,
  });

  final String cropId;

  /// The crop's display name.
  final String crop;
  final double areaHectares;
  final double targetYieldTPerHa;
  final bool targetYieldCapped;
  final String yieldBasis;
  final SoilAdjustment soilAdjustment;
  final NutrientAmounts nutrientRequirementPerHaKg;
  final NutrientAmounts nutrientRequirementKg;
  final SelectionMode selectionMode;

  /// Empty when no fertilizer is needed (the first note explains why).
  final List<ProductQuantity> products;
  final NutrientAmounts nutrientsSupplied;

  /// + = over-supply, − = shortfall.
  final NutrientAmounts nutrientBalanceKg;
  final List<ScheduleStage> schedule;
  final int plantCount;

  /// Covers only priced products when [costComplete] is false.
  final double totalEstimatedCost;
  final bool costComplete;
  final String currency;
  final List<String> warnings;

  /// Advice; the last one is always the disclaimer.
  final List<String> notes;

  factory FertilizerResult.fromJson(Map<String, dynamic> json) {
    return FertilizerResult(
      cropId: readString(json, 'cropId'),
      crop: readString(json, 'crop'),
      areaHectares: readDouble(json, 'areaHectares'),
      targetYieldTPerHa: readDouble(json, 'targetYieldTPerHa'),
      targetYieldCapped: readBool(json, 'targetYieldCapped'),
      yieldBasis: readString(json, 'yieldBasis'),
      soilAdjustment: SoilAdjustment.fromJson(readMap(json, 'soilAdjustment')),
      nutrientRequirementPerHaKg: NutrientAmounts.fromJson(readMap(json, 'nutrientRequirementPerHaKg')),
      nutrientRequirementKg: NutrientAmounts.fromJson(readMap(json, 'nutrientRequirementKg')),
      selectionMode: SelectionMode.fromJson(json['selectionMode']),
      products: readList(json, 'products', ProductQuantity.fromJson),
      nutrientsSupplied: NutrientAmounts.fromJson(readMap(json, 'nutrientsSupplied')),
      nutrientBalanceKg: NutrientAmounts.fromJson(readMap(json, 'nutrientBalanceKg')),
      schedule: readList(json, 'schedule', ScheduleStage.fromJson),
      plantCount: readInt(json, 'plantCount'),
      totalEstimatedCost: readDouble(json, 'totalEstimatedCost'),
      costComplete: readBool(json, 'costComplete'),
      currency: readString(json, 'currency'),
      warnings: readStrings(json, 'warnings'),
      notes: readStrings(json, 'notes'),
    );
  }
}
