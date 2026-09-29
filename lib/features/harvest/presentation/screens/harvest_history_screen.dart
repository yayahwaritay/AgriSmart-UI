import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/widgets/neu_card.dart';
import '../../application/harvest_providers.dart';
import '../widgets/confidence_badge.dart';

/// `GET /harvest/history` — see README.mobile.md. Only predictions made
/// while logged in show up here.
class HarvestHistoryScreen extends ConsumerWidget {
  const HarvestHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    final history = ref.watch(harvestHistoryProvider);

    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Harvest history')),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(harvestHistoryProvider);
            await ref.read(harvestHistoryProvider.future);
          },
          child: history.when(
            data: (items) => items.isEmpty
                ? LayoutBuilder(
                    builder: (context, constraints) => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: constraints.maxHeight,
                          child: Center(
                            child: Text(
                              'No saved predictions yet — run one from the predictor.',
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final prediction = items[index];
                      return NeuCard(
                        padding: const EdgeInsets.all(16),
                        onTap: () => context.push('/harvest/detail', extra: prediction),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(prediction.cropName, style: context.textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Expected ${prediction.harvest.expected.toShortDateLabel()} · '
                                    'planted ${prediction.plantingDate.toShortDateLabel()}',
                                    style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                                  ),
                                  const SizedBox(height: 8),
                                  ConfidenceBadge(confidence: prediction.harvest.confidence),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
                          ],
                        ),
                      );
                    },
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('Could not load your harvest history', style: TextStyle(color: colors.accent)),
            ),
          ),
        ),
      ),
    );
  }
}
