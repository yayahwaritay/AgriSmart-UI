import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/agri_badge.dart';
import '../../../../core/widgets/neu_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../scan/application/scan_providers.dart';
import '../../../scan/domain/entities/diagnosis_result.dart';
import '../widgets/confidence_readout.dart';
import '../widgets/treatment_step_tile.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, this.diagnosis});

  /// Passed via `go_router`'s `extra` when opened from Home/History. Falls
  /// back to the live scan result when opened straight after a scan.
  final DiagnosisResult? diagnosis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    final result = diagnosis ?? ref.watch(scanControllerProvider).result;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(
          child: Text('No diagnosis to show yet.', style: context.textTheme.bodyMedium),
        ),
      );
    }

    final (label, variant) = switch (result.severity) {
      DiagnosisSeverity.healthy => ('Healthy', AgriBadgeVariant.primary),
      DiagnosisSeverity.low => ('Low risk', AgriBadgeVariant.neutral),
      DiagnosisSeverity.moderate => ('Moderate risk', AgriBadgeVariant.alert),
      DiagnosisSeverity.high => ('High risk', AgriBadgeVariant.alert),
    };

    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Diagnosis')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    result.diseaseName ?? result.plantName,
                    style: context.textTheme.headlineSmall,
                  ),
                ),
                AgriBadge(label: label, variant: variant),
              ],
            ),
            const SizedBox(height: 4),
            Text(result.plantName, style: context.textTheme.bodyMedium?.copyWith(color: colors.textSecondary)),
            const SizedBox(height: 16),
            ConfidenceReadout(confidence: result.confidence),
            const SizedBox(height: 20),
            NeuCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Summary', style: context.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(result.summary, style: context.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Recommended treatment', style: context.textTheme.titleMedium),
            const SizedBox(height: 14),
            for (final step in result.treatmentSteps) TreatmentStepTile(step: step),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Back to Home',
              onPressed: () => context.go('/'),
            ),
          ],
        ),
      ),
    );
  }
}
