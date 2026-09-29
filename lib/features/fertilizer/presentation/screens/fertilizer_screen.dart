import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/crop_image.dart';
import '../../../../core/widgets/neu_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/fertilizer_providers.dart';
import '../widgets/area_section.dart';
import '../widgets/fertilizer_crop_picker_sheet.dart';
import '../widgets/fertilizer_form_parts.dart';
import '../widgets/product_section.dart';
import '../widgets/soil_section.dart';
import '../widgets/target_yield_section.dart';

/// The `/fertilizer` calculator form — see README.fertilizer.mobile.md.
/// Crop → farm size → soil → target yield → fertilizers, then "Calculate"
/// opens `/fertilizer/result`. Inputs live in
/// [fertilizerCalculatorControllerProvider], so they survive leaving and
/// coming back.
class FertilizerScreen extends ConsumerStatefulWidget {
  const FertilizerScreen({super.key});

  @override
  ConsumerState<FertilizerScreen> createState() => _FertilizerScreenState();
}

class _FertilizerScreenState extends ConsumerState<FertilizerScreen> {
  bool _loadingCrops = false;

  Future<void> _pickCrop() async {
    setState(() => _loadingCrops = true);
    try {
      final crops = await ref.read(fertilizerCropsProvider.future);
      if (!mounted) return;
      setState(() => _loadingCrops = false);
      final crop = await showFertilizerCropPickerSheet(
        context,
        crops,
        selected: ref.read(fertilizerCalculatorControllerProvider).crop,
      );
      if (crop != null) ref.read(fertilizerCalculatorControllerProvider.notifier).selectCrop(crop);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingCrops = false);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: const Text('Could not load crops. Check your connection.'),
            action: SnackBarAction(
              label: 'Try again',
              onPressed: () {
                ref.invalidate(fertilizerCropsProvider);
                _pickCrop();
              },
            ),
          ),
        );
    }
  }

  Future<void> _calculate() async {
    final controller = ref.read(fertilizerCalculatorControllerProvider.notifier);
    final ok = await controller.calculate();
    if (!mounted) return;
    if (ok) {
      await context.push('/fertilizer/result');
      return;
    }
    final message = ref.read(fertilizerCalculatorControllerProvider).errorMessage;
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final state = ref.watch(fertilizerCalculatorControllerProvider);
    final calculating = state.status == CalculationStatus.calculating;
    final crop = state.crop;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Fertilizer calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Saved plans',
            onPressed: () => context.push('/fertilizer/history'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Text(
              'How much fertilizer do I need?',
              style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            NeuCard(
              padding: const EdgeInsets.all(12),
              onTap: _loadingCrops ? null : _pickCrop,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CropImage(cropId: crop?.id ?? '', size: 56, fallbackIcon: fertilizerCropIcon(crop)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(crop?.name ?? 'Choose a crop', style: context.textTheme.titleMedium),
                            if (crop != null && crop.localName.isNotEmpty)
                              Text(
                                crop.localName,
                                style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                              ),
                          ],
                        ),
                      ),
                      if (_loadingCrops)
                        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      else
                        Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
                    ],
                  ),
                  if (crop?.isPerennial ?? false) ...[
                    const SizedBox(height: 10),
                    const PerennialBadge(),
                  ],
                  InlineFieldError(state.fieldErrors[FertilizerField.crop]),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const AreaSection(),
            const SizedBox(height: 12),
            const SoilSection(),
            if (crop != null) ...[
              const SizedBox(height: 12),
              const TargetYieldSection(),
            ],
            const SizedBox(height: 12),
            const ProductSection(),
            const SizedBox(height: 24),
            PrimaryButton(
              label: calculating ? 'Calculating…' : 'Calculate',
              icon: Icons.calculate_rounded,
              onPressed: calculating ? null : _calculate,
            ),
          ],
        ),
      ),
    );
  }
}
