import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_bottom_nav.dart';

/// Hosts the five bottom-nav branches (Home, Scan, Market, Learn, Profile)
/// behind a shared floating nav bar, via [StatefulShellRoute.indexedStack].
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    AppBottomNavItem(icon: Icons.home_rounded, label: 'Home'),
    AppBottomNavItem(icon: Icons.camera_alt_rounded, label: 'Scan'),
    AppBottomNavItem(icon: Icons.storefront_rounded, label: 'Market'),
    AppBottomNavItem(icon: Icons.smart_display_rounded, label: 'Learn'),
    AppBottomNavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        items: _items,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
