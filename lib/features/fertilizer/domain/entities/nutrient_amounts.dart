import 'package:flutter/foundation.dart';

import 'json_read.dart';

/// `{ "n", "p2o5", "k2o" }` in kg (or kg/ha) — shown as N, P₂O₅, K₂O.
@immutable
class NutrientAmounts {
  const NutrientAmounts({this.n = 0, this.p2o5 = 0, this.k2o = 0});

  final double n;
  final double p2o5;
  final double k2o;

  factory NutrientAmounts.fromJson(Map<String, dynamic> json) {
    return NutrientAmounts(
      n: readDouble(json, 'n'),
      p2o5: readDouble(json, 'p2o5'),
      k2o: readDouble(json, 'k2o'),
    );
  }
}
