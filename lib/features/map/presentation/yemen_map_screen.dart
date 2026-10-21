import 'dart:async';
import 'dart:convert';
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
  double? _minPrice;
  double? _maxPrice;
  int? _minBedrooms;

  bool _isListView = false;
  bool _showSearchThisAreaBtn = false;
  double _currentZoom = 7.5;
  LatLng? _lastSearchCenter;
  Timer? _debounceTimer;
  int _activeCardImageIndex = 0;
  bool _isSatellite = false;

  // Freehand Map Drawing Mode (Zillow "يرسم" feature)
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
    if (prop.latitude != null && prop.longitude != null) {
      return (prop.latitude!, prop.longitude!);
    }
    return AppConstants.getCoordinatesForGovernorate(prop.city);
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

      // Filter text query (city, district, title)
      if (query.isNotEmpty) {
        final inCity = p.city.toLowerCase().contains(query);
        final inDist = p.district.toLowerCase().contains(query);
        final inTitle = p.title.toLowerCase().contains(query);
        if (!inCity && !inDist && !inTitle) return false;
      }

      // Filter price
      if (_minPrice != null && p.price < _minPrice!) return false;
      if (_maxPrice != null && p.price > _maxPrice!) return false;

      // Filter bedrooms
      if (_minBedrooms != null && p.bedrooms < _minBedrooms!) return false;

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
        int? tempBeds = _minBedrooms;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 16),
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
                              tempBeds = null;
                            });
                          },
                          child: Text(
                            'إعادة ضبط',
                            style: GoogleFonts.cairo(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Deal Type
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

                    // Property Type
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
                          label: 'مكاتب تجارية',
                          isSelected: tempType == 'office',
                          onTap: () => setModalState(() => tempType = 'office'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Bedrooms
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
                    const SizedBox(height: 24),

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
                            _minBedrooms = tempBeds;
                            _selectedProperty = null;
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

  // Group properties into clusters by governorate
  Map<String, List<Property>> _clusterPropertiesByGov(List<Property> properties) {
    final map = <String, List<Property>>{};
    for (final p in properties) {
      final gov = p.city.isNotEmpty ? p.city : 'صنعاء';
      map.putIfAbsent(gov, () => []).add(p);
    }
    return map;
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
          final govClusters = _clusterPropertiesByGov(filteredProperties);

          return Stack(
            children: [
              // 1. Full Screen Interactive Map or List View
              if (!_isListView)
                GestureDetector(
                  // Handlers for freehand drawing feature (Zillow "يرسم")
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
                      // CartoDB Voyager: World-standard clean pastel map matching Zillow / Google Maps exactly
                      TileLayer(
                        urlTemplate: _isSatellite
                            ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                            : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.yemenreal.portal',
                        maxZoom: 19,
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

                      // Drawn Polygon Layer (Zillow Draw Area)
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

                      // When zoomed out (< 10.5): render Purple Zillow Cluster Badges: [🏢 28 وحدة]
                      if (_currentZoom < 10.5 &&
                          _selectedGovName == null &&
                          _drawnPolygon.isEmpty)
                        MarkerLayer(
                          markers: govClusters.entries.map((entry) {
                            final govName = entry.key;
                            final props = entry.value;
                            final coords =
                                AppConstants.getCoordinatesForGovernorate(
                                    govName);

                            return Marker(
                              point: LatLng(coords.$1, coords.$2),
                              width: 110,
                              height: 40,
                              child: GestureDetector(
                                onTap: () {
                                  final govMatch = _governorates.firstWhere(
                                    (g) =>
                                        g.name == govName ||
                                        govName.contains(g.name) ||
                                        g.name.contains(govName),
                                    orElse: () => YemenGovernorateCoord(
                                      name: govName,
                                      latitude: coords.$1,
                                      longitude: coords.$2,
                                      defaultZoom: 13.0,
                                    ),
                                  );
                                  _selectGovernorate(govMatch);
                                },
                                child: _buildZillowPurpleClusterBadge(
                                  count: props.length,
                                  govName: govName,
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      else
                        // When zoomed in (>= 10.5), governorate selected, or area drawn: render individual property pins
                        MarkerLayer(
                          markers: filteredProperties.map((prop) {
                            final isSelected = _selectedProperty?.id == prop.id;
                            final priceText = _formatPriceTag(prop);
                            final isRent = prop.dealType == AppConstants.dealRent;
                            final coords = _getPropertyCoords(prop);

                            return Marker(
                              point: LatLng(coords.$1, coords.$2),
                              width: isSelected ? 150 : 130,
                              height: 52,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedProperty = prop;
                                    _activeCardImageIndex = 0;
                                  });
                                  _animatedMapMove(
                                    LatLng(coords.$1, coords.$2),
                                    14.5,
                                  );
                                },
                                child: _buildZillowMarker(
                                  priceText: priceText,
                                  isSelected: isSelected,
                                  isRent: isRent,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                )
              else
                // Synced List View
                Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.only(top: 155),
                  child: filteredProperties.isEmpty
                      ? _buildEmptyAreaView()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredProperties.length,
                          itemBuilder: (context, index) {
                            final prop = filteredProperties[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: _buildZillowPropertyCard(
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

              // 2. Exact Zillow Top Search Bar & Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildZillowTopHeader(),
              ),

              // 3. Sub-controls on map: "يرسم" (Draw), "المدارس ˅" (Schools), and Governorates Chips
              Positioned(
                top: 112,
                left: 0,
                right: 0,
                child: _buildZillowSubControlBar(),
              ),

              // 4. Drawing Mode Instruction Banner
              if (_isDrawingMode)
                Positioned(
                  top: 165,
                  left: 20,
                  right: 20,
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

              // 5. Active Drawn Polygon Filter Badge: "تم تحديد المنطقة بالرسم [مسح]"
              if (_drawnPolygon.isNotEmpty && !_isDrawingMode)
                Positioned(
                  top: 165,
                  left: 20,
                  right: 20,
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

              // 6. "Search this area" Button (Zillow floating refresh pill)
              if (_showSearchThisAreaBtn && !_isListView && !_isDrawingMode)
                Positioned(
                  top: 175,
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

              // 7. Floating Bottom Map Controls (Zillow Count Pill, List Toggle, and Layers)
              Positioned(
                bottom: _selectedProperty != null ? 360 : 16,
                left: 14,
                right: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bottom-Left Count Chip: "2,892 of 274,057"
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(200),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        '${filteredProperties.length} من ${effectiveList.length} عقار 🇾🇪',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Bottom-Center: Floating "List" / "Map" Pill
                    FloatingActionButton.extended(
                      heroTag: 'map_list_toggle',
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E293B),
                      elevation: 4,
                      icon: Icon(
                        _isListView
                            ? Icons.map_rounded
                            : Icons.format_list_bulleted,
                        size: 18,
                        color: const Color(0xFF0D6EFD),
                      ),
                      label: Text(
                        _isListView ? 'عرض الخريطة' : 'عرض القائمة',
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

                    // Floating Yemen Official Map Button
                    FloatingActionButton.small(
                      heroTag: 'map_offline_atlas',
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      tooltip: 'خريطة اليمن الرسمية المعتمدة (أوفلاين)',
                      onPressed: _showOfflineMapDialog,
                      child: const Icon(
                        Icons.map_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Bottom-Right: Floating Layers / Satellite Toggle
                    FloatingActionButton.small(
                      heroTag: 'map_layers_toggle',
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E293B),
                      elevation: 4,
                      tooltip: 'تغيير نمط الخريطة (قمر صناعي / شوارع)',
                      onPressed: () {
                        setState(() {
                          _isSatellite = !_isSatellite;
                        });
                      },
                      child: Icon(
                        _isSatellite ? Icons.layers_clear : Icons.layers_outlined,
                        size: 20,
                        color: const Color(0xFF0D6EFD),
                      ),
                    ),
                  ],
                ),
              ),

              // 8. Exact Zillow Selected Property Card (Screenshot 4)
              if (_selectedProperty != null && !_isListView)
                Positioned(
                  bottom: 10,
                  left: isMobile ? 8 : 20,
                  right: isMobile ? 8 : 20,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: _buildZillowPropertyCard(_selectedProperty!),
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

  // Exact Zillow Top Header Widget (Screenshots 1, 2, 3)
  Widget _buildZillowTopHeader() {
    final authState = ref.watch(authProvider);

    return Container(
      padding: const EdgeInsets.only(top: 36, left: 12, right: 12, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Small Top Title Badge
          Row(
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
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Row 1: Hamburger Menu + Search Box + Avatar
          Row(
            children: [
              Builder(
                builder: (btnCtx) => IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Color(0xFF0F172A),
                    size: 24,
                  ),
                  onPressed: () => Scaffold.of(btnCtx).openDrawer(),
                ),
              ),
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade400, width: 1.2),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Address, neighborhood, city, ZIP',
                            hintStyle: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey.shade500,
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
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 18,
                          ),
                        )
                      else
                        const Icon(
                          Icons.search,
                          color: Colors.black87,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // User Avatar Circle ("آنسة" or User Avatar)
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
                  decoration: const BoxDecoration(
                    color: Color(0xFF044E54), // Zillow teal/dark circle
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    authState.isAuthenticated
                        ? (authState.user?.fullName.isNotEmpty == true
                            ? authState.user!.fullName.substring(0, 1)
                            : 'ح')
                        : 'آنسة',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Row 2: Filters Dropdown + Save Search Button + Sparkle Magic Button
          Row(
            children: [
              // Filters Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  side: BorderSide(
                    color: (_selectedTypeId != null || _minBedrooms != null)
                        ? const Color(0xFF0D6EFD)
                        : Colors.grey.shade400,
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                icon: const Icon(Icons.tune, size: 15),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Filters',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 16),
                  ],
                ),
                onPressed: _showFilterModal,
              ),
              const SizedBox(width: 8),

              // Save Search (حفظ البحث) Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD), // Zillow Blue
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                ),
                icon: const Icon(Icons.bookmark_border, size: 15),
                label: Text(
                  'حفظ البحث',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم حفظ هذا البحث وتنبيهات العقارات بنجاح',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: const Color(0xFF0D6EFD),
                    ),
                  );
                },
              ),
              const Spacer(),

              // Sparkle AI Blue Button
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFF0D6EFD),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 17,
                  ),
                  onPressed: () => _selectGovernorate(null),
                  tooltip: 'اقتراحات ذكية وخريطة شاملة',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Sub-controls on map: "يرسم" (Draw), "المدارس ˅" (Schools), and Governorates Chips
  Widget _buildZillowSubControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          // "يرسم" (Draw Area) Button (Zillow Feature)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              backgroundColor: _isDrawingMode || _drawnPolygon.isNotEmpty
                  ? const Color(0xFF0D6EFD)
                  : Colors.white.withAlpha(245),
              foregroundColor: _isDrawingMode || _drawnPolygon.isNotEmpty
                  ? Colors.white
                  : Colors.black87,
              elevation: 2,
              side: BorderSide(
                color: _isDrawingMode || _drawnPolygon.isNotEmpty
                    ? const Color(0xFF0D6EFD)
                    : Colors.grey.shade400,
                width: 1.3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            icon: Icon(
              _drawnPolygon.isNotEmpty ? Icons.close : Icons.draw_outlined,
              size: 14,
            ),
            label: Text(
              _drawnPolygon.isNotEmpty ? 'مسح الرسم' : 'يرسم',
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
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

          // "خريطة اليمن 🇾🇪" (Offline Official Map) Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E).withAlpha(20),
              foregroundColor: const Color(0xFF0F766E),
              elevation: 2,
              side: const BorderSide(color: Color(0xFF0D9488), width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            icon: const Icon(Icons.map_rounded, size: 14),
            label: Text(
              'خريطة اليمن 🇾🇪',
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: _showOfflineMapDialog,
          ),
          const SizedBox(width: 6),

          // "المدارس ˅" (Schools/Services) Dropdown Button
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(245),
              foregroundColor: Colors.black87,
              elevation: 2,
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            onPressed: _showFilterModal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'المدارس',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.keyboard_arrow_down, size: 14),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Governorates Quick Horizontal List
          Expanded(
            child: SizedBox(
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _governorates.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isAll = _selectedGovName == null;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ChoiceChip(
                        label: Text(
                          'كافة المحافظات 🇾🇪',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isAll ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        selected: isAll,
                        selectedColor: const Color(0xFF0D6EFD),
                        backgroundColor: Colors.white.withAlpha(245),
                        onSelected: (_) => _selectGovernorate(null),
                      ),
                    );
                  }

                  final gov = _governorates[index - 1];
                  final isSelected = _selectedGovName == gov.name;

                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ChoiceChip(
                      label: Text(
                        gov.name,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0D6EFD),
                      backgroundColor: Colors.white.withAlpha(245),
                      onSelected: (_) => _selectGovernorate(gov),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Zillow Purple Cluster Badge: [🏢 28 وحدة] (Screenshot 2 & 3)
  Widget _buildZillowPurpleClusterBadge({
    required int count,
    required String govName,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6B46C1), // Zillow Purple Cluster Color
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B46C1).withAlpha(120),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.apartment_rounded,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$count وحدة',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Zillow Property Price Marker (Screenshot 2, 3, 4)
  Widget _buildZillowMarker({
    required String priceText,
    required bool isSelected,
    required bool isRent,
  }) {
    final bgColor = isSelected
        ? Colors.amber.shade700
        : (isRent ? const Color(0xFF0D6EFD) : const Color(0xFF6B46C1));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Colors.amber.withAlpha(120)
                    : Colors.black.withAlpha(60),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  priceText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: isSelected ? 11.5 : 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
        CustomPaint(
          size: const Size(10, 5),
          painter: _TrianglePainter(color: bgColor),
        ),
      ],
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

  // Exact Zillow Selected Property Card (Screenshot 4)
  Widget _buildZillowPropertyCard(Property prop, {VoidCallback? onSelectOnMap}) {
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
                            color: const Color(0xFF0D6EFD), // Zillow Blue
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

                    // Action Buttons: Call + WhatsApp + Big Blue "تحقق من التوافر"
                    Row(
                      children: [
                        // Call Phone Circular Button
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0D6EFD),
                              width: 1.5,
                            ),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.phone,
                              color: Color(0xFF0D6EFD),
                              size: 19,
                            ),
                            tooltip: 'اتصال',
                            onPressed: () => _makeCall(prop.contactPhone),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // WhatsApp Circular Button
                        if (prop.contactWhatsapp != null &&
                            prop.contactWhatsapp!.isNotEmpty) ...[
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.green.shade600,
                                width: 1.5,
                              ),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.chat,
                                color: Colors.green.shade600,
                                size: 19,
                              ),
                              tooltip: 'واتساب',
                              onPressed: () => _openWhatsApp(
                                prop.contactWhatsapp!,
                                prop.title,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Large Wide Blue Primary Button: "تحقق من التوافر" / "عرض التفاصيل"
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF0D6EFD), // Zillow Blue
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                if (onSelectOnMap != null) {
                                  onSelectOnMap();
                                } else {
                                  context.push('/property/${prop.id}');
                                }
                              },
                              child: Text(
                                isRent ? 'تحقق من التوافر' : 'عرض التفاصيل والحجز',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _TrianglePainter extends CustomPainter {
  final Color color;

  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}
