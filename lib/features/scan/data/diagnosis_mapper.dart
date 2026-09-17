import '../domain/entities/diagnosis_result.dart';
import '../domain/entities/treatment_step.dart';

/// Maps a `DiagnosisResultDto` (see README.mobile.md) onto [DiagnosisResult].
DiagnosisResult diagnosisResultFromJson(Map<String, dynamic> json) {
  final diseaseName = json['diseaseName'] as String?;
  return DiagnosisResult(
    plantName: json['plantName'] as String,
    diseaseName: diseaseName,
    confidence: (json['confidence'] as num).toDouble(),
    severity: diagnosisSeverityFromJson(diseaseName, json['severity'] as String),
    summary: json['summary'] as String,
    treatmentSteps: (json['treatmentSteps'] as List<dynamic>)
        .map((e) => _treatmentStepFromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

DiagnosisSeverity diagnosisSeverityFromJson(String? diseaseName, String severity) {
  if (diseaseName == null) return DiagnosisSeverity.healthy;
  return switch (severity) {
    'low' => DiagnosisSeverity.low,
    'moderate' => DiagnosisSeverity.moderate,
    'high' => DiagnosisSeverity.high,
    _ => DiagnosisSeverity.moderate,
  };
}

TreatmentStep _treatmentStepFromJson(Map<String, dynamic> json) {
  return TreatmentStep(
    order: json['order'] as int,
    title: json['title'] as String,
    description: json['description'] as String,
  );
}
