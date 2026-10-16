class LocationItem {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? parentId;
  final double? latitude;
  final double? longitude;
  final int sortOrder;
  final bool isActive;

  LocationItem({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.parentId,
    this.latitude,
    this.longitude,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory LocationItem.fromJson(Map<String, dynamic> json) {
    return LocationItem(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String? ?? '',
      parentId: json['parent_id'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'parent_id': parentId,
      'latitude': latitude,
      'longitude': longitude,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }
}
