import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../models/property.dart';
import '../repositories/property_repository.dart';

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  return PropertyRepository();
});

// Search and Filter State
class PropertyFilterState {
  final String? dealType;
  final String? propertyTypeId;
  final String? city;
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final double? minArea;
  final double? maxArea;
  final int? bedrooms;
  final String sortBy;

  PropertyFilterState({
    this.dealType,
    this.propertyTypeId,
    this.city,
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
    this.minArea,
    this.maxArea,
    this.bedrooms,
    this.sortBy = 'newest',
  });

  PropertyFilterState copyWith({
    String? dealType,
    String? propertyTypeId,
    String? city,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    int? bedrooms,
    String? sortBy,
    bool clearDealType = false,
    bool clearPropertyType = false,
    bool clearCity = false,
  }) {
    return PropertyFilterState(
      dealType: clearDealType ? null : (dealType ?? this.dealType),
      propertyTypeId: clearPropertyType
          ? null
          : (propertyTypeId ?? this.propertyTypeId),
      city: clearCity ? null : (city ?? this.city),
      searchQuery: searchQuery ?? this.searchQuery,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      bedrooms: bedrooms ?? this.bedrooms,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  void reset() {}
}

class PropertyFilterNotifier extends StateNotifier<PropertyFilterState> {
  PropertyFilterNotifier() : super(PropertyFilterState());

  void setDealType(String? dealType) {
    state = state.copyWith(
      dealType: dealType,
      clearDealType: dealType == null || dealType.isEmpty,
    );
  }

  void setPropertyType(String? typeId) {
    state = state.copyWith(
      propertyTypeId: typeId,
      clearPropertyType: typeId == null || typeId.isEmpty,
    );
  }

  void setCity(String? city) {
    state = state.copyWith(city: city, clearCity: city == null || city.isEmpty);
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  void setPriceRange(double? min, double? max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
  }

  void setAreaRange(double? min, double? max) {
    state = state.copyWith(minArea: min, maxArea: max);
  }

  void setBedrooms(int? count) {
    state = state.copyWith(bedrooms: count);
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void resetFilters() {
    state = PropertyFilterState();
  }
}

final propertyFilterProvider =
    StateNotifierProvider<PropertyFilterNotifier, PropertyFilterState>((ref) {
      return PropertyFilterNotifier();
    });

// Featured Properties Provider
final featuredPropertiesProvider = FutureProvider<List<Property>>((ref) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return await repo.getProperties(onlyFeatured: true, limit: 10);
});

// Latest Properties for Sale
final propertiesForSaleProvider = FutureProvider<List<Property>>((ref) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return await repo.getProperties(dealType: AppConstants.dealSale, limit: 10);
});

// Latest Properties for Rent
final propertiesForRentProvider = FutureProvider<List<Property>>((ref) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return await repo.getProperties(dealType: AppConstants.dealRent, limit: 10);
});

// Pending Properties Awaiting Admin Review Provider
final pendingPropertiesProvider = FutureProvider<List<Property>>((ref) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return await repo.getPendingProperties();
});

// All Properties for Yemen Map View
final allMapPropertiesProvider = FutureProvider<List<Property>>((ref) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return await repo.getProperties(limit: 1000);
});

// Filtered Search Results Provider
final searchPropertiesProvider = FutureProvider<List<Property>>((ref) async {
  final repo = ref.watch(propertyRepositoryProvider);
  final filter = ref.watch(propertyFilterProvider);

  return await repo.getProperties(
    dealType: filter.dealType,
    propertyTypeId: filter.propertyTypeId,
    city: filter.city,
    searchQuery: filter.searchQuery,
    minPrice: filter.minPrice,
    maxPrice: filter.maxPrice,
    minArea: filter.minArea,
    maxArea: filter.maxArea,
    bedrooms: filter.bedrooms,
    sortBy: filter.sortBy,
    limit: 50,
  );
});

// Single Property Detail Provider
final propertyDetailProvider = FutureProvider.family<Property, String>((
  ref,
  id,
) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return await repo.getPropertyById(id);
});

// User Properties Provider
final userPropertiesProvider = FutureProvider.family<List<Property>, String>((
  ref,
  userId,
) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return await repo.getUserProperties(userId);
});
