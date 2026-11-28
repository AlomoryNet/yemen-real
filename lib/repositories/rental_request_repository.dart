import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../core/constants/app_constants.dart';
import '../models/admin_list_page.dart';
import '../core/exceptions/app_exception.dart';
import '../models/rental_request.dart';
import '../services/supabase_service.dart';
import 'admin_paging.dart';

class RentalRequestRepository {
  final SupabaseClient? _client = SupabaseService.client;

  /// Submit new rental request
  Future<RentalRequest> submitRentalRequest({
    required String propertyId,
    required String userId,
    required String fullName,
    required String phone,
    DateTime? requestedStartDate,
    DateTime? scheduledVisitAt,
    String? notes,
    String? propertyTitle,
    double? propertyPrice,
    String? propertyCurrency,
  }) async {
    // Generate unique request tracking number
    final randomSuffix = 1000 + Random().nextInt(9000);
    final requestNumber = 'REQ-${DateTime.now().year}-$randomSuffix';

    if (AppConfig.isDemoMode || _client == null) {
      final newReq = RentalRequest(
        id: 'req-${DateTime.now().millisecondsSinceEpoch}',
        requestNumber: requestNumber,
        propertyId: propertyId,
        userId: userId,
        fullName: fullName,
        phone: phone,
        requestedStartDate: requestedStartDate,
        scheduledVisitAt: scheduledVisitAt,
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
        'scheduled_visit_at': scheduledVisitAt?.toIso8601String(),
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
    if (AppConfig.isDemoMode || _client == null) {
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

  /// Get all rental requests for export, in bounded chunks (Admin access).
  Future<List<RentalRequest>> getAllRentalRequests() =>
      collectAdminStream(streamAllRentalRequestsForExport());

  /// One bounded page for the admin rental requests tab.
  Future<AdminListPage<RentalRequest>> getRentalRequestsPage({
    int limit = 12,
    int offset = 0,
  }) async {
    final pageOffset = normalizeAdminOffset(offset);
    final pageLimit = normalizeAdminLimit(limit);
    final results = await Future.wait<dynamic>([
      _fetchRentalRequestsPage(limit: pageLimit, offset: pageOffset),
      countRentalRequests(),
    ]);

    return AdminListPage<RentalRequest>(
      items: results[0] as List<RentalRequest>,
      total: results[1] as int,
      offset: pageOffset,
    );
  }

  Future<int> countRentalRequests() async {
    if (AppConfig.isDemoMode || _client == null) {
      return SupabaseService.demoRentalRequests.length;
    }

    try {
      return await _client.from('rental_requests').count();
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  Future<List<RentalRequest>> _fetchRentalRequestsPage({
    required int limit,
    required int offset,
  }) async {
    if (AppConfig.isDemoMode || _client == null) {
      return pageAdminDemo(
        SupabaseService.demoRentalRequests,
        offset,
        limit,
        (request) => request.createdAt,
        (request) => request.id,
      );
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
          .order('created_at', ascending: false)
          .order('id', ascending: false)
          .range(offset, offset + limit - 1);

      return (data as List)
          .map((item) => RentalRequest.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Complete request list for PDF/CSV export without an unbounded select.
  Stream<List<RentalRequest>> streamAllRentalRequestsForExport({
    int pageSize = 200,
  }) async* {
    final total = await countRentalRequests();
    final size = normalizeAdminLimit(pageSize);

    for (var offset = 0; offset < total; offset += size) {
      final page = await _fetchRentalRequestsPage(limit: size, offset: offset);
      if (page.isEmpty) break;
      yield page;
    }
  }

  /// Update rental request status (Admin / Property Owner)
  Future<void> updateRentalRequestStatus({
    required String requestId,
    required String status,
    String? adminNotes,
  }) async {
    if (AppConfig.isDemoMode || _client == null) {
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

  /// Set or clear the property-viewing appointment (Admin / Property Owner).
  Future<void> updateRentalRequestVisit({
    required String requestId,
    DateTime? scheduledVisitAt,
    bool clearVisit = false,
  }) async {
    if (!clearVisit && scheduledVisitAt == null) return;

    if (AppConfig.isDemoMode || _client == null) {
      final idx = SupabaseService.demoRentalRequests.indexWhere(
        (r) => r.id == requestId,
      );
      if (idx != -1) {
        final current = SupabaseService.demoRentalRequests[idx];
        SupabaseService.demoRentalRequests[idx] = current.copyWith(
          scheduledVisitAt: scheduledVisitAt,
          clearScheduledVisit: clearVisit,
        );
      }
      return;
    }

    try {
      await _client
          .from('rental_requests')
          .update({
            'scheduled_visit_at': clearVisit
                ? null
                : scheduledVisitAt?.toIso8601String(),
          })
          .eq('id', requestId);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }
}
