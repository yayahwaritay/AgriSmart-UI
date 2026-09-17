import '../../../../core/network/api_client.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository(this._client);

  final ApiClient _client;

  AuthResult _parse(dynamic json) {
    final map = json as Map<String, dynamic>;
    return AuthResult(
      token: map['token'] as String,
      user: AppUser.fromJson(map['user'] as Map<String, dynamic>),
    );
  }

  @override
  Future<AuthResult> register({required String name, required String email, required String password}) async {
    final json = await _client.post(
      '/auth/register',
      body: {'name': name, 'email': email, 'password': password, 'role': 'buyer'},
    );
    return _parse(json);
  }

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    final json = await _client.post('/auth/login', body: {'email': email, 'password': password});
    return _parse(json);
  }
}
