import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exception.dart';
import '../models/commission.dart';
import '../services/supabase_service.dart';

class CommissionRepository {
  final SupabaseClient? _client = SupabaseService.client;

  /// Get all commission records (Admin only)
  Future<List<Commission>> getCommissions() async {
    if (EnvConfig.isDemoMode || _client == null) {
      return List<Commission>.from(SupabaseService.demoCommissions);
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
          .order('recorded_at', ascending: false);

      return (data as List)
          .map((item) => Commission.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException.fromSupabase(e);
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
