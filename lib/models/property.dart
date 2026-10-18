import '../core/constants/app_constants.dart';
import 'property_image.dart';
import 'property_type.dart';
import 'user_profile.dart';

class Property {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String dealType; // sale, rent
  final String propertyTypeId;
  final String? locationId;
  final String city;
  final String district;
  final String? addressDetails;
  final double? latitude;
  final double? longitude;
  final double price;
  final String currency; // YER, SAR, USD
  final double areaSqm;
  final int bedrooms;
  final int bathrooms;
  final String contactPhone;
  final String? contactWhatsapp;
  final String status; // draft, pending, published, hidden, archived, rejected
  final String publishingMode; // self_review, admin_approval
  final bool isFeatured;
  final int viewsCount;
  final bool hasOwnershipPledge;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final List<PropertyImage> images;
  final PropertyType? propertyType;
  final UserProfile? owner;

  Property({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.dealType,
    required this.propertyTypeId,
    this.locationId,
    required this.city,
    required this.district,
    this.addressDetails,
    this.latitude,
    this.longitude,
    required this.price,
    this.currency = AppConstants.currencyYer,
    required this.areaSqm,
    this.bedrooms = 0,
    this.bathrooms = 0,
    required this.contactPhone,
    this.contactWhatsapp,
    this.status = AppConstants.statusPublished,
    this.publishingMode = 'admin_approval',
    this.isFeatured = false,
    this.viewsCount = 0,
    this.hasOwnershipPledge = true,
    required this.createdAt,
    this.updatedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
    this.images = const [],
    this.propertyType,
    this.owner,
  });

  bool get isForRent => dealType == AppConstants.dealRent;
  bool get isForSale => dealType == AppConstants.dealSale;
  bool get isPublished => status == AppConstants.statusPublished;
  bool get isDraft => status == AppConstants.statusDraft;
  bool get isHidden => status == AppConstants.statusHidden;
  bool get isArchived => status == AppConstants.statusArchived;

  String? get primaryImageUrl {
    if (images.isEmpty) return null;
    final primary = images.firstWhere(
      (img) => img.isPrimary,
      orElse: () => images.first,
    );
    return primary.imageUrl;
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    List<PropertyImage> parsedImages = [];
    if (json['property_images'] != null) {
      final list = json['property_images'] as List;
      parsedImages = list
          .map((item) => PropertyImage.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    PropertyType? parsedType;
    if (json['property_types'] != null) {
      parsedType = PropertyType.fromJson(
        json['property_types'] as Map<String, dynamic>,
      );
    }

    UserProfile? parsedOwner;
    if (json['profiles'] != null) {
      parsedOwner = UserProfile.fromJson(
        json['profiles'] as Map<String, dynamic>,
      );
    }

    return Property(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dealType: json['deal_type'] as String,
      propertyTypeId: json['property_type_id'] as String,
      locationId: json['location_id'] as String?,
      city: json['city'] as String? ?? 'صنعاء',
      district: json['district'] as String? ?? '',
      addressDetails: json['address_details'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? AppConstants.currencyYer,
      areaSqm: (json['area_sqm'] as num).toDouble(),
      bedrooms: json['bedrooms'] as int? ?? 0,
      bathrooms: json['bathrooms'] as int? ?? 0,
      contactPhone: json['contact_phone'] as String? ?? '',
      contactWhatsapp: json['contact_whatsapp'] as String?,
      status: json['status'] as String? ?? AppConstants.statusPending,
      publishingMode: json['publishing_mode'] as String? ?? 'admin_approval',
      isFeatured: json['is_featured'] as bool? ?? false,
      viewsCount: json['views_count'] as int? ?? 0,
      hasOwnershipPledge: json['has_ownership_pledge'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      images: parsedImages,
      propertyType: parsedType,
      owner: parsedOwner,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'deal_type': dealType,
      'property_type_id': propertyTypeId,
      'location_id': locationId,
      'city': city,
      'district': district,
      'address_details': addressDetails,
      'latitude': latitude,
      'longitude': longitude,
      'price': price,
      'currency': currency,
      'area_sqm': areaSqm,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'contact_phone': contactPhone,
      'contact_whatsapp': contactWhatsapp,
      'status': status,
      'publishing_mode': publishingMode,
      'is_featured': isFeatured,
      'views_count': viewsCount,
      'has_ownership_pledge': hasOwnershipPledge,
      if (reviewedBy != null) 'reviewed_by': reviewedBy,
      if (reviewedAt != null) 'reviewed_at': reviewedAt!.toIso8601String(),
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
    };
  }

  Property copyWith({
    String? title,
    String? description,
    String? dealType,
    String? propertyTypeId,
    String? locationId,
    String? city,
    String? district,
    String? addressDetails,
    double? latitude,
    double? longitude,
    double? price,
    String? currency,
    double? areaSqm,
    int? bedrooms,
    int? bathrooms,
    String? contactPhone,
    String? contactWhatsapp,
    String? status,
    bool? isFeatured,
    int? viewsCount,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? rejectionReason,
    List<PropertyImage>? images,
  }) {
    return Property(
      id: id,
      ownerId: ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      dealType: dealType ?? this.dealType,
      propertyTypeId: propertyTypeId ?? this.propertyTypeId,
      locationId: locationId ?? this.locationId,
      city: city ?? this.city,
      district: district ?? this.district,
      addressDetails: addressDetails ?? this.addressDetails,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      areaSqm: areaSqm ?? this.areaSqm,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      contactPhone: contactPhone ?? this.contactPhone,
      contactWhatsapp: contactWhatsapp ?? this.contactWhatsapp,
      status: status ?? this.status,
      publishingMode: publishingMode,
      isFeatured: isFeatured ?? this.isFeatured,
      viewsCount: viewsCount ?? this.viewsCount,
      hasOwnershipPledge: hasOwnershipPledge,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      images: images ?? this.images,
      propertyType: propertyType,
      owner: owner,
    );
  }
}
