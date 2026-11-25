import 'package:latlong2/latlong.dart' as latlong;

import '../../../core/constants/app_constants.dart';
import '../../../models/property.dart';
import '../../map/services/map_cluster_service.dart';

/// Published listings within [radiusKm] of [center], nearest first.
///
/// Kept as a pure function so the dashboard's nearby section can be computed
/// once by a provider (and cached across rebuilds) instead of scanning the
/// whole demo catalogue inside `HomeScreen.build`.
List<Property> computeNearbyProperties({
  required Iterable<Property> listings,
  required latlong.LatLng center,
  required double radiusKm,
}) {
  const distance = latlong.Distance();
  final scored = <(Property, double)>[];

  for (final property in listings) {
    if (property.status != AppConstants.statusPublished) continue;
    final coords = MapClusterService.getPropertyCoordinates(property);
    final km = distance.as(
      latlong.LengthUnit.Kilometer,
      center,
      latlong.LatLng(coords.$1, coords.$2),
    );
    if (km <= radiusKm) scored.add((property, km));
  }

  scored.sort((a, b) => a.$2.compareTo(b.$2));
  return scored.map((entry) => entry.$1).toList();
}
