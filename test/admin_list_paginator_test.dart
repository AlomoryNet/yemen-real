import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/models/admin_list_page.dart';
import 'package:yemen_real_estate_portal/providers/admin_paging_provider.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 1));

void main() {
  test('AdminListPaginator appends pages without gaps or duplicates', () async {
    const total = 5;
    final pages = <int, List<String>>{
      0: const ['a', 'b'],
      2: const ['c', 'd'],
      4: const ['e'],
    };
    final paginator = AdminListPaginator<String>(
      (offset, limit) async => AdminListPage<String>(
        items: pages[offset] ?? const <String>[],
        total: total,
        offset: offset,
      ),
      pageSize: 2,
    );

    await settle();
    var page = paginator.state.value!;
    expect(page.items, ['a', 'b']);
    expect(page.total, total);
    expect(page.hasMore, isTrue);

    await paginator.loadMore();
    page = paginator.state.value!;
    expect(page.items, ['a', 'b', 'c', 'd']);
    expect(page.isLoadingMore, isFalse);
    expect(page.hasMore, isTrue);

    await paginator.loadMore();
    page = paginator.state.value!;
    expect(page.items, ['a', 'b', 'c', 'd', 'e']);
    expect(page.hasMore, isFalse);

    // A completed paginator ignores redundant load requests.
    final before = page.items;
    await paginator.loadMore();
    expect(paginator.state.value!.items, same(before));
  });

  test('AdminListPaginator reload resets to the first page', () async {
    var calls = 0;
    final paginator = AdminListPaginator<String>((offset, limit) async {
      calls++;
      return AdminListPage<String>(
        items: offset == 0 ? const ['first'] : const ['later'],
        total: 2,
        offset: offset,
      );
    }, pageSize: 1);

    await settle();
    await paginator.loadMore();
    expect(paginator.state.value!.items, ['first', 'later']);

    await paginator.reload();
    expect(paginator.state.value!.items, ['first']);
    expect(calls, 3);
  });
}
