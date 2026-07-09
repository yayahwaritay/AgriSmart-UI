import 'dart:io';
import 'dart:math';

import '../features/scan/domain/entities/diagnosis_result.dart';
import '../features/scan/domain/entities/treatment_step.dart';
import 'diagnosis_service.dart';

/// Deterministic-ish fake used until a real model/API is wired in. Simulates
/// network/inference latency and returns one of a few canned results.
class MockDiagnosisService implements DiagnosisService {
  MockDiagnosisService({Random? random}) : _random = random ?? Random();

  final Random _random;

  static final List<DiagnosisResult> _sampleResults = [
    const DiagnosisResult(
      plantName: 'Tomato',
      diseaseName: 'Early Blight',
      confidence: 0.91,
      severity: DiagnosisSeverity.moderate,
      summary:
          'Dark concentric leaf spots consistent with Alternaria solani. '
          'Left untreated this spreads to stems and fruit.',
      treatmentSteps: [
        TreatmentStep(
          order: 1,
          title: 'Remove affected leaves',
          description: 'Prune and dispose of infected foliage away from the field to cut the spore source.',
        ),
        TreatmentStep(
          order: 2,
          title: 'Apply a copper-based fungicide',
          description: 'Spray every 7-10 days, focusing on the underside of leaves.',
        ),
        TreatmentStep(
          order: 3,
          title: 'Improve airflow',
          description: 'Space plants further apart and stake to reduce leaf wetness duration.',
        ),
      ],
    ),
    const DiagnosisResult(
      plantName: 'Maize',
      diseaseName: 'Fall Armyworm',
      confidence: 0.87,
      severity: DiagnosisSeverity.high,
      summary:
          'Window-pane feeding damage and frass in the whorl indicate an '
          'active Spodoptera frugiperda infestation.',
      treatmentSteps: [
        TreatmentStep(
          order: 1,
          title: 'Scout the whole plot',
          description: 'Check 20 plants at multiple points; treat if over 20% show damage.',
        ),
        TreatmentStep(
          order: 2,
          title: 'Apply a targeted insecticide',
          description: 'Use a Bt-based or approved contact insecticide, applied to the whorl in early morning or evening.',
        ),
      ],
    ),
    const DiagnosisResult(
      plantName: 'Cassava',
      confidence: 0.96,
      severity: DiagnosisSeverity.healthy,
      summary: 'No signs of pests or disease detected. Leaf color and structure look healthy.',
      treatmentSteps: [
        TreatmentStep(
          order: 1,
          title: 'Keep monitoring',
          description: 'Re-scan every 1-2 weeks, especially after rain, to catch issues early.',
        ),
      ],
    ),
  ];

  @override
  Future<DiagnosisResult> diagnose(File image) async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    return _sampleResults[_random.nextInt(_sampleResults.length)];
  }
}
