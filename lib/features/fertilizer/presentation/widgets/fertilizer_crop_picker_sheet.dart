import 'package:flutter/material.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/agri_badge.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/fertilizer_crop.dart';

/// The calculator's crop picker — same sheet as the harvest predictor's,
/// with the Krio name as a subtitle and a badge for tree crops.
Future<FertilizerCrop?> showFertilizerCropPickerSheet(BuildContext context, List<FertilizerCrop> crops) {
  return showModalBottomSheet<FertilizerCrop>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: SafeArea(child: _CropPickerSheet(crops: crops)),
    ),
  );
}

class _CropPickerSheet extends StatelessWidget {
  const _CropPickerSheet({required this.crops});

  final List<FertilizerCrop> crops;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pick a crop', style: context.textTheme.titleLarge),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: crops.length,
              separatorBuilder: (_, _) => Divider(color: colors.divider, height: 1),
              itemBuilder: (context, index) {
                final crop = crops[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  minTileHeight: 56,
                  leading: Icon(crop.isPerennial ? Icons.park_rounded : Icons.grass_rounded, color: colors.primary),
                  title: Text(crop.name, style: context.textTheme.titleMedium),
                  subtitle: crop.localName.isEmpty && !crop.isPerennial
                      ? null
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (crop.localName.isNotEmpty)
                              Text(
                                crop.localName,
                                style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                              ),
                            if (crop.isPerennial) ...[
                              const SizedBox(height: 4),
                              const PerennialBadge(),
                            ],
                          ],
                        ),
                  onTap: () => Navigator.of(context).pop(crop),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// "Rates per year, mature trees" — for `isPerennial` crops.
class PerennialBadge extends StatelessWidget {
  const PerennialBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const AgriBadge(
      label: 'Rates per year, mature trees',
      icon: Icons.park_rounded,
      variant: AgriBadgeVariant.neutral,
    );
  }
}
