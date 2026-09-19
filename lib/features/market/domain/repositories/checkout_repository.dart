import '../entities/checkout_session.dart';

/// The "pay online via Monime" checkout path — `POST /checkout/sessions`
/// starts a session against the caller's cart; `GET /checkout/sessions/{id}`
/// polls it while the buyer completes payment on Monime's hosted page (or
/// by dialing the returned USSD code). See README.mobile.md's
/// "Checkout — three ways to pay", path 1.
abstract interface class CheckoutRepository {
  /// [successUrl]/[cancelUrl] are optional deep links back into the app;
  /// omit both to use the backend's configured default pages.
  Future<CheckoutSession> createSession({String? successUrl, String? cancelUrl});

  /// Polls the caller's own session. `404`s if it isn't the caller's.
  Future<CheckoutSession> getSession(String id);
}
