import 'package:agrismart/app.dart';
import 'package:agrismart/core/network/token_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Avoids touching the real `flutter_secure_storage` platform channel —
/// under `testWidgets`'s fake-async clock, that channel's Future never
/// resolves, which would leave [AuthController] stuck on `AuthStatus.unknown`
/// forever and the splash spinner never clears.
class _FakeTokenStorage implements TokenStorage {
  @override
  Future<String?> readToken() async => null;

  @override
  Future<String?> readUserJson() async => null;

  @override
  Future<void> save({required String token, required String userJson}) async {}

  @override
  Future<void> clear() async {}

  @override
  Future<String?> readBiometricEmail() async => null;

  @override
  Future<void> saveBiometricEmail(String email) async {}

  @override
  Future<void> clearBiometricEmail() async {}
}

void main() {
  testWidgets('App boots to the login screen when logged out', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenStorageProvider.overrideWithValue(_FakeTokenStorage())],
        child: const AgriSmartApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AgriSmart 🌱'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text("Don't have an account? Sign up"), findsOneWidget);
  });
}
