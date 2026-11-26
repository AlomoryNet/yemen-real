import 'package:flutter/widgets.dart';
import 'package:maplibre_platform_interface/maplibre_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Minimal MapLibre platform for widget tests.
///
/// `MapLibreLayer` mounts a native `MapLibreMap`, which is unavailable in
/// `flutter test`. This stub renders an empty box but marks the map as
/// initialized so that `FlutterMapAdapter` children (markers, polygons) still
/// build and remain inspectable by tests.
class FakeMapLibreMapState extends MapLibreMapState {
  @override
  void initState() {
    super.initState();
    camera =
        widget.camera ??
        const CameraPosition(
          center: Geographic(lon: 44.2, lat: 15.35),
          zoom: 7,
          bearing: 0,
          pitch: 0,
        );
    isInitialized = true;
  }

  @override
  StyleController? get style => null;

  @override
  Widget buildPlatformWidget(BuildContext context) => const SizedBox.expand();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeMapLibrePlatform extends MapLibrePlatform
    with MockPlatformInterfaceMixin {
  @override
  MapLibreMapState createWidgetState() => FakeMapLibreMapState();
}

/// Call from `setUp` in any test that pumps a map screen.
void registerFakeMapLibrePlatform() {
  MapLibrePlatform.instance = FakeMapLibrePlatform();
}
