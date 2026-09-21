import 'package:flutter/material.dart';

import '../../data/calendar_mark.dart';

/// Green / red / amber for Good / Cautious / Neutral.
///
/// Every colour comes with a DARKER outline of the same hue, so a mark stays
/// readable on any style and in both themes (the light and dark bases differ
/// so each stands out on its own background).
class MarkPalette {
  MarkPalette._();

  static Color base(MarkType type, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return switch (type) {
      MarkType.good => dark ? const Color(0xFF66BB6A) : const Color(0xFF43A047),
      MarkType.cautious =>
        dark ? const Color(0xFFEF5350) : const Color(0xFFE53935),
      MarkType.neutral =>
        dark ? const Color(0xFFFFCA28) : const Color(0xFFFFB300),
    };
  }

  /// The same colour, clearly darker.
  static Color outline(MarkType type, Brightness brightness) {
    final hsl = HSLColor.fromColor(base(type, brightness));
    return hsl.withLightness((hsl.lightness * 0.55).clamp(0.0, 1.0)).toColor();
  }

  /// Text/icon colour that reads on [background].
  static Color onColor(Color background) =>
      ThemeData.estimateBrightnessForColor(background) == Brightness.dark
          ? Colors.white
          : const Color(0xFF1B1B1B);

  static IconData icon(MarkType type) => switch (type) {
        MarkType.good => Icons.check_circle_outline,
        MarkType.cautious => Icons.warning_amber_rounded,
        MarkType.neutral => Icons.circle_outlined,
      };
}
