import 'package:flutter/material.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/glass_card.dart';

class AboutCard extends StatelessWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return GlassCard(
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.eco_rounded, color: colors.primary),
              const SizedBox(width: 10),
              Text('AgriSmart', style: context.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'AgriSmart is free, open-source software for detecting plant pests '
            'and diseases from a photo. Contributions are welcome under the '
            'MIT license.',
            style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 12),
          Text('v1.0.0 · MIT License', style: context.textTheme.labelSmall?.copyWith(color: colors.textSecondary)),
        ],
      ),
    );
  }
}
