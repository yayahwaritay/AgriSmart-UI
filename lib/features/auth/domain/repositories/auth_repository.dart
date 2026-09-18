import 'package:flutter/foundation.dart';

import '../entities/app_user.dart';

@immutable
class AuthResult {
  const AuthResult({required this.token, required this.user});

  final String token;
  final AppUser user;
}

abstract interface class AuthRepository {
  Future<AuthResult> register({required String name, required String email, required String password});

  Future<AuthResult> login({required String email, required String password});

  /// `POST /auth/change-password` — used both for a voluntary password
  /// change and to finish a temporary-password reset (pass the temporary
  /// password as [currentPassword]). See README.mobile.md "Reset / forgot
  /// password".
  Future<void> changePassword({required String currentPassword, required String newPassword});
}
