import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/neu_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/crop.dart';

class CropDetailScreen extends StatelessWidget {
  const CropDetailScreen({super.key, required this.crop});

  final CropSummary crop;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: Text(crop.name)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Row(
              children: [
                Expanded(
                  child: NeuCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('~${crop.typicalDaysToMaturity}', style: context.textTheme.headlineSmall),
                        Text(
                          'days to maturity',
                          style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeuCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(crop.gddToMaturity.toStringAsFixed(0), style: context.textTheme.headlineSmall),
                        Text(
                          'GDD to maturity',
                          style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            NeuCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TempReadout(label: 'Base temp', value: crop.baseTemperatureC),
                  _TempReadout(label: 'Upper temp', value: crop.upperTemperatureC),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Growth stages', style: context.textTheme.titleMedium),
            const SizedBox(height: 12),
            NeuCard(
              child: Column(
                children: [
                  for (var i = 0; i < crop.stages.length; i++) ...[
                    _StageRow(
                      name: crop.stages[i].name,
                      startFraction: crop.stages[i].startFraction,
                    ),
                    if (i != crop.stages.length - 1) Divider(color: colors.divider, height: 20),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Predict harvest for this crop',
              icon: Icons.calendar_month_rounded,
              onPressed: () => context.push('/harvest', extra: crop),
            ),
          ],
        ),
      ),
    );
  }
}

class _TempReadout extends StatelessWidget {
  const _TempReadout({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary)),
        const SizedBox(height: 4),
        Text('${value.toStringAsFixed(0)}°C', style: context.textTheme.titleMedium),
      ],
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({required this.name, required this.startFraction});

  final String name;
  final double startFraction;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: colors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(name, style: context.textTheme.bodyMedium)),
        Text(
          '${(startFraction * 100).toStringAsFixed(0)}%',
          style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
