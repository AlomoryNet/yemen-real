import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:maplibre/maplibre.dart';

import '../core/constants/map_sources.dart';

/// Offline map storage for the MapLibre/OpenFreeMap stack.
///
/// MapLibre keeps an ambient cache of every style resource and tile the user
/// actually views. This service caps that cache and can additionally
/// pre-download a country-level Yemen pack. The pack is intentionally limited
/// to zoom 5–10: that is 1,105 tiles (~9 MB) over Yemen, safely inside
/// OpenFreeMap's public-instance limit of 3,000 tiles and 50 MB per download.
/// Higher-zoom areas the user visits are still kept in the bounded ambient
/// cache, so the offline pack stays small enough to be compliant.
class MapOfflineService {
  const MapOfflineService._();

  /// 100 MB is enough for a country pack plus several city areas on a low-end
  /// device without competing with property photos for storage.
  static const int ambientCacheBytes = 100 * 1024 * 1024;

  static const double countryMinZoom = 5;
  /// z5–10 covers Yemen in 1,105 tiles; z11 alone adds another 3,010 and would
  /// exceed OpenFreeMap's 3,000-tile offline-download limit.
  static const double countryMaxZoom = 10;

  /// Yemen including Socotra and the disputed southern islands.
  static const GeoBox yemenBounds = GeoBox(
    west: 42.5,
    east: 54.5,
    south: 12.5,
    north: 19.5,
  );

  static const String _regionName = 'Yemen';

  static bool get isSupported => OfflineManager.isSupported;

  /// Applies the ambient cache cap once at startup. Failures are logged rather
  /// than crashing the app on platforms where the native cache is unavailable.
  static Future<void> configureAmbientCache() async {
    if (!isSupported) return;
    try {
      final manager = await OfflineManager.createInstance();
      try {
        await manager.setMaximumAmbientCacheSize(bytes: ambientCacheBytes);
      } finally {
        manager.dispose();
      }
    } catch (error) {
      debugPrint('Could not configure MapLibre ambient cache: $error');
    }
  }

  static Future<List<OfflineRegion>> listRegions() async {
    if (!isSupported) return const <OfflineRegion>[];
    final manager = await OfflineManager.createInstance();
    try {
      return await manager.listOfflineRegions();
    } finally {
      manager.dispose();
    }
  }

  static OfflineRegion? yemenRegion(List<OfflineRegion> regions) {
    for (final region in regions) {
      if (region.metadata['name'] == _regionName) return region;
    }
    return null;
  }

  static Stream<DownloadProgress> downloadYemen() async* {
    if (!isSupported) {
      throw UnsupportedError('Offline maps are not supported on this platform');
    }
    final manager = await OfflineManager.createInstance();
    try {
      yield* manager.downloadRegion(
        definition: OfflineTilePyramidRegionDefinition(
          bounds: yemenBounds,
          styleUrl: AppMapSources.openFreeMapStyleUrl,
          minZoom: countryMinZoom,
          maxZoom: countryMaxZoom,
          pixelRatio: 1,
        ),
        metadata: const <String, Object?>{
          'name': _regionName,
          'source': 'OpenFreeMap',
        },
      );
    } finally {
      manager.dispose();
    }
  }

  static Future<void> deleteRegion(int regionId) async {
    if (!isSupported) return;
    final manager = await OfflineManager.createInstance();
    try {
      await manager.deleteRegion(regionId: regionId);
    } finally {
      manager.dispose();
    }
  }
}
