import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/device_id.dart';
import '../../../core/network/token_storage.dart';
import '../data/biometric_signature_service.dart';
import '../data/repositories/http_auth_repository.dart';
import '../data/repositories/http_biometric_repository.dart';
import '../domain/entities/app_user.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/biometric_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return HttpAuthRepository(ref.watch(apiClientProvider));
});

final biometricRepositoryProvider = Provider<BiometricRepository>((ref) {
  return HttpBiometricRepository(ref.watch(apiClientProvider));
});

enum AuthStatus { unknown, authenticated, unauthenticated }

@immutable
class AuthState {
  const AuthState({required this.status, this.user, this.token, this.errorMessage, this.biometricEmail});

  const AuthState.unknown() : this(status: AuthStatus.unknown);

  const AuthState.unauthenticated([String? errorMessage, String? biometricEmail])
      : this(status: AuthStatus.unauthenticated, errorMessage: errorMessage, biometricEmail: biometricEmail);

  const AuthState.authenticated(AppUser user, String token, [String? biometricEmail])
      : this(status: AuthStatus.authenticated, user: user, token: token, biometricEmail: biometricEmail);

  final AuthStatus status;
  final AppUser? user;
  final String? token;
  final String? errorMessage;

  /// The email biometric login is registered for on this device, or `null`
  /// if it isn't enabled — see README.mobile.md's "Biometric login"
  /// section. Independent of [status]: it survives logout, since the whole
  /// point is signing back in with Face ID/fingerprint instead of a
  /// password.
  final String? biometricEmail;

  bool get biometricEnabled => biometricEmail != null;
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _restore();
    return const AuthState.unknown();
  }

  Future<void> _restore() async {
    try {
      final storage = ref.read(tokenStorageProvider);
      final token = await storage.readToken();
      final userJson = await storage.readUserJson();
      final biometricEmail = await storage.readBiometricEmail();

      if (token == null || userJson == null) {
        state = AuthState.unauthenticated(null, biometricEmail);
        return;
      }
      final user = AppUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      state = AuthState.authenticated(user, token, biometricEmail);
    } catch (_) {
      // Secure storage can throw (no keychain access, corrupted entry, no
      // plugin in a test host, ...) — treat it as "no saved session" rather
      // than leaving the app stuck on the splash screen forever.
      state = const AuthState.unauthenticated();
    }
  }

  Future<bool> _persist(String token, AppUser user) async {
    await ref.read(tokenStorageProvider).save(token: token, userJson: jsonEncode(user.toJson()));
    state = AuthState.authenticated(user, token, state.biometricEmail);
    return true;
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      final result = await ref.read(authRepositoryProvider).login(email: email, password: password);
      return _persist(result.token, result.user);
    } on ApiException catch (e) {
      state = AuthState.unauthenticated(e.message, state.biometricEmail);
      return false;
    }
  }

  Future<bool> register({required String name, required String email, required String password}) async {
    try {
      final result = await ref.read(authRepositoryProvider).register(name: name, email: email, password: password);
      return _persist(result.token, result.user);
    } on ApiException catch (e) {
      state = AuthState.unauthenticated(e.message, state.biometricEmail);
      return false;
    }
  }

  /// Changes the current account's password — used both for a voluntary
  /// change from the profile screen and to finish a temporary-password
  /// reset (pass the temporary password as [currentPassword]; see
  /// README.mobile.md "Reset / forgot password"). Clears
  /// `mustChangePassword` on the persisted user so the forced-reset
  /// redirect doesn't fire again.
  Future<bool> changePassword({required String currentPassword, required String newPassword}) async {
    final user = state.user;
    final token = state.token;
    if (state.status != AuthStatus.authenticated || user == null || token == null) return false;

    try {
      await ref
          .read(authRepositoryProvider)
          .changePassword(currentPassword: currentPassword, newPassword: newPassword);
      final updatedUser = user.copyWith(mustChangePassword: false);
      await ref.read(tokenStorageProvider).save(token: token, userJson: jsonEncode(updatedUser.toJson()));
      state = AuthState.authenticated(updatedUser, token, state.biometricEmail);
      return true;
    } on ApiException catch (e) {
      state = AuthState(
        status: state.status,
        user: state.user,
        token: state.token,
        biometricEmail: state.biometricEmail,
        errorMessage: e.message,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clear();
    state = AuthState.unauthenticated(null, state.biometricEmail);
  }

  Future<void> forceLogout() async {
    await ref.read(tokenStorageProvider).clear();
    state = AuthState.unauthenticated('Session expired — please log in again.', state.biometricEmail);
  }

  // --- Biometric login (README.mobile.md "Biometric login") ---

  Future<bool> biometricAvailable() => ref.read(biometricSignatureServiceProvider).isAvailable();

  /// Enables biometric login for the current account on this device. Must
  /// be called while authenticated — reads the current user's email and
  /// token to register the device's new key with the server.
  Future<bool> enableBiometric() async {
    final user = state.user;
    if (state.status != AuthStatus.authenticated || user == null) return false;

    try {
      final biometricService = ref.read(biometricSignatureServiceProvider);
      if (!await biometricService.isAvailable()) {
        throw const BiometricException('No biometrics are enrolled on this device.');
      }
      final publicKey = await biometricService.createKeyPair();
      final deviceId = await ref.read(deviceIdProvider.future);
      await ref.read(biometricRepositoryProvider).registerKey(deviceId: deviceId, publicKey: publicKey);
      await ref.read(tokenStorageProvider).saveBiometricEmail(user.email);
      state = AuthState(status: state.status, user: state.user, token: state.token, biometricEmail: user.email);
      return true;
    } catch (e) {
      state = AuthState(
        status: state.status,
        user: state.user,
        token: state.token,
        biometricEmail: state.biometricEmail,
        errorMessage: e is BiometricException || e is ApiException ? '$e' : 'Could not enable biometric login.',
      );
      return false;
    }
  }

  /// Turns biometric login off for this device — best-effort server-side
  /// (only possible while still holding a valid token), always local.
  Future<void> disableBiometric() async {
    try {
      if (state.token != null) {
        final deviceId = await ref.read(deviceIdProvider.future);
        await ref.read(biometricRepositoryProvider).unregisterKey(deviceId);
      }
    } catch (_) {
      // Ignore — deleting the on-device key below is what actually stops
      // biometric login from working here; a failed server call just
      // leaves an orphaned registration the account owner can't reach.
    }
    await ref.read(biometricSignatureServiceProvider).deleteKeyPair();
    await ref.read(tokenStorageProvider).clearBiometricEmail();
    state = AuthState(status: state.status, user: state.user, token: state.token);
  }

  /// Signs in using the device's registered biometric key. Only meaningful
  /// while [AuthState.biometricEnabled] is true.
  Future<bool> loginWithBiometric() async {
    final email = state.biometricEmail;
    if (email == null) return false;

    try {
      final deviceId = await ref.read(deviceIdProvider.future);
      final biometricRepository = ref.read(biometricRepositoryProvider);
      final challenge = await biometricRepository.requestChallenge(email: email, deviceId: deviceId);
      final signature = await ref.read(biometricSignatureServiceProvider).sign(challenge);
      final result = await biometricRepository.login(email: email, deviceId: deviceId, signature: signature);
      return _persist(result.token, result.user);
    } catch (e) {
      // A 400 (README: "account/device never registered a key") or a
      // signing failure from an invalidated key (fingerprints changed)
      // both mean this device's registration is dead — clear it and fall
      // back to the password form, per README.mobile.md.
      await ref.read(tokenStorageProvider).clearBiometricEmail();
      await ref.read(biometricSignatureServiceProvider).deleteKeyPair();
      state = AuthState.unauthenticated(
        e is ApiException ? e.message : 'Biometric login failed — please use your password.',
      );
      return false;
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
