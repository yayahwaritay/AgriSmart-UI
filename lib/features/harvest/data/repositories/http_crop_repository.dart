import '../../../../core/network/api_client.dart';
import '../../domain/entities/crop.dart';
import '../../domain/repositories/crop_repository.dart';

class HttpCropRepository implements CropRepository {
  HttpCropRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<CropSummary>> fetchAll() async {
    final json = await _client.get('/crops') as List<dynamic>;
    return json.map((e) => CropSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<CropSummary> fetchById(String cropId) async {
    final json = await _client.get('/crops/$cropId') as Map<String, dynamic>;
    return CropSummary.fromJson(json);
  }
}
