import '../../../../core/network/api_client.dart';
import '../../../../core/utils/date_x.dart';
import '../../domain/entities/harvest_prediction.dart';
import '../../domain/repositories/harvest_repository.dart';

/// API-backed predictor — see `POST /harvest/predict` and
/// `GET /harvest/history` in README.mobile.md.
class HttpHarvestRepository implements HarvestRepository {
  HttpHarvestRepository(this._client);

  final ApiClient _client;

  @override
  Future<HarvestPrediction> predict({
    required String cropId,
    required double latitude,
    required double longitude,
    required DateTime plantingDate,
    bool includeDailyTrace = false,
    double? gddToMaturityOverride,
  }) async {
    final json = await _client.post(
      '/harvest/predict',
      body: {
        'cropId': cropId,
        'latitude': latitude,
        'longitude': longitude,
        'plantingDate': plantingDate.toIsoDate(),
        'includeDailyTrace': includeDailyTrace,
        'gddToMaturityOverride': ?gddToMaturityOverride,
      },
    ) as Map<String, dynamic>;
    return HarvestPrediction.fromJson(json);
  }

  @override
  Future<List<HarvestPrediction>> fetchHistory() async {
    final json = await _client.get('/harvest/history') as List<dynamic>;
    return json.map((e) => HarvestPrediction.fromJson(e as Map<String, dynamic>)).toList();
  }
}
