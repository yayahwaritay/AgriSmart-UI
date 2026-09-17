import '../entities/market_category.dart';

abstract interface class CategoryRepository {
  Future<List<MarketCategory>> fetchAll();
}
