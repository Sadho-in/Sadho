import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/app_storage.dart';

class AppLanguage {
  const AppLanguage(this.code, this.name, this.nativeName);

  final String code;
  final String name;
  final String nativeName;
}

const appLanguages = [
  AppLanguage('en', 'English', 'English'),
  AppLanguage('hi', 'Hindi', 'हिन्दी'),
  AppLanguage('pa', 'Punjabi', 'ਪੰਜਾਬੀ'),
];

/// Stores the user's preferred UI language.
///
/// TODO(later-phase): wire this into real localisation (flutter_localizations
/// + ARB files). In Phase 1 the choice is only remembered.
class LanguageNotifier extends Notifier<String> {
  @override
  String build() => (AppStorage.settings.get('language') as String?) ?? 'en';

  void set(String code) {
    state = code;
    AppStorage.settings.put('language', code);
  }
}

final languageProvider =
    NotifierProvider<LanguageNotifier, String>(LanguageNotifier.new);
