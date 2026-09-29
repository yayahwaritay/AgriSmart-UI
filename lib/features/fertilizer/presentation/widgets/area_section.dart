import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/neu_card.dart';
import '../../application/fertilizer_providers.dart';
import '../../domain/entities/fertilizer_enums.dart';
import '../fertilizer_format.dart';
import 'fertilizer_form_parts.dart';

/// "How big is your farm?" — unit chips plus either one size field or plot
/// length × width.
class AreaSection extends ConsumerWidget {
  const AreaSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    final state = ref.watch(fertilizerCalculatorControllerProvider);
    final controller = ref.read(fertilizerCalculatorControllerProvider.notifier);
    final unit = state.areaUnit;
    final version = state.formVersion;

    // The result echoes the size in hectares — only show it while the
    // inputs still match what was calculated.
    final last = state.lastRequest;
    final result = state.result;
    final showHectares = result != null &&
        last != null &&
        last.areaUnit == unit &&
        (unit == AreaUnit.plotDimensions
            ? last.lengthM == state.lengthM && last.widthM == state.widthM
            : last.area == state.area);

    return NeuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormSectionHeader(icon: Icons.straighten_rounded, title: 'How big is your farm?'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final option in AreaUnit.values)
                SelectChip(
                  label: option.label,
                  selected: option == unit,
                  onTap: () => controller.setAreaUnit(option),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (unit == AreaUnit.plotDimensions)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: NumberField(
                    key: ValueKey('length-$version'),
                    label: 'Length',
                    unit: 'm',
                    initialValue: state.lengthM,
                    errorText: state.fieldErrors[FertilizerField.lengthM],
                    onChanged: controller.setLength,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                  child: Text('×', style: context.textTheme.titleMedium),
                ),
                Expanded(
                  child: NumberField(
                    key: ValueKey('width-$version'),
                    label: 'Width',
                    unit: 'm',
                    initialValue: state.widthM,
                    errorText: state.fieldErrors[FertilizerField.widthM],
                    onChanged: controller.setWidth,
                  ),
                ),
              ],
            )
          else
            NumberField(
              key: ValueKey('area-$version-${unit.name}'),
              label: 'Farm size',
              unit: unit.shortLabel,
              initialValue: state.area,
              errorText: state.fieldErrors[FertilizerField.area],
              onChanged: controller.setArea,
            ),
          if (showHectares && unit != AreaUnit.hectare) ...[
            const SizedBox(height: 8),
            Text(
              '= ${formatNumber(result.areaHectares, decimals: 2)} ha',
              style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
