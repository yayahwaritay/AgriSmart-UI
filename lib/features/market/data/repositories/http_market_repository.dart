import '../../../../core/network/api_client.dart';
import '../../domain/entities/market_product.dart';
import '../../domain/repositories/market_repository.dart';

class HttpMarketRepository implements MarketRepository {
  HttpMarketRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<MarketProduct>> fetchAll() async {
    final json = await _client.get('/products') as List<dynamic>;
    return json.map((e) => MarketProduct.fromJson(e as Map<String, dynamic>)).toList();
  }
}
