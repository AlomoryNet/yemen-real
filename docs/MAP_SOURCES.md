# Map sources, offline cache, and PMTiles migration

## Current stack (2026-11-26)

| Purpose | Source | Key / billing | Notes |
| --- | --- | --- | --- |
| Street/vector map | OpenFreeMap Liberty style (`https://tiles.openfreemap.org/styles/liberty`) | None | Rendered through `MapLibreLayer` inside the existing `FlutterMap`, so clusters, polygons, animated camera moves and RTL overlays stay unchanged. |
| Satellite raster | Esri World Imagery (`server.arcgisonline.com/.../World_Imagery/...`) | None | Kept only for the existing satellite toggle. Attribution is shown in the map. No Esri street tiles remain. |
| Boundaries | Bundled governorate GeoJSON in `assets/` | None | Fully offline, independent of tile services. |
| Location | `geolocator` (OS location APIs) | None | No geocoding/reverse-geocoding service is used. |
| Directions | Google Maps outbound URLs | None | `https://www.google.com/maps/...` deep links only; no API key or billable request. |

Google Fonts runtime fetching is disabled; the OpenFreeMap style uses Noto Sans
glyphs from OpenFreeMap's own font endpoint. The tiles contain Arabic `name:ar`
fields and the device downloaded an Arabic glyph range, but the Liberty style
itself renders Latin names. App-owned governorate/district labels (chips, cards,
filter sheet, contracts) are localized through `AppConstants` and the ARBs, so
Arabic mode shows `إب` etc. A future self-hosted style can change the label
expressions to prefer `name:ar`. Public `tile.openstreetmap.org` tiles are
deliberately not used: they were unreachable from the target device.

All configurable URLs live in `lib/core/constants/map_sources.dart`. Swapping to
a self-hosted style should only require changing `openFreeMapStyleUrl` there.

## Local cache

- MapLibre's ambient cache is capped at **100 MB** at startup
  (`MapOfflineService.configureAmbientCache`). Tiles and style resources for
  areas the user actually views are retained automatically at any zoom.
- Settings → **الخريطة دون اتصال** can pre-download a country pack covering
  Yemen (including Socotra) at zoom **5–10**. That is 1,105 vector tiles
  (~9 MB measured on device), within OpenFreeMap's public-instance limit of
  3,000 tiles and 50 MB per offline download. Zoom 11 alone would add 3,010
  tiles, so it is deliberately excluded; city-level detail comes from the
  ambient cache after it has been viewed online once.
- The region can be deleted from the same Settings tile. Downloads use the
  native MapLibre offline database; no app-managed HTTP cache is needed.
- MapLibre native owns the `User-Agent` header, so requests carry an additional
  `X-Yemen-Real-Estate-Portal` header to identify the app in access logs. The
  map plugin uses MapLibre's default request concurrency; a self-hosted R2
  style is the path to full control over concurrency and UA.
- Verification: after downloading, enable airplane mode and reopen the map.
  The downloaded overview and previously viewed detail areas should still
  render. Attribution remains visible offline.

## Future: self-hosted PMTiles on Cloudflare R2

The app is prepared for this but it is **not enabled yet**. Recommended pipeline:

1. Obtain a Yemen OSM extract (Geofabrik or BBBike) and generate
   `yemen.pmtiles` with Planetiler (zoom 0–14 is a reasonable ceiling).
2. Create a Cloudflare R2 bucket in the free tier (10 GB-month included),
   enable its public `r2.dev` URL or attach a custom domain, and upload the
   `.pmtiles` object.
3. Set R2 CORS to allow the app origin(s) and expose `Content-Range` and
   `Accept-Ranges`. PMTiles requires byte-range requests; verify with:
   `curl -I -H 'Range: bytes=0-16' https://<r2-url>/yemen.pmtiles`.
4. Publish a style JSON whose vector source points at
   `pmtiles://https://<r2-url>/yemen.pmtiles` (Protomaps/MapLibre PMTiles
   plugin) and whose `name` fields prefer `name:ar` with `name` fallback.
5. Change `AppMapSources.openFreeMapStyleUrl` to the R2 style URL behind a
   config flag, keeping OpenFreeMap as the fallback until the R2 style has been
   verified on `ZY22G4C24N` in Arabic and English, light and dark.
6. Re-download the offline pack from the new style. Existing cached regions
   are style-bound; delete the old Yemen region in Settings first.

Expect R2 egress and Class B operations to stay within the free tier for a
country-sized PMTiles file, but monitor range-request counts after launch.

## URL pre-flight (2026-11-26)

- `tiles.openfreemap.org/styles/liberty` — HTTP 200 JSON on dev PC.
- OpenFreeMap Yemen vector tile and Arabic glyph range — downloaded on device.
- `server.arcgisonline.com` and `r2.cloudflarestorage.com` — device TCP 443 OK.
- `tile.openstreetmap.org` — device TCP 443 failed; excluded.
