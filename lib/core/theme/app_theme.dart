import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  /// The theme for [palette] in [brightness].
  static ThemeData build(SadhoPalette palette, Brightness brightness) =>
      _build(colorScheme(palette, brightness));

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

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
    );
    final text = _textTheme(base.textTheme);

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

  /// Fraunces for display/headline/large titles, Karla for everything else.
  static TextTheme _textTheme(TextTheme base) {
    final body = GoogleFonts.karlaTextTheme(base);
    final heading = GoogleFonts.frauncesTextTheme(base);
    return body.copyWith(
      displayLarge: heading.displayLarge,
      displayMedium: heading.displayMedium,
      displaySmall: heading.displaySmall,
      headlineLarge: heading.headlineLarge,
      headlineMedium: heading.headlineMedium,
      headlineSmall: heading.headlineSmall,
      titleLarge: heading.titleLarge,
    );
  }
}
