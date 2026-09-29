import 'package:flutter/foundation.dart';

/// One growth phase in a [CropSummary.stages] timeline, e.g. "Flowering"
/// starting at 45% of the way to maturity.
@immutable
class CropStage {
  const CropStage({required this.name, required this.startFraction});

  final String name;

  /// `0.0`-`1.0` — the fraction of [CropSummary.gddToMaturity] at which this
  /// stage begins.
  final double startFraction;

  factory CropStage.fromJson(Map<String, dynamic> json) {
    return CropStage(
      name: json['name'] as String,
      startFraction: (json['startFraction'] as num).toDouble(),
    );
  }
}

/// `CropSummaryDto` — see README.mobile.md's "Crops & Harvest Prediction".
/// Populate a crop picker from `GET /crops`; don't hardcode the list.
@immutable
class CropSummary {
  const CropSummary({
    required this.id,
    required this.name,
    required this.baseTemperatureC,
    required this.upperTemperatureC,
    required this.gddToMaturity,
    required this.typicalDaysToMaturity,
    required this.stages,
  });

  /// Opaque catalog key (e.g. `"maize"`, `"rice-lowland"`) — pass this back
  /// as `cropId` when predicting. Not something to construct client-side.
  final String id;

  final String name;
  final double baseTemperatureC;
  final double upperTemperatureC;

  /// Growing-degree-days required to reach maturity — what actually drives
  /// the prediction (unlike [typicalDaysToMaturity], which is just a rough
  /// calendar-day sanity check).
  final double gddToMaturity;
  final int typicalDaysToMaturity;
  final List<CropStage> stages;

  factory CropSummary.fromJson(Map<String, dynamic> json) {
    return CropSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      baseTemperatureC: (json['baseTemperatureC'] as num).toDouble(),
      upperTemperatureC: (json['upperTemperatureC'] as num).toDouble(),
      gddToMaturity: (json['gddToMaturity'] as num).toDouble(),
      typicalDaysToMaturity: json['typicalDaysToMaturity'] as int,
      stages: (json['stages'] as List<dynamic>)
          .map((e) => CropStage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is CropSummary && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
