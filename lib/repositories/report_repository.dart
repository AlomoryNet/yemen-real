import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';
import '../core/exceptions/app_exception.dart';
import '../models/admin_list_page.dart';
import '../models/report_item.dart';
import '../services/supabase_service.dart';
import 'admin_paging.dart';

class ReportRepository {
  final SupabaseClient? _client = SupabaseService.client;

  /// Submit report for a violating property
  Future<void> submitReport({
    required String propertyId,
    String? reporterId,
    required String reason,
    String? details,
  }) async {
    if (EnvConfig.isDemoMode || _client == null) {
      final report = ReportItem(
        id: 'rep-${DateTime.now().millisecondsSinceEpoch}',
        propertyId: propertyId,
        reporterId: reporterId,
        reason: reason,
        details: details,
        status: 'pending',
        createdAt: DateTime.now(),
      );
      SupabaseService.demoReports.insert(0, report);
      return;
    }

    try {
      await _client.from('reports').insert({
        'property_id': propertyId,
        'reporter_id': reporterId,
        'reason': reason,
        'details': details,
        'status': 'pending',
      });
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Get all reports for export, in bounded chunks (Admin).
  Future<List<ReportItem>> getReports() =>
      collectAdminStream(streamAllReportsForExport());

  /// One bounded page for the admin reports tab.
  Future<AdminListPage<ReportItem>> getReportsPage({
    int limit = 12,
    int offset = 0,
  }) async {
    final pageOffset = normalizeAdminOffset(offset);
    final pageLimit = normalizeAdminLimit(limit);
    final results = await Future.wait<dynamic>([
      _fetchReportsPage(limit: pageLimit, offset: pageOffset),
      countReports(),
    ]);

    return AdminListPage<ReportItem>(
      items: results[0] as List<ReportItem>,
      total: results[1] as int,
      offset: pageOffset,
    );
  }

  Future<int> countReports() async {
    if (EnvConfig.isDemoMode || _client == null) {
      return SupabaseService.demoReports.length;
    }

    try {
      return await _client.from('reports').count();
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  Future<List<ReportItem>> _fetchReportsPage({
    required int limit,
    required int offset,
  }) async {
    if (EnvConfig.isDemoMode || _client == null) {
      return pageAdminDemo(
        SupabaseService.demoReports,
        offset,
        limit,
        (report) => report.createdAt,
        (report) => report.id,
      );
    }

    try {
      final data = await _client
          .from('reports')
          .select('''
            *,
            properties (
              title
            )
          ''')
          .order('created_at', ascending: false)
          .order('id', ascending: false)
          .range(offset, offset + limit - 1);

      return (data as List)
          .map((item) => ReportItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Complete report list for PDF export without an unbounded select.
  Stream<List<ReportItem>> streamAllReportsForExport({
    int pageSize = 200,
  }) async* {
    final total = await countReports();
    final size = normalizeAdminLimit(pageSize);

    for (var offset = 0; offset < total; offset += size) {
      final page = await _fetchReportsPage(limit: size, offset: offset);
      if (page.isEmpty) break;
      yield page;
    }
  }

  /// Resolve or update report status (Admin)
  Future<void> updateReportStatus({
    required String reportId,
    required String status,
    String? adminActionTaken,
    String? adminId,
  }) async {
    if (EnvConfig.isDemoMode || _client == null) {
      final idx = SupabaseService.demoReports.indexWhere(
        (r) => r.id == reportId,
      );
      if (idx != -1) {
        final current = SupabaseService.demoReports[idx];
        SupabaseService.demoReports[idx] = ReportItem(
          id: current.id,
          propertyId: current.propertyId,
          reporterId: current.reporterId,
          reason: current.reason,
          details: current.details,
          status: status,
          adminActionTaken: adminActionTaken ?? current.adminActionTaken,
          resolvedBy: adminId,
          createdAt: current.createdAt,
          resolvedAt: DateTime.now(),
          propertyTitle: current.propertyTitle,
        );
      }
      return;
    }

    try {
      await _client
          .from('reports')
          .update({
            'status': status,
            if (adminActionTaken != null)
              'admin_action_taken': adminActionTaken,
            'resolved_by': adminId,
            'resolved_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reportId);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }
}
