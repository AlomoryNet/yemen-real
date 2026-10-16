import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exception.dart';
import '../models/rental_request.dart';
import '../services/supabase_service.dart';

class RentalRequestRepository {
  final SupabaseClient? _client = SupabaseService.client;

  /// Submit new rental request
  Future<RentalRequest> submitRentalRequest({
    required String propertyId,
    required String userId,
    required String fullName,
    required String phone,
    DateTime? requestedStartDate,
    String? notes,
    String? propertyTitle,
    double? propertyPrice,
    String? propertyCurrency,
  }) async {
    // Generate unique request tracking number
    final randomSuffix = 1000 + Random().nextInt(9000);
    final requestNumber = 'REQ-${DateTime.now().year}-$randomSuffix';

    if (EnvConfig.isDemoMode || _client == null) {
      final newReq = RentalRequest(
        id: 'req-${DateTime.now().millisecondsSinceEpoch}',
        requestNumber: requestNumber,
        propertyId: propertyId,
        userId: userId,
        fullName: fullName,
        phone: phone,
        requestedStartDate: requestedStartDate,
        notes: notes,
        status: AppConstants.reqStatusNew,
        createdAt: DateTime.now(),
        propertyTitle: propertyTitle,
        propertyPrice: propertyPrice,
        propertyCurrency: propertyCurrency,
      );

      SupabaseService.demoRentalRequests.insert(0, newReq);
      return newReq;
    }

    try {
      final row = {
        'request_number': requestNumber,
        'property_id': propertyId,
        'user_id': userId,
        'full_name': fullName,
        'phone': phone,
        'requested_start_date': requestedStartDate
            ?.toIso8601String()
            .split('T')
            .first,
        'notes': notes,
        'status': AppConstants.reqStatusNew,
      };

      final data = await _client.from('rental_requests').insert(row).select('''
            *,
            properties (
              title,
              price,
              currency
            )
          ''').single();

      return RentalRequest.fromJson(data);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Get user's submitted rental requests
  Future<List<RentalRequest>> getUserRentalRequests(String userId) async {
    if (EnvConfig.isDemoMode || _client == null) {
      return SupabaseService.demoRentalRequests
          .where(
            (r) =>
                r.userId == userId ||
                userId == 'demo-user-2' ||
                userId == 'demo-admin-1',
          )
          .toList();
    }

    try {
      final data = await _client
          .from('rental_requests')
          .select('''
            *,
            properties (
              title,
              price,
              currency
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => RentalRequest.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Get all rental requests (Admin access)
  Future<List<RentalRequest>> getAllRentalRequests() async {
    if (EnvConfig.isDemoMode || _client == null) {
      return List<RentalRequest>.from(SupabaseService.demoRentalRequests);
    }

    try {
      final data = await _client
          .from('rental_requests')
          .select('''
            *,
            properties (
              title,
              price,
              currency
            )
          ''')
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => RentalRequest.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Update rental request status (Admin / Property Owner)
  Future<void> updateRentalRequestStatus({
    required String requestId,
    required String status,
    String? adminNotes,
  }) async {
    if (EnvConfig.isDemoMode || _client == null) {
      final idx = SupabaseService.demoRentalRequests.indexWhere(
        (r) => r.id == requestId,
      );
      if (idx != -1) {
        final current = SupabaseService.demoRentalRequests[idx];
        SupabaseService.demoRentalRequests[idx] = current.copyWith(
          status: status,
          adminNotes: adminNotes,
        );
      }
      return;
    }

    try {
      await _client
          .from('rental_requests')
          .update({
            'status': status,
            if (adminNotes != null) 'admin_notes': adminNotes,
          })
          .eq('id', requestId);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }
}
