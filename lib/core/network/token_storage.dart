import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the JWT and the logged-in user's own profile JSON across app
/// restarts. There is no `/me` endpoint (see README.mobile.md), so the user
/// profile returned by login/register is cached here rather than re-fetched.
class TokenStorage {
  TokenStorage() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  static const _biometricEmailKey = 'auth_biometric_email';

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<String?> readUserJson() => _storage.read(key: _userKey);

  Future<void> save({required String token, required String userJson}) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: userJson);
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  /// The email biometric login was last enabled for on this device, or
  /// `null` if it isn't enabled. Deliberately untouched by [clear] — a
  /// biometric-enabled login should survive a normal logout (that's the
  /// point: sign back in with Face ID/fingerprint instead of a password).
  Future<String?> readBiometricEmail() => _storage.read(key: _biometricEmailKey);

  Future<void> saveBiometricEmail(String email) => _storage.write(key: _biometricEmailKey, value: email);

  Future<void> clearBiometricEmail() => _storage.delete(key: _biometricEmailKey);
}

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());
