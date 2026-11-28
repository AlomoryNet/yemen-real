import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../data/demo_properties_generator.dart';
import '../models/commission.dart';
import '../models/location_item.dart';
import '../models/notification_item.dart';
import '../models/property.dart';
import '../models/property_image.dart';
import '../models/property_type.dart';
import '../models/rental_request.dart';
import '../models/report_item.dart';
import '../models/saved_search.dart';
import '../models/user_profile.dart';
import '../core/constants/app_constants.dart';
import '../core/l10n/app_labels_en.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _initialized = false;

  static SupabaseClient? get client => _client;
  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (AppConfig.isDemoMode) {
      debugPrint(
        'Running in Demo Mode. Supabase credentials not set or using placeholder.',
      );
      _initDemoData();
      return;
    }

    // Environment declarations are compile-time constants: without `const`
    // Dart returns the default value and Supabase gets a relative REST URL.
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
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
  static List<SavedSearch> demoSavedSearches = [];
  static List<NotificationItem> demoNotifications = [];
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
      UserProfile(
        id: 'demo-user-2',
        fullName: 'طارق عبدالكريم',
        // Matches the email pre-filled by the login screen's "demo user" CTA,
        // so that shortcut opens a stable account with listings and requests.
        email: 'user@yemenrealestate.local',
        phone: '+967772223334',
        role: AppConstants.roleUser,
        isVerified: true,
        createdAt: DateTime(2026, 2, 3),
      ),
      UserProfile(
        id: 'demo-owner-1',
        fullName: 'أحمد صالح باشان',
        email: 'demo.owner@yemen.local',
        phone: '+967771112223',
        role: AppConstants.roleUser,
        isVerified: true,
        createdAt: DateTime(2026, 2, 10),
      ),
      UserProfile(
        id: 'demo-user-3',
        fullName: 'منى عبدالرحمن',
        email: 'demo3@yemen.local',
        phone: '+967733445566',
        role: AppConstants.roleUser,
        isVerified: true,
        createdAt: DateTime(2026, 3, 1),
      ),
      UserProfile(
        id: 'demo-agent-1',
        fullName: 'خالد العتيقي',
        email: 'agent@yemen.local',
        phone: '+967755667788',
        role: AppConstants.roleAdmin,
        isVerified: true,
        createdAt: DateTime(2026, 3, 12),
      ),
      UserProfile(
        id: 'unverified-user',
        fullName: 'حساب غير مفعل',
        email: 'unverified@yemen.local',
        phone: '+967766554433',
        role: AppConstants.roleUser,
        isVerified: false,
        createdAt: DateTime(2026, 4, 1),
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
              nameEn: AppLabelsEn.governorate[entry.value.name] ??
                  entry.value.slug,
              sortOrder: entry.key + 1,
            ))
        .toList();

    // Users must authenticate explicitly; no unverified/auto-authenticated session
    demoCurrentUser = null;

    // 3. Realistic Demo Properties across all 22 Yemen Governorates (440 total)
    demoProperties = List<Property>.from(
      DemoPropertiesGenerator.cachedDemoProperties,
    );

    // Pending-approval submissions keep the admin moderation queue and owner
    // dashboards populated without changing the 440 published demo listings.
    demoProperties.addAll([
      Property(
        id: 'demo-pending-1',
        ownerId: 'demo-user-2',
        title: 'شقة للإيجار في بيت بوس بانتظار المراجعة',
        description:
            'إعلان تجريبي بانتظار موافقة الإدارة، شقة مكونة من ثلاث غرف في بيت بوس مع عقد سنوي.',
        dealType: AppConstants.dealRent,
        propertyTypeId: 'apartment',
        city: 'أمانة العاصمة',
        district: 'بيت بوس',
        addressDetails: 'حي اليرموك - بيت بوس',
        latitude: 15.335,
        longitude: 44.195,
        price: 620,
        currency: AppConstants.currencyUsd,
        areaSqm: 145,
        bedrooms: 3,
        bathrooms: 2,
        contactPhone: '+967772223334',
        status: AppConstants.statusPending,
        publishingMode: 'admin_approval',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        images: [
          PropertyImage(
            id: 'demo-pending-1-img-1',
            propertyId: 'demo-pending-1',
            imageUrl: DemoPropertiesGenerator.sampleImages[0],
            isPrimary: true,
            sortOrder: 1,
          ),
        ],
      ),
      Property(
        id: 'demo-pending-2',
        ownerId: 'demo-owner-1',
        title: 'فيلا للبيع في المعلا بانتظار المراجعة',
        description:
            'إعلان تجريبي بانتظار موافقة الإدارة، فيلا مكونة من طابقين بموقع قريب من البحر.',
        dealType: AppConstants.dealSale,
        propertyTypeId: 'villa',
        city: 'عدن',
        district: 'المعلا',
        addressDetails: 'شارع الزعفران - المعلا',
        latitude: 12.786,
        longitude: 45.037,
        price: 185000,
        currency: AppConstants.currencyUsd,
        areaSqm: 420,
        bedrooms: 5,
        bathrooms: 4,
        contactPhone: '+967771112223',
        status: AppConstants.statusPending,
        publishingMode: 'admin_approval',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        images: [
          PropertyImage(
            id: 'demo-pending-2-img-1',
            propertyId: 'demo-pending-2',
            imageUrl: DemoPropertiesGenerator.sampleImages[1],
            isPrimary: true,
            sortOrder: 1,
          ),
        ],
      ),
      Property(
        id: 'demo-pending-3',
        ownerId: 'demo-user-2',
        title: 'أرض استثمارية في القاهرة بانتظار المراجعة',
        description:
            'إعلان تجريبي بانتظار موافقة الإدارة، أرض استثمارية على شارع رئيسي في مدينة القاهرة.',
        dealType: AppConstants.dealSale,
        propertyTypeId: 'land',
        city: 'تعز',
        district: 'القاهرة',
        addressDetails: 'شارع الوحدة - القاهرة',
        latitude: 13.577,
        longitude: 44.018,
        price: 42000,
        currency: AppConstants.currencyUsd,
        areaSqm: 900,
        contactPhone: '+967772223334',
        status: AppConstants.statusPending,
        publishingMode: 'admin_approval',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        images: [
          PropertyImage(
            id: 'demo-pending-3-img-1',
            propertyId: 'demo-pending-3',
            imageUrl: DemoPropertiesGenerator.sampleImages[2],
            isPrimary: true,
            sortOrder: 1,
          ),
        ],
      ),
    ]);

    // Demo Rental Request
    demoRentalRequests = [
      RentalRequest(
        id: 'req-1',
        requestNumber: 'REQ-2026-1082',
        propertyId: 'd3300000-0000-0000-0001-000000000004',
        userId: 'demo-user-2',
        fullName: 'طارق عبدالكريم',
        phone: '+967772223334',
        requestedStartDate: DateTime.now().add(const Duration(days: 14)),
        notes: 'عائلة مكونة من 4 أفراد، نفضل عقد سنوي مع دفع مقدم 3 أشهر.',
        status: AppConstants.reqStatusNew,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        propertyTitle: 'شقة للإيجار في بيت بوس',
        propertyPrice: 550,
        propertyCurrency: AppConstants.currencyUsd,
      ),
      RentalRequest(
        id: 'req-2',
        requestNumber: 'REQ-2026-1083',
        propertyId: 'd3300000-0000-0000-0001-000000000016',
        userId: 'demo-user-2',
        fullName: 'طارق عبدالكريم',
        phone: '+967772223334',
        requestedStartDate: DateTime.now().add(const Duration(days: 21)),
        notes: 'طلب لمحل تجاري مناسب لمشروع مقهى صغير.',
        status: AppConstants.reqStatusNew,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        propertyTitle: 'محل تجاري في بيت بوس',
        propertyPrice: 900,
        propertyCurrency: AppConstants.currencyUsd,
      ),
      RentalRequest(
        id: 'req-3',
        requestNumber: 'REQ-2026-1084',
        propertyId: 'd3300000-0000-0000-0002-000000000002',
        userId: 'demo-user-2',
        fullName: 'طارق عبدالكريم',
        phone: '+967772223334',
        requestedStartDate: DateTime.now().add(const Duration(days: 30)),
        notes: 'طلب سكن عائلي قريب من مركز المدينة.',
        status: AppConstants.reqStatusUnderReview,
        adminNotes: 'تم التحقق من رقم الهاتف.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        propertyTitle: 'شقة في سنحان',
        propertyPrice: 480,
        propertyCurrency: AppConstants.currencyUsd,
      ),
      RentalRequest(
        id: 'req-4',
        requestNumber: 'REQ-2026-1085',
        propertyId: 'd3300000-0000-0000-0003-000000000003',
        userId: 'demo-user-3',
        fullName: 'منى عبدالرحمن',
        phone: '+967733445566',
        requestedStartDate: DateTime.now().subtract(const Duration(days: 10)),
        notes: 'تم إكمال العقد واستلام المفتاح.',
        status: AppConstants.reqStatusCompleted,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        propertyTitle: 'شقة في تعز',
        propertyPrice: 400,
        propertyCurrency: AppConstants.currencyUsd,
      ),
    ];

    String demoPropertyTitle(String id) =>
        demoProperties.cast<Property?>().firstWhere(
              (p) => p?.id == id,
              orElse: () => null,
            )?.title ??
        'عقار تجريبي';

    // Demo commissions cover paid/due/cancelled states and every liable party.
    demoCommissions = [
      Commission(
        id: 'comm-1',
        propertyId: 'd3300000-0000-0000-0001-000000000004',
        liableParty: AppConstants.liableBoth,
        sellerAmount: 3800,
        buyerAmount: 3800,
        totalAmount: 7600,
        currency: AppConstants.currencyUsd,
        reasonAndNotes:
            'عمولة وساطة تسويق العقار وفق الاتفاق المكتوب بين الطرفين.',
        settlementStatus: AppConstants.commStatusPaid,
        settlementMethod: 'تحويل عبر الكريمي للصرافة',
        createdBy: 'admin-mohammed-saqqaf',
        recordedAt: DateTime.now().subtract(const Duration(days: 10)),
        settledAt: DateTime.now().subtract(const Duration(days: 8)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        propertyTitle:
            demoPropertyTitle('d3300000-0000-0000-0001-000000000004'),
      ),
      Commission(
        id: 'comm-2',
        propertyId: 'd3300000-0000-0000-0001-000000000016',
        liableParty: AppConstants.liableSeller,
        sellerAmount: 2200,
        totalAmount: 2200,
        currency: AppConstants.currencyUsd,
        reasonAndNotes: 'عمولة مستحقة بعد توقيع عقد الإيجار.',
        settlementStatus: AppConstants.commStatusDue,
        createdBy: 'admin-mohammed-saqqaf',
        recordedAt: DateTime.now().subtract(const Duration(days: 4)),
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        propertyTitle:
            demoPropertyTitle('d3300000-0000-0000-0001-000000000016'),
      ),
      Commission(
        id: 'comm-3',
        propertyId: 'd3300000-0000-0000-0002-000000000002',
        liableParty: AppConstants.liableBuyer,
        buyerAmount: 1500,
        totalAmount: 1500,
        currency: AppConstants.currencyUsd,
        reasonAndNotes: 'عمولة المشتري بعد معاينة العقار.',
        settlementStatus: AppConstants.commStatusDue,
        settlementMethod: 'دفع نقدي عند الاستلام',
        createdBy: 'admin-mohammed-saqqaf',
        recordedAt: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        propertyTitle:
            demoPropertyTitle('d3300000-0000-0000-0002-000000000002'),
      ),
      Commission(
        id: 'comm-4',
        propertyId: 'd3300000-0000-0000-0003-000000000003',
        liableParty: AppConstants.liableBoth,
        sellerAmount: 900,
        buyerAmount: 900,
        totalAmount: 1800,
        currency: AppConstants.currencyUsd,
        reasonAndNotes: 'أُلغيت العمولة بعد إلغاء الصفقة من الطرفين.',
        settlementStatus: AppConstants.commStatusCancelled,
        createdBy: 'admin-mohammed-saqqaf',
        recordedAt: DateTime.now().subtract(const Duration(days: 18)),
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        propertyTitle:
            demoPropertyTitle('d3300000-0000-0000-0003-000000000003'),
      ),
    ];

    // Violation reports in all three admin-review states.
    demoReports = [
      ReportItem(
        id: 'rep-1',
        propertyId: 'd3300000-0000-0000-0001-000000000004',
        reporterId: 'demo-user-3',
        reason: 'صورة غير مطابقة للعقار',
        details: 'الصور المعروضة لا تمثل الوحدة المؤجرة عند المعاينة.',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        propertyTitle:
            demoPropertyTitle('d3300000-0000-0000-0001-000000000004'),
      ),
      ReportItem(
        id: 'rep-2',
        propertyId: 'd3300000-0000-0000-0002-000000000002',
        reporterId: 'demo-user-2',
        reason: 'رقم التواصل غير صحيح',
        details: 'لم يتم الرد على رقم الهاتف المذكور في الإعلان.',
        status: 'investigating',
        adminActionTaken: 'تم إرسال تنبيه إلى مالك الإعلان.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        propertyTitle:
            demoPropertyTitle('d3300000-0000-0000-0002-000000000002'),
      ),
      ReportItem(
        id: 'rep-3',
        propertyId: 'd3300000-0000-0000-0003-000000000003',
        reporterId: 'demo-user-3',
        reason: 'إعلان مكرر',
        details: 'العقار معلن أكثر من مرة بأسعار مختلفة.',
        status: 'resolved',
        adminActionTaken: 'تم حذف الإعلان المكرر والإبقاء على الأحدث.',
        resolvedBy: 'admin-mohammed-saqqaf',
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
        resolvedAt: DateTime.now().subtract(const Duration(days: 7)),
        propertyTitle:
            demoPropertyTitle('d3300000-0000-0000-0003-000000000003'),
      ),
    ];

    // Seed the demo user's favorites so the Favorites tab is not empty on
    // first login via the quick demo CTA.
    demoFavoriteIds = {
      'd3300000-0000-0000-0001-000000000004',
      'd3300000-0000-0000-0001-000000000016',
      'd3300000-0000-0000-0002-000000000002',
    };
  }
}
