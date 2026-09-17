import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../features/auth/application/auth_providers.dart';
import '../config/api_config.dart';
import 'api_exception.dart';

/// Single point of contact with the AgriSmart API — attaches the bearer
/// token, decodes JSON, and turns non-2xx responses into [ApiException].
/// On a 401 it also forces the app back to the logged-out state, since
/// tokens expire in 10 minutes and there is no refresh endpoint.
class ApiClient {
  ApiClient(this._ref) : _client = http.Client();

  final Ref _ref;
  final http.Client _client;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v?.toString())),
    );
  }

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = _ref.read(authControllerProvider).token;
    return {
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    var message = 'Something went wrong (${response.statusCode}).';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] is String) {
        message = body['message'] as String;
      }
    } catch (_) {
      // Non-JSON error body — fall back to the generic message above.
    }

    if (response.statusCode == 401) {
      _ref.read(authControllerProvider.notifier).forceLogout();
    }
    throw ApiException(message, response.statusCode);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final response = await _client.get(_uri(path, query), headers: await _headers());
    return _decode(response);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final response = await _client.post(
      _uri(path),
      headers: await _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final response = await _client.put(
      _uri(path),
      headers: await _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await _client.delete(_uri(path), headers: await _headers());
    return _decode(response);
  }

  /// Multipart upload — used by `POST /scans` (and `POST /diagnoses`).
  Future<dynamic> postMultipart(
    String path, {
    required String field,
    required File file,
    Map<String, String>? fields,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path))
      ..headers.addAll(await _headers(json: false))
      ..files.add(await http.MultipartFile.fromPath(field, file.path));
    if (fields != null) request.fields.addAll(fields);
    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    return _decode(response);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));
