import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_list_page.dart';
import '../models/commission.dart';
import '../models/report_item.dart';
import '../models/user_profile.dart';
import '../repositories/admin_repository.dart';
import '../repositories/commission_repository.dart';
import '../repositories/report_repository.dart';
import 'admin_paging_provider.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

final commissionRepositoryProvider = Provider<CommissionRepository>((ref) {
  return CommissionRepository();
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository();
});

final adminStatsProvider = FutureProvider<AdminDashboardStats>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return await repo.getDashboardStats();
});

// Full lists are kept for CSV/PDF export only. The tabs watch the paginators
// below so the dashboard no longer loads every row into memory.
final allUsersProvider = FutureProvider<List<UserProfile>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return await repo.getAllUsers();
});

final adminCommissionsProvider = FutureProvider<List<Commission>>((ref) async {
  final repo = ref.watch(commissionRepositoryProvider);
  return await repo.getCommissions();
});

final adminReportsProvider = FutureProvider<List<ReportItem>>((ref) async {
  final repo = ref.watch(reportRepositoryProvider);
  return await repo.getReports();
});

final adminUsersPaginatorProvider =
    StateNotifierProvider<
      AdminListPaginator<UserProfile>,
      AsyncValue<AdminListPage<UserProfile>>
    >((ref) {
      final repo = ref.watch(adminRepositoryProvider);
      return AdminListPaginator<UserProfile>(
        (offset, limit) => repo.getUsersPage(offset: offset, limit: limit),
      );
    });

final adminCommissionsPaginatorProvider =
    StateNotifierProvider<
      AdminListPaginator<Commission>,
      AsyncValue<AdminListPage<Commission>>
    >((ref) {
      final repo = ref.watch(commissionRepositoryProvider);
      return AdminListPaginator<Commission>(
        (offset, limit) =>
            repo.getCommissionsPage(offset: offset, limit: limit),
      );
    });

final adminReportsPaginatorProvider =
    StateNotifierProvider<
      AdminListPaginator<ReportItem>,
      AsyncValue<AdminListPage<ReportItem>>
    >((ref) {
      final repo = ref.watch(reportRepositoryProvider);
      return AdminListPaginator<ReportItem>(
        (offset, limit) => repo.getReportsPage(offset: offset, limit: limit),
      );
    });
