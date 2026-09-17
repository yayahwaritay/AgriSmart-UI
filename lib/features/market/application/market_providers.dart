import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/repositories/http_cart_repository.dart';
import '../data/repositories/http_category_repository.dart';
import '../data/repositories/http_market_repository.dart';
import '../domain/entities/cart.dart';
import '../domain/entities/market_category.dart';
import '../domain/entities/market_product.dart';
import '../domain/entities/order.dart';
import '../domain/repositories/cart_repository.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/market_repository.dart';

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return HttpMarketRepository(ref.watch(apiClientProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return HttpCategoryRepository(ref.watch(apiClientProvider));
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return HttpCartRepository(ref.watch(apiClientProvider));
});

final marketProductsProvider = FutureProvider<List<MarketProduct>>((ref) {
  return ref.watch(marketRepositoryProvider).fetchAll();
});

final marketCategoriesProvider = FutureProvider<List<MarketCategory>>((ref) {
  return ref.watch(categoryRepositoryProvider).fetchAll();
});

/// `null` means "All" — drives the category chips on the Market screen.
/// Holds a category id.
class MarketFilter extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? categoryId) => state = categoryId;
}

final marketFilterProvider = NotifierProvider<MarketFilter, String?>(MarketFilter.new);

final filteredProductsProvider = Provider<AsyncValue<List<MarketProduct>>>((ref) {
  final products = ref.watch(marketProductsProvider);
  final filter = ref.watch(marketFilterProvider);
  if (filter == null) return products;
  return products.whenData(
    (items) => items.where((p) => p.categoryId == filter).toList(),
  );
});

/// Cart, fetched from and mutated against the backend — see
/// README.mobile.md's `/cart` endpoints. Every mutation re-fetches the cart
/// afterwards rather than trusting the mutation response shape, which keeps
/// this resilient to whatever each endpoint actually returns.
class CartNotifier extends AsyncNotifier<Cart> {
  @override
  Future<Cart> build() {
    return ref.watch(cartRepositoryProvider).fetchCart();
  }

  Future<void> _mutate(Future<void> Function(CartRepository repo) action) async {
    final repository = ref.read(cartRepositoryProvider);
    try {
      await action(repository);
      state = AsyncData(await repository.fetchCart());
    } catch (e, st) {
      state = AsyncValue<Cart>.error(e, st);
      rethrow;
    }
  }

  Future<void> add(String productId) => _mutate((repo) => repo.addItem(productId, 1));

  Future<void> removeOne(String productId) async {
    final items = state.value?.items ?? const [];
    CartLine? line;
    for (final item in items) {
      if (item.productId == productId) line = item;
    }
    if (line == null) return;
    final quantity = line.quantity;
    await _mutate((repo) {
      return quantity <= 1 ? repo.removeItem(productId) : repo.setQuantity(productId, quantity - 1);
    });
  }

  Future<void> clear() => _mutate((repo) => repo.clearCart());

  Future<Order> checkout() async {
    final repository = ref.read(cartRepositoryProvider);
    try {
      final order = await repository.checkout();
      state = AsyncData(await repository.fetchCart());
      return order;
    } catch (e, st) {
      state = AsyncValue<Cart>.error(e, st);
      rethrow;
    }
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, Cart>(CartNotifier.new);

final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).value?.itemCount ?? 0;
});
