import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/neu_card.dart';
import '../../application/fertilizer_providers.dart';
import '../fertilizer_format.dart';
import 'fertilizer_form_parts.dart';

/// Optional target yield — a slider from the crop's reference yield up to
/// its realistic maximum. Left untouched, nothing is sent and the API uses
/// the reference yield.
class TargetYieldSection extends ConsumerWidget {
  const TargetYieldSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    final state = ref.watch(fertilizerCalculatorControllerProvider);
    final controller = ref.read(fertilizerCalculatorControllerProvider.notifier);
    final crop = state.crop;
    if (crop == null) return const SizedBox.shrink();

    final min = crop.referenceYieldTPerHa;
    final max = crop.maxRealisticYieldTPerHa;
    if (min <= 0 || max <= min) return const SizedBox.shrink();

    final target = state.targetYieldTPerHa;
    final value = (target ?? min).clamp(min, max).toDouble();
    final basis = crop.yieldBasis.isEmpty ? '' : ' of ${crop.yieldBasis}';
    final label = '${formatNumber(value)} t/ha$basis';

    return NeuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            icon: Icons.flag_rounded,
            title: 'Target harvest (optional)',
            subtitle: 'Tonnes per hectare$basis',
            trailing: target == null
                ? null
                : TextButton(onPressed: () => controller.setTargetYield(null), child: const Text('Reset')),
          ),
          const SizedBox(height: 12),
          Text(label, style: AppTheme.dataReadout(colors, fontSize: 20)),
          if (target == null)
            Text('Normal yield', style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary)),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 10).round().clamp(1, 200),
            label: label,
            semanticFormatterCallback: (_) => label,
            onChanged: (v) => controller.setTargetYield(double.parse(v.toStringAsFixed(1))),
          ),
          Row(
            children: [
              Text('${formatNumber(min)} t/ha', style: context.textTheme.labelSmall),
              const Spacer(),
              Text('${formatNumber(max)} t/ha', style: context.textTheme.labelSmall),
            ],
          ),
          InlineFieldError(state.fieldErrors[FertilizerField.targetYield]),
        ],
      ),
    );
  }
}
