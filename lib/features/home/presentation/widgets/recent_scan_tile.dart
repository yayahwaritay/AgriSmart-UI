import 'package:flutter/material.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/agri_badge.dart';
import '../../../../core/widgets/neu_card.dart';
import '../../../scan/domain/entities/plant_scan.dart';

class RecentScanTile extends StatelessWidget {
  const RecentScanTile({super.key, required this.scan, required this.onTap});

  final PlantScan scan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final diagnosis = scan.diagnosis;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeuCard(
        padding: const EdgeInsets.all(14),
        borderRadius: 20,
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.eco_rounded, color: colors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diagnosis.diseaseName ?? '${diagnosis.plantName} · Healthy',
                    style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    diagnosis.plantName,
                    style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            AgriBadge(
              label: diagnosis.isHealthy ? 'Healthy' : diagnosis.severity.name,
              variant: diagnosis.isHealthy ? AgriBadgeVariant.primary : AgriBadgeVariant.alert,
            ),
          ],
        ),
      ),
    );
  }
}
