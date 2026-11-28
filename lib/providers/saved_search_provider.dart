import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/map_query.dart';
import '../models/saved_search.dart';
import '../repositories/saved_search_repository.dart';
import 'auth_provider.dart';

final savedSearchRepositoryProvider = Provider<SavedSearchRepository>((ref) {
  return SavedSearchRepository();
});

class SavedSearchesNotifier extends StateNotifier<AsyncValue<List<SavedSearch>>> {
  final Ref _ref;

  SavedSearchesNotifier(this._ref) : super(const AsyncValue.loading()) {
    // Auth can still be resolving when this provider is first read from a
    // drawer/rail tile. Reload when the signed-in identity actually changes.
    _ref.listen(authProvider, (previous, next) {
      if (previous?.user?.id != next.user?.id) {
        loadSavedSearches();
      }
    });
    loadSavedSearches();
  }

  Future<void> loadSavedSearches() async {
    final userId = _ref.read(authProvider).user?.id;
    if (userId == null) {
      state = const AsyncValue.data(<SavedSearch>[]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final list = await _ref
          .read(savedSearchRepositoryProvider)
          .getSavedSearches(userId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<SavedSearch?> addSavedSearch({
    required String name,
    required MapQuery query,
    bool notify = true,
  }) async {
    final userId = _ref.read(authProvider).user?.id;
    if (userId == null) return null;

    try {
      final created = await _ref.read(savedSearchRepositoryProvider).createSavedSearch(
            userId: userId,
            name: name,
            query: query,
            notify: notify,
          );
      await loadSavedSearches();
      return created;
    } catch (_) {
      return null;
    }
  }

  Future<void> setNotify(String id, bool notify) async {
    final search = _current(id);
    if (search == null) return;
    await _update(search.copyWith(notify: notify));
  }

  Future<void> rename(String id, String name) async {
    final search = _current(id);
    if (search == null || name.trim().isEmpty) return;
    await _update(search.copyWith(name: name.trim()));
  }

  Future<void> deleteSavedSearch(String id) async {
    final userId = _ref.read(authProvider).user?.id;
    if (userId == null) return;

    try {
      await _ref
          .read(savedSearchRepositoryProvider)
          .deleteSavedSearch(id: id, userId: userId);
      await loadSavedSearches();
    } catch (_) {
      // Keep the current list and let the user retry.
    }
  }

  SavedSearch? _current(String id) => state.maybeWhen(
        data: (list) {
          for (final item in list) {
            if (item.id == id) return item;
          }
          return null;
        },
        orElse: () => null,
      );

  Future<void> _update(SavedSearch search) async {
    try {
      await _ref.read(savedSearchRepositoryProvider).updateSavedSearch(search);
      await loadSavedSearches();
    } catch (_) {
      // Keep the current list and let the user retry.
    }
  }
}

final savedSearchesProvider =
    StateNotifierProvider<SavedSearchesNotifier, AsyncValue<List<SavedSearch>>>(
  (ref) => SavedSearchesNotifier(ref),
);
