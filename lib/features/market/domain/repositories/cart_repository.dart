import '../entities/cart.dart';
import '../entities/order.dart';

abstract interface class CartRepository {
  Future<Cart> fetchCart();

  /// Increments the line's quantity if [productId] is already in the cart.
  Future<void> addItem(String productId, int quantity);

  Future<void> setQuantity(String productId, int quantity);

  Future<void> removeItem(String productId);

  Future<void> clearCart();

  /// Places an order from the cart's contents and empties it.
  Future<Order> checkout();
}
