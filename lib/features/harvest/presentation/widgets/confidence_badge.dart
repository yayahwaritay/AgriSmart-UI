import 'package:flutter/material.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../domain/entities/harvest_prediction.dart';

/// "High" green / "Medium" amber / "Low" red-gray — see README.mobile.md:
/// `confidence` is just the harvest window's width bucketed, safe to render
/// as a color directly.
class ConfidenceBadge extends StatelessWidget {
  const ConfidenceBadge({super.key, required this.confidence});

  final HarvestConfidence confidence;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final (label, color) = switch (confidence) {
      HarvestConfidence.high => ('High confidence', colors.success),
      HarvestConfidence.medium => ('Medium confidence', colors.warning),
      HarvestConfidence.low => ('Low confidence', colors.accent),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
