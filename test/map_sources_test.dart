import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/core/constants/map_sources.dart';
import 'package:yemen_real_estate_portal/services/map_offline_service.dart';

void main() {
  test('free map sources are key-less and centralized', () {
    final style = Uri.parse(AppMapSources.openFreeMapStyleUrl);
    final satellite = Uri.parse(AppMapSources.satelliteTileUrl);

    expect(style.scheme, 'https');
    expect(style.host, 'tiles.openfreemap.org');
    expect(style.path, '/styles/liberty');
    expect(style.query, isEmpty);
    expect(style.fragment, isEmpty);

    expect(satellite.scheme, 'https');
    expect(satellite.host, 'server.arcgisonline.com');
    expect(satellite.path, contains('World_Imagery/MapServer/tile'));
    expect(
      AppMapSources.openFreeMapAttribution,
      contains('OpenStreetMap contributors'),
    );
  });

  test('offline pack covers Yemen with a bounded zoom and cache size', () {
    expect(MapOfflineService.yemenBounds.west, lessThanOrEqualTo(42.5));
    expect(MapOfflineService.yemenBounds.east, greaterThanOrEqualTo(54.5));
    expect(MapOfflineService.yemenBounds.south, lessThanOrEqualTo(12.5));
    expect(MapOfflineService.yemenBounds.north, greaterThanOrEqualTo(19.0));
    expect(MapOfflineService.countryMinZoom, 5);
    expect(MapOfflineService.countryMaxZoom, 10);
    expect(MapOfflineService.ambientCacheBytes, 100 * 1024 * 1024);
  });

  test('country pack stays inside OpenFreeMap 3,000-tile offline limit', () {
    const bounds = MapOfflineService.yemenBounds;
    var tiles = 0;
    for (
      var zoom = MapOfflineService.countryMinZoom.toInt();
      zoom <= MapOfflineService.countryMaxZoom;
      zoom++
    ) {
      final scale = math.pow(2, zoom).toDouble();
      final westX = ((bounds.west + 180) / 360 * scale).floor();
      final eastX = ((bounds.east + 180) / 360 * scale).floor();
      tiles += (eastX - westX + 1) * (northTileY(bounds.north, scale) -
              southTileY(bounds.south, scale) +
              1);
    }
    expect(tiles, lessThanOrEqualTo(3000));
  });
}

int northTileY(double latitude, double scale) {
  final radians = latitude * math.pi / 180;
  return ((1 -
          math.log(math.tan(radians) + 1 / math.cos(radians)) / math.pi) /
      2 *
      scale)
      .floor();
}

int southTileY(double latitude, double scale) {
  final radians = latitude * math.pi / 180;
  return ((1 -
          math.log(math.tan(radians) + 1 / math.cos(radians)) / math.pi) /
      2 *
      scale)
      .ceil();
}
