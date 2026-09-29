import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/widgets/neu_card.dart';
import '../../application/fertilizer_providers.dart';
import '../../domain/entities/fertilizer_recommendation.dart';
import '../fertilizer_format.dart';

/// `GET /fertilizer/recommendations` — the farmer's saved plans, newest
/// first, loading the next page as they scroll. Filter by crop or by exact
/// plot name.
class FertilizerHistoryScreen extends ConsumerStatefulWidget {
  const FertilizerHistoryScreen({super.key});

  @override
  ConsumerState<FertilizerHistoryScreen> createState() => _FertilizerHistoryScreenState();
}

class _FertilizerHistoryScreenState extends ConsumerState<FertilizerHistoryScreen> {
  late final TextEditingController _plotController;

  @override
  void initState() {
    super.initState();
    _plotController = TextEditingController(text: ref.read(fertilizerHistoryFilterProvider).plotLabel ?? '');
  }

  @override
  void dispose() {
    _plotController.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.extentAfter < 300) {
      ref.read(fertilizerHistoryProvider.notifier).loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final history = ref.watch(fertilizerHistoryProvider);
    final filter = ref.watch(fertilizerHistoryFilterProvider);

    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Fertilizer history')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: _Filters(
                plotController: _plotController,
                filter: filter,
                onClear: () {
                  _plotController.clear();
                  ref.read(fertilizerHistoryFilterProvider.notifier).clear();
                },
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(fertilizerHistoryProvider);
                  await ref.read(fertilizerHistoryProvider.future);
                },
                child: history.when(
                  data: (data) => data.items.isEmpty
                      ? _Message(
                          filter.isActive
                              ? 'No saved plans match these filters.'
                              : 'No saved plans yet. Work one out in the calculator and tap Save.',
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: _onScroll,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                            itemCount: data.items.length + 1,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              if (index == data.items.length) return _Footer(state: data);
                              return _HistoryTile(item: data.items[index]);
                            },
                          ),
                        ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _Message(
                    'Could not load your saved plans.',
                    color: colors.accent,
                    onRetry: () => ref.invalidate(fertilizerHistoryProvider),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.plotController, required this.filter, required this.onClear});

  final TextEditingController plotController;
  final FertilizerHistoryFilter filter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crops = ref.watch(fertilizerCropsProvider).value ?? const [];
    final notifier = ref.read(fertilizerHistoryFilterProvider.notifier);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String?>(
                initialValue: crops.any((c) => c.id == filter.cropId) ? filter.cropId : null,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Crop', isDense: true),
                items: [
                  const DropdownMenuItem<String?>(child: Text('All crops')),
                  for (final crop in crops) DropdownMenuItem<String?>(value: crop.id, child: Text(crop.name)),
                ],
                onChanged: notifier.setCrop,
              ),
            ),
            if (filter.isActive)
              IconButton(
                tooltip: 'Clear filters',
                icon: const Icon(Icons.filter_alt_off_rounded),
                onPressed: onClear,
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: plotController,
          textInputAction: TextInputAction.search,
          onSubmitted: notifier.setPlotLabel,
          decoration: InputDecoration(
            labelText: 'Plot name',
            hintText: 'Type the exact plot name',
            isDense: true,
            suffixIcon: IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search_rounded),
              onPressed: () => notifier.setPlotLabel(plotController.text),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final RecommendationSummary item;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final cost = item.totalEstimatedCost > 0 ? ' · ${formatMoney(item.totalEstimatedCost)} ${item.currency}' : '';

    return NeuCard(
      padding: const EdgeInsets.all(16),
      onTap: () => context.push('/fertilizer/detail', extra: item.id),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.cropName, style: context.textTheme.titleMedium),
                if (item.plotLabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.place_rounded, size: 16, color: colors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(child: Text(item.plotLabel, style: context.textTheme.bodyMedium)),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${formatNumber(item.areaHectares, decimals: 2)} ha$cost',
                  style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
                Text(
                  item.createdAt.toShortDateLabel(),
                  style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
        ],
      ),
    );
  }
}

class _Footer extends ConsumerWidget {
  const _Footer({required this.state});

  final FertilizerHistoryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.loadMoreFailed) {
      return Center(
        child: TextButton.icon(
          onPressed: () => ref.read(fertilizerHistoryProvider.notifier).loadMore(),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Could not load more. Try again'),
        ),
      );
    }
    if (state.hasMore) return const SizedBox(height: 48);
    return const SizedBox.shrink();
  }
}

/// Centered text that still allows pull-to-refresh.
class _Message extends StatelessWidget {
  const _Message(this.text, {this.color, this.onRetry});

  final String text;
  final Color? color;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodySmall?.copyWith(color: color ?? colors.textSecondary),
                    ),
                    if (onRetry != null) ...[
                      const SizedBox(height: 8),
                      TextButton(onPressed: onRetry, child: const Text('Try again')),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
