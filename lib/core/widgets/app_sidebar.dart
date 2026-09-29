import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_providers.dart';
import '../theme/build_context_x.dart';
import 'app_logo.dart';
import 'liquid_glass.dart';

/// A destination link inside [AppSidebar]. [path] is matched with
/// [GoRouterState.matchedLocation] to highlight the active item; [push]
/// controls whether it's opened on top of the shell (`context.push`) or
/// swaps the active tab (`context.go`).
class SidebarDestination {
  const SidebarDestination({
    required this.icon,
    required this.label,
    required this.path,
    this.push = false,
  });

  final IconData icon;
  final String label;
  final String path;
  final bool push;
}

const _mainDestinations = [
  SidebarDestination(icon: Icons.home_rounded, label: 'Home', path: '/'),
  SidebarDestination(icon: Icons.camera_alt_rounded, label: 'Scan a plant', path: '/scan'),
  SidebarDestination(icon: Icons.storefront_rounded, label: 'Marketplace', path: '/market'),
  SidebarDestination(icon: Icons.smart_display_rounded, label: 'Video tutorials', path: '/tutorials'),
];

const _toolDestinations = [
  SidebarDestination(icon: Icons.query_stats_rounded, label: 'Harvest predictor', path: '/crops', push: true),
  SidebarDestination(icon: Icons.history_rounded, label: 'Harvest history', path: '/harvest/history', push: true),
  SidebarDestination(icon: Icons.science_rounded, label: 'Fertilizer calculator', path: '/fertilizer', push: true),
  SidebarDestination(
    icon: Icons.bookmarks_rounded,
    label: 'Fertilizer history',
    path: '/fertilizer/history',
    push: true,
  ),
];

const _accountDestinations = [
  SidebarDestination(icon: Icons.person_rounded, label: 'Profile', path: '/profile'),
  SidebarDestination(icon: Icons.lock_reset_rounded, label: 'Change password', path: '/change-password', push: true),
];

/// The app's slide-in navigation drawer — a Liquid Glass panel giving quick
/// access to every shell tab plus the screens that don't fit the bottom nav
/// (harvest predictor and history, fertilizer calculator and history,
/// change password).
class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  void _open(BuildContext context, SidebarDestination destination) {
    Navigator.of(context).pop();
    if (destination.push) {
      context.push(destination.path);
    } else {
      context.go(destination.path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    final user = ref.watch(authControllerProvider).user;
    final location = GoRouterState.of(context).matchedLocation;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: 300,
      child: Container(
        color: colors.background,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(name: user?.name, email: user?.email),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _SidebarSection(
                        destinations: _mainDestinations,
                        activeLocation: location,
                        onTap: (d) => _open(context, d),
                      ),
                      const SizedBox(height: 20),
                      const _SectionLabel('Tools'),
                      const SizedBox(height: 4),
                      _SidebarSection(
                        destinations: _toolDestinations,
                        activeLocation: location,
                        onTap: (d) => _open(context, d),
                      ),
                      const SizedBox(height: 20),
                      const _SectionLabel('Account'),
                      const SizedBox(height: 4),
                      _SidebarSection(
                        destinations: _accountDestinations,
                        activeLocation: location,
                        onTap: (d) => _open(context, d),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                const SizedBox(height: 8),
                _SidebarTile(
                  icon: Icons.logout_rounded,
                  label: 'Log out',
                  color: colors.accent,
                  onTap: () {
                    Navigator.of(context).pop();
                    ref.read(authControllerProvider.notifier).logout();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.email});

  final String? name;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return LiquidGlass(
      borderRadius: 22,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const AppLogo(size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AgriSmart', style: context.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  name ?? email ?? 'Your farm, at a glance',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Text(
        label.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SidebarSection extends StatelessWidget {
  const _SidebarSection({
    required this.destinations,
    required this.activeLocation,
    required this.onTap,
  });

  final List<SidebarDestination> destinations;
  final String activeLocation;
  final ValueChanged<SidebarDestination> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return Column(
      children: [
        for (final destination in destinations)
          _SidebarTile(
            icon: destination.icon,
            label: destination.label,
            selected: destination.path == activeLocation,
            color: colors.primary,
            onTap: () => onTap(destination),
          ),
      ],
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: selected ? color.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 22, color: selected ? color : colors.textSecondary),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: selected ? color : colors.textPrimary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
