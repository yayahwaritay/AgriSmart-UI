import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/widgets/crop_image.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/widgets/neu_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/harvest_providers.dart';
import '../../domain/entities/crop.dart';
import '../widgets/crop_picker_sheet.dart';
import '../widgets/harvest_result_card.dart';

/// The `/harvest` predictor — see README.mobile.md's "Crops & Harvest
/// Prediction". Optionally opened with a [CropSummary] via `extra` (e.g.
/// from the crop catalog) to preselect it.
class HarvestScreen extends ConsumerStatefulWidget {
  const HarvestScreen({super.key, this.initialCrop});

  final CropSummary? initialCrop;

  @override
  ConsumerState<HarvestScreen> createState() => _HarvestScreenState();
}

class _HarvestScreenState extends ConsumerState<HarvestScreen> {
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  bool _locatingDevice = false;

  @override
  void initState() {
    super.initState();
    final crop = widget.initialCrop;
    if (crop != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(harvestPredictionControllerProvider.notifier).selectCrop(crop);
      });
    }
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _useDeviceLocation() async {
    setState(() => _locatingDevice = true);
    final found = await ref.read(harvestPredictionControllerProvider.notifier).useDeviceLocation();
    if (!mounted) return;
    setState(() => _locatingDevice = false);
    if (!found) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get your location — enter it manually instead.')),
      );
      return;
    }
    final state = ref.read(harvestPredictionControllerProvider);
    _latitudeController.text = '${state.latitude}';
    _longitudeController.text = '${state.longitude}';
  }

  Future<void> _pickCrop() async {
    final crops = await ref.read(cropsProvider.future);
    if (!mounted) return;
    final crop = await showCropPickerSheet(
      context,
      crops,
      selected: ref.read(harvestPredictionControllerProvider).crop,
    );
    if (crop != null) {
      ref.read(harvestPredictionControllerProvider.notifier).selectCrop(crop);
    }
  }

  Future<void> _pickPlantingDate() async {
    final now = DateTime.now();
    final current = ref.read(harvestPredictionControllerProvider).plantingDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(now.year - 3, now.month, now.day),
      lastDate: DateTime(now.year + 1, now.month, now.day),
    );
    if (picked != null) {
      ref.read(harvestPredictionControllerProvider.notifier).setPlantingDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final formState = ref.watch(harvestPredictionControllerProvider);

    ref.listen(harvestPredictionControllerProvider, (previous, next) {
      if (next.status == PredictionStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    final predicting = formState.status == PredictionStatus.predicting;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Harvest predictor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'History',
            onPressed: () => context.push('/harvest/history'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Text(
              'When should I harvest this?',
              style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            NeuCard(
              onTap: _pickCrop,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CropImage(cropId: formState.crop?.id ?? '', size: 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formState.crop == null ? 'Crop' : 'Crop · ~${formState.crop!.typicalDaysToMaturity} days',
                          style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formState.crop?.name ?? 'Choose a crop',
                          style: context.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 12),
            NeuCard(
              onTap: _pickPlantingDate,
              child: Row(
                children: [
                  Icon(Icons.event_rounded, color: colors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Planted ${formState.plantingDate.toShortDateLabel()}',
                        style: context.textTheme.bodyMedium),
                  ),
                  Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 12),
            NeuCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Field location', style: context.textTheme.titleSmall),
                      ),
                      GlassButton(
                        label: _locatingDevice ? 'Locating…' : 'Use my location',
                        icon: Icons.my_location_rounded,
                        onPressed: _locatingDevice ? null : _useDeviceLocation,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _CoordinateField(
                          label: 'Latitude',
                          controller: _latitudeController,
                          onChanged: (value) => _applyManualCoordinates(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CoordinateField(
                          label: 'Longitude',
                          controller: _longitudeController,
                          onChanged: (value) => _applyManualCoordinates(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: predicting ? 'Predicting…' : 'Predict harvest',
              icon: Icons.query_stats_rounded,
              onPressed: predicting ? null : () => ref.read(harvestPredictionControllerProvider.notifier).predict(),
            ),
            if (formState.status == PredictionStatus.success && formState.result != null) ...[
              const SizedBox(height: 28),
              HarvestResultCard(prediction: formState.result!),
            ],
          ],
        ),
      ),
    );
  }

  void _applyManualCoordinates() {
    final latitude = double.tryParse(_latitudeController.text);
    final longitude = double.tryParse(_longitudeController.text);
    if (latitude == null || longitude == null) return;
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) return;
    ref.read(harvestPredictionControllerProvider.notifier).setLocation(latitude, longitude);
  }
}

class _CoordinateField extends StatelessWidget {
  const _CoordinateField({required this.label, required this.controller, required this.onChanged});

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, isDense: true),
    );
  }
}
