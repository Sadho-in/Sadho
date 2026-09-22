import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/shell/language_provider.dart';
import 'app_localizations.dart';

/// The UI locale: the language chosen in the app (top bar, Profile, or
/// first-launch onboarding), persisted in Hive via [languageProvider] and
/// turned into a real [Locale] here.
///
/// A chosen code with no matching `.arb` file yet (translation not written
/// yet, or a stale/corrupt saved value) falls back to English rather than
/// crashing `MaterialApp`'s locale resolution.
final localeProvider = Provider<Locale>((ref) {
  final code = ref.watch(languageProvider);
  return AppLocalizations.supportedLocales.firstWhere(
    (l) => l.languageCode == code,
    orElse: () => const Locale('en'),
  );
});

/// The app's texts for provider/service code that has a `ref` but no
/// `BuildContext` (a Notifier building a notification, a background message).
final l10nProvider = Provider<AppLocalizations>(
    (ref) => lookupAppLocalizations(ref.watch(localeProvider)));
