import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import 'property_filter_selection.dart';

/// Where a map/results request came from. Kept for titles/analytics only —
/// the actual filtering always lives in [MapQuery].
enum MapQuerySource { general, search, nearby, featured, category }

enum MapViewMode { map, list }

const Object _unset = Object();

/// Immutable, single source of truth for the map/results surface.
///
/// The search field owns [freeText]; the governorate is a separate filter chip.
/// Nothing writes a governorate display label into [freeText], which removes the
/// stale-label class of bugs that used to empty the results after Reset.
@immutable
class MapQuery {
  const MapQuery({
    this.freeText = '',
    this.dealType = '',
    this.propertyTypeId,
    this.governorate,
    this.district,
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
    this.onlyFeatured = false,
    this.onlyExactCoordinates = false,
    this.nearbyCenter,
    this.radiusKm,
    this.view = MapViewMode.map,
    this.source = MapQuerySource.general,
  });

  final String freeText;
  final String dealType;
  final String? propertyTypeId;
  final String? governorate;
  final String? district;
  final double? minPrice;
  final double? maxPrice;
  final int? minBedrooms;
  final bool onlyFeatured;
  final bool onlyExactCoordinates;
  final LatLng? nearbyCenter;
  final double? radiusKm;
  final MapViewMode view;
  final MapQuerySource source;

  MapQuery copyWith({
    String? freeText,
    String? dealType,
    Object? propertyTypeId = _unset,
    Object? governorate = _unset,
    Object? district = _unset,
    Object? minPrice = _unset,
    Object? maxPrice = _unset,
    Object? minBedrooms = _unset,
    bool? onlyFeatured,
    bool? onlyExactCoordinates,
    Object? nearbyCenter = _unset,
    Object? radiusKm = _unset,
    MapViewMode? view,
    MapQuerySource? source,
  }) {
    return MapQuery(
      freeText: freeText ?? this.freeText,
      dealType: dealType ?? this.dealType,
      propertyTypeId: identical(propertyTypeId, _unset)
          ? this.propertyTypeId
          : propertyTypeId as String?,
      governorate: identical(governorate, _unset)
          ? this.governorate
          : governorate as String?,
      district: identical(district, _unset)
          ? this.district
          : district as String?,
      minPrice: identical(minPrice, _unset) ? this.minPrice : minPrice as double?,
      maxPrice: identical(maxPrice, _unset) ? this.maxPrice : maxPrice as double?,
      minBedrooms: identical(minBedrooms, _unset)
          ? this.minBedrooms
          : minBedrooms as int?,
      onlyFeatured: onlyFeatured ?? this.onlyFeatured,
      onlyExactCoordinates: onlyExactCoordinates ?? this.onlyExactCoordinates,
      nearbyCenter: identical(nearbyCenter, _unset)
          ? this.nearbyCenter
          : nearbyCenter as LatLng?,
      radiusKm: identical(radiusKm, _unset)
          ? this.radiusKm
          : radiusKm as double?,
      view: view ?? this.view,
      source: source ?? this.source,
    );
  }

  PropertyFilterSelection get toSelection => PropertyFilterSelection(
        dealType: dealType,
        typeId: propertyTypeId,
        governorate: governorate,
        district: district,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minBedrooms: minBedrooms,
        onlyExactCoordinates: onlyExactCoordinates,
      );

  MapQuery applySelection(PropertyFilterSelection selection) => copyWith(
        dealType: selection.dealType,
        propertyTypeId: selection.typeId,
        governorate: selection.governorate,
        district: selection.district,
        minPrice: selection.minPrice,
        maxPrice: selection.maxPrice,
        minBedrooms: selection.minBedrooms,
        onlyExactCoordinates: selection.onlyExactCoordinates,
      );

  /// Reset clears every filter, including dashboard presets (featured/nearby).
  /// The current view and origin are presentation context, not filters.
  MapQuery resetFilters() => MapQuery(view: view, source: source);

  bool get hasActiveFilters =>
      freeText.trim().isNotEmpty ||
      dealType.isNotEmpty ||
      propertyTypeId != null ||
      governorate != null ||
      district != null ||
      minPrice != null ||
      maxPrice != null ||
      minBedrooms != null ||
      onlyFeatured ||
      onlyExactCoordinates ||
      nearbyCenter != null ||
      radiusKm != null;

  /// Stable key used to reset list pagination when the result set changes.
  String get filterKey => [
        freeText.trim(),
        dealType,
        propertyTypeId ?? '',
        governorate ?? '',
        district ?? '',
        minPrice?.toStringAsFixed(2) ?? '',
        maxPrice?.toStringAsFixed(2) ?? '',
        minBedrooms?.toString() ?? '',
        onlyFeatured ? '1' : '0',
        onlyExactCoordinates ? '1' : '0',
        nearbyCenter == null
            ? ''
            : '${nearbyCenter!.latitude.toStringAsFixed(4)},'
                '${nearbyCenter!.longitude.toStringAsFixed(4)}',
        radiusKm?.toStringAsFixed(2) ?? '',
      ].join('|');

  /// Camera should reframe on every filter change except pure free-text typing
  /// (which is committed on submit) and view/source-only changes.
  String get cameraKey => copyWith(freeText: '').filterKey;

  bool sameFiltersAs(MapQuery other) => filterKey == other.filterKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MapQuery &&
          other.filterKey == filterKey &&
          other.view == view &&
          other.source == source);

  @override
  int get hashCode => Object.hash(filterKey, view, source);
}
