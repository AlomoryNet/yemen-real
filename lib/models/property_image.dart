class PropertyImage {
  final String id;
  final String propertyId;
  final String imageUrl;
  final bool isPrimary;
  final int sortOrder;

  PropertyImage({
    required this.id,
    required this.propertyId,
    required this.imageUrl,
    this.isPrimary = false,
    this.sortOrder = 0,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      imageUrl: json['image_url'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      'sort_order': sortOrder,
    };
  }
}
