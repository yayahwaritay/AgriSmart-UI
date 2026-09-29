import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/build_context_x.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/widgets/agri_badge.dart';
import '../../../../core/widgets/neu_card.dart';
import '../../domain/entities/harvest_prediction.dart';
import 'confidence_badge.dart';
import 'gdd_progress_bar.dart';

/// The predictor's headline answer — used both right after a `POST
/// /harvest/predict` call and when reopening a saved history entry.
class HarvestResultCard extends StatelessWidget {
  const HarvestResultCard({super.key, required this.prediction});

  final HarvestPrediction prediction;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final harvest = prediction.harvest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(prediction.cropName, style: context.textTheme.headlineSmall),
            ),
            if (prediction.alreadyMature) const AgriBadge(label: 'Ready now', icon: Icons.check_circle_rounded),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Planted ${prediction.plantingDate.toShortDateLabel()} · as of ${prediction.asOf.toShortDateLabel()}',
          style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 20),
        NeuCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Expected harvest', style: context.textTheme.titleSmall?.copyWith(color: colors.textSecondary)),
              const SizedBox(height: 6),
              Text(harvest.expected.toShortDateLabel(), style: AppTheme.dataReadout(colors, fontSize: 26)),
              const SizedBox(height: 4),
              Text(
                harvest.windowWidthDays == 0
                    ? '${harvest.daysFromNow} days from now'
                    : '${harvest.earliest.toShortDateLabel()} – ${harvest.latest.toShortDateLabel()} '
                        '(${harvest.daysFromNow} days from now)',
                style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: 12),
              ConfidenceBadge(confidence: harvest.confidence),
              const SizedBox(height: 12),
              _ExpandableBasis(basis: harvest.basis),
            ],
          ),
        ),
        const SizedBox(height: 16),
        NeuCard(child: GddProgressBar(gdd: prediction.gdd)),
        const SizedBox(height: 16),
        NeuCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Growth stage', style: context.textTheme.titleSmall),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.eco_rounded, color: colors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(prediction.stage.current, style: context.textTheme.bodyMedium),
                ],
              ),
              if (prediction.stage.next != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Next: ${prediction.stage.next} on '
                  '${prediction.stage.nextStageStarts?.toShortDateLabel() ?? '—'}',
                  style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
              ],
            ],
          ),
        ),
        if (prediction.methodology.notes.isNotEmpty) ...[
          const SizedBox(height: 16),
          NeuCard(
            inset: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: colors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    prediction.methodology.notes,
                    style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ExpandableBasis extends StatefulWidget {
  const _ExpandableBasis({required this.basis});

  final String basis;

  @override
  State<_ExpandableBasis> createState() => _ExpandableBasisState();
}

class _ExpandableBasisState extends State<_ExpandableBasis> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.help_outline_rounded, size: 16, color: colors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _expanded ? widget.basis : 'Why this date? Tap to see the methodology.',
              style: context.textTheme.labelMedium?.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
