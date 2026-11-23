import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../models/property.dart';
import '../../../core/theme/app_colors.dart';
import '../services/map_cluster_service.dart';
import '../../../core/l10n/context_l10n.dart';

/// One official governorate polygon from the Yemen ADM1 GeoJSON asset.
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

/// Short price label used on map markers (e.g. Â«5.2 Ù… Ø±.ÙŠÂ», Â«850 Ø£Ù„Ù Ø±.ÙŠÂ»).
String formatMapPriceTag(BuildContext context, Property p) {
  final cur = p.currency == AppConstants.currencyYer
      ? context.l10n.map_currency_yer
      : p.currency == AppConstants.currencyUsd
          ? '\$'
          : context.l10n.map_currency_sar;

  final isRent = p.dealType == AppConstants.dealRent;
  final suffix = isRent ? context.l10n.map_per_month : '';

  if (p.price >= 1000000) {
    final millions = (p.price / 1000000).toStringAsFixed(1).replaceAll('.0', '');
    return '$millions ${context.l10n.map_million_abbr} $cur $suffix'.trim();
  } else if (p.price >= 1000) {
    final thousands = (p.price / 1000).toStringAsFixed(0);
    return '$thousands ${context.l10n.map_thousand_abbr} $cur $suffix'.trim();
  }
  return '${p.price.toStringAsFixed(0)} $cur $suffix'.trim();
}

/// Shared interactive map used by BOTH the /map tab and the search results
/// listâ†”map toggle. Renders: OpenStreetMap / Esri satellite tiles, official
/// Yemen governorate boundaries (from bundled GeoJSON), spatial clustering
/// with price pin markers, and an optional freehand-drawn polygon.
///
/// Host concerns (selected-property card, filters, search-this-area, satellite
/// toggle button, drawing gestures) stay in the hosts; pass them in via the
/// constructor parameters and callbacks.
class PropertyMapView extends StatefulWidget {
  final List<Property> properties;
  final MapController? mapController;
  final LatLng initialCenter;
  final double initialZoom;
  final double minZoom;
  final double maxZoom;
  final bool isSatellite;
  final String? selectedPropertyId;
  final String? highlightGovernorate;
  final List<LatLng> drawnPolygon;
  final bool showBoundaries;

  /// Interaction flags bitmask (defaults to all interactive). Pass
  /// [InteractiveFlag.none] while a freehand drawing gesture is active.
  final int interactionFlags;

  final void Function(MapCamera camera, bool hasGesture)? onPositionChanged;
  final void Function(TapPosition tapPosition, LatLng point)? onMapTap;

  /// Called with the tapped property and its marker centroid.
  final void Function(Property property, LatLng centroid)? onPropertyTap;

  const PropertyMapView({
    super.key,
    required this.properties,
    this.mapController,
    this.initialCenter = const LatLng(15.3547, 44.2075),
    this.initialZoom = 7.5,
    this.minZoom = 5.0,
    this.maxZoom = 18.0,
    this.isSatellite = false,
    this.selectedPropertyId,
    this.highlightGovernorate,
    this.drawnPolygon = const [],
    this.showBoundaries = true,
    this.interactionFlags = InteractiveFlag.all,
    this.onPositionChanged,
    this.onMapTap,
    this.onPropertyTap,
  });

  @override
  State<PropertyMapView> createState() => _PropertyMapViewState();
}

class _PropertyMapViewState extends State<PropertyMapView>
    with SingleTickerProviderStateMixin {
  static List<GovernorateBoundary>? _cachedBoundaries;
  static Future<List<GovernorateBoundary>>? _loadingBoundaries;

  static const Map<String, String> _shapeNameToArabic = {
    "SanÊ¿aÊ¾": "Ø£Ù…Ø§Ù†Ø© Ø§Ù„Ø¹Ø§ØµÙ…Ø©",
    "SanÊ¿aÊ¾ Governorate": "ØµÙ†Ø¹Ø§Ø¡",
    "Lahij Governorate": "Ù„Ø­Ø¬",
    "â€˜Adan Governorate": "Ø¹Ø¯Ù†",
    "Al Hudaydah Governorate": "Ø§Ù„Ø­Ø¯ÙŠØ¯Ø©",
    "Ta'izz Governorate": "ØªØ¹Ø²",
    "Shabwah Governorate": "Ø´Ø¨ÙˆØ©",
    "Hadhramaut": "Ø­Ø¶Ø±Ù…ÙˆØª",
    "Abyan Governorate": "Ø£Ø¨ÙŠÙ†",
    "Al Jawf Governorate": "Ø§Ù„Ø¬ÙˆÙ",
    "Ibb Governorate": "Ø¥Ø¨",
    "Al Bayda' Governorate": "Ø§Ù„Ø¨ÙŠØ¶Ø§Ø¡",
    "Ad Dali' Governorate": "Ø§Ù„Ø¶Ø§Ù„Ø¹",
    "Al Mahwit Governorate": "Ø§Ù„Ù…Ø­ÙˆÙŠØª",
    "Sa'dah Governorate": "ØµØ¹Ø¯Ø©",
    "Hajjah Governorate": "Ø­Ø¬Ø©",
    "Dhamar Governorate": "Ø°Ù…Ø§Ø±",
    "'Amran Governorate": "Ø¹Ù…Ø±Ø§Ù†",
    "Al Mahrah Governorate": "Ø§Ù„Ù…Ù‡Ø±Ø©",
    "Ma'rib Governorate": "Ù…Ø£Ø±Ø¨",
    "Raymah Governorate": "Ø±ÙŠÙ…Ø©",
    "Socotra": "Ø³Ù‚Ø·Ø±Ù‰",
  };

  static Future<List<GovernorateBoundary>> _loadBoundariesOnce() {
    final cached = _cachedBoundaries;
    if (cached != null) return Future.value(cached);
    return _loadingBoundaries ??= _readBoundaries();
  }

  static Future<List<GovernorateBoundary>> _readBoundaries() async {
    try {
      final jsonStr = await rootBundle
          .loadString('assets/map/yemen_adm1_simplified.geojson');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>;
      final List<GovernorateBoundary> loaded = [];

      void addRing(List<List<LatLng>> rings, List<dynamic> ring) {
        final points = ring.map((pt) {
          final p = pt as List<dynamic>;
          final lon = (p[0] as num).toDouble();
          final lat = (p[1] as num).toDouble();
          return LatLng(lat, lon);
        }).toList();
        if (points.isNotEmpty) rings.add(points);
      }

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
            addRing(rings, ring as List<dynamic>);
          }
        } else if (type == 'MultiPolygon') {
          for (final poly in coords) {
            for (final ring in poly as List<dynamic>) {
              addRing(rings, ring as List<dynamic>);
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

      _cachedBoundaries = loaded;
      return loaded;
    } catch (e) {
      debugPrint('Error loading Yemen GeoJSON: $e');
      return const [];
    }
  }

  late final MapController _controller;
  late final bool _ownController;
  late double _zoom;
  List<GovernorateBoundary> _boundaries = const [];

  @override
  void initState() {
    super.initState();
    _zoom = widget.initialZoom;
    final provided = widget.mapController;
    _controller = provided ?? MapController();
    _ownController = provided == null;
    _loadBoundariesOnce().then((loaded) {
      if (mounted) setState(() => _boundaries = loaded);
    });
  }

  @override
  void dispose() {
    if (_ownController) _controller.dispose();
    super.dispose();
  }

  void _animatedMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
      begin: _controller.camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: _controller.camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _controller.camera.zoom,
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
      _controller.move(
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

  void _handleClusterTap(PropertyCluster cluster) {
    if (cluster.latSpan > 0.0003 ||
        cluster.lngSpan > 0.0003 ||
        _zoom < 15.0) {
      _animatedMove(cluster.centroid, math.min(_zoom + 2.5, 16.5));
    } else {
      _showClusterPropertiesSheet(cluster.properties);
    }
  }

  void _showClusterPropertiesSheet(List<Property> props) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.infoMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: AppColors.info,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${context.l10n.map_cluster_properties_title} (${props.length} ${context.l10n.map_cluster_property_unit})',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: context.l10n.map_close,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: props.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final p = props[index];
                    final imageUrl = p.images.isNotEmpty
                        ? p.images.first.imageUrl
                        : p.primaryImageUrl;

                    Widget thumbnail() {
                      final fallback = Container(
                        color: AppColors.surfaceVariant,
                        child: Icon(
                          Icons.apartment,
                          color: AppColors.textMuted,
                        ),
                      );
                      if (imageUrl == null || imageUrl.isEmpty) {
                        return fallback;
                      }
                      return CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.surfaceVariant,
                          child: const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => fallback,
                      );
                    }

                    return Material(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          final c =
                              MapClusterService.getPropertyCoordinates(p);
                          widget.onPropertyTap?.call(p, LatLng(c.$1, c.$2));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: thumbnail(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                        height: 1.25,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${p.city}${p.district.isNotEmpty ? ' - ${p.district}' : ''}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      formatMapPriceTag(context, p),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryInk,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_left_rounded,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
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

  @override
  Widget build(BuildContext context) {
    final clusters = MapClusterService.clusterProperties(
      properties: widget.properties,
      zoom: _zoom,
    );
    final highlight = widget.highlightGovernorate;

    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: widget.initialCenter,
        initialZoom: widget.initialZoom,
        minZoom: widget.minZoom,
        maxZoom: widget.maxZoom,
        interactionOptions: InteractionOptions(flags: widget.interactionFlags),
        onPositionChanged: (pos, hasGesture) {
          if ((pos.zoom - _zoom).abs() > 0.001) {
            setState(() => _zoom = pos.zoom);
          }
          widget.onPositionChanged?.call(pos, hasGesture);
        },
        onTap: (tapPosition, point) =>
            widget.onMapTap?.call(tapPosition, point),
      ),
      children: [
        TileLayer(
          urlTemplate: widget.isSatellite
              ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
              : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.yemenreal.portal',
          maxZoom: 19,
        ),
        if (widget.showBoundaries && _boundaries.isNotEmpty)
          PolygonLayer(
            polygons: _boundaries.expand((gov) {
              final isSelected = highlight != null &&
                  (gov.arabicName == highlight ||
                      gov.arabicName.contains(highlight) ||
                      highlight.contains(gov.arabicName));
              return gov.polygonRings.map((ring) {
                return Polygon(
                  points: ring,
                  color: isSelected
                      ? AppColors.primary.withAlpha(45)
                      : Colors.transparent,
                  borderColor: isSelected
                      ? AppColors.primary
                      : const Color(0xFF4A5568).withAlpha(120),
                  borderStrokeWidth: isSelected ? 2.8 : 1.2,
                );
              });
            }).toList(),
          ),
        if (widget.drawnPolygon.isNotEmpty)
          PolygonLayer(
            polygons: [
              Polygon(
                points: widget.drawnPolygon,
                color: AppColors.primary.withAlpha(45),
                borderColor: AppColors.primary,
                borderStrokeWidth: 3.0,
              ),
            ],
          ),
        MarkerLayer(
          markers: clusters.map((cluster) {
            if (cluster.isSingle) {
              final prop = cluster.singleProperty;
              final isSelected = widget.selectedPropertyId == prop.id;
              final isRent = prop.dealType == AppConstants.dealRent;
              final hasExact = MapClusterService.hasExactCoordinates(prop);

              return Marker(
                point: cluster.centroid,
                width: isSelected ? 160 : 140,
                height: isSelected ? 74 : 66,
                child: GestureDetector(
                  onTap: () =>
                      widget.onPropertyTap?.call(prop, cluster.centroid),
                  child: _PropertyPriceMarker(
                    priceText: formatMapPriceTag(context, prop),
                    isSelected: isSelected,
                    isRent: isRent,
                    hasExact: hasExact,
                  ),
                ),
              );
            }

            final count = cluster.count;
            final size = count >= 100 ? 60.0 : (count >= 10 ? 54.0 : 48.0);
            return Marker(
              point: cluster.centroid,
              width: size,
              height: size,
              child: GestureDetector(
                onTap: () => _handleClusterTap(cluster),
                child: _ClusterBadge(count: count),
              ),
            );
          }).toList(),
        ),
        RichAttributionWidget(
          alignment: AttributionAlignment.bottomRight,
          attributions: [
            TextSourceAttribution(
              widget.isSatellite
                  ? 'Esri, Maxar, Earthstar Geographics'
                  : 'OpenStreetMap contributors',
              onTap: () {
                final uri = Uri.parse(widget.isSatellite
                    ? 'https://www.esri.com/'
                    : 'https://www.openstreetmap.org/copyright');
                canLaunchUrl(uri).then((ok) {
                  if (ok) launchUrl(uri, mode: LaunchMode.externalApplication);
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Google Maps-style teardrop pin with a price badge.
class _PropertyPriceMarker extends StatelessWidget {
  final String priceText;
  final bool isSelected;
  final bool isRent;
  final bool hasExact;

  const _PropertyPriceMarker({
    required this.priceText,
    required this.isSelected,
    required this.isRent,
    this.hasExact = true,
  });

  @override
  Widget build(BuildContext context) {
    // Selected = amber, rent = blue, sale = teal
    final pinColor = isSelected
        ? const Color(0xFFD97706)
        : (isRent ? const Color(0xFF1565C0) : const Color(0xFF0F766E));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
}

/// Circular cluster badge with brand styling (blue / dark blue / red by size).
class _ClusterBadge extends StatelessWidget {
  final int count;

  const _ClusterBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final size = count >= 100 ? 56.0 : (count >= 10 ? 50.0 : 44.0);
    final inner = count >= 50
        ? const Color(0xFFD32F2F)
        : count >= 10
            ? const Color(0xFF1565C0)
            : AppColors.primary;

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
}

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

    // Drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final shadowPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx + 1, headY + 2), radius: r))
      ..moveTo(cx - 1, headY + r - 2)
      ..lineTo(cx + 1, h + 2)
      ..lineTo(cx + 3, headY + r - 2);
    canvas.drawPath(shadowPath, shadowPaint);

    // Teardrop body
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final pinPath = Path();
    pinPath.moveTo(cx, h); // tip
    pinPath.cubicTo(
      cx - r * 0.3,
      headY + r * 0.9,
      cx - r,
      headY + r * 0.5,
      cx - r,
      headY,
    );
    pinPath
        .arcTo(Rect.fromCircle(center: Offset(cx, headY), radius: r), math.pi,
            math.pi, false);
    pinPath.cubicTo(
      cx + r,
      headY + r * 0.5,
      cx + r * 0.3,
      headY + r * 0.9,
      cx,
      h,
    );
    pinPath.close();
    canvas.drawPath(pinPath, fillPaint);

    // White border stroke
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.5 : 1.8;
    canvas.drawPath(pinPath, strokePaint);

    // Inner white dot (GPS crosshair)
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
      old.color != color ||
      old.isSelected != isSelected ||
      old.isApproximate != isApproximate;
}
