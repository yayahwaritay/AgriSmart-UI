import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/harvest_providers.dart';
import '../widgets/crop_card.dart';

/// Crop catalog browser — `GET /crops` (see README.mobile.md). Public, so it
/// works for a browsing/not-yet-registered user; tapping a crop opens the
/// harvest predictor pre-filled with it.
class CropsScreen extends ConsumerWidget {
  const CropsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    final crops = ref.watch(cropsProvider);

    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Crops')),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(cropsProvider);
            await ref.read(cropsProvider.future);
          },
          child: crops.when(
            data: (items) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                Text(
                  'Pick a crop to see its growth stages, or jump straight to a harvest prediction.',
                  style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: 16),
                for (final crop in items) ...[
                  CropCard(crop: crop, onTap: () => context.push('/crops/detail', extra: crop)),
                  const SizedBox(height: 12),
                ],
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => LayoutBuilder(
              builder: (context, constraints) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: constraints.maxHeight,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Could not load the crop catalog', style: TextStyle(color: colors.accent)),
                            const SizedBox(height: 16),
                            PrimaryButton(
                              label: 'Retry',
                              expand: false,
                              onPressed: () => ref.invalidate(cropsProvider),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
