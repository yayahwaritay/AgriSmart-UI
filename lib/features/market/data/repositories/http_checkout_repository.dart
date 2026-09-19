import '../../../../core/network/api_client.dart';
import '../../domain/entities/checkout_session.dart';
import '../../domain/repositories/checkout_repository.dart';

class HttpCheckoutRepository implements CheckoutRepository {
  HttpCheckoutRepository(this._client);

  final ApiClient _client;

  @override
  Future<CheckoutSession> createSession({String? successUrl, String? cancelUrl}) async {
    final body = <String, dynamic>{
      if (successUrl != null) 'successUrl': successUrl,
      if (cancelUrl != null) 'cancelUrl': cancelUrl,
    };
    // The backend requires a real JSON body — `{}` is valid, but no body at
    // all (even with Content-Type set) gets rejected, so never pass `null`.
    final json = await _client.post('/checkout/sessions', body: body);
    return CheckoutSession.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<CheckoutSession> getSession(String id) async {
    final json = await _client.get('/checkout/sessions/$id');
    return CheckoutSession.fromJson(json as Map<String, dynamic>);
  }
}
