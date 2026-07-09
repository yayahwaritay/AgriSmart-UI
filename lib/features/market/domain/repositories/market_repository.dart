import '../entities/market_product.dart';

/// Read side of the marketplace catalogue.
abstract interface class MarketRepository {
  Future<List<MarketProduct>> fetchAll();
}
