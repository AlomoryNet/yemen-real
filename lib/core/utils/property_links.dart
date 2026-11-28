const String _configuredWebOrigin = String.fromEnvironment('APP_BASE_URL');

/// Builds and parses links that open a property detail page.
///
/// The custom `yemenreal://property/<id>` scheme is the default share link.
/// A deployed HTTPS origin supplied at build time with `APP_BASE_URL` makes
/// [propertyShareUrl] return an HTTPS `/property/<id>` link instead. Real
/// Android App Links and iOS Universal Links are not configured yet, so the
/// custom scheme is intentionally retained as the fallback.
abstract final class PropertyLinks {
  /// The custom URL scheme handled by the installed app.
  static const String customScheme = 'yemenreal';

  /// The host used by custom-scheme property links.
  static const String propertyHost = 'property';

  /// The first path segment of a web property link.
  static const String webSegment = 'property';
}

/// Returns the app route for the property identified by [id].
String propertyPath(String id) =>
    '/${Uri(pathSegments: [PropertyLinks.webSegment, id])}';

/// Returns the custom-scheme URI that opens [id] in the installed app.
Uri propertyAppUri(String id) => Uri(
      scheme: PropertyLinks.customScheme,
      host: PropertyLinks.propertyHost,
      pathSegments: [id],
    );

/// Returns the shareable URL for the property identified by [id].
///
/// Uses [webOrigin] or the build-time `APP_BASE_URL` when either is a valid
/// HTTP origin, and otherwise falls back to [propertyAppUri]. The environment
/// value is read with [String.fromEnvironment] and has no literal default.
String propertyShareUrl(String id, {String? webOrigin}) {
  final origin = (webOrigin ?? _configuredWebOrigin).trim();
  if (origin.isNotEmpty) {
    final parsed = Uri.tryParse(origin);
    if (parsed != null && parsed.hasScheme && parsed.hasAuthority) {
      return parsed
          .replace(
            pathSegments: [PropertyLinks.webSegment, id],
            query: null,
            fragment: null,
          )
          .toString();
    }
  }
  return propertyAppUri(id).toString();
}

/// Extracts a property id from an incoming app or web link.
///
/// Returns `null` when [uri] is not a supported property link.
String? propertyIdFromLink(Uri uri) {
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  final isCustomScheme =
      uri.scheme.toLowerCase() == PropertyLinks.customScheme;

  if (isCustomScheme &&
      uri.host.toLowerCase() == PropertyLinks.propertyHost &&
      segments.isNotEmpty) {
    return _decodeSegment(segments.first);
  }

  if (segments.length >= 2 &&
      segments.first == PropertyLinks.webSegment &&
      (isCustomScheme ||
          uri.scheme == 'https' ||
          uri.scheme == 'http')) {
    return _decodeSegment(segments[1]);
  }

  if (isCustomScheme &&
      uri.host.toLowerCase() == PropertyLinks.propertyHost) {
    return _decodeSegment(uri.queryParameters['id']);
  }

  return null;
}

String? _decodeSegment(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return Uri.decodeComponent(value);
  } catch (_) {
    return value;
  }
}
