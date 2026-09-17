import 'auth_repository.dart';

/// Server side of README.mobile.md's "Biometric login" flow — see
/// `BiometricSignatureService` for the on-device key generation/signing
/// half.
abstract interface class BiometricRepository {
  /// `POST /auth/biometric/register` — enables biometric login for this
  /// account/device pair. Requires an existing JWT.
  Future<void> registerKey({required String deviceId, required String publicKey});

  /// `POST /auth/biometric/challenge` — returns a base64 challenge to sign,
  /// or throws an ApiException (400) if this account/device never
  /// registered a key.
  Future<String> requestChallenge({required String email, required String deviceId});

  /// `POST /auth/biometric/login` — exchanges a signed challenge for a
  /// normal session. The challenge is single-use and expires after 2
  /// minutes, so call this immediately after signing.
  Future<AuthResult> login({required String email, required String deviceId, required String signature});

  /// `DELETE /auth/biometric/{deviceId}` — turns biometric login off for
  /// this device. Requires an existing JWT.
  Future<void> unregisterKey(String deviceId);
}
