import 'dart:io';

import '../../../scan/domain/entities/plant_scan.dart';

abstract class ScanHistoryRepository {
  Future<List<PlantScan>> fetchAll();

  /// Diagnoses [image] and saves it to history in one call — see
  /// `POST /scans` in README.mobile.md. [latitude]/[longitude] are optional
  /// and only improve diagnosis accuracy.
  Future<PlantScan> addScan(File image, {double? latitude, double? longitude});
}
