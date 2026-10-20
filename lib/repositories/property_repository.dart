import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exception.dart';
import '../models/property.dart';
import '../models/property_image.dart';
import '../models/property_type.dart';
import '../services/supabase_service.dart';

class PropertyRepository {
  final SupabaseClient? _client = SupabaseService.client;

  /// Fetch properties with multi-criteria filtering, sorting, and pagination
  Future<List<Property>> getProperties({
    String? dealType,
    String? propertyTypeId,
    String? city,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    int? bedrooms,
    String sortBy = 'newest', // newest, price_asc, price_desc
    int limit = 20,
    int offset = 0,
    bool onlyFeatured = false,
  }) async {
    if (EnvConfig.isDemoMode || _client == null) {
      var list = List<Property>.from(SupabaseService.demoProperties);

      // Status check (only published for public)
      list = list
          .where((p) => p.status == AppConstants.statusPublished)
          .toList();

      if (onlyFeatured) {
        list = list.where((p) => p.isFeatured).toList();
      }
      if (dealType != null && dealType.isNotEmpty) {
        list = list.where((p) => p.dealType == dealType).toList();
      }
      if (propertyTypeId != null && propertyTypeId.isNotEmpty) {
        list = list.where((p) => p.propertyTypeId == propertyTypeId).toList();
      }
      if (city != null && city.isNotEmpty) {
        list = list
            .where((p) => p.city.contains(city) || p.district.contains(city))
            .toList();
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        list = list
            .where(
              (p) =>
                  p.title.toLowerCase().contains(q) ||
                  p.description.toLowerCase().contains(q) ||
                  p.district.toLowerCase().contains(q),
            )
            .toList();
      }
      if (minPrice != null) {
        list = list.where((p) => p.price >= minPrice).toList();
      }
      if (maxPrice != null) {
        list = list.where((p) => p.price <= maxPrice).toList();
      }
      if (minArea != null) {
        list = list.where((p) => p.areaSqm >= minArea).toList();
      }
      if (maxArea != null) {
        list = list.where((p) => p.areaSqm <= maxArea).toList();
      }
      if (bedrooms != null && bedrooms > 0) {
        list = list.where((p) => p.bedrooms >= bedrooms).toList();
      }

      // Sort
      if (sortBy == 'price_asc') {
        list.sort((a, b) => a.price.compareTo(b.price));
      } else if (sortBy == 'price_desc') {
        list.sort((a, b) => b.price.compareTo(a.price));
      } else {
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      final start = offset < list.length ? offset : list.length;
      final end = (start + limit) < list.length ? (start + limit) : list.length;
      return list.sublist(start, end);
    }

    try {
      var query = _client.from('properties').select('''
            *,
            property_images (*),
            property_types (*),
            profiles (*)
          ''');

      query = query.eq('status', AppConstants.statusPublished);

      if (onlyFeatured) {
        query = query.eq('is_featured', true);
      }
      if (dealType != null && dealType.isNotEmpty) {
        query = query.eq('deal_type', dealType);
      }
      if (propertyTypeId != null && propertyTypeId.isNotEmpty) {
        query = query.eq('property_type_id', propertyTypeId);
      }
      if (city != null && city.isNotEmpty) {
        query = query.ilike('city', '%$city%');
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        query = query.or(
          'title.ilike.%$searchQuery%,description.ilike.%$searchQuery%,district.ilike.%$searchQuery%',
        );
      }
      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }
      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }
      if (minArea != null) {
        query = query.gte('area_sqm', minArea);
      }
      if (maxArea != null) {
        query = query.lte('area_sqm', maxArea);
      }
      if (bedrooms != null && bedrooms > 0) {
        query = query.gte('bedrooms', bedrooms);
      }

      // Sort & Range
      PostgrestTransformBuilder<PostgrestList> transformQuery;
      if (sortBy == 'price_asc') {
        transformQuery = query.order('price', ascending: true);
      } else if (sortBy == 'price_desc') {
        transformQuery = query.order('price', ascending: false);
      } else {
        transformQuery = query.order('created_at', ascending: false);
      }

      final data = await transformQuery.range(offset, offset + limit - 1);
      return data.map((item) => Property.fromJson(item)).toList();
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Get property details by ID
  Future<Property> getPropertyById(String id) async {
    if (EnvConfig.isDemoMode || _client == null) {
      final prop = SupabaseService.demoProperties.firstWhere(
        (p) => p.id == id,
        orElse: () => throw AppException('العقار غير موجود'),
      );
      return prop;
    }

    try {
      final data = await _client
          .from('properties')
          .select('''
            *,
            property_images (*),
            property_types (*),
            profiles (*)
          ''')
          .eq('id', id)
          .single();

      // Increment view count in background
      _client
          .rpc('increment_property_views', params: {'prop_id': id})
          .catchError((_) {});

      return Property.fromJson(data);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Create new property (Self review flow)
  Future<Property> createProperty({
    required Property property,
    required List<String> imageUrls,
  }) async {
    if (EnvConfig.isDemoMode || _client == null) {
      final newId = 'prop-${DateTime.now().millisecondsSinceEpoch}';
      final images = imageUrls.asMap().entries.map((entry) {
        return PropertyImage(
          id: 'img-${entry.key}-${DateTime.now().millisecondsSinceEpoch}',
          propertyId: newId,
          imageUrl: entry.value,
          isPrimary: entry.key == 0,
          sortOrder: entry.key,
        );
      }).toList();

      final created = Property(
        id: newId,
        ownerId: property.ownerId,
        title: property.title,
        description: property.description,
        dealType: property.dealType,
        propertyTypeId: property.propertyTypeId,
        locationId: property.locationId,
        city: property.city,
        district: property.district,
        addressDetails: property.addressDetails,
        latitude: property.latitude,
        longitude: property.longitude,
        price: property.price,
        currency: property.currency,
        areaSqm: property.areaSqm,
        bedrooms: property.bedrooms,
        bathrooms: property.bathrooms,
        contactPhone: property.contactPhone,
        contactWhatsapp: property.contactWhatsapp,
        status: property.status,
        publishingMode: 'self_review',
        isFeatured: false,
        viewsCount: 0,
        hasOwnershipPledge: true,
        createdAt: DateTime.now(),
        images: images,
        propertyType: SupabaseService.demoPropertyTypes.firstWhere(
          (t) => t.id == property.propertyTypeId,
          orElse: () => PropertyType(
            id: property.propertyTypeId,
            nameAr: 'عقار',
            nameEn: 'Property',
          ),
        ),
      );

      SupabaseService.demoProperties.insert(0, created);
      return created;
    }

    try {
      final propertyData = property.toJson();
      propertyData.remove('id'); // let PostgreSQL generate UUID
      // Remove nested objects that don't belong in the properties table
      propertyData.remove('property_images');
      propertyData.remove('property_types');
      propertyData.remove('profiles');

      final inserted = await _client
          .from('properties')
          .insert(propertyData)
          .select()
          .single();

      final newPropertyId = inserted['id'] as String;

      // Insert images
      if (imageUrls.isNotEmpty) {
        final imageRows = imageUrls.asMap().entries.map((entry) {
          return {
            'property_id': newPropertyId,
            'image_url': entry.value,
            'is_primary': entry.key == 0,
            'sort_order': entry.key,
          };
        }).toList();

        await _client.from('property_images').insert(imageRows);
      }

      return await getPropertyById(newPropertyId);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Update existing property
  Future<Property> updateProperty(Property property) async {
    if (EnvConfig.isDemoMode || _client == null) {
      final idx = SupabaseService.demoProperties.indexWhere(
        (p) => p.id == property.id,
      );
      if (idx != -1) {
        SupabaseService.demoProperties[idx] = property;
      }
      return property;
    }

    try {
      // Build update payload — exclude id (PK), nested relations, and read-only audit fields
      final payload = {
        'owner_id': property.ownerId,
        'title': property.title,
        'description': property.description,
        'deal_type': property.dealType,
        'property_type_id': property.propertyTypeId,
        'location_id': property.locationId,
        'city': property.city,
        'district': property.district,
        'address_details': property.addressDetails,
        'latitude': property.latitude,
        'longitude': property.longitude,
        'price': property.price,
        'currency': property.currency,
        'area_sqm': property.areaSqm,
        'bedrooms': property.bedrooms,
        'bathrooms': property.bathrooms,
        'contact_phone': property.contactPhone,
        'contact_whatsapp': property.contactWhatsapp,
        'status': property.status,
        'publishing_mode': property.publishingMode,
        'is_featured': property.isFeatured,
        'has_ownership_pledge': property.hasOwnershipPledge,
      };

      await _client
          .from('properties')
          .update(payload)
          .eq('id', property.id);

      return await getPropertyById(property.id);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Update status only (published, hidden, archived, pending, rejected)
  Future<void> updatePropertyStatus(String id, String newStatus) async {
    if (EnvConfig.isDemoMode || _client == null) {
      final idx = SupabaseService.demoProperties.indexWhere((p) => p.id == id);
      if (idx != -1) {
        final current = SupabaseService.demoProperties[idx];
        SupabaseService.demoProperties[idx] = current.copyWith(
          status: newStatus,
        );
      }
      return;
    }

    try {
      await _client
          .from('properties')
          .update({'status': newStatus})
          .eq('id', id);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Get all properties awaiting admin approval (status = 'pending')
  Future<List<Property>> getPendingProperties() async {
    if (EnvConfig.isDemoMode || _client == null) {
      return SupabaseService.demoProperties
          .where((p) => p.status == AppConstants.statusPending)
          .toList();
    }

    try {
      final data = await _client
          .from('properties')
          .select('''
            *,
            property_images (*),
            property_types (*),
            profiles (*)
          ''')
          .eq('status', AppConstants.statusPending)
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => Property.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Approve property publishing (Exclusive to sole admin: Mohammed Al-Saqqaf)
  Future<void> approvePropertyPublishing(String id) async {
    if (EnvConfig.isDemoMode || _client == null) {
      final idx = SupabaseService.demoProperties.indexWhere((p) => p.id == id);
      if (idx != -1) {
        final current = SupabaseService.demoProperties[idx];
        SupabaseService.demoProperties[idx] = current.copyWith(
          status: AppConstants.statusPublished,
          reviewedAt: DateTime.now(),
        );
      }
      return;
    }

    try {
      final currentUserId = _client.auth.currentUser?.id;
      await _client
          .from('properties')
          .update({
            'status': AppConstants.statusPublished,
            'reviewed_by': currentUserId,
            'reviewed_at': DateTime.now().toIso8601String(),
            'rejection_reason': null,
          })
          .eq('id', id);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Reject property publishing (Exclusive to sole admin: Mohammed Al-Saqqaf)
  Future<void> rejectPropertyPublishing(String id, String reason) async {
    if (EnvConfig.isDemoMode || _client == null) {
      final idx = SupabaseService.demoProperties.indexWhere((p) => p.id == id);
      if (idx != -1) {
        final current = SupabaseService.demoProperties[idx];
        SupabaseService.demoProperties[idx] = current.copyWith(
          status: AppConstants.statusRejected,
          rejectionReason: reason,
          reviewedAt: DateTime.now(),
        );
      }
      return;
    }

    try {
      final currentUserId = _client.auth.currentUser?.id;
      await _client
          .from('properties')
          .update({
            'status': AppConstants.statusRejected,
            'reviewed_by': currentUserId,
            'reviewed_at': DateTime.now().toIso8601String(),
            'rejection_reason': reason,
          })
          .eq('id', id);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Delete property
  Future<void> deleteProperty(String id) async {
    if (EnvConfig.isDemoMode || _client == null) {
      SupabaseService.demoProperties.removeWhere((p) => p.id == id);
      return;
    }

    try {
      await _client.from('properties').delete().eq('id', id);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Get properties published by a specific user
  Future<List<Property>> getUserProperties(String userId) async {
    if (EnvConfig.isDemoMode || _client == null) {
      return SupabaseService.demoProperties
          .where((p) => p.ownerId == userId || userId == 'demo-admin-1')
          .toList();
    }

    try {
      final data = await _client
          .from('properties')
          .select('''
            *,
            property_images (*),
            property_types (*)
          ''')
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => Property.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  // ===========================================================================
  // Favorites Management
  // ===========================================================================
  Future<bool> toggleFavorite(String userId, String propertyId) async {
    if (EnvConfig.isDemoMode || _client == null) {
      if (SupabaseService.demoFavoriteIds.contains(propertyId)) {
        SupabaseService.demoFavoriteIds.remove(propertyId);
        return false;
      } else {
        SupabaseService.demoFavoriteIds.add(propertyId);
        return true;
      }
    }

    try {
      final existing = await _client
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('property_id', propertyId)
          .maybeSingle();

      if (existing != null) {
        await _client
            .from('favorites')
            .delete()
            .eq('user_id', userId)
            .eq('property_id', propertyId);
        return false;
      } else {
        await _client.from('favorites').insert({
          'user_id': userId,
          'property_id': propertyId,
        });
        return true;
      }
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  Future<bool> isFavorite(String userId, String propertyId) async {
    if (EnvConfig.isDemoMode || _client == null) {
      return SupabaseService.demoFavoriteIds.contains(propertyId);
    }

    try {
      final data = await _client
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('property_id', propertyId)
          .maybeSingle();
      return data != null;
    } catch (_) {
      return false;
    }
  }

  Future<List<Property>> getUserFavorites(String userId) async {
    if (EnvConfig.isDemoMode || _client == null) {
      return SupabaseService.demoProperties
          .where((p) => SupabaseService.demoFavoriteIds.contains(p.id))
          .toList();
    }

    try {
      final data = await _client
          .from('favorites')
          .select('''
            properties (
              *,
              property_images (*),
              property_types (*)
            )
          ''')
          .eq('user_id', userId);

      final list = <Property>[];
      for (final row in data as List) {
        if (row['properties'] != null) {
          list.add(
            Property.fromJson(row['properties'] as Map<String, dynamic>),
          );
        }
      }
      return list;
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }
}
