# AGENTS_HISTORY.md — Full change log (Yemen Real Estate Portal)

This file contains the complete historical "Status — done / remaining" log moved out of
`AGENTS.md` to reduce per-task context consumption. Read it only when you need prior
decisions, migration history, or why a convention exists.

---

## Status — done / remaining (full history)

DONE (admin list paging, 2026-11-25, `flutter analyze` clean, 100/100 tests):
- Replaced the four unbounded admin selects (profiles, commissions, reports,
  rental requests) with bounded repository pages: `get*Page({limit, offset})`
  applies the original ordering plus a secondary `id` tie-breaker and
  `.range(offset, offset + limit - 1)`, and a separate `count*()` supplies the
  total. Demo data is sorted/sliced the same way via `admin_paging.dart`.
- Added `streamAll*ForExport({pageSize: 200})` for every table. The existing
  `getAll*()` methods now collect those chunks, so CSV/PDF can still include
  every row without issuing one unbounded query.
- Added `AdminListPage<T>` and `AdminListPaginator<T>`. New paginator providers
  in `admin_provider.dart` and `rental_request_provider.dart` feed the four
  admin tabs; mutations reload the first page instead of refreshing a full
  list. `AdminPagedList` gained optional external paging
  (`hasMore/isLoadingMore/onLoadMore`) while preserving the legacy prefix mode
  used by properties/favorites.
- CSV buttons and PDF sections now await the separate full-list providers
  instead of reading only the loaded UI page, removing the old export
  truncation risk. PDF localization strings are snapshotted once before the
  async provider reads to keep the analyzer clean.
- Added `test/admin_paging_repository_test.dart`,
  `test/admin_list_paginator_test.dart`, and external-paging cases in
  `test/admin_paged_list_test.dart`. `flutter analyze`: no issues;
  `flutter test`: 100/100 passed. Fresh USB cold launch + DTD hot restart:
  opened all four admin tabs; requests/commissions CSV dialogs and PDF sections
  1–4 (properties, requests, commissions, reports, users) all exported with
  success dialogs. No Flutter runtime errors in logcat and no new `data_app_anr`
  (latest remains 2026-11-25 00:41:13). Demo tables fit one 12-row page, so the
  device "Load more" path is covered by the external-paging widget tests.

DONE (map cluster ticker fix, 2026-11-25, `flutter analyze` clean, 92/92 tests):
- Extended USB interaction found
  `_PropertyMapViewState is a SingleTickerProviderStateMixin but multiple
  tickers were created` when a cluster marker was tapped repeatedly. The old
  `_animatedMove` created and disposed a fresh `AnimationController` per tap.
- `PropertyMapView` now owns one `AnimationController`, registered once in
  `initState` and disposed in `dispose`. `_animatedMove` captures the camera's
  current center/zoom and resets/restarts that controller; a single listener
  interpolates the camera with `Curves.easeInOutCubic` and calls
  `MapController.move`.
- Added `test/property_map_cluster_ticker_test.dart`, which invokes a cluster
  badge's `onTap` twice without settling the first animation and asserts no
  exception was recorded.
- Verified with a fresh USB cold launch, DTD hot reload, two rapid taps on the
  large initial cluster plus four rapid taps on later clusters, then menu/back:
  no runtime errors, no Flutter exception lines in logcat, and no new
  `data_app_anr` entry (latest remains 2026-11-25 00:41:13).

DONE (local Cairo font, 2026-11-25, `flutter analyze` clean, 91/91 tests):
- Declared `assets/fonts/Cairo.ttf` as the `CairoLocal` font family in
  `pubspec.yaml`. The bundled file is variable; its `fvar` table exposes
  `wght` 200–1000, so requested weights can be rendered without downloading
  static instances.
- Added `core/theme/app_fonts.dart` with a `GoogleFonts.cairo`-compatible
  `AppFonts.cairo()` helper that sets `FontVariation('wght', …)` from the
  effective `TextStyle.fontWeight` (clamped to 200–1000) and an
  `AppFonts.cairoTextTheme()` replacement.
- Migrated every `GoogleFonts.cairo`, `GoogleFonts.outfit` and
  `GoogleFonts.amiri` call in `lib/` to `AppFonts.cairo`. The two minor display
  fonts now intentionally render with the bundled Cairo family.
- Set `GoogleFonts.config.allowRuntimeFetching = false` in `main.dart` so any
  future direct GoogleFonts use fails fast instead of making an HTTP request.
- Added `test/app_fonts_test.dart` for family selection, weight-axis mapping,
  clamping and `textStyle` merging. Also updated
  `test/property_text_styles_test.dart` to restore `AppFonts.cairo` as the
  default factory.
- Verified with a fresh USB cold launch (required for the newly declared font
  asset) plus menu tap + back: no runtime errors and no Flutter exception /
  `google_fonts` lines in logcat.

DONE (contract locale defaults, 2026-11-25, `flutter analyze` clean, 87/87 tests):
- Added `models/contract_default_text.dart` with Arabic and English legal
  template text (lease/sale titles, owner address, payment/duration wording,
  indefinite sale end date, utilities/maintenance/late-payment text and
  clause lists).
- `PropertyContract.defaultTemplate()` now chooses
  `ContractDefaultText.forCurrentLocale()` from the `AppLocale` mirror unless a
  caller passes an explicit variant. The generated strings are written into
  the existing `PropertyContract` fields, so saved contracts keep the language
  they were created in and no schema/JSON migration was needed.
- `ContractService.getOwnerDefaultTemplate()` still reuses a saved owner
  template unchanged; only new contracts without a saved template follow the
  active locale.
- Added `test/contract_locale_defaults_test.dart` covering Arabic parity,
  English lease/sale defaults and JSON persistence.
- Verified with a fresh USB launch, DTD hot restart and menu tap + back: no
  runtime errors and no Flutter exception/ANR lines in logcat.

DONE (i18n PDF direction + place names, 2026-11-25, `flutter analyze` clean, 83/83 tests):
- `contract_preview_screen.dart` and `admin_pdf_service.dart` now snapshot
  `Directionality.of(context) == TextDirection.rtl` before the async font load.
  Contract `pw.Directionality`, admin `pw.MultiPage`, the terms heading and the
  admin table `cellAlignment` follow that value, so English mode no longer
  renders RTL/right-aligned PDF content.
- `AppLabelsEn.governorate` holds display names for all canonical Arabic
  governorate keys plus Sana'a aliases; `AppLabelsEn.district` holds English
  names for all 182 demo districts and the extra location aliases. Unknown
  values deliberately fall back to their stored Arabic text.
- `AppConstants.getGovernorateNameAr` / `getDistrictNameAr` are the one
  locale-aware display gate. Storage, filters, `governorateMatches`, GeoJSON
  canonicalization and `PropertyFilterSelection` values remain Arabic.
- Display call sites migrated: shared filter sheet labels/hints, `PropertyCard`,
  property detail, add/edit dropdown and district chips, map filter chips and
  approximate-location caption, contract preview/PDF text. On `/map`, applying
  a governorate filter writes the localized label into the search box; the
  free-text pass skips that exact label so English mode still returns the
  Arabic-keyed listings.
- `supabase_service.dart` demo `LocationItem.nameEn` now uses
  `AppLabelsEn.governorate[entry.value.name]` instead of `entry.value.slug`,
  so English UI no longer shows `sanaa_capital` / `sanaa_gov`.
- Added `test/display_name_localization_test.dart` (locale getters, alias
  handling, no-slug regression, one English label per demo district) and an
  English `/map` regression in `test/yemen_map_screen_test.dart` that proves
  "Sana'a Governorate" + "Bayt Bous" still returns the two Arabic-keyed demo
  listings.
- Verified on USB with a fresh install, DTD hot restart and menu tap + back:
  no Dart runtime errors, no Flutter exceptions/ANR lines in logcat, and no new
  `data_app_anr` entry (latest remains 2026-11-25 00:41:13).

DONE (Dashboard FAB alignment, 2026-11-25):
- `HomeScreen`'s stacked FABs now set `crossAxisAlignment: CrossAxisAlignment.end`,
  so the compact `AddPropertyFab` aligns with the trailing edge of the wider
  extended map FAB. Previously `Column` defaulted to `center`, which made the
  small FAB float above the middle of the extended FAB even though `Scaffold`
  places the stack at `endFloat`.

DONE (ANR/input-dispatch mitigation, 2026-11-25, `flutter analyze` clean, 78/78 tests):
- Diagnosed the reported `"isn't responding"` dialog as input-dispatch timeout /
  main-thread jank, not a Dart exception: DropBox showed
  `Input dispatching timed out`, `Choreographer: Skipped 156 frames!`,
  `OpenGLRenderer Davey! duration=2622ms`; DTD reported no runtime errors.
- Moved the dashboard's 440-property nearby scan into pure
  `computeNearbyProperties` plus cached `nearbyPropertiesProvider`, so
  `HomeScreen.build` no longer scores/sorts the whole catalogue on rebuild.
  Added `test/home_nearby_properties_test.dart`.
- Cached every distinct Cairo `TextStyle` in `PropertyTextStyles` keyed by
  size, exact `FontWeight`, colour and height (no `copyWith` weight reuse).
  Added an injectable font factory so tests verify identity/line heights
  without a runtime font download (`test/property_text_styles_test.dart`).
- Capped `PropertyImage.memCacheWidth` for grid/management cards to 800 px.
- Reworked the first-run location flow: persist `locationPromptShown` only
  after the OS permission result, and set `homeCenterProvider` instead of
  calling `setState`.
- USB cold launch surfaced two regressions in that async flow and both were
  fixed: (1) `ref.read` in a post-frame callback after disposal now avoided by
  capturing settings/center notifiers with `ref.read` in `initState`;
  (2) illegal `ProviderScope.containerOf(context)` in `initState` replaced by
  those captured notifiers. `SettingsState` is also captured in `initState`
  instead of reading a protected notifier `state` after the async gap.
- Verified after the fix with DTD hot restart (`No runtime errors found.`) and
  adb menu tap + back (no Flutter exceptions in logcat). A fresh USB cold
  launch installed cleanly with no Flutter exception and no new `data_app_anr`
  entry (latest remains 2026-11-25 00:41:13); debug cold start still logs
  `Choreographer: Skipped frames` / `Davey` warnings on this device.

DONE (Android build fix, v2.3.0+17 era → verified running on device):
- Gradle 9.3.1, AGP 9.1.0, KGP 2.4.0, Java 17, pubspec floor ^3.11.0-0.
- Root docs/ consolidation (prototype files moved to docs/).

DONE (UI/UX consolidation, 2026-11-18, `flutter analyze` clean):
- Header minimal; auth only in drawer/rail; rail on desktop; bottom nav 4 items; drawer map tile
  deduped; search FAB list↔map toggle; home hero banner removed; publisher CTA consolidated;
  property-detail teal map button removed; map screen avatar removed (menu mobile-only);
  footer links wired to real routes; back-button logic deduplicated (single PopScope handler;
  AppRootBackButtonDispatcher removed); fake language toggle + locale_provider removed;
  all screens hide bottom nav/drawer on desktop and use AppPageBody rail wrapper.

DONE (Map unification + web tiles attribution, 2026-11-19, `flutter analyze` clean):
- Shared map class `lib/features/map/presentation/property_map_view.dart` (PropertyMapView):
  OSM tiles / Esri satellite option, official Yemen ADM1 GeoJSON boundaries (static-memoized
  load), spatial clustering with price-pin markers & brand cluster badges (moved from map screen),
  freehand-drawn polygon layer, OSM/Esri `RichAttributionWidget` tile credit. Host concerns
  (filters, satellite toggle, drawing gestures, selected card) stay in the host via callbacks.
- `/map` (yemen_map_screen.dart) now delegates rendering to PropertyMapView; dead code removed
  (_buildPropertyPriceMarker, _buildYemenPortalClusterBadge, _GooglePinPainter,
  _showClusterPropertiesBottomSheet, inline GeoJSON/clustering). Cluster sheet restyled to M3
  (28 dp top radius, tonal icon tile, image thumbnails) and moved into PropertyMapView; tap selects
  property via onPropertyTap.
- Search results in-screen map view now reuses PropertyMapView (same class/visuals as /map)
  instead of the old flat chip markers; FAB still toggles list↔map (no navigation to /map).
- Footer links: underline decoration removed (M3 ink feedback instead).
- Map UI/UX grounded in M3 search: expanded rail (already done 2026-11-18) + cards/attribution
  polish. Empty states remain consistent (tonal circle icon).

DONE (App feel overhaul → "looks like a native app, not a website", 2026-11-19):
- Theme (`app_theme.dart`) rewritten to Material 3 Expressive: Cairo bold-forward type scale,
  Elevated/Filled/Outlined/Text buttons stadium (≥44/50 dp), filled tonal inputs (14 dp radius,
  2 dp focus ring, no underline), M3 Chip/Card/Dialog/BottomSheet/SnackBar themes, cards lose
  their 1 px `BorderSide` hairlines.
- Palette: stray Bootstrap-blue `#0D6EFD` swept to `AppColors.primary` repo-wide (map 34, map view 5,
  home 1, my_properties 1). Teal `#0F766E` kept for the search-toggle FAB/pins by design.
- Tab routes (`/`, `/map`, `/my-properties`) get a 150 ms fade-through custom page
  (`_tabPage` in app_router.dart); other routes keep platform transitions.
- Bottom nav rebuilt M3 Expressive: 72 dp tonal surface, 62×32 animated pill indicator + filled
  icon when selected, centered labels; dropped the web-ish special raised center button.
- App bar: hairline bottom border removed; CTA "أضف عقارك" is now a stadium amber button.
- Drawer redesigned: gradient rounded header, avatar with user initial, per-tile tonal icon tints,
  prominent teal map CTA card, stadium auth buttons (rounded icon fix too).
- Map header (`_buildMapHeader`): "خريطة اليمن / العقارات المتاحة..." title-badge strip REMOVED;
  opaque white bar + 1 px border → floating glass card (26 dp radius, blur, deep shadow on the map);
  back/menu are tonal circle buttons; search is a pill TextField (46 dp); deal/type/governorate/
  filter-bar chips all borderless tonal stadiums (selected = `primaryMuted` fill + primary text).
  Floating overlays re-anchored to `padding.top + 128`.
- Search map toggle: fixed 520 px box inside the scroll view → full-bleed `Expanded` region that
  fills the screen exactly like the /map tab (list mode layout unchanged).
- Property cards: hairline border dropped, radius 18, specs are tonal chips with primary icons.
- Tests updated to the new design (header has only the single "أضف عقارك" action; map header has no
  title badge; governorate chips assert only lazily-built visible items). `flutter test` 56/56 pass.
  `flutter analyze`: No issues found. Home ran on ZY22G4C24N (launch OK; screencaps show the new
  header/nav/search/map; user visual verdict pending — Review-pane screenshots shown).

BLOCKED / UNVERIFIED:
- Full desktop rail layout not yet visually verified (Windows desktop target exists; not launched).
- Phone run after the 2026-11-19 UI overhaul: app launched + screens captured; user verification
  of the new look pending (fonts/Cairo + map tiles need the phone's internet).
- Visual nits likely remain (e.g. exact glass-card blur/shadow tuning); iterate on user feedback.

DONE (APK, 2026-11-19):
- Release APK built: build/app/outputs/flutter-apk/app-release.apk (66.6 MB, signs with debug key).
- Warnings only: builtInKotlin plugins (package_info_plus, shared_preferences_android) — future
  Flutter will require migration; NDK mismatch notice (project keeps 26.3.11579264 intentionally,
  do NOT bump without asking). Build OK.

DONE (Location-first dashboard + Settings + i18n framework, 2026-11-21, `flutter analyze` clean, 56/56 tests):
- 2-tab navigation only: الرئيسية (dashboard, `/`) + ممتلكاتي. Property search now lives ONLY in the
  map screen (`/map`); the old `/search` route + SearchScreen were removed (dashboard/search → `/map`).
- AppHeader: menu removed; brand + settings gear + single outlined Add Property action.
- First-run location consent (`DeviceLocationService`, geolocator) caches lat/lng via `settingsProvider`
  (SharedPreferences); denial falls back to Ibb centroid (`DeviceLocationService.ibbCenter`,
  LatLng(13.9667, 44.1833)). Dashboard shows a "nearby properties"
  section (DemoPropertiesGenerator filtered by `searchRadiusKm`, nearest-first).
- Dashboard FAB (`dashboard_map_fab`) → `/map` with `extra: true` → YemenMapScreen opens in LIST mode
  (`initialListView` param); map FAB still toggles list↔map in-place.
- Map: separate draw-area FAB above the main toggle, satellite toggle retained, asset-count badge now
  shown in list mode too (`asset_count_visibility` pref; default `always`).
- `/settings` route + screen: language (ar/en), display (theme system/light/dark, Add Property style
  outlined vs small FAB, asset-count visibility), current location + reset, search radius slider,
  notifications toggle, about (version, privacy/terms dialogs, contact). Gear entry points: appbar,
  search top bar, drawer (authenticated users, below logout), rail.
- i18n framework wired: `l10n.yaml`, `lib/l10n/app_{ar,en}.arb`, generated `lib/l10n/app_localizations*.dart`,
  `AppLocalizations.{localizationsDelegates,supportedLocales,locale}` in `main.dart`, `flutter: generate: true`.
  ThemeMode + Locale driven by `settingsProvider` (persisted).
- Global keyboard dismissal: translucent tap detector + scroll listener in `MaterialApp.builder`.
- Test updated: bottom nav asserts exactly 2 tabs and no map/search tab.

DONE (Full string-level i18n migration, 2026-11-21, `flutter analyze` clean, 56/56 tests):
- Migrated all user-visible UI copy in ~30 screens to generated getters via `context.l10n`
  (`lib/core/l10n/context_l10n.dart`): shell/nav/drawer/rail/footer, dashboard, map/list, search,
  settings, profile, favorites, requests, auth, admin, property forms/detail and contract preview.
  ~834 UI keys added to `lib/l10n/app_{ar,en}.arb` (five parallel batches, merged centrally).
- Context-free localizations: `lib/core/l10n/app_locale.dart` (locale mirror set from `main.dart`),
  `lib/core/l10n/app_strings.dart` (`tr` getter via `lookupAppLocalizations`), and `app_labels_en.dart`
  for `AppConstants` enum labels. Used by validators, `AppException`, repositories, storage service,
  admin CSV headers, WhatsApp message template, area unit and generated-contract document text.
- `AuthCallbackScreen` defers `_processCallback` to a post-frame callback because `context.l10n`
  cannot be resolved in `initState` (fixed a widget-test crash).
- Fixed `use_build_context_synchronously` infos introduced by the migration (`context.mounted` guards
  plus pre-await `l10n` captures in admin PDF export, register resend and contract PDF save).
- Tests now provide `AppLocalizations.localizationsDelegates/supportedLocales/locale: ar_YE` on every
  `MaterialApp` they pump. `flutter gen-l10n` regenerated; analyze + 56/56 tests pass.
- `Formatters` number/date formatters are now locale-aware (cached per locale via `AppLocale`), so
  digits and dates follow the language switch too.
- Launched on USB (`ZY22G4C24N`): app starts cleanly, Supabase demo init OK, no runtime exceptions.
  Visual walkthrough of the language switch on-device still pending user confirmation.

DONE (Plan audit fixes + Ibb fallback, 2026-11-21, `flutter analyze` clean, 56/56 tests):
- Location fallback changed Sanaa → Ibb: `DeviceLocationService.ibbCenter` = LatLng(13.9667, 44.1833),
  dashboard nearby center + fallback detection, ARB labels (`dash_nearby_fallback_count`,
  `set_default_ibb`). Old `sanaaCenter` alias kept for compatibility.
- Settings screen restructured to the confirmed plan: اللغة · العرض (Theme + Add Property style +
  asset-count visibility in one card with sub-headers) · الموقع (current location, reset, radius) ·
  الإشعارات · حول البرنامج (version, privacy/terms dialogs, contact). New ARB keys: `set_display`,
  `set_add_property_style`, `set_asset_count_visibility`, `about_privacy_body`, `about_terms_body`,
  `close`; renamed `set_default_sanaa` → `set_default_ibb`.
- Drawer: Settings tile removed from the general nav list; it now appears below the account action
  (below logout for authenticated users, below the login CTA for guests — the header gear is gone).
- Map filter bar: removed the duplicate draw-area chip; Draw Area is now only the separate icon FAB
  above the list/map toggle. The active-polygon pill still clears the drawn filter.

DONE (Header/search clean-up, dark-theme readability, pagination, 2026-11-21, `flutter analyze` clean, 56/56 tests):
- `AppHeader` is now only a drawer menu (mobile/tablet) + centered app name; brand logo,
  Add Property CTA and settings gear removed. All 14 AppHeader screens now provide an
  `AppDrawer` so the menu works everywhere; desktop hides the drawer (rail instead).
- Search top-bar gear removed. Settings is reachable from the drawer (below logout for
  authenticated users, below login CTA for guests) and the desktop rail.
- Dark theme rebuilt from one palette-driven recipe (`AppTheme._build`): full M3 component
  themes in both brightnesses. `AppColors` exposes brightness-aware semantic getters
  (`textPrimary/Secondary/Muted`, `surface*`, `divider`, `primaryMuted`, `primaryInk`)
  mirrored from `main.dart` and `AppPageBody`; 100+ hardcoded foreground teal usages now
  use `primaryInk` (bright teal in dark) so icons/text stay legible. `textLight` stays
  white for image/footer overlays.
- Map/list pagination: 12 rows initially, extends by 12 on scroll (300 px from end) or
  via an explicit "عرض المزيد" button; pagination resets when filters change. Map
  "Search this area" debounce tightened 350 → 300 ms; clustering unchanged.
- Keyboard dismissal now also lives in `AppPageBody` (tap/scroll), with the global
  `MaterialApp.builder` detector retained for dialogs/auth screens and other non-body UI.
- New ARB key `map_load_more` (ar/en); localizations regenerated. Test updated to assert
  the quiet header (menu + app name, no CTA/gear).

DONE (Map screen cleanup + /search removal + test fixes, 2026-11-21, `flutter analyze` clean, 56/56 tests):
- YemenMapScreen: removed now-unused helpers (`_buildPropertyTypeDropdown`, `_buildGovernorateChip`,
  `_showOfflineMapDialog`, `_buildDealTypeDropdown`); filter button (`Icons.tune` + `map_filters` label)
  + `_activeFilterChips()` chips live in the floating glass header; count badge now takes the filtered
  list (`_buildCountBadge(List<Property> properties)`).
- User scope fulfilled: dashboard search flow (`_onSearchSubmit`, view-all/empty-state pushes) now goes
  to `/map`; old `/search` route + `lib/features/search/` (SearchScreen) DELETED; drawer/rail/footer/
  empty-states/property-detail entry points repointed `/search` → `/map`.
- Map header glass container color fixed (was hardcoded `Colors.white` → now `AppColors.surface`, was
  unreadable in dark theme).
- Tests updated to the new map header design (search pill, `الفلاتر` filter button, `عرض القائمة`
  map/list toggle). `flutter analyze`: No issues found. `flutter test`: 56/56 pass.

REMAINING / NOTES:
- Deliberately NOT translated (data, not UI chrome): governorate/district names, demo listing titles/
  descriptions/notes/names, default owner/tenant names, and the Arabic legal clause defaults in
  `models/property_contract.dart` (const constructor defaults must stay compile-time constants).
- Dummy data: `DemoPropertiesGenerator` (440 listings) feeds the dashboard nearby section and the
  `/map`/list view (map screen falls back to it whenever Supabase returns no properties). Gate it
  behind a release flag before production. Detect demo mode with `EnvConfig.isDemoMode` (true when
  credentials are missing/placeholder or `EnvConfig.setForceDemoModeForTesting(true)` is set in tests);
  `SupabaseService.initialize()` logs "Running in Demo Mode..." when this is active.
- PROJECT_SUMMARY.md is stale (references v2.3.0+17 APK at repo root that no longer exists; see note there).
- Contact info in footer (+967 770 000 000, support@yemenrealestate.local) is placeholder/demo — replace with real contact when known.
- docs/ audit (2026-11-18, user-approved deletions done): removed Yemen_Real_Estate_Prototype_Page_4.pdf
  (byte-identical to Figure_2_1), v1_1_*.png, updated_*.png, verification_summary.json.
  Kept (not approved): live_phone_*.png, screen.png, prototype_figure_render.html, prototype_figure_2_2.html.
- `AppPageBody` wraps body only; scaffold-level `appBar` stays AppHeader everywhere (by design).
- Analytics: none. Deep links: supabase callbacks on /login-callback, /auth-callback.
- Known accepted trade-off: `flutter_run6.log` etc. in temp — not committed.
- The 2026-11-19 04:12 release APK predates the UI overhaul; it is stale. Rebuild only if the user asks.

DONE (Theme + readability + dashboard/map layout fixes, 2026-11-21, `flutter analyze` clean, 56/56 tests):
- Theme consistency: `main.dart` now adds `WidgetsBindingObserver` with `didChangePlatformBrightness()` so `AppColors.isDark` stays in sync when the OS brightness changes while `themeMode == ThemeMode.system` (previously MaterialApp switched themes but `AppColors.isDark` stayed stale, leaving screens stuck in dark/white). Removed the build side-effect `AppColors.isDark = ...` from `AppPageBody.build()` which caused per-screen inconsistency.
- Icon/input readability (dark mode): bottom nav active icon → `primaryInk` (bright teal in dark), inactive color + pill fill brightness-aware; map filter button (`_buildFilterBarBtn`) active fill lighter in dark + `primaryInk` icon/text; "Search this area" button `Colors.white` → `AppColors.surface`; active polygon badge `Colors.white` → `surface`, border `primary` → `primaryInk`; selected property card `Colors.white` → `surface`; bedrooms pill `white.withAlpha(240)` → `surfaceVariant`, `black87` → `textPrimary`; price/title text `black87` → `textPrimary`; more_horiz icon `black54` → `textMuted` (removed `const`); unit badge `grey.shade100/300` → `surfaceVariant`/`divider`, `black87` → `textPrimary`; draw button active background `primary` → `primaryInk`.
- Dashboard: added "Add your property" `ElevatedButton` below the search widget in the hero section; made "Properties near you" card width responsive (`screenWidth - 68` on mobile so cards use parent width, 240 on desktop).
- Map/list FABs: changed `Positioned(left/right: 16)` → `PositionedDirectional(end: 16)` so controls sit on the trailing edge (right in LTR, left in RTL), matching the dashboard FAB `CrossAxisAlignment.end`; restacked vertically bottom→top: list-toggle FAB → count badge → satellite → draw.
- Draw button active background in dark mode: `AppColors.primary` → `primaryInk` (was invisible on dark surface).

DONE (Navigation flow + FAB directionality + dark-mode badge fixes, 2026-11-23, `flutter analyze` clean, 56/56 tests):
- Dashboard FAB now matches map/list screen design: teal `#0F766E` background, white foreground, elevation 6, `map_rounded` icon (size 18), positioned via `PositionedDirectional(end: 16, bottom: 10)` for RTL-aware trailing-edge alignment. Opens map mode (`extra: false`).
- Footer hidden on mobile/tablet (`!Responsive.isDesktop(context)` returns `SizedBox.shrink()`).
- "Search this area" button repositioned to `top: MediaQuery.of(context).padding.top + 210` to avoid overlap with floating glass header.
- `StatusBadge.dealType` now uses `AppColors.primaryInk` for text color in dark mode (previously `AppColors.primary` which was identical to `AppColors.primaryMuted` `#134E4A` → invisible).
- Map screen hardcoded colors reduced: SnackBar warning/error colors, FAB colors, and key interactive elements now use theme-aware `AppColors` tokens.
- Home screen `AppColors.textSecondary` and `AppColors.border` changed from `const` to non-const to avoid `invalid_constant` analyze errors.
- Dashboard and map/list screens maintain consistent FAB design and directionality (trailing edge positioning) per Material 3 Expressive guidelines.

DONE (AppHeader screen-specific titles + overflow fixes, 2026-11-23, `flutter analyze` clean, 56/56 tests):
- `AppHeader` now supports optional `title` and `showBack` parameters for screen-specific titles and back button.
- Screens updated with screen-specific titles + back button: Property Detail, Add/Edit Property, Favorites, Admin Dashboard, My Rental Requests.
- My Properties tab keeps app name (dashboard title) per user request (it's a tab).
- `sh_back` tooltip removed (was undefined in ARB); uses MaterialLocalizations tooltip instead.
- My Properties tab overflow fixed: Row with views count + preview button now uses `Expanded` + `TextOverflow.ellipsis`; badge Row wrapped in `Flexible`.
- All hardcoded `Colors.white`/`Colors.grey`/`Colors.black` in map screen replaced with theme-aware `AppColors` tokens where possible.

DONE (Home screen UI split + dashboard filter notifier, 2026-11-23, `flutter analyze` clean, 56/56 tests):
- `home_screen.dart` (was 1,293 lines) split into sibling widgets under `lib/features/home/presentation/`:
  `home_hero_section.dart` (HomeHeroSection), `home_nearby_section.dart` (HomeNearbySection),
  `home_governorate_picker.dart` (HomeGovernoratePickerSheet), `home_property_sections.dart`
  (HomeSectionHeader + HomePropertyGrid), `home_publisher_cta.dart` (HomePublisherCta).
  Screen now holds only state/callbacks + Scaffold shell; all strings/routes/FAB key preserved.
- Phase 2: new `lib/providers/dashboard_filter_provider.dart` (DashboardFilterState/Notifier)
  owns hero search text controller + pending deal/type/governorate selections; `_HomeScreenState`
  now only keeps location-first state (`_userCenter`, `_locationResolved`).
- Fixed refactor fallout: missing `location_provider` (propertyTypesProvider), `go_router` and
  `flutter_riverpod` imports; unclosed Row + stale `_locationResolved` in nearby section; unused imports.
- Runtime fix found via USB run: `HomeNearbySection` clamps `screenWidth - 68` to >= 0 (first frame
  MediaQuery width can be 0 → negative SizedBox width assertion). Hot reload verified: no runtime errors.

DONE (Dashboard → map routing + map-scoped results + accurate nearby, 2026-11-23, `flutter analyze` clean, 56/56 tests):
- Verified in code: the list screen's "عرض المزيد من العقارات" only paginates inside `/map`; the four
  dashboard pushes (hero search + featured/sale/rent "عرض الكل") were the stale `/search` ones.
- New `MapScreenArgs` (in `yemen_map_screen.dart`) carries `initialListView` + seed filters from the
  dashboard; `/map` router handles both `bool` (old FAB/nearby behaviour) and `MapScreenArgs`.
  `YemenMapScreen` seeds its local filter state and map centre from those args; all four dashboard
  pushes now go to `/map` in list mode (no 404 route).
- Map count badge, list rows and draw-filter count now use only properties inside the current map
  viewport: `LatLngBounds` from `onPositionChanged` / `MapEventMoveEnd`, with a `MapCamera` fallback
  computed from centre+zoom+screen size while the list is open. Pagination resets when the view moves.
- "Properties near you" now filters `DemoPropertiesGenerator` by distance from `_userCenter` (Ibb
  fallback) using `settingsProvider.searchRadiusKm`, sorts nearest-first and takes 4 — previously it
  just took the generator's first 4 rows (other governorates).
- USB verified on `ZY22G4C24N`: nearby cards are all "إب - …"; map badge reads 20 عقار متاح (Ibb's
  demo listings, not 440); list mode shows only إب listings; "عرض الكل" opens the map/list screen
  (no 404); DTD reports no runtime errors after hot reload.
- Nearby count fix: `_nearbyProperties()` now returns ALL listings within `searchRadiusKm` (sorted
  nearest-first) instead of only 4; `HomeNearbySection` still renders at most 4 cards via `take(4)`.
  The section subtitle therefore shows the real total (20) matching the map/list badge, while
  "عرض الكل" opens the full list. `flutter analyze` clean, 56/56 tests pass.

DONE (Unified property cards + admin/settings/drawer/map redesign, 2026-11-23, `flutter analyze` clean, 56/56 tests, USB hot restart clean):
- Added `lib/core/theme/property_text_styles.dart` for shared property-card typography and
  `lib/shared/widgets/property/` for favorite button, image/placeholder, carousel and spec chips.
- Rewrote `lib/shared/widgets/property_card.dart` as the canonical card with
  `PropertyCardLayout.grid/row/overlay/management`. Shared radius, typography, favorite control,
  image handling and spec chips are centralized. Overlay/maps keep optional carousel, close,
  call, WhatsApp, directions and detail action slots; management cards add status/owner info.
- Migrated `lib/features/map/presentation/property_map_view.dart` cluster rows and
  `lib/features/map/presentation/yemen_map_screen.dart` list rows + floating selected card to the
  shared card. Removed private tile/thumbnail/chip helpers and hardcoded Unsplash fallbacks from
  the map selected card.
- Reworked map shell geometry: `_headerBottom`, `_selectedCardReserve`, one RTL-aware control
  stack and `_buildSmallMapFab`; floating header now has `AppColors.divider` border and translucent
  `AppColors.surface`; filter-chip row indentation normalized.
- Rebuilt `lib/features/profile/presentation/my_properties_screen.dart` with a page header, stats
  tiles, deal filter chips, shared management cards, popup actions, FAB and empty states.
- Rail: merged duplicate Search + Map destinations into one `البحث والخريطة` item → `/map`;
  `MapScreenArgs` pushes and the in-screen list/map toggle remain intact. Added
  `sh_nav_search_map` to `app_ar.arb`/`app_en.arb` and regenerated localizations.
  `AppBottomNavBar` remains exactly 2 destinations (Home + My properties) by requirement.
- Drawer: added selected-route styling, check icons and tokenized map-card colors; removed the
  unused `currentRoute` local that `flutter analyze` flagged.
- Settings: tokenized card theme and section headers; the live `ar_YE/en_US` language radio
  remains unchanged.
- Admin split (same `/admin` route, same `AdminDashboardScreen({super.key})` API):
  - `presentation/widgets/admin_stats.dart` (grid + stat card),
    `admin_pending_properties.dart`, `admin_pending_property_card.dart`,
    `admin_dialogs.dart` (CSV preview/copy + manual commission dialog).
  - `presentation/tabs/` holds `AdminPropertiesTab`, `AdminRequestsTab`,
    `AdminCommissionsTab`, `AdminReportsTab`, `AdminUsersTab`.
  - `services/admin_pdf_service.dart` owns section export. PDF mapping stayed 0=properties,
    1=requests, 2=commissions, 3=reports, 4=users; `context.mounted` guards and all provider
    refreshes preserved. Users tab keeps the super-admin role/email/id whitelist.
  - Shell keeps only auth guard, title, stats, moderation queue, five-tab layout and PDF trigger;
    `SizedBox(height: 650)` around `TabBarView` preserved.
- Verification: `flutter analyze` → No issues found; `flutter test` → 56/56; `flutter devices`
  showed USB `ZY22G4C24N`; `flutter run -d ZY22G4C24N` built/installed and DTD hot restart
  succeeded with no runtime errors. Known offline OSM tile `Network is unreachable` noise remains.

DONE (Paging + overflow fixes, 2026-11-23, `flutter analyze` clean, 56/56 tests, fresh USB run):
- My Properties no longer builds the whole owner catalog. `getUserProperties(userId, {limit, offset})`
  pages at the repository (Supabase `.range(...)` + demo sublist); new `getUserPropertyStats`
  and `UserPropertyStats` provide lightweight totals; `UserPropertiesPaginator` /
  `userPropertiesPaginatorProvider` load 12 at a time and append more via an explicit
  "load more" button plus a scroll-near-bottom trigger. Verified on device: 440 total/published
  stats with only a bounded set of cards built.
- Favorites grid and admin moderation queue now render 12 cards with a "Load more" button and
  reset the window when their providers change. Both were converted to `ConsumerStatefulWidget`;
  `ref.listen` must be called in `build()` (an `initState` assertion on Favorites was caught on
  device and fixed).
- Overflow fixes: admin moderation actions use `Wrap`; admin owner/phone/date, location/area,
  type/price, section-header and moderation empty-state rows use `Flexible`/`Expanded` + ellipsis;
  `PropertyCard._badges` is a `Wrap` so the map discount pill no longer overflows; map selected-card
  price caption is ellipsized. Profile header name + admin badge row uses `Flexible` + ellipsis
  (fixed 15px overflow for `م/محمد السقاف` + super-admin pill). Device sweep (Profile, My Properties,
  Favorites, Admin, Map/list) shows no RenderFlex overflow.
- Verification: `flutter analyze` clean, `flutter test` 56/56, fresh `flutter run -d ZY22G4C24N`
  + DTD hot restart; only remaining noise is offline OSM tile `Network is unreachable`.

DONE (CARTO Voyager tile migration, 2026-11-24):
- Diagnosed blank street tiles on `ZY22G4C24N`: the phone reaches general internet (google.com
  loads in Chrome) but OSM tile hosts fail with socket `Network is unreachable (errno 101)`;
  OSM does not block the app User-Agent, and `flutter_map` warns against OSM a/b/c subdomains.
- Switched every street `TileLayer` to CARTO Voyager
  (`https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png`, a/b/c/d) in
  `property_map_view.dart`, `property_detail_screen.dart` and `add_edit_property_screen.dart`.
  Added `© OpenStreetMap contributors © CARTO` `TextSourceAttribution` (links to
  carto.com/attributions) and kept `errorTileCallback` logging. Esri satellite unchanged.
  Attribution in detail/add-edit is lifted with `Padding` so it clears bottom action overlays.
- Verification: CARTO tile returns HTTP 200 and renders in phone Chrome; CARTO tiles render on
  `/map` in the app; `flutter analyze` clean; `flutter test` 56/56; fresh USB
  `flutter run -d ZY22G4C24N`.

DONE (Esri street tiles replace CARTO, 2026-11-24):
- User reported every tile rendered as `API KEY REQUIRED carto.com/basemaps/apikey`.
  Confirmed by downloading the CARTO PNG (2,049 bytes) and OCR'ing it — HTTP 200 alone
  was misleading because the response is a key-required placeholder image.
- Replaced all three street `TileLayer`s with Esri World Street Map
  (`server.arcgisonline.com/.../World_Street_Map/MapServer/tile/{z}/{y}/{x}`), no
  subdomains/API key. Attribution updated to Esri's published sources with a link to
  the World Street Map terms. Satellite (World_Imagery) unchanged.
- Verified the Esri tile is a real 18 KB image, loads in Chrome on `ZY22G4C24N`, and
  renders in the app's `/map` (133 colour buckets, OCR shows no key-required text).
  `flutter analyze` clean; no tile-failure logs; no runtime errors.

DONE (Settings screen completion + verification, 2026-11-24, `flutter analyze` clean, 71/71 tests):
- Added persisted preferences for currency (YER/SAR/USD), distance unit (km/miles),
  text size (small/medium/large), default map view (list/map) and a duplicate-key
  fix for `set_add_property_style` in both ARBs. Regenerated l10n output.
- Closed three gaps found during verification: text size now drives a root
  `MediaQuery.textScaler` (0.85/1.0/1.15) because `MaterialApp.router` has no
  `textScaler` parameter in Flutter 3.47; search-radius values remain stored in
  km but are converted to miles for both the slider label and subtitle;
  `PropertyCard` now `watch`es `settingsProvider` so a currency change rebuilds
  price labels immediately. Currency switching changes the label only until an
  FX rate source exists.
- Reworked `test/settings_test.dart`: deterministic `notifier.loaded` instead of
  1 s sleeps, all setters awaited, new checks for text scaling, km→miles display,
  and reload from SharedPreferences. `addPropertyStyle` and `notificationsEnabled`
  persist but still have no consumer outside the Settings screen.
- Verification: `flutter analyze` clean, `flutter test` 70/70 (71/71 after the
  theme-scope regression test below), fresh USB build on `ZY22G4C24N` + DTD hot
  reload with no runtime errors.

DONE (Stale dark/light elements after theme switch, 2026-11-24, `flutter analyze` clean, 71/71 tests):
- Root cause: `AppColors.isDark` is a mutable static mirror of the effective
  brightness. Static getters cannot mark widgets dirty, so widgets that read
  `AppColors.surface/textPrimary/...` directly kept the previous palette until
  navigation built a fresh page.
- Added `lib/core/theme/app_theme_scope.dart`: a `ConsumerWidget` that watches
  `settingsProvider.themeMode`, resolves system brightness through `MediaQuery`,
  and keys its child subtree by the effective `Brightness`. Every GoRouter page
  (`_tabPage` and all `builder` routes) is wrapped in it, so the whole route
  re-evaluates its colors on a theme change while the router page key and
  navigation stack stay intact.
- Added a widget regression test in `test/settings_test.dart` asserting the
  subtree rebuilds when `ThemeMode` changes.
- Verification: `flutter analyze` clean, `flutter test` 71/71, DTD hot restart
  on `ZY22G4C24N`, then Dark→Light and Light→Dark round-trips from Settings back
  to the dashboard. Scaffold, surfaces, header and bottom nav all matched the
  selected theme after the transition; run log had no runtime errors/overflows.
- Release prep: bumped `pubspec.yaml` to `2.4.1+19` for the GitHub release.

DONE (back/filter/settings UI pass, 2026-11-24):
- GlobalAppBackHandler now awaits its async handler, checks route before `pop`,
  and no longer treats the single root GoRoute as poppable — one back on the
  dashboard shows the exit snackbar, a second within 2s exits.
- The global tap-to-dismiss keyboard GestureDetector uses `deferToChild`
  instead of `translucent`, so tapping a TextField no longer instantly
  unfocuses it. Register screen bottom fields keep the keyboard open.
- Map filtering now frames the coordinates of the filtered listings with
  `CameraFit.coordinates`, shows a live result-count chip in the header, and
  no longer shows the redundant "Search this area" button. List pagination is
  clamped to the actual filtered length (fixes RangeError after filtering).
- Settings "Add Property button" preference is now consumed: outlined option
  replaces the hero map CTA with an outlined add-property button + helper text
  and keeps the map FAB; FAB option adds an add-property FAB above the map
  controls (including list view). The bottom publisher CTA and drawer map card
  were removed as duplicated/context-free map shortcuts.
- Location consent is requested once on the first dashboard visit; Settings
  gained an explicit permission retry tile that opens OS app settings when the
  permission is denied forever. Search radius now has a subtitle explaining it
  drives Home → Properties near you.

DONE (web deferred loading + clustering, 2026-11-24):
- `AdminDashboardScreen` and `YemenMapScreen` are now deferred imports in
  `app_router.dart`. A shared `DeferredScreen` loads the library once, shows a
  localized loading state, and offers a retry on failure. New l10n keys
  `sh_deferred_loading`, `sh_deferred_error`, `sh_deferred_retry` were added to
  both ARBs and generated.
- `MapScreenArgs` was extracted to `lib/features/map/presentation/map_screen_args.dart`;
  `yemen_map_screen.dart` re-exports it for existing imports, while Home and the
  router import only the tiny type. This prevents Home from pulling the heavy
  map screen into the eagerly-loaded graph.
- `MapClusterService.clusterProperties` now uses a `(latCell, lngCell)` spatial
  hash and checks only the seed cell plus its 8 neighbours, replacing the
  previous all-pairs O(n²) scan. Added `test/map_cluster_service_test.dart`
  with a brute-force oracle across six zoom levels and a bounds/centroid check.
- Added `test/deferred_screen_test.dart` covering the loading → ready path and
  the error → retry path. Verification: `flutter analyze` clean, 71/71 tests,
  `flutter build web --release` succeeded with three deferred JS parts
  (`main.dart.js_1/2/3.part.js`; main bundle ~5.28 MB).

DONE (map filter + add-action correction, 2026-11-25):
- `AppConstants.canonicalGovernorate` / `governorateMatches` now treat
  `صنعاء`, `أمانة العاصمة`, `أمانة العاصمة صنعاء` and `محافظة صنعاء` as one
  search area. This fixes Governorate=صنعاء + District=بيت بوس, which previously
  returned 0 because the two demo listings are stored under `أمانة العاصمة`.
- Removed viewport clipping from the map count badge and synced list. They now
  use the same `filteredProperties` list as the map markers, so correct filters
  no longer look empty while the camera is still at the governorate centroid.
  Deleted the unused `MapEvent` subscription / `_visibleBounds` camera fallback.
- Added `lib/shared/widgets/add_property_fab.dart`: a compact, theme-aware
  `FloatingActionButton.small` with `Icons.add_home_outlined`. It is shown on
  Home and only in the map's list view; the previous extended FAB was removed
  from the map surface. Home's map FAB now uses `AppColors` tokens instead of
  hardcoded teal/white.
- Added `test/governorate_filter_test.dart` and extended
  `test/yemen_map_screen_test.dart` with the exact صنعاء/بيت بوس case and the
  list-only add-FAB placement check. Verification: `flutter analyze` clean,
  74/74 tests, USB hot restart with no runtime errors.

## Docs policy
- AGENTS.md = agent memory (this file). PROJECT_SUMMARY.md = stale human snapshot, keep for context.
- `docs/reports/` = historical verification (keep) · `docs/screenshots/` = curated only
- Do not add new report files without user request. Update this file after every completed change.