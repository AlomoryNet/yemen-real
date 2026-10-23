import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/property.dart';

/// Represents a clustered group of properties or a single property marker on the map.
class PropertyCluster {
  final LatLng centroid;
  final List<Property> properties;
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  PropertyCluster({
    required this.centroid,
    required this.properties,
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });

  bool get isSingle => properties.length == 1;
  Property get singleProperty => properties.first;
  int get count => properties.length;

  /// Bounding box span
  double get latSpan => (maxLat - minLat).abs();
  double get lngSpan => (maxLng - minLng).abs();
}

/// High-performance spatial clustering engine for Yemen Real Estate Portal
class MapClusterService {
  /// Gets exact coordinates for a property or provides deterministic district fallback
  static (double, double) getPropertyCoordinates(Property prop) {
    if (prop.latitude != null &&
        prop.longitude != null &&
        prop.latitude != 0.0 &&
        prop.longitude != 0.0) {
      return (prop.latitude!, prop.longitude!);
    }

    // Deterministic fallback based on governorate / city and property hash
    final base = AppConstants.getCoordinatesForGovernorate(prop.city);
    final hash = prop.id.hashCode.abs();
    final latOffset = ((hash % 100) - 50) * 0.0003;
    final lngOffset = (((hash ~/ 100) % 100) - 50) * 0.0003;
    return (base.$1 + latOffset, base.$2 + lngOffset);
  }

  /// Checks if a property has genuine GPS coordinates
  static bool hasExactCoordinates(Property prop) {
    return prop.latitude != null &&
        prop.longitude != null &&
        prop.latitude != 0.0 &&
        prop.longitude != 0.0;
  }

  /// Calculates dynamic clustering radius in degrees based on zoom level and screen density
  static double getClusterRadiusDegrees(double zoom) {
    if (zoom < 8.0) {
      return 0.75; // Regional governorate scale
    } else if (zoom < 10.0) {
      return 0.35;
    } else if (zoom < 11.5) {
      return 0.16;
    } else if (zoom < 13.0) {
      return 0.06;
    } else if (zoom < 14.5) {
      return 0.018;
    } else if (zoom < 16.0) {
      return 0.004; // Neighborhood scale
    } else {
      return 0.0006; // Building scale: only identical or nearly identical points group together
    }
  }

  /// Clusters a list of properties according to the current map zoom
  static List<PropertyCluster> clusterProperties({
    required List<Property> properties,
    required double zoom,
  }) {
    if (properties.isEmpty) return const [];

    final radiusDeg = getClusterRadiusDegrees(zoom);
    final radiusSq = radiusDeg * radiusDeg;

    final List<PropertyCluster> clusters = [];
    final List<bool> visited = List.filled(properties.length, false);

    // Pre-extract coordinates for fast distance calculation
    final coords = List<LatLng>.generate(properties.length, (i) {
      final pair = getPropertyCoordinates(properties[i]);
      return LatLng(pair.$1, pair.$2);
    });

    for (int i = 0; i < properties.length; i++) {
      if (visited[i]) continue;

      visited[i] = true;
      final clusterProperties = <Property>[properties[i]];
      double sumLat = coords[i].latitude;
      double sumLng = coords[i].longitude;
      double minLat = coords[i].latitude;
      double maxLat = coords[i].latitude;
      double minLng = coords[i].longitude;
      double maxLng = coords[i].longitude;

      // Group nearby properties into the cluster
      for (int j = i + 1; j < properties.length; j++) {
        if (visited[j]) continue;

        final dLat = coords[i].latitude - coords[j].latitude;
        final dLng = coords[i].longitude - coords[j].longitude;
        final distSq = (dLat * dLat) + (dLng * dLng);

        if (distSq <= radiusSq) {
          visited[j] = true;
          clusterProperties.add(properties[j]);
          sumLat += coords[j].latitude;
          sumLng += coords[j].longitude;

          minLat = math.min(minLat, coords[j].latitude);
          maxLat = math.max(maxLat, coords[j].latitude);
          minLng = math.min(minLng, coords[j].longitude);
          maxLng = math.max(maxLng, coords[j].longitude);
        }
      }

      final count = clusterProperties.length;
      final centroid = LatLng(sumLat / count, sumLng / count);

      clusters.add(PropertyCluster(
        centroid: centroid,
        properties: clusterProperties,
        minLat: minLat,
        maxLat: maxLat,
        minLng: minLng,
        maxLng: maxLng,
      ));
    }

    return clusters;
  }
}
