import '../../../../core/network/api_client.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/biometric_repository.dart';

class HttpBiometricRepository implements BiometricRepository {
  HttpBiometricRepository(this._client);

  final ApiClient _client;

  @override
  Future<void> registerKey({required String deviceId, required String publicKey}) async {
    await _client.post('/auth/biometric/register', body: {'deviceId': deviceId, 'publicKey': publicKey});
  }

  @override
  Future<String> requestChallenge({required String email, required String deviceId}) async {
    final json = await _client.post('/auth/biometric/challenge', body: {'email': email, 'deviceId': deviceId});
    return (json as Map<String, dynamic>)['challenge'] as String;
  }

  @override
  Future<AuthResult> login({required String email, required String deviceId, required String signature}) async {
    final json = await _client.post(
      '/auth/biometric/login',
      body: {'email': email, 'deviceId': deviceId, 'signature': signature},
    );
    final map = json as Map<String, dynamic>;
    return AuthResult(
      token: map['token'] as String,
      user: AppUser.fromJson(map['user'] as Map<String, dynamic>),
    );
  }

  @override
  Future<void> unregisterKey(String deviceId) async {
    await _client.delete('/auth/biometric/$deviceId');
  }
}
