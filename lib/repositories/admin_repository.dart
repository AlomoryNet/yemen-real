import 'package:csv/csv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';
import '../core/constants/app_constants.dart';
import '../models/admin_list_page.dart';
import '../core/exceptions/app_exception.dart';
import '../models/commission.dart';
import '../models/property.dart';
import '../models/rental_request.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';
import '../core/l10n/app_strings.dart';
import 'admin_paging.dart';

class AdminDashboardStats {
  final int totalProperties;
  final int publishedProperties;
  final int pendingProperties;
  final int totalUsers;
  final int pendingRentalRequests;
  final int openReports;
  final int totalCommissions;
  final double totalCommissionAmount;

  AdminDashboardStats({
    required this.totalProperties,
    required this.publishedProperties,
    this.pendingProperties = 0,
    required this.totalUsers,
    required this.pendingRentalRequests,
    required this.openReports,
    required this.totalCommissions,
    required this.totalCommissionAmount,
  });
}

class AdminRepository {
  final SupabaseClient? _client = SupabaseService.client;

  /// Fetch dashboard analytical summary
  Future<AdminDashboardStats> getDashboardStats() async {
    if (EnvConfig.isDemoMode || _client == null) {
      final totalProps = SupabaseService.demoProperties.length;
      final pubProps = SupabaseService.demoProperties
          .where((p) => p.status == AppConstants.statusPublished)
          .length;
      final pendingProps = SupabaseService.demoProperties
          .where((p) => p.status == AppConstants.statusPending)
          .length;
      final pendingReqs = SupabaseService.demoRentalRequests
          .where((r) => r.status == AppConstants.reqStatusNew)
          .length;
      final openReps = SupabaseService.demoReports
          .where((r) => r.status == 'pending')
          .length;
      final totalComms = SupabaseService.demoCommissions.length;
      final totalCommAmount = SupabaseService.demoCommissions.fold<double>(
        0,
        (sum, item) => sum + item.totalAmount,
      );

      return AdminDashboardStats(
        totalProperties: totalProps,
        publishedProperties: pubProps,
        pendingProperties: pendingProps,
        totalUsers: 14,
        pendingRentalRequests: pendingReqs,
        openReports: openReps,
        totalCommissions: totalComms,
        totalCommissionAmount: totalCommAmount,
      );
    }

    try {
      final propsCount = await _client.from('properties').count();
      final pubPropsCount = await _client
          .from('properties')
          .count()
          .eq('status', AppConstants.statusPublished);
      final pendingPropsCount = await _client
          .from('properties')
          .count()
          .eq('status', AppConstants.statusPending);
      final usersCount = await _client.from('profiles').count();
      final reqsCount = await _client
          .from('rental_requests')
          .count()
          .eq('status', AppConstants.reqStatusNew);
      final repsCount = await _client
          .from('reports')
          .count()
          .eq('status', 'pending');
      late final int commCount;
      late final double commSum;
      try {
        // PostgREST aggregates avoid downloading every commission row just to
        // compute these two numbers. Older backends may reject aggregate
        // syntax, so fall back to the previous client-side fold below.
        final aggregate = await _client
            .from('commissions')
            .select('total_amount.sum(),id.count()');
        final rows = aggregate as List;
        final row = rows.isNotEmpty
            ? rows.first as Map<String, dynamic>
            : const <String, dynamic>{};
        commCount = (row['count'] as num?)?.toInt() ?? 0;
        commSum = (row['sum'] as num?)?.toDouble() ?? 0;
      } catch (_) {
        final commsData = await _client
            .from('commissions')
            .select('total_amount');
        final rows = commsData as List;
        commCount = rows.length;
        commSum = rows.fold<double>(0, (sum, row) {
          final amount = (row as Map<String, dynamic>)['total_amount'] as num?;
          return sum + (amount?.toDouble() ?? 0);
        });
      }

      return AdminDashboardStats(
        totalProperties: propsCount,
        publishedProperties: pubPropsCount,
        pendingProperties: pendingPropsCount,
        totalUsers: usersCount,
        pendingRentalRequests: reqsCount,
        openReports: repsCount,
        totalCommissions: commCount,
        totalCommissionAmount: commSum,
      );
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Get all user profiles for export, in bounded chunks.
  Future<List<UserProfile>> getAllUsers() =>
      collectAdminStream(streamAllUsersForExport());

  /// One bounded page for the admin users tab.
  Future<AdminListPage<UserProfile>> getUsersPage({
    int limit = 12,
    int offset = 0,
  }) async {
    final pageOffset = normalizeAdminOffset(offset);
    final pageLimit = normalizeAdminLimit(limit);
    final results = await Future.wait<dynamic>([
      _fetchUsersPage(limit: pageLimit, offset: pageOffset),
      countUsers(),
    ]);

    return AdminListPage<UserProfile>(
      items: results[0] as List<UserProfile>,
      total: results[1] as int,
      offset: pageOffset,
    );
  }

  Future<int> countUsers() async {
    if (EnvConfig.isDemoMode || _client == null) {
      return SupabaseService.demoUsers.length;
    }

    try {
      return await _client.from('profiles').count();
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  Future<List<UserProfile>> _fetchUsersPage({
    required int limit,
    required int offset,
  }) async {
    if (EnvConfig.isDemoMode || _client == null) {
      return pageAdminDemo(
        SupabaseService.demoUsers,
        offset,
        limit,
        (user) => user.createdAt,
        (user) => user.id,
      );
    }

    try {
      final data = await _client
          .from('profiles')
          .select()
          .order('created_at', ascending: false)
          .order('id', ascending: false)
          .range(offset, offset + limit - 1);

      return (data as List)
          .map((item) => UserProfile.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Complete user list for PDF/CSV export without an unbounded select.
  Stream<List<UserProfile>> streamAllUsersForExport({
    int pageSize = 200,
  }) async* {
    final total = await countUsers();
    final size = normalizeAdminLimit(pageSize);

    for (var offset = 0; offset < total; offset += size) {
      final page = await _fetchUsersPage(limit: size, offset: offset);
      if (page.isEmpty) break;
      yield page;
    }
  }

  /// Change user role (Super Admin action)
  Future<void> updateUserRole(String userId, String newRole) async {
    if (EnvConfig.isDemoMode || _client == null) {
      return;
    }

    try {
      await _client.from('profiles').update({'role': newRole}).eq('id', userId);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Export Properties to CSV
  String exportPropertiesToCsv(List<Property> properties) {
    List<List<dynamic>> rows = [
      [
        tr.csv_id,
        tr.csv_property_title,
        tr.csv_deal_type,
        tr.csv_property_type,
        tr.csv_city,
        tr.csv_district,
        tr.csv_price,
        tr.csv_currency,
        tr.csv_area,
        tr.csv_status,
        tr.csv_publish_date,
        tr.csv_contact_phone,
      ],
    ];

    for (final p in properties) {
      rows.add([
        p.id,
        p.title,
        AppConstants.getDealTypeNameAr(p.dealType),
        p.propertyType?.nameAr ?? p.propertyTypeId,
        p.city,
        p.district,
        p.price,
        p.currency,
        p.areaSqm,
        AppConstants.getPropertyStatusNameAr(p.status),
        p.createdAt.toIso8601String().split('T').first,
        p.contactPhone,
      ]);
    }

    return '\uFEFF${const ListToCsvConverter().convert(rows)}';
  }

  /// Export Rental Requests to CSV
  String exportRentalRequestsToCsv(List<RentalRequest> requests) {
    List<List<dynamic>> rows = [
      [
        tr.csv_request_number,
        tr.csv_property_title,
        tr.csv_tenant_name,
        tr.csv_phone,
        tr.csv_requested_start,
        tr.csv_status,
        tr.csv_admin_notes,
        tr.csv_request_date,
      ],
    ];

    for (final r in requests) {
      rows.add([
        r.requestNumber,
        r.propertyTitle ?? r.propertyId,
        r.fullName,
        r.phone,
        r.requestedStartDate?.toIso8601String().split('T').first ?? '-',
        AppConstants.getRentalRequestStatusNameAr(r.status),
        r.adminNotes ?? '-',
        r.createdAt.toIso8601String().split('T').first,
      ]);
    }

    return '\uFEFF${const ListToCsvConverter().convert(rows)}';
  }

  /// Export Commissions to CSV
  String exportCommissionsToCsv(List<Commission> commissions) {
    List<List<dynamic>> rows = [
      [
        tr.csv_id,
        tr.csv_property_title,
        tr.csv_liable_party,
        tr.csv_seller_amount,
        tr.csv_buyer_amount,
        tr.csv_total_commission,
        tr.csv_currency,
        tr.csv_settlement_status,
        tr.csv_settlement_method,
        tr.csv_registration_date,
        tr.csv_notes,
      ],
    ];

    for (final c in commissions) {
      rows.add([
        c.id,
        c.propertyTitle ?? c.propertyId,
        AppConstants.getLiablePartyNameAr(c.liableParty),
        c.sellerAmount,
        c.buyerAmount,
        c.totalAmount,
        c.currency,
        AppConstants.getCommissionStatusNameAr(c.settlementStatus),
        c.settlementMethod ?? '-',
        c.recordedAt.toIso8601String().split('T').first,
        c.reasonAndNotes ?? '-',
      ]);
    }

    return '\uFEFF${const ListToCsvConverter().convert(rows)}';
  }
}
