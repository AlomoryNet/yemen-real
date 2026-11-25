import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_list_page.dart';

/// Loads admin lists one page at a time while remembering the server total.
///
/// The full-list providers remain the export sources; this notifier is only
/// used by the visible tabs so opening the dashboard never pulls every row.
class AdminListPaginator<T>
    extends StateNotifier<AsyncValue<AdminListPage<T>>> {
  AdminListPaginator(this._fetchPage, {this.pageSize = 12})
    : super(const AsyncValue.loading()) {
    loadFirstPage();
  }

  final Future<AdminListPage<T>> Function(int offset, int limit) _fetchPage;
  final int pageSize;

  int _generation = 0;

  Future<void> loadFirstPage() async {
    final generation = ++_generation;
    state = const AsyncValue.loading();

    try {
      final first = await _fetchPage(0, pageSize);
      if (generation != _generation) return;
      state = AsyncValue.data(first.copyWith(offset: 0));
    } catch (e, st) {
      if (generation != _generation) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    final generation = _generation;
    final nextOffset = current.offset + current.items.length;
    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    try {
      final next = await _fetchPage(nextOffset, pageSize);
      if (generation != _generation) return;
      state = AsyncValue.data(
        current.copyWith(
          items: [...current.items, ...next.items],
          total: next.total,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      if (generation != _generation) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reload() => loadFirstPage();
}
