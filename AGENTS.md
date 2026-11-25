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
flutter test      → suite (last known: 124 tests)
```

## Status — latest
- Readability fix (uncommitted, after `f85d78b` was committed/pushed): filter
  sheet chips (property type + minimum bedrooms) now set explicit label styles
  instead of relying on the theme's muted `textSecondary`: unselected labels use
  `AppColors.textPrimary` on `AppColors.surfaceVariant`, selected labels and
  icons use white on `AppColors.primary`. The featured badge in `PropertyCard`
  and property detail now pairs white ink (`AppColors.onAccentBadge`) with a
  deeper amber fill (`AppColors.accentBadgeFill`) so it reads in both themes;
  the old bright-amber/dark-ink pair was hard to read. Renamed
  `PropertyTextStyles.badgeOnAccent()` → `featuredBadge()`, added contrast and
  chip-label regressions (125/125 tests), and kept the bright-amber/dark-ink
  token for the other amber badges (hero count, admin/detail/profile icons).
  Fresh USB run + DTD hot reload: filter sheet remained readable in light mode
  (inspector confirmed the new label widget), Featured cards rendered in dark
  mode, no runtime errors and no new ANR (latest remains
  `anr_2026-11-25-03-21-45-455`).
- Env config moved off the exposed Dart file to `.env` (uncommitted): removed
  `lib/config/env_config.dart` entirely; Supabase URL/key now read directly via
  `String.fromEnvironment('SUPABASE_URL'/'SUPABASE_ANON_KEY', defaultValue: '')` at
  the call sites in `SupabaseService`, sourced from `--dart-define-from-file=.env`.
  Demo-mode logic relocated to the new minimal `lib/config/app_config.dart`
  (`AppConfig.isDemoMode` / `AppConfig.setForceDemoModeForTesting`); all repositories,
  storage service and tests updated to use it. `.env` holds SUPABASE_URL / SUPABASE_ANON_KEY /
  DEFAULT_CURRENCY / SUPPORT_PHONE / SUPPORT_WHATSAPP. `flutter analyze` clean;
  full suite passes after the badge contrast and map-query fixes below.
- Unified map query refactor (uncommitted): `MapQuery` + `mapQueryProvider` are
  now the single source of truth for map search text, filters, view and source.
  `YemenMapScreen` wraps every visit in a scoped provider override seeded before
  the first frame; chips, filter sheet Apply/Reset and search submit all commit
  through that notifier. Free text is user-owned — the governorate is only a
  removable chip, never injected into the search field. One build-time listener
  reframes the camera on filter changes; list/map toggles do not. Dashboard
  search, nearby, featured and category CTAs use typed `MapScreenArgs` factories
  and open list view. `filterMapProperties()` is a pure shared filter (status,
  text, chips, featured, nearby radius, drawn polygon). Fixed `onAccent` to a
  real dark ink (WCAG AA 5.6:1) instead of the light `darkTextPrimary`.
  Added `test/map_query_test.dart` and updated map regressions. Removed the now
  unused `MapQueryNotifier.seed()` (the scoped override owns initial state).
  `flutter analyze` clean, `flutter test` 124/124. Fresh USB cold run + DTD hot
  reload: direct `/map` opened with 20 listings + an Ibb chip; sheet Reset →
  Apply showed 440, plain Filters chip and a zoomed-out cluster field. Nearby
  "View all" opened list view with 20 listings + a Near You chip; deleting that
  chip showed 440. Dashboard search seeded `test` into the map field (0 results),
  and Featured "View all" opened list view with 88 featured listings + a
  Featured chip. No runtime errors and no new ANR (latest remains
  `anr_2026-11-25-03-21-45-455`).
- Filter reset/chip/zoom fix (uncommitted): resetting `/map`'s bottom-sheet
  filters and removing the governorate chip now both clear the auto-written
  governorate label from the search field, so the free-text pass no longer
  filters every listing out (English `Ibb` did not match Arabic data keys).
  Every chip removal now also requests a fresh fit-to-results. The fit camera's
  `minZoom` floor dropped from 11.5 to 3.0, so Reset-to-all actually zooms out
  over Yemen; tiny result sets are still expanded before fitting. Added two
  widget regressions; also corrected `PropertyTextStyles.badgeOnAccent()` to use
  `AppColors.onAccent` after two contrast tests caught `accentInk`. `flutter
  analyze` clean, `flutter test` 116/116. Fresh USB run: Ibb (20) → chip delete
  and sheet Reset → Apply both showed 440 with an empty search field, plain
  Filters chip and a visibly zoomed-out cluster field; hot reload clean, no
  runtime errors and no new ANR.
- Map/profile/readability/admin/demo-data UX batch completed (uncommitted):
  `/map` now derives its default governorate from stored location (إب fallback),
  applies that default to the filter sheet and actual filtering, makes
  fit-to-results the only camera authority after a filter change, and expands
  degenerate bounds so a single-area result is readable. `صنعاء` + `بيت بوس`
  still returns 2 listings in count/list/map. The filter sheet uses localized
  property-type labels and `onPrimaryContainer` for selected chips. Home keeps
  the original inline search-field/filter/search `Row`; on compact widths the
  48dp icon-only filter/search buttons use plain icon children so each icon is
  centered in its button. Profile is a
  pushed hierarchical page with a top back button and no bottom nav; drawer
  root routes use `go` while Profile/requests/settings use `push`. StatusBadge
  and detail/featured badges use brightness-aware ink/fill pairs, and drawer
  tints follow the theme. Admin title/tabs/PDF CTA and stat/list rows wrap
  instead of squeezing. Demo mode now seeds stable pending approvals,
  commissions, rental requests, reports, favorites and two usable logins;
  quick demo shortcuts fill a valid `Demo@2026` password. Added
  `test/demo_data_coverage_test.dart`, `test/navigation_demo_shortcuts_test.dart`
  and map default/localization regressions; fixed two login-row overflows
  found by the new widget test. `flutter analyze` clean, `flutter test`
  114/114. Fresh USB pass: `/map` opened with the Ibb default (20 listings) and
  localized filter sheet; Profile pushed with Back and no bottom nav, then
  returned home; light↔dark repainted immediately and badge ink switched from
  RGB(3,105,161) light to RGB(125,211,252) dark; admin header/stats rendered
  without squeeze. A follow-up hot reload restored the inline home search Row
  and confirmed centered compact button icons. No Flutter errors, overflows or
  new ANR. Device uses real
  Supabase credentials, so admin pending/commission counts stay 0 there; the
  seeded demo records are covered by `demo_data_coverage_test.dart`.
- Accessibility + loading UX completed (uncommitted): `AppColors.onAccent` /
  `PropertyTextStyles.badgeOnAccent()` fix the amber featured-badge contrast;
  icon controls gained tooltips/`Semantics` and 48dp targets, with root
  `FocusTraversalGroup` reading-order traversal. Added static `SkeletonLoader`
  via `LoadingView(skeleton: true)` and unified map/contract/admin states with
  `LoadingView`, `ErrorView(title: ...)` and `EmptyStateView`. Also fixed a USB
  regression where a camera animation could call `setState()` on a disposed map
  view: `YemenMapScreen` reuses and disposes one `AnimationController`, and
  `PropertyMapView` guards late position callbacks. `flutter analyze` clean,
  `flutter test` 105/105. Fresh USB launch verified `صنعاء`+`بيت بوس` → 2
  listings (map + list), detail thumbnails/favorites, contract preview/editor,
  admin pending empty state and Users tab; no Flutter errors or new ANR. Full
  detail in `AGENTS_HISTORY.md`.
- Admin list paging completed: the four previously unbounded admin selects
  (profiles, commissions, reports, rental requests) now use bounded
  `get*Page()` queries with stable secondary `id` ordering and separate counts.
  `AdminListPaginator` + new paginator providers feed the four admin tabs;
  `AdminPagedList` supports external `hasMore/isLoadingMore/onLoadMore`. CSV
  buttons and PDF sections await separate full-list providers that collect
  chunked `streamAll*ForExport()` streams, so exports still contain every row.
  Added `test/admin_paging_repository_test.dart`,
  `test/admin_list_paginator_test.dart` and external-paging widget tests;
  `flutter analyze` clean, 100/100 tests. Fresh USB cold launch + DTD hot
  restart: all four admin tabs opened, requests/commissions CSV dialogs and
  PDF sections 1–4 (properties/requests/commissions/reports/users) exported
  successfully; no Flutter runtime errors and no new `data_app_anr` entry
  (latest remains 2026-11-25 00:41:13). Demo lists fit one page, so device
  "Load more" was covered by the external-paging widget tests.
- Map cluster-animation regression fixed: `_PropertyMapViewState` now reuses a
  single `AnimationController` for cluster zoom taps, interpolating from the
  camera's current position instead of creating a new controller (and ticker)
  per tap. Added `test/property_map_cluster_ticker_test.dart`; `flutter analyze`
  clean, 92/92 tests. Fresh USB cold launch + DTD hot reload + repeated cluster
  taps/menu/back had no runtime errors and no new `data_app_anr` entry (latest
  remains 2026-11-25 00:41:13).
- Local Cairo font, no runtime fetch: `assets/fonts/Cairo.ttf` is bundled as
  family `CairoLocal`; `core/theme/app_fonts.dart` maps `FontWeight` to the
  variable font's `wght` axis (200–1000) and all former
  `GoogleFonts.cairo`/`outfit`/`amiri` call sites now use `AppFonts.cairo`.
  `main.dart` sets `GoogleFonts.config.allowRuntimeFetching = false`, so a
  future missed call fails instead of downloading a font. Added
  `test/app_fonts_test.dart`; `flutter analyze` clean, 91/91 tests; fresh USB
  cold launch with the new asset plus menu tap/back had no runtime errors.
- Contract locale defaults: `PropertyContract.defaultTemplate()` now generates
  the title, owner address, payment/duration text and legal clauses from
  `AppLocale` at creation time via `models/contract_default_text.dart`. The
  generated text is stored in the existing contract fields, so saved contracts
  keep their original language and no schema/JSON migration was needed. Added
  `test/contract_locale_defaults_test.dart`; `flutter analyze` clean, 87/87
  tests; fresh USB launch + DTD hot restart + menu tap/back had no runtime
  errors.
- i18n place names + PDF direction: contract/admin PDFs derive `pw.TextDirection`
  and alignment from `Directionality.of(context)` instead of forcing RTL.
  `AppLabelsEn` now owns English governorate/district labels; the display-only
  getters in `AppConstants` keep Arabic as the canonical data/filter key and are
  consumed by filter sheets, cards, detail, add/edit, map chips/caption and
  contract text. Demo `LocationItem.nameEn` uses the display label instead of a
  slug. Map governorate search text shows the localized label while skipping
  the redundant free-text pass so English mode still finds Arabic listings.
  Added `test/display_name_localization_test.dart` plus an English `/map`
  filter regression in `test/yemen_map_screen_test.dart`. `flutter analyze`
  clean, 83/83 tests; USB cold launch + DTD hot restart + menu tap/back had no
  runtime errors and no new `data_app_anr` entry (latest remains 2026-11-25
  00:41:13).
- Dashboard FAB stack alignment: the compact add-property FAB now shares the
  extended map FAB's trailing edge (`CrossAxisAlignment.end`) instead of being
  centered over it. The old centered look came from `Column`'s default
  `crossAxisAlignment: center` while `Scaffold` keeps the FAB at `endFloat`.
- ANR/input-dispatch mitigation: moved the dashboard's 440-listing nearby scan
  out of `HomeScreen.build` into cached `nearbyPropertiesProvider`; capped
  grid/management image decode width; delayed the first-run location prompt's
  SharedPreferences write until after the OS permission result; cached all
  distinct Cairo `TextStyle` variants keyed by exact size/weight/colour/height.
  Fixed two async regressions found on USB: reading Riverpod after the Home
  State was disposed, and calling `ProviderScope.containerOf` from `initState`.
  The location callback now captures settings/center notifiers with `ref.read`
  in `initState`. `flutter analyze` clean, 78/78 tests, USB hot restart after
  the fix had no runtime errors; menu tap + back produced no exceptions.
  Fresh USB cold launch installed cleanly with no Flutter exception and no new
  `data_app_anr` entry (latest remains 2026-11-25 00:41:13). Debug cold start
  still logs `Choreographer: Skipped frames` / `Davey` warnings on this device.
- Map filter/add-action correction: `AppConstants.governorateMatches` treats
  `صنعاء` and `أمانة العاصمة` as one area, so Governorate=صنعاء +
  District=بيت بوس now returns the 2 demo listings. The map count/list no longer
  clips filtered results to the current viewport. Added a shared compact
  `AddPropertyFab` (small FAB, `add_home_outlined`) shown on Home and only in the
  map's list view — never over the map. `flutter analyze` clean, 74/74 tests,
  USB hot restart with no runtime errors.
- Web deferred loading + clustering pass: `/admin` and `/map` now use deferred
  imports in `app_router.dart` behind a shared `DeferredScreen` (localized
  loading/error/retry). `MapScreenArgs` moved to a tiny file so Home does not
  eagerly import the map screen. `MapClusterService` now uses a spatial hash
  instead of an all-pairs scan. Added `test/deferred_screen_test.dart` and
  `test/map_cluster_service_test.dart`; `flutter analyze` clean, 74/74 tests,
  `flutter build web --release` succeeded with three deferred JS parts.
- Back/filter/settings UI pass: root back now shows the exit snackbar before exiting (verified twice on USB: first back keeps the app, second finishes the activity); global tap-to-dismiss uses `deferToChild` so register fields keep the keyboard; map filters fit the camera to the filtered coordinates, show a live count chip, drop "Search this area", and clamp list pagination; the add-property style setting now drives the hero button and a map-screen FAB; publisher/drawer map CTAs removed; first-run location consent + Settings retry added (USB log shows the OS permission dialog; it was cancelled so permission remains denied, retry is in Settings); search-radius intent documented. `flutter analyze` clean, 74/74 tests, fresh USB run + DTD hot restart with no runtime errors. See `AGENTS_HISTORY.md`.
- Settings screen verified functional and expanded: currency (YER/SAR/USD),
  distance unit (km/miles), text size (small/medium/large) and default map view
  (list/map) added with SharedPreferences persistence via settingsProvider.
  Text size drives a root `MediaQuery` textScaler; default map view drives /map
  initial list/map mode; property-card price labels use the chosen currency code
  (display only — no FX conversion). Search radius stays stored in km and is
  converted for display when miles is selected. Asset-count visibility is also
  consumed on the map. `addPropertyStyle` and `notificationsEnabled` persist but
  still have no consumer outside Settings, so those two toggles do not change
  app behavior yet. Fixed a duplicate `set_add_property_style` ARB key introduced
  with the new labels. `flutter analyze` clean, `flutter test` 71/71 passed.
- Fixed stale dark/light elements after a theme switch: `AppColors.isDark` is a
  mutable static mirror, so widgets reading its semantic getters did not always
  rebuild when `ThemeMode` changed. Added `AppThemeScope` around every router
  page; it keys the route subtree by effective brightness, forcing all
  directly-styled widgets to re-evaluate colors without resetting navigation.
  Verified on USB: Dark→Light and Light→Dark both repaint dashboard scaffold,
  surfaces, header and bottom nav immediately; no runtime errors. Added a
  widget regression test in `test/settings_test.dart`.
- Current focus: remaining performance/UX work (bundled Cairo font deferred until
  its `wght` axis can be set safely; admin query paging as a coordinated unit).
  Full roadmap in `TODO.md`.
- `getDashboardStats()` now uses PostgREST `sum()`/`count()` aggregates for commission
  totals with a client-side fallback; no longer downloads every commission row.
- The 440 demo listings are generated once per process via
  `DemoPropertiesGenerator.cachedDemoProperties` and reused by the demo store, Home
  and the map fallback. Removed Home's no-op post-frame rebuild; `AppTheme` caches
  both themes. Added `test/demo_properties_cache_test.dart` (59 tests total).
- Applied a `const` pass (40 mechanical fixes) across admin tabs, contract/map/sheet
  widgets, `PropertyCard` and tests; `analysis_options.yaml` is unchanged.
- Fixed add/edit screen `RenderFlex` overflows (4 unconstrained Rows, incl. logged
  line 995) and the contract editor date/ID row overflow (logged at
  `contract_preview_screen.dart:772`), and removed unbounded ellipsis from My
  Properties header/subtitle, dashboard category subtitles, admin headers/tab titles,
  drawer map subtitle and rental-request date rows so descriptive text wraps instead
  of being clipped. Contract editor `SwitchListTile`s now have their own transparent
  `Material` ancestor to remove ListTile ink/background debug errors.
- Contract preview + editor sheet now use `AppColors` tokens (no hardcoded
  white/black/grey); dark-ink `primaryDark`/`accentDark` foregrounds replaced with
  `primaryInk`/new `accentInk`; direction-hardcoded paddings/borders are
  `EdgeInsetsDirectional`/`BorderDirectional`. Added `AppColors.shadow` and
  `accentInk`; themed modal barrier scrim on all bottom sheets + `AuthPromptDialog`.
- Migrated remaining dark-theme breakers: admin pending card, `StatusBadge` pending,
  property detail, login/auth-callback/register notices, admin users tab, admin PDF dialog,
  bottom nav, back-exit snackbar, filter-sheet shadow and rental-request spinner.
- Last two raw `Image.network` calls replaced with `CachedNetworkImage` +
  `memCacheWidth`. Property-card/image overlay positions now use
  `PositionedDirectional(start/end)` (RTL layout unchanged, LTR mirrors correctly).
  Four unbounded admin Supabase queries deliberately left alone — a hard cap
  would silently truncate admin exports; needs coordinated paging work.
- All five admin tabs now use `AdminPagedList<T>` (12 rows + "Load more");
  moderation queue shows 6 heavy cards initially. Added `test/admin_paged_list_test.dart`.
- i18n quick wins done: localized AppHeader titles (admin/favorites/requests/detail/add-edit),
  `Back` tooltip, publisher CTA, hero-map strings (new `dash_map_cta_title`/`subtitle`
  keys in both ARBs), branding and copyright. Regenerate with `flutter gen-l10n`
  after ARB edits (`flutter pub get` alone does NOT regenerate here).
- Remaining i18n work: LTR mirroring of fixed `Positioned left/right` in
  `PropertyCard`/`PropertyImage`, forced-RTL PDFs, governorate name data model,
  contract default clauses. See `TODO.md`.
- Previous: unified property cards + redesigned property/admin/settings/drawer/map UI.
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
- Last verified (2026-11-24): `flutter analyze` clean, 58/58 tests, fresh USB
  `flutter run -d ZY22G4C24N` plus DTD hot restart. Current run log has no
  `RenderFlex overflow`, Flutter error banner or runtime errors. /map opened on device
  with Esri street tiles rendering (133 distinct quantized colour buckets, OCR found no
  'API KEY REQUIRED'); no tile-failure logs. Earlier 2026-11-23 USB pass covered My
  Properties, Favorites, Admin dashboard, Map + list view with no overflow/widget errors.
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