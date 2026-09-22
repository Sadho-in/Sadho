import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/fonts.dart';
import 'palettes.dart';

/// Sadho's warm devotional palette.
class SadhoColors {
  SadhoColors._();

  static const marigold = Color(0xFFDE8517);
  static const indigo = Color(0xFF4B4691);
  static const parchment = Color(0xFFFBF7F0);
}

class AppTheme {
  AppTheme._();

  /// The default (Marigold) themes.
  static ThemeData get light => build(defaultPalette, Brightness.light);
  static ThemeData get dark => build(defaultPalette, Brightness.dark);

  /// The theme for [palette] in [brightness]. [languageCode] (e.g. 'hi',
  /// 'pa') adds that language's bundled Noto font as a fallback throughout
  /// the UI text, so a translated interface renders its own script instead of
  /// tofu boxes or an inconsistent system font. Omit it (or pass 'en', or an
  /// unrecognised code) for the plain Latin theme.
  static ThemeData build(
    SadhoPalette palette,
    Brightness brightness, [
    String? languageCode,
  ]) =>
      _build(colorScheme(palette, brightness), languageCode);

  /// Just the colours (no fonts), for palette previews and tests.
  static ColorScheme colorScheme(SadhoPalette palette, Brightness brightness) {
    final c = palette.colors(brightness);
    return ColorScheme.fromSeed(
      seedColor: palette.light.primary,
      brightness: brightness,
    ).copyWith(
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primaryContainer,
      onPrimaryContainer: c.onPrimaryContainer,
      secondary: c.secondary,
      onSecondary: c.onSecondary,
      secondaryContainer: c.secondaryContainer,
      onSecondaryContainer: c.onSecondaryContainer,
      surface: c.surface,
      onSurface: c.onSurface,
      surfaceContainerLowest: c.surfaceContainerLowest,
      surfaceContainerLow: c.surfaceContainerLow,
      surfaceContainer: c.surfaceContainer,
      surfaceContainerHigh: c.surfaceContainerHigh,
      surfaceContainerHighest: c.surfaceContainerHighest,
    );
  }

  static ThemeData _build(ColorScheme scheme, String? languageCode) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
    );
    final text = _textTheme(base.textTheme, languageCode);

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  /// Fraunces for display/headline/large titles, Karla for everything else —
  /// each with [languageCode]'s bundled Noto font (if any) added as a
  /// fallback, so every style keeps rendering that language's script.
  static TextTheme _textTheme(TextTheme base, String? languageCode) {
    final body = GoogleFonts.karlaTextTheme(base);
    final heading = GoogleFonts.frauncesTextTheme(base);
    final noto = languageCode == null ? null : ScriptFonts.forLanguage(languageCode);
    return _withFallback(
      body.copyWith(
        displayLarge: heading.displayLarge,
        displayMedium: heading.displayMedium,
        displaySmall: heading.displaySmall,
        headlineLarge: heading.headlineLarge,
        headlineMedium: heading.headlineMedium,
        headlineSmall: heading.headlineSmall,
        titleLarge: heading.titleLarge,
      ),
      noto,
    );
  }

  /// Adds [family] to every style's fallback list (after whatever is already
  /// there), or returns [theme] unchanged if [family] is null.
  static TextTheme _withFallback(TextTheme theme, String? family) {
    if (family == null) return theme;
    TextStyle? add(TextStyle? s) =>
        s?.copyWith(fontFamilyFallback: [...?s.fontFamilyFallback, family]);
    return TextTheme(
      displayLarge: add(theme.displayLarge),
      displayMedium: add(theme.displayMedium),
      displaySmall: add(theme.displaySmall),
      headlineLarge: add(theme.headlineLarge),
      headlineMedium: add(theme.headlineMedium),
      headlineSmall: add(theme.headlineSmall),
      titleLarge: add(theme.titleLarge),
      titleMedium: add(theme.titleMedium),
      titleSmall: add(theme.titleSmall),
      bodyLarge: add(theme.bodyLarge),
      bodyMedium: add(theme.bodyMedium),
      bodySmall: add(theme.bodySmall),
      labelLarge: add(theme.labelLarge),
      labelMedium: add(theme.labelMedium),
      labelSmall: add(theme.labelSmall),
    );
  }
}
