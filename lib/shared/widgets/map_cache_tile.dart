import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre/maplibre.dart';

import '../../core/utils/app_feedback.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../services/map_offline_service.dart';

/// Settings control for the MapLibre offline pack.
///
/// The country pack covers zoom 5–10; areas the user actually browses are
/// retained by MapLibre's bounded ambient cache at higher zoom levels.
class MapCacheTile extends ConsumerStatefulWidget {
  const MapCacheTile({super.key});

  @override
  ConsumerState<MapCacheTile> createState() => _MapCacheTileState();
}

class _MapCacheTileState extends ConsumerState<MapCacheTile> {
  StreamSubscription<DownloadProgress>? _subscription;
  OfflineRegion? _region;
  double? _progress;
  bool _downloading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRegion();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadRegion() async {
    if (!MapOfflineService.isSupported) return;
    try {
      final regions = await MapOfflineService.listRegions();
      if (!mounted) return;
      setState(() => _region = MapOfflineService.yemenRegion(regions));
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  Future<void> _download() async {
    if (!MapOfflineService.isSupported) return;
    setState(() {
      _downloading = true;
      _progress = 0;
      _error = null;
    });
    await _subscription?.cancel();
    _subscription = MapOfflineService.downloadYemen().listen(
      (progress) {
        if (!mounted) return;
        setState(() {
          _region = progress.region;
          _progress = progress.progress;
          if (progress.downloadCompleted) _downloading = false;
        });
        if (progress.downloadCompleted && context.mounted) {
          showOptionalFeedback(
            context,
            ref,
            AppLocalizations.of(context)!.set_offline_map_downloaded,
            backgroundColor: AppColors.primary,
          );
        }
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _downloading = false;
          _error = error.toString();
        });
      },
      onDone: () {
        if (!mounted) return;
        setState(() => _downloading = false);
      },
    );
  }

  Future<void> _delete() async {
    final region = _region;
    if (region == null) return;
    try {
      await MapOfflineService.deleteRegion(region.id);
      if (!mounted) return;
      setState(() {
        _region = null;
        _progress = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final supported = MapOfflineService.isSupported;
    final status = !supported
        ? l10n.set_offline_map_unsupported
        : _error != null
        ? _error!
        : _downloading
        ? _progress == null
            ? l10n.set_offline_map_downloading
            : '${l10n.set_offline_map_downloading} ${(_progress! * 100).round()}%'
        : _region != null
        ? l10n.set_offline_map_downloaded
        : l10n.set_offline_map_hint;

    return Card(
      child: ListTile(
        leading: Icon(Icons.download_for_offline_outlined,
            color: AppColors.primaryInk),
        title: Text(
          l10n.set_offline_map_title,
          style: AppFonts.cairo(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Text(l10n.set_offline_map_hint, style: AppFonts.cairo(fontSize: 11)),
            if (_downloading && supported)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 4,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              status,
              style: AppFonts.cairo(
                fontSize: 11.5,
                color: _error == null ? AppColors.textSecondary : AppColors.error,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: !supported
            ? null
            : _downloading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(
                onPressed: _region == null ? _download : _delete,
                child: Text(
                  _region == null
                      ? l10n.set_offline_map_download
                      : l10n.set_offline_map_delete,
                  style: AppFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
      ),
    );
  }
}
