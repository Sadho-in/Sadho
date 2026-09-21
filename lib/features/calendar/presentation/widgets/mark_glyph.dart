import 'package:flutter/material.dart';

import '../../application/mark_style_provider.dart';
import '../../data/calendar_mark.dart';
import 'mark_palette.dart';

/// Draws a marked date in one of the five [MarkStyle]s around [child] (the
/// date number, and an emoji). Each style shows the mark in its own colour
/// WITH a darker outline of that same colour:
///
/// - **dot**: a small filled dot under the date (one per kind of mark)
/// - **filled**: the date on a solid coloured circle
/// - **highlight**: a light tint behind the whole date cell
/// - **circle**: a tinted circle around the date
/// - **square**: a tinted rounded square around the date
class MarkGlyph extends StatelessWidget {
  const MarkGlyph({
    super.key,
    required this.style,
    required this.types,
    required this.child,
    this.dotSize = 8,
  });

  final MarkStyle style;

  /// The kinds of mark on the date, most important first. The shape uses the
  /// first; the Dot style shows one dot per kind.
  final List<MarkType> types;
  final Widget child;
  final double dotSize;

  /// The fill of a shape for [type]: solid for Filled, a light tint otherwise.
  static Color fill(MarkStyle style, MarkType type, Brightness b) {
    final base = MarkPalette.base(type, b);
    return switch (style) {
      MarkStyle.filled => base,
      MarkStyle.highlight => base.withValues(alpha: 0.30),
      MarkStyle.circle || MarkStyle.square => base.withValues(alpha: 0.16),
      MarkStyle.dot => base,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (types.isEmpty) return Center(child: child);
    final b = Theme.of(context).brightness;
    final type = types.first;
    final outline = MarkPalette.outline(type, b);

    if (style == MarkStyle.dot) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final t in types.take(3))
                Container(
                  key: ValueKey('mark-dot-${t.name}'),
                  width: dotSize,
                  height: dotSize,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MarkPalette.base(t, b),
                    border: Border.all(
                      color: MarkPalette.outline(t, b),
                      width: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    }

    final decoration = BoxDecoration(
      color: fill(style, type, b),
      border: Border.all(
        color: outline,
        width: style == MarkStyle.highlight ? 1.2 : 2,
      ),
      shape: style == MarkStyle.circle || style == MarkStyle.filled
          ? BoxShape.circle
          : BoxShape.rectangle,
      borderRadius: switch (style) {
        MarkStyle.highlight => BorderRadius.circular(10),
        MarkStyle.square => BorderRadius.circular(8),
        _ => null,
      },
    );

    return LayoutBuilder(builder: (context, box) {
      final raw = box.biggest.shortestSide;
      final side = (raw.isFinite ? raw : 44.0).clamp(0.0, 44.0).toDouble();
      final full = style == MarkStyle.highlight;
      return Center(
        child: Container(
          key: const ValueKey('mark-shape'),
          width: full ? double.infinity : side,
          height: full ? double.infinity : side,
          decoration: decoration,
          alignment: Alignment.center,
          child: child,
        ),
      );
    });
  }
}
