import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../models/property.dart';
import '../models/user_property_stats.dart';
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

// True totals for the dashboard section headers. The preview providers above
// cap their lists at 10, so the header must not use preview.length as the count.
final featuredCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return await repo.getPropertyCount(onlyFeatured: true);
});

final propertiesForSaleCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return await repo.getPropertyCount(dealType: AppConstants.dealSale);
});

final propertiesForRentCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return await repo.getPropertyCount(dealType: AppConstants.dealRent);
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

// User Properties Provider (full list, kept for small/cache-only callers)
final userPropertiesProvider = FutureProvider.family<List<Property>, String>((
  ref,
  userId,
) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return await repo.getUserProperties(userId);
});

/// One paged slice of the owner's listings plus lightweight totals.
class UserPropertiesPage {
  const UserPropertiesPage({
    required this.properties,
    required this.stats,
    this.isLoadingMore = false,
  });

  final List<Property> properties;
  final UserPropertyStats stats;
  final bool isLoadingMore;

  bool get hasMore => properties.length < stats.total;

  UserPropertiesPage copyWith({
    List<Property>? properties,
    UserPropertyStats? stats,
    bool? isLoadingMore,
  }) {
    return UserPropertiesPage(
      properties: properties ?? this.properties,
      stats: stats ?? this.stats,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Incrementally loads the signed-in owner's properties, 12 at a time.
class UserPropertiesPaginator
    extends StateNotifier<AsyncValue<UserPropertiesPage>> {
  UserPropertiesPaginator(this._ref, this._userId)
    : super(const AsyncValue.loading()) {
    loadFirstPage();
  }

  static const int pageSize = 12;

  final Ref _ref;
  final String _userId;

  Future<void> loadFirstPage() async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(propertyRepositoryProvider);
      final pageFuture = repo.getUserProperties(
        _userId,
        limit: pageSize,
        offset: 0,
      );
      final statsFuture = repo.getUserPropertyStats(_userId);
      final page = await pageFuture;
      final stats = await statsFuture;
      state = AsyncValue.data(
        UserPropertiesPage(properties: page, stats: stats),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    try {
      final repo = _ref.read(propertyRepositoryProvider);
      final next = await repo.getUserProperties(
        _userId,
        limit: pageSize,
        offset: current.properties.length,
      );
      state = AsyncValue.data(
        current.copyWith(
          properties: [...current.properties, ...next],
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final userPropertiesPaginatorProvider =
    StateNotifierProvider.family<
      UserPropertiesPaginator,
      AsyncValue<UserPropertiesPage>,
      String
    >((ref, userId) => UserPropertiesPaginator(ref, userId));
