/// Bundled Noto Sans families, one per non-Latin script the app supports (see
/// `pubspec.yaml` for the font files under `assets/fonts/`). Karla and
/// Fraunces (the app's own fonts, from Google Fonts) only carry Latin, so
/// these are added as fallbacks wherever a script other than Latin can appear
/// — the UI text of a non-English language, or a mantra's script/
/// transliteration in any language.
class ScriptFonts {
  ScriptFonts._();

  static const devanagari = 'NotoSansDevanagari'; // Hindi, Marathi
  static const gurmukhi = 'NotoSansGurmukhi'; // Punjabi
  static const bengali = 'NotoSansBengali';
  static const gujarati = 'NotoSansGujarati';
  static const tamil = 'NotoSansTamil';
  static const telugu = 'NotoSansTelugu';
  static const kannada = 'NotoSansKannada';

  /// Every bundled family, most-common-in-this-app first. A mantra's script
  /// can be in any of these regardless of the UI language, so text that
  /// renders scripture (`ScriptText`) always offers the lot as fallbacks.
  static const all = [
    devanagari,
    gurmukhi,
    bengali,
    gujarati,
    tamil,
    telugu,
    kannada,
  ];

  /// The family for UI text in [languageCode], or null for a Latin-script
  /// language (English) that needs no fallback beyond the app's own fonts.
  static String? forLanguage(String languageCode) => switch (languageCode) {
        'hi' || 'mr' => devanagari,
        'pa' => gurmukhi,
        'bn' => bengali,
        'gu' => gujarati,
        'ta' => tamil,
        'te' => telugu,
        'kn' => kannada,
        _ => null,
      };
}
