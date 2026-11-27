import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

const MethodChannel fakeGeolocatorChannel =
    MethodChannel('flutter.baseflow.com/geolocator');

/// Minimal method-channel responses for location tests.
///
/// [calls] receives the plugin method names in order, so tests can assert that
/// a passive map open never prompts while the relocate button always does.
void mockGeolocator({
  required LocationPermission checkPermission,
  LocationPermission? requestPermission,
  bool serviceEnabled = true,
  LatLng? position,
  LatLng? lastKnownPosition,
  bool failCurrentPosition = false,
  List<String>? calls,
}) {
  final requestResult = requestPermission ?? checkPermission;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(fakeGeolocatorChannel, (call) async {
    calls?.add(call.method);
    switch (call.method) {
      case 'isLocationServiceEnabled':
        return serviceEnabled;
      case 'checkPermission':
        return checkPermission.index;
      case 'requestPermission':
        return requestResult.index;
      case 'getCurrentPosition':
        if (failCurrentPosition) {
          throw PlatformException(code: 'LOCATION_UNAVAILABLE');
        }
        if (position == null) return null;
        return <String, dynamic>{
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': DateTime(2026).millisecondsSinceEpoch,
        };
      case 'getLastKnownPosition':
        final cached = lastKnownPosition ?? position;
        if (cached == null) return null;
        return <String, dynamic>{
          'latitude': cached.latitude,
          'longitude': cached.longitude,
          'timestamp': DateTime(2026).millisecondsSinceEpoch,
        };
      case 'openAppSettings':
        return true;
      default:
        return null;
    }
  });
}

void resetGeolocatorMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(fakeGeolocatorChannel, null);
}
