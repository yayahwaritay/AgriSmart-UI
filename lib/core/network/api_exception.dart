import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Thrown for any non-2xx API response. [message] is the API's own
/// human-readable reason (`{ "message": "..." }`, per README.mobile.md).
@immutable
class ApiException implements Exception {
  const ApiException(this.message, this.statusCode, {this.errors = const {}});

  /// Builds the exception from a raw error response body. Reads `message`
  /// (the API's own shape), falling back to `title` (ASP.NET's
  /// `ValidationProblemDetails`, e.g. an unknown enum string) and then to a
  /// generic message. [errors] is filled from an `errors` object when there
  /// is one — see README.fertilizer.mobile.md's "Errors".
  factory ApiException.fromResponseBody(int statusCode, String body) {
    var message = 'Something went wrong ($statusCode).';
    var errors = const <String, List<String>>{};
    try {
      final json = jsonDecode(body);
      if (json is Map) {
        if (json['message'] is String) {
          message = json['message'] as String;
        } else if (json['title'] is String) {
          message = json['title'] as String;
        }
        errors = parseErrors(json['errors']);
      }
    } catch (_) {
      // Non-JSON error body — fall back to the generic message above.
    }
    return ApiException(message, statusCode, errors: errors);
  }

  final String message;
  final int statusCode;

  /// Field-level validation errors keyed by request field path, e.g.
  /// `area`, `soil.fertility`, `customPrices[0].pricePerBag` — or ASP.NET's
  /// `$.areaUnit` style for malformed JSON. Empty when the API sent none.
  final Map<String, List<String>> errors;

  bool get isUnauthorized => statusCode == 401;

  /// Parses an `errors` object, keeping only string messages. Anything that
  /// isn't a map of lists (or single strings) is ignored.
  static Map<String, List<String>> parseErrors(Object? raw) {
    if (raw is! Map) return const {};
    final result = <String, List<String>>{};
    for (final entry in raw.entries) {
      final value = entry.value;
      final messages = switch (value) {
        final List<dynamic> list => list.whereType<String>().toList(),
        final String single => [single],
        _ => const <String>[],
      };
      if (messages.isNotEmpty) result['${entry.key}'] = messages;
    }
    return result;
  }

  @override
  String toString() => message;
}
