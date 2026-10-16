class PropertyType {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? icon;
  final int sortOrder;
  final bool isActive;

  PropertyType({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.icon,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory PropertyType.fromJson(Map<String, dynamic> json) {
    return PropertyType(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String? ?? '',
      icon: json['icon'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'icon': icon,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }
}
