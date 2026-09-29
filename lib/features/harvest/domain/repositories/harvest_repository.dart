import '../entities/harvest_prediction.dart';

abstract class HarvestRepository {
  /// `POST /harvest/predict` — see README.mobile.md. Public: works without
  /// auth, but attaching the caller's token (handled automatically by
  /// [ApiClient]) saves the result to `GET /harvest/history`.
  ///
  /// [plantingDate] must be within 3 years in the past to 1 year in the
  /// future — reject obviously-wrong dates before calling, since the
  /// backend does too (as a `400`). Only set [gddToMaturityOverride] for a
  /// farmer with their own calibrated figure for a specific variety.
  Future<HarvestPrediction> predict({
    required String cropId,
    required double latitude,
    required double longitude,
    required DateTime plantingDate,
    bool includeDailyTrace = false,
    double? gddToMaturityOverride,
  });

  /// `GET /harvest/history` — Buyer auth required. The caller's own saved
  /// predictions, newest first. `dailyTrace` is always `null` on each one.
  Future<List<HarvestPrediction>> fetchHistory();
}
