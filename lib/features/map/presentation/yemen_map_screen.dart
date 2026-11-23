import 'dart:ui' show ImageFilter;
import 'dart:async';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
import '../../../providers/favorites_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_page_body.dart';
import '../../../data/demo_properties_generator.dart';
import '../services/map_cluster_service.dart';
import 'property_map_view.dart';
import '../../../core/l10n/context_l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  /// Dashboard FAB opens the map/list view in list mode. Direct /map visits
  /// keep the map as the initial view.
  final bool initialListView;

  const YemenMapScreen({super.key, this.initialListView = false});

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

  bool _isListView = false; // overwritten from widget.initialListView in initState
  bool _showSearchThisAreaBtn = false;
  double _currentZoom = _defaultZoom;
  LatLng? _lastSearchCenter;
  Timer? _debounceTimer;
  final ScrollController _listScrollController = ScrollController();

  // Listing pagination — render 12 rows initially, extend on scroll.
  static const int _pageSize = 12;
  int _visibleCount = _pageSize;
  int _lastFilteredCount = 0;
  String _lastFilterKey = '';

  int _activeCardImageIndex = 0;
  bool _isSatellite = false;

  // Freehand Map Drawing Mode
  bool _isDrawingMode = false;
  List<LatLng> _drawnPolygon = [];

  static const double _defaultZoom = 12.5;
  static const LatLng _ibbCenter = LatLng(13.9667, 44.1833);

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

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _isListView = widget.initialListView;
    // Use user's location (or Ibb fallback) for initial map center/zoom
    _initMapCenter();
    _listScrollController.addListener(() {
      if (!_listScrollController.hasClients || !mounted) return;
      final position = _listScrollController.position;
      if (position.pixels >= position.maxScrollExtent - 300 &&
          _visibleCount < _lastFilteredCount) {
        setState(() {
          _visibleCount = (_visibleCount + _pageSize).clamp(0, _lastFilteredCount);
        });
      }
    });
  }

  /// Initialize map center and zoom based on user's stored location (or Ibb fallback).
  Future<void> _initMapCenter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('settings_latitude');
      final lng = prefs.getDouble('settings_longitude');
      if (lat != null && lng != null) {
        _lastSearchCenter = LatLng(lat, lng);
        _currentZoom = _defaultZoom;
      } else {
        _lastSearchCenter = _ibbCenter;
        _currentZoom = _defaultZoom;
      }
    } catch (_) {
      _lastSearchCenter = _ibbCenter;
      _currentZoom = _defaultZoom;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _listScrollController.dispose();
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
              context.l10n.map_location_missing_message,
              style: GoogleFonts.cairo(fontSize: 13),
            ),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: context.l10n.map_call,
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
              context.l10n.map_maps_open_error,
              style: GoogleFonts.cairo(fontSize: 13),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phone, String title) async {
    final cleanPhone = Formatters.formatPhoneForWhatsApp(phone);
    final msg = Uri.encodeComponent(
      '${context.l10n.map_whatsapp_prefix}: $title',
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
                      Icon(Icons.tune_rounded, color: AppColors.primaryInk),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.map_filter_title,
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
                          context.l10n.map_reset_filters,
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
                            context.l10n.map_deal_type,
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildFilterOption(
                                label: context.l10n.map_all,
                                isSelected: tempDeal == '',
                                onTap: () => setModalState(() => tempDeal = ''),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterOption(
                                label: context.l10n.map_for_sale,
                                isSelected: tempDeal == AppConstants.dealSale,
                                onTap: () => setModalState(
                                    () => tempDeal = AppConstants.dealSale),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterOption(
                                label: context.l10n.map_for_rent,
                                isSelected: tempDeal == AppConstants.dealRent,
                                onTap: () => setModalState(
                                    () => tempDeal = AppConstants.dealRent),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 2. Property Type
                          Text(
                            context.l10n.map_property_type,
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildFilterOption(
                                label: context.l10n.map_all,
                                isSelected: tempType == null,
                                onTap: () => setModalState(() => tempType = null),
                              ),
                              _buildFilterOption(
                                label: context.l10n.map_type_apartment,
                                isSelected: tempType == 'apartment',
                                onTap: () =>
                                    setModalState(() => tempType = 'apartment'),
                              ),
                              _buildFilterOption(
                                label: context.l10n.map_type_villa,
                                isSelected: tempType == 'villa',
                                onTap: () => setModalState(() => tempType = 'villa'),
                              ),
                              _buildFilterOption(
                                label: context.l10n.map_type_shop,
                                isSelected: tempType == 'shop',
                                onTap: () => setModalState(() => tempType = 'shop'),
                              ),
                              _buildFilterOption(
                                label: context.l10n.map_type_land,
                                isSelected: tempType == 'land',
                                onTap: () => setModalState(() => tempType = 'land'),
                              ),
                              _buildFilterOption(
                                label: context.l10n.map_type_building,
                                isSelected: tempType == 'building',
                                onTap: () =>
                                    setModalState(() => tempType = 'building'),
                              ),
                              _buildFilterOption(
                                label: context.l10n.map_type_office,
                                isSelected: tempType == 'office',
                                onTap: () => setModalState(() => tempType = 'office'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 3. Governorate Selector
                          Text(
                            context.l10n.map_governorate,
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 38,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildFilterOption(
                                  label: context.l10n.map_all_governorates,
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
                              '${context.l10n.map_district_in} $tempGov',
                              style:
                                  GoogleFonts.cairo(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildFilterOption(
                                  label: '${context.l10n.map_all_districts_in} $tempGov',
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
                            context.l10n.map_price_range,
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
                                    labelText: context.l10n.map_min_price,
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
                                    labelText: context.l10n.map_max_price,
                                    labelStyle: GoogleFonts.cairo(fontSize: 12),
                                    hintText: context.l10n.map_no_max,
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
                            context.l10n.map_min_bedrooms,
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              for (final b in [null, 1, 2, 3, 4, 5])
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: _buildFilterOption(
                                    label: b == null ? context.l10n.map_all : '$b+',
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
                                        context.l10n.map_exact_gps_only,
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                      Text(
                                        context.l10n.map_hide_approximate,
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
                                  activeColor: AppColors.primary,
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
                        backgroundColor: AppColors.primary,
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
                        context.l10n.map_apply_filters,
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
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
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

  void _onPropertyTap(Property prop, LatLng centroid) {
    setState(() {
      _selectedProperty = prop;
      _activeCardImageIndex = 0;
    });
    _animatedMapMove(centroid, math.max(_currentZoom, 14.5));
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(allMapPropertiesProvider);
    final settings = ref.watch(settingsProvider);
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      drawer: isDesktop ? null : const AppDrawer(),
      bottomNavigationBar:
          isDesktop ? null : const AppBottomNavBar(currentRoute: '/map'),
      body: AppPageBody(
        child: propertiesAsync.when(
        data: (allProperties) {
          final effectiveList = allProperties.isNotEmpty
              ? allProperties
              : DemoPropertiesGenerator.generateAllDemoProperties();

          final filteredProperties = _filterProperties(effectiveList);

          // Reset pagination whenever the result set changes.
          final filterKey = [
            _searchController.text,
            _selectedDealType,
            _selectedTypeId,
            _selectedGovName,
            _selectedDistrict,
            _minPrice,
            _maxPrice,
            _minBedrooms,
            _onlyExactCoordinates,
            _drawnPolygon.length,
          ].join('|');
          if (filterKey != _lastFilterKey) {
            _lastFilterKey = filterKey;
            _visibleCount = _pageSize;
          }
          _lastFilteredCount = filteredProperties.length;

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
                  child: PropertyMapView(
                    properties: filteredProperties,
                    mapController: _mapController,
                    initialCenter: _lastSearchCenter ?? _ibbCenter,
                    initialZoom: _currentZoom,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                    isSatellite: _isSatellite,
                    selectedPropertyId: _selectedProperty?.id,
                    highlightGovernorate: _selectedGovName,
                    drawnPolygon: _drawnPolygon,
                    showBoundaries: true,
                    interactionFlags: _isDrawingMode
                        ? InteractiveFlag.none
                        : InteractiveFlag.all,
                    onPositionChanged: (pos, hasGesture) {
                      if (pos.zoom != _currentZoom) {
                        setState(() {
                          _currentZoom = pos.zoom;
                        });
                      }
                      if (hasGesture && !_isDrawingMode) {
                        _debounceTimer?.cancel();
                        _debounceTimer = Timer(
                            const Duration(milliseconds: 300), () {
                          if (mounted) {
                            final dist = _lastSearchCenter != null
                                ? const Distance()
                                    .as(LengthUnit.Kilometer,
                                        _lastSearchCenter!, pos.center)
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
                    onMapTap: (tapPosition, point) {
                      if (_selectedProperty != null) {
                        setState(() {
                          _selectedProperty = null;
                        });
                      }
                    },
                    onPropertyTap: _onPropertyTap,
                  ),
                )
              else
                // Synced List View
                Container(
                  color: AppColors.background,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 128,
                  ),
                  child: filteredProperties.isEmpty
                      ? _buildEmptyAreaView()
                      : ListView.builder(
                          controller: _listScrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _visibleCount < _lastFilteredCount
                              ? _visibleCount + 1
                              : _visibleCount,
                          itemBuilder: (context, index) {
                            if (index == _visibleCount) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: OutlinedButton.icon(
                                  onPressed: () => setState(() {
                                    _visibleCount =
                                        (_visibleCount + _pageSize)
                                            .clamp(0, _lastFilteredCount);
                                  }),
                                  icon: const Icon(Icons.expand_more_rounded),
                                  label: Text(context.l10n.map_load_more),
                                ),
                              );
                            }
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
                  top: MediaQuery.of(context).padding.top + 128,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
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
                            context.l10n.map_draw_instruction,
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
                            context.l10n.map_cancel,
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
                  top: MediaQuery.of(context).padding.top + 128,
                  left: 16,
                  right: 16,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryInk,
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
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primaryInk,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${context.l10n.map_draw_filter_active} (${filteredProperties.length} ${context.l10n.map_result_property_unit})',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryInk,
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
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: AppColors.textPrimary,
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
                  top: MediaQuery.of(context).padding.top + 210,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.primaryInk,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: AppColors.primaryInk,
                            width: 1.5,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text(
                        context.l10n.map_search_this_area,
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

              // 6. Floating Bottom Map Controls
              // Stacked vertically on one RTL-aware side:
              //   list-toggle FAB (bottom) -> count badge -> satellite -> draw (top)
              // `PositionedDirectional` flips start/end so controls sit on the
              //   trailing edge (right in LTR, left in RTL), matching the
              //   dashboard FAB alignment.
              if (settings.assetCountVisibility == 'always' ||
                  filteredProperties.isNotEmpty)
                PositionedDirectional(
                  end: 16,
                  bottom: _selectedProperty != null ? 420 : 76,
                  child: _buildCountBadge(filteredProperties),
                ),

              if (!_isListView)
                PositionedDirectional(
                  end: 16,
                  bottom: _selectedProperty != null ? 480 : 136,
                  child: FloatingActionButton.small(
                    heroTag: 'map_layers_toggle',
                    backgroundColor: AppColors.surfaceVariant,
                    foregroundColor: AppColors.primaryInk,
                    elevation: 3,
                    tooltip: _isSatellite
                        ? context.l10n.map_switch_to_streets
                        : context.l10n.map_switch_to_satellite,
                    onPressed: () {
                      setState(() {
                        _isSatellite = !_isSatellite;
                      });
                    },
                    child: Icon(
                      _isSatellite ? Icons.map_rounded : Icons.satellite_alt_rounded,
                      size: 20,
                    ),
                  ),
                ),

              if (!_isListView)
                PositionedDirectional(
                  end: 16,
                  bottom: _selectedProperty != null ? 540 : 196,
                  child: FloatingActionButton.small(
                    heroTag: 'map_draw_area',
                    backgroundColor: _isDrawingMode
                        ? AppColors.primaryInk // bright teal in dark mode
                        : AppColors.surfaceVariant,
                    foregroundColor: _isDrawingMode
                        ? Colors.white
                        : AppColors.primaryInk,
                    elevation: 3,
                    tooltip: _isDrawingMode
                        ? context.l10n.map_cancel_draw
                        : context.l10n.map_draw_search_area,
                    onPressed: () {
                      setState(() {
                        _isDrawingMode = !_isDrawingMode;
                        if (!_isDrawingMode) _drawnPolygon.clear();
                      });
                    },
                    child: const Icon(Icons.draw_rounded, size: 20),
                  ),
                ),

              // C. Primary list <-> map toggle — same extended teal FAB as the
              //    search view (matches the new map/list screen).
              PositionedDirectional(
                end: 16,
                bottom: _selectedProperty != null ? 360 : 16,
                child: FloatingActionButton.extended(
                  key: const ValueKey('map_list_toggle'),
                  heroTag: 'map_list_toggle',
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  icon: Icon(
                    _isListView ? Icons.map_rounded : Icons.format_list_bulleted_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _isListView
                        ? context.l10n.map_show_map
                        : context.l10n.map_show_list,
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
                  context.l10n.map_load_error,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.refresh(allMapPropertiesProvider),
                  child: Text(context.l10n.map_retry),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  // Unified Map Header & Filter Bar (RTL, Responsive, High Contrast)
  Widget _buildMapHeader() {
    final hasActiveFilters = _selectedTypeId != null ||
        _minBedrooms != null ||
        _selectedGovName != null ||
        _selectedDistrict != null ||
        _minPrice != null ||
        _maxPrice != null ||
        _onlyExactCoordinates ||
        _selectedDealType.isNotEmpty;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                color: AppColors.surface,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Search Row: back + pill search + menu
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Row(
                        children: [
                          _mapHeaderCircleButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: context.l10n.map_back_home,
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/');
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: _mapHeaderSearchField()),
                          const SizedBox(width: 8),
                          if (!Responsive.isDesktop(context))
                            Builder(
                              builder: (btnCtx) => _mapHeaderCircleButton(
                                icon: Icons.menu_rounded,
                                tooltip: context.l10n.map_main_menu,
                                onPressed: () =>
                                    Scaffold.of(btnCtx).openDrawer(),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Filter Chips Row: filter button opens the bottom sheet;
                    // any active filter is shown as a chip right beside it.
                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        children: [
                  // زر الفلاتر الشاملة — يفتح شريحة الفلاتر السفلية
                  _buildFilterBarBtn(
                    label: hasActiveFilters
                        ? context.l10n.map_filters_active
                        : context.l10n.map_filters,
                    icon: Icons.tune,
                    isActive: hasActiveFilters,
                    onTap: _showFilterModal,
                  ),
                  const SizedBox(width: 8),
                  // الفلاتر المختارة تظهر كشيكات صغيرة بجوار زر الفلاتر
                  ..._activeFilterChips(),
                ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mapHeaderSearchField() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(23),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.primaryInk, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: context.l10n.map_search_hint,
                hintStyle: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.textMuted,
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
              child: Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary,
                size: 19,
              ),
            ),
        ],
      ),
    );
  }

  Widget _mapHeaderCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surfaceVariant,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: AppColors.primaryInk, size: 22),
          ),
        ),
      ),
    );
  }

  /// الفلاتر المختارة تظهر كشيكات صغيرة بجوار زر الفلاتر في شريط الرأس.
  List<Widget> _activeFilterChips() {
    final chips = <Widget>[];

    if (_selectedDealType.isNotEmpty) {
      chips.add(_buildSelectedFilterChip(
        _selectedDealType == AppConstants.dealSale
            ? context.l10n.map_for_sale
            : context.l10n.map_for_rent,
        onRemoved: () => setState(() => _selectedDealType = ''),
      ));
    }

    if (_selectedTypeId != null && _selectedTypeId!.isNotEmpty) {
      chips.add(_buildSelectedFilterChip(
        _propertyTypeLabel(_selectedTypeId!),
        onRemoved: () => setState(() => _selectedTypeId = null),
      ));
    }

    if (_selectedGovName != null && _selectedGovName!.isNotEmpty) {
      chips.add(_buildSelectedFilterChip(
        _selectedGovName!,
        onRemoved: () => setState(() => _selectedGovName = null),
      ));
    }

    if (_minBedrooms != null) {
      chips.add(_buildSelectedFilterChip(
        '$_minBedrooms ${context.l10n.map_bedrooms}',
        onRemoved: () => setState(() => _minBedrooms = null),
      ));
    }

    if (_minPrice != null || _maxPrice != null) {
      chips.add(_buildSelectedFilterChip(
        '${_minPrice ?? 0} - ${_maxPrice ?? 0}',
        onRemoved: () => setState(() {
          _minPrice = null;
          _maxPrice = null;
        }),
      ));
    }

    if (_onlyExactCoordinates) {
      chips.add(_buildSelectedFilterChip(
        context.l10n.map_exact_gps_only,
        onRemoved: () => setState(() => _onlyExactCoordinates = false),
      ));
    }

    return chips;
  }

  Widget _buildSelectedFilterChip(String label,
      {required VoidCallback onRemoved}) {
    return Chip(
      deleteIcon: const Icon(Icons.close_rounded, size: 16),
      onDeleted: onRemoved,
      label: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      backgroundColor: AppColors.surfaceVariant,
      side: BorderSide.none,
      shape: const StadiumBorder(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  String _propertyTypeLabel(String typeId) {
    switch (typeId) {
      case 'apartment':
        return context.l10n.map_type_apartment;
      case 'villa':
        return context.l10n.map_type_villa;
      case 'shop':
        return context.l10n.map_type_shop;
      case 'land':
        return context.l10n.map_type_land;
      case 'building':
        return context.l10n.map_type_building;
      case 'office':
        return context.l10n.map_type_office;
      default:
        return context.l10n.map_property_type;
    }
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
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? (AppColors.isDark
                  ? AppColors.primaryMuted.withAlpha(140)
                  : AppColors.primaryMuted)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? AppColors.primaryInk : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.primaryInk : AppColors.textPrimary,
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

  Widget _buildEmptyAreaView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 56,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 14),
            Text(
              context.l10n.map_no_properties_in_area,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.map_no_properties_area_hint,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Property count badge — capsule with the same height (40 dp) and
  // fully-rounded shape as the draw / satellite buttons beside it.
  Widget _buildCountBadge(List<Property> properties) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(AppColors.isDark ? 70 : 20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.apartment_rounded, size: 16, color: AppColors.primaryInk),
          const SizedBox(width: 8),
          Text(
            '${properties.length} ${context.l10n.map_properties_available}',
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
        ],
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
          color: AppColors.surface,
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
                            child: Icon(
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
                            color: AppColors.primary, // Portal Blue
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isRent ? context.l10n.map_rent_discount : context.l10n.map_sale_discount,
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
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${prop.bedrooms} ${context.l10n.map_bedrooms}',
                              style: GoogleFonts.cairo(
                                color: AppColors.textPrimary,
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
                                '${Formatters.formatCurrency(prop.price, prop.currency)} ${isRent ? context.l10n.map_or_more : ''}',
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Subtitle link: "السعر الشهري الإجمالي" with blue checkmark
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: AppColors.primaryInk,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isRent
                                        ? context.l10n.map_total_monthly_price
                                        : context.l10n.map_final_purchase_price,
                                    style: GoogleFonts.cairo(
                                      color: AppColors.primaryInk,
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
                          icon: Icon(
                            Icons.more_horiz,
                            color: AppColors.textMuted,
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
                        color: AppColors.textPrimary,
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
                                  ? context.l10n.map_exact_location
                                  : '${context.l10n.map_approximate_location_prefix} ${prop.city}',
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
                            '${context.l10n.map_one_bedroom} ${Formatters.formatCurrency(prop.price, prop.currency)}',
                          ),
                        if (prop.bedrooms > 1)
                          _buildUnitBadge(
                            '${context.l10n.map_two_bedrooms} ${(prop.price * 1.25).toStringAsFixed(0)} ${prop.currency}',
                          ),
                        _buildUnitBadge('${prop.areaSqm.toInt()} ${context.l10n.map_area_sqm}'),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // أزرار الإجراءات: اتصال + واتساب + تفاصيل + الوصول للعقار
                    Row(
                      children: [
                        // زر الاتصال
                        _buildCircleActionBtn(
                          icon: Icons.phone,
                          color: AppColors.primary,
                          tooltip: context.l10n.map_call,
                          onTap: () => _makeCall(prop.contactPhone),
                        ),
                        const SizedBox(width: 6),

                        // زر واتساب
                        if (prop.contactWhatsapp != null &&
                            prop.contactWhatsapp!.isNotEmpty) ...[
                          _buildCircleActionBtn(
                            icon: Icons.chat,
                            color: Colors.green.shade600,
                            tooltip: context.l10n.map_whatsapp,
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
                          tooltip: context.l10n.map_directions,
                          onTap: () => _openGoogleMapsNavigation(prop),
                        ),
                        const SizedBox(width: 6),

                        // زر التفاصيل / التوافر
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
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
                                isRent ? context.l10n.map_check_availability : context.l10n.map_view_details,
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
                            context.l10n.map_directions_google_maps,
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
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 10.5,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}


