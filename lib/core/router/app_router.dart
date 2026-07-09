import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
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
