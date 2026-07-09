import '../../../scan/domain/entities/plant_scan.dart';

abstract class ScanHistoryRepository {
  Future<List<PlantScan>> fetchAll();
  Future<void> add(PlantScan scan);
}
