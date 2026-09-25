import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../../../l10n/labels.dart';
import '../../application/mark_style_provider.dart';
import '../../data/calendar_mark.dart';
import 'mark_glyph.dart';
import 'mark_palette.dart';

/// One date on the month grid: the number, the mark drawn in the chosen
/// [MarkStyle], the emoji of the mark, and the today indicator.
///
/// Today is shown SEPARATELY from marks: a bold number and a small accent dot
/// in the corner (the theme's indigo/lavender accent, which is never green,
/// red or amber), so it never clashes with a mark colour.
class MarkDayCell extends StatelessWidget {
  const MarkDayCell({
    super.key,
    required this.day,
    required this.marks,
    required this.style,
    required this.isToday,
  });

  final DateTime day;

  /// The marks on this date, most severe first.
  final List<CalendarMark> marks;
  final MarkStyle style;
  final bool isToday;

  static const _emojiStyle = TextStyle(fontSize: 11, height: 1.1);

  /// How tall the date number and an emoji under it are at the current text
  /// size (measured with the real styles, so a large text size makes the
  /// grid rows and the mark shapes grow instead of overflowing).
  static double contentHeight(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    double measure(String text, TextStyle? style) {
      final p = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      final h = p.height;
      p.dispose();
      return h;
    }

    return measure('30', Theme.of(context).textTheme.bodyMedium) +
        measure('🪔', _emojiStyle);
  }

  /// The month grid's row height: the usual 56, or more when the text size
  /// needs it (room for the number, the emoji, the Dot style's dots and the
  /// cell padding).
  static double rowHeight(BuildContext context) =>
      math.max(56, contentHeight(context) + 16);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;
    final types = <MarkType>[
      for (final m in marks)
        if (!marks.sublist(0, marks.indexOf(m)).any((o) => o.type == m.type)) m.type,
    ];
    final emoji = marks.map((m) => m.emoji).whereType<String>().firstOrNull;
    // Text sits on a solid colour only in the Filled style.
    final onFilled = style == MarkStyle.filled && types.isNotEmpty;
    final numberColor = onFilled
        ? MarkPalette.onColor(MarkPalette.base(types.first, theme.brightness))
        : scheme.onSurface;

    // A date is one line: it never wraps into two in a narrow (one
    // seventh of the width) cell, and only scales down if it could not fit
    // at all (not before a very large text size).
    final number = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        '${day.day}',
        maxLines: 1,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: numberColor,
          fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    );
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        number,
        if (emoji != null)
          Text(
            emoji,
            style: _emojiStyle.copyWith(color: numberColor),
          ),
      ],
    );

    final kinds =
        types.map((t) => t.localized(l).toLowerCase()).join(' ${l.dayCellAnd} ');
    return Semantics(
      label: '${day.day}'
          '${isToday ? l.dayCellToday : ''}'
          '${marks.isEmpty ? '' : l.dayCellMarkedSuffix(marks.length, kinds)}',
      button: true,
      excludeSemantics: true,
      child: KeyedSubtree(
        key: ValueKey('day-${dateKey(day)}'),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Stack(
            children: [
              Positioned.fill(
                child: MarkGlyph(
                  style: style,
                  types: types,
                  contentHeight: contentHeight(context),
                  child: content,
                ),
              ),
              if (isToday)
                Positioned(
                  top: 2,
                  right: 4,
                  child: Container(
                    key: const ValueKey('today-dot'),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: scheme.secondary,
                      shape: BoxShape.circle,
                      // A ring in the ground colour keeps it distinct when it
                      // overlaps a mark's shape.
                      border: Border.all(color: scheme.surface, width: 1.2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
