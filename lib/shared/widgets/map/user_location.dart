import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/device_location_service.dart';

/// Google-Maps-style blue dot for the device position.
///
/// Kept pointer-transparent so tapping near it still pans/selects the map.
class UserLocationMarker extends StatelessWidget {
  const UserLocationMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.map_locate_me,
      child: IgnorePointer(
        child: Center(
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A73E8).withValues(alpha: 0.16),
            ),
            child: Center(
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1A73E8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ready-to-use flutter_map marker for [position].
Marker userLocationMarker(LatLng position) => Marker(
      point: position,
      width: 38,
      height: 38,
      child: const UserLocationMarker(),
    );

/// Floating "locate me" control used on every map in the app.
///
/// A press behaves like Google Maps' location button: it asks for permission
/// if needed, finds the device position and hands it to [onLocated] so the host
/// can recentre its camera. When permission is denied forever the snackbar
/// offers a shortcut to app settings; no marker is produced in that case.
class LocateMeButton extends StatefulWidget {
  const LocateMeButton({
    super.key,
    required this.onLocated,
    this.heroTag,
  });

  final ValueChanged<LatLng> onLocated;

  /// Pass a unique tag when more than one FAB shares the same hero namespace.
  /// `null` disables the hero transition entirely.
  final Object? heroTag;

  @override
  State<LocateMeButton> createState() => _LocateMeButtonState();
}

class _LocateMeButtonState extends State<LocateMeButton> {
  bool _locating = false;

  Future<void> _locate() async {
    if (_locating) return;
    setState(() => _locating = true);

    final result = await DeviceLocationService.requestLocation();
    if (!mounted) return;
    setState(() => _locating = false);

    if (result.hasPosition) {
      widget.onLocated(result.position!);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    if (result.permanentlyDenied) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.map_location_permission_denied),
          action: SnackBarAction(
            label: l10n.map_location_open_settings,
            onPressed: () => DeviceLocationService.openAppSettings(),
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.map_location_unavailable)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.map_locate_me,
      child: Tooltip(
        message: context.l10n.map_locate_me,
        child: FloatingActionButton.small(
          heroTag: widget.heroTag,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primaryInk,
          elevation: 4,
          shape: const CircleBorder(),
          onPressed: _locate,
          child: _locating
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.primaryInk,
                  ),
                )
              : const Icon(Icons.my_location_rounded, size: 20),
        ),
      ),
    );
  }
}
