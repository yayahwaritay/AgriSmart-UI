import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../scan/domain/entities/plant_scan.dart';
import '../data/repositories/http_scan_history_repository.dart';
import '../domain/repositories/scan_history_repository.dart';

final scanHistoryRepositoryProvider = Provider<ScanHistoryRepository>((ref) {
  return HttpScanHistoryRepository(ref.watch(apiClientProvider));
});

class ScanHistoryList extends AsyncNotifier<List<PlantScan>> {
  @override
  Future<List<PlantScan>> build() {
    return ref.watch(scanHistoryRepositoryProvider).fetchAll();
  }

  /// Diagnoses [image] and saves it to history in one call, then updates the
  /// cached list without a round-trip fetch.
  Future<PlantScan> addScan(File image, {double? latitude, double? longitude}) async {
    final repository = ref.read(scanHistoryRepositoryProvider);
    final scan = await repository.addScan(image, latitude: latitude, longitude: longitude);
    state = AsyncData([scan, ...state.value ?? const []]);
    return scan;
  }
}

final scanHistoryProvider = AsyncNotifierProvider<ScanHistoryList, List<PlantScan>>(
  ScanHistoryList.new,
);
