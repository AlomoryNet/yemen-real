# AGENTS.md — Working memory for agents (project: Yemen Real Estate Portal)

Flutter (Android/iOS/Web/Windows) RTL Arabic-first app. Supabase backend with automatic
demo/offline fallback (DemoPropertiesGenerator). State: Riverpod. Routing: GoRouter
(lib/config/app_router.dart). Maps: flutter_map + Yemen GeoJSON. Backend: supabase_flutter.

## Golden rules
1. Read `AGENTS.md` before making changes. Update the "Status — latest" section after any change.
   Full history lives in `AGENTS_HISTORY.md`; read it only when prior decisions/history are needed.
2. NEVER download anything (SDKs, Gradle, AGP, NDK, platforms) without explicit user approval.
   Machine has multiple JDKs (Corretto 8/17/18) — JAVA_HOME=Corretto 17 is correct; do not change it.
3. Prefer USB device `ZY22G4C24N` (moto g pure) over network `192.168.8.117:33803` (too slow).
4. Verify with `flutter analyze` (must report zero issues) and a USB `flutter run -d ZY22G4C24N`.
5. `pubspec.lock` is committed; if you change deps, keep it consistent.
6. User is Arabic-first; UI strings are hardcoded Arabic (no l18n/i18n — do not expect runtime
   translations and do not flip locale expecting translated strings).
7. No destructive deletions of docs files without explicit per-item user approval.

## Environment (do not fight it)
- Flutter 3.47.6 stable / Dart 3.13.5, JAVA_HOME Corretto 17. Android SDK at
  `C:\Users\komar\AppData\Local\Android\sdk` (android-36/37, NDK 26.3.11579264 REQUIRED, installed).
- Android: Gradle wrapper 9.3.1, AGP 9.1.0, KGP 2.4.0, Java 17.
  `gradle.properties` MUST keep `android.builtInKotlin=false` and `android.newDsl=false`
  (Flutter 3.47 auto re-adds them). Do not bump compileSdk/targetSdk/minSdk/NDK without asking.
- pubspec sdk floor: `^3.11.0-0` (lockfile requires it).

## Project layout
- `lib/main.dart` — entry, Supabase init, auth state stream (fixed locale ar_YE).
- `lib/config/app_router.dart` — routes + single back-button handler (GlobalAppBackHandler, PopScope).
- `lib/core/{theme,constants,utils}` · `lib/features/<name>/presentation` (screens)
- `lib/shared/widgets` — shared UI. Key files:
  - `app_header.dart` — MINIMAL app bar: (mobile/tablet) drawer menu button + centered app name.
    No logo, no Add Property CTA, no settings gear, no auth actions, no map button, no language toggle.
  - `app_navigation_rail.dart` — persistent expanded NavigationRail for desktop (>=1100dp):
    الرئيسية/البحث/الخريطة/المفضلة (+ عقاراتي/طلبات/الملف الشخصي for authenticated, لوحة الإدارة
    for admins) with account section (profile + تسجيل الخروج / دخول) pinned at the bottom.
  - `app_page_body.dart` — wraps a screen body with the rail on desktop; no-op on mobile/tablet.
  - `app_bottom_nav_bar.dart` — 4 destinations (الرئيسية، البحث، الخريطة، عقاراتي); mobile/tablet only.
  - `app_drawer.dart` — single account home (login CTA / profile / properties / requests / admin / logout)
    + prominent gradient map card. Mobile/tablet only (desktop uses the rail).
  - `app_footer.dart` — all links are real `context.push` routes (no dead text).
- `lib/providers/` · `lib/repositories/` · `lib/models/` · `lib/services/`
- `assets/` — map geojson, images, fonts. `test/` holds the suite.

## Conventions / UI decisions (do not regress)
- Auth lives ONLY in the drawer (mobile/tablet) and the navigation rail (desktop). Never add
  account/login buttons to the app bar, bottom nav, map top bar, or header.
- Desktop (>=1100dp, see `core/utils/responsive.dart`) = expanded rail (M3); bottom nav and drawer
  are hidden (`isDesktop ? null : ...`). Tablet/mobile = bottom nav + drawer.
- Home has NO hero map banner. The single map CTA is the "خريطة اليمن / أضف إعلانك" publisher row
  (one responsive implementation, not duplicated per breakpoint).
- Search screen results area toggles in-screen between list grid and a flutter_map view of the SAME
  filtered results (FAB, endFloat, collapses to icon-only on scroll via `isExtended` + `AnimatedSize`;
  re-expands near top). FAB does NOT navigate to /map. No map button in the search top bar.
- Property detail: keep the small overlay map button ON the map preview; the standalone full-width
  teal map button was removed.
- Map screen: floating top bar has back button + search + filter chips only (user avatar removed;
  menu button mobile-only). Full-screen /map has no app bar by design.
- No language toggle anywhere (i18n not implemented). If real i18n lands, restore from git history.

## How to verify
```
flutter analyze   → expect "No issues found!"
flutter run -d ZY22G4C24N   (USB, preferred)
flutter test      → suite (last known: 56 tests)
```

## Status — latest
- Current focus: unified property cards + redesigned property/admin/settings/drawer/map UI.
- `PropertyCard` (`lib/shared/widgets/property_card.dart`) is canonical with `grid`,
  `row`, `overlay`, `management` layouts plus optional carousel/favorite/spec chips and
  call/WhatsApp/directions/detail action slots. Shared tokens live in
  `lib/core/theme/property_text_styles.dart` and `lib/shared/widgets/property/`.
  Dashboard, favorites, map cluster rows, map list, map selected card and My Properties
  all use it. Rich map-card actions were preserved as slots.
- My Properties rebuilt: page header, stats tiles, deal chips, management cards, popup
  actions, FAB and empty states. It now **paginates** owner listings (12 per page) via
  `UserPropertiesPaginator`; totals come from a lightweight `getUserPropertyStats` query
  (`lib/models/user_property_stats.dart`), so the tab never builds all 440 demo cards.
  "Load more" appears below the list and auto-triggers near the bottom of the scroll view.
- Same bounded-page pattern applied to Favorites and the admin moderation queue (12 visible
  cards + "Load more" button). Map list and admin tabs already use lazy/limited builders.
- Rail Search + Map merged into one `البحث والخريطة` destination → `/map`; added
  `sh_nav_search_map` to ARB/generated l10n. Bottom nav deliberately stays at **2**
  destinations (Home + My properties).
- Drawer now highlights the active route with tokenized surfaces/check icons. Settings
  received tokenized cards/headers while keeping the live `ar_YE/en_US` radio.
- Admin split: `/admin` and `AdminDashboardScreen({super.key})` unchanged; the old
  2,555-line screen now delegates to `presentation/widgets/`, `presentation/tabs/` and
  `services/admin_pdf_service.dart`. PDF section mapping 0–4, super-admin whitelist,
  provider refreshes and `context.mounted` guards all preserved.
- Map: floating header gained a subtle divider and translucent surface; filter-chip row
  indentation normalized. Previous grouped-property sheet, reusable filter sheet and
  dashboard category sections remain intact.
- Overflow regression fixes: admin moderation action buttons use `Wrap`; owner/date/type/price
  rows, admin section headers, the moderation empty-state row and the Profile header name/admin
  badge row use `Flexible`/`Expanded` + ellipsis; `PropertyCard._badges` uses `Wrap` (map discount
  pill no longer overflows); map selected-card price caption is ellipsized.
- Map tiles: all three street `TileLayer`s (`property_map_view.dart`,
  `property_detail_screen.dart`, `add_edit_property_screen.dart`) use **Esri World
  Street Map** (`https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}`,
  no subdomains/key) with `TextSourceAttribution` 'Tiles © Esri — Sources: Esri, HERE,
  Garmin, USGS, OpenStreetMap contributors, GIS User Community' linking to the Esri
  terms. Esri World Imagery satellite layer unchanged. `errorTileCallback` logging kept.
  Detail/add-edit attribution is padded above bottom action overlays;
  `AttributionAlignment` only supports bottomLeft/bottomRight in flutter_map 8.3.2.
  Do NOT use CARTO Voyager: in 2026 its URL still returns HTTP 200 but serves a
  ~2 KB placeholder PNG reading `API KEY REQUIRED carto.com/basemaps/apikey`.
  Do NOT use OSM public tiles: unreachable from `ZY22G4C24N` (socket errno 101)
  despite google.com loading in Chrome. Dev PC reaches internet only via Cloudflare
  VPN, so its Sanaa/YE geolocation is not the router WAN IP.
- Last verified: `flutter analyze` clean, 56/56 tests, fresh USB `flutter run -d ZY22G4C24N`
  (2026-11-24). /map opened on device with Esri street tiles rendering (133 distinct
  quantized colour buckets, OCR found no 'API KEY REQUIRED'); no tile-failure logs and
  no runtime errors. Earlier 2026-11-23 USB pass covered My Properties, Favorites,
  Admin dashboard, Map + list view with no `RenderFlex overflow` or widget errors.
- Full changelog: `AGENTS_HISTORY.md`.

## Docs policy
- AGENTS.md = agent memory (this file). PROJECT_SUMMARY.md = stale human snapshot, keep for context.
- `docs/reports/` = historical verification (keep) · `docs/screenshots/` = curated only
- Do not add new report files without user request. Update this file after every completed change.

## Focus folders for code tasks
- `lib/main.dart`, `lib/config/`, `lib/core/`, `lib/shared/`, `lib/features/`,
  `lib/providers/`, `lib/repositories/`, `lib/models/`, `lib/services/`.

## Context efficiency
- Do not read binary assets/docs (`*.pdf`, `*.png`, `*.geojson`, `assets/**`, `docs/**`) unless a
  task explicitly requires them.
- Prefer targeted `glob`/`grep` over full-repo reads.
- For feature-scoped work, use a sub-agent with a narrowed file set (e.g. `lib/features/map/**`).
- Keep this file short; put detailed change logs in `AGENTS_HISTORY.md`.