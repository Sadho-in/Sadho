import 'package:flutter/material.dart';

/// The colours of one palette in one brightness. Every role the app's
/// components use is spelled out, so a palette is fully predictable (and its
/// contrast can be tested).
class PaletteColors {
  const PaletteColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.surface,
    required this.onSurface,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    this.onSurfaceVariant,
    this.outline,
    this.outlineVariant,
    this.error,
    this.onError,
    this.errorContainer,
    this.onErrorContainer,
    this.tertiary,
    this.onTertiary,
    this.tertiaryContainer,
    this.onTertiaryContainer,
    this.inverseSurface,
    this.onInverseSurface,
    this.inversePrimary,
  });

  final Color primary, onPrimary, primaryContainer, onPrimaryContainer;
  final Color secondary, onSecondary, secondaryContainer, onSecondaryContainer;
  final Color surface, onSurface;
  final Color surfaceContainerLowest,
      surfaceContainerLow,
      surfaceContainer,
      surfaceContainerHigh,
      surfaceContainerHighest;

  /// The remaining roles (secondary text, borders, errors, snackbars...).
  /// Null takes Material's colour for the palette; the High contrast palette
  /// sets every one, so all of its text and controls are pinned down.
  final Color? onSurfaceVariant, outline, outlineVariant;
  final Color? error, onError, errorContainer, onErrorContainer;
  final Color? tertiary, onTertiary, tertiaryContainer, onTertiaryContainer;
  final Color? inverseSurface, onInverseSurface, inversePrimary;
}

/// A soothing colour theme the user can choose in Profile.
class SadhoPalette {
  const SadhoPalette({
    required this.id,
    required this.name,
    required this.blurb,
    required this.light,
    required this.dark,
  });

  /// Stable id saved in Hive.
  final String id;
  final String name;
  final String blurb;
  final PaletteColors light;
  final PaletteColors dark;

  PaletteColors colors(Brightness b) => b == Brightness.dark ? dark : light;

  /// The two colours shown on the picker's swatch.
  Color get swatchPrimary => light.primary;
  Color get swatchSecondary => light.secondary;
}

// ---- colour maths --------------------------------------------------------

/// WCAG contrast ratio between two colours (1 to 21).
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

Color _hsl(double hue, double sat, double light) =>
    HSLColor.fromAHSL(1, hue % 360, sat.clamp(0.0, 1.0), light.clamp(0.0, 1.0))
        .toColor();

/// White or near-black text, whichever reads better on [bg].
Color _onColor(Color bg) {
  const dark = Color(0xFF1B140C);
  return contrastRatio(bg, Colors.white) >= contrastRatio(bg, dark)
      ? Colors.white
      : dark;
}

/// Builds a palette from a hue and two brand colours (each given for light and
/// dark mode). Surfaces are tinted with the hue: warm and paper-like in light
/// mode, deep and low-glare in dark mode.
SadhoPalette _derive({
  required String id,
  required String name,
  required String blurb,
  required double hue,
  required Color primaryLight,
  required Color primaryDark,
  required Color accentLight,
  required Color accentDark,
}) {
  PaletteColors light() {
    final onPc = _hsl(HSLColor.fromColor(primaryLight).hue, 0.55, 0.13);
    final onSc = _hsl(HSLColor.fromColor(accentLight).hue, 0.5, 0.14);
    return PaletteColors(
      primary: primaryLight,
      onPrimary: _onColor(primaryLight),
      primaryContainer: _mix(primaryLight, Colors.white, 0.78),
      onPrimaryContainer: onPc,
      secondary: accentLight,
      onSecondary: _onColor(accentLight),
      secondaryContainer: _mix(accentLight, Colors.white, 0.82),
      onSecondaryContainer: onSc,
      surface: _hsl(hue, 0.38, 0.965),
      onSurface: _hsl(hue, 0.30, 0.13),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: _hsl(hue, 0.36, 0.945),
      surfaceContainer: _hsl(hue, 0.34, 0.925),
      surfaceContainerHigh: _hsl(hue, 0.32, 0.90),
      surfaceContainerHighest: _hsl(hue, 0.30, 0.875),
    );
  }

  PaletteColors dark() => PaletteColors(
        primary: primaryDark,
        onPrimary: _onColor(primaryDark),
        primaryContainer: _mix(primaryDark, Colors.black, 0.62),
        onPrimaryContainer: _mix(primaryDark, Colors.white, 0.72),
        secondary: accentDark,
        onSecondary: _onColor(accentDark),
        secondaryContainer: _mix(accentDark, Colors.black, 0.6),
        onSecondaryContainer: _mix(accentDark, Colors.white, 0.75),
        surface: _hsl(hue, 0.18, 0.075),
        onSurface: _hsl(hue, 0.25, 0.92),
        surfaceContainerLowest: _hsl(hue, 0.18, 0.05),
        surfaceContainerLow: _hsl(hue, 0.18, 0.10),
        surfaceContainer: _hsl(hue, 0.18, 0.125),
        surfaceContainerHigh: _hsl(hue, 0.17, 0.155),
        surfaceContainerHighest: _hsl(hue, 0.16, 0.19),
      );

  return SadhoPalette(
    id: id,
    name: name,
    blurb: blurb,
    light: light(),
    dark: dark(),
  );
}

// ---- the palettes --------------------------------------------------------

/// Marigold: Sadho's original marigold and indigo on warm parchment. These are
/// the exact colours the app has always used.
final _marigold = SadhoPalette(
  id: 'marigold',
  name: 'Marigold',
  blurb: 'Warm saffron and deep indigo',
  light: const PaletteColors(
    primary: Color(0xFFDE8517),
    // Marigold is too light for white text (~2.7:1); use deep brown.
    onPrimary: Color(0xFF2A1600),
    primaryContainer: Color(0xFFFFDDB2),
    onPrimaryContainer: Color(0xFF2A1600),
    secondary: Color(0xFF4B4691),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE3DFFF),
    onSecondaryContainer: Color(0xFF14104A),
    surface: Color(0xFFFBF7F0),
    onSurface: Color(0xFF2B2118),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF7F1E6),
    surfaceContainer: Color(0xFFF3EBDD),
    surfaceContainerHigh: Color(0xFFEDE4D3),
    surfaceContainerHighest: Color(0xFFE7DDCA),
  ),
  dark: const PaletteColors(
    primary: Color(0xFFDE8517),
    onPrimary: Color(0xFF2A1600),
    primaryContainer: Color(0xFF6B3F00),
    onPrimaryContainer: Color(0xFFFFDDB2),
    // Deep indigo is too dim on a dark ground, so the accent is lifted and the
    // brand indigo becomes the container.
    secondary: Color(0xFFC3BEFF),
    onSecondary: Color(0xFF14104A),
    secondaryContainer: Color(0xFF4B4691),
    onSecondaryContainer: Color(0xFFE3DFFF),
    surface: Color(0xFF17130F),
    onSurface: Color(0xFFF1E9DC),
    surfaceContainerLowest: Color(0xFF110E0B),
    surfaceContainerLow: Color(0xFF1E1913),
    surfaceContainer: Color(0xFF241E17),
    surfaceContainerHigh: Color(0xFF2E271F),
    surfaceContainerHighest: Color(0xFF393127),
  ),
);

final _sandalwood = _derive(
  id: 'sandalwood',
  name: 'Sandalwood',
  blurb: 'Soft sandal brown and clay',
  hue: 32,
  primaryLight: const Color(0xFF8A6238),
  primaryDark: const Color(0xFFD9B48A),
  accentLight: const Color(0xFF9A4A3A),
  accentDark: const Color(0xFFEBB3A4),
);

final _tulsi = _derive(
  id: 'tulsi',
  name: 'Tulsi green',
  blurb: 'Calm holy-basil green',
  hue: 130,
  primaryLight: const Color(0xFF2F7A4B),
  primaryDark: const Color(0xFF8FD4A4),
  accentLight: const Color(0xFF8A6A1C),
  accentDark: const Color(0xFFE6C874),
);

final _twilight = _derive(
  id: 'twilight',
  name: 'Twilight indigo',
  blurb: 'Dusk indigo with a lamp-glow gold',
  hue: 245,
  primaryLight: const Color(0xFF4B4691),
  primaryDark: const Color(0xFFB9B4F5),
  accentLight: const Color(0xFF8F5B0B),
  accentDark: const Color(0xFFF0C27B),
);

final _lotus = _derive(
  id: 'lotus',
  name: 'Lotus rose',
  blurb: 'Gentle lotus pink and leaf green',
  hue: 340,
  primaryLight: const Color(0xFFB0446A),
  primaryDark: const Color(0xFFF2A5BE),
  accentLight: const Color(0xFF3F7A5C),
  accentDark: const Color(0xFF9ADAB8),
);

/// High contrast: black on white (white on black in dark mode) with deep
/// accents. Every text colour is at least 7:1 on every surface it sits on
/// (WCAG AAA) and every control at least 3:1.
const _highContrast = SadhoPalette(
  id: 'highContrast',
  name: 'High contrast',
  blurb: 'Strongest contrast, for easy reading',
  light: PaletteColors(
    primary: Color(0xFF003A8C),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD8E6FF),
    onPrimaryContainer: Color(0xFF001533),
    secondary: Color(0xFF6B2E00),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFE3CF),
    onSecondaryContainer: Color(0xFF2A1000),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF000000),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF7F7F7),
    surfaceContainer: Color(0xFFF0F0F0),
    surfaceContainerHigh: Color(0xFFE8E8E8),
    surfaceContainerHighest: Color(0xFFE0E0E0),
    onSurfaceVariant: Color(0xFF1F1F1F),
    outline: Color(0xFF262626),
    outlineVariant: Color(0xFF595959),
    error: Color(0xFF8C0009),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    tertiary: Color(0xFF005226),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFC8F2D5),
    onTertiaryContainer: Color(0xFF00210C),
    inverseSurface: Color(0xFF121212),
    onInverseSurface: Color(0xFFFFFFFF),
    inversePrimary: Color(0xFFB5D0FF),
  ),
  dark: PaletteColors(
    primary: Color(0xFFA8C8FF),
    onPrimary: Color(0xFF000000),
    primaryContainer: Color(0xFF0B2E66),
    onPrimaryContainer: Color(0xFFFFFFFF),
    secondary: Color(0xFFFFC999),
    onSecondary: Color(0xFF000000),
    secondaryContainer: Color(0xFF5A2A00),
    onSecondaryContainer: Color(0xFFFFFFFF),
    surface: Color(0xFF000000),
    onSurface: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFF000000),
    surfaceContainerLow: Color(0xFF0D0D0D),
    surfaceContainer: Color(0xFF141414),
    surfaceContainerHigh: Color(0xFF1C1C1C),
    surfaceContainerHighest: Color(0xFF262626),
    onSurfaceVariant: Color(0xFFE6E6E6),
    outline: Color(0xFFE0E0E0),
    outlineVariant: Color(0xFFA6A6A6),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF000000),
    errorContainer: Color(0xFF8C0009),
    onErrorContainer: Color(0xFFFFFFFF),
    tertiary: Color(0xFF8EE6AE),
    onTertiary: Color(0xFF000000),
    tertiaryContainer: Color(0xFF004D22),
    onTertiaryContainer: Color(0xFFFFFFFF),
    inverseSurface: Color(0xFFF2F2F2),
    onInverseSurface: Color(0xFF000000),
    inversePrimary: Color(0xFF003A8C),
  ),
);

/// All palettes, the default first.
final sadhoPalettes = <SadhoPalette>[
  _marigold,
  _sandalwood,
  _tulsi,
  _twilight,
  _lotus,
  _highContrast,
];

SadhoPalette get defaultPalette => sadhoPalettes.first;

/// The palette with [id], or the default for an unknown / missing id.
SadhoPalette paletteById(Object? id) => sadhoPalettes.firstWhere(
      (p) => p.id == id,
      orElse: () => defaultPalette,
    );
