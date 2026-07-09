import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../history/application/history_providers.dart';
import '../../scan/domain/entities/diagnosis_result.dart';

class HomeStats {
  const HomeStats({required this.totalScans, required this.healthy, required this.needsAttention});

  final int totalScans;
  final int healthy;
  final int needsAttention;
}

/// Derives dashboard stat-card numbers from the scan history, so Home never
/// has to know how history is stored.
final homeStatsProvider = Provider<AsyncValue<HomeStats>>((ref) {
  final history = ref.watch(scanHistoryProvider);
  return history.whenData((scans) {
    final healthy = scans.where((s) => s.diagnosis.severity == DiagnosisSeverity.healthy).length;
    return HomeStats(
      totalScans: scans.length,
      healthy: healthy,
      needsAttention: scans.length - healthy,
    );
  });
});
