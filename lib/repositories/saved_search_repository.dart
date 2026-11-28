import '../config/app_config.dart';
import '../core/exceptions/app_exception.dart';
import '../models/map_query.dart';
import '../models/saved_search.dart';
import '../services/supabase_service.dart';

/// Stores saved searches in Supabase, with an in-memory demo fallback.
class SavedSearchRepository {
  static const String table = 'saved_searches';

  Future<List<SavedSearch>> getSavedSearches(String userId) async {
    if (AppConfig.isDemoMode) {
      _seedDemoSearches(userId);
      return SupabaseService.demoSavedSearches
          .where((search) => search.userId == userId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    final client = SupabaseService.client;
    if (client == null) return const <SavedSearch>[];

    try {
      final rows = await client
          .from(table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return rows
          .map(
            (row) => SavedSearch.fromJson(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList();
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  Future<SavedSearch> createSavedSearch({
    required String userId,
    required String name,
    required MapQuery query,
    bool notify = true,
  }) async {
    final now = DateTime.now();

    if (AppConfig.isDemoMode) {
      _seedDemoSearches(userId);
      final search = SavedSearch(
        id: 'demo-saved-${DateTime.now().microsecondsSinceEpoch}',
        userId: userId,
        name: name.trim(),
        query: query,
        notify: notify,
        createdAt: now,
        updatedAt: now,
      );
      SupabaseService.demoSavedSearches.add(search);
      return search;
    }

    final client = SupabaseService.client;
    if (client == null) {
      throw AppException('Supabase client is not initialized.');
    }

    try {
      final row = await client
          .from(table)
          .insert(<String, dynamic>{
            'user_id': userId,
            'name': name.trim(),
            'query': query.toSavedJson(),
            'notify': notify,
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          })
          .select()
          .single();
      return SavedSearch.fromJson(Map<String, dynamic>.from(row as Map));
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  Future<void> updateSavedSearch(SavedSearch search) async {
    if (AppConfig.isDemoMode) {
      final index = SupabaseService.demoSavedSearches
          .indexWhere((item) => item.id == search.id);
      if (index >= 0) {
        SupabaseService.demoSavedSearches[index] = search;
      }
      return;
    }

    final client = SupabaseService.client;
    if (client == null) return;

    try {
      await client
          .from(table)
          .update(<String, dynamic>{
            'name': search.name,
            'query': search.query.toSavedJson(),
            'notify': search.notify,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', search.id)
          .eq('user_id', search.userId);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  Future<void> deleteSavedSearch({
    required String id,
    required String userId,
  }) async {
    if (AppConfig.isDemoMode) {
      SupabaseService.demoSavedSearches
          .removeWhere((item) => item.id == id && item.userId == userId);
      return;
    }

    final client = SupabaseService.client;
    if (client == null) return;

    try {
      await client.from(table).delete().eq('id', id).eq('user_id', userId);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  void _seedDemoSearches(String userId) {
    if (SupabaseService.demoSavedSearches.any(
      (search) => search.userId == userId,
    )) {
      return;
    }
    SupabaseService.demoSavedSearches.add(
      SavedSearch(
        id: 'demo-saved-search-$userId',
        userId: userId,
        name: 'إيجارات إب',
        query: const MapQuery(
          dealType: 'rent',
          governorate: 'إب',
          view: MapViewMode.list,
        ),
        notify: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );
  }
}
