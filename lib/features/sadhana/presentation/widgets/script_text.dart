import 'package:flutter/material.dart';

import '../../../../l10n/fonts.dart';

/// Text in Devanagari / Gurmukhi / Bengali / Gujarati / Tamil / Telugu /
/// Kannada — a mantra's script or transliteration, in whichever of these it
/// is written, regardless of the app's own UI language. Karla and Fraunces
/// (the app's own fonts) do not carry these glyphs, so the bundled Noto Sans
/// fonts (`assets/fonts/`, declared in pubspec.yaml) are offered as
/// fallbacks, rendering identically on every device rather than depending on
/// whatever the system happens to have. A slightly taller line height keeps
/// matras and vowel signs from clipping.
class ScriptText extends StatelessWidget {
  const ScriptText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Text(
        text,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
        style: (style ?? Theme.of(context).textTheme.titleMedium)?.copyWith(
          height: 1.5,
          fontFamilyFallback: ScriptFonts.all,
        ),
      );
}
