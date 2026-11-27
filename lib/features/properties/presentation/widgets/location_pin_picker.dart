import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_maplibre/flutter_map_maplibre.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:maplibre/maplibre.dart' as ml;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/map_sources.dart';
import '../../../../core/l10n/app_locale.dart';
import '../../../../core/l10n/context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../services/device_location_service.dart';
import '../../../../shared/widgets/map/user_location.dart';

/// Fixed-centre-pin map used by the add/edit property form.
///
/// The selected pin is owned by the parent through [selectedPin], so a drag
/// frame never rebuilds the surrounding 1700-line form. Only this widget's
/// caption listens to the notifier; the caption's nearest-governorate lookup is
/// cached per coordinate and language. Hosts that need to react to the *final*
/// pin receive a single coalesced call on [onPinCommitted] (~90ms after the
/// last gesture frame, or immediately for tap/locate/clear/dispose).
class LocationPinPicker extends StatefulWidget {
  const LocationPinPicker({
    super.key,
    required this.selectedPin,
    required this.initialCenter,
    this.onPinCommitted,
    this.commitDebounce = const Duration(milliseconds: 90),
  });

  /// Parent-owned pin. Save reads `selectedPin.value` at submit time.
  final ValueNotifier<LatLng?> selectedPin;

  /// Camera centre when the form has no saved pin yet.
  final LatLng initialCenter;

  /// Optional coalesced notification of the committed pin.
  final ValueChanged<LatLng?>? onPinCommitted;

  /// How long to wait for more gesture frames before committing.
  final Duration commitDebounce;

  @override
  State<LocationPinPicker> createState() => LocationPinPickerState();
}

class LocationPinPickerState extends State<LocationPinPicker> {
  static const int _maxCaptionCacheEntries = 64;

  final MapController _mapController = MapController();
  final Map<String, String> _captionCache = <String, String>{};
  Timer? _commitTimer;
  LatLng? _userLocation;
  LatLng? _lastCommitted;
  bool _hasCommitted = false;

  @override
  void initState() {
    super.initState();
    _restoreUserLocation();
  }

  @override
  void dispose() {
    // A gesture that ends by navigating away still needs its final value.
    _commitNow();
    _commitTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  /// Zoom reported by the live camera (used by the zoom controls and tests).
  double get cameraZoom => _mapController.camera.zoom;

  /// Permission was already granted (first-run prompt or Settings), so reveal
  /// the blue dot without asking again.
  Future<void> _restoreUserLocation() async {
    final result = await DeviceLocationService.currentLocationIfPermitted();
    if (!mounted || !result.hasPosition) return;
    setState(() => _userLocation = result.position);
  }

  static bool _samePin(LatLng? a, LatLng? b) {
    if (a == null || b == null) return a == null && b == null;
    return a.latitude == b.latitude && a.longitude == b.longitude;
  }

  void _commitNow() {
    _commitTimer?.cancel();
    final value = widget.selectedPin.value;
    if (_hasCommitted && _samePin(_lastCommitted, value)) return;
    _hasCommitted = true;
    _lastCommitted = value;
    widget.onPinCommitted?.call(value);
  }

  void _scheduleCommit() {
    _commitTimer?.cancel();
    _commitTimer = Timer(widget.commitDebounce, _commitNow);
  }

  /// Applies a gesture-driven camera centre without touching the parent form.
  ///
  /// Called for every flutter_map `onPositionChanged` frame; the host callback
  /// is coalesced so dozens of frames produce one commit.
  void applyGestureCenter(LatLng center) {
    widget.selectedPin.value = center;
    _scheduleCommit();
  }

  /// Places the pin immediately (tap, governorate change, host-initiated move).
  void commitPin(LatLng point) {
    widget.selectedPin.value = point;
    _commitNow();
    _mapController.move(point, cameraZoom);
  }

  /// Moves the map to [point] and commits it, e.g. on governorate change.
  void moveTo(LatLng point, {double zoom = 12.5}) {
    widget.selectedPin.value = point;
    _commitNow();
    _mapController.move(point, zoom);
  }

  void clearPin() {
    widget.selectedPin.value = null;
    _commitNow();
  }

  void zoomBy(double delta) {
    final camera = _mapController.camera;
    final zoom = (camera.zoom + delta).clamp(5.0, 18.0);
    _mapController.move(camera.center, zoom.toDouble());
  }

  void _onUserLocated(LatLng position) {
    if (!mounted) return;
    setState(() => _userLocation = position);
    widget.selectedPin.value = position;
    _commitNow();
    _mapController.move(position, 15);
  }

  /// Caption text is derived from the pin; the O(22) governorate scan only
  /// runs once per distinct coordinate/language pair.
  String _coordinateCaption(LatLng pin) {
    final language = AppLocale.isArabic ? 'ar' : 'en';
    final key = '${pin.latitude}|${pin.longitude}|$language';
    final cached = _captionCache[key];
    if (cached != null) return cached;

    final nearest = AppConstants.getNearestGovernorate(
      pin.latitude,
      pin.longitude,
    );
    final place = nearest == null
        ? ''
        : ' · ${AppConstants.getGovernorateNameAr(nearest)}';
    final caption =
        '${pin.latitude.toStringAsFixed(5)}, '
        '${pin.longitude.toStringAsFixed(5)}$place';
    if (_captionCache.length >= _maxCaptionCacheEntries) {
      _captionCache.clear();
    }
    _captionCache[key] = caption;
    return caption;
  }

  Widget _zoomButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          elevation: 3,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, size: 20, color: AppColors.primaryInk),
            ),
          ),
        ),
      ),
    );
  }

  Widget _caption(BuildContext context) {
    return ValueListenableBuilder<LatLng?>(
      valueListenable: widget.selectedPin,
      builder: (context, pin, _) {
        final pinned = pin != null;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                pinned ? Icons.check_circle_rounded : Icons.touch_app_rounded,
                size: 18,
                color: AppColors.primaryInk,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pinned
                          ? context.l10n.addprop_location_pinned
                          : context.l10n.addprop_map_center_hint,
                      style: AppFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (pinned)
                      Text(
                        _coordinateCaption(pin),
                        style: AppFonts.cairo(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (pinned)
                TextButton(
                  onPressed: clearPin,
                  child: Text(
                    context.l10n.addprop_clear_pin,
                    style: AppFonts.cairo(fontSize: 11.5),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _map() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.selectedPin.value ?? widget.initialCenter,
        initialZoom: 13,
        minZoom: 5,
        maxZoom: 18,
        cameraConstraint: CameraConstraint.containLatitude(),
        // Dragging (or zooming) moves the pin with the camera centre — no need
        // to hit an exact pixel.
        onPositionChanged: (position, gesture) {
          if (gesture && mounted) applyGestureCenter(position.center);
        },
        onTap: (tapPosition, point) => commitPin(point),
      ),
      children: [
        MapLibreLayer(
          style: const ml.MapStyle.url(AppMapSources.openFreeMapStyleUrl),
          onError: (event) =>
              debugPrint('Location map error: ${event.message}'),
          children: [
            if (_userLocation != null)
              FlutterMapAdapter(
                child: MarkerLayer(
                  markers: [userLocationMarker(_userLocation!)],
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 76),
          child: RichAttributionWidget(
            alignment: AttributionAlignment.bottomRight,
            attributions: [
              TextSourceAttribution(
                AppMapSources.openFreeMapAttribution,
                onTap: () {
                  final uri = Uri.parse(
                    AppMapSources.openFreeMapAttributionUrl,
                  );
                  canLaunchUrl(uri).then((ok) {
                    if (ok) {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: RepaintBoundary(
        child: Container(
          height: 320,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
          ),
          child: Stack(
            children: [
              _map(),
              // Fixed centre pin — the tip marks the exact stored coordinate.
              Positioned.fill(
                child: RepaintBoundary(
                  child: IgnorePointer(
                    child: Center(
                      child: Transform.translate(
                        offset: const Offset(0, -20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                size: 34,
                                color: AppColors.primary,
                              ),
                            ),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(110),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 10,
                start: 10,
                child: LocateMeButton(
                  heroTag: 'add_property_locate_me',
                  onLocated: _onUserLocated,
                ),
              ),
              PositionedDirectional(
                top: 10,
                end: 10,
                child: Column(
                  children: [
                    _zoomButton(
                      icon: Icons.add_rounded,
                      tooltip: context.l10n.addprop_map_zoom_in,
                      onPressed: () => zoomBy(1),
                    ),
                    const SizedBox(height: 8),
                    _zoomButton(
                      icon: Icons.remove_rounded,
                      tooltip: context.l10n.addprop_map_zoom_out,
                      onPressed: () => zoomBy(-1),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: RepaintBoundary(child: _caption(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
