import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sadho's warm devotional palette.
class SadhoColors {
  SadhoColors._();

  static const marigold = Color(0xFFDE8517);
  static const indigo = Color(0xFF4B4691);
  static const parchment = Color(0xFFFBF7F0);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        ColorScheme.fromSeed(
          seedColor: SadhoColors.marigold,
          brightness: Brightness.light,
        ).copyWith(
          primary: SadhoColors.marigold,
          // Marigold is too light for white text (~2.7:1); use deep brown.
          onPrimary: const Color(0xFF2A1600),
          primaryContainer: const Color(0xFFFFDDB2),
          onPrimaryContainer: const Color(0xFF2A1600),
          secondary: SadhoColors.indigo,
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFE3DFFF),
          onSecondaryContainer: const Color(0xFF14104A),
          surface: SadhoColors.parchment,
          onSurface: const Color(0xFF2B2118),
          surfaceContainerLowest: const Color(0xFFFFFFFF),
          surfaceContainerLow: const Color(0xFFF7F1E6),
          surfaceContainer: const Color(0xFFF3EBDD),
          surfaceContainerHigh: const Color(0xFFEDE4D3),
          surfaceContainerHighest: const Color(0xFFE7DDCA),
        ),
      );

  static ThemeData get dark => _build(
        ColorScheme.fromSeed(
          seedColor: SadhoColors.marigold,
          brightness: Brightness.dark,
        ).copyWith(
          primary: SadhoColors.marigold,
          onPrimary: const Color(0xFF2A1600),
          primaryContainer: const Color(0xFF6B3F00),
          onPrimaryContainer: const Color(0xFFFFDDB2),
          // Deep indigo is too dim on a dark ground, so the accent is lifted
          // and the brand indigo becomes the container.
          secondary: const Color(0xFFC3BEFF),
          onSecondary: const Color(0xFF14104A),
          secondaryContainer: SadhoColors.indigo,
          onSecondaryContainer: const Color(0xFFE3DFFF),
          surface: const Color(0xFF17130F),
          onSurface: const Color(0xFFF1E9DC),
          surfaceContainerLowest: const Color(0xFF110E0B),
          surfaceContainerLow: const Color(0xFF1E1913),
          surfaceContainer: const Color(0xFF241E17),
          surfaceContainerHigh: const Color(0xFF2E271F),
          surfaceContainerHighest: const Color(0xFF393127),
        ),
      );

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
