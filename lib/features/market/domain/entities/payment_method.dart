/// The three ways a buyer can settle an order — see README.mobile.md's
/// "Checkout — three ways to pay".
enum PaymentMethod {
  /// Pay online now (card/bank/momo, incl. Orange Money) via Monime.
  /// Triggered through `POST /checkout/sessions`, never sent as a
  /// `paymentMethod` body value.
  monimeOnline,

  /// Pay cash in person when picking up the goods.
  cashOnPickup,

  /// Place the order now, unpaid — price/stock held for 24 hours only.
  unpaidHold;

  String get wireValue => name;

  static PaymentMethod fromJson(String value) {
    return PaymentMethod.values.firstWhere((m) => m.name == value, orElse: () => PaymentMethod.cashOnPickup);
  }
}
