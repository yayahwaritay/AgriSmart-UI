import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../scan/domain/entities/plant_scan.dart';
import '../data/repositories/in_memory_scan_history_repository.dart';
import '../domain/repositories/scan_history_repository.dart';

final scanHistoryRepositoryProvider = Provider<ScanHistoryRepository>((ref) {
  return InMemoryScanHistoryRepository();
});

class ScanHistoryList extends AsyncNotifier<List<PlantScan>> {
  @override
  Future<List<PlantScan>> build() {
    return ref.watch(scanHistoryRepositoryProvider).fetchAll();
  }

  Future<void> addScan(PlantScan scan) async {
    final repository = ref.read(scanHistoryRepositoryProvider);
    await repository.add(scan);
    state = AsyncData(await repository.fetchAll());
  }
}

final scanHistoryProvider = AsyncNotifierProvider<ScanHistoryList, List<PlantScan>>(
  ScanHistoryList.new,
);
