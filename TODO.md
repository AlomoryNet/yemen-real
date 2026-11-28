# TODO — Yemen Real Estate Portal

Living roadmap. Update as items are completed. Full change history stays in `AGENTS_HISTORY.md`.

## Next up

- [x] **Supabase signup/reset email delivery (2026-11-28)** —
      Verified end to end on `ZY22G4C24N`; credentials stayed in `.env` only and
      no values were printed or copied into tracked files. Earlier UI/API retries
      with a no-dot alias returned HTTP 429 `over_email_send_rate_limit`; the
      real `Asmor112011@gmail.com` account was never touched. Switched to the
      address from `TEMP_EMIAL` as-is: the app Register UI accepted it, the
      Supabase confirmation message was observed in Gmail on device Chrome, its
      link was tapped, and that temporary user became `confirmed=True`.
      Supabase `site_url` was changed to `yemenreal://login-callback` and
      `AuthCallbackScreen` gained an in-app new-password form. At 05:02 local a
      single fresh reset request was sent from the app Reset password screen;
      the new reset email arrived at 05:04, was opened in Gmail on the device and
      its link was tapped. The PKCE link contained only `code`, so the mobile
      callback was updated to detect gotrue's `passwordRecovery` event (and to
      accept a `type=recovery` deep link) before showing the form. The new
      password was entered twice through that UI, saved, and login with it was
      verified on the device. While still signed in, the drawer's Saved searches
      and Notifications screens both loaded, and the map filter sheet's
      `Save search` action created one temporary saved search that appeared in
      the list. Only after those UI checks was the temporary `TEMP_EMIAL` user
      deleted (the protected account remains present).

- [x] **MapLibre + OpenFreeMap street maps with local tile cache** (2026-11-26,
      committed `add0b3f`; `flutter analyze` clean, `flutter test` 136/136):
      - [x] `MapLibreLayer` replaces Esri street tiles on `/map`, property detail
        and the add/edit picker while keeping the existing `FlutterMap`
        clusters, polygons, camera animation and RTL overlays. Esri World
        Imagery remains only for the satellite toggle.
      - [x] `lib/core/constants/map_sources.dart` centralizes URLs/attribution;
        `docs/MAP_SOURCES.md` documents the live stack, the offline cache and
        the future Cloudflare R2 free-tier PMTiles upload pipeline.
      - [x] Settings offline-map tile downloads/deletes a Yemen z5–10 pack
        (1,105 tiles / ~9 MB, within OpenFreeMap's 3,000-tile and 50 MB limits)
        on top of a 100 MB ambient cache. Verified on `ZY22G4C24N` with Wi-Fi
        and mobile data disabled.
      - [x] Supabase `String.fromEnvironment` values are now `const`; temporary
        diagnostic prints removed. iOS target is 15.0 for `maplibre: ^0.4.0`.
      - [x] USB pass covered clusters/toggle, detail preview, add/edit pin drop,
        Settings download/delete/offline rendering and Arabic locale; DTD showed
        no runtime errors.

- [x] **Remaining i18n (Option B) — PDF direction + place names**
      - [x] PDF locale policy: `contract_preview_screen.dart` and
        `admin_pdf_service.dart` now snapshot `Directionality.of(context)`
        before the async font load; PDF direction and cell/heading alignment
        follow the active locale instead of always rendering RTL.
      - [x] Governorate/district display names: `AppLabelsEn` holds English
        labels, `AppConstants.getGovernorateNameAr/getDistrictNameAr` are the
        single display gate, and filter/card/detail/map/contract call sites use
        them. Arabic stays the canonical storage/filter key. The map search box
        now shows the localized governorate label without breaking filtering.
        Demo `LocationItem.nameEn` is a display name, not `sanaa_capital`.
      - Added `test/display_name_localization_test.dart` plus an English `/map`
        filter regression in `test/yemen_map_screen_test.dart`; `flutter analyze`
        clean, 83/83 tests, USB hot restart with no runtime errors.

- [x] **Contract default clauses/titles — locale defaults at creation**
      - Added `models/contract_default_text.dart` with Arabic/English legal
        template text. `PropertyContract.defaultTemplate()` picks the active
        locale via `AppLocale` and stores the chosen title, payment/duration,
        utilities/maintenance/late-payment wording and clauses in the existing
        string fields, so no schema/JSON migration is needed.
      - Saved owner templates keep the language they were created in; new
        contracts without a saved template follow the current locale.
      - Added `test/contract_locale_defaults_test.dart`; `flutter analyze` clean,
        87/87 tests, fresh USB hot restart with no runtime errors.
      - Leave as-is: demo property content, model JSON fallbacks, comments,
        log strings, Arabic comma in user-edited contract clauses.

- [x] **Performance quick wins**
      - [x] Cold-start jank: the 440 demo listings are now generated once per
        process (`DemoPropertiesGenerator.cachedDemoProperties`) and reused by
        the demo store, Home and the map fallback. Home's no-op post-frame
        rebuild was removed and both `ThemeData` objects are cached.
      - [x] Input-dispatch ANR mitigation: the dashboard's 440-listing nearby
        scan is now cached in `nearbyPropertiesProvider`, card images decode at
        a capped width, and first-run location consent no longer races a
        SharedPreferences write with the OS permission dialog.
      - [x] Runtime font fetching removed: `assets/fonts/Cairo.ttf` is declared
        as the `CairoLocal` family (its `fvar` table exposes `wght` 200–1000),
        and `core/theme/app_fonts.dart` sets `FontVariation('wght', …)` for
        every requested weight. All `GoogleFonts.cairo`/`outfit`/`amiri` calls
        were migrated to `AppFonts.cairo` (the two minor fonts now render with
        bundled Cairo), `GoogleFonts.config.allowRuntimeFetching = false` in
        `main.dart`, and `test/app_fonts_test.dart` was added. `flutter analyze`
        clean, 92/92 tests, fresh USB cold launch with no runtime errors.
      - [x] Slim the four unbounded admin queries (users, commissions, reports,
        rental requests). Each repository now exposes a bounded `get*Page()`
        (`order(...).range(...)` plus a separate count), a chunked
        `streamAll*ForExport()`, and keeps the old full-list method as an
        export-only collector. `AdminListPaginator` drives the four tabs via
        new paginator providers; `AdminPagedList` gained external
        `hasMore/isLoadingMore/onLoadMore`. CSV buttons and PDF sections await
        the separate full-list providers, so exports remain complete.
        Added `test/admin_paging_repository_test.dart`,
        `test/admin_list_paginator_test.dart` and external-paging widget tests;
        `flutter analyze` clean, 100/100 tests. USB pass verified all four
        tabs and PDF sections 1–4; requests/commissions CSV dialogs opened
        with complete headers. No runtime errors or new ANR.
      - [x] `getDashboardStats()` now uses PostgREST `sum()`/`count()` aggregates
        with a client-side fallback for older backends (`admin_repository.dart`).
      - [x] `const` constructor pass (40 `const`/`unnecessary_const` fixes across
        hot-path and shared widgets; `prefer_const_constructors` was temporarily
        enabled to find them, then disabled again in `analysis_options.yaml`).
      - [x] Web bundle deferred loading for admin/map — route libraries are
        loaded through `DeferredScreen`; the release web build emits separate
        deferred parts for the heavy screens.
      - [x] Map clustering with `map_cluster_service.dart` — clustering now uses
        a spatial hash instead of an O(n²) all-pairs scan.
      - [x] Map cluster zoom animation now reuses one `AnimationController` in
        `PropertyMapView`, so rapid repeated cluster taps cannot create extra
        tickers. Added `test/property_map_cluster_ticker_test.dart`; verified on
        USB with repeated cluster taps and no runtime errors.

- [x] **Accessibility + loading UX** — verified on USB (2026-11-25).
      - [x] `PropertyTextStyles.badgeOnAccent()` + `AppColors.onAccent` keep the
        featured badge at AA contrast on the amber fill; contrast is asserted in
        `test/property_text_styles_test.dart`.
      - [x] `Semantics` labels/tooltips and 48dp tap targets on icon controls,
        plus root `FocusTraversalGroup` reading-order traversal for web/desktop.
      - [x] Static `SkeletonLoader` via `LoadingView(skeleton: true)` on map,
        contract, deferred screens, favorites, detail, My Properties and admin
        tabs; no extra tickers or infinite shimmer loops.
      - [x] Unified loading/error/empty states via `LoadingView`, `ErrorView`
        (with optional context title + retry) and `EmptyStateView`, including
        map, contract load failures and admin pending/users tabs.

- [x] **Map filter Reset no longer empties results** (2026-11-25). Resetting
      the bottom-sheet filters clears the governorate label that `/map` writes
      into the search field, so the stale free-text query cannot hide every
      listing (especially with the English label). Added a widget regression;
      `flutter analyze` clean, 115/115 tests. Fresh USB pass: Ibb (20) → Reset
      → Apply showed 440 with an empty search field and no runtime errors/ANR.

- [x] **Map/filter + profile/readability/admin/demo-data UX batch** (2026-11-25).
      - [x] Map default governorate follows stored location (إب fallback), is
        reflected in the filter sheet, and participates in actual filtering;
        filter changes fit the camera to the full filtered set with expanded
        bounds for tiny/degenerate results. `صنعاء` + `بيت بوس` stays at 2.
      - [x] Filter sheet labels localize with `AppLocale`, selected chips use
        `onPrimaryContainer`; home retains its original inline search Row, with
        the compact filter/search button icons centered inside 48dp buttons.
      - [x] Profile is pushed with a top back button and no bottom nav; drawer
        uses `go` only for root destinations and `push` for hierarchical pages.
      - [x] Status/featured badges use brightness-aware fill/ink colors; admin
        header, tabs, PDF CTA, stats and list rows wrap instead of squeezing.
      - [x] Demo mode seeds pending approvals, commissions, rental requests,
        reports, favorites and usable login profiles; login shortcuts fill a
        valid password. `flutter analyze` clean, 114/114 tests. Fresh USB
        light/dark pass confirmed map defaults, Profile back-stack, badge ink
        and admin layout with no errors or new ANR.

- [ ] **Flow / product**
      - [x] Deep links + share for property detail (2026-11-28): canonical
        `/property/<id>` web paths via `usePathUrlStrategy()`, Android
        `yemenreal://property/<id>` custom-scheme links, `PropertyLinks` helper,
        incoming-link routing in `main.dart`, copy-link share action with a
        snackbar, and static + per-property dynamic OG/Twitter/canonical meta.
        The OpenFreeMap request header is native-only now to avoid a browser
        CORS preflight failure. `flutter analyze` clean, `flutter test`
        178/178, `flutter build web --release` succeeded. USB `ZY22G4C24N`: a
        `yemenreal://property/<id>` intent opened the correct detail page, share
        copied `yemenreal://property/<id>` (verified by pasting into the home
        search field) and showed `تم نسخ رابط العقار للمشاركة`; no runtime
        errors. Local web SPA check confirmed `/property/<id>` loads with
        per-property title/OG/canonical meta and no console errors. User decided
        (2026-11-28) to keep custom-scheme-only sharing for now; revisit HTTPS
        App Links / iOS Universal Links later if a hosted domain is provided
        (`APP_BASE_URL`, `assetlinks.json`/AASA).
      - [x] Saved searches + alerts on new matching listings (2026-11-28,
        uncommitted): `MapQuery` JSON serialization, `SavedSearch` model,
        Supabase/demo repositories and providers, save-current-search dialog in
        the map filter sheet, saved-searches/notifications screens and routes,
        drawer/rail entries, and rerunnable SQL migration with RLS, policy,
        function, grants and an `AFTER INSERT OR UPDATE OF status` trigger on
        `properties`. Alerts are in-app `notifications` rows (no new dependency
        or push service) and deliberately exclude the listing owner’s own saved
        searches. Matching covers deal/type, governorate/district contains,
        free text, price/bedrooms, featured, exact coordinates and nearby radius
        with a governorate-center fallback. Migration applied to the linked
        Supabase project using credentials loaded only from `.env`; verified
        tables/index/4 policies/function/trigger. A live trigger test created a
        temporary matching/non-matching saved search and a published listing:
        only the matching non-owner received one notification; all temporary
        rows were deleted and both property triggers remain enabled. `flutter
        analyze` clean, `flutter test` 187/187. USB `ZY22G4C24N`: the filter
        sheet's `Save search` action closes the sheet and shows the sign-in
        prompt for guests. The authenticated pass was completed after the email
        flow: Saved searches and Notifications loaded, and one temporary saved
        search created from the filter sheet appeared in the list before the
        temporary user was cleaned up.
      - Visit/booking scheduling in rental requests.
      - First-run onboarding: location permission + city selection.
      - Offline cache of viewed properties + favorites (Hive).

- [ ] **Quality / DX**
      - More widget tests (filter sheet, pagination, PropertyCard layouts).
      - Golden tests for key screens.
      - [x] CI: `.github/workflows/ci.yml` runs `flutter pub get`,
        `flutter analyze` and `flutter test` on pushes to `main` and on PRs,
        using Flutter 3.47.6 stable and Java 17 (2026-11-28, uncommitted).
      - Production crash reporting (Sentry/Crashlytics).

## Recently completed (2026-11-25)

- [x] **Dashboard FAB stack alignment.** The compact add-property FAB now uses
      the extended map FAB's trailing edge (`CrossAxisAlignment.end`); the old
      centered `Column` child looked detached from the `endFloat` FAB stack.
- [x] **Map filter + add-action correction.** `صنعاء` aliases `أمانة العاصمة`,
      so Governorate=صنعاء + District=بيت بوس returns the 2 demo listings.
      Count/list now use the full filtered set instead of clipping to the map
      viewport. Added a compact shared `AddPropertyFab` (small FAB, add-home
      icon) on Home and in the map list view only. `flutter analyze` clean,
      74/74 tests, USB hot restart with no runtime errors.

## Recently completed (2026-11-24)

- [x] **Performance quick wins — web deferred routes + map clustering.**
      `AdminDashboardScreen` and `YemenMapScreen` are now deferred imports in
      `app_router.dart`, loaded through `DeferredScreen` with a localized loading
      and retry state. `MapScreenArgs` moved to its own tiny file so Home no
      longer pulls the map screen into the eagerly-loaded graph.
      `MapClusterService.clusterProperties` now buckets coordinates into a
      spatial hash and only checks the seed cell plus its 8 neighbours, turning
      the previous O(n²) scan into near-linear work for large result sets.
      Added `test/deferred_screen_test.dart` and
      `test/map_cluster_service_test.dart` (brute-force equivalence oracle).
      `flutter analyze` clean, 71/71 tests, `flutter build web --release`
      succeeded and emitted three deferred parts.
- [x] **Performance quick win — `const` pass.** Applied 40 mechanical
      `const`/`unnecessary_const` fixes across admin tabs, contract/map/sheet
      widgets, `PropertyCard` and tests. No behavior changes.
- [x] **Performance quick win — cold-start hot path.** `HomeScreen` no longer
      regenerates 440 demo listings on every build and no longer schedules a
      no-op post-frame `setState`; the map fallback and demo store reuse the
      same cached snapshot. `AppTheme` now caches both themes; added
      `test/demo_properties_cache_test.dart`.
- [x] **Performance quick win — dashboard commission totals.** `getDashboardStats()`
      now asks PostgREST for `sum()`/`count()` instead of downloading every
      commission row, with a fallback to the previous fold if aggregates are unsupported.
- [x] **Overflow, hidden text & theme consistency pass.**
      - Fixed 4 unconstrained `Row`s in `add_edit_property_screen.dart` (incl.
        the exact log overflow at line 995) and the contract editor date/ID row
        overflow (`contract_preview_screen.dart:772`) by wrapping long text in
        `Flexible`. Contract editor switches now use transparent `Material`
        ancestors to remove ListTile ink debug errors.
      - My Properties header title/subtitle no longer ellipsize without a
        `maxLines` budget — the subtitle now wraps in full. Same relaxation
        applied to dashboard category subtitles, admin dashboard/tab titles,
        moderation heading, drawer map subtitle, contact-unavailable notice and
        rental-request date rows.
      - Contract preview + editor sheet migrated off hardcoded white/black/grey
        to `AppColors` semantic tokens; dark-ink `primaryDark`/`accentDark`
        foregrounds replaced with `primaryInk`/new `accentInk`; direction-hardcoded
        paddings/borders made `EdgeInsetsDirectional`/`BorderDirectional`.
      - Added `AppColors.shadow` and `accentInk` tokens; themed modal barrier
        scrim on all four bottom sheets and `AuthPromptDialog`.
      - Migrated dark-theme breakers in admin pending card, status badge,
        property detail, login/auth-callback/register notices, admin users tab,
        admin PDF dialog, bottom nav, back-exit snackbar, filter-sheet shadow
        and rental-request spinner to theme tokens.
- [x] **Image + LTR follow-up.** Last two raw `Image.network` calls now use
      `CachedNetworkImage` with `memCacheWidth` and placeholders
      (`add_edit_property_screen.dart`, `admin_pending_property_card.dart`).
      Property-card/image overlays use `PositionedDirectional(start/end)` so
      badges/favorites mirror correctly in LTR while RTL output is unchanged;
      add/edit thumbnail margin is `EdgeInsetsDirectional`.
- [x] **Admin huge list at the bottom.** Added reusable `AdminPagedList<T>`
      (`lib/features/admin/presentation/widgets/admin_paged_list.dart`) and wired
      it into all five admin tabs — 12 rows initially, "Load more" reveals the
      next page. Moderation queue initial page reduced 12 → 6 heavy cards.
      Added `test/admin_paged_list_test.dart` (2 tests). Analyze clean, 58/58
      tests pass, USB run + DTD hot restart with no runtime errors.
- [x] **i18n quick wins.** App-bar titles localized in admin, favorites, rental
      requests, property detail and add/edit; `Back` tooltip localized;
      publisher CTA uses existing `dash_cta_*` keys; two new hero-map ARB keys
      added in AR + EN; branding/copyright switched to locale-aware getters;
      map semantics separator fixed. Full ARB regeneration via `flutter gen-l10n`.
- [x] **Map tile provider — resolved (done in another session).** All three
      street layers use Esri World Street Map; Esri World Imagery unchanged.
      Do **not** revert to OSM public tiles (unreachable from `ZY22G4C24N`) and
      do **not** use CARTO Voyager (`API KEY REQUIRED` placeholder PNG).
- [x] Admin screen split into `presentation/widgets/`, `presentation/tabs/` and
      `services/admin_pdf_service.dart`.
- [x] Property cards unified via `PropertyCard`; pagination applied to My
      Properties, Favorites and moderation queue.
- [x] Map grouped-properties sheet redesigned with app tokens.
