import 'package:latlong2/latlong.dart';

import '../../../models/map_query.dart';
import '../../../models/saved_search.dart';

/// One-time seed sent from other screens into the map/results surface.
/// The map screen copies these values into [mapQueryProvider] in `initState`;
/// after that the provider is the only source of truth.
class MapScreenArgs {
  const MapScreenArgs({
    this.initialListView = false,
    this.searchQuery,
    this.dealType,
    this.propertyTypeId,
    this.city,
    this.district,
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
    this.onlyFeatured = false,
    this.onlyExactCoordinates = false,
    this.nearbyCenter,
    this.radiusKm,
    this.source = MapQuerySource.general,
  });

  final bool initialListView;
  final String? searchQuery;
  final String? dealType;
  final String? propertyTypeId;
  final String? city;
  final String? district;
  final double? minPrice;
  final double? maxPrice;
  final int? minBedrooms;
  final bool onlyFeatured;
  final bool onlyExactCoordinates;
  final LatLng? nearbyCenter;
  final double? radiusKm;
  final MapQuerySource source;

  factory MapScreenArgs.search({
    required String searchQuery,
    String? dealType,
    String? propertyTypeId,
    String? city,
    String? district,
  }) {
    return MapScreenArgs(
      initialListView: true,
      searchQuery: searchQuery,
      dealType: dealType,
      propertyTypeId: propertyTypeId,
      city: city,
      district: district,
      source: MapQuerySource.search,
    );
  }

  factory MapScreenArgs.nearby({
    required LatLng center,
    required double radiusKm,
  }) {
    return MapScreenArgs(
      initialListView: true,
      nearbyCenter: center,
      radiusKm: radiusKm,
      source: MapQuerySource.nearby,
    );
  }

  factory MapScreenArgs.featured() {
    return MapScreenArgs(
      initialListView: true,
      onlyFeatured: true,
      source: MapQuerySource.featured,
    );
  }

  factory MapScreenArgs.category({String? dealType, String? propertyTypeId}) {
    return MapScreenArgs(
      initialListView: true,
      dealType: dealType,
      propertyTypeId: propertyTypeId,
      source: MapQuerySource.category,
    );
  }

  /// Reopens the complete filter set captured by a saved search.
  factory MapScreenArgs.fromSavedSearch(SavedSearch saved) {
    final query = saved.query;
    return MapScreenArgs(
      initialListView: true,
      searchQuery: query.freeText.isEmpty ? null : query.freeText,
      dealType: query.dealType.isEmpty ? null : query.dealType,
      propertyTypeId: query.propertyTypeId,
      city: query.governorate,
      district: query.district,
      minPrice: query.minPrice,
      maxPrice: query.maxPrice,
      minBedrooms: query.minBedrooms,
      onlyFeatured: query.onlyFeatured,
      onlyExactCoordinates: query.onlyExactCoordinates,
      nearbyCenter: query.nearbyCenter,
      radiusKm: query.radiusKm,
      source: MapQuerySource.search,
    );
  }
}
