import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../core/exceptions/app_exception.dart';
import '../models/location_item.dart';
import '../models/property_type.dart';
import '../services/supabase_service.dart';

class LocationRepository {
  final SupabaseClient? _client = SupabaseService.client;

  /// Fetch all active property types
  Future<List<PropertyType>> getPropertyTypes() async {
    if (AppConfig.isDemoMode || _client == null) {
      return List<PropertyType>.from(SupabaseService.demoPropertyTypes);
    }

    try {
      final data = await _client
          .from('property_types')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (data as List)
          .map((item) => PropertyType.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Fetch all active locations (Governorates and Districts)
  Future<List<LocationItem>> getLocations() async {
    if (AppConfig.isDemoMode || _client == null) {
      return List<LocationItem>.from(SupabaseService.demoLocations);
    }

    try {
      final data = await _client
          .from('locations')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (data as List)
          .map((item) => LocationItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }
}
