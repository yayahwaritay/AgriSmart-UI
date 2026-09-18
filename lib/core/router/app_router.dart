import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/market/presentation/screens/market_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/result/presentation/screens/result_screen.dart';
import '../../features/scan/domain/entities/diagnosis_result.dart';
import '../../features/scan/presentation/screens/scan_screen.dart';
import '../../features/tutorials/domain/entities/tutorial_video.dart';
import '../../features/tutorials/presentation/screens/tutorials_screen.dart';
import '../../features/tutorials/presentation/screens/video_detail_screen.dart';
import 'app_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Bridges Riverpod's [authControllerProvider] to go_router's
/// `refreshListenable`, so a login/logout (including a 401-triggered
/// `forceLogout`) re-runs [GoRouter.redirect] even when nothing navigated.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.status != next.status) notifyListeners();
    });
  }
}

const _publicLocations = {'/login', '/register'};

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      if (authState.status == AuthStatus.unknown) {
        return location == '/splash' ? null : '/splash';
      }

      final loggedIn = authState.status == AuthStatus.authenticated;
      final onPublicScreen = _publicLocations.contains(location);

      if (!loggedIn && !onPublicScreen) return '/login';
      if (loggedIn && (onPublicScreen || location == '/splash')) return '/';

      // Admin-issued temporary password (README.mobile.md "Reset / forgot
      // password") — block the rest of the app until it's replaced.
      final mustChangePassword = authState.user?.mustChangePassword ?? false;
      if (loggedIn && mustChangePassword && location != '/change-password') return '/change-password';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: '/change-password',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (context, state) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/scan', builder: (context, state) => const ScanScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/market', builder: (context, state) => const MarketScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/tutorials', builder: (context, state) => const TutorialsScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())],
          ),
        ],
      ),
      GoRoute(
        path: '/result',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => ResultScreen(diagnosis: state.extra as DiagnosisResult?),
      ),
      GoRoute(
        path: '/tutorial',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => VideoDetailScreen(initialVideo: state.extra as TutorialVideo),
      ),
    ],
  );
});
