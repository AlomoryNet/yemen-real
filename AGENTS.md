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
- Current focus: themed map grouped-properties bottom sheet.
- `_ClusterPropertiesSheet` in `lib/features/map/presentation/property_map_view.dart`
  now uses app surface/divider/teal tokens, a count pill, close action, deal badges,
  thumbnails, meta chips and price rows. It is bottom-anchored, bounded to
  620dp x 78% screen height, safe-area/IME aware, and shrink-wraps short lists.
  User-owned OSM tile-loading edits were preserved.
- Previous: reusable dashboard category sections + shared filter sheet.
  Added `PropertyCategorySection` (bounded preview, real count, view-all) and
  `PropertyFilterSheet` (searchable governorate/district dropdowns, M3 chips);
  dashboard hero now has search + one filter button only, and the map reuses
  the same sheet with advanced filters.
- Follow-up fixed runtime assertions: wrapped the filter sheet's
  `SwitchListTile` in a transparent `Material`, and switched the map screen to
  `TickerProviderStateMixin` for repeated camera animations.
- Map tiles: `TileLayer` in `property_map_view.dart` and
  `property_detail_screen.dart` now rotate OSM `a/b/c` subdomains and log tile
  failures via `errorTileCallback`. Diagnosis on `ZY22G4C24N` (2026-11-23):
  blank tiles are caused by the **phone having no outbound internet** (Chrome:
  `DNS_PROBE_FINISHED_NXDOMAIN`, TCP timeouts to public IPs) even though WiFi
  "Alomory" is associated; PC on the same `192.168.8.1` network has internet.
  OSM does NOT block our `com.yemenreal.portal` User-Agent (verified real tile,
  no `x-blocked` header) — no provider switch needed for that reason.
- Last verified: `flutter analyze` clean, 56/56 tests, USB hot restart/reload on
  `ZY22G4C24N` (2026-11-23). Grouped-property sheet opens, stays compact and
  selects a property correctly. Only runtime errors are the known offline OSM
  tile `Network is unreachable` failures.
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