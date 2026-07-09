import 'dart:io';

import '../entities/diagnosis_result.dart';

/// Domain-facing abstraction the Scan feature depends on. The concrete
/// implementation (in `data/`) delegates to a [DiagnosisService] — see
/// `lib/services/diagnosis_service.dart` for the actual model/API swap point.
abstract class DiagnosisRepository {
  Future<DiagnosisResult> diagnosePlant(File image);
}
