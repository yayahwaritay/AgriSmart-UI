import '../entities/fertilizer_crop.dart';
import '../entities/fertilizer_product.dart';
import '../entities/fertilizer_recommendation.dart';
import '../entities/fertilizer_request.dart';
import '../entities/fertilizer_result.dart';

abstract class FertilizerRepository {
  /// `GET /fertilizer/crops` — public. See README.fertilizer.mobile.md.
  Future<List<FertilizerCrop>> fetchCrops();

  /// `GET /fertilizer/products` — public.
  Future<List<FertilizerProduct>> fetchProducts();

  /// `POST /fertilizer/calculate` — public and stateless; nothing is saved.
  /// A `400` carries field errors in [ApiException.errors].
  Future<FertilizerResult> calculate(FertilizerRequest request);

  /// `POST /fertilizer/recommendations` — auth required. Calculates and
  /// saves, with the request's optional `plotLabel`.
  Future<FertilizerRecommendation> save(FertilizerRequest request);

  /// `GET /fertilizer/recommendations` — the caller's own history, newest
  /// first. [plotLabel] is an exact, case-insensitive match.
  Future<PagedResult<RecommendationSummary>> fetchHistory({
    int page = 1,
    int pageSize = 20,
    String? cropId,
    String? plotLabel,
  });

  /// `GET /fertilizer/recommendations/{id}` — `404` for someone else's.
  Future<FertilizerRecommendation> fetchRecommendation(String id);

  /// `DELETE /fertilizer/recommendations/{id}` — `204`.
  Future<void> deleteRecommendation(String id);
}
