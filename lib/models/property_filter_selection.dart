/// Filter values returned by the shared property filter sheet.
///
/// `dealType` is `''` for "all". `governorate`, `district` and `typeId` use
/// `null` for "all". Advanced price/bedroom/GPS fields are ignored by callers
/// that open the sheet without advanced filters.
class PropertyFilterSelection {
  const PropertyFilterSelection({
    this.dealType = '',
    this.typeId,
    this.governorate,
    this.district,
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
    this.onlyExactCoordinates = false,
  });

  final String dealType;
  final String? typeId;
  final String? governorate;
  final String? district;
  final double? minPrice;
  final double? maxPrice;
  final int? minBedrooms;
  final bool onlyExactCoordinates;

  int get activeCount {
    var count = 0;
    if (dealType.isNotEmpty) count++;
    if (typeId != null) count++;
    if (governorate != null && governorate!.isNotEmpty) count++;
    if (district != null && district!.isNotEmpty) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (minBedrooms != null) count++;
    if (onlyExactCoordinates) count++;
    return count;
  }
}
