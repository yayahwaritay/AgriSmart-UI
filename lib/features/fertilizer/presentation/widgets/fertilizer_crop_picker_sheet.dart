import 'package:flutter/material.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/agri_badge.dart';
import '../../../../core/widgets/crop_image.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/fertilizer_crop.dart';

/// The calculator's crop picker — same photo grid as the harvest predictor's,
/// with the Krio name as a subtitle and a chip for tree crops.
Future<FertilizerCrop?> showFertilizerCropPickerSheet(
  BuildContext context,
  List<FertilizerCrop> crops, {
  FertilizerCrop? selected,
}) {
  return showModalBottomSheet<FertilizerCrop>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: SafeArea(child: _CropPickerSheet(crops: crops, selectedId: selected?.id)),
    ),
  );
}

/// Glyph for a fertilizer crop with no photo — a tree for perennials.
IconData fertilizerCropIcon(FertilizerCrop? crop) =>
    crop?.isPerennial ?? false ? Icons.park_rounded : Icons.grass_rounded;

class _CropPickerSheet extends StatelessWidget {
  const _CropPickerSheet({required this.crops, this.selectedId});

  final List<FertilizerCrop> crops;
  final String? selectedId;

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
              'Rates are worked out from this crop\'s nutrient needs.',
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
                // A touch taller than the harvest tile to fit the Krio name.
                childAspectRatio: 0.86,
              ),
              itemBuilder: (context, index) {
                final crop = crops[index];
                return _CropTile(
                  crop: crop,
                  selected: crop.id == selectedId,
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

  final FertilizerCrop crop;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    const radius = 18.0;

    final semanticLabel = [
      crop.name,
      if (crop.localName.isNotEmpty) crop.localName,
      if (crop.isPerennial) 'tree crop',
    ].join(', ');

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
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
                          fallbackIcon: fertilizerCropIcon(crop),
                        ),
                      ),
                      if (crop.isPerennial)
                        const Positioned(
                          left: 6,
                          bottom: 6,
                          child: AgriBadge(
                            label: 'Tree crop',
                            icon: Icons.park_rounded,
                            variant: AgriBadgeVariant.neutral,
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
                      Text(
                        crop.localName.isNotEmpty ? crop.localName : ' ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
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
