import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/property.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../data/demo_properties_generator.dart';
import '../services/map_cluster_service.dart';

class GovernorateBoundary {
  final String englishName;
  final String arabicName;
  final List<List<LatLng>> polygonRings;

  const GovernorateBoundary({
    required this.englishName,
    required this.arabicName,
    required this.polygonRings,
  });
}

class YemenGovernorateCoord {
  final String name;
  final double latitude;
  final double longitude;
  final double defaultZoom;

  const YemenGovernorateCoord({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.defaultZoom = 12.5,
  });
}

class YemenMapScreen extends ConsumerStatefulWidget {
  const YemenMapScreen({super.key});

  @override
  ConsumerState<YemenMapScreen> createState() => _YemenMapScreenState();
}

class _YemenMapScreenState extends ConsumerState<YemenMapScreen>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  Property? _selectedProperty;
  String _selectedDealType = ''; // '' = all, 'sale', 'rent'
  String? _selectedTypeId; // null = all
  String? _selectedGovName; // null = all yemen
  String? _selectedDistrict; // null = all districts
  double? _minPrice;
  double? _maxPrice;
  int? _minBedrooms;
  bool _onlyExactCoordinates = false;

  bool _isListView = false;
  bool _showSearchThisAreaBtn = false;
  double _currentZoom = 7.5;
  LatLng? _lastSearchCenter;
  Timer? _debounceTimer;
  int _activeCardImageIndex = 0;
  bool _isSatellite = false;

  // Freehand Map Drawing Mode
  bool _isDrawingMode = false;
  List<LatLng> _drawnPolygon = [];

  // Official Yemen GeoJSON Boundaries (Loaded from downloaded asset)
  List<GovernorateBoundary> _governorateBoundaries = [];
  bool _isLoadingGeoJson = false;

  static const List<YemenGovernorateCoord> _governorates = [
    YemenGovernorateCoord(
      name: 'أمانة العاصمة',
      latitude: 15.3547,
      longitude: 44.2075,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'صنعاء',
      latitude: 15.2200,
      longitude: 44.3500,
      defaultZoom: 11.5,
    ),
    YemenGovernorateCoord(
      name: 'عدن',
      latitude: 12.8250,
      longitude: 45.0100,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'تعز',
      latitude: 13.5789,
      longitude: 44.0219,
      defaultZoom: 13.0,
    ),
    YemenGovernorateCoord(
      name: 'حضرموت',
      latitude: 14.5425,
      longitude: 49.1242,
      defaultZoom: 12.0,
    ),
    YemenGovernorateCoord(
      name: 'إب',
      latitude: 13.9667,
      longitude: 44.1833,
      defaultZoom: 13.0,
    ),
    YemenGovernorateCoord(
      name: 'الحديدة',
      latitude: 14.7978,
      longitude: 42.9545,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'مأرب',
      latitude: 15.4624,
      longitude: 45.3258,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'ذمار',
      latitude: 14.5427,
      longitude: 44.4051,
      defaultZoom: 13.0,
    ),
    YemenGovernorateCoord(
      name: 'شبوة',
      latitude: 14.5377,
      longitude: 46.8319,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'لحج',
      latitude: 13.0583,
      longitude: 44.8828,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'أبين',
      latitude: 13.1287,
      longitude: 45.3805,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'صعدة',
      latitude: 16.9402,
      longitude: 43.7639,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'المهرة',
      latitude: 16.2079,
      longitude: 52.1760,
      defaultZoom: 12.0,
    ),
    YemenGovernorateCoord(
      name: 'عمران',
      latitude: 15.6594,
      longitude: 43.9439,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'حجة',
      latitude: 15.6942,
      longitude: 43.6021,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'البيضاء',
      latitude: 13.9852,
      longitude: 45.5727,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'الضالع',
      latitude: 13.6957,
      longitude: 44.7314,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'ريمة',
      latitude: 14.6289,
      longitude: 43.7128,
      defaultZoom: 12.0,
    ),
    YemenGovernorateCoord(
      name: 'المحويت',
      latitude: 15.4701,
      longitude: 43.5449,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'سقطرى',
      latitude: 12.6500,
      longitude: 54.0167,
      defaultZoom: 11.0,
    ),
    YemenGovernorateCoord(
      name: 'الجوف',
      latitude: 16.1404,
      longitude: 44.9609,
      defaultZoom: 11.5,
    ),
  ];

  static const LatLng _yemenCenter = LatLng(15.3547, 44.2075);
  static const double _initialZoom = 7.5;

  static const Map<String, String> _shapeNameToArabic = {
    'Sanʿaʾ': 'أمانة العاصمة',
    'Sanʿaʾ Governorate': 'صنعاء',
    'Lahij Governorate': 'لحج',
    '‘Adan Governorate': 'عدن',
    'Al Hudaydah Governorate': 'الحديدة',
    'Ta\'izz Governorate': 'تعز',
    'Shabwah Governorate': 'شبوة',
    'Hadhramaut': 'حضرموت',
    'Abyan Governorate': 'أبين',
    'Al Jawf Governorate': 'الجوف',
    'Ibb Governorate': 'إب',
    'Al Bayda\' Governorate': 'البيضاء',
    'Ad Dali\' Governorate': 'الضالع',
    'Al Mahwit Governorate': 'المحويت',
    'Sa\'dah Governorate': 'صعدة',
    'Hajjah Governorate': 'حجة',
    'Dhamar Governorate': 'ذمار',
    '\'Amran Governorate': 'عمران',
    'Al Mahrah Governorate': 'المهرة',
    'Ma\'rib Governorate': 'مأرب',
    'Raymah Governorate': 'ريمة',
    'Socotra': 'سقطرى',
  };

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _lastSearchCenter = _yemenCenter;
    _currentZoom = _initialZoom;
    _loadYemenGeoJsonBoundaries();
  }

  Future<void> _loadYemenGeoJsonBoundaries() async {
    if (_isLoadingGeoJson || _governorateBoundaries.isNotEmpty) return;
    _isLoadingGeoJson = true;
    try {
      final jsonStr = await rootBundle.loadString('assets/map/yemen_adm1_simplified.geojson');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>;
      final List<GovernorateBoundary> loaded = [];

      for (final f in features) {
        final props = f['properties'] as Map<String, dynamic>;
        final shapeName = props['shapeName']?.toString() ?? '';
        final arabicName = _shapeNameToArabic[shapeName] ?? shapeName;
        final geom = f['geometry'] as Map<String, dynamic>;
        final type = geom['type']?.toString();
        final coords = geom['coordinates'] as List<dynamic>;

        final List<List<LatLng>> rings = [];
        if (type == 'Polygon') {
          for (final ring in coords) {
            final points = (ring as List<dynamic>).map((pt) {
              final lon = (pt[0] as num).toDouble();
              final lat = (pt[1] as num).toDouble();
              return LatLng(lat, lon);
            }).toList();
            if (points.isNotEmpty) rings.add(points);
          }
        } else if (type == 'MultiPolygon') {
          for (final poly in coords) {
            for (final ring in poly as List<dynamic>) {
              final points = (ring as List<dynamic>).map((pt) {
                final lon = (pt[0] as num).toDouble();
                final lat = (pt[1] as num).toDouble();
                return LatLng(lat, lon);
              }).toList();
              if (points.isNotEmpty) rings.add(points);
            }
          }
        }

        if (rings.isNotEmpty) {
          loaded.add(GovernorateBoundary(
            englishName: shapeName,
            arabicName: arabicName,
            polygonRings: rings,
          ));
        }
      }

      if (mounted) {
        setState(() {
          _governorateBoundaries = loaded;
        });
      }
    } catch (e) {
      debugPrint('Error loading Yemen GeoJSON: $e');
    } finally {
      _isLoadingGeoJson = false;
    }
  }

  void _showOfflineMapDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F766E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.map_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'خريطة الجمهورية اليمنية المعتمدة (أوفلاين)',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.pinch_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'يمكنك تكبير وتصغير الخريطة باللمس أو الماوس',
                      style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 5.0,
                    child: Image.asset(
                      'assets/images/yemen_map_hd.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/yemen_map.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: destZoom,
    );

    final controller = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _selectGovernorate(YemenGovernorateCoord? gov) {
    setState(() {
      _selectedGovName = gov?.name;
      _selectedDistrict = null;
      _selectedProperty = null;
      _showSearchThisAreaBtn = false;
      _drawnPolygon.clear();
      _isDrawingMode = false;
      if (gov != null) {
        _searchController.text = gov.name;
      } else {
        _searchController.clear();
      }
    });

    if (gov != null) {
      _animatedMapMove(
        LatLng(gov.latitude, gov.longitude),
        gov.defaultZoom,
      );
      _lastSearchCenter = LatLng(gov.latitude, gov.longitude);
    } else {
      _animatedMapMove(_yemenCenter, 7.0);
      _lastSearchCenter = _yemenCenter;
    }
  }

  (double, double) _getPropertyCoords(Property prop) {
    return MapClusterService.getPropertyCoordinates(prop);
  }

  // Point in polygon ray-casting test for freehand drawing filter
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return true;
    bool inside = false;
    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; i++) {
      final xi = polygon[i].latitude;
      final yi = polygon[i].longitude;
      final xj = polygon[j].latitude;
      final yj = polygon[j].longitude;

      final intersect = ((yi > point.longitude) != (yj > point.longitude)) &&
          (point.latitude < (xj - xi) * (point.longitude - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
      j = i;
    }
    return inside;
  }

  List<Property> _filterProperties(List<Property> all) {
    final query = _searchController.text.trim().toLowerCase();

    return all.where((p) {
      if (p.status != AppConstants.statusPublished) return false;

      // Filter deal type
      if (_selectedDealType.isNotEmpty && p.dealType != _selectedDealType) {
        return false;
      }

      // Filter property type
      if (_selectedTypeId != null &&
          _selectedTypeId!.isNotEmpty &&
          p.propertyTypeId != _selectedTypeId) {
        return false;
      }

      // Filter governorate
      if (_selectedGovName != null && _selectedGovName!.isNotEmpty) {
        final matchesCity = p.city == _selectedGovName ||
            p.city.contains(_selectedGovName!) ||
            _selectedGovName!.contains(p.city);
        if (!matchesCity) return false;
      }

      // Filter district
      if (_selectedDistrict != null && _selectedDistrict!.isNotEmpty) {
        final matchesDist = p.district == _selectedDistrict ||
            p.district.contains(_selectedDistrict!) ||
            _selectedDistrict!.contains(p.district);
        if (!matchesDist) return false;
      }

      // Filter text query (city, district, addressDetails, title)
      if (query.isNotEmpty) {
        final inCity = p.city.toLowerCase().contains(query);
        final inDist = p.district.toLowerCase().contains(query);
        final inTitle = p.title.toLowerCase().contains(query);
        final inAddr = (p.addressDetails ?? '').toLowerCase().contains(query);
        if (!inCity && !inDist && !inTitle && !inAddr) return false;
      }

      // Filter price
      if (_minPrice != null && p.price < _minPrice!) return false;
      if (_maxPrice != null && p.price > _maxPrice!) return false;

      // Filter bedrooms
      if (_minBedrooms != null && p.bedrooms < _minBedrooms!) return false;

      // Filter exact coordinates only
      if (_onlyExactCoordinates && !MapClusterService.hasExactCoordinates(p)) {
        return false;
      }

      // Filter by custom drawn polygon if active
      if (_drawnPolygon.length > 2) {
        final coords = _getPropertyCoords(p);
        if (!_isPointInPolygon(LatLng(coords.$1, coords.$2), _drawnPolygon)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  String _formatPriceTag(Property p) {
    final cur = p.currency == AppConstants.currencyYer
        ? 'ر.ي'
        : p.currency == AppConstants.currencyUsd
            ? '\$'
            : 'ر.س';

    final isRent = p.dealType == AppConstants.dealRent;
    final suffix = isRent ? '/شهرياً' : '';

    if (p.price >= 1000000) {
      final millions =
          (p.price / 1000000).toStringAsFixed(1).replaceAll('.0', '');
      return '$millions م $cur $suffix'.trim();
    } else if (p.price >= 1000) {
      final thousands = (p.price / 1000).toStringAsFixed(0);
      return '$thousands ألف $cur $suffix'.trim();
    }
    return '${p.price.toStringAsFixed(0)} $cur $suffix'.trim();
  }

  Future<void> _makeCall(String phone) async {
    final clean = Formatters.formatPhoneForDialing(phone);
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// فتح Google Maps للملاحة إلى موقع العقار الحقيقي
  Future<void> _openGoogleMapsNavigation(Property prop) async {
    final lat = prop.latitude;
    final lng = prop.longitude;

    if (lat == null || lng == null || lat == 0.0 || lng == 0.0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لم يتم تحديد موقع هذا العقار على الخريطة بعد. يرجى التواصل مع صاحب العقار لتحديد الموقع.',
              style: GoogleFonts.cairo(fontSize: 13),
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'اتصال',
              textColor: Colors.white,
              onPressed: () => _makeCall(prop.contactPhone),
            ),
          ),
        );
      }
      return;
    }

    // رابط Google Maps للملاحة بإحداثيات العقار الحقيقية
    final googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
    // رابط بديل يفتح موقع العقار مباشرة عبر تطبيق الملاحة
    final googleMapsAppUrl = 'google.navigation:q=$lat,$lng&mode=d';
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');

    try {
      // محاولة فتح تطبيق Google Maps للملاحة مباشرة
      final appUri = Uri.parse(googleMapsAppUrl);
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    try {
      // محاولة فتح تطبيق الخرائط عبر بروتوكول geo المعتمد
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    // فتح رابط Google Maps عبر المتصفح كبديل
    try {
      final webUri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر فتح خرائط Google. تأكد من تثبيت التطبيق أو الاتصال بالإنترنت.',
              style: GoogleFonts.cairo(fontSize: 13),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phone, String title) async {
    final cleanPhone = Formatters.formatPhoneForWhatsApp(phone);
    final msg = Uri.encodeComponent(
      'السلام عليكم، بخصوص العقار المعروض في بوابة اليمن العقارية: $title',
    );
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String tempDeal = _selectedDealType;
        String? tempType = _selectedTypeId;
        String? tempGov = _selectedGovName;
        String? tempDist = _selectedDistrict;
        int? tempBeds = _minBedrooms;
        double? tempMinPrice = _minPrice;
        double? tempMaxPrice = _maxPrice;
        bool tempExactGps = _onlyExactCoordinates;

        final minController = TextEditingController(
          text: _minPrice != null ? _minPrice!.toStringAsFixed(0) : '',
        );
        final maxController = TextEditingController(
          text: _maxPrice != null ? _maxPrice!.toStringAsFixed(0) : '',
        );

        return StatefulBuilder(
          builder: (context, setModalState) {
            final availableDistricts = tempGov != null
                ? AppConstants.getDistrictsForGovernorate(tempGov)
                : const <String>[];

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded, color: Color(0xFF0D6EFD)),
                      const SizedBox(width: 8),
                      Text(
                        'تصفية خريطة العقارات (Filters)',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempDeal = '';
                            tempType = null;
                            tempGov = null;
                            tempDist = null;
                            tempBeds = null;
                            tempMinPrice = null;
                            tempMaxPrice = null;
                            tempExactGps = false;
                            minController.clear();
                            maxController.clear();
                          });
                        },
                        child: Text(
                          'إعادة ضبط',
                          style: GoogleFonts.cairo(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Deal Type
                          Text(
                            'نوع المعاملة',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildFilterOption(
                                label: 'الكل',
                                isSelected: tempDeal == '',
                                onTap: () => setModalState(() => tempDeal = ''),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterOption(
                                label: 'للبيع',
                                isSelected: tempDeal == AppConstants.dealSale,
                                onTap: () => setModalState(
                                    () => tempDeal = AppConstants.dealSale),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterOption(
                                label: 'للإيجار',
                                isSelected: tempDeal == AppConstants.dealRent,
                                onTap: () => setModalState(
                                    () => tempDeal = AppConstants.dealRent),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 2. Property Type
                          Text(
                            'نوع العقار',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildFilterOption(
                                label: 'الكل',
                                isSelected: tempType == null,
                                onTap: () => setModalState(() => tempType = null),
                              ),
                              _buildFilterOption(
                                label: 'شقق سكنية',
                                isSelected: tempType == 'apartment',
                                onTap: () =>
                                    setModalState(() => tempType = 'apartment'),
                              ),
                              _buildFilterOption(
                                label: 'فلل ومنازل',
                                isSelected: tempType == 'villa',
                                onTap: () => setModalState(() => tempType = 'villa'),
                              ),
                              _buildFilterOption(
                                label: 'محلات تجارية',
                                isSelected: tempType == 'shop',
                                onTap: () => setModalState(() => tempType = 'shop'),
                              ),
                              _buildFilterOption(
                                label: 'أراضٍ',
                                isSelected: tempType == 'land',
                                onTap: () => setModalState(() => tempType = 'land'),
                              ),
                              _buildFilterOption(
                                label: 'عمارات ومباني',
                                isSelected: tempType == 'building',
                                onTap: () =>
                                    setModalState(() => tempType = 'building'),
                              ),
                              _buildFilterOption(
                                label: 'مكاتب تجارية',
                                isSelected: tempType == 'office',
                                onTap: () => setModalState(() => tempType = 'office'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 3. Governorate Selector
                          Text(
                            'المحافظة',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 38,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildFilterOption(
                                  label: 'كافة المحافظات 🇾🇪',
                                  isSelected: tempGov == null,
                                  onTap: () => setModalState(() {
                                    tempGov = null;
                                    tempDist = null;
                                  }),
                                ),
                                const SizedBox(width: 6),
                                for (final gov in _governorates) ...[
                                  _buildFilterOption(
                                    label: gov.name,
                                    isSelected: tempGov == gov.name,
                                    onTap: () => setModalState(() {
                                      tempGov = gov.name;
                                      tempDist = null;
                                    }),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 4. District Selector (Appears if governorate selected)
                          if (tempGov != null && availableDistricts.isNotEmpty) ...[
                            Text(
                              'المديرية في $tempGov',
                              style:
                                  GoogleFonts.cairo(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildFilterOption(
                                  label: 'كافة مديريات $tempGov',
                                  isSelected: tempDist == null,
                                  onTap: () =>
                                      setModalState(() => tempDist = null),
                                ),
                                for (final dist in availableDistricts)
                                  _buildFilterOption(
                                    label: dist,
                                    isSelected: tempDist == dist,
                                    onTap: () =>
                                        setModalState(() => tempDist = dist),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          // 5. Price Range
                          Text(
                            'نطاق السعر',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: minController,
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.cairo(fontSize: 13),
                                  decoration: InputDecoration(
                                    labelText: 'الحد الأدنى',
                                    labelStyle: GoogleFonts.cairo(fontSize: 12),
                                    hintText: '0',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  onChanged: (val) {
                                    tempMinPrice = double.tryParse(val.trim());
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: maxController,
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.cairo(fontSize: 13),
                                  decoration: InputDecoration(
                                    labelText: 'الحد الأقصى',
                                    labelStyle: GoogleFonts.cairo(fontSize: 12),
                                    hintText: 'بلا سقف',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  onChanged: (val) {
                                    tempMaxPrice = double.tryParse(val.trim());
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 6. Bedrooms
                          Text(
                            'عدد الغرف على الأقل',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              for (final b in [null, 1, 2, 3, 4, 5])
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: _buildFilterOption(
                                    label: b == null ? 'الكل' : '$b+',
                                    isSelected: tempBeds == b,
                                    onTap: () => setModalState(() => tempBeds = b),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 7. Verified GPS Switch
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.gps_fixed,
                                  color: Color(0xFF0F766E),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'إحداثيات GPS دقيقة فقط',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                      Text(
                                        'إخفاء العقارات ذات المواقع التقريبية',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: tempExactGps,
                                  activeColor: const Color(0xFF0D6EFD),
                                  onChanged: (val) {
                                    setModalState(() {
                                      tempExactGps = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6EFD),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedDealType = tempDeal;
                          _selectedTypeId = tempType;
                          _selectedGovName = tempGov;
                          _selectedDistrict = tempDist;
                          _minBedrooms = tempBeds;
                          _minPrice = tempMinPrice;
                          _maxPrice = tempMaxPrice;
                          _onlyExactCoordinates = tempExactGps;
                          _selectedProperty = null;

                          if (tempGov != null) {
                            _searchController.text = tempGov!;
                            final govCoord = _governorates.firstWhere(
                              (g) => g.name == tempGov,
                              orElse: () => _governorates.first,
                            );
                            _animatedMapMove(
                              LatLng(govCoord.latitude, govCoord.longitude),
                              govCoord.defaultZoom,
                            );
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'تطبيق الفلاتر',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D6EFD) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D6EFD) : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(allMapPropertiesProvider);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentRoute: '/map'),
      body: propertiesAsync.when(
        data: (allProperties) {
          final effectiveList = allProperties.isNotEmpty
              ? allProperties
              : DemoPropertiesGenerator.generateAllDemoProperties();

          final filteredProperties = _filterProperties(effectiveList);
          final clusters = MapClusterService.clusterProperties(
            properties: filteredProperties,
            zoom: _currentZoom,
          );

          return Stack(
            children: [
              // 1. Full Screen Interactive Map or List View
              if (!_isListView)
                GestureDetector(
                  // Handlers for freehand drawing feature
                  onPanStart: _isDrawingMode
                      ? (details) {
                          final latLng = _mapController.camera
                              .offsetToCrs(details.localPosition);
                          setState(() {
                            _drawnPolygon = [latLng];
                          });
                        }
                      : null,
                  onPanUpdate: _isDrawingMode
                      ? (details) {
                          final latLng = _mapController.camera
                              .offsetToCrs(details.localPosition);
                          setState(() {
                            _drawnPolygon.add(latLng);
                          });
                        }
                      : null,
                  onPanEnd: _isDrawingMode
                      ? (details) {
                          if (_drawnPolygon.length > 2) {
                            setState(() {
                              _isDrawingMode = false;
                            });
                          }
                        }
                      : null,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _yemenCenter,
                      initialZoom: _initialZoom,
                      minZoom: 5.0,
                      maxZoom: 18.0,
                      interactionOptions: InteractionOptions(
                        flags: _isDrawingMode
                            ? InteractiveFlag.none
                            : InteractiveFlag.all,
                      ),
                      onPositionChanged: (pos, hasGesture) {
                        if (pos.zoom != _currentZoom) {
                          setState(() {
                            _currentZoom = pos.zoom;
                          });
                        }
                        if (hasGesture && !_isDrawingMode) {
                          _debounceTimer?.cancel();
                          _debounceTimer =
                              Timer(const Duration(milliseconds: 350), () {
                            if (mounted) {
                              final dist = _lastSearchCenter != null
                                  ? const Distance().as(
                                      LengthUnit.Kilometer,
                                      _lastSearchCenter!,
                                      pos.center,
                                    )
                                  : 0;
                              if (dist > 3.0) {
                                setState(() {
                                  _showSearchThisAreaBtn = true;
                                });
                              }
                            }
                          });
                        }
                      },
                      onTap: (tapPosition, point) {
                        if (_selectedProperty != null) {
                          setState(() {
                            _selectedProperty = null;
                          });
                        }
                      },
                    ),
                    children: [
                      // OpenStreetMap — بلاطات مجانية مفتوحة بلا مفتاح API
                      TileLayer(
                        urlTemplate: _isSatellite
                            ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                            : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.yemenreal.portal',
                        maxZoom: 19,
                        // OpenStreetMap مجاني ومفتوح — لا يحتاج مفتاح API
                        additionalOptions: const {
                          'attribution': '© OpenStreetMap contributors',
                        },
                      ),

                      // Official Yemen Governorate Boundaries from downloaded GeoJSON
                      if (_governorateBoundaries.isNotEmpty)
                        PolygonLayer(
                          polygons: _governorateBoundaries.expand((gov) {
                            final isSelected = _selectedGovName != null &&
                                (gov.arabicName == _selectedGovName ||
                                    gov.arabicName.contains(_selectedGovName!) ||
                                    _selectedGovName!.contains(gov.arabicName));
                            return gov.polygonRings.map((ring) {
                              return Polygon(
                                points: ring,
                                color: isSelected
                                    ? const Color(0xFF0D6EFD).withAlpha(45)
                                    : Colors.transparent,
                                borderColor: isSelected
                                    ? const Color(0xFF0D6EFD)
                                    : const Color(0xFF4A5568).withAlpha(120),
                                borderStrokeWidth: isSelected ? 2.8 : 1.2,
                              );
                            });
                          }).toList(),
                        ),

                      // Drawn Polygon Layer
                      if (_drawnPolygon.isNotEmpty)
                        PolygonLayer(
                          polygons: [
                            Polygon(
                              points: _drawnPolygon,
                              color: const Color(0xFF0D6EFD).withAlpha(45),
                              borderColor: const Color(0xFF0D6EFD),
                              borderStrokeWidth: 3.0,
                            ),
                          ],
                        ),

                      // Dynamic Spatial Clustering Layer (Yemen Portal Blue Brand)
                      MarkerLayer(
                        markers: clusters.map((cluster) {
                          if (cluster.isSingle) {
                            final prop = cluster.singleProperty;
                            final isSelected = _selectedProperty?.id == prop.id;
                            final priceText = _formatPriceTag(prop);
                            final isRent = prop.dealType == AppConstants.dealRent;
                            final hasExact = MapClusterService.hasExactCoordinates(prop);

                            return Marker(
                              point: cluster.centroid,
                              width: isSelected ? 160 : 140,
                              height: isSelected ? 74 : 66,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedProperty = prop;
                                    _activeCardImageIndex = 0;
                                  });
                                  _animatedMapMove(
                                    LatLng(cluster.centroid.latitude, cluster.centroid.longitude),
                                    math.max(_currentZoom, 14.5),
                                  );
                                },
                                child: _buildPropertyPriceMarker(
                                  priceText: priceText,
                                  isSelected: isSelected,
                                  isRent: isRent,
                                  hasExact: hasExact,
                                ),
                              ),
                            );
                          } else {
                            final count = cluster.count;
                            return Marker(
                              point: cluster.centroid,
                              width: count >= 100 ? 60 : (count >= 10 ? 54 : 48),
                              height: count >= 100 ? 60 : (count >= 10 ? 54 : 48),
                              child: GestureDetector(
                                onTap: () {
                                  if (cluster.latSpan > 0.0003 || cluster.lngSpan > 0.0003 || _currentZoom < 15.0) {
                                    final nextZoom = math.min(_currentZoom + 2.5, 16.5);
                                    _animatedMapMove(cluster.centroid, nextZoom);
                                  } else {
                                    _showClusterPropertiesBottomSheet(cluster.properties);
                                  }
                                },
                                child: _buildYemenPortalClusterBadge(
                                  count: count,
                                ),
                              ),
                            );
                          }
                        }).toList(),
                      ),
                    ],
                  ),
                )
              else
                // Synced List View
                Container(
                  color: AppColors.background,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 100,
                  ),
                  child: filteredProperties.isEmpty
                      ? _buildEmptyAreaView()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredProperties.length,
                          itemBuilder: (context, index) {
                            final prop = filteredProperties[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: _buildSelectedPropertyCard(
                                prop,
                                onSelectOnMap: () {
                                  setState(() {
                                    _isListView = false;
                                    _selectedProperty = prop;
                                    _activeCardImageIndex = 0;
                                  });
                                  final coords = _getPropertyCoords(prop);
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    _animatedMapMove(
                                      LatLng(coords.$1, coords.$2),
                                      15.0,
                                    );
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),

              // 2. Unified Top Search & Filters Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildMapHeader(),
              ),

              // 3. Drawing Mode Instruction Banner
              if (_isDrawingMode)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 96,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D6EFD),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.draw_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'المس واسحب بإصبعك على الخريطة لرسم حدود المنطقة المطلوبة',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isDrawingMode = false;
                              _drawnPolygon.clear();
                            });
                          },
                          child: Text(
                            'إلغاء',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 4. Active Drawn Polygon Filter Badge
              if (_drawnPolygon.isNotEmpty && !_isDrawingMode)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 96,
                  left: 16,
                  right: 16,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF0D6EFD),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF0D6EFD),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'تم حصر البحث بالرسم (${filteredProperties.length} عقار)',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0D6EFD),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _drawnPolygon.clear();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 5. "Search this area" Button
              if (_showSearchThisAreaBtn && !_isListView && !_isDrawingMode)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 96,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0D6EFD),
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: Color(0xFF0D6EFD),
                            width: 1.5,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text(
                        'البحث في هذه المنطقة',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _lastSearchCenter = _mapController.camera.center;
                          _showSearchThisAreaBtn = false;
                        });
                      },
                    ),
                  ),
                ),

              // 6. Floating Bottom Map Controls (Clean, Non-overlapping, RTL-friendly)
              // A. Property Count Badge (Bottom-Right in RTL)
              if (!_isListView)
                Positioned(
                  bottom: _selectedProperty != null ? 360 : 70,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.apartment_rounded,
                          size: 15,
                          color: Color(0xFF0D6EFD),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${filteredProperties.length} عقار متاح',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // B. Layers / Satellite Toggle Button (Bottom-Left in RTL)
              if (!_isListView)
                Positioned(
                  bottom: _selectedProperty != null ? 360 : 70,
                  left: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'map_layers_toggle',
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 3,
                    tooltip: _isSatellite ? 'تبديل إلى خريطة الشوارع' : 'تبديل إلى قمر صناعي',
                    onPressed: () {
                      setState(() {
                        _isSatellite = !_isSatellite;
                      });
                    },
                    child: Icon(
                      _isSatellite ? Icons.map_rounded : Icons.satellite_alt_rounded,
                      size: 20,
                      color: _isSatellite ? const Color(0xFF0D6EFD) : const Color(0xFF0F172A),
                    ),
                  ),
                ),

              // C. Primary Center Toggle: "عرض القائمة" / "عرض الخريطة"
              Positioned(
                bottom: _selectedProperty != null ? 360 : 16,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton.icon(
                    key: const ValueKey('map_list_toggle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    icon: Icon(
                      _isListView
                          ? Icons.map_rounded
                          : Icons.format_list_bulleted_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isListView
                          ? 'عرض الخريطة'
                          : 'عرض القائمة',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isListView = !_isListView;
                      });
                    },
                  ),
                ),
              ),

              // 8. Selected Property Card
              if (_selectedProperty != null && !_isListView)
                Positioned(
                  bottom: 10,
                  left: isMobile ? 8 : 20,
                  right: isMobile ? 8 : 20,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: _buildSelectedPropertyCard(_selectedProperty!),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  'تعذر تحميل الخريطة. يمكنك استخدام العرض البديل.',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.refresh(allMapPropertiesProvider),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Unified Map Header & Filter Bar (RTL, Responsive, High Contrast)
  Widget _buildMapHeader() {
    final authState = ref.watch(authProvider);

    final hasActiveFilters = _selectedTypeId != null ||
        _minBedrooms != null ||
        _selectedGovName != null ||
        _selectedDistrict != null ||
        _minPrice != null ||
        _maxPrice != null ||
        _onlyExactCoordinates ||
        _selectedDealType.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Title Badge
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 2),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Color(0xFF0D6EFD)),
                  const SizedBox(width: 4),
                  Text(
                    'خريطة اليمن',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D6EFD),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'العقارات المتاحة للبيع والإيجار',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Row 1: Back Button + Search Input + Menu + User Account
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
              child: Row(
                children: [
                  // Back Button (Returns to Home)
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    tooltip: 'العودة للرئيسية',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                  const SizedBox(width: 4),

                  // Search Field (Independent from buttons)
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: AppColors.primary,
                            size: 19,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'ابحث بالمحافظة، الحي، أو اسم العقار...',
                                hintStyle: GoogleFonts.cairo(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (val) => setState(() {}),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchController.clear();
                                  _selectedGovName = null;
                                  _selectedDistrict = null;
                                });
                              },
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.grey,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Menu / Drawer Button
                  Builder(
                    builder: (btnCtx) => IconButton(
                      icon: const Icon(
                        Icons.menu_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      tooltip: 'القائمة الرئيسية',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      onPressed: () => Scaffold.of(btnCtx).openDrawer(),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // User Avatar / Login
                  GestureDetector(
                    onTap: () {
                      if (authState.isAuthenticated) {
                        context.push('/profile');
                      } else {
                        context.push('/login');
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: authState.isAuthenticated
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: authState.isAuthenticated
                              ? AppColors.primary
                              : Colors.grey.shade400,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: authState.isAuthenticated
                          ? Text(
                              authState.user?.fullName.isNotEmpty == true
                                  ? authState.user!.fullName.substring(0, 1)
                                  : 'ح',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // Row 2: شريط الفلاتر والتصنيفات — قابل للتمرير بدون تداخل
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                children: [
                  // 1. زر الفلاتر الشاملة
                  _buildFilterBarBtn(
                    label: hasActiveFilters ? 'الفلاتر ✓' : 'الفلاتر',
                    icon: Icons.tune,
                    isActive: hasActiveFilters,
                    onTap: _showFilterModal,
                  ),
                  const SizedBox(width: 6),

                  // 2. نوع المعاملة
                  _buildDealTypeDropdown(),
                  const SizedBox(width: 6),

                  // 3. نوع العقار
                  _buildPropertyTypeDropdown(),
                  const SizedBox(width: 6),

                  // 4. رسم المنطقة
                  _buildFilterBarBtn(
                    label: _drawnPolygon.isNotEmpty ? 'مسح الرسم' : 'رسم منطقة',
                    icon: _drawnPolygon.isNotEmpty ? Icons.close_rounded : Icons.draw_rounded,
                    isActive: _isDrawingMode || _drawnPolygon.isNotEmpty,
                    onTap: () {
                      if (_drawnPolygon.isNotEmpty) {
                        setState(() {
                          _drawnPolygon.clear();
                          _isDrawingMode = false;
                        });
                      } else {
                        setState(() {
                          _isDrawingMode = !_isDrawingMode;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 6),

                  // 5. خريطة اليمن الرسمية
                  _buildFilterBarBtn(
                    label: 'خريطة اليمن 🇾🇪',
                    icon: Icons.map_rounded,
                    isActive: false,
                    onTap: _showOfflineMapDialog,
                  ),
                  const SizedBox(width: 6),

                  // فاصل عمودي
                  Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 6),

                  // 5. جميع المحافظات
                  _buildGovernorateChip(
                    label: 'كافة المحافظات 🇾🇪',
                    isSelected: _selectedGovName == null,
                    onTap: () => _selectGovernorate(null),
                  ),

                  // 6. المحافظات
                  for (final gov in _governorates) ...[  
                    const SizedBox(width: 5),
                    _buildGovernorateChip(
                      label: gov.name,
                      isSelected: _selectedGovName == gov.name,
                      onTap: () => _selectGovernorate(gov),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildDealTypeDropdown() {
    final label = _selectedDealType == AppConstants.dealSale
        ? 'للبيع'
        : _selectedDealType == AppConstants.dealRent
            ? 'للإيجار'
            : 'الكل (بيع/إيجار)';
    final isFiltered = _selectedDealType.isNotEmpty;

    return PopupMenuButton<String>(
      onSelected: (val) {
        setState(() {
          _selectedDealType = val;
        });
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: '',
          child: Text('الكل (بيع وإيجار)', style: GoogleFonts.cairo(fontSize: 12)),
        ),
        PopupMenuItem(
          value: AppConstants.dealSale,
          child: Text('للبيع فقط', style: GoogleFonts.cairo(fontSize: 12)),
        ),
        PopupMenuItem(
          value: AppConstants.dealRent,
          child: Text('للإيجار فقط', style: GoogleFonts.cairo(fontSize: 12)),
        ),
      ],
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isFiltered ? const Color(0xFF0D6EFD).withAlpha(25) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFiltered ? const Color(0xFF0D6EFD) : Colors.grey.shade300,
            width: isFiltered ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isFiltered ? const Color(0xFF0D6EFD) : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: isFiltered ? const Color(0xFF0D6EFD) : Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyTypeDropdown() {
    final typeName = _selectedTypeId == null
        ? 'نوع العقار'
        : _selectedTypeId == 'apartment'
            ? 'شقق سكنية'
            : _selectedTypeId == 'villa'
                ? 'فلل ومنازل'
                : _selectedTypeId == 'shop'
                    ? 'محلات تجارية'
                    : _selectedTypeId == 'land'
                        ? 'أراضٍ'
                        : _selectedTypeId == 'building'
                            ? 'عمارات ومباني'
                            : _selectedTypeId == 'office'
                                ? 'مكاتب تجارية'
                                : 'نوع العقار';
    final isFiltered = _selectedTypeId != null;

    return PopupMenuButton<String?>(
      onSelected: (val) {
        setState(() {
          _selectedTypeId = val;
        });
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: null,
          child: Text('كافة أنواع العقارات', style: GoogleFonts.cairo(fontSize: 12)),
        ),
        PopupMenuItem(
          value: 'apartment',
          child: Text('شقق سكنية', style: GoogleFonts.cairo(fontSize: 12)),
        ),
        PopupMenuItem(
          value: 'villa',
          child: Text('فلل ومنازل', style: GoogleFonts.cairo(fontSize: 12)),
        ),
        PopupMenuItem(
          value: 'shop',
          child: Text('محلات تجارية', style: GoogleFonts.cairo(fontSize: 12)),
        ),
        PopupMenuItem(
          value: 'land',
          child: Text('أراضٍ', style: GoogleFonts.cairo(fontSize: 12)),
        ),
        PopupMenuItem(
          value: 'building',
          child: Text('عمارات ومباني', style: GoogleFonts.cairo(fontSize: 12)),
        ),
        PopupMenuItem(
          value: 'office',
          child: Text('مكاتب تجارية', style: GoogleFonts.cairo(fontSize: 12)),
        ),
      ],
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isFiltered ? const Color(0xFF0D6EFD).withAlpha(25) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFiltered ? const Color(0xFF0D6EFD) : Colors.grey.shade300,
            width: isFiltered ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              typeName,
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isFiltered ? const Color(0xFF0D6EFD) : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: isFiltered ? const Color(0xFF0D6EFD) : Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGovernorateChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0D6EFD) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF0D6EFD) : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  /// زر شريط الفلاتر العلوي — موحد ومنظم
  Widget _buildFilterBarBtn({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0D6EFD) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF0D6EFD) : Colors.grey.shade300,
            width: isActive ? 1.5 : 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF0D6EFD).withAlpha(40),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// زر دائري للإجراءات في بطاقة العقار
  Widget _buildCircleActionBtn({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
            color: color.withAlpha(12),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  // Google Maps–style circular cluster badge
  Widget _buildYemenPortalClusterBadge({required int count}) {
    final double size = count >= 100 ? 56 : (count >= 10 ? 50 : 44);
    final Color inner = count >= 50
        ? const Color(0xFFD32F2F)
        : count >= 10
            ? const Color(0xFF1565C0)
            : const Color(0xFF0D6EFD);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: inner.withAlpha(40),
        border: Border.all(color: inner.withAlpha(90), width: 1),
      ),
      child: Center(
        child: Container(
          width: size - 12,
          height: size - 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: inner,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: inner.withAlpha(130),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: count >= 100 ? 11 : 13,
                height: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Google Maps–style teardrop location pin with price badge
  Widget _buildPropertyPriceMarker({
    required String priceText,
    required bool isSelected,
    required bool isRent,
    bool hasExact = true,
  }) {
    // Pin head colour: selected = amber, rent = blue, sale = teal
    final Color pinColor = isSelected
        ? const Color(0xFFD97706)
        : (isRent ? const Color(0xFF1565C0) : const Color(0xFF0F766E));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Price badge above the pin
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD97706) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: pinColor,
              width: isSelected ? 0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            priceText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: isSelected ? 11 : 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : pinColor,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 1),
        // Google Maps teardrop pin
        CustomPaint(
          size: Size(isSelected ? 28 : 24, isSelected ? 36 : 30),
          painter: _GooglePinPainter(
            color: pinColor,
            isSelected: isSelected,
            isApproximate: !hasExact,
          ),
        ),
      ],
    );
  }

  void _showClusterPropertiesBottomSheet(List<Property> props) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.apartment_rounded, color: Color(0xFF0D6EFD)),
                    const SizedBox(width: 8),
                    Text(
                      'عقارات هذا الموقع (${props.length} عقار)',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: props.length,
                  itemBuilder: (context, index) {
                    final p = props[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildSelectedPropertyCard(
                        p,
                        onSelectOnMap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _selectedProperty = p;
                            _activeCardImageIndex = 0;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyAreaView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_off_outlined,
              size: 56,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 14),
            Text(
              'لا توجد عقارات مطابقة في هذا النطاق',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'يرجى تغيير نطاق البحث أو مسح الفلاتر لعرض العقارات المتوفرة في بقية محافظات اليمن.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(
                'عرض كافة المحافظات اليمنية',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              onPressed: () => _selectGovernorate(null),
            ),
          ],
        ),
      ),
    );
  }

  // Selected Property Card
  Widget _buildSelectedPropertyCard(Property prop, {VoidCallback? onSelectOnMap}) {
    final isRent = prop.dealType == AppConstants.dealRent;
    final images = prop.images.isNotEmpty
        ? prop.images.map((img) => img.imageUrl).toList()
        : [
            prop.primaryImageUrl ??
                'https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=800&q=80',
            'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80',
            'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=800&q=80',
          ];

    final isFav = ref.watch(favoritesProvider).maybeWhen(
          data: (favs) => favs.any((f) => f.id == prop.id),
          orElse: () => false,
        );

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Image Carousel with Pagination Dots & Badges
              Stack(
                children: [
                  SizedBox(
                    height: 155,
                    width: double.infinity,
                    child: PageView.builder(
                      itemCount: images.length,
                      onPageChanged: (idx) {
                        setState(() {
                          _activeCardImageIndex = idx;
                        });
                      },
                      itemBuilder: (context, idx) {
                        return CachedNetworkImage(
                          imageUrl: images[idx],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.surfaceVariant,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, err) => Container(
                            color: AppColors.surfaceVariant,
                            child: const Icon(
                              Icons.apartment,
                              size: 40,
                              color: AppColors.textMuted,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Close button on top-right (if floating modal)
                  if (onSelectOnMap == null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedProperty = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(140),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),

                  // Top Badges: Deal Discount & Bedrooms (Screenshot 4)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Blue Discount / Deal Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D6EFD), // Portal Blue
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isRent ? 'خصم خاص للإيجار' : 'خصم خاص للبيع',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),

                        // White Bedrooms Pill
                        if (prop.bedrooms > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(240),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${prop.bedrooms} غرف نوم',
                              style: GoogleFonts.cairo(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Heart Favorite Button on Top-Right (Screenshot 4)
                  Positioned(
                    top: 8,
                    right: onSelectOnMap == null ? 36 : 8,
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(favoritesProvider.notifier)
                            .toggleFavorite(prop.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(100),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  // Pagination Dots Indicator at bottom of image
                  if (images.length > 1)
                    Positioned(
                      bottom: 6,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length.clamp(1, 6),
                          (dotIdx) => Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _activeCardImageIndex == dotIdx
                                  ? Colors.white
                                  : Colors.white.withAlpha(120),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Content & Details below Image
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price Row with 3-dots menu
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${Formatters.formatCurrency(prop.price, prop.currency)} ${isRent ? 'فأكثر' : ''}',
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black87,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Subtitle link: "السعر الشهري الإجمالي" with blue checkmark
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF0D6EFD),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isRent
                                        ? 'السعر الشهري الإجمالي'
                                        : 'سعر الشراء النهائي المعتمد',
                                    style: GoogleFonts.cairo(
                                      color: const Color(0xFF0D6EFD),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Colors.black54,
                          ),
                          onPressed: () {
                            context.push('/property/${prop.id}');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Property Title and Address
                    Text(
                      '${prop.title} — ${prop.city}، ${prop.district}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // Location accuracy indicator badge
                    Builder(
                      builder: (context) {
                        final hasExactGps = prop.latitude != null &&
                            prop.longitude != null &&
                            prop.latitude != 0.0 &&
                            prop.longitude != 0.0;
                        return Row(
                          children: [
                            Icon(
                              hasExactGps
                                  ? Icons.location_on
                                  : Icons.near_me_outlined,
                              size: 13,
                              color: hasExactGps
                                  ? const Color(0xFF0F766E)
                                  : Colors.orange.shade800,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hasExactGps
                                  ? 'موقع محدد بدقة على الخريطة'
                                  : 'موقع تقديري بناءً على مركز ${prop.city}',
                              style: GoogleFonts.cairo(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: hasExactGps
                                    ? const Color(0xFF0F766E)
                                    : Colors.orange.shade800,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    // Sub-specifications pill chips (Screenshot 4)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (prop.bedrooms > 0)
                          _buildUnitBadge(
                            'غرفة نوم واحدة ${Formatters.formatCurrency(prop.price, prop.currency)}',
                          ),
                        if (prop.bedrooms > 1)
                          _buildUnitBadge(
                            'غرفتا نوم ${(prop.price * 1.25).toStringAsFixed(0)} ${prop.currency}',
                          ),
                        _buildUnitBadge('${prop.areaSqm.toInt()} م² مساحة'),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // أزرار الإجراءات: اتصال + واتساب + تفاصيل + الوصول للعقار
                    Row(
                      children: [
                        // زر الاتصال
                        _buildCircleActionBtn(
                          icon: Icons.phone,
                          color: const Color(0xFF0D6EFD),
                          tooltip: 'اتصال',
                          onTap: () => _makeCall(prop.contactPhone),
                        ),
                        const SizedBox(width: 6),

                        // زر واتساب
                        if (prop.contactWhatsapp != null &&
                            prop.contactWhatsapp!.isNotEmpty) ...[
                          _buildCircleActionBtn(
                            icon: Icons.chat,
                            color: Colors.green.shade600,
                            tooltip: 'واتساب',
                            onTap: () => _openWhatsApp(
                              prop.contactWhatsapp!,
                              prop.title,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],

                        // زر الوصول إلى العقار عبر Google Maps
                        _buildCircleActionBtn(
                          icon: Icons.directions_rounded,
                          color: Colors.green.shade700,
                          tooltip: 'الوصول إلى العقار',
                          onTap: () => _openGoogleMapsNavigation(prop),
                        ),
                        const SizedBox(width: 6),

                        // زر التفاصيل / التوافر
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D6EFD),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              onPressed: () {
                                if (onSelectOnMap != null) {
                                  onSelectOnMap();
                                } else {
                                  context.push('/property/${prop.id}');
                                }
                              },
                              child: Text(
                                isRent ? 'تحقق من التوافر' : 'عرض التفاصيل',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // زر الوصول إلى العقار — بارز ومستقل
                    if (onSelectOnMap == null) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green.shade700,
                            side: BorderSide(color: Colors.green.shade600, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          icon: Icon(Icons.directions_rounded, size: 18, color: Colors.green.shade700),
                          label: Text(
                            'الوصول إلى العقار عبر Google Maps',
                            style: GoogleFonts.cairo(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          onPressed: () => _openGoogleMapsNavigation(prop),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 10.5,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Draws a Google Maps–style teardrop pin
class _GooglePinPainter extends CustomPainter {
  final Color color;
  final bool isSelected;
  final bool isApproximate;

  const _GooglePinPainter({
    required this.color,
    this.isSelected = false,
    this.isApproximate = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final r = w / 2; // head radius
    final headY = r; // centre of head circle

    // --- Drop shadow ---
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final shadowPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx + 1, headY + 2), radius: r))
      ..moveTo(cx - 1, headY + r - 2)
      ..lineTo(cx + 1, h + 2)
      ..lineTo(cx + 3, headY + r - 2);
    canvas.drawPath(shadowPath, shadowPaint);

    // --- Teardrop body ---
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final bodyPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, headY), radius: r))
      ..moveTo(cx - r * 0.35, headY + r * 0.65)
      ..quadraticBezierTo(cx, h, cx + r * 0.35, headY + r * 0.65);
    canvas.drawPath(bodyPath, fillPaint);

    // Actual teardrop using a path
    final pinPath = Path();
    pinPath.moveTo(cx, h); // tip
    pinPath.cubicTo(cx - r * 0.3, headY + r * 0.9, cx - r, headY + r * 0.5, cx - r, headY);
    pinPath.arcTo(Rect.fromCircle(center: Offset(cx, headY), radius: r), math.pi, math.pi, false);
    pinPath.cubicTo(cx + r, headY + r * 0.5, cx + r * 0.3, headY + r * 0.9, cx, h);
    pinPath.close();
    canvas.drawPath(pinPath, fillPaint);

    // --- White border stroke ---
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.5 : 1.8;
    canvas.drawPath(pinPath, strokePaint);

    // --- Inner white dot (GPS crosshair) ---
    final dotPaint = Paint()
      ..color = isApproximate ? Colors.white.withAlpha(160) : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, headY), r * 0.32, dotPaint);

    // Dashed ring for approximate location
    if (isApproximate) {
      final dashPaint = Paint()
        ..color = Colors.white.withAlpha(180)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      for (int i = 0; i < 8; i++) {
        final angle = (i / 8) * 2 * math.pi;
        final x1 = cx + (r * 0.5) * math.cos(angle);
        final y1 = headY + (r * 0.5) * math.sin(angle);
        final x2 = cx + (r * 0.72) * math.cos(angle);
        final y2 = headY + (r * 0.72) * math.sin(angle);
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GooglePinPainter old) =>
      old.color != color || old.isSelected != isSelected || old.isApproximate != isApproximate;
}
