import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../../shell/language_provider.dart';

/// Whether the first-launch language + tradition screen has been completed.
/// Saved in Hive, so it is asked again only when the phone's data is cleared
/// (Profile's "Delete account", which wipes every box including this key).
class OnboardingNotifier extends Notifier<bool> {
  static const _key = 'onboarding.done';

  @override
  bool build() => AppStorage.settings.get(_key) == true;

  void complete() {
    state = true;
    AppStorage.settings.put(_key, true);
  }
}

/// The first-launch privacy / terms notice (under Continue): when it was
/// first shown and when the user continued past it (ms since the epoch), kept
/// in Hive as a record of the notice.
abstract final class LegalNotice {
  static const shownAtKey = 'legal.noticeShownAt';
  static const acceptedAtKey = 'legal.noticeAcceptedAt';

  /// Records the first time the notice was shown (later showings keep it).
  static void markShown(DateTime now) {
    if (AppStorage.settings.get(shownAtKey) is int) return;
    AppStorage.settings.put(shownAtKey, now.millisecondsSinceEpoch);
  }

  static void markAccepted(DateTime now) =>
      AppStorage.settings.put(acceptedAtKey, now.millisecondsSinceEpoch);

  static DateTime? _at(String key) {
    final v = AppStorage.settings.get(key);
    return v is int ? DateTime.fromMillisecondsSinceEpoch(v) : null;
  }

  static DateTime? get shownAt => _at(shownAtKey);
  static DateTime? get acceptedAt => _at(acceptedAtKey);
}

final onboardingCompleteProvider =
    NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

/// The phone's own locale, read once at startup. A seam so tests can choose
/// what "the phone's language" is without changing the OS.
final devicePlatformLocaleProvider =
    Provider<Locale>((ref) => WidgetsBinding.instance.platformDispatcher.locale);

/// The language to preselect on first launch: [locale]'s language if it is
/// one of the nine Sadho supports, English otherwise.
String initialLanguageCode(Locale locale) => appLanguages
    .firstWhere((l) => l.code == locale.languageCode, orElse: () => appLanguages.first)
    .code;
