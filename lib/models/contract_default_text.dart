import '../core/l10n/app_locale.dart';

/// Locale-specific text used when a new contract template is created.
///
/// The generated strings are stored as ordinary [PropertyContract] fields, so
/// a contract keeps the language it was created in even if the user later
/// switches the app locale. This is legal document content, not a UI label.
class ContractDefaultText {
  const ContractDefaultText({
    required this.rentTitle,
    required this.saleTitle,
    required this.ownerAddress,
    required this.monthlyPayment,
    required this.fullPayment,
    required this.oneYear,
    required this.permanentOwnership,
    required this.indefiniteEndDate,
    required this.utilities,
    required this.maintenance,
    required this.latePayment,
    required this.rentClauses,
    required this.saleClauses,
  });

  final String rentTitle;
  final String saleTitle;
  final String ownerAddress;
  final String monthlyPayment;
  final String fullPayment;
  final String oneYear;
  final String permanentOwnership;
  final String indefiniteEndDate;
  final String utilities;
  final String maintenance;
  final String latePayment;
  final List<String> rentClauses;
  final List<String> saleClauses;

  static const ContractDefaultText arabic = ContractDefaultText(
    rentTitle: 'عقد إيجار شرعي وقانوني',
    saleTitle: 'عقد بيع وشراء عقار',
    ownerAddress: 'صنعاء، الجمهورية اليمنية',
    monthlyPayment: 'شهرياً مقدماً',
    fullPayment: 'دفعة كاملة عند التوثيق',
    oneYear: 'سنة واحدة',
    permanentOwnership: 'تمليك نهائي',
    indefiniteEndDate: 'دائم',
    utilities: 'المستأجر بالكامل (كهرباء، ماء، خدمات نظافة)',
    maintenance: 'استلم المستأجر العين بحالة ممتازة وتعهد بتسليمها سليمة',
    latePayment: 'مهلة أسبوعين كحد أقصى وإلا يعتبر العقد مفسوخاً تلقائياً',
    rentClauses: [
      'استخدام العين المؤجرة للسكن العائلي فقط ولا يحق تحويلها لغرض تجاري أو غيره.',
      'عدم إحداث أي استحداثات أو تعديلات أو فتحات في الجدران إلا بإذن خطي من المالك.',
      'يلتزم المستأجر بسداد فواتير الكهرباء والماء والهاتف والخدمات أولاً بأول وتسليم إبراء ذمة عند الإخلاء.',
      'المؤجر غير مسؤول عن أي حوادث أو سرقات أو كوارث قدرية تقع داخل العين المؤجرة.',
    ],
    saleClauses: [
      'يقر البائع بخلو العقار من أي نزاع أو رهن أو حقوق للغير.',
      'يلتزم البائع بتسليم كافة بصائر وأصول ووثائق الملكية الشرعية للمشتري.',
    ],
  );

  static const ContractDefaultText english = ContractDefaultText(
    rentTitle: 'Legal lease contract',
    saleTitle: 'Property sale and purchase contract',
    ownerAddress: "Sana'a, Republic of Yemen",
    monthlyPayment: 'Monthly in advance',
    fullPayment: 'Full payment upon notarization',
    oneYear: 'One full year',
    permanentOwnership: 'Permanent ownership',
    indefiniteEndDate: 'Indefinite',
    utilities: 'Tenant bears all utility bills (electricity, water, sanitation)',
    maintenance:
        'The tenant received the property in excellent condition and undertakes to return it intact',
    latePayment:
        'A maximum grace period of two weeks; otherwise the contract is automatically terminated',
    rentClauses: [
      'The leased property may be used for family housing only and may not be converted to commercial or any other use.',
      "No alterations, modifications or openings in the walls may be made without the owner's written permission.",
      'The tenant shall pay electricity, water, telephone and service bills promptly and provide a clearance certificate upon vacating.',
      'The owner is not liable for any accidents, theft or force majeure events occurring inside the leased property.',
    ],
    saleClauses: [
      'The seller confirms that the property is free from any dispute, mortgage or third-party rights.',
      'The seller undertakes to hand over all title deeds, original documents and legal ownership papers to the buyer.',
    ],
  );

  /// Defaults for the active app locale, used at contract creation time.
  static ContractDefaultText forCurrentLocale() =>
      AppLocale.isArabic ? arabic : english;
}
