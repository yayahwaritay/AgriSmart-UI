import 'package:flutter/material.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/neu_card.dart';
import '../../domain/entities/crop.dart';

class CropCard extends StatelessWidget {
  const CropCard({super.key, required this.crop, required this.onTap});

  final CropSummary crop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return NeuCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.primary.withValues(alpha: 0.28), colors.primary.withValues(alpha: 0.10)],
              ),
            ),
            child: Icon(Icons.grass_rounded, color: colors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(crop.name, style: context.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  '~${crop.typicalDaysToMaturity} days to maturity',
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
