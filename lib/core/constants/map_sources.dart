/// Free map tile sources used by every map surface in the app.
///
/// Street maps use OpenFreeMap vector tiles (no API key, no billing) rendered
/// by MapLibre. Satellite imagery stays on the existing Esri World Imagery
/// raster service, which is also free with attribution. The future PMTiles
/// export hosted on Cloudflare R2 can replace [openFreeMapStyleUrl] without
/// touching any screen.
class AppMapSources {
  const AppMapSources._();

  /// OpenFreeMap Liberty style. Includes `name:ar` fields and Noto Sans
  /// glyphs, so Arabic governorate/district labels render correctly.
  static const String openFreeMapStyleUrl =
      'https://tiles.openfreemap.org/styles/liberty';

  static const String openFreeMapAttribution =
      '© OpenStreetMap contributors · OpenFreeMap · OpenMapTiles';
  static const String openFreeMapAttributionUrl = 'https://openfreemap.org';

  /// MapLibre native manages `User-Agent`, so the public instance cannot see
  /// an app-specific UA. This header at least identifies the client in access
  /// logs. A self-hosted R2 style can use a real customized UA later.
  static const Map<String, String> appRequestHeaders = <String, String>{
    'X-Yemen-Real-Estate-Portal': 'yemen-real-estate-portal/1.0',
  };

  /// Esri World Imagery is used only for the optional satellite view.
  static const String satelliteTileUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  static const String satelliteAttribution = 'Imagery © Esri, Maxar, Earthstar Geographics';
  static const String satelliteAttributionUrl = 'https://www.esri.com/';
}
