import '../../../../core/network/api_client.dart';
import '../../domain/entities/market_category.dart';
import '../../domain/repositories/category_repository.dart';

class HttpCategoryRepository implements CategoryRepository {
  HttpCategoryRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<MarketCategory>> fetchAll() async {
    final json = await _client.get('/categories') as List<dynamic>;
    return json.map((e) => MarketCategory.fromJson(e as Map<String, dynamic>)).toList();
  }
}
