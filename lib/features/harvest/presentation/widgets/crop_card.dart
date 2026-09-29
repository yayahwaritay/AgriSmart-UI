import 'package:flutter/material.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/crop_image.dart';
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
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          Hero(tag: 'crop-image-${crop.id}', child: CropImage(cropId: crop.id, size: 64)),
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
