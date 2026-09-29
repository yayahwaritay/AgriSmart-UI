import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/fertilizer_providers.dart';
import '../../domain/entities/fertilizer_recommendation.dart';
import '../widgets/fertilizer_result_view.dart';

/// `/fertilizer/detail` — one saved plan (`GET
/// /fertilizer/recommendations/{id}`), shown exactly as calculated then,
/// with "Recalculate" (prefills the calculator) and "Delete".
class FertilizerDetailScreen extends ConsumerWidget {
  const FertilizerDetailScreen({super.key, required this.recommendationId});

  final String recommendationId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this plan?'),
        content: const Text('It will be removed from your saved plans. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(fertilizerHistoryProvider.notifier).delete(recommendationId);
      messenger.showSnackBar(const SnackBar(content: Text('Plan deleted.')));
      if (context.mounted) context.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not delete: $e')));
    }
  }

  Future<void> _recalculate(BuildContext context, WidgetRef ref, FertilizerRecommendation saved) async {
    try {
      await ref.read(fertilizerCalculatorControllerProvider.notifier).prefillFrom(saved.inputs);
      if (context.mounted) await context.push('/fertilizer');
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the calculator. Check your connection.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    final recommendation = ref.watch(fertilizerRecommendationProvider(recommendationId));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Saved plan'),
        actions: [
          if (recommendation.hasValue)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _delete(context, ref),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: recommendation.when(
          data: (saved) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              if (saved.plotLabel.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.place_rounded, size: 18, color: colors.primary),
                    const SizedBox(width: 6),
                    Expanded(child: Text(saved.plotLabel, style: context.textTheme.titleMedium)),
                  ],
                ),
              Text(
                'Saved ${saved.createdAt.toShortDateLabel()}',
                style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: 16),
              FertilizerResultView(result: saved.result),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Recalculate',
                icon: Icons.refresh_rounded,
                onPressed: () => _recalculate(context, ref, saved),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () => _delete(context, ref),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete'),
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Could not load this plan', style: TextStyle(color: colors.accent)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.invalidate(fertilizerRecommendationProvider(recommendationId)),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
