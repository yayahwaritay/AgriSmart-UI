import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/location/device_location.dart';
import '../../../core/network/api_client.dart';
import '../../auth/application/auth_providers.dart';
import '../data/repositories/http_crop_repository.dart';
import '../data/repositories/http_harvest_repository.dart';
import '../domain/entities/crop.dart';
import '../domain/entities/harvest_prediction.dart';
import '../domain/repositories/crop_repository.dart';
import '../domain/repositories/harvest_repository.dart';

final cropRepositoryProvider = Provider<CropRepository>((ref) {
  return HttpCropRepository(ref.watch(apiClientProvider));
});

final harvestRepositoryProvider = Provider<HarvestRepository>((ref) {
  return HttpHarvestRepository(ref.watch(apiClientProvider));
});

/// The predictor's crop picker — don't hardcode the list, see
/// README.mobile.md.
final cropsProvider = FutureProvider<List<CropSummary>>((ref) {
  return ref.watch(cropRepositoryProvider).fetchAll();
});

enum PredictionStatus { idle, predicting, success, error }

@immutable
class HarvestFormState {
  const HarvestFormState({
    required this.plantingDate,
    this.crop,
    this.latitude,
    this.longitude,
    this.status = PredictionStatus.idle,
    this.result,
    this.errorMessage,
  });

  final CropSummary? crop;
  final double? latitude;
  final double? longitude;
  final DateTime plantingDate;
  final PredictionStatus status;
  final HarvestPrediction? result;
  final String? errorMessage;

  bool get hasLocation => latitude != null && longitude != null;

  HarvestFormState copyWith({
    CropSummary? crop,
    double? latitude,
    double? longitude,
    DateTime? plantingDate,
    PredictionStatus? status,
    HarvestPrediction? result,
    String? errorMessage,
  }) {
    return HarvestFormState(
      crop: crop ?? this.crop,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      plantingDate: plantingDate ?? this.plantingDate,
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}

/// Drives the `/harvest` predictor screen: form fields plus the in-flight
/// `POST /harvest/predict` call. See README.mobile.md's "Crops & Harvest
/// Prediction" — these endpoints are public, but attaching the caller's
/// token (handled automatically by [ApiClient]) saves the result to
/// `GET /harvest/history`, so always run this while logged in when possible.
class HarvestPredictionController extends Notifier<HarvestFormState> {
  @override
  HarvestFormState build() => HarvestFormState(plantingDate: DateTime.now());

  void selectCrop(CropSummary crop) {
    if (state.crop?.id == crop.id) return;
    state = state.copyWith(crop: crop);
  }

  void setLocation(double latitude, double longitude) {
    state = state.copyWith(latitude: latitude, longitude: longitude);
  }

  void setPlantingDate(DateTime date) {
    state = state.copyWith(plantingDate: DateTime(date.year, date.month, date.day));
  }

  /// Best-effort GPS fix for "my current field" — silently does nothing if
  /// location is denied/unavailable, same contract as [DeviceLocation].
  Future<bool> useDeviceLocation() async {
    final coordinates = await ref.read(deviceLocationProvider).current();
    if (coordinates == null) return false;
    setLocation(coordinates.$1, coordinates.$2);
    return true;
  }

  String? _validate() {
    if (state.crop == null) return 'Pick a crop first.';
    if (!state.hasLocation) return 'Set the field\'s location.';
    final now = DateTime.now();
    final earliestAllowed = DateTime(now.year - 3, now.month, now.day);
    final latestAllowed = DateTime(now.year + 1, now.month, now.day);
    if (state.plantingDate.isBefore(earliestAllowed)) {
      return 'Planting date can\'t be more than 3 years in the past.';
    }
    if (state.plantingDate.isAfter(latestAllowed)) {
      return 'Planting date can\'t be more than 1 year in the future.';
    }
    return null;
  }

  Future<void> predict() async {
    final validationError = _validate();
    if (validationError != null) {
      state = state.copyWith(status: PredictionStatus.error, errorMessage: validationError);
      return;
    }

    final crop = state.crop!;
    state = state.copyWith(status: PredictionStatus.predicting);
    try {
      final result = await ref.read(harvestRepositoryProvider).predict(
            cropId: crop.id,
            latitude: state.latitude!,
            longitude: state.longitude!,
            plantingDate: state.plantingDate,
          );
      state = state.copyWith(status: PredictionStatus.success, result: result);
      if (ref.read(authControllerProvider).status == AuthStatus.authenticated) {
        ref.invalidate(harvestHistoryProvider);
      }
    } catch (e) {
      state = state.copyWith(status: PredictionStatus.error, errorMessage: '$e');
    }
  }

  void reset() => state = HarvestFormState(crop: state.crop, plantingDate: DateTime.now());
}

final harvestPredictionControllerProvider =
    NotifierProvider<HarvestPredictionController, HarvestFormState>(HarvestPredictionController.new);

/// The caller's own saved predictions — `GET /harvest/history` — only ever
/// meaningful while logged in; the History link is only shown then.
class HarvestHistoryList extends AsyncNotifier<List<HarvestPrediction>> {
  @override
  Future<List<HarvestPrediction>> build() {
    return ref.watch(harvestRepositoryProvider).fetchHistory();
  }
}

final harvestHistoryProvider = AsyncNotifierProvider<HarvestHistoryList, List<HarvestPrediction>>(
  HarvestHistoryList.new,
);
