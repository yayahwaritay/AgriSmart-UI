import 'dart:io';

import '../../../../services/diagnosis_service.dart';
import '../../domain/entities/diagnosis_result.dart';
import '../../domain/repositories/diagnosis_repository.dart';

class DiagnosisRepositoryImpl implements DiagnosisRepository {
  DiagnosisRepositoryImpl(this._service);

  final DiagnosisService _service;

  @override
  Future<DiagnosisResult> diagnosePlant(File image) => _service.diagnose(image);
}
