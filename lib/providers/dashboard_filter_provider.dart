import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dashboard hero filter state: the user's pending search selections before
/// they are submitted to [propertyFilterProvider] and opened as results.
class DashboardFilterState {
  const DashboardFilterState({
    this.searchQuery = '',
    this.dealType = '',
    this.typeId,
    this.governorate,
  });

  final String searchQuery;
  final String dealType;
  final String? typeId;
  final String? governorate;
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
    );
  }

  void setDealType(String dealType) {
    state = DashboardFilterState(
      searchQuery: state.searchQuery,
      dealType: dealType,
      typeId: state.typeId,
      governorate: state.governorate,
    );
  }

  void setTypeId(String? typeId) {
    state = DashboardFilterState(
      searchQuery: state.searchQuery,
      dealType: state.dealType,
      typeId: typeId,
      governorate: state.governorate,
    );
  }

  void setGovernorate(String? governorate) {
    state = DashboardFilterState(
      searchQuery: state.searchQuery,
      dealType: state.dealType,
      typeId: state.typeId,
      governorate: governorate,
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
