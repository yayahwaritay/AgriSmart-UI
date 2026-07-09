import 'package:flutter/foundation.dart';

import 'diagnosis_result.dart';

/// A completed scan persisted to History: the captured image plus the
/// diagnosis produced for it.
@immutable
class PlantScan {
  const PlantScan({
    required this.id,
    required this.imagePath,
    required this.diagnosis,
    required this.scannedAt,
  });

  final String id;
  final String imagePath;
  final DiagnosisResult diagnosis;
  final DateTime scannedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantScan &&
          id == other.id &&
          imagePath == other.imagePath &&
          diagnosis == other.diagnosis &&
          scannedAt == other.scannedAt;

  @override
  int get hashCode => Object.hash(id, imagePath, diagnosis, scannedAt);
}
