import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Result of the first-run location consent flow.
class DeviceLocationResult {
  final LatLng? position;
  final bool granted;

  const DeviceLocationResult({this.position, required this.granted});

  bool get hasPosition => position != null;
}

/// Thin wrapper around `geolocator` for the location-first dashboard.
///
/// Denials and unavailable services are normal (emulators, desktop, privacy-
/// conscious users) so they return [DeviceLocationResult] instead of throwing.
class DeviceLocationService {
  /// Fallback centre used when location is denied — Ibb, Yemen.
  static const LatLng ibbCenter = LatLng(13.9667, 44.1833);

  /// Kept for backward compatibility.
  static const LatLng sanaaCenter = ibbCenter;

  static Future<DeviceLocationResult> requestLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return const DeviceLocationResult(granted: false);

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const DeviceLocationResult(granted: false);
      }

      final position = await Geolocator.getCurrentPosition()
          .timeout(const Duration(seconds: 10));
      return DeviceLocationResult(
        granted: true,
        position: LatLng(position.latitude, position.longitude),
      );
    } catch (_) {
      return const DeviceLocationResult(granted: false);
    }
  }
}
