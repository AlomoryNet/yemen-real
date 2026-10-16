import 'package:csv/csv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exception.dart';
import '../models/commission.dart';
import '../models/property.dart';
import '../models/rental_request.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';

class AdminDashboardStats {
  final int totalProperties;
  final int publishedProperties;
  final int totalUsers;
  final int pendingRentalRequests;
  final int openReports;
  final int totalCommissions;
  final double totalCommissionAmount;

  AdminDashboardStats({
    required this.totalProperties,
    required this.publishedProperties,
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
      final usersCount = await _client.from('profiles').count();
      final reqsCount = await _client
          .from('rental_requests')
          .count()
          .eq('status', AppConstants.reqStatusNew);
      final repsCount = await _client
          .from('reports')
          .count()
          .eq('status', 'pending');
      final commsData = await _client
          .from('commissions')
          .select('total_amount');

      double commSum = 0;
      for (final row in commsData as List) {
        commSum += (row['total_amount'] as num?)?.toDouble() ?? 0;
      }

      return AdminDashboardStats(
        totalProperties: propsCount,
        publishedProperties: pubPropsCount,
        totalUsers: usersCount,
        pendingRentalRequests: reqsCount,
        openReports: repsCount,
        totalCommissions: (commsData as List).length,
        totalCommissionAmount: commSum,
      );
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Get all user profiles
  Future<List<UserProfile>> getAllUsers() async {
    if (EnvConfig.isDemoMode || _client == null) {
      return [
        if (SupabaseService.demoCurrentUser != null)
          SupabaseService.demoCurrentUser!,
        UserProfile(
          id: 'demo-user-1',
          fullName: 'أحمد سيف المعمري',
          phone: '+967771234567',
          role: AppConstants.roleUser,
          isVerified: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        UserProfile(
          id: 'demo-user-2',
          fullName: 'طارق عبدالكريم',
          phone: '+967772223334',
          role: AppConstants.roleUser,
          isVerified: false,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];
    }

    try {
      final data = await _client
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => UserProfile.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException.fromSupabase(e);
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
        'المعرف',
        'عنوان العقار',
        'نوع العملية',
        'نوع العقار',
        'المدينة',
        'المنطقة',
        'السعر',
        'العملة',
        'المساحة (م²)',
        'الحالة',
        'تاريخ النشر',
        'هاتف التواصل',
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

    return const ListToCsvConverter().convert(rows);
  }

  /// Export Rental Requests to CSV
  String exportRentalRequestsToCsv(List<RentalRequest> requests) {
    List<List<dynamic>> rows = [
      [
        'رقم الطلب',
        'عنوان العقار',
        'اسم المستأجر',
        'رقم الهاتف',
        'تاريخ البدء المطلوب',
        'الحالة',
        'ملاحظات الإدارة',
        'تاريخ الطلب',
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

    return const ListToCsvConverter().convert(rows);
  }

  /// Export Commissions to CSV
  String exportCommissionsToCsv(List<Commission> commissions) {
    List<List<dynamic>> rows = [
      [
        'المعرف',
        'عنوان العقار',
        'الطرف المتحمل',
        'مبلغ البائع',
        'مبلغ المشتري',
        'إجمالي العمولة',
        'العملة',
        'حالة التسوية',
        'طريقة التسوية',
        'تاريخ التسجيل',
        'الملاحظات',
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

    return const ListToCsvConverter().convert(rows);
  }
}
