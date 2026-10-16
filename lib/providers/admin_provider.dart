import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/commission.dart';
import '../models/report_item.dart';
import '../models/user_profile.dart';
import '../repositories/admin_repository.dart';
import '../repositories/commission_repository.dart';
import '../repositories/report_repository.dart';

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
