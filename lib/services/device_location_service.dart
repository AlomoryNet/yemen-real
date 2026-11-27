import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Result of the first-run location consent flow.
class DeviceLocationResult {
  final LatLng? position;
  final bool granted;
  final bool permanentlyDenied;

  const DeviceLocationResult({
    this.position,
    required this.granted,
    this.permanentlyDenied = false,
  });

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

  /// Reads the device position **only when permission is already granted**.
  ///
  /// Maps call this when they open so they can quietly centre on the user
  /// without re-prompting. Use [requestLocation] from an explicit button press
  /// when the user has not granted permission yet.
  static Future<DeviceLocationResult> currentLocationIfPermitted() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return const DeviceLocationResult(granted: false);

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        return const DeviceLocationResult(
          granted: false,
          permanentlyDenied: true,
        );
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return const DeviceLocationResult(granted: false);
      }

      final position = await _devicePosition();
      if (position == null) {
        return const DeviceLocationResult(granted: false);
      }
      return DeviceLocationResult(
        granted: true,
        position: LatLng(position.latitude, position.longitude),
      );
    } catch (_) {
      return const DeviceLocationResult(granted: false);
    }
  }

  /// Fresh fixes can take longer than a map-open or a button press on a slow
  /// device. Fall back to the OS-cached position (as Google Maps does) so the
  /// blue dot appears immediately instead of leaving the map without a marker.
  static Future<Position?> _devicePosition() async {
    try {
      return await Geolocator.getCurrentPosition().timeout(
        const Duration(seconds: 10),
      );
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition().timeout(
          const Duration(seconds: 3),
        );
      } catch (_) {
        return null;
      }
    }
  }

  static Future<DeviceLocationResult> requestLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return const DeviceLocationResult(granted: false);

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const DeviceLocationResult(
          granted: false,
          permanentlyDenied: true,
        );
      }
      if (permission == LocationPermission.denied) {
        return const DeviceLocationResult(granted: false);
      }

      final position = await _devicePosition();
      if (position == null) {
        return const DeviceLocationResult(granted: false);
      }
      return DeviceLocationResult(
        granted: true,
        position: LatLng(position.latitude, position.longitude),
      );
    } catch (_) {
      return const DeviceLocationResult(granted: false);
    }
  }

  /// Opens the OS app settings so a denied-forever permission can be retried.
  static Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
