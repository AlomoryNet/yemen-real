import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/property.dart';
import 'auth_provider.dart';
import 'property_provider.dart';

class FavoritesNotifier extends StateNotifier<AsyncValue<List<Property>>> {
  final Ref _ref;

  FavoritesNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final authState = _ref.read(authProvider);
    if (authState.user == null) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(propertyRepositoryProvider);
      final list = await repo.getUserFavorites(authState.user!.id);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> toggleFavorite(String propertyId) async {
    final authState = _ref.read(authProvider);
    if (authState.user == null) return false;

    try {
      final repo = _ref.read(propertyRepositoryProvider);
      final isNowFavorite = await repo.toggleFavorite(
        authState.user!.id,
        propertyId,
      );
      await loadFavorites();
      return isNowFavorite;
    } catch (e) {
      return false;
    }
  }

  bool isFavorite(String propertyId) {
    return state.maybeWhen(
      data: (list) => list.any((p) => p.id == propertyId),
      orElse: () => false,
    );
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, AsyncValue<List<Property>>>((ref) {
      return FavoritesNotifier(ref);
    });
