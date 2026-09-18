import 'package:flutter/foundation.dart';

@immutable
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.mustChangePassword = false,
  });

  final String id;
  final String name;
  final String email;
  final String role;

  /// `true` for an admin-issued account still on its temporary password —
  /// see README.mobile.md's "Reset / forgot password" section. The app must
  /// route straight to a "set a new password" screen when this is set.
  final bool mustChangePassword;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      mustChangePassword: json['mustChangePassword'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'email': email, 'role': role, 'mustChangePassword': mustChangePassword};

  AppUser copyWith({bool? mustChangePassword}) => AppUser(
        id: id,
        name: name,
        email: email,
        role: role,
        mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      );
}
