import 'package:advance_calendar/features/calendar/application/mark_style_provider.dart';
import 'package:advance_calendar/features/calendar/presentation/calendar_screen.dart';
import 'package:advance_calendar/features/calendar/presentation/widgets/mark_day_cell.dart';
import 'package:advance_calendar/features/calendar/presentation/widgets/mark_editor_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';

import 'calendar_support.dart';

/// P4.3-2c: a large text size makes the grid taller and the mark shapes
/// grow; nothing is cut off and no date wraps.
void main() {
  Finder cell(int day) => find.byKey(
      ValueKey('day-2026-09-${day.toString().padLeft(2, '0')}'));
  Finder inCell(int day, Finder f) => find.descendant(of: cell(day), matching: f);

  Future<void> open(WidgetTester tester, double scale,
      {MarkStyle style = MarkStyle.dot}) async {
    phoneScreen(tester, width: 360);
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final c = await calendarContainer(marks: [
      markOn(DateTime(2026, 9, 22), id: 'g', emoji: '🪔'),
    ]);
    c.read(markStyleProvider.notifier).set(style);
    await pumpScreen(tester, c, const CalendarScreen());
  }

  testWidgets('rows are 56 high at the default size and taller at 1.6',
      (tester) async {
    await open(tester, 1.0);
    final normal = tester.getSize(cell(22)).height;
    expect(normal, 56);
    await open(tester, 1.6);
    expect(tester.getSize(cell(22)).height, greaterThan(normal));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a date number stays on one line at 1.6', (tester) async {
    await open(tester, 1.6);
    for (final d in [10, 22, 30]) {
      final text = tester.widget<Text>(inCell(d, find.text('$d')));
      expect(text.maxLines, 1, reason: '$d');
      final para = tester.renderObject<RenderParagraph>(inCell(d, find.text('$d')));
      expect(para.didExceedMaxLines, isFalse, reason: '$d');
    }
  });

  for (final style in [MarkStyle.circle, MarkStyle.filled]) {
    testWidgets('${style.name}: a circle at 1.0, an upright pill at 1.6',
        (tester) async {
      await open(tester, 1.0, style: style);
      final shape = inCell(22, find.byKey(const ValueKey('mark-shape')));
      var d = tester.widget<Container>(shape).decoration! as BoxDecoration;
      expect(d.shape, BoxShape.circle);

      await open(tester, 1.6, style: style);
      d = tester.widget<Container>(shape).decoration! as BoxDecoration;
      final size = tester.getSize(shape);
      expect(d.shape, BoxShape.rectangle);
      expect(d.borderRadius, BorderRadius.circular(size.width / 2));
      expect(size.height, greaterThan(size.width));
      // The number and the emoji are inside the shape.
      final shapeRect = tester.getRect(shape);
      for (final f in [find.text('22'), find.text('🪔')]) {
        final r = tester.getRect(inCell(22, f));
        expect(r.top, greaterThanOrEqualTo(shapeRect.top - 0.5));
        expect(r.bottom, lessThanOrEqualTo(shapeRect.bottom + 0.5));
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('MarkDayCell.rowHeight grows with the text size', (tester) async {
    late BuildContext ctx;
    for (final (scale, check) in [
      (1.0, equals(56.0)),
      (1.6, greaterThan(56.0)),
    ]) {
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: Builder(builder: (c) {
            ctx = c;
            return const SizedBox();
          }),
        ),
      ));
      expect(MarkDayCell.rowHeight(ctx), check, reason: '$scale');
    }
  });

  testWidgets('editor buttons wrap to two lines instead of overflowing',
      (tester) async {
    phoneScreen(tester, width: 360);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final c = await calendarContainer(marks: [
      markOn(DateTime(2026, 9, 22), id: 'g'),
    ]);
    await pumpScreen(tester, c,
        MarkEditorSheet(date: DateTime(2026, 9, 22), markId: 'g'));
    expect(tester.takeException(), isNull);
    final del = tester.getRect(find.byKey(const ValueKey('delete-mark')));
    final save = tester.getRect(find.byKey(const ValueKey('save-mark')));
    // Save stays on the right, level with or under Delete.
    expect(save.right, greaterThanOrEqualTo(del.right));
    expect(save.top, greaterThanOrEqualTo(del.top));
    expect(save.right, lessThanOrEqualTo(360));
  });
}
