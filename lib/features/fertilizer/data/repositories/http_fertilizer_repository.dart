import '../../../../core/network/api_client.dart';
import '../../domain/entities/fertilizer_crop.dart';
import '../../domain/entities/fertilizer_product.dart';
import '../../domain/entities/fertilizer_recommendation.dart';
import '../../domain/entities/fertilizer_request.dart';
import '../../domain/entities/fertilizer_result.dart';
import '../../domain/repositories/fertilizer_repository.dart';

/// API-backed fertilizer calculator — see README.fertilizer.mobile.md.
class HttpFertilizerRepository implements FertilizerRepository {
  HttpFertilizerRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<FertilizerCrop>> fetchCrops() async {
    final json = await _client.get('/fertilizer/crops') as List<dynamic>;
    return json.map((e) => FertilizerCrop.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<FertilizerProduct>> fetchProducts() async {
    final json = await _client.get('/fertilizer/products') as List<dynamic>;
    return json.map((e) => FertilizerProduct.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<FertilizerResult> calculate(FertilizerRequest request) async {
    final json = await _client.post('/fertilizer/calculate', body: request.toJson()) as Map<String, dynamic>;
    return FertilizerResult.fromJson(json);
  }

  @override
  Future<FertilizerRecommendation> save(FertilizerRequest request) async {
    final json = await _client.post('/fertilizer/recommendations', body: request.toJson()) as Map<String, dynamic>;
    return FertilizerRecommendation.fromJson(json);
  }

  @override
  Future<PagedResult<RecommendationSummary>> fetchHistory({
    int page = 1,
    int pageSize = 20,
    String? cropId,
    String? plotLabel,
  }) async {
    final json = await _client.get(
      '/fertilizer/recommendations',
      query: {
        'page': page,
        'pageSize': pageSize,
        'cropId': ?cropId,
        'plotLabel': ?plotLabel,
      },
    ) as Map<String, dynamic>;
    return PagedResult.fromJson(json, RecommendationSummary.fromJson);
  }

  @override
  Future<FertilizerRecommendation> fetchRecommendation(String id) async {
    final json = await _client.get('/fertilizer/recommendations/$id') as Map<String, dynamic>;
    return FertilizerRecommendation.fromJson(json);
  }

  @override
  Future<void> deleteRecommendation(String id) async {
    await _client.delete('/fertilizer/recommendations/$id');
  }
}
