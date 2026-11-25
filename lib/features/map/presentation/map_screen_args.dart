/// Options forwarded by the dashboard when it opens the map/list screen.
/// The map screen owns its filter state, so the incoming values are used as
/// a one-time seed (no global filter provider is required).
class MapScreenArgs {
  final bool initialListView;
  final String? searchQuery;
  final String? dealType;
  final String? propertyTypeId;
  final String? city;
  final String? district;

  const MapScreenArgs({
    this.initialListView = false,
    this.searchQuery,
    this.dealType,
    this.propertyTypeId,
    this.city,
    this.district,
  });
}
