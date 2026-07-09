import '../../domain/entities/market_product.dart';
import '../../domain/repositories/market_repository.dart';

/// Seeded, in-memory catalogue — stands in for a backend the same way
/// [InMemoryScanHistoryRepository] does for scan history.
class InMemoryMarketRepository implements MarketRepository {
  static const _catalogue = [
    // Farm inputs — seeds.
    MarketProduct(
      id: 'seed-maize',
      name: 'Hybrid maize seeds',
      category: ProductCategory.seeds,
      price: 8500,
      unit: '10 kg bag',
      seller: 'GreenGrow Supplies',
      emoji: '🌽',
      description: 'Drought-tolerant hybrid, 95% germination rate.',
    ),
    MarketProduct(
      id: 'seed-tomato',
      name: 'Roma tomato seeds',
      category: ProductCategory.seeds,
      price: 3200,
      unit: '500 g tin',
      seller: 'GreenGrow Supplies',
      emoji: '🍅',
      description: 'High-yield Roma VF variety for open fields.',
    ),
    MarketProduct(
      id: 'seed-rice',
      name: 'FARO 44 rice paddy',
      category: ProductCategory.seeds,
      price: 12000,
      unit: '25 kg bag',
      seller: 'Delta AgroSeeds',
      emoji: '🌾',
      description: 'Certified lowland paddy seed, fast maturing.',
    ),
    MarketProduct(
      id: 'seed-pepper',
      name: 'Habanero pepper seeds',
      category: ProductCategory.seeds,
      price: 2800,
      unit: '250 g tin',
      seller: 'Delta AgroSeeds',
      emoji: '🌶️',
      description: 'Hot pepper strain suited to humid climates.',
    ),
    // Farm inputs — fertilizer.
    MarketProduct(
      id: 'fert-npk',
      name: 'NPK 15-15-15',
      category: ProductCategory.fertilizer,
      price: 21500,
      unit: '50 kg bag',
      seller: 'AgroChem Depot',
      emoji: '🧪',
      description: 'Balanced starter fertilizer for most field crops.',
    ),
    MarketProduct(
      id: 'fert-urea',
      name: 'Urea 46-0-0',
      category: ProductCategory.fertilizer,
      price: 18000,
      unit: '50 kg bag',
      seller: 'AgroChem Depot',
      emoji: '⚗️',
      description: 'High-nitrogen top dressing for maize and rice.',
    ),
    MarketProduct(
      id: 'fert-compost',
      name: 'Organic compost',
      category: ProductCategory.fertilizer,
      price: 6500,
      unit: '40 kg bag',
      seller: 'EarthCare Organics',
      emoji: '🍂',
      description: 'Fully cured compost for soil conditioning.',
    ),
    // Harvested crops listed by farmers.
    MarketProduct(
      id: 'crop-tomatoes',
      name: 'Fresh tomatoes',
      category: ProductCategory.produce,
      price: 9000,
      unit: 'crate',
      seller: 'Amina\'s Farm, Kaduna',
      emoji: '🍅',
      description: 'Picked this week, firm and ripe.',
    ),
    MarketProduct(
      id: 'crop-yam',
      name: 'Puna yam tubers',
      category: ProductCategory.produce,
      price: 15000,
      unit: 'bundle of 5',
      seller: 'Okoro Farms, Benue',
      emoji: '🍠',
      description: 'Large tubers from this season\'s harvest.',
    ),
    MarketProduct(
      id: 'crop-maize',
      name: 'Dry maize grain',
      category: ProductCategory.produce,
      price: 42000,
      unit: '100 kg bag',
      seller: 'Musa Cooperative, Kano',
      emoji: '🌽',
      description: 'Well-dried grain, cleaned and bagged.',
    ),
    MarketProduct(
      id: 'crop-cassava',
      name: 'Cassava roots',
      category: ProductCategory.produce,
      price: 11000,
      unit: '50 kg sack',
      seller: 'Okoro Farms, Benue',
      emoji: '🥔',
      description: 'Fresh roots, ideal for garri or fufu processing.',
    ),
    MarketProduct(
      id: 'crop-plantain',
      name: 'Plantain bunches',
      category: ProductCategory.produce,
      price: 7500,
      unit: 'bunch',
      seller: 'Amina\'s Farm, Kaduna',
      emoji: '🍌',
      description: 'Green cooking plantain, harvested to order.',
    ),
    MarketProduct(
      id: 'crop-greens',
      name: 'Leafy greens (ugu)',
      category: ProductCategory.produce,
      price: 2500,
      unit: 'basket',
      seller: 'Riverside Gardens, Ogun',
      emoji: '🥬',
      description: 'Fluted pumpkin leaves, cut the same morning.',
    ),
  ];

  @override
  Future<List<MarketProduct>> fetchAll() async {
    // Mimic a small network delay so loading states are exercised.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _catalogue;
  }
}
