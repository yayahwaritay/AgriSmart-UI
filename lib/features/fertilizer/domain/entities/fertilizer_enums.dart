/// The fertilizer API's enums — serialized as camelCase strings, see
/// README.fertilizer.mobile.md's "JSON conventions". Each enum's [name]
/// already is the wire value, so `toJson` is just `name`; unknown strings
/// fall back to a safe default rather than throwing.
library;

T _byName<T extends Enum>(List<T> values, Object? value, T fallback) {
  for (final v in values) {
    if (v.name == value) return v;
  }
  return fallback;
}

enum AreaUnit {
  acre,
  hectare,
  squareMeter,
  plotDimensions;

  static AreaUnit fromJson(Object? value) => _byName(values, value, AreaUnit.hectare);

  String toJson() => name;

  String get label => switch (this) {
        AreaUnit.acre => 'Acres',
        AreaUnit.hectare => 'Hectares',
        AreaUnit.squareMeter => 'Square metres',
        AreaUnit.plotDimensions => 'Length × width',
      };

  String get shortLabel => switch (this) {
        AreaUnit.acre => 'acre',
        AreaUnit.hectare => 'ha',
        AreaUnit.squareMeter => 'm²',
        AreaUnit.plotDimensions => 'm',
      };
}

enum SoilMode {
  simple,
  soilTest;

  static SoilMode fromJson(Object? value) => _byName(values, value, SoilMode.simple);

  String toJson() => name;
}

enum SoilFertility {
  low,
  medium,
  high;

  /// `null` when absent — fertility is optional in soil-test mode.
  static SoilFertility? fromJson(Object? value) => value == null || value == '' ? null : _byName(values, value, SoilFertility.medium);

  String toJson() => name;
}

enum SoilType {
  sandy,
  loamy,
  clay;

  static SoilType? fromJson(Object? value) => value == null || value == '' ? null : _byName(values, value, SoilType.loamy);

  String toJson() => name;
}

enum ProductType {
  compound,
  straight,
  organic;

  static ProductType fromJson(Object? value) => _byName(values, value, ProductType.compound);

  String toJson() => name;

  String get label => switch (this) {
        ProductType.compound => 'Compound (NPK)',
        ProductType.straight => 'Straight',
        ProductType.organic => 'Organic',
      };
}

enum SelectionMode {
  automatic,
  farmerSelected;

  static SelectionMode fromJson(Object? value) => _byName(values, value, SelectionMode.automatic);

  String toJson() => name;
}

/// A soil nutrient's Low/Medium/High class in `soilAdjustment`.
enum NutrientClass {
  low,
  medium,
  high;

  static NutrientClass fromJson(Object? value) => _byName(values, value, NutrientClass.medium);

  String toJson() => name;

  String get label => switch (this) {
        NutrientClass.low => 'Low',
        NutrientClass.medium => 'Medium',
        NutrientClass.high => 'High',
      };
}
