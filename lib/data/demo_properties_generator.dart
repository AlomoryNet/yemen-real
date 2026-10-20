import 'dart:math' as math;
import '../core/constants/app_constants.dart';
import '../models/property.dart';
import '../models/property_image.dart';

class YemenGovInfo {
  final String name;
  final String slug;
  final double latitude;
  final double longitude;
  final double defaultZoom;
  final List<String> districts;

  const YemenGovInfo({
    required this.name,
    required this.slug,
    required this.latitude,
    required this.longitude,
    this.defaultZoom = 12.5,
    required this.districts,
  });
}

class DemoPropertiesGenerator {
  static const String demoOwnerId = '5356d901-f84f-4be0-80d4-60e19771ad08';
  static const String demoPhone = '+967770000000';
  static const String demoWhatsapp = '967770000000';

  static const List<YemenGovInfo> allGovernorates = [
    YemenGovInfo(
      name: 'أمانة العاصمة',
      slug: 'sanaa_capital',
      latitude: 15.3547,
      longitude: 44.2075,
      defaultZoom: 12.5,
      districts: [
        'حدة',
        'السبعين',
        'الأصبحي',
        'بيت بوس',
        'عصر',
        'شيراتون',
        'الحصبة',
        'مذبح',
        'الروضة',
        'شميلة',
        'نقم',
        'دار سلم',
      ],
    ),
    YemenGovInfo(
      name: 'صنعاء',
      slug: 'sanaa_gov',
      latitude: 15.2200,
      longitude: 44.3500,
      defaultZoom: 11.5,
      districts: [
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
    ),
    YemenGovInfo(
      name: 'عدن',
      slug: 'aden',
      latitude: 12.8250,
      longitude: 45.0100,
      defaultZoom: 12.5,
      districts: [
        'المعلا',
        'كريتر',
        'خور مكسر',
        'المنصورة',
        'الشيخ عثمان',
        'التواهي',
        'البريقة',
        'مدينة إنماء',
        'كابوتا',
        'الممدارة',
      ],
    ),
    YemenGovInfo(
      name: 'تعز',
      slug: 'taiz',
      latitude: 13.5789,
      longitude: 44.0219,
      defaultZoom: 13.0,
      districts: [
        'صالة',
        'القاهرة',
        'المظفر',
        'الحوبان',
        'المسبح',
        'وادي القاضي',
        'عصيفرة',
        'بئر باشا',
        'الدحي',
        'الروضة',
      ],
    ),
    YemenGovInfo(
      name: 'حضرموت',
      slug: 'hadramout',
      latitude: 14.5425,
      longitude: 49.1242,
      defaultZoom: 12.0,
      districts: [
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
    ),
    YemenGovInfo(
      name: 'إب',
      slug: 'ibb',
      latitude: 13.9667,
      longitude: 44.1833,
      defaultZoom: 13.0,
      districts: [
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
    ),
    YemenGovInfo(
      name: 'الحديدة',
      slug: 'hodeidah',
      latitude: 14.7978,
      longitude: 42.9545,
      defaultZoom: 12.5,
      districts: [
        'الميناء',
        'الحوك',
        'الحالي',
        'باجل',
        'زبيد',
        'بيت الفقيه',
        'الدريهمي',
        'المراوعة',
        'الزيدية',
      ],
    ),
    YemenGovInfo(
      name: 'مأرب',
      slug: 'marib',
      latitude: 15.4624,
      longitude: 45.3258,
      defaultZoom: 12.5,
      districts: [
        'مدينة مأرب',
        'الوادي',
        'حريب',
        'الجوبة',
        'صرواح',
        'مدغل',
        'رغوان',
        'مجزر',
      ],
    ),
    YemenGovInfo(
      name: 'ذمار',
      slug: 'dhamar',
      latitude: 14.5427,
      longitude: 44.4051,
      defaultZoom: 13.0,
      districts: [
        'مدينة ذمار',
        'معبر',
        'جهران',
        'الحداء',
        'عنس',
        'عتمة',
        'مغرب عنس',
        'ضوران آنس',
      ],
    ),
    YemenGovInfo(
      name: 'شبوة',
      slug: 'shabwah',
      latitude: 14.5377,
      longitude: 46.8319,
      defaultZoom: 12.5,
      districts: [
        'عتق',
        'بيحان',
        'حبان',
        'ميفعة',
        'الروضة',
        'الصعيد',
        'نصاب',
        'عين',
      ],
    ),
    YemenGovInfo(
      name: 'لحج',
      slug: 'lahj',
      latitude: 13.0583,
      longitude: 44.8828,
      defaultZoom: 12.5,
      districts: [
        'الحوطة',
        'تبن',
        'ردفان',
        'طور الباحة',
        'يافع لبعوس',
        'يهر',
        'الملاح',
        'حبيل جبر',
      ],
    ),
    YemenGovInfo(
      name: 'أبين',
      slug: 'abyan',
      latitude: 13.1287,
      longitude: 45.3805,
      defaultZoom: 12.5,
      districts: [
        'زنجبار',
        'خنفر',
        'جعار',
        'لودر',
        'مودية',
        'أحور',
        'المحفد',
        'رصد',
      ],
    ),
    YemenGovInfo(
      name: 'صعدة',
      slug: 'saada',
      latitude: 16.9402,
      longitude: 43.7639,
      defaultZoom: 12.5,
      districts: [
        'مدينة صعدة',
        'سحار',
        'الطلح',
        'الصفراء',
        'رازح',
        'حيدان',
        'باقم',
        'منبه',
      ],
    ),
    YemenGovInfo(
      name: 'المهرة',
      slug: 'almahrah',
      latitude: 16.2079,
      longitude: 52.1760,
      defaultZoom: 12.0,
      districts: [
        'الغيضة',
        'حوف',
        'سيحوت',
        'قشن',
        'شحن',
        'حصوين',
        'المسيلة',
        'منعر',
      ],
    ),
    YemenGovInfo(
      name: 'عمران',
      slug: 'amran',
      latitude: 15.6594,
      longitude: 43.9439,
      defaultZoom: 12.5,
      districts: [
        'مدينة عمران',
        'خمر',
        'ثلاء',
        'ريدة',
        'حوث',
        'عيال سريح',
        'حبور ظليمة',
        'شهارة',
      ],
    ),
    YemenGovInfo(
      name: 'حجة',
      slug: 'hajjah',
      latitude: 15.6942,
      longitude: 43.6021,
      defaultZoom: 12.5,
      districts: [
        'مدينة حجة',
        'عبس',
        'المحابشة',
        'كحلان عفار',
        'حرض',
        'ميدي',
        'مستبأ',
        'كعيدنة',
      ],
    ),
    YemenGovInfo(
      name: 'البيضاء',
      slug: 'albayda',
      latitude: 13.9852,
      longitude: 45.5727,
      defaultZoom: 12.5,
      districts: [
        'مدينة البيضاء',
        'رداع',
        'مكيراس',
        'الزاهر',
        'ذي ناعم',
        'السوادية',
        'الطفة',
        'ولد ربيع',
      ],
    ),
    YemenGovInfo(
      name: 'الضالع',
      slug: 'aldhalee',
      latitude: 13.6957,
      longitude: 44.7314,
      defaultZoom: 12.5,
      districts: [
        'مدينة الضالع',
        'قعطبة',
        'دمت',
        'جبن',
        'الأزارق',
        'جحاف',
        'الحصين',
      ],
    ),
    YemenGovInfo(
      name: 'ريمة',
      slug: 'raymah',
      latitude: 14.6289,
      longitude: 43.7128,
      defaultZoom: 12.0,
      districts: [
        'الجبين',
        'السلفية',
        'بلاد الطعام',
        'كسمة',
        'الجعفرية',
        'مزهر',
      ],
    ),
    YemenGovInfo(
      name: 'المحويت',
      slug: 'almahweet',
      latitude: 15.4701,
      longitude: 43.5449,
      defaultZoom: 12.5,
      districts: [
        'مدينة المحويت',
        'شبام كوكبان',
        'الطويلة',
        'ملحان',
        'الرجم',
        'حفاش',
        'الخبت',
      ],
    ),
    YemenGovInfo(
      name: 'سقطرى',
      slug: 'socotra',
      latitude: 12.6500,
      longitude: 54.0167,
      defaultZoom: 11.0,
      districts: [
        'حديبو',
        'قلنسية',
        'نوجد',
        'دكسم',
        'مومي',
        'قاضب',
      ],
    ),
    YemenGovInfo(
      name: 'الجوف',
      slug: 'aljawf',
      latitude: 16.1404,
      longitude: 44.9609,
      defaultZoom: 11.5,
      districts: [
        'الحزم',
        'المتون',
        'المصلوب',
        'برط العنان',
        'خب والشعف',
        'الزاهر',
        'رجوزة',
      ],
    ),
  ];

  static const List<String> sampleImages = [
    'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1000&q=80',
    'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1000&q=80',
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1000&q=80',
    'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1000&q=80',
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1000&q=80',
    'https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=1000&q=80',
    'https://images.unsplash.com/photo-1582407947304-fd86f028f716?auto=format&fit=crop&w=1000&q=80',
    'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=1000&q=80',
    'https://images.unsplash.com/photo-1570129477492-45c003edd2be?auto=format&fit=crop&w=1000&q=80',
    'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=1000&q=80',
  ];

  /// Generate exactly 20 diverse, realistic demo properties for each of the 22 governorates
  /// Total: 22 * 20 = 440 properties
  static List<Property> generateAllDemoProperties() {
    final List<Property> list = [];
    int globalIndex = 1;

    for (int g = 0; g < allGovernorates.length; g++) {
      final gov = allGovernorates[g];
      for (int i = 1; i <= 20; i++) {
        final propId = 'd3300000-0000-0000-${(g + 1).toString().padLeft(4, '0')}-${i.toString().padLeft(12, '0')}';
        final district = gov.districts[(i - 1) % gov.districts.length];

        // Property types: 1-8 apartment, 9-12 villa, 13-16 shop, 17-18 land, 19-20 office
        String pTypeId;
        String pTypeNameAr;
        if (i <= 8) {
          pTypeId = 'apartment';
          pTypeNameAr = 'شقة سكنية';
        } else if (i <= 12) {
          pTypeId = 'villa';
          pTypeNameAr = 'فيلا مستقلة';
        } else if (i <= 16) {
          pTypeId = 'shop';
          pTypeNameAr = 'محل تجاري';
        } else if (i <= 18) {
          pTypeId = 'land';
          pTypeNameAr = 'أرض استثمارية';
        } else {
          pTypeId = 'office';
          pTypeNameAr = 'مكتب تجاري';
        }

        // Deal type: odd = rent, even = sale
        final bool isRent = (i % 2 == 1);
        final String dealType = isRent ? AppConstants.dealRent : AppConstants.dealSale;

        // Pricing logic
        double price;
        String currency;
        if (isRent) {
          if (pTypeId == 'apartment') {
            price = 70000.0 + (i * 12000.0);
            currency = AppConstants.currencyYer;
          } else if (pTypeId == 'villa') {
            price = 400.0 + (i * 35.0);
            currency = AppConstants.currencyUsd;
          } else if (pTypeId == 'shop') {
            price = 90000.0 + (i * 15000.0);
            currency = AppConstants.currencyYer;
          } else if (pTypeId == 'office') {
            price = 120000.0 + (i * 18000.0);
            currency = AppConstants.currencyYer;
          } else {
            price = 50000.0 + (i * 10000.0);
            currency = AppConstants.currencyYer;
          }
        } else {
          // Sale
          if (pTypeId == 'apartment') {
            price = 22000000.0 + (i * 2500000.0);
            currency = AppConstants.currencyYer;
          } else if (pTypeId == 'villa') {
            price = 95000.0 + (i * 12000.0);
            currency = AppConstants.currencyUsd;
          } else if (pTypeId == 'shop') {
            price = 18000000.0 + (i * 2000000.0);
            currency = AppConstants.currencyYer;
          } else if (pTypeId == 'land') {
            price = 8500000.0 + (i * 1500000.0);
            currency = AppConstants.currencyYer;
          } else {
            price = 28000000.0 + (i * 3000000.0);
            currency = AppConstants.currencyYer;
          }
        }

        // Realistic coordinates offset within city bounds (tight cluster < 3.5km from center)
        final double angle = (i * 18.0) * (math.pi / 180.0);
        final double radius = 0.005 + ((i % 5) * 0.003);
        final double lat = gov.latitude + (radius * math.sin(angle));
        final double lng = gov.longitude + (radius * math.cos(angle));

        // Area & Specs
        final double areaSqm = pTypeId == 'land'
            ? (250.0 + (i * 30.0))
            : pTypeId == 'villa'
                ? (320.0 + (i * 25.0))
                : (110.0 + (i * 8.0));

        final int bedrooms = pTypeId == 'land' || pTypeId == 'shop'
            ? 0
            : pTypeId == 'villa'
                ? (4 + (i % 3))
                : (2 + (i % 3));

        final int bathrooms = pTypeId == 'land'
            ? 0
            : pTypeId == 'shop'
                ? 1
                : (1 + (i % 3));

        final title = 'عرض تجريبي — ليس إعلانًا حقيقيًا — $pTypeNameAr ${isRent ? 'للإيجار' : 'للبيع'} في $district';
        final description =
            'عرض تجريبي مخصص لاختبار خريطة اليمن العقارية ومنظومة البحث. العقار يقع في $district بـ ${gov.name}. يحتوي على تشطيب ممتاز وموقع هادئ. تنبيه: هذا العرض مخصص لأغراض العرض التجريبي والاختبار فقط ولا يمثل إعلاناً حقيقياً.';

        final img1 = sampleImages[(globalIndex) % sampleImages.length];
        final img2 = sampleImages[(globalIndex + 1) % sampleImages.length];

        final property = Property(
          id: propId,
          ownerId: demoOwnerId,
          title: title,
          description: description,
          dealType: dealType,
          propertyTypeId: pTypeId,
          city: gov.name,
          district: district,
          addressDetails: '$district — حي الهدوء التجريبي $i',
          latitude: double.parse(lat.toStringAsFixed(6)),
          longitude: double.parse(lng.toStringAsFixed(6)),
          price: price,
          currency: currency,
          areaSqm: areaSqm,
          bedrooms: bedrooms,
          bathrooms: bathrooms,
          contactPhone: demoPhone,
          contactWhatsapp: demoWhatsapp,
          status: AppConstants.statusPublished,
          publishingMode: 'self_review',
          isFeatured: (i % 5 == 0),
          viewsCount: 25 + (i * 7),
          hasOwnershipPledge: true,
          createdAt: DateTime.now().subtract(Duration(days: (i * 2))),
          images: [
            PropertyImage(
              id: 'd330img-${(g + 1)}-$i-1',
              propertyId: propId,
              imageUrl: img1,
              isPrimary: true,
              sortOrder: 1,
            ),
            PropertyImage(
              id: 'd330img-${(g + 1)}-$i-2',
              propertyId: propId,
              imageUrl: img2,
              isPrimary: false,
              sortOrder: 2,
            ),
          ],
        );

        list.add(property);
        globalIndex++;
      }
    }

    return list;
  }
}
