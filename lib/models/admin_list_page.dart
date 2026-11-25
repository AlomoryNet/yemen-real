/// One incrementally loaded slice of an admin list.
///
/// Unlike the old full-list providers, [items] may contain only the first page
/// while [total] still describes the complete server-side result set.
class AdminListPage<T> {
  const AdminListPage({
    required this.items,
    required this.total,
    this.offset = 0,
    this.isLoadingMore = false,
  });

  final List<T> items;
  final int total;

  /// Offset of the first loaded item. Paginators normally start at zero.
  final int offset;
  final bool isLoadingMore;

  bool get hasMore => offset + items.length < total;

  AdminListPage<T> copyWith({
    List<T>? items,
    int? total,
    int? offset,
    bool? isLoadingMore,
  }) {
    return AdminListPage<T>(
      items: items ?? this.items,
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
