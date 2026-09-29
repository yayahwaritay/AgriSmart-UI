import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/neu_card.dart';
import '../../application/fertilizer_providers.dart';
import '../../domain/entities/fertilizer_enums.dart';
import 'fertilizer_form_parts.dart';

/// "What is your soil like?" — simple Low/Medium/High cards by default, or
/// the three lab values behind "I have a soil test report".
class SoilSection extends ConsumerStatefulWidget {
  const SoilSection({super.key});

  @override
  ConsumerState<SoilSection> createState() => _SoilSectionState();
}

class _SoilSectionState extends ConsumerState<SoilSection> {
  bool _phReading = false;
  int _version = -1;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fertilizerCalculatorControllerProvider);
    final controller = ref.read(fertilizerCalculatorControllerProvider.notifier);
    final errors = state.fieldErrors;
    final version = state.formVersion;
    final soilTest = state.soilMode == SoilMode.soilTest;

    // Re-sync the pH toggle when the form is prefilled from history.
    if (_version != version) {
      _version = version;
      _phReading = state.ph != null;
    }

    return NeuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormSectionHeader(icon: Icons.landscape_rounded, title: 'What is your soil like?'),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('I have a soil test report'),
            value: soilTest,
            onChanged: (on) => controller.setSoilMode(on ? SoilMode.soilTest : SoilMode.simple),
          ),
          const SizedBox(height: 4),
          if (soilTest) ...[
            NumberField(
              key: ValueKey('n-$version'),
              label: 'Total nitrogen (N)',
              unit: '%',
              initialValue: state.nitrogenTotalPercent,
              errorText: errors[FertilizerField.nitrogen],
              onChanged: controller.setNitrogen,
            ),
            const SizedBox(height: 12),
            NumberField(
              key: ValueKey('p-$version'),
              label: 'Available phosphorus (Bray-1 P)',
              unit: 'mg/kg',
              hint: 'Same as ppm',
              initialValue: state.phosphorusBray1MgPerKg,
              errorText: errors[FertilizerField.phosphorus],
              onChanged: controller.setPhosphorus,
            ),
            const SizedBox(height: 12),
            NumberField(
              key: ValueKey('k-$version'),
              label: 'Exchangeable potassium (K)',
              unit: 'cmol/kg',
              hint: 'Same as meq/100 g',
              initialValue: state.potassiumCmolPerKg,
              errorText: errors[FertilizerField.potassium],
              onChanged: controller.setPotassium,
            ),
            const SizedBox(height: 12),
            NumberField(
              key: ValueKey('ph-test-$version'),
              label: 'Soil pH (optional)',
              unit: 'pH',
              initialValue: state.ph,
              errorText: errors[FertilizerField.ph],
              onChanged: controller.setPh,
            ),
          ] else ...[
            for (final fertility in SoilFertility.values) ...[
              _FertilityCard(
                fertility: fertility,
                selected: state.fertility == fertility,
                onTap: () => controller.setFertility(fertility),
              ),
              const SizedBox(height: 10),
            ],
            InlineFieldError(errors[FertilizerField.fertility]),
            const SizedBox(height: 8),
            Text('Soil type (optional)', style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final type in SoilType.values)
                  SelectChip(
                    label: _soilTypeLabel(type),
                    icon: _soilTypeIcon(type),
                    selected: state.soilType == type,
                    onTap: () => controller.toggleSoilType(type),
                  ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('I have a pH reading'),
              value: _phReading,
              onChanged: (on) {
                setState(() => _phReading = on);
                if (!on) controller.setPh(null);
              },
            ),
            if (_phReading)
              NumberField(
                key: ValueKey('ph-$version'),
                label: 'Soil pH',
                unit: 'pH',
                hint: 'Between 3 and 10',
                initialValue: state.ph,
                errorText: errors[FertilizerField.ph],
                onChanged: controller.setPh,
              ),
          ],
          InlineFieldError(errors[FertilizerField.soil]),
        ],
      ),
    );
  }

  String _soilTypeLabel(SoilType type) => switch (type) {
        SoilType.sandy => 'Sandy',
        SoilType.loamy => 'Loamy',
        SoilType.clay => 'Clay',
      };

  IconData _soilTypeIcon(SoilType type) => switch (type) {
        SoilType.sandy => Icons.grain_rounded,
        SoilType.loamy => Icons.spa_rounded,
        SoilType.clay => Icons.water_drop_rounded,
      };
}

/// One big Low/Medium/High card with a plain-language description.
class _FertilityCard extends StatelessWidget {
  const _FertilityCard({required this.fertility, required this.selected, required this.onTap});

  final SoilFertility fertility;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final (title, description, icon) = switch (fertility) {
      SoilFertility.low => ('Low', 'Crops were poor last season. Leaves were pale.', Icons.trending_down_rounded),
      SoilFertility.medium => ('Medium', 'Crops were about average.', Icons.trending_flat_rounded),
      SoilFertility.high => ('High', 'New land, dark soil, or after a fallow.', Icons.trending_up_rounded),
    };

    return Semantics(
      selected: selected,
      button: true,
      child: NeuCard(
        inset: !selected,
        color: selected ? colors.primary.withValues(alpha: 0.35) : null,
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: colors.primary, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(description, style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: selected ? colors.primary : colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
