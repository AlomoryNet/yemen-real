import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/config/app_config.dart';
import 'package:yemen_real_estate_portal/models/admin_list_page.dart';
import 'package:yemen_real_estate_portal/models/commission.dart';
import 'package:yemen_real_estate_portal/models/report_item.dart';
import 'package:yemen_real_estate_portal/models/rental_request.dart';
import 'package:yemen_real_estate_portal/models/user_profile.dart';
import 'package:yemen_real_estate_portal/repositories/admin_repository.dart';
import 'package:yemen_real_estate_portal/repositories/commission_repository.dart';
import 'package:yemen_real_estate_portal/repositories/report_repository.dart';
import 'package:yemen_real_estate_portal/repositories/rental_request_repository.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';

Future<void> checkPaging<T>({
  required Future<AdminListPage<T>> Function({int limit, int offset}) getPage,
  required Future<int> Function() count,
  required Future<List<T>> Function() getAll,
  required String Function(T item) id,
}) async {
  final total = await count();
  final first = await getPage(limit: 3, offset: 0);

  expect(first.total, total);
  expect(first.offset, 0);
  expect(first.items.length, lessThanOrEqualTo(3));
  expect(first.hasMore, total > first.items.length);

  if (total > first.items.length) {
    final second = await getPage(limit: 3, offset: first.items.length);
    final seenIds = first.items.map(id).toSet();
    expect(second.items, isNotEmpty);
    expect(second.items.every((item) => !seenIds.contains(id(item))), isTrue);
  }

  final all = await getAll();
  expect(all.length, total);
  expect(all.map(id).toSet().length, total);
}

Future<List<T>> collectChunks<T>(
  Stream<List<T>> Function({int pageSize}) stream,
) async {
  final chunks = await stream(pageSize: 3).toList();
  return chunks.expand((chunk) => chunk).toList();
}

void main() {
  setUpAll(() async {
    AppConfig.setForceDemoModeForTesting(true);
    await SupabaseService.initialize();
  });

  tearDownAll(() {
    AppConfig.setForceDemoModeForTesting(false);
  });

  test('admin user pages are bounded and export stream is complete', () async {
    final repo = AdminRepository();
    await checkPaging<UserProfile>(
      getPage: repo.getUsersPage,
      count: repo.countUsers,
      getAll: repo.getAllUsers,
      id: (user) => user.id,
    );

    final streamed = await collectChunks(repo.streamAllUsersForExport);
    expect(streamed.length, await repo.countUsers());
  });

  test('commission pages are bounded and export stream is complete', () async {
    final repo = CommissionRepository();
    await checkPaging<Commission>(
      getPage: repo.getCommissionsPage,
      count: repo.countCommissions,
      getAll: repo.getCommissions,
      id: (commission) => commission.id,
    );

    final streamed = await collectChunks(repo.streamAllCommissionsForExport);
    expect(streamed.length, await repo.countCommissions());
  });

  test('report pages are bounded and export stream is complete', () async {
    final repo = ReportRepository();
    await checkPaging<ReportItem>(
      getPage: repo.getReportsPage,
      count: repo.countReports,
      getAll: repo.getReports,
      id: (report) => report.id,
    );

    final streamed = await collectChunks(repo.streamAllReportsForExport);
    expect(streamed.length, await repo.countReports());
  });

  test(
    'rental request pages are bounded and export stream is complete',
    () async {
      final repo = RentalRequestRepository();
      await checkPaging<RentalRequest>(
        getPage: repo.getRentalRequestsPage,
        count: repo.countRentalRequests,
        getAll: repo.getAllRentalRequests,
        id: (request) => request.id,
      );

      final streamed = await collectChunks(
        repo.streamAllRentalRequestsForExport,
      );
      expect(streamed.length, await repo.countRentalRequests());
    },
  );
}
