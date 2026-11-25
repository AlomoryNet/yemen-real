import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:yemen_real_estate_portal/data/demo_properties_generator.dart';
import 'package:yemen_real_estate_portal/features/map/services/map_cluster_service.dart';
import 'package:yemen_real_estate_portal/models/property.dart';

/// Original all-pairs implementation, kept as an oracle for the spatial-hash
/// optimisation. It is intentionally O(n²) — tests only use the 440 demo rows.
List<Set<String>> _bruteForceClusters(List<Property> properties, double zoom) {
  final radius = MapClusterService.getClusterRadiusDegrees(zoom);
  final radiusSq = radius * radius;
  final coords = properties
      .map((p) => MapClusterService.getPropertyCoordinates(p))
      .toList();
  final visited = List<bool>.filled(properties.length, false);
  final result = <Set<String>>[];

  for (var i = 0; i < properties.length; i++) {
    if (visited[i]) continue;
    visited[i] = true;
    final ids = <String>{properties[i].id};
    for (var j = i + 1; j < properties.length; j++) {
      if (visited[j]) continue;
      final dLat = coords[i].$1 - coords[j].$1;
      final dLng = coords[i].$2 - coords[j].$2;
      if ((dLat * dLat) + (dLng * dLng) <= radiusSq) {
        visited[j] = true;
        ids.add(properties[j].id);
      }
    }
    result.add(ids);
  }
  return result;
}

void main() {
  final properties = DemoPropertiesGenerator.cachedDemoProperties;

  test('spatial hash clustering matches the brute-force result', () {
    for (final zoom in <double>[6.0, 9.5, 11.0, 13.5, 15.0, 17.0]) {
      final actual = MapClusterService.clusterProperties(
        properties: properties,
        zoom: zoom,
      ).map((cluster) => cluster.properties.map((p) => p.id).toSet()).toList();

      final expected = _bruteForceClusters(properties, zoom);

      expect(
        actual.length,
        expected.length,
        reason: 'zoom $zoom cluster count',
      );
      for (final cluster in expected) {
        expect(
          actual.any(
            (ids) =>
                ids.length == cluster.length && ids.every(cluster.contains),
          ),
          isTrue,
          reason: 'zoom $zoom missing cluster ${cluster.toList()}',
        );
      }
    }
  });

  test('cluster bounds and centroid cover their members', () {
    final clusters = MapClusterService.clusterProperties(
      properties: properties.take(80).toList(),
      zoom: 11.0,
    );
    for (final cluster in clusters) {
      final coords = cluster.properties
          .map(MapClusterService.getPropertyCoordinates)
          .toList();
      expect(cluster.minLat, lessThanOrEqualTo(coords.first.$1));
      expect(cluster.maxLat, greaterThanOrEqualTo(coords.first.$1));
      expect(cluster.latSpan, lessThanOrEqualTo(1.0));
      final centroid = LatLng(
        coords.map((c) => c.$1).reduce((a, b) => a + b) / coords.length,
        coords.map((c) => c.$2).reduce((a, b) => a + b) / coords.length,
      );
      expect(
        const Distance().as(LengthUnit.Meter, cluster.centroid, centroid),
        lessThan(1),
      );
    }
    expect(
      clusters.fold<int>(0, (sum, c) => sum + c.count),
      math.min(80, properties.length),
    );
  });
}
