import '../../../scan/domain/entities/diagnosis_result.dart';
import '../../../scan/domain/entities/plant_scan.dart';
import '../../../scan/domain/entities/treatment_step.dart';
import '../../domain/repositories/scan_history_repository.dart';

/// In-memory store seeded with a couple of past scans, so History and the
/// Home dashboard have something to render before the user scans anything.
/// Swap for a persisted (e.g. sqlite/Hive) implementation without touching
/// any presentation code.
class InMemoryScanHistoryRepository implements ScanHistoryRepository {
  final List<PlantScan> _scans = [
    PlantScan(
      id: 'seed-1',
      imagePath: '',
      scannedAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      diagnosis: const DiagnosisResult(
        plantName: 'Tomato',
        diseaseName: 'Early Blight',
        confidence: 0.91,
        severity: DiagnosisSeverity.moderate,
        summary: 'Dark concentric leaf spots consistent with Alternaria solani.',
        treatmentSteps: [
          TreatmentStep(order: 1, title: 'Remove affected leaves', description: 'Prune infected foliage.'),
        ],
      ),
    ),
    PlantScan(
      id: 'seed-2',
      imagePath: '',
      scannedAt: DateTime.now().subtract(const Duration(days: 6)),
      diagnosis: const DiagnosisResult(
        plantName: 'Cassava',
        confidence: 0.96,
        severity: DiagnosisSeverity.healthy,
        summary: 'No signs of pests or disease detected.',
        treatmentSteps: [
          TreatmentStep(order: 1, title: 'Keep monitoring', description: 'Re-scan every 1-2 weeks.'),
        ],
      ),
    ),
  ];

  @override
  Future<List<PlantScan>> fetchAll() async {
    final sorted = [..._scans]..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    return sorted;
  }

  @override
  Future<void> add(PlantScan scan) async {
    _scans.add(scan);
  }
}
