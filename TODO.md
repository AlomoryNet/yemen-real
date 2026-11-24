# TODO — Yemen Real Estate Portal

Living roadmap. Update as items are completed. Full change history stays in `AGENTS_HISTORY.md`.

## Next up

- [ ] **Remaining i18n (Option B) — larger migrations**
      - PDF locale policy: `contract_preview_screen.dart` and
        `admin_pdf_service.dart` force RTL (`pw.Directionality`, `MultiPage`,
        `pw.Alignment.centerRight`) even in English mode.
      - Governorate/district display names: `app_constants.dart`, both map
        screens, demo generator, `AppLabelsEn`; fix `supabase_service.dart:125`
        where `nameEn` is a slug (`sanaa_capital`).
      - Contract default clauses/titles in `models/property_contract.dart` are
        bilingual content — needs a data-model decision, not a label migration.
      - Leave as-is: demo property content, model JSON fallbacks, comments,
        log strings, Arabic comma in contract clauses.

- [ ] **Performance quick wins**
      - Cold-start jank on `ZY22G4C24N`: `Choreographer: Skipped 1028 frames`
        during first load (2026-11-24 USB run). Profile startup; likely the
        440-property demo generation plus first-frame/PDF/font work.
      - Slim the four unbounded admin queries: `admin_repository.dart:124`
        `.select()`, `commission_repository.dart:20`, `report_repository.dart:53`,
        `rental_request_repository.dart:123` (all `select('*')`, no `.limit()`).
        Needs coordinated provider + UI + PDF-export changes so a hard cap
        does not silently truncate admin exports — deferred as a unit.
      - `getDashboardStats()` fetches every commission row just to sum it
        (`admin_repository.dart:91–98`) — use an aggregate query.
      - `const` constructor pass; web bundle deferred loading for admin/map.
      - Profile map clustering with `map_cluster_service.dart` for large sets.

- [ ] **Accessibility + loading UX**
      - Remaining low-contrast token: `PropertyTextStyles.badge()` uses
        `textLight` on `accent` amber at 11px (below ideal WCAG).
      - `Semantics` on icon buttons, 48dp tap targets, keyboard focus traversal
        for web/desktop.
      - Skeleton/shimmer loaders instead of spinners on lists and detail.
      - Unify empty/error states via `EmptyStateView` / `ErrorView`.

- [ ] **Flow / product**
      - Deep links + share for property detail (web + app links, OG meta).
      - Saved searches + alerts on new matching listings.
      - Visit/booking scheduling in rental requests.
      - First-run onboarding: location permission + city selection.
      - Offline cache of viewed properties + favorites (Hive).

- [ ] **Quality / DX**
      - More widget tests (filter sheet, pagination, PropertyCard layouts).
      - Golden tests for key screens.
      - CI: `flutter analyze` + `flutter test` on PRs.
      - Production crash reporting (Sentry/Crashlytics).

## Recently completed (2026-11-24)

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
