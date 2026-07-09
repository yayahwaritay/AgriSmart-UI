import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/in_memory_market_repository.dart';
import '../domain/entities/market_product.dart';
import '../domain/repositories/market_repository.dart';

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return InMemoryMarketRepository();
});

final marketProductsProvider = FutureProvider<List<MarketProduct>>((ref) {
  return ref.watch(marketRepositoryProvider).fetchAll();
});

/// `null` means "All" — drives the category chips on the Market screen.
class MarketFilter extends Notifier<ProductCategory?> {
  @override
  ProductCategory? build() => null;

  void select(ProductCategory? category) => state = category;
}

final marketFilterProvider = NotifierProvider<MarketFilter, ProductCategory?>(MarketFilter.new);

final filteredProductsProvider = Provider<AsyncValue<List<MarketProduct>>>((ref) {
  final products = ref.watch(marketProductsProvider);
  final filter = ref.watch(marketFilterProvider);
  if (filter == null) return products;
  return products.whenData(
    (items) => items.where((p) => p.category == filter).toList(),
  );
});

/// Product id → quantity. Kept as a plain map so the cart survives catalogue
/// reloads and stays trivially serialisable later.
class CartNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => const {};

  void add(String productId) {
    state = {...state, productId: (state[productId] ?? 0) + 1};
  }

  void removeOne(String productId) {
    final quantity = state[productId] ?? 0;
    if (quantity <= 1) {
      state = {...state}..remove(productId);
    } else {
      state = {...state, productId: quantity - 1};
    }
  }

  void clear() => state = const {};
}

final cartProvider = NotifierProvider<CartNotifier, Map<String, int>>(CartNotifier.new);

/// A cart line joined with its catalogue product.
class CartItem {
  const CartItem({required this.product, required this.quantity});

  final MarketProduct product;
  final int quantity;

  double get lineTotal => product.price * quantity;
}

/// Cart entries resolved against the loaded catalogue. Empty while the
/// catalogue is still loading — the cart badge and sheet simply show nothing
/// until products arrive.
final cartItemsProvider = Provider<List<CartItem>>((ref) {
  final cart = ref.watch(cartProvider);
  final products = ref.watch(marketProductsProvider).value ?? const <MarketProduct>[];
  return [
    for (final product in products)
      if (cart.containsKey(product.id)) CartItem(product: product, quantity: cart[product.id]!),
  ];
});

final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).values.fold(0, (sum, quantity) => sum + quantity);
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartItemsProvider).fold(0, (sum, item) => sum + item.lineTotal);
});
