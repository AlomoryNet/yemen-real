# AGENTS_HISTORY.md — Full change log (Yemen Real Estate Portal)

This file contains the complete historical "Status — done / remaining" log moved out of
`AGENTS.md` to reduce per-task context consumption. Read it only when you need prior
decisions, migration history, or why a convention exists.

---

## Status — done / remaining (full history)

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

## Docs policy
- AGENTS.md = agent memory (this file). PROJECT_SUMMARY.md = stale human snapshot, keep for context.
- `docs/reports/` = historical verification (keep) · `docs/screenshots/` = curated only
- Do not add new report files without user request. Update this file after every completed change.