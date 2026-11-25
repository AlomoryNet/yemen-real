import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../core/constants/app_constants.dart';
import '../features/map/services/map_cluster_service.dart';
import '../models/map_query.dart';
import '../models/property.dart';
import '../models/property_filter_selection.dart';

/// Owns the committed map/results query. Every entry point (dashboard seed,
/// sheet Apply/Reset, chip removal, search submit) writes here; the screen only
/// renders what this provider says.
class MapQueryNotifier extends StateNotifier<MapQuery> {
  MapQueryNotifier([MapQuery? initialQuery]) : super(initialQuery ?? const MapQuery());

  void seed(MapQuery query) => state = query;

  void update(MapQuery Function(MapQuery current) change) {
    final next = change(state);
    if (next != state) state = next;
  }

  void setFreeText(String text) {
    if (state.freeText == text) return;
    state = state.copyWith(freeText: text);
  }

  void setView(MapViewMode view) {
    if (state.view == view) return;
    state = state.copyWith(view: view);
  }

  void applySelection(PropertyFilterSelection selection) {
    state = state.applySelection(selection);
  }

  void resetFilters() => state = state.resetFilters();
}

final mapQueryProvider =
    StateNotifierProvider<MapQueryNotifier, MapQuery>((_) => MapQueryNotifier());

/// Pure filter used by the map, its tests and any future results surface.
/// [drawnPolygon] stays outside [MapQuery] because it changes on every pointer
/// move while drawing and is not a committed filter.
List<Property> filterMapProperties({
  required Iterable<Property> listings,
  required MapQuery query,
  List<latlong.LatLng> drawnPolygon = const <latlong.LatLng>[],
}) {
  final text = query.freeText.trim().toLowerCase();
  const distance = latlong.Distance();

  return listings.where((property) {
    if (property.status != AppConstants.statusPublished) return false;

    if (query.onlyFeatured && !property.isFeatured) return false;

    if (query.dealType.isNotEmpty && property.dealType != query.dealType) {
      return false;
    }

    if (query.propertyTypeId != null &&
        query.propertyTypeId!.isNotEmpty &&
        property.propertyTypeId != query.propertyTypeId) {
      return false;
    }

    // Sana'a City and Sana'a Governorate are one area in the source data.
    if (!AppConstants.governorateMatches(query.governorate, property.city)) {
      return false;
    }

    if (query.district != null && query.district!.isNotEmpty) {
      final district = query.district!;
      if (property.district != district &&
          !property.district.contains(district) &&
          !district.contains(property.district)) {
        return false;
      }
    }

    if (text.isNotEmpty) {
      final inCity = property.city.toLowerCase().contains(text);
      final inDistrict = property.district.toLowerCase().contains(text);
      final inTitle = property.title.toLowerCase().contains(text);
      final inAddress =
          (property.addressDetails ?? '').toLowerCase().contains(text);
      if (!inCity && !inDistrict && !inTitle && !inAddress) return false;
    }

    if (query.minPrice != null && property.price < query.minPrice!) {
      return false;
    }
    if (query.maxPrice != null && property.price > query.maxPrice!) {
      return false;
    }
    if (query.minBedrooms != null && property.bedrooms < query.minBedrooms!) {
      return false;
    }
    if (query.onlyExactCoordinates &&
        !MapClusterService.hasExactCoordinates(property)) {
      return false;
    }

    if (query.nearbyCenter != null && query.radiusKm != null) {
      final coords = MapClusterService.getPropertyCoordinates(property);
      final km = distance.as(
        latlong.LengthUnit.Kilometer,
        query.nearbyCenter!,
        latlong.LatLng(coords.$1, coords.$2),
      );
      if (km > query.radiusKm!) return false;
    }

    if (drawnPolygon.length > 2) {
      final coords = MapClusterService.getPropertyCoordinates(property);
      if (!_isPointInPolygon(
        latlong.LatLng(coords.$1, coords.$2),
        drawnPolygon,
      )) {
        return false;
      }
    }

    return true;
  }).toList();
}

bool _isPointInPolygon(latlong.LatLng point, List<latlong.LatLng> polygon) {
  var inside = false;
  var previous = polygon.length - 1;
  for (var i = 0; i < polygon.length; i++) {
    final xi = polygon[i].latitude;
    final yi = polygon[i].longitude;
    final xj = polygon[previous].latitude;
    final yj = polygon[previous].longitude;
    final intersects = ((yi > point.longitude) != (yj > point.longitude)) &&
        (point.latitude <
            (xj - xi) * (point.longitude - yi) / (yj - yi) + xi);
    if (intersects) inside = !inside;
    previous = i;
  }
  return inside;
}
