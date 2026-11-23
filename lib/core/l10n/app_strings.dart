import '../../l10n/app_localizations.dart';
import 'app_locale.dart';

/// Context-free accessor for localized strings.
///
/// Use this in helpers that have no `BuildContext` (exceptions, validators,
/// repositories, services, models). Widgets should use `context.l10n` instead.
/// The locale mirror is kept in sync from `main.dart` whenever Settings
/// changes the language.
AppLocalizations get tr => lookupAppLocalizations(AppLocale.current);
