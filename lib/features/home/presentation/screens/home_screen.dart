import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/neu_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../history/application/history_providers.dart';
import '../../../market/presentation/widgets/featured_produce_carousel.dart';
import '../../application/home_providers.dart';
import '../widgets/recent_scan_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    final stats = ref.watch(homeStatsProvider);
    final history = ref.watch(scanHistoryProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            Text('Good to see you 🌱', style: context.textTheme.bodyMedium?.copyWith(color: colors.textSecondary)),
            const SizedBox(height: 4),
            Text('Your fields, at a glance', style: context.textTheme.headlineSmall),
            const SizedBox(height: 20),
            stats.when(
              data: (s) => Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.grid_view_rounded,
                      value: '${s.totalScans}',
                      label: 'Total scans',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.check_circle_rounded,
                      value: '${s.healthy}',
                      label: 'Healthy',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.warning_rounded,
                      value: '${s.needsAttention}',
                      label: 'Needs care',
                      accentColor: colors.accent,
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox(height: 96, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('Could not load stats', style: TextStyle(color: colors.accent)),
            ),
            const SizedBox(height: 24),
            NeuCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Spot a problem early', style: context.textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          'Scan a leaf to check for pests and disease.',
                          style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  PrimaryButton(
                    label: 'Scan',
                    icon: Icons.camera_alt_rounded,
                    expand: false,
                    onPressed: () => context.push('/scan'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(child: Text('Fresh from the market', style: context.textTheme.titleMedium)),
                TextButton(
                  onPressed: () => context.go('/market'),
                  child: Text(
                    'See all',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const FeaturedProduceCarousel(),
            const SizedBox(height: 20),
            NeuCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stock up for planting season', style: context.textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          'Seeds, fertilizer and fresh harvests from farmers near you.',
                          style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  PrimaryButton(
                    label: 'Shop',
                    icon: Icons.storefront_rounded,
                    expand: false,
                    onPressed: () => context.go('/market'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Recent scans', style: context.textTheme.titleMedium),
            const SizedBox(height: 12),
            history.when(
              data: (scans) {
                if (scans.isEmpty) {
                  return Text('No scans yet — try scanning a plant.',
                      style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary));
                }
                return Column(
                  children: [
                    for (final scan in scans.take(5))
                      RecentScanTile(
                        scan: scan,
                        onTap: () => context.push('/result', extra: scan.diagnosis),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Could not load history', style: TextStyle(color: colors.accent)),
            ),
          ],
        ),
      ),
    );
  }
}
