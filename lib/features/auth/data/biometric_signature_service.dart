import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:biometric_signature/biometric_signature.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thrown when a `biometric_signature` operation fails to produce a usable
/// result; [code] is the plugin's own [BiometricError] when known.
class BiometricException implements Exception {
  const BiometricException(this.message, [this.code]);

  final String message;
  final BiometricError? code;

  @override
  String toString() => message;
}

/// Device-local half of README.mobile.md's "Biometric login" flow — key
/// generation and signing only, no networking (see
/// `HttpBiometricRepository` for the server calls).
///
/// Gated to Android/iOS: the plugin also ships a Windows implementation,
/// but Windows only supports RSA keys there (see
/// `CreateKeysConfig.signatureType`'s docs), which can't satisfy the
/// backend's "EC (P-256) key pair" requirement — so biometric login stays
/// mobile-only, matching the README's Android Keystore / iOS Secure
/// Enclave language.
class BiometricSignatureService {
  BiometricSignatureService() : _plugin = BiometricSignature();

  final BiometricSignature _plugin;

  /// One fixed alias — this app only ever needs one login key per device.
  static const _keyAlias = 'agrismart_biometric_login';

  bool get isSupportedPlatform => Platform.isAndroid || Platform.isIOS;

  Future<bool> isAvailable() async {
    if (!isSupportedPlatform) return false;
    final availability = await _plugin.biometricAuthAvailable();
    return availability.canAuthenticate ?? false;
  }

  /// Creates the device's biometric-gated EC (P-256) key pair and returns
  /// the public key as a base64 DER (SubjectPublicKeyInfo) string — ready
  /// to send straight to `POST /auth/biometric/register`.
  Future<String> createKeyPair() async {
    final result = await _plugin.createKeys(
      keyAlias: _keyAlias,
      keyFormat: KeyFormat.base64,
      promptMessage: 'Confirm your identity to enable Face ID / fingerprint login',
      config: CreateKeysConfig(
        signatureType: SignatureType.ecdsa,
        enforceBiometric: true,
        setInvalidatedByBiometricEnrollment: true,
        requireAuthentication: true,
        failIfExists: false,
      ),
    );
    if (result.code != BiometricError.success || result.publicKey == null) {
      throw BiometricException(result.error ?? 'Could not create a biometric key.', result.code);
    }
    return result.publicKey!;
  }

  /// Signs the raw bytes of a server-issued challenge (base64-decoded
  /// first, per README.mobile.md — the challenge isn't guaranteed to be
  /// UTF-8 safe as a string), prompting for biometrics. Returns the
  /// ECDSA-SHA256 DER signature as base64.
  Future<String> sign(String challengeBase64) async {
    final result = await _plugin.createSignatureFromBytes(
      payload: Uint8List.fromList(base64.decode(challengeBase64)),
      keyAlias: _keyAlias,
      signatureFormat: SignatureFormat.base64,
      promptMessage: 'Log in to AgriSmart',
      config: CreateSignatureConfig(),
    );
    if (result.code != BiometricError.success || result.signature == null) {
      throw BiometricException(result.error ?? 'Biometric signing failed.', result.code);
    }
    return result.signature!;
  }

  Future<void> deleteKeyPair() async {
    if (!isSupportedPlatform) return;
    await _plugin.deleteKeys(keyAlias: _keyAlias);
  }
}

final biometricSignatureServiceProvider = Provider<BiometricSignatureService>((ref) {
  return BiometricSignatureService();
});
