import 'package:flutter/foundation.dart';

import 'json_read.dart';
import 'nutrient_amounts.dart';

/// One split in a [FertilizerCrop]'s application schedule, e.g. "Basal (at
/// planting)" taking 40% of the N and all of the P and K.
@immutable
class CropScheduleSplit {
  const CropScheduleSplit({
    required this.stage,
    required this.daysAfterPlanting,
    required this.timing,
    required this.nitrogenPercent,
    required this.phosphatePercent,
    required this.potashPercent,
  });

  final String stage;
  final int daysAfterPlanting;
  final String timing;
  final double nitrogenPercent;
  final double phosphatePercent;
  final double potashPercent;

  factory CropScheduleSplit.fromJson(Map<String, dynamic> json) {
    return CropScheduleSplit(
      stage: readString(json, 'stage'),
      daysAfterPlanting: readInt(json, 'daysAfterPlanting'),
      timing: readString(json, 'timing'),
      nitrogenPercent: readDouble(json, 'nitrogenPercent'),
      phosphatePercent: readDouble(json, 'phosphatePercent'),
      potashPercent: readDouble(json, 'potashPercent'),
    );
  }
}

/// `GET /fertilizer/crops` — see README.fertilizer.mobile.md. A separate
/// catalog from the harvest predictor's crops, though ids match where both
/// exist. Don't hardcode the list.
@immutable
class FertilizerCrop {
  const FertilizerCrop({
    required this.id,
    required this.name,
    required this.localName,
    required this.nutrientRequirementKgPerHa,
    required this.referenceYieldTPerHa,
    required this.maxRealisticYieldTPerHa,
    required this.yieldBasis,
    required this.plantsPerHectare,
    required this.isPerennial,
    required this.notes,
    required this.schedule,
  });

  /// Stable key (e.g. `"maize"`) — pass back as `cropId`.
  final String id;
  final String name;

  /// Krio name, or `""` when there isn't one.
  final String localName;
  final NutrientAmounts nutrientRequirementKgPerHa;
  final double referenceYieldTPerHa;
  final double maxRealisticYieldTPerHa;

  /// What the yield is measured as, e.g. "dry grain".
  final String yieldBasis;
  final int plantsPerHectare;

  /// Tree crops (cocoa, oil palm): rates are per year for mature trees.
  final bool isPerennial;
  final String notes;
  final List<CropScheduleSplit> schedule;

  factory FertilizerCrop.fromJson(Map<String, dynamic> json) {
    return FertilizerCrop(
      id: readString(json, 'id'),
      name: readString(json, 'name'),
      localName: readString(json, 'localName'),
      nutrientRequirementKgPerHa: NutrientAmounts.fromJson(readMap(json, 'nutrientRequirementKgPerHa')),
      referenceYieldTPerHa: readDouble(json, 'referenceYieldTPerHa'),
      maxRealisticYieldTPerHa: readDouble(json, 'maxRealisticYieldTPerHa'),
      yieldBasis: readString(json, 'yieldBasis'),
      plantsPerHectare: readInt(json, 'plantsPerHectare'),
      isPerennial: readBool(json, 'isPerennial'),
      notes: readString(json, 'notes'),
      schedule: readList(json, 'schedule', CropScheduleSplit.fromJson),
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is FertilizerCrop && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
