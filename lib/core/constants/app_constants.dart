// Yemen Real Estate Portal — بوابة اليمن العقارية
// Core Constants

class AppConstants {
  static const String appNameAr = 'بوابة اليمن العقارية';
  static const String appNameEn = 'Yemen Real Estate Portal';
  static const String appTaglineAr = 'منصتك الموثوقة للعقارات في اليمن';
  static const String appVersion = '1.0.0';

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
}
