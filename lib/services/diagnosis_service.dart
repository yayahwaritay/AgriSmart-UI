import 'dart:io';

import '../features/scan/domain/entities/diagnosis_result.dart';

/// The single swap point for real inference.
///
/// [MockDiagnosisService] (in this same directory) implements this today.
/// To wire up a real backend — a hosted inference API or an on-device TFLite
/// model — write one new class implementing [DiagnosisService], then point
/// `diagnosisServiceProvider` (in `lib/features/scan/application/scan_providers.dart`)
/// at it. No other code, including every widget in `features/scan`, needs to
/// change.
abstract class DiagnosisService {
  Future<DiagnosisResult> diagnose(File image);
}
