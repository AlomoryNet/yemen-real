import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';
import '../core/constants/app_constants.dart';
import '../models/admin_list_page.dart';
import '../core/exceptions/app_exception.dart';
import '../models/commission.dart';
import '../services/supabase_service.dart';
import 'admin_paging.dart';

class CommissionRepository {
  final SupabaseClient? _client = SupabaseService.client;

  /// Get all commission records for export, in bounded chunks (Admin only).
  Future<List<Commission>> getCommissions() =>
      collectAdminStream(streamAllCommissionsForExport());

  /// One bounded page for the admin commissions tab.
  Future<AdminListPage<Commission>> getCommissionsPage({
    int limit = 12,
    int offset = 0,
  }) async {
    final pageOffset = normalizeAdminOffset(offset);
    final pageLimit = normalizeAdminLimit(limit);
    final results = await Future.wait<dynamic>([
      _fetchCommissionsPage(limit: pageLimit, offset: pageOffset),
      countCommissions(),
    ]);

    return AdminListPage<Commission>(
      items: results[0] as List<Commission>,
      total: results[1] as int,
      offset: pageOffset,
    );
  }

  Future<int> countCommissions() async {
    if (EnvConfig.isDemoMode || _client == null) {
      return SupabaseService.demoCommissions.length;
    }

    try {
      return await _client.from('commissions').count();
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  Future<List<Commission>> _fetchCommissionsPage({
    required int limit,
    required int offset,
  }) async {
    if (EnvConfig.isDemoMode || _client == null) {
      return pageAdminDemo(
        SupabaseService.demoCommissions,
        offset,
        limit,
        (commission) => commission.recordedAt,
        (commission) => commission.id,
      );
    }

    try {
      final data = await _client
          .from('commissions')
          .select('''
            *,
            properties (
              title
            )
          ''')
          .order('recorded_at', ascending: false)
          .order('id', ascending: false)
          .range(offset, offset + limit - 1);

      return (data as List)
          .map((item) => Commission.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Complete commission list for PDF/CSV export without an unbounded select.
  Stream<List<Commission>> streamAllCommissionsForExport({
    int pageSize = 200,
  }) async* {
    final total = await countCommissions();
    final size = normalizeAdminLimit(pageSize);

    for (var offset = 0; offset < total; offset += size) {
      final page = await _fetchCommissionsPage(limit: size, offset: offset);
      if (page.isEmpty) break;
      yield page;
    }
  }

  /// Create manual commission record (Admin only)
  Future<Commission> createCommission({
    required String propertyId,
    required String liableParty, // seller, buyer, both
    required double sellerAmount,
    required double buyerAmount,
    required double totalAmount,
    required String currency,
    String? reasonAndNotes,
    String settlementStatus = AppConstants.commStatusDue,
    String? settlementMethod,
    String? adminUserId,
    String? propertyTitle,
  }) async {
    if (EnvConfig.isDemoMode || _client == null) {
      final newComm = Commission(
        id: 'comm-${DateTime.now().millisecondsSinceEpoch}',
        propertyId: propertyId,
        liableParty: liableParty,
        sellerAmount: sellerAmount,
        buyerAmount: buyerAmount,
        totalAmount: totalAmount,
        currency: currency,
        reasonAndNotes: reasonAndNotes,
        settlementStatus: settlementStatus,
        settlementMethod: settlementMethod,
        createdBy: adminUserId,
        recordedAt: DateTime.now(),
        settledAt: settlementStatus == AppConstants.commStatusPaid
            ? DateTime.now()
            : null,
        createdAt: DateTime.now(),
        propertyTitle: propertyTitle,
      );

      SupabaseService.demoCommissions.insert(0, newComm);
      return newComm;
    }

    try {
      final row = {
        'property_id': propertyId,
        'liable_party': liableParty,
        'seller_amount': sellerAmount,
        'buyer_amount': buyerAmount,
        'total_amount': totalAmount,
        'currency': currency,
        'reason_and_notes': reasonAndNotes,
        'settlement_status': settlementStatus,
        'settlement_method': settlementMethod,
        'created_by': adminUserId,
        'recorded_at': DateTime.now().toIso8601String(),
        'settled_at': settlementStatus == AppConstants.commStatusPaid
            ? DateTime.now().toIso8601String()
            : null,
      };

      final data = await _client.from('commissions').insert(row).select('''
            *,
            properties (
              title
            )
          ''').single();

      return Commission.fromJson(data);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Update settlement status
  Future<void> updateCommissionStatus({
    required String commissionId,
    required String status,
    String? settlementMethod,
  }) async {
    if (EnvConfig.isDemoMode || _client == null) {
      final idx = SupabaseService.demoCommissions.indexWhere(
        (c) => c.id == commissionId,
      );
      if (idx != -1) {
        final current = SupabaseService.demoCommissions[idx];
        SupabaseService.demoCommissions[idx] = Commission(
          id: current.id,
          propertyId: current.propertyId,
          liableParty: current.liableParty,
          sellerAmount: current.sellerAmount,
          buyerAmount: current.buyerAmount,
          totalAmount: current.totalAmount,
          currency: current.currency,
          reasonAndNotes: current.reasonAndNotes,
          settlementStatus: status,
          settlementMethod: settlementMethod ?? current.settlementMethod,
          createdBy: current.createdBy,
          recordedAt: current.recordedAt,
          settledAt: status == AppConstants.commStatusPaid
              ? DateTime.now()
              : null,
          createdAt: current.createdAt,
          updatedAt: DateTime.now(),
          propertyTitle: current.propertyTitle,
        );
      }
      return;
    }

    try {
      final updateData = <String, dynamic>{
        'settlement_status': status,
        if (settlementMethod != null) 'settlement_method': settlementMethod,
        if (status == AppConstants.commStatusPaid)
          'settled_at': DateTime.now().toIso8601String(),
      };

      await _client
          .from('commissions')
          .update(updateData)
          .eq('id', commissionId);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }
}
