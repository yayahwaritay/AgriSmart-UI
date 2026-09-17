import 'dart:io';

import '../../../../core/network/api_client.dart';
import '../../../scan/data/diagnosis_mapper.dart';
import '../../../scan/domain/entities/plant_scan.dart';
import '../../domain/repositories/scan_history_repository.dart';

/// API-backed scan history — see `GET/POST /scans` in README.mobile.md.
class HttpScanHistoryRepository implements ScanHistoryRepository {
  HttpScanHistoryRepository(this._client);

  final ApiClient _client;

  PlantScan _scanFromJson(Map<String, dynamic> json) {
    return PlantScan(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      diagnosis: diagnosisResultFromJson(json['diagnosis'] as Map<String, dynamic>),
      scannedAt: DateTime.parse(json['scannedAt'] as String),
    );
  }

  @override
  Future<List<PlantScan>> fetchAll() async {
    final json = await _client.get('/scans') as List<dynamic>;
    final scans = json.map((e) => _scanFromJson(e as Map<String, dynamic>)).toList();
    scans.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    return scans;
  }

  @override
  Future<PlantScan> addScan(File image, {double? latitude, double? longitude}) async {
    final json = await _client.postMultipart(
      '/scans',
      field: 'image',
      file: image,
      fields: {
        if (latitude != null) 'latitude': '$latitude',
        if (longitude != null) 'longitude': '$longitude',
      },
    ) as Map<String, dynamic>;
    return _scanFromJson(json);
  }
}
