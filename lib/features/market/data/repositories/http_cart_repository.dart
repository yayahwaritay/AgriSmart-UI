import '../../../../core/network/api_client.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/repositories/cart_repository.dart';

class HttpCartRepository implements CartRepository {
  HttpCartRepository(this._client);

  final ApiClient _client;

  @override
  Future<Cart> fetchCart() async {
    final json = await _client.get('/cart');
    return Cart.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> addItem(String productId, int quantity) async {
    await _client.post('/cart/items', body: {'productId': productId, 'quantity': quantity});
  }

  @override
  Future<void> setQuantity(String productId, int quantity) async {
    await _client.put('/cart/items/$productId', body: {'quantity': quantity});
  }

  @override
  Future<void> removeItem(String productId) async {
    await _client.delete('/cart/items/$productId');
  }

  @override
  Future<void> clearCart() async {
    await _client.delete('/cart');
  }

  @override
  Future<Order> checkout(PaymentMethod method) async {
    assert(method != PaymentMethod.monimeOnline, 'use CheckoutRepository.createSession for monimeOnline');
    final json = await _client.post('/cart/checkout', body: {'paymentMethod': method.wireValue});
    return Order.fromJson(json as Map<String, dynamic>);
  }
}
