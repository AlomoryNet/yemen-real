import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/property_filter_selection.dart';

/// Dashboard hero filter state: the user's pending search selections before
/// they are submitted to the map/list screen.
class DashboardFilterState {
  const DashboardFilterState({
    this.searchQuery = '',
    this.dealType = '',
    this.typeId,
    this.governorate,
    this.district,
  });

  final String searchQuery;
  final String dealType;
  final String? typeId;
  final String? governorate;
  final String? district;

  int get activeFilterCount {
    var count = 0;
    if (dealType.isNotEmpty) count++;
    if (typeId != null) count++;
    if (governorate != null && governorate!.isNotEmpty) count++;
    if (district != null && district!.isNotEmpty) count++;
    return count;
  }
}

/// Owns the dashboard filter fields and the hero's search text controller.
///
/// The controller lives here (rather than in the screen's State) so the whole
/// dashboard filter concern can be watched from any widget and survives the
/// screen being rebuilt. It is disposed when the provider container is
/// disposed.
class DashboardFilterNotifier extends StateNotifier<DashboardFilterState> {
  DashboardFilterNotifier() : super(const DashboardFilterState());

  final TextEditingController searchController = TextEditingController();

  void setSearchQuery(String query) {
    state = DashboardFilterState(
      searchQuery: query,
      dealType: state.dealType,
      typeId: state.typeId,
      governorate: state.governorate,
      district: state.district,
    );
  }

  void setDealType(String dealType) {
    state = DashboardFilterState(
      searchQuery: state.searchQuery,
      dealType: dealType,
      typeId: state.typeId,
      governorate: state.governorate,
      district: state.district,
    );
  }

  void setTypeId(String? typeId) {
    state = DashboardFilterState(
      searchQuery: state.searchQuery,
      dealType: state.dealType,
      typeId: typeId,
      governorate: state.governorate,
      district: state.district,
    );
  }

  void setGovernorate(String? governorate) {
    state = DashboardFilterState(
      searchQuery: state.searchQuery,
      dealType: state.dealType,
      typeId: state.typeId,
      governorate: governorate,
      district: state.district,
    );
  }

  void setDistrict(String? district) {
    state = DashboardFilterState(
      searchQuery: state.searchQuery,
      dealType: state.dealType,
      typeId: state.typeId,
      governorate: state.governorate,
      district: district,
    );
  }

  void applySelection(PropertyFilterSelection selection) {
    state = DashboardFilterState(
      searchQuery: state.searchQuery,
      dealType: selection.dealType,
      typeId: selection.typeId,
      governorate: selection.governorate,
      district: selection.district,
    );
  }

  void reset() {
    searchController.clear();
    state = const DashboardFilterState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

final dashboardFilterProvider =
    StateNotifierProvider<DashboardFilterNotifier, DashboardFilterState>((ref) {
  final notifier = DashboardFilterNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});
