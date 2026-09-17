import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Best-effort device coordinates for `POST /scans`/`POST /diagnoses`
/// (see README.mobile.md) — location there is optional and only improves
/// accuracy, so any denial/unavailability returns null instead of throwing.
class DeviceLocation {
  Future<(double, double)?> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.reduced),
      );
      return (position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }
}

final deviceLocationProvider = Provider<DeviceLocation>((ref) => DeviceLocation());
