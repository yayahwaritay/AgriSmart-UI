import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/repositories/http_cart_repository.dart';
import '../data/repositories/http_category_repository.dart';
import '../data/repositories/http_checkout_repository.dart';
import '../data/repositories/http_market_repository.dart';
import '../domain/entities/cart.dart';
import '../domain/entities/checkout_session.dart';
import '../domain/entities/market_category.dart';
import '../domain/entities/market_product.dart';
import '../domain/entities/order.dart';
import '../domain/entities/payment_method.dart';
import '../domain/repositories/cart_repository.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/checkout_repository.dart';
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

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  return HttpCheckoutRepository(ref.watch(apiClientProvider));
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

  /// Places a cash-on-pickup or unpaid-hold order. For paying online via
  /// Monime use [checkoutSessionControllerProvider] instead — see
  /// README.mobile.md's "Checkout — three ways to pay".
  Future<Order> checkout(PaymentMethod method) async {
    final repository = ref.read(cartRepositoryProvider);
    try {
      final order = await repository.checkout(method);
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

/// Drives the "pay online via Monime" flow: creates a checkout session
/// against the caller's cart, then polls it every few seconds so the UI can
/// reflect completion without waiting for an admin to reconcile it. See
/// README.mobile.md's `POST /checkout/sessions` / `GET /checkout/sessions/{id}`.
class CheckoutSessionController extends AsyncNotifier<CheckoutSession> {
  Timer? _pollTimer;

  @override
  Future<CheckoutSession> build() async {
    ref.onDispose(() => _pollTimer?.cancel());
    final session = await ref.read(checkoutRepositoryProvider).createSession();
    // The session is created against the cart's current contents — refresh
    // it so the cart badge/sheet reflect that it's now spoken for.
    ref.invalidate(cartProvider);
    _schedulePoll(session.id);
    return session;
  }

  void _schedulePoll(String sessionId) {
    _pollTimer?.cancel();
    _pollTimer = Timer(const Duration(seconds: 4), () => _poll(sessionId));
  }

  Future<void> _poll(String sessionId) async {
    if (!ref.mounted) return;
    try {
      final session = await ref.read(checkoutRepositoryProvider).getSession(sessionId);
      if (!ref.mounted) return;
      state = AsyncData(session);
      if (session.status == CheckoutSessionStatus.pending) {
        _schedulePoll(sessionId);
      }
    } catch (_) {
      // Transient network hiccup while polling — keep trying rather than
      // surfacing an error over what may still be a valid, pending session.
      if (ref.mounted) _schedulePoll(sessionId);
    }
  }
}

final checkoutSessionControllerProvider =
    AsyncNotifierProvider.autoDispose<CheckoutSessionController, CheckoutSession>(CheckoutSessionController.new);
