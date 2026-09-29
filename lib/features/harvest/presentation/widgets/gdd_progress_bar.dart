import 'package:flutter/material.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../domain/entities/harvest_prediction.dart';

/// Thermal-time progress bar — [GddProgress.percentComplete] is the one
/// number most UIs need out of the raw growing-degree-day accounting.
class GddProgressBar extends StatelessWidget {
  const GddProgressBar({super.key, required this.gdd});

  final GddProgress gdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final fraction = (gdd.percentComplete / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Growth progress', style: context.textTheme.titleSmall),
            Text(
              '${gdd.percentComplete.toStringAsFixed(0)}%',
              style: context.textTheme.titleSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 10,
            backgroundColor: colors.divider,
            valueColor: AlwaysStoppedAnimation(colors.primary),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${gdd.accumulated.toStringAsFixed(0)} / ${gdd.required_.toStringAsFixed(0)} GDD accumulated',
          style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
