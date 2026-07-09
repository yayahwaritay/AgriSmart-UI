import 'package:flutter/foundation.dart';

import 'treatment_step.dart';

enum DiagnosisSeverity { healthy, low, moderate, high }

@immutable
class DiagnosisResult {
  const DiagnosisResult({
    required this.plantName,
    required this.confidence,
    required this.severity,
    required this.summary,
    required this.treatmentSteps,
    this.diseaseName,
  });

  final String plantName;

  /// Null when [severity] is [DiagnosisSeverity.healthy].
  final String? diseaseName;

  /// 0.0-1.0 model confidence.
  final double confidence;

  final DiagnosisSeverity severity;
  final String summary;
  final List<TreatmentStep> treatmentSteps;

  bool get isHealthy => severity == DiagnosisSeverity.healthy;

  DiagnosisResult copyWith({
    String? plantName,
    String? diseaseName,
    double? confidence,
    DiagnosisSeverity? severity,
    String? summary,
    List<TreatmentStep>? treatmentSteps,
  }) {
    return DiagnosisResult(
      plantName: plantName ?? this.plantName,
      diseaseName: diseaseName ?? this.diseaseName,
      confidence: confidence ?? this.confidence,
      severity: severity ?? this.severity,
      summary: summary ?? this.summary,
      treatmentSteps: treatmentSteps ?? this.treatmentSteps,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagnosisResult &&
          plantName == other.plantName &&
          diseaseName == other.diseaseName &&
          confidence == other.confidence &&
          severity == other.severity &&
          summary == other.summary &&
          listEquals(treatmentSteps, other.treatmentSteps);

  @override
  int get hashCode => Object.hash(
        plantName,
        diseaseName,
        confidence,
        severity,
        summary,
        Object.hashAll(treatmentSteps),
      );
}
