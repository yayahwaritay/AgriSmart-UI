import '../entities/crop.dart';

abstract class CropRepository {
  /// `GET /crops` — see README.mobile.md. All crops the predictor supports.
  Future<List<CropSummary>> fetchAll();

  /// `GET /crops/{cropId}` — throws [ApiException] with a `404` if [cropId]
  /// isn't recognized.
  Future<CropSummary> fetchById(String cropId);
}
