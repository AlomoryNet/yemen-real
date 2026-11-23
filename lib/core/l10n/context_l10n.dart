import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Convenience accessor for the generated [AppLocalizations].
///
/// Usage in widgets: `context.l10n.some_key`. Arabic is the default locale;
/// English is selected from Settings. All user-visible copy must go through
/// this accessor (or `AppLocalizations.of(context)!`) so language changes take
/// effect at runtime.
extension AppL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
