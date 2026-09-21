import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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

    final number = Text(
      '${day.day}',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: numberColor,
        fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
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
            style: TextStyle(fontSize: 11, height: 1.1, color: numberColor),
          ),
      ],
    );

    final kinds = types.map((t) => t.label.toLowerCase()).join(' and ');
    return Semantics(
      label: '${day.day}'
          '${isToday ? ', today' : ''}'
          '${marks.isEmpty ? '' : ', marked $kinds, ${marks.length} '
              '${marks.length == 1 ? 'mark' : 'marks'}'}',
      button: true,
      excludeSemantics: true,
      child: KeyedSubtree(
        key: ValueKey('day-${dateKey(day)}'),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Stack(
            children: [
              Positioned.fill(
                child: MarkGlyph(style: style, types: types, child: content),
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
