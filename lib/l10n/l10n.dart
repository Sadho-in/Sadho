import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

final _english = lookupAppLocalizations(const Locale('en'));

/// The English texts, for pure-Dart code with neither a [BuildContext] nor a
/// `ref` (a default parameter value, a plain function's fallback).
AppLocalizations get englishL10n => _english;

/// `context.l10n.someString`: the app's texts in the current language.
///
/// Falls back to English when no [AppLocalizations] is installed above
/// [context] (a bare widget pumped on its own in a test, an overlay built
/// outside the app's `MaterialApp`) rather than throwing, so a widget that
/// reads `context.l10n` stays usable wherever it is dropped.
extension AppL10n on BuildContext {
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ?? _english;
}
