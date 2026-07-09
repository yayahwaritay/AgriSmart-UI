import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/diagnosis_service.dart';
import '../../../services/mock_diagnosis_service.dart';
import '../data/repositories/diagnosis_repository_impl.dart';
import '../domain/entities/diagnosis_result.dart';
import '../domain/repositories/diagnosis_repository.dart';

/// The one line to change when swapping in a real inference backend.
final diagnosisServiceProvider = Provider<DiagnosisService>((ref) {
  return MockDiagnosisService();
});

final diagnosisRepositoryProvider = Provider<DiagnosisRepository>((ref) {
  return DiagnosisRepositoryImpl(ref.watch(diagnosisServiceProvider));
});

enum ScanStatus { idle, captured, diagnosing, success, error }

@immutable
class ScanState {
  const ScanState({
    this.status = ScanStatus.idle,
    this.image,
    this.result,
    this.errorMessage,
  });

  final ScanStatus status;
  final File? image;
  final DiagnosisResult? result;
  final String? errorMessage;

  ScanState copyWith({
    ScanStatus? status,
    File? image,
    DiagnosisResult? result,
    String? errorMessage,
  }) {
    return ScanState(
      status: status ?? this.status,
      image: image ?? this.image,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}

class ScanController extends Notifier<ScanState> {
  @override
  ScanState build() => const ScanState();

  void setCapturedImage(File image) {
    state = ScanState(status: ScanStatus.captured, image: image);
  }

  Future<void> runDiagnosis() async {
    final image = state.image;
    if (image == null) return;

    state = state.copyWith(status: ScanStatus.diagnosing);
    try {
      final result = await ref.read(diagnosisRepositoryProvider).diagnosePlant(image);
      state = state.copyWith(status: ScanStatus.success, result: result);
    } catch (e) {
      state = state.copyWith(status: ScanStatus.error, errorMessage: e.toString());
    }
  }

  void reset() => state = const ScanState();
}

final scanControllerProvider = NotifierProvider<ScanController, ScanState>(
  ScanController.new,
);
