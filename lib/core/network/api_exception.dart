import 'package:flutter/foundation.dart';

/// Thrown for any non-2xx API response. [message] is the API's own
/// human-readable reason (`{ "message": "..." }`, per README.mobile.md).
@immutable
class ApiException implements Exception {
  const ApiException(this.message, this.statusCode);

  final String message;
  final int statusCode;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}
