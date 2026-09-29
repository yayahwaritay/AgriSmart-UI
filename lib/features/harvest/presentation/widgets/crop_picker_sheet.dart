import 'package:flutter/material.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/crop.dart';

Future<CropSummary?> showCropPickerSheet(BuildContext context, List<CropSummary> crops) {
  return showModalBottomSheet<CropSummary>(
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

  final List<CropSummary> crops;

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
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: crops.length,
              separatorBuilder: (_, _) => Divider(color: colors.divider, height: 1),
              itemBuilder: (context, index) {
                final crop = crops[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.grass_rounded, color: colors.primary),
                  title: Text(crop.name, style: context.textTheme.bodyMedium),
                  subtitle: Text(
                    '~${crop.typicalDaysToMaturity} days to maturity',
                    style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
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
