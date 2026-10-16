import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';
import '../core/exceptions/app_exception.dart';
import '../models/report_item.dart';
import '../services/supabase_service.dart';

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

  /// Get reports (Admin)
  Future<List<ReportItem>> getReports() async {
    if (EnvConfig.isDemoMode || _client == null) {
      return List<ReportItem>.from(SupabaseService.demoReports);
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
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => ReportItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException.fromSupabase(e);
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
