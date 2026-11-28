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
8. SECRETS: never copy any value from `.env` (or any untracked secret file) into a
   tracked file — not into Dart, SQL, tests, docs, comments, migrations or reports.
   `String.fromEnvironment('NAME')` is the ONLY allowed reference to an env variable
   name; it must have no literal/default value in source. `.env` and `*.env` stay
   gitignored. Before any commit/push, audit tracked files for old project URLs,
   anon/service keys, tokens and credentials and redact them (never delete docs
   files wholesale). Runtime reads via `--dart-define-from-file=.env` are fine;
   printing, logging or committing the values is not.
9. RELEASES: when the user says "create new release", always publish the GitHub
   release with both the generated source archives AND an APK asset. Build the APK
   from the pushed tag and upload it to that same release. Debug signing is the
   current fallback (there is no keystore in the repo); ask for signing details if
   a properly signed APK is required.

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
flutter test      → suite (last known: 173 tests)
```

## Status - latest
- Rental-request visit scheduling (uncommitted, 2026-11-28): added a distinct
  `scheduled_visit_at TIMESTAMPTZ` field (not the move-in date) via
  `supabase/migrations/20261128_rental_request_visits.sql` (also folded into
  `complete_setup.sql`). Tenants can optionally propose a future visit in
  `RentalRequestModal`; admins/owners can schedule, reschedule or clear it from
  `AdminRequestsTab`. Added shared `DateTimePickers.futureDateTime`, tenant
  display, success-view confirmation, CSV/PDF columns, demo seeds, localized
  ARB keys and a rerunnable migration. `userRentalRequestsProvider` is now
  `autoDispose` and invalidated after submit/admin changes so My Rental Requests
  refreshes. Migration applied with `.env` credentials only; no values copied to
  tracked files. The success-sheet note now uses theme-aware
  `warningFill`/`warningInk` at 13sp instead of a fixed light fill/ink, so it
  stays readable in dark mode. `flutter analyze` clean, `flutter test` 193/193.
  USB `ZY22G4C24N`: admin schedule→clear→reschedule, tenant submission with a
  proposed visit, success view and My Requests display all verified; DTD
  reported no runtime errors. Temporary user/listing/requests removed and the
  protected account remains.
- Saved-search dialog teardown fix (commit `1de0ac9`, pushed 2026-11-28): the transient
  `Overlay`/`_dependents.isEmpty` assertion was reproducible in a widget test.
  Root cause: `_saveCurrentSearch` disposed its `TextEditingController` as soon
  as `showDialog` returned, while the dialog was still animating out and
  rebuilding against the disposed controller; the cascade then deactivated
  inherited elements in the wrong build scope. `_SaveSearchDialog` now owns the
  controller for the whole dialog lifetime and returns a typed result, and its
  content `Column` uses `mainAxisSize.min`. Added
  `test/saved_search_dialog_test.dart` as a regression. `flutter analyze` clean,
  `flutter test` 188/188. USB `ZY22G4C24N`: recreated a temporary confirmed user
  via the admin API (no email sent), signed in through the UI, saved a search
  from the map filter sheet with no runtime errors, confirmed it appeared in
  Saved searches, then deleted only that temporary user and verified the
  protected user remains. Hot restart: no runtime errors.
- Commit `f820778` pushed to `origin/main` (2026-11-28): includes the verified
  Supabase email flows, PKCE recovery fix, saved searches/alerts, property deep
  links/share, CI workflow and map chip alignment. Follow-up `chore` commit
  ignores local `.opencode-tmp/` artifacts.
- Supabase email verification completed + PKCE recovery fix (uncommitted,
  2026-11-28): the confirmation email for the `.env` `TEMP_EMIAL` user was
  observed in device Gmail, tapped, and that user became `confirmed=True`.
  `site_url` is now `yemenreal://login-callback`. One fresh reset link was
  requested from the app UI at 05:02 (no retries/brute-forcing); the 05:04 Gmail
  reset message was opened on `ZY22G4C24N`. Supabase PKCE recoveries send only
  `code`, so `AuthCallbackScreen` now also watches gotrue's `passwordRecovery`
  event, and `main.dart` routes `type=recovery` callbacks; the active recovery
  session was reopened with that deep link, the in-app password form saved the
  new password, and UI login with it succeeded. While signed in, the drawer's
  Saved searches and Notifications screens loaded, and the `/map` filter
  sheet's `Save search` created one temporary saved search that appeared in the
  list. The temporary user was deleted only after all UI checks; a post-cleanup
  audit confirmed it is absent and `Asmor112011@gmail.com` remains present. No
  credential values were printed or written to tracked files. An
  `Overlay`/`_dependents.isEmpty` assertion observed during the saved-search
  dialog teardown was later reproduced and fixed by the entry above; the rest of
  the signed-in checks completed and DTD reported no runtime errors. `flutter
  analyze` clean; `flutter test` 187/187 at the time; `TODO.md` marks both flows
  and the authenticated saved-search pass done.
- CI + map header chip alignment (uncommitted, 2026-11-28): added
  `.github/workflows/ci.yml` (Flutter 3.47.6 stable + Java 17, `flutter pub get`,
  `flutter analyze`, `flutter test` on `main` pushes and PRs). The `/map`
  floating header now gives the filter button, live result badge and every
  active filter chip the same 48dp height; the chip row's vertical padding was
  removed so they sit on one baseline. The shared filter sheet's `FilterChip`s
  use the same 48dp height, so the header and sheet chips stay visually
  consistent. Added height assertions to `test/yemen_map_screen_test.dart`;
  `flutter analyze` clean, `flutter test` 187/187.
- Saved-search migration applied (uncommitted, 2026-11-28):
  `supabase/migrations/20261128_saved_searches_and_alerts.sql` was applied to the
  linked project with `psycopg2` using `SUPABASE_DB_PASSWORD` loaded only from
  `.env` (no values printed or written to tracked files). Verified
  `saved_searches`/`notifications` tables, the user+created index, 4 RLS
  policies, `notify_saved_search_matches()` and the properties trigger. The
  function excludes the owner’s own searches, uses bidirectional
  governorate/district contains matching, treats 0,0 as missing coordinates and
  falls back to the governorate center for nearby alerts. `complete_setup.sql`
  carries the same function/grants. A live trigger test inserted a temporary
  published listing plus matching/non-matching/owner saved searches: only the
  matching non-owner got one notification, and all temporary rows were removed
  with both property triggers confirmed enabled. USB `ZY22G4C24N`: the map
  filter sheet's `Save search` action closes the sheet and shows the guest
  sign-in prompt. `TODO.md` now marks saved searches done pending authenticated
  screen verification; `flutter analyze` clean, `flutter test` 187/187.
- Supabase recovery-link UX fix (uncommitted, 2026-11-28): the observed reset
  email was generated while Supabase `site_url` was still `http://localhost:3000`,
  so tapping `Reset password` opened an unreachable local page. `AuthCallbackScreen`
  now recognises `type=recovery` fragments, waits for supabase_flutter to consume
  the deep link, and shows an in-app new-password/confirm form that calls
  `auth.updateUser()` then signs out before routing to `/login`. Added
  `reset_password_*` keys to both ARBs and regenerated l10n. Supabase Auth
  `site_url` was changed via the Management API (credentials loaded only from
  `.env`) to `yemenreal://login-callback` so future reset links land in the app;
  no secret values were printed or copied into tracked files. `flutter analyze`
  clean, `flutter test` 187/187, `flutter build web --release --no-wasm-dry-run`
  succeeded, fresh USB install on `ZY22G4C24N` with DTD reporting no runtime
  errors. A single fresh reset request is scheduled for
  05:02 local (one hour after the 04:01 send) to respect the email limiter;
  reset/login verification and temporary-user cleanup are still pending, so
  `TODO.md` was intentionally left unchanged.
- Supabase email verification partial pass (2026-11-28): the previous no-dot
  alias retries hit HTTP 429, so the user supplied a different recipient in
  `.env` as `TEMP_EMIAL` and asked to use that value as-is. The app Register UI
  accepted it, the confirmation email was observed in Gmail on device Chrome,
  the link was tapped, and the temporary user is now `confirmed=True`. The link
  redirected to `localhost:3000` because Supabase still has a local site URL,
  but confirmation succeeded. Forgot-password still returns "Too many requests
  recently"; no reset email arrived after two UI taps, so a single retry is
  scheduled for 03:57 local. The temporary user has NOT been cleaned up yet and
  `Asmor112011@gmail.com` was not touched. `TODO.md` records the partial state.
- Property detail deep links + share (uncommitted, 2026-11-28): added
  `lib/core/utils/property_links.dart` (canonical `/property/<id>` paths,
  `yemenreal://property/<id>` links, parser, `APP_BASE_URL` via
  `String.fromEnvironment` only), conditional web meta helpers
  (`web_meta{,_web,_stub}.dart`), `usePathUrlStrategy()` and incoming-link
  routing in `main.dart`, Android custom-scheme intent filter, copy-link share
  action with snackbar on property detail, static OG/Twitter tags in
  `web/index.html` and refreshed `web/manifest.json`. The OpenFreeMap request
  header is now native-only; sending it from the browser caused a CORS preflight
  failure on the map style. Added `flutter_web_plugins` as a direct SDK
  dependency and `test/property_links_test.dart` +
  `test/property_detail_share_test.dart`. `flutter analyze` clean,
  `flutter test` 178/178, `flutter build web --release` succeeded. USB
  `ZY22G4C24N`: `yemenreal://property/<id>` opened the correct detail page,
  share copied `yemenreal://property/<id>` (verified by pasting into the home
  search field) and showed the copied snackbar, with no runtime errors. Local
  web SPA check: `/property/<id>` loaded, per-property title/OG/canonical meta
  updated and no console errors after the CORS fix. User decided
  (2026-11-28) to **keep custom-scheme-only sharing for now**; revisit HTTPS
  App Links / iOS Universal Links later if a hosted domain is provided.
- Home category fallback fix (uncommitted, 2026-11-27): the live Supabase project
  currently has **zero** `properties` rows, so the featured/for-sale/for-rent
  preview providers returned empty lists while the nearby section and `/map`
  used the generated demo catalogue. The three preview providers and their
  count providers now fall back to that same demo catalogue only when the
  backend returns zero rows; non-empty live results and real errors still win.
  Added regressions in `test/dashboard_category_counts_test.dart`.
  `flutter analyze` clean; `flutter test` 173/173. Verified after commit on the
  linked network device `192.168.8.117:33803` (USB `ZY22G4C24N` was unavailable):
  Featured showed 88 demo listings, For sale and For rent showed populated demo
  cards, and the trust/publisher sections rendered without runtime errors.
- Release policy + APK asset (2026-11-28): the standing release rule now requires
  source archives **and** an APK asset. Built `app-release.apk` with debug signing
  from the pushed code and uploaded it to the existing `v2.4.1+19` release as
  `yemen-real-v2.4.1+19.apk` (107,441,437 bytes). The docs policy was committed
  as `47f1806` and pushed to `origin/main`.
- Responsive landing page pass (uncommitted, 2026-11-27): Home now uses a
  two-column desktop hero (>=900dp) with one search/filter card and one
  publisher/map row, and its body is wrapped in `AppPageBody` so the existing
  expanded navigation rail is the desktop sidebar. Added
  `home_trust_section.dart` (4 stats + 4 M3 trust pillars, 1/2/4-column
  responsive) before the publisher CTA, new `landing_*` ARB keys in both
  locales, and `test/landing_page_sections_test.dart`. Existing hero keys,
  add-property style behaviour and the single-map-CTA rule are unchanged.
  `flutter analyze` clean; `flutter test` 171/171. USB `ZY22G4C24N`: verified
  the hero, property feeds, trust stats/pillars and publisher CTA in Arabic and
  English, light and dark; no runtime errors or overflows, and settings were
  restored to Arabic/light.
- Auth callback redesign + real Supabase verification (uncommitted, 2026-11-27):
  `AuthCallbackScreen` now has a localized `callback_title` AppBar, themed
  status/email/navigation states, and M3 filled/tonal actions. Added
  `callback_*` keys to both locales and updated `test/auth_verification_flow_test.dart`.
  Verified real Supabase login, add-property persistence and cleanup on the
  linked project; the mobile callback needed a quoted Android URI in the test
  helper because an unquoted `&` truncated the token fragment. `flutter analyze`
  clean; full suite included in 171/171.
- Detail redesign + map perf + DB hardening pass (uncommitted, 2026-11-27):
  Property detail now uses a self-contained `PropertyImageGallery` (swipeable
  main image + thumbnail strip; tapping a thumbnail no longer rebuilds the
  inline map), `Responsive.contentMaxWidth()`, M3 `ColorScheme`/`TextTheme`
  tokens (no raw colours/text styles in the redesigned sections), tonal/filled
  action buttons, directional breadcrumb separators and map overlays, a carded
  320dp map preview with a `RepaintBoundary`, semantic price marker and capped
  image decode widths. The featured-badge contrast token pair is unchanged.
  Add/edit's picker is now `LocationPinPicker`: the parent owns a
  `ValueNotifier<LatLng?>`, save reads it directly, camera frames only update
  the notifier/caption, host commits are coalesced through one ~90ms `Timer`,
  and the nearest-governorate caption is cached by coordinate + language.
  `StorageService()` now falls back to `SupabaseService.client`, and
  `String.fromEnvironment` no longer carries literal defaults.
  `supabase/complete_setup.sql` is now rerunnable (all 33 policies are dropped
  before creation), grants roles explicitly, owns the full 22-governorate /
  103-district coordinate seed, adds the `pending`-aware status constraint,
  review columns, `increment_property_views` RPC and the non-admin publish
  guard. Applied to the linked project with the CLI using credentials loaded
  only from `.env`; no wipe. Verified: 125 locations, 6 property types, 3
  settings, 29 policies, both new functions/triggers, and all tables reachable
  with the service key. Old live Supabase project refs were redacted from
  tracked docs/tests/migrations; `.env` secrets remain untracked and are never
  copied into source. `flutter analyze` clean; `flutter test` 169/169.
- Device-location + pin-picker pass (uncommitted, verified 2026-11-27):
  `/map`, property detail and add/edit now use Google-Maps-style location
  behaviour. `DeviceLocationService.currentLocationIfPermitted()` is the silent
  map-open lookup; the shared `LocateMeButton` is the only path that calls
  `requestLocation()`. A fresh `getCurrentPosition()` now falls back to
  `getLastKnownPosition()` so a slow GPS fix no longer leaves the blue dot
  missing. `UserLocationMarker` / `userLocationMarker()` draw the blue dot on
  all three hosts (after the property markers, so it stays visible), and each
  host owns its own camera movement via `onLocated`; plain `/map` recentres on
  the device while explicit `MapScreenArgs` presets keep their governorate.
  The add/edit picker is now a 320dp fixed-centre-pin map: drag/zoom/tap moves
  the pin under a large centre marker, a themed caption shows the nearest
  governorate plus coordinates, `Clear` restores the hint, and locate adds the
  blue dot. Currency values are normalized to `YER/SAR/USD`; property types use
  locale-aware `AppConstants.localizedName()`, so the Arabic dropdown never
  shows `en`. Added l10n keys (`map_locate_me`, `map_location_found`,
  `map_location_open_settings`, `map_location_permission_denied`,
  `map_location_unavailable`, `addprop_map_center_hint`, `addprop_clear_pin`,
  `addprop_map_zoom_in`, `addprop_map_zoom_out`) and regenerated l10n. Added
  `test/helpers/fake_geolocator.dart`, `test/user_location_test.dart` and
  `test/add_edit_property_layout_test.dart`; `flutter analyze` clean and
  `flutter test` 167/167.
  - ANR triage: DTD reported `No runtime errors found.`, there was no
    `data_app_crash` and the process stayed alive. The Android ANR was
    `Input dispatching timed out (Application does not have a focused window)`,
    not a Dart crash. MapLibre's `configureAmbientCache()` is deferred until
    after the first frame and Home's first-run location request is delayed by
    2s so startup input focus is not blocked. A fresh cold launch with eight
    rapid early taps left the app alive and produced no new ANR (only the old
    `anr_2026-11-27-03-14-16-225`).
  - USB `ZY22G4C24N`: with permission denied, opening `/map` showed no prompt
    and no blue dot; pressing `My location` raised the OS permission dialog.
    After grant, a first press showed an unavailable snackbar until the cached
    fallback was added; reloading and pressing again produced a blue dot and
    recentred camera. Property detail showed the blue dot on locate; add/edit
    placed the centre pin at `13.95891, 44.16381 · إب`, showed the blue dot,
    and `Clear` restored the drag hint. Verified in English/light and
    Arabic/dark, including the Arabic property-type dropdown (no `en`), with
    no runtime errors, overflows or new ANR. Everything in this pass and the
    earlier Settings pass remains uncommitted.
- Currency field keyboard + design fix (uncommitted, verified 2026-11-26):
  `AppPageBody` still used `HitTestBehavior.translucent` and unfocused on every
  `ScrollUpdateNotification`, so tapping the lower rate fields immediately hid
  the keyboard (the register form had already moved to `deferToChild`). It now
  uses `deferToChild` and only unfocuses on a real user drag
  (`ScrollStartNotification.dragDetails != null`), matching `main.dart`. The
  rate fields were redesigned from raw outlined inputs to the themed filled
  fields used by auth: label above, exchange icon, `0.00` hint, `YER` suffix,
  `TextInputAction.done` and no local border override. Added a focused-field
  keyboard regression in `test/settings_screen_test.dart` (stays visible after
  the IME resize, still hides on drag). `flutter analyze` clean,
  `flutter test` 152/152. USB `ZY22G4C24N`: tapping the USD rate showed
  `mInputShown=true` with only `SHOW_SOFT_INPUT` (no `HIDE_SOFT_INPUT`), typing
  `300` committed and produced `Example: ≈ 333 US dollar`, reset restored
  `250.00`/`66.70`, and DTD reported no runtime errors.
- Settings audit + currency/add-style pass (uncommitted, verified 2026-11-26):
  `Settings → Add Property button` is now mutually exclusive — `Outline button
  on Home` (default) shows the outlined CTA on Home and hides the small FAB;
  `FAB above map FAB` shows the compact `add_home_outlined` FAB above the map
  FAB on Home and only in `/map` list view. The currency radio now changes more
  than a label: user-editable USD→YER (default 250) and SAR→YER (default 66.7)
  rates persist, a live `≈` preview is shown, `Reset rates` restores defaults,
  cards/detail show converted browsing prices plus the original stored amount,
  and new listings prefill their currency from the preference. Saved listings,
  contracts, admin/financial records still keep their original currency; no
  live FX is fetched. The About version now uses `l10n.about_version(...)` and
  matches `pubspec.yaml` (`2.4.1+19`). Added "Enable Notifications" helper copy
  and optional in-app confirmations for report submits, copied links and
  offline-map downloads; added a confirmed `Reset all settings` card. The
  `YemenMapScreen` scoped query no longer lets the stored-location default
  overwrite an explicit dashboard governorate such as `صنعاء` (found by the new
  FAB-mode regression). Added `test/currency_rates_test.dart`,
  `test/settings_screen_test.dart`, `test/add_property_style_test.dart`,
  `test/display_price_widget_test.dart`, `test/app_feedback_test.dart` and map
  regressions. `flutter analyze` clean, `flutter test` 151/151. Fresh USB
  `ZY22G4C24N` run + DTD hot reload: verified outline/FAB modes on Home and
  `/map` list (FAB hidden over the map), USD preference + live preview →
  converted card and detail prices → add-form prefill → YER/default reset, and
  `Version: 2.4.1+19`; rate sanitization/persistence is covered by the new
  unit/widget tests. No runtime errors, overflows or new ANR.
- MapLibre + OpenFreeMap migration with offline cache (committed `add0b3f`,
  verified 2026-11-26): street maps now use `MapLibreLayer` (`flutter_map_maplibre`)
  inside the existing `FlutterMap` on `/map`, property detail and the add/edit
  picker, so clusters, polygons, camera animations, gestures and RTL overlays
  are unchanged. Esri World Imagery is retained only for the satellite toggle;
  no Esri street tiles remain. URLs/attribution moved to
  `lib/core/constants/map_sources.dart`; future R2/PMTiles instructions are in
  `docs/MAP_SOURCES.md`. Settings gained an offline-map tile: 100 MB ambient
  cache plus a Yemen z5–10 pack (1,105 tiles / ~9 MB, inside OpenFreeMap's
  3,000-tile and 50 MB offline limits). MapLibre native owns `User-Agent`, so
  requests send `X-Yemen-Real-Estate-Portal` for identification; concurrency is
  plugin-controlled. The offline pack was deleted/re-downloaded on device and
  rendered with Wi-Fi and mobile data disabled. `String.fromEnvironment` for
  Supabase is now `const` (required by Dart 3.13) and the temporary diagnostic
  prints were removed. `flutter analyze` clean, `flutter test` 136/136; USB
  `ZY22G4C24N` verified map clusters/toggle, detail preview, add/edit pin drop,
  Settings download/delete/offline rendering, Arabic locale and DTD
  `No runtime errors found.`
- Map floating header + dashboard count fix (verified 2026-11-26): the top bar
  now uses a frosted M3 surface with semantic tokens, a 48dp filter chip with a
  real ripple, a visually grouped search icon, and an always-visible live result
  chip; selected filters remain removable chips. The dashboard's Featured/For
  sale/For rent header counts no longer use the capped 10-card preview lists:
  `PropertyRepository.getPropertyCount()` backs three new count providers, so
  the headers show the full published total that "View all" opens on the map.
  Added `test/dashboard_category_counts_test.dart` (133/133 tests). USB
  `ZY22G4C24N`: Featured showed 88 on Home and 88 in `/map`; header stayed inside
  bounds in English/light and Arabic/dark, filter sheet opened and closed, and
  DTD reported no runtime errors. `flutter analyze` clean.
- Auth screen redesign (committed 2026-11-26, after `9517a8e`): Login, Register
  and Forgot-password now share `lib/features/auth/presentation/widgets/auth_ui.dart`
  (top-aligned scrollable card, one app-bar title, themed `AuthField`,
  `AuthPrimaryButton`/`AuthSecondaryButton`, `AuthSwitchLink`, semantic
  `AuthInfoBanner`). Removed duplicate in-card titles, fixed long/demo button and
  switch-link overflow with ellipsis/2-line labels, replaced hardcoded amber
  warnings with `AppColors.warningFill`/`warningInk`, and made the sent-state
  reset screen use success tokens. `flutter analyze` clean; `flutter test`
  132/132 (new `test/auth_layout_test.dart`). USB `ZY22G4C24N`: verified Login /
  Register / Forgot in English + Arabic, light + dark, back stack intact, all
  button/link bounds inside the screen, register phone tap kept IME open
  (`mInputShown=true`), no runtime errors and no new ANR. Committed and pushed.
  The unrelated map `BorderRadius` tweak is committed separately.
- Auth back-stack + exit-info placement fix (committed 2026-11-26, after `bfdc870`):
  the exit hint now uses a new `exitInfoSnackBar()` helper with
  `SnackBarBehavior.fixed` and **no margin**, so it sits at the bottom above the
  bottom nav (official Flutter docs define SnackBar as bottom feedback; `floating`
  + margin was lifting it toward the middle). Auth destinations opened from
  inside the app now keep a real stack: drawer CTA, auth-prompt dialog buttons
  (router captured before the dialog pop), desktop rail login CTA, login→forgot
  and register→login use `push`; login↔register switches use `pushReplacement`
  so they do not reverse-endlessly. `appBackPress()` now trusts `nav.canPop()`
  as the stack signal and only applies root/exit policy when there is nothing to
  pop. Post-auth success and `/auth-callback` redirects still use `go`.
  Added `test/app_back_navigation_test.dart` (fixed/no-margin SnackBar + pushed
  auth route pop via native-policy helper).
  - USB `ZY22G4C24N` verified: Home→drawer→Login→Back returned Home (no exit
    hint); drawer→Login→Create account→Back returned Home; Login→Forgot→Back
    returned Login; favorite auth-prompt→Create account→Back returned Home;
    register phone field still opened the IME (`mInputShown=true`). Home single
    back showed the teal hint only at y≈1320–1396 (bottom, above the 1516 nav
    bar), activity stayed resumed; two quick backs returned to the Motorola
    launcher. No runtime errors and no new ANR (latest remains
    `anr_2026-11-25-03-21-45-455`).
  - `flutter analyze` clean; `flutter test` 128/128. Committed and pushed.
- Back-button regression fixed via root `didPopRoute` (uncommitted, after `bfdc870`):
  the native Android back key was destroying the activity again (task fell to the
  Moto launcher / engine disconnect) even though the exit-snackbar flow had been
  verified before. Root cause: `GlobalAppBackHandler`'s `PopScope` is mounted in
  `MaterialApp.router.builder`, i.e. ABOVE the GoRouter `Navigator`, so it never
  registers with a `ModalRoute` and its `canPop: false` veto never applies; the pop
  disposition bubbles up → default → `SystemNavigator.pop()` → activity destroyed.
  Fix: back handling now lives in `_YemenRealEstateAppState.didPopRoute`
  (`WidgetsBindingObserver`, registered ahead of the framework/dispatcher chain) and
  delegates to a new shared top-level `appBackPress()` in `lib/config/app_router.dart`
  (overlay pop / history-back / root-or-auth exit policy: single back → exit snackbar,
  double back → `SystemNavigator.pop()`). `GlobalAppBackHandler._handleBackPress` now
  delegates to the same shared policy; back history + last-back-press timestamp moved to
  top-level `appBackNavigationHistory` / `appLastBackPressTime`.
  - Verified on `ZY22G4C24N` with the fixed build: back key (`adb shell input keyevent 4`)
    on Home (root) → handled, activity stayed resumed (task `t281`), engine pid alive;
    second back within ~1s → app exited properly (resumed activity returned to Moto
    launcher via handled `SystemNavigator.pop`). Previously: back destroyed the activity.
  - `flutter analyze` clean; `flutter test` 125/125; no runtime errors in logs.
- Sign-up / create-account / auth screens fix (committed `ee4903c`, pushed to
  `origin/main`, after `12e1930`): Login, Register and Forgot-password screens
  now render a real localized AppBar title (`login_title` / `register_title` /
  `forgot_title`, Cairo bold 17) instead of a bare `AppLogo` mark, matching the
  app bar pattern of the rest of the app. The register submit button now uses
  explicit theme tokens (`AppColors.primary` bg, `AppColors.textLight` fg,
  StadiumBorder, bold, ellipsis overflow, disabled-while-loading) instead of the
  raw theme default; switch-to-account rows made overflow-safe
  (`Flexible` + centered/ellipsis text) for Arabic strings.
  - Keyboard: verified on `ZY22G4C24N` via `dumpsys input_method` that the
    global tap-outside + scroll unfocus handling (`HitTestBehavior.deferToChild`
    GestureDetector in `lib/main.dart`, ScrollNotification unfocus) keeps the
    IME open when a create-account field is pressed — last check showed
    `mInputShown=true` with only a `SHOW_SOFT_INPUT` event after tapping the
    phone field (no follow-up `HIDE_SOFT_INPUT`). The temporary experiment
    states used during debugging were reverted; `lib/main.dart` is clean
    (no diff).
  - Auth flow: all auth transitions now use `context.go` (root-level) instead of
    `context.push` (stacked): login→register, register→login, drawer login CTA,
    auth prompt dialog actions, login→forgot-password. Back navigation no
    longer reverses the login ↔ create-account chain.
  - Verification: `flutter analyze` clean; `flutter test` 125/125; fresh hot
    reload on the running USB app after the edits, no runtime errors and no new
    ANR (latest remains `anr_2026-11-25-03-21-45-455`).
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