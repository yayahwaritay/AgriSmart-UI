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
}
