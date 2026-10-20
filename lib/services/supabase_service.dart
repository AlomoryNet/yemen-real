import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';
import '../data/demo_properties_generator.dart';
import '../models/commission.dart';
import '../models/location_item.dart';
import '../models/property.dart';
import '../models/property_type.dart';
import '../models/rental_request.dart';
import '../models/report_item.dart';
import '../models/user_profile.dart';
import '../core/constants/app_constants.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _initialized = false;

  static SupabaseClient? get client => _client;
  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (EnvConfig.isDemoMode) {
      debugPrint(
        'Running in Demo Mode. Supabase credentials not set or using placeholder.',
      );
      _initDemoData();
      return;
    }

    try {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _initialized = true;
      debugPrint('Supabase initialized successfully.');
    } catch (e) {
      debugPrint(
        'Supabase initialization failed: $e. Falling back to Demo Mode.',
      );
      _initDemoData();
    }
  }

  // ===========================================================================
  // Demo Mode Data Store (Used if Supabase is not yet configured)
  // ===========================================================================
  static List<PropertyType> demoPropertyTypes = [];
  static List<LocationItem> demoLocations = [];
  static List<Property> demoProperties = [];
  static List<RentalRequest> demoRentalRequests = [];
  static List<Commission> demoCommissions = [];
  static List<ReportItem> demoReports = [];
  static Set<String> demoFavoriteIds = {};
  static UserProfile? demoCurrentUser;
  static List<UserProfile> demoUsers = [];

  static void _initDemoData() {
    demoCurrentUser = null;
    demoUsers = [
      UserProfile(
        id: 'admin-mohammed-saqqaf',
        fullName: 'م/محمد السقاف',
        email: 'mo772522233@gmail.com',
        phone: '+967772522233',
        role: AppConstants.roleSuperAdmin,
        isVerified: true,
        createdAt: DateTime(2026, 1, 1),
      ),
    ];
    // 1. Property Types
    demoPropertyTypes = [
      PropertyType(
        id: 'apartment',
        nameAr: 'شقق سكنية',
        nameEn: 'Apartments',
        icon: 'apartment',
        sortOrder: 1,
      ),
      PropertyType(
        id: 'villa',
        nameAr: 'فلل ومنازل',
        nameEn: 'Villas & Houses',
        icon: 'villa',
        sortOrder: 2,
      ),
      PropertyType(
        id: 'land',
        nameAr: 'أراضٍ',
        nameEn: 'Lands',
        icon: 'terrain',
        sortOrder: 3,
      ),
      PropertyType(
        id: 'shop',
        nameAr: 'محلات تجارية',
        nameEn: 'Commercial Shops',
        icon: 'storefront',
        sortOrder: 4,
      ),
      PropertyType(
        id: 'office',
        nameAr: 'مكاتب ومبانٍ تجارية',
        nameEn: 'Offices & Commercial Buildings',
        icon: 'business',
        sortOrder: 5,
      ),
      PropertyType(
        id: 'other',
        nameAr: 'عقارات أخرى',
        nameEn: 'Other',
        icon: 'more_horiz',
        sortOrder: 6,
      ),
    ];

    // 2. Locations (All 22 Yemeni Governorates)
    demoLocations = DemoPropertiesGenerator.allGovernorates
        .asMap()
        .entries
        .map((entry) => LocationItem(
              id: 'loc-${entry.key + 1}',
              nameAr: entry.value.name,
              nameEn: entry.value.slug,
              sortOrder: entry.key + 1,
            ))
        .toList();

    // Users must authenticate explicitly; no unverified/auto-authenticated session
    demoCurrentUser = null;

    // 3. Realistic Demo Properties across all 22 Yemen Governorates (440 total)
    demoProperties = DemoPropertiesGenerator.generateAllDemoProperties();

    // Demo Rental Request
    demoRentalRequests = [
      RentalRequest(
        id: 'req-1',
        requestNumber: 'REQ-2026-1082',
        propertyId: 'prop-1',
        userId: 'demo-user-2',
        fullName: 'طارق عبدالكريم',
        phone: '+967772223334',
        requestedStartDate: DateTime.now().add(const Duration(days: 14)),
        notes: 'عائلة مكونة من 4 أفراد، نفضل عقد سنوي مع دفع مقدم 3 أشهر.',
        status: AppConstants.reqStatusNew,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        propertyTitle: 'شقة فاخرة للإيجار السنوي في حدة بالقرب من شارع بغداد',
        propertyPrice: 550,
        propertyCurrency: AppConstants.currencyUsd,
      ),
    ];

    // Demo Commissions (Manual record - liable party: both)
    demoCommissions = [
      Commission(
        id: 'comm-1',
        propertyId: 'prop-2',
        liableParty: AppConstants.liableBoth,
        sellerAmount: 3800,
        buyerAmount: 3800,
        totalAmount: 7600,
        currency: AppConstants.currencyUsd,
        reasonAndNotes:
            'عمولة وساطة تسويق الفيلا في بيت بوس وفق الاتفاق المكتوب بين الطرفين.',
        settlementStatus: AppConstants.commStatusPaid,
        settlementMethod: 'تحويل عبر الكريمي للصرافة',
        recordedAt: DateTime.now().subtract(const Duration(days: 10)),
        settledAt: DateTime.now().subtract(const Duration(days: 8)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        propertyTitle: 'فيلا مستقلة طابقين حجر أبيض أصيل في بيت بوس',
      ),
    ];

    // Demo Reports
    demoReports = [];
  }
}
