import 'package:flutter/foundation.dart';

/// Monime's own status values for a [CheckoutSession] — distinct from
/// `OrderDto.status`. See README.mobile.md's `GET /checkout/sessions/{id}`.
enum CheckoutSessionStatus {
  pending,
  completed,
  cancelled,
  expired;

  static CheckoutSessionStatus fromJson(String value) {
    return CheckoutSessionStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => CheckoutSessionStatus.pending,
    );
  }
}

/// `CheckoutSessionDto` — returned by `POST /checkout/sessions` and polled
/// via `GET /checkout/sessions/{id}` while the buyer completes payment on
/// Monime's hosted page (`redirectUrl`) — that page is the entire payment
/// experience; there is no separate USSD option.
@immutable
class CheckoutSession {
  const CheckoutSession({
    required this.id,
    required this.orderId,
    required this.monimeSessionId,
    required this.status,
    required this.redirectUrl,
    required this.expireTime,
    required this.amount,
    required this.currency,
  });

  final String id;
  final String orderId;
  final String monimeSessionId;
  final CheckoutSessionStatus status;
  final String redirectUrl;

  /// Monime's default is ~1 hour from creation.
  final DateTime expireTime;
  final double amount;
  final String currency;

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      monimeSessionId: json['monimeSessionId'] as String,
      status: CheckoutSessionStatus.fromJson(json['status'] as String),
      redirectUrl: json['redirectUrl'] as String,
      expireTime: DateTime.parse(json['expireTime'] as String),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }
}
