import 'package:flutter/foundation.dart';

import 'fertilizer_enums.dart';
import 'json_read.dart';

double? _optionalDouble(Map<String, dynamic> json, String key) => (json[key] as num?)?.toDouble();

/// The request's `soil` object. In [SoilMode.simple] only [fertility] (plus
/// the optional [soilType] and [ph]) is sent; in [SoilMode.soilTest] the
/// three lab values are sent instead of [fertility].
@immutable
class SoilInput {
  const SoilInput({
    this.mode = SoilMode.simple,
    this.fertility,
    this.soilType,
    this.ph,
    this.nitrogenTotalPercent,
    this.phosphorusBray1MgPerKg,
    this.potassiumCmolPerKg,
  });

  final SoilMode mode;
  final SoilFertility? fertility;
  final SoilType? soilType;
  final double? ph;

  /// Total N, %.
  final double? nitrogenTotalPercent;

  /// Available P (Bray-1), mg/kg.
  final double? phosphorusBray1MgPerKg;

  /// Exchangeable K, cmol/kg.
  final double? potassiumCmolPerKg;

  Map<String, dynamic> toJson() {
    final soilTest = mode == SoilMode.soilTest;
    return {
      'mode': mode.toJson(),
      if (!soilTest) 'fertility': ?fertility?.toJson(),
      'soilType': ?soilType?.toJson(),
      'ph': ?ph,
      if (soilTest) ...{
        'nitrogenTotalPercent': ?nitrogenTotalPercent,
        'phosphorusBray1MgPerKg': ?phosphorusBray1MgPerKg,
        'potassiumCmolPerKg': ?potassiumCmolPerKg,
      },
    };
  }

  factory SoilInput.fromJson(Map<String, dynamic> json) {
    final nitrogen = _optionalDouble(json, 'nitrogenTotalPercent');
    final phosphorus = _optionalDouble(json, 'phosphorusBray1MgPerKg');
    final potassium = _optionalDouble(json, 'potassiumCmolPerKg');
    // The API infers soil-test mode when `mode` is omitted and any lab
    // value is present — mirror that for older saved inputs.
    final inferredTest = nitrogen != null || phosphorus != null || potassium != null;
    final mode = json['mode'] == null || json['mode'] == ''
        ? (inferredTest ? SoilMode.soilTest : SoilMode.simple)
        : SoilMode.fromJson(json['mode']);
    return SoilInput(
      mode: mode,
      fertility: SoilFertility.fromJson(json['fertility']),
      soilType: SoilType.fromJson(json['soilType']),
      ph: _optionalDouble(json, 'ph'),
      nitrogenTotalPercent: nitrogen,
      phosphorusBray1MgPerKg: phosphorus,
      potassiumCmolPerKg: potassium,
    );
  }
}

/// One `customPrices[]` entry — SLE per bag for a product.
@immutable
class CustomPrice {
  const CustomPrice({required this.productId, required this.pricePerBag});

  final String productId;
  final double pricePerBag;

  Map<String, dynamic> toJson() => {'productId': productId, 'pricePerBag': pricePerBag};

  factory CustomPrice.fromJson(Map<String, dynamic> json) {
    return CustomPrice(productId: readString(json, 'productId'), pricePerBag: readDouble(json, 'pricePerBag'));
  }
}

/// Body of `POST /fertilizer/calculate` and (with [plotLabel])
/// `POST /fertilizer/recommendations`. Also the saved record's `inputs`.
@immutable
class FertilizerRequest {
  const FertilizerRequest({
    required this.cropId,
    required this.areaUnit,
    required this.soil,
    this.area,
    this.lengthM,
    this.widthM,
    this.targetYieldTPerHa,
    this.fertilizerProductIds = const [],
    this.customPrices = const [],
    this.plotLabel,
  });

  final String cropId;
  final AreaUnit areaUnit;

  /// For acre / hectare / squareMeter.
  final double? area;

  /// Both only for [AreaUnit.plotDimensions].
  final double? lengthM;
  final double? widthM;
  final SoilInput soil;
  final double? targetYieldTPerHa;

  /// Empty = "Choose for me".
  final List<String> fertilizerProductIds;
  final List<CustomPrice> customPrices;

  /// Save only — max 100 characters.
  final String? plotLabel;

  Map<String, dynamic> toJson() {
    final plot = areaUnit == AreaUnit.plotDimensions;
    final label = plotLabel?.trim();
    return {
      'cropId': cropId,
      'areaUnit': areaUnit.toJson(),
      if (!plot) 'area': ?area,
      if (plot) ...{'lengthM': ?lengthM, 'widthM': ?widthM},
      'soil': soil.toJson(),
      'targetYieldTPerHa': ?targetYieldTPerHa,
      if (fertilizerProductIds.isNotEmpty) 'fertilizerProductIds': fertilizerProductIds,
      if (customPrices.isNotEmpty) 'customPrices': [for (final p in customPrices) p.toJson()],
      if (label != null && label.isNotEmpty) 'plotLabel': label,
    };
  }

  factory FertilizerRequest.fromJson(Map<String, dynamic> json) {
    final label = json['plotLabel'] as String?;
    return FertilizerRequest(
      cropId: readString(json, 'cropId'),
      areaUnit: AreaUnit.fromJson(json['areaUnit']),
      area: _optionalDouble(json, 'area'),
      lengthM: _optionalDouble(json, 'lengthM'),
      widthM: _optionalDouble(json, 'widthM'),
      soil: SoilInput.fromJson(readMap(json, 'soil')),
      targetYieldTPerHa: _optionalDouble(json, 'targetYieldTPerHa'),
      fertilizerProductIds: readStrings(json, 'fertilizerProductIds'),
      customPrices: readList(json, 'customPrices', CustomPrice.fromJson),
      plotLabel: label == null || label.isEmpty ? null : label,
    );
  }

  FertilizerRequest withPlotLabel(String? label) {
    return FertilizerRequest(
      cropId: cropId,
      areaUnit: areaUnit,
      soil: soil,
      area: area,
      lengthM: lengthM,
      widthM: widthM,
      targetYieldTPerHa: targetYieldTPerHa,
      fertilizerProductIds: fertilizerProductIds,
      customPrices: customPrices,
      plotLabel: label,
    );
  }
}
