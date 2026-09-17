import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/location/device_location.dart';
import '../../history/application/history_providers.dart';
import '../domain/entities/diagnosis_result.dart';

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

  /// Diagnoses and saves the captured image in one call — `POST /scans`,
  /// see README.mobile.md — sending the device's location when available to
  /// improve accuracy.
  Future<void> runDiagnosis() async {
    final image = state.image;
    if (image == null) return;

    state = state.copyWith(status: ScanStatus.diagnosing);
    try {
      final coordinates = await ref.read(deviceLocationProvider).current();
      final scan = await ref.read(scanHistoryProvider.notifier).addScan(
            image,
            latitude: coordinates?.$1,
            longitude: coordinates?.$2,
          );
      state = state.copyWith(status: ScanStatus.success, result: scan.diagnosis);
    } catch (e) {
      state = state.copyWith(status: ScanStatus.error, errorMessage: e.toString());
    }
  }

  void reset() => state = const ScanState();
}

final scanControllerProvider = NotifierProvider<ScanController, ScanState>(
  ScanController.new,
);
