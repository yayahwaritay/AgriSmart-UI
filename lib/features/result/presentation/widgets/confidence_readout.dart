import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/neu_card.dart';

/// Monospaced confidence score readout, e.g. "91.0%".
class ConfidenceReadout extends StatelessWidget {
  const ConfidenceReadout({super.key, required this.confidence});

  final double confidence;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final percent = (confidence * 100).toStringAsFixed(1);

    return NeuCard(
      inset: true,
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insights_rounded, size: 18, color: colors.primary),
          const SizedBox(width: 8),
          Text('CONFIDENCE', style: context.textTheme.labelSmall?.copyWith(color: colors.textSecondary)),
          const SizedBox(width: 10),
          Text('$percent%', style: AppTheme.dataReadout(colors, fontSize: 16)),
        ],
      ),
    );
  }
}
