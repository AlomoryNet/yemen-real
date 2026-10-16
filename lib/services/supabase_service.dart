import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';
import '../core/constants/app_constants.dart';
import '../models/commission.dart';
import '../models/location_item.dart';
import '../models/property.dart';
import '../models/property_image.dart';
import '../models/property_type.dart';
import '../models/rental_request.dart';
import '../models/report_item.dart';
import '../models/user_profile.dart';

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

  static void _initDemoData() {
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

    // 2. Locations (Yemen)
    demoLocations = [
      LocationItem(
        id: 'loc-1',
        nameAr: 'أمانة العاصمة صنعاء',
        nameEn: 'Sanaa',
        sortOrder: 1,
      ),
      LocationItem(
        id: 'loc-2',
        nameAr: 'حدة والحي الدبلوماسي',
        nameEn: 'Hadda',
        parentId: 'loc-1',
        sortOrder: 2,
      ),
      LocationItem(
        id: 'loc-3',
        nameAr: 'السبعين والأصبحي',
        nameEn: 'Al Sabeen & Asbahi',
        parentId: 'loc-1',
        sortOrder: 3,
      ),
      LocationItem(
        id: 'loc-4',
        nameAr: 'بيت بوس',
        nameEn: 'Bait Baws',
        parentId: 'loc-1',
        sortOrder: 4,
      ),
      LocationItem(
        id: 'loc-5',
        nameAr: 'الستين الغربي وشملان',
        nameEn: 'West 60th & Shamlan',
        parentId: 'loc-1',
        sortOrder: 5,
      ),
      LocationItem(
        id: 'loc-6',
        nameAr: 'محافظة عدن - المنصورة وخور مكسر',
        nameEn: 'Aden',
        sortOrder: 6,
      ),
    ];

    // Demo Admin & Demo Owner
    final demoOwner = UserProfile(
      id: 'demo-user-1',
      fullName: 'أحمد سيف المعمري',
      phone: '+967771234567',
      role: AppConstants.roleUser,
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    demoCurrentUser = UserProfile(
      id: 'demo-admin-1',
      fullName: 'مدير المنصة العام',
      phone: '+967770000000',
      role: AppConstants.roleSuperAdmin,
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    );

    // 3. Realistic Demo Properties in Yemen
    demoProperties = [
      Property(
        id: 'prop-1',
        ownerId: demoOwner.id,
        title: 'شقة فاخرة للإيجار السنوي في حدة بالقرب من شارع بغداد',
        description:
            'شقة سكنية راقية بتشطيب ديلوكس، مدخلين مستقلين، صالة استقبال ضيوف واسعة، مجلس مستقل مع حمام، جناح نوم رئيسي، ومطبخ راكب بنظام أمريكي حديث. خزان ماء مستقل وموقف سيارة مغطى.',
        dealType: AppConstants.dealRent,
        propertyTypeId: 'apartment',
        locationId: 'loc-2',
        city: 'صنعاء',
        district: 'حدة',
        addressDetails: 'حي السفارات القديم - خلف فندق القصر',
        latitude: 15.3188,
        longitude: 44.1853,
        price: 550,
        currency: AppConstants.currencyUsd,
        areaSqm: 185,
        bedrooms: 3,
        bathrooms: 2,
        contactPhone: '+967771234567',
        contactWhatsapp: '967771234567',
        status: AppConstants.statusPublished,
        isFeatured: true,
        viewsCount: 342,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        images: [
          PropertyImage(
            id: 'img-1-1',
            propertyId: 'prop-1',
            imageUrl:
                'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1200&q=80',
            isPrimary: true,
          ),
          PropertyImage(
            id: 'img-1-2',
            propertyId: 'prop-1',
            imageUrl:
                'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1200&q=80',
          ),
          PropertyImage(
            id: 'img-1-3',
            propertyId: 'prop-1',
            imageUrl:
                'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
          ),
        ],
        propertyType: demoPropertyTypes[0],
        owner: demoOwner,
      ),
      Property(
        id: 'prop-2',
        ownerId: demoOwner.id,
        title: 'فيلا مستقلة طابقين حجر أبيض أصيل في بيت بوس',
        description:
            'فيلا معمارية مميزة مبنية بحجر أبيض أصيل ونوافذ قمرية واسعة على الطراز الصنعاني الحديث. تتكون من طابقين وبدروم، حديقة منزلية مشجرة، حوش يتسع لثلاث سيارات، وخزان مياه أرضي كبير.',
        dealType: AppConstants.dealSale,
        propertyTypeId: 'villa',
        locationId: 'loc-4',
        city: 'صنعاء',
        district: 'بيت بوس',
        addressDetails: 'بالقرب من جولة كاك بنك - شارع 24',
        latitude: 15.2891,
        longitude: 44.1984,
        price: 380000,
        currency: AppConstants.currencyUsd,
        areaSqm: 420,
        bedrooms: 6,
        bathrooms: 5,
        contactPhone: '+967771234567',
        contactWhatsapp: '967771234567',
        status: AppConstants.statusPublished,
        isFeatured: true,
        viewsCount: 890,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        images: [
          PropertyImage(
            id: 'img-2-1',
            propertyId: 'prop-2',
            imageUrl:
                'https://images.unsplash.com/photo-1613977257363-707ba9348227?auto=format&fit=crop&w=1200&q=80',
            isPrimary: true,
          ),
          PropertyImage(
            id: 'img-2-2',
            propertyId: 'prop-2',
            imageUrl:
                'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
          ),
        ],
        propertyType: demoPropertyTypes[1],
        owner: demoOwner,
      ),
      Property(
        id: 'prop-3',
        ownerId: demoOwner.id,
        title: 'أرض سكنية تجارية ركنية في الأصبحي على شارعين',
        description:
            'قطعة أرض ممتازة بموقع استثماري واعد في الأصبحي. ركنية على شارع 16 وشارع 14، مسورة بالكامل ومملوكة ببصيرة شرعية موثقة ومعمدة رسمياً. جاهزة للبناء المباشر.',
        dealType: AppConstants.dealSale,
        propertyTypeId: 'land',
        locationId: 'loc-3',
        city: 'صنعاء',
        district: 'الأصبحي',
        addressDetails: 'خلف مركز المعلمين - المربع الذهبي',
        latitude: 15.3087,
        longitude: 44.2173,
        price: 180000000,
        currency: AppConstants.currencyYer,
        areaSqm: 360,
        bedrooms: 0,
        bathrooms: 0,
        contactPhone: '+967771234567',
        contactWhatsapp: '967771234567',
        status: AppConstants.statusPublished,
        isFeatured: false,
        viewsCount: 512,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        images: [
          PropertyImage(
            id: 'img-3-1',
            propertyId: 'prop-3',
            imageUrl:
                'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80',
            isPrimary: true,
          ),
        ],
        propertyType: demoPropertyTypes[2],
        owner: demoOwner,
      ),
      Property(
        id: 'prop-4',
        ownerId: demoOwner.id,
        title: 'محل تجاري بموقع حيوي على شارع الستين الغربي',
        description:
            'محل تجاري واسع بمساحة 65 متر مربع مع سدة مرتفعة (ميزانين)، واجهة زجاجية عريضة، وعداد كهرباء تجاري وخط مياه مستقل. مناسب لصيدلية أو معرض أو كافيه.',
        dealType: AppConstants.dealRent,
        propertyTypeId: 'shop',
        locationId: 'loc-5',
        city: 'صنعاء',
        district: 'الستين الغربي',
        addressDetails: 'تقاطع الستين مع شارع الرباط',
        latitude: 15.3620,
        longitude: 44.1750,
        price: 250000,
        currency: AppConstants.currencyYer,
        areaSqm: 65,
        bedrooms: 0,
        bathrooms: 1,
        contactPhone: '+967771234567',
        contactWhatsapp: '967771234567',
        status: AppConstants.statusPublished,
        isFeatured: false,
        viewsCount: 220,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        images: [
          PropertyImage(
            id: 'img-4-1',
            propertyId: 'prop-4',
            imageUrl:
                'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1200&q=80',
            isPrimary: true,
          ),
        ],
        propertyType: demoPropertyTypes[3],
        owner: demoOwner,
      ),
    ];

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
