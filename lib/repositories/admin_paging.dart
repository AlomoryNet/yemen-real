/// Shared helpers for the bounded admin repository queries.
///
/// The admin tabs load 12 rows at a time while CSV/PDF exports walk the same
/// tables in larger chunks. Keeping the normalization and demo slicing here
/// makes both paths agree on ordering and page boundaries.
int normalizeAdminLimit(int limit) {
  if (limit < 1) return 1;
  if (limit > 500) return 500;
  return limit;
}

int normalizeAdminOffset(int offset) => offset < 0 ? 0 : offset;

/// Returns a copy of [source] ordered by newest [createdAt], then by id.
List<T> sortedAdminDemo<T>(
  Iterable<T> source,
  DateTime Function(T item) createdAt,
  String Function(T item) id,
) {
  final sorted = List<T>.from(source);
  sorted.sort((a, b) {
    final byDate = createdAt(b).compareTo(createdAt(a));
    if (byDate != 0) return byDate;
    return id(b).compareTo(id(a));
  });
  return sorted;
}

/// Slices demo data the same way `.order(...).range(...)` slices PostgREST.
List<T> pageAdminDemo<T>(
  Iterable<T> source,
  int offset,
  int limit,
  DateTime Function(T item) createdAt,
  String Function(T item) id,
) {
  final sorted = sortedAdminDemo(source, createdAt, id);
  final start = offset < sorted.length ? offset : sorted.length;
  final end = (start + limit) < sorted.length ? start + limit : sorted.length;
  return sorted.sublist(start, end);
}

/// Collects chunked export data into a single list for the existing CSV/PDF
/// serializers, without issuing one unbounded database query.
Future<List<T>> collectAdminStream<T>(Stream<List<T>> chunks) async {
  final all = <T>[];
  await for (final chunk in chunks) {
    all.addAll(chunk);
  }
  return all;
}
