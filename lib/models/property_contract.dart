// Yemen Real Estate Portal — بوابة اليمن العقارية
// Property Contract Model — نموذج عقد الإيجار والبيع اليمني القابل للتشكيل والطباعة

class PropertyContract {
  final String id;
  final String propertyId;
  final String contractType; // 'rent' or 'sale'
  final String title;

  // الطرف الأول (المؤجر / البائع)
  final String ownerName;
  final String ownerIdCard;
  final String ownerPhone;
  final String ownerAddress;

  // الطرف الثاني (المستأجر / المشتري)
  final String tenantName;
  final String tenantIdCard;
  final String tenantPhone;
  final String tenantAddress;

  // بيانات العين المؤجرة / العقار
  final String propertyCity;
  final String propertyDistrict;
  final String propertyAddressDetails;
  final String propertyDescription;

  // الأمور المالية
  final double amount; // الإيجار أو ثمن البيع
  final String currency; // YER, SAR, USD
  final String paymentFrequency; // شهرياً, سنوياً, نصف سنوي, دفعة واحدة
  final double securityDeposit; // مبلغ التأمين / الضمان

  // المدة والتواريخ
  final String durationText; // سنة كاملة, سنتان, إلخ
  final String startDate;
  final String endDate;

  // البنود والشروط المحددة من المؤجر
  final bool isRenewableOnlyByOwner; // غير قابلة للتجديد إلا برغبة الطرف الأول
  final bool forbidSubleasing; // منع التقبيل أو التأجير من الباطن نهائياً
  final String
  utilitiesPayableBy; // فواتير الكهرباء والماء والنظافة (المستأجر / المؤجر)
  final String maintenanceLiability; // التزامات الصيانة والمحافظة على العين
  final String latePaymentPolicy; // مهلة التأخير (أسبوعين قبل إلغاء العقد)
  final List<String> customClauses; // شروط إضافية مخصصة يحددها المؤجر

  final bool isSavedAsDefaultTemplate;
  final DateTime createdAt;

  const PropertyContract({
    required this.id,
    required this.propertyId,
    this.contractType = 'rent',
    this.title = 'عقد إيجار شرعي وقانوني موثق',
    this.ownerName = '',
    this.ownerIdCard = '',
    this.ownerPhone = '',
    this.ownerAddress = 'صنعاء، الجمهورية اليمنية',
    this.tenantName = '',
    this.tenantIdCard = '',
    this.tenantPhone = '',
    this.tenantAddress = '',
    this.propertyCity = 'صنعاء',
    this.propertyDistrict = 'حدة',
    this.propertyAddressDetails = '',
    this.propertyDescription = '',
    this.amount = 0.0,
    this.currency = 'USD',
    this.paymentFrequency = 'شهرياً مقدماً',
    this.securityDeposit = 0.0,
    this.durationText = 'سنة كاملة',
    this.startDate = '',
    this.endDate = '',
    this.isRenewableOnlyByOwner = true,
    this.forbidSubleasing = true,
    this.utilitiesPayableBy = 'المستأجر بالكامل (كهرباء، ماء، خدمات نظافة)',
    this.maintenanceLiability =
        'استلم المستأجر العين بحالة ممتازة وتعهد بتسليمها سليمة',
    this.latePaymentPolicy =
        'مهلة أسبوعين كحد أقصى وإلا يعتبر العقد مفسوخاً تلقائياً',
    this.customClauses = const [],
    this.isSavedAsDefaultTemplate = false,
    required this.createdAt,
  });

  factory PropertyContract.defaultTemplate({
    required String propertyId,
    String ownerName = '',
    String ownerPhone = '',
    String city = 'صنعاء',
    String district = '',
    double price = 0,
    String currency = 'USD',
    String dealType = 'rent',
  }) {
    final now = DateTime.now();
    final nextYear = DateTime(now.year + 1, now.month, now.day);
    final isRent = dealType == 'rent';

    return PropertyContract(
      id: 'contract-${DateTime.now().millisecondsSinceEpoch}',
      propertyId: propertyId,
      contractType: dealType,
      title: isRent ? 'عقد إيجار شرعي وقانوني' : 'عقد بيع وشراء عقار',
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      propertyCity: city,
      propertyDistrict: district,
      amount: price,
      currency: currency,
      paymentFrequency: isRent ? 'شهرياً مقدماً' : 'دفعة كاملة عند التوثيق',
      durationText: isRent ? 'سنة واحدة' : 'تمليك نهائي',
      startDate: '${now.year}/${now.month}/${now.day}',
      endDate: isRent
          ? '${nextYear.year}/${nextYear.month}/${nextYear.day}'
          : 'دائم',
      securityDeposit: isRent ? price : 0.0,
      customClauses: isRent
          ? [
              'استخدام العين المؤجرة للسكن العائلي فقط ولا يحق تحويلها لغرض تجاري أو غيره.',
              'عدم إحداث أي استحداثات أو تعديلات أو فتحات في الجدران إلا بإذن خطي من المالك.',
              'يلتزم المستأجر بسداد فواتير الكهرباء والماء والهاتف والخدمات أولاً بأول وتسليم إبراء ذمة عند الإخلاء.',
              'المؤجر غير مسؤول عن أي حوادث أو سرقات أو كوارث قدرية تقع داخل العين المؤجرة.',
            ]
          : [
              'يقر البائع بخلو العقار من أي نزاع أو رهن أو حقوق للغير.',
              'يلتزم البائع بتسليم كافة بصائر وأصول ووثائق الملكية الشرعية للمشتري.',
            ],
      createdAt: now,
    );
  }

  PropertyContract copyWith({
    String? id,
    String? propertyId,
    String? contractType,
    String? title,
    String? ownerName,
    String? ownerIdCard,
    String? ownerPhone,
    String? ownerAddress,
    String? tenantName,
    String? tenantIdCard,
    String? tenantPhone,
    String? tenantAddress,
    String? propertyCity,
    String? propertyDistrict,
    String? propertyAddressDetails,
    String? propertyDescription,
    double? amount,
    String? currency,
    String? paymentFrequency,
    double? securityDeposit,
    String? durationText,
    String? startDate,
    String? endDate,
    bool? isRenewableOnlyByOwner,
    bool? forbidSubleasing,
    String? utilitiesPayableBy,
    String? maintenanceLiability,
    String? latePaymentPolicy,
    List<String>? customClauses,
    bool? isSavedAsDefaultTemplate,
    DateTime? createdAt,
  }) {
    return PropertyContract(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      contractType: contractType ?? this.contractType,
      title: title ?? this.title,
      ownerName: ownerName ?? this.ownerName,
      ownerIdCard: ownerIdCard ?? this.ownerIdCard,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerAddress: ownerAddress ?? this.ownerAddress,
      tenantName: tenantName ?? this.tenantName,
      tenantIdCard: tenantIdCard ?? this.tenantIdCard,
      tenantPhone: tenantPhone ?? this.tenantPhone,
      tenantAddress: tenantAddress ?? this.tenantAddress,
      propertyCity: propertyCity ?? this.propertyCity,
      propertyDistrict: propertyDistrict ?? this.propertyDistrict,
      propertyAddressDetails:
          propertyAddressDetails ?? this.propertyAddressDetails,
      propertyDescription: propertyDescription ?? this.propertyDescription,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      durationText: durationText ?? this.durationText,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isRenewableOnlyByOwner:
          isRenewableOnlyByOwner ?? this.isRenewableOnlyByOwner,
      forbidSubleasing: forbidSubleasing ?? this.forbidSubleasing,
      utilitiesPayableBy: utilitiesPayableBy ?? this.utilitiesPayableBy,
      maintenanceLiability: maintenanceLiability ?? this.maintenanceLiability,
      latePaymentPolicy: latePaymentPolicy ?? this.latePaymentPolicy,
      customClauses: customClauses ?? this.customClauses,
      isSavedAsDefaultTemplate:
          isSavedAsDefaultTemplate ?? this.isSavedAsDefaultTemplate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'contract_type': contractType,
      'title': title,
      'owner_name': ownerName,
      'owner_id_card': ownerIdCard,
      'owner_phone': ownerPhone,
      'owner_address': ownerAddress,
      'tenant_name': tenantName,
      'tenant_id_card': tenantIdCard,
      'tenant_phone': tenantPhone,
      'tenant_address': tenantAddress,
      'property_city': propertyCity,
      'property_district': propertyDistrict,
      'property_address_details': propertyAddressDetails,
      'property_description': propertyDescription,
      'amount': amount,
      'currency': currency,
      'payment_frequency': paymentFrequency,
      'security_deposit': securityDeposit,
      'duration_text': durationText,
      'start_date': startDate,
      'end_date': endDate,
      'is_renewable_only_by_owner': isRenewableOnlyByOwner,
      'forbid_subleasing': forbidSubleasing,
      'utilities_payable_by': utilitiesPayableBy,
      'maintenance_liability': maintenanceLiability,
      'late_payment_policy': latePaymentPolicy,
      'custom_clauses': customClauses,
      'is_saved_as_default_template': isSavedAsDefaultTemplate,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PropertyContract.fromJson(Map<String, dynamic> json) {
    return PropertyContract(
      id: json['id'] as String? ?? 'contract-1',
      propertyId: json['property_id'] as String? ?? '',
      contractType: json['contract_type'] as String? ?? 'rent',
      title: json['title'] as String? ?? 'عقد إيجار شرعي وقانوني',
      ownerName: json['owner_name'] as String? ?? '',
      ownerIdCard: json['owner_id_card'] as String? ?? '',
      ownerPhone: json['owner_phone'] as String? ?? '',
      ownerAddress: json['owner_address'] as String? ?? '',
      tenantName: json['tenant_name'] as String? ?? '',
      tenantIdCard: json['tenant_id_card'] as String? ?? '',
      tenantPhone: json['tenant_phone'] as String? ?? '',
      tenantAddress: json['tenant_address'] as String? ?? '',
      propertyCity: json['property_city'] as String? ?? '',
      propertyDistrict: json['property_district'] as String? ?? '',
      propertyAddressDetails: json['property_address_details'] as String? ?? '',
      propertyDescription: json['property_description'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      paymentFrequency: json['payment_frequency'] as String? ?? 'شهرياً مقدماً',
      securityDeposit: (json['security_deposit'] as num?)?.toDouble() ?? 0.0,
      durationText: json['duration_text'] as String? ?? 'سنة كاملة',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      isRenewableOnlyByOwner:
          json['is_renewable_only_by_owner'] as bool? ?? true,
      forbidSubleasing: json['forbid_subleasing'] as bool? ?? true,
      utilitiesPayableBy: json['utilities_payable_by'] as String? ?? '',
      maintenanceLiability: json['maintenance_liability'] as String? ?? '',
      latePaymentPolicy: json['late_payment_policy'] as String? ?? '',
      customClauses:
          (json['custom_clauses'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isSavedAsDefaultTemplate:
          json['is_saved_as_default_template'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
