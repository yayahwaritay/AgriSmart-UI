import 'package:flutter/material.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/crop_image.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/crop.dart';

Future<CropSummary?> showCropPickerSheet(BuildContext context, List<CropSummary> crops, {CropSummary? selected}) {
  return showModalBottomSheet<CropSummary>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: SafeArea(child: _CropPickerSheet(crops: crops, selected: selected)),
    ),
  );
}

class _CropPickerSheet extends StatelessWidget {
  const _CropPickerSheet({required this.crops, this.selected});

  final List<CropSummary> crops;
  final CropSummary? selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('Pick a crop', style: context.textTheme.titleLarge),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Harvest timing is predicted from local temperatures for this crop.',
              style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.62),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: crops.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.92,
              ),
              itemBuilder: (context, index) {
                final crop = crops[index];
                return _CropTile(
                  crop: crop,
                  selected: crop == selected,
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

class _CropTile extends StatelessWidget {
  const _CropTile({required this.crop, required this.selected, required this.onTap});

  final CropSummary crop;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    const radius = 18.0;

    return Semantics(
      button: true,
      selected: selected,
      label: '${crop.name}, about ${crop.typicalDaysToMaturity} days to maturity',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: selected ? colors.primary.withValues(alpha: 0.12) : colors.glassTint,
              border: Border.all(
                color: selected ? colors.primary : colors.glassBorder,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) => CropImage(
                          cropId: crop.id,
                          size: constraints.maxWidth,
                          borderRadius: radius - 6,
                        ),
                      ),
                      if (selected)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(3),
                            child: Icon(Icons.check_rounded, size: 16, color: colors.onPrimary),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 6, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 12, color: colors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '~${crop.typicalDaysToMaturity} days',
                            style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
