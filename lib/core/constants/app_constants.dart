// Yemen Real Estate Portal — بوابة اليمن العقارية
// Core Constants

class AppConstants {
  static const String appNameAr = 'بوابة اليمن العقارية';
  static const String appNameEn = 'Yemen Real Estate Portal';
  static const String appTaglineAr = 'منصتك الموثوقة للعقارات في اليمن';
  static const String appVersion = '1.0.0';

  // Developer & Copyright Branding
  static const String developerNameAr = 'شركة هيبه سوفت';
  static const String developerNameEn = 'Hiba Soft';
  static const String copyrightNoticeAr = 'تم التطوير بواسطة شركة هيبه سوفت (Hiba Soft) — جميع الحقوق محفوظة © 2026';
  static const String copyrightNoticeEn = 'Developed by Hiba Soft — All rights reserved © 2026';

  // Supported Currencies
  static const String currencyYer = 'YER';
  static const String currencySar = 'SAR';
  static const String currencyUsd = 'USD';

  static const List<String> supportedCurrencies = [
    currencyYer,
    currencySar,
    currencyUsd,
  ];

  static String getCurrencyNameAr(String code) {
    switch (code.toUpperCase()) {
      case currencyYer:
        return 'ريال يمني';
      case currencySar:
        return 'ريال سعودي';
      case currencyUsd:
        return 'دولار أمريكي';
      default:
        return code;
    }
  }

  // Deal Types
  static const String dealSale = 'sale';
  static const String dealRent = 'rent';

  static String getDealTypeNameAr(String dealType) {
    switch (dealType) {
      case dealSale:
        return 'للبيع';
      case dealRent:
        return 'للإيجار';
      default:
        return dealType;
    }
  }

  // Property Status
  static const String statusDraft = 'draft';
  static const String statusPublished = 'published';
  static const String statusHidden = 'hidden';
  static const String statusArchived = 'archived';
  static const String statusRejected = 'rejected';

  static String getPropertyStatusNameAr(String status) {
    switch (status) {
      case statusDraft:
        return 'مسودة';
      case statusPublished:
        return 'منشور';
      case statusHidden:
        return 'مخفي';
      case statusArchived:
        return 'مؤرشف';
      case statusRejected:
        return 'مرفوض';
      default:
        return status;
    }
  }

  // Rental Request Status
  static const String reqStatusNew = 'new';
  static const String reqStatusUnderReview = 'under_review';
  static const String reqStatusContacted = 'contacted';
  static const String reqStatusProvisionallyAccepted = 'provisionally_accepted';
  static const String reqStatusRejected = 'rejected';
  static const String reqStatusCancelled = 'cancelled';
  static const String reqStatusCompleted = 'completed';

  static String getRentalRequestStatusNameAr(String status) {
    switch (status) {
      case reqStatusNew:
        return 'جديد';
      case reqStatusUnderReview:
        return 'قيد المراجعة';
      case reqStatusContacted:
        return 'تم التواصل';
      case reqStatusProvisionallyAccepted:
        return 'مقبول مبدئياً';
      case reqStatusRejected:
        return 'مرفوض';
      case reqStatusCancelled:
        return 'ملغي';
      case reqStatusCompleted:
        return 'مكتمل';
      default:
        return status;
    }
  }

  // Commission Liable Parties
  static const String liableSeller = 'seller';
  static const String liableBuyer = 'buyer';
  static const String liableBoth = 'both';

  static String getLiablePartyNameAr(String party) {
    switch (party) {
      case liableSeller:
        return 'البائع';
      case liableBuyer:
        return 'المشتري / المستأجر';
      case liableBoth:
        return 'كلاهما (البائع والمشتري)';
      default:
        return party;
    }
  }

  // Commission Settlement Status
  static const String commStatusDue = 'due';
  static const String commStatusPaid = 'paid';
  static const String commStatusCancelled = 'cancelled';

  static String getCommissionStatusNameAr(String status) {
    switch (status) {
      case commStatusDue:
        return 'مستحق';
      case commStatusPaid:
        return 'مسدد';
      case commStatusCancelled:
        return 'ملغى';
      default:
        return status;
    }
  }

  // User Roles
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';
  static const String roleSuperAdmin = 'super_admin';

  // Storage
  static const String propertyImagesBucket = 'property-images';
  static const int maxImageSizeInBytes = 5 * 1024 * 1024; // 5 MB

  // Yemeni Governorates & Popular Districts
  static const List<String> yemeniGovernorates = [
    'صنعاء',
    'عدن',
    'تعز',
    'حضرموت',
    'إب',
    'الحديدة',
    'مأرب',
    'ذمار',
    'شبوة',
    'لحج',
    'أبين',
    'صعدة',
    'المهرة',
    'عمران',
    'حجة',
    'البيضاء',
    'الضالع',
    'ريمة',
    'المحويت',
    'سقطرى',
    'الجوف',
  ];

  static const Map<String, List<String>> governorateDistricts = {
    'صنعاء': [
      'حدة',
      'الأصبحي',
      'بيت بوس',
      'السبعين',
      'عصر',
      'الستين الغربي',
      'الستين الجنوبي',
      'شيراتون',
      'الحصبة',
      'مذبح',
      'الروضة',
      'دار سلم',
      'بني حشيش',
      'نقم',
      'شميلة',
    ],
    'عدن': [
      'المعلا',
      'كريتر',
      'خور مكسر',
      'المنصورة',
      'الشيخ عثمان',
      'التواهي',
      'مدينة إنماء',
      'البريقة',
      'كابوتا',
      'الممدارة',
    ],
    'تعز': [
      'الحوبان',
      'المسبح',
      'وادي القاضي',
      'صالة',
      'التحرير',
      'الدحي',
      'عصيفرة',
      'بئر باشا',
      'حي الروضة',
    ],
    'حضرموت': [
      'المكلا',
      'الشرج',
      'الديس',
      'فوه',
      'بويش',
      'روكب',
      'سيئون',
      'تريم',
      'الشحر',
      'القطن',
      'شبام',
    ],
    'إب': [
      'المشنة',
      'الظهار',
      'حي الجامعة',
      'الميدان',
      'القاعدة',
      'يريم',
      'السحول',
      'جبلة',
    ],
    'الحديدة': [
      'الحوك',
      'الميناء',
      'الحالي',
      'شارع صنعاء',
      'شارع فلسطين',
      'كيلو 16',
      'باجل',
      'زبيد',
    ],
    'مأرب': [
      'المدينة',
      'الوادي',
      'المجمع',
      'حي الروضة',
      'حي الزراعة',
    ],
    'ذمار': [
      'المدينة',
      'الدائري الغربي',
      'حي الجامعة',
      'معبر',
      'عنس',
    ],
    'شبوة': [
      'عتق',
      'بيحان',
      'حبان',
      'نصاب',
    ],
    'لحج': [
      'الحوطة',
      'تبن',
      'صبر',
      'يافع',
    ],
    'أبين': [
      'زنجبار',
      'خنفر',
      'جعار',
      'لودر',
    ],
    'صعدة': [
      'المدينة',
      'سحار',
      'الطلح',
    ],
    'المهرة': [
      'الغيضة',
      'حوف',
      'شحن',
      'سيحوت',
    ],
  };

  static List<String> getDistrictsForGovernorate(String? gov) {
    if (gov == null || gov.isEmpty) return const [];
    // Try exact match or match if gov starts with key
    for (final entry in governorateDistricts.entries) {
      if (gov.contains(entry.key) || entry.key.contains(gov)) {
        return entry.value;
      }
    }
    return const [];
  }
}

