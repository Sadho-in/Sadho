import 'package:flutter/material.dart';

/// Text in Devanagari / Gurmukhi etc. Karla and Fraunces do not carry these
/// glyphs, so the system's Noto fallback fonts render them; a slightly taller
/// line height keeps matras and vowel signs from clipping.
///
/// TODO(later-phase): bundle Noto Sans Devanagari/Gurmukhi so rendering is
/// identical on every device.
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
        style: (style ?? Theme.of(context).textTheme.titleMedium)
            ?.copyWith(height: 1.5),
      );
}
