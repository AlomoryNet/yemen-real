// Yemen Real Estate Portal — بوابة اليمن العقارية
// Core Constants

import '../l10n/app_labels_en.dart';
import '../l10n/app_locale.dart';

class AppConstants {
  static const String appNameAr = 'بوابة اليمن العقارية';
  static const String appNameEn = 'Yemen Real Estate Portal';
  static const String appTaglineAr = 'منصتك الموثوقة للعقارات في اليمن';
  static const String appVersion = '1.3.0';

  // Developer & Copyright Branding
  static const String developerNameAr = 'شركة هيبه سوفت';
  static const String developerNameEn = 'Hiba Soft';
  static const String copyrightNoticeAr =
      'تم التطوير بواسطة شركة هيبه سوفت (Hiba Soft) — جميع الحقوق محفوظة © 2026';
  static const String copyrightNoticeEn =
      'Developed by Hiba Soft — All rights reserved © 2026';

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
    if (!AppLocale.isArabic) return AppLabelsEn.currency[code.toUpperCase()] ?? code;
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
    if (!AppLocale.isArabic) return AppLabelsEn.dealType[dealType] ?? dealType;
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
  static const String statusPending = 'pending';
  static const String statusPublished = 'published';
  static const String statusHidden = 'hidden';
  static const String statusArchived = 'archived';
  static const String statusRejected = 'rejected';

  static String getPropertyStatusNameAr(String status) {
    if (!AppLocale.isArabic) return AppLabelsEn.propertyStatus[status] ?? status;
    switch (status) {
      case statusDraft:
        return 'مسودة';
      case statusPending:
        return 'قيد المراجعة';
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
    if (!AppLocale.isArabic) return AppLabelsEn.rentalRequestStatus[status] ?? status;
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
    if (!AppLocale.isArabic) return AppLabelsEn.liableParty[party] ?? party;
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
    if (!AppLocale.isArabic) return AppLabelsEn.commissionStatus[status] ?? status;
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
    'أمانة العاصمة',
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
    'أمانة العاصمة': [
      'حدة',
      'السبعين',
      'الأصبحي',
      'بيت بوس',
      'عصر',
      'الستين الغربي',
      'الستين الجنوبي',
      'شيراتون',
      'الحصبة',
      'مذبح',
      'الروضة',
      'دار سلم',
      'نقم',
      'شميلة',
    ],
    'أمانة العاصمة صنعاء': [
      'حدة',
      'السبعين',
      'الأصبحي',
      'بيت بوس',
      'عصر',
      'الستين الغربي',
      'الستين الجنوبي',
      'شيراتون',
      'الحصبة',
      'مذبح',
      'الروضة',
      'دار سلم',
      'نقم',
      'شميلة',
    ],
    'صنعاء': [
      'بني مطر',
      'سنحان',
      'همدان',
      'بني حشيش',
      'بلاد الروس',
      'أرحب',
      'خولان',
      'الحيمة الداخلية',
      'الحيمة الخارجية',
      'مناخة',
    ],
    'محافظة صنعاء': [
      'بني مطر',
      'سنحان',
      'همدان',
      'بني حشيش',
      'بلاد الروس',
      'أرحب',
      'خولان',
      'الحيمة الداخلية',
      'الحيمة الخارجية',
      'مناخة',
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
      'صالة',
      'القاهرة',
      'المظفر',
      'الحوبان',
      'المسبح',
      'وادي القاضي',
      'عصيفرة',
      'بئر باشا',
      'الدحي',
      'حي الروضة',
    ],
    'حضرموت': [
      'المكلا',
      'سيئون',
      'الشرج',
      'الديس',
      'فوه',
      'بويش',
      'روكب',
      'الشحر',
      'تريم',
      'شبام',
      'القطن',
    ],
    'إب': [
      'الظهار',
      'المشنة',
      'حي الجامعة',
      'الميدان',
      'يريم',
      'جبلة',
      'السحول',
      'القاعدة',
      'بعدان',
      'حبيش',
    ],
    'الحديدة': [
      'الميناء',
      'الحوك',
      'الحالي',
      'شارع صنعاء',
      'شارع فلسطين',
      'باجل',
      'زبيد',
      'بيت الفقيه',
      'المراوعة',
    ],
    'مأرب': [
      'مدينة مأرب',
      'الوادي',
      'حريب',
      'الجوبة',
      'صرواح',
      'مدغل',
      'المجمع',
      'حي الروضة',
    ],
    'ذمار': [
      'مدينة ذمار',
      'معبر',
      'جهران',
      'الحداء',
      'عنس',
      'عتمة',
      'مغرب عنس',
      'حي الجامعة',
    ],
    'شبوة': [
      'عتق',
      'بيحان',
      'حبان',
      'ميفعة',
      'الروضة',
      'الصعيد',
      'نصاب',
    ],
    'لحج': [
      'الحوطة',
      'تبن',
      'ردفان',
      'طور الباحة',
      'يافع لبعوس',
      'الملاح',
      'صبر',
    ],
    'أبين': [
      'زنجبار',
      'خنفر',
      'جعار',
      'لودر',
      'مودية',
      'أحور',
      'المحفد',
    ],
    'صعدة': [
      'مدينة صعدة',
      'سحار',
      'الطلح',
      'الصفراء',
      'رازح',
      'حيدان',
      'باقم',
    ],
    'المهرة': [
      'الغيضة',
      'حوف',
      'سيحوت',
      'قشن',
      'شحن',
      'حصوين',
    ],
    'عمران': [
      'مدينة عمران',
      'خمر',
      'ثلاء',
      'ريدة',
      'حوث',
      'عيال سريح',
      'حبور ظليمة',
    ],
    'حجة': [
      'مدينة حجة',
      'عبس',
      'المحابشة',
      'كحلان عفار',
      'حرض',
      'ميدي',
    ],
    'البيضاء': [
      'مدينة البيضاء',
      'رداع',
      'مكيراس',
      'الزاهر',
      'ذي ناعم',
      'السوادية',
    ],
    'الضالع': [
      'مدينة الضالع',
      'قعطبة',
      'دمت',
      'جبن',
      'الأزارق',
      'جحاف',
    ],
    'ريمة': [
      'الجبين',
      'السلفية',
      'بلاد الطعام',
      'كسمة',
      'الجعفرية',
      'مزهر',
    ],
    'المحويت': [
      'مدينة المحويت',
      'شبام كوكبان',
      'الطويلة',
      'ملحان',
      'الرجم',
      'حفاش',
    ],
    'سقطرى': [
      'حديبو',
      'قلنسية',
      'نوجد',
      'دكسم',
      'مومي',
    ],
    'الجوف': [
      'الحزم',
      'المتون',
      'المصلوب',
      'برط العنان',
      'خب والشعف',
      'الزاهر',
    ],
  };

  static List<String> getDistrictsForGovernorate(String? gov) {
    if (gov == null || gov.isEmpty) return const [];
    for (final entry in governorateDistricts.entries) {
      if (gov == entry.key || gov.contains(entry.key) || entry.key.contains(gov)) {
        return entry.value;
      }
    }
    return const [];
  }

  static const Map<String, (double, double)> governorateCoordinates = {
    'أمانة العاصمة': (15.3547, 44.2075),
    'صنعاء': (15.2200, 44.3500),
    'عدن': (12.8250, 45.0100),
    'تعز': (13.5789, 44.0219),
    'حضرموت': (14.5425, 49.1242),
    'إب': (13.9667, 44.1833),
    'الحديدة': (14.7978, 42.9545),
    'مأرب': (15.4624, 45.3258),
    'ذمار': (14.5427, 44.4051),
    'شبوة': (14.5377, 46.8319),
    'لحج': (13.0583, 44.8828),
    'أبين': (13.1287, 45.3805),
    'صعدة': (16.9402, 43.7639),
    'المهرة': (16.2079, 52.1760),
    'عمران': (15.6594, 43.9439),
    'حجة': (15.6942, 43.6021),
    'البيضاء': (13.9852, 45.5727),
    'الضالع': (13.6957, 44.7314),
    'ريمة': (14.6289, 43.7128),
    'المحويت': (15.4701, 43.5449),
    'سقطرى': (12.6500, 54.0167),
    'الجوف': (16.1404, 44.9609),
  };

  static (double, double) getCoordinatesForGovernorate(String? gov) {
    if (gov == null || gov.isEmpty) {
      return (15.3547, 44.2075);
    }
    for (final entry in governorateCoordinates.entries) {
      if (gov == entry.key || gov.contains(entry.key) || entry.key.contains(gov)) {
        return entry.value;
      }
    }
    return (15.3547, 44.2075);
  }
}
