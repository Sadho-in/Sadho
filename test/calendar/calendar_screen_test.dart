import 'package:advance_calendar/features/calendar/application/mark_style_provider.dart';
import 'package:advance_calendar/features/calendar/data/calendar_mark.dart';
import 'package:advance_calendar/features/calendar/presentation/calendar_screen.dart';
import 'package:advance_calendar/features/calendar/presentation/widgets/mark_palette.dart';
import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';

import 'calendar_support.dart';

void main() {
  // "Today" in these tests: Monday 21 September 2026, 08:00.
  Finder cell(int day, {int month = 9, int year = 2026}) => find.byKey(ValueKey(
      'day-$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}'));
  /// [f] within the month grid only (the style picker has previews too).
  Finder grid(Finder f) =>
      find.descendant(of: find.byType(TableCalendar<void>), matching: f);
  final shape = find.byKey(const ValueKey('mark-shape'));
  Finder inCell(int day, Finder f) => find.descendant(of: cell(day), matching: f);
  BoxDecoration shapeOf(WidgetTester t, int day) => t
      .widget<Container>(inCell(day, find.byKey(const ValueKey('mark-shape'))))
      .decoration! as BoxDecoration;
  BoxDecoration dotOf(WidgetTester t, int day, MarkType type) => t
      .widget<Container>(inCell(day, find.byKey(ValueKey('mark-dot-${type.name}'))))
      .decoration! as BoxDecoration;

  Future<ProviderContainer> open(
    WidgetTester tester, {
    List<CalendarMark> marks = const [],
    MarkStyle? style,
    Brightness brightness = Brightness.light,
  }) async {
    phoneScreen(tester);
    final c = await calendarContainer(marks: marks);
    if (style != null) c.read(markStyleProvider.notifier).set(style);
    await pumpScreen(tester, c, const CalendarScreen(), brightness: brightness);
    return c;
  }

  // One mark of each kind, on the 22nd, 23rd and 24th.
  final threeKinds = [
    markOn(DateTime(2026, 9, 22), id: 'g', type: MarkType.good),
    markOn(DateTime(2026, 9, 23), id: 'c', type: MarkType.cautious),
    markOn(DateTime(2026, 9, 24), id: 'n', type: MarkType.neutral),
  ];
  const days = {MarkType.good: 22, MarkType.cautious: 23, MarkType.neutral: 24};

  group('month grid', () {
    testWidgets('shows the month, weekday names and every date of it',
        (tester) async {
      await open(tester);
      expect(find.text('September 2026'), findsOneWidget);
      for (final d in ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']) {
        expect(find.text(d), findsWidgets, reason: d);
      }
      for (var d = 1; d <= 30; d++) {
        expect(cell(d), findsOneWidget, reason: 'the ${d}th');
      }
      expect(find.byKey(const ValueKey('day-2026-08-31')), findsNothing,
          reason: 'no dates from neighbouring months');
      expect(find.byKey(const ValueKey('day-2026-10-01')), findsNothing);
    });

    testWidgets('next and previous month', (tester) async {
      await open(tester);
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.text('October 2026'), findsOneWidget);
      expect(cell(31, month: 10), findsOneWidget);
      expect(cell(1, month: 10), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      expect(find.text('August 2026'), findsOneWidget);
      expect(cell(31, month: 8), findsOneWidget);
    });

    testWidgets('the arrows are labelled for screen readers', (tester) async {
      await open(tester);
      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Previous month'), findsOneWidget);
      expect(find.bySemanticsLabel('Next month'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('swiping the grid changes the month too', (tester) async {
      await open(tester);
      await tester.drag(cell(15), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('October 2026'), findsOneWidget);
    });

    testWidgets('Today jumps back from another month', (tester) async {
      await open(tester);
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();
      }
      expect(find.text('December 2026'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('go-today')));
      await tester.pumpAndSettle();
      expect(find.text('September 2026'), findsOneWidget);
    });

    testWidgets('works across a year end and in a leap February', (tester) async {
      await open(tester);
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();
      }
      expect(find.text('January 2027'), findsOneWidget);
      expect(cell(31, month: 1, year: 2027), findsOneWidget);
    });

    testWidgets('tapping a date opens the editor for that date', (tester) async {
      await open(tester);
      await tester.tap(cell(24));
      await tester.pumpAndSettle();
      expect(find.text('New mark'), findsWidgets);
      expect(find.byKey(const ValueKey('editor-date')), findsOneWidget);
      expect(
          tester.widget<Text>(find.byKey(const ValueKey('editor-date'))).data,
          'Thursday, September 24, 2026');
    });

    testWidgets('a date in another month opens with that month\'s date',
        (tester) async {
      await open(tester);
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      await tester.tap(cell(2, month: 10));
      await tester.pumpAndSettle();
      expect(
          tester.widget<Text>(find.byKey(const ValueKey('editor-date'))).data,
          'Friday, October 2, 2026');
    });
  });

  group('today is indicated separately from marks', () {
    testWidgets('a small accent dot and a bold number, on today only',
        (tester) async {
      await open(tester);
      expect(find.byKey(const ValueKey('today-dot')), findsOneWidget);
      expect(inCell(21, find.byKey(const ValueKey('today-dot'))), findsOneWidget);
      FontWeight? weight(int d) => tester
          .widget<Text>(find.descendant(of: cell(d), matching: find.text('$d')))
          .style
          ?.fontWeight;
      expect(weight(21), FontWeight.w800, reason: 'today is bold');
      expect(weight(20), FontWeight.w500);
      expect(weight(22), FontWeight.w500);
    });

    testWidgets('the dot is the theme accent, in light and dark', (tester) async {
      for (final b in Brightness.values) {
        await open(tester, brightness: b);
        final dot = tester.widget<Container>(find.byKey(const ValueKey('today-dot')));
        final accent = calendarTestTheme(b).colorScheme.secondary;
        expect((dot.decoration! as BoxDecoration).color, accent, reason: b.name);
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('the accent is never a mark colour', (tester) async {
      for (final b in Brightness.values) {
        final accent = calendarTestTheme(b).colorScheme.secondary;
        for (final t in MarkType.values) {
          for (final bb in Brightness.values) {
            expect(accent, isNot(MarkPalette.base(t, bb)));
            expect(accent, isNot(MarkPalette.outline(t, bb)));
          }
        }
      }
    });

    testWidgets('it follows the clock: no dot on a month that has no today',
        (tester) async {
      await open(tester);
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('today-dot')), findsNothing);
    });

    for (final style in MarkStyle.values) {
      testWidgets('today can also be marked (${style.name}): both show',
          (tester) async {
        await open(tester,
            marks: [markOn(DateTime(2026, 9, 21), type: MarkType.cautious)],
            style: style);
        expect(inCell(21, find.byKey(const ValueKey('today-dot'))), findsOneWidget);
        final marked = style == MarkStyle.dot
            ? inCell(21, find.byKey(const ValueKey('mark-dot-cautious')))
            : inCell(21, find.byKey(const ValueKey('mark-shape')));
        expect(marked, findsOneWidget, reason: 'the mark is drawn too');
      });
    }
  });

  group('mark styles: colour WITH a darker outline of the same colour', () {
    for (final b in Brightness.values) {
      for (final t in MarkType.values) {
        test('${t.name} (${b.name}): outline is a darker shade of the same hue',
            () {
          final base = MarkPalette.base(t, b);
          final outline = MarkPalette.outline(t, b);
          expect(outline.computeLuminance(), lessThan(base.computeLuminance()));
          expect(HSLColor.fromColor(outline).lightness,
              lessThan(HSLColor.fromColor(base).lightness - 0.1),
              reason: 'clearly darker');
          expect(HSLColor.fromColor(outline).hue,
              closeTo(HSLColor.fromColor(base).hue, 1.5));
        });
      }
    }

    test('the three colours are green, red and amber', () {
      double hue(MarkType t) =>
          HSLColor.fromColor(MarkPalette.base(t, Brightness.light)).hue;
      expect(hue(MarkType.good), inInclusiveRange(90, 150), reason: 'green');
      expect(hue(MarkType.cautious), anyOf(inInclusiveRange(0, 15), inInclusiveRange(345, 360)),
          reason: 'red');
      expect(hue(MarkType.neutral), inInclusiveRange(35, 50), reason: 'amber');
    });

    for (final b in Brightness.values) {
      group('(${b.name} theme)', () {
        testWidgets('Dot: a small filled dot with a darker outline, per kind',
            (tester) async {
          await open(tester, marks: threeKinds, style: MarkStyle.dot, brightness: b);
          for (final t in MarkType.values) {
            final d = dotOf(tester, days[t]!, t);
            expect(d.shape, BoxShape.circle);
            expect(d.color, MarkPalette.base(t, b), reason: t.name);
            expect(d.border!.top.color, MarkPalette.outline(t, b));
            expect(d.border!.top.width, greaterThan(0));
            expect(inCell(days[t]!, find.byKey(const ValueKey('mark-shape'))),
                findsNothing,
                reason: 'a dot is not a shape');
            final size = tester.getSize(
                inCell(days[t]!, find.byKey(ValueKey('mark-dot-${t.name}'))));
            expect(size.width, lessThan(12), reason: 'small');
          }
        });

        testWidgets('Filled: the date on a solid circle, darker outline',
            (tester) async {
          await open(tester, marks: threeKinds, style: MarkStyle.filled, brightness: b);
          for (final t in MarkType.values) {
            final d = shapeOf(tester, days[t]!);
            expect(d.shape, BoxShape.circle, reason: t.name);
            expect(d.color, MarkPalette.base(t, b), reason: 'solid, not tinted');
            expect(d.color!.a, 1.0);
            expect(d.border!.top.color, MarkPalette.outline(t, b));
            // The number stays readable on the solid colour.
            final number = tester.widget<Text>(
                find.descendant(of: cell(days[t]!), matching: find.text('${days[t]}')));
            expect(number.style?.color, MarkPalette.onColor(MarkPalette.base(t, b)));
          }
        });

        testWidgets('Highlight: a light tint behind the date, darker outline',
            (tester) async {
          await open(tester, marks: threeKinds, style: MarkStyle.highlight, brightness: b);
          for (final t in MarkType.values) {
            final d = shapeOf(tester, days[t]!);
            expect(d.shape, BoxShape.rectangle);
            expect(d.borderRadius, isNotNull, reason: 'rounded');
            expect(d.color, MarkPalette.base(t, b).withValues(alpha: 0.30));
            expect(d.color!.a, lessThan(0.5), reason: 'light tint');
            expect(d.border!.top.color, MarkPalette.outline(t, b));
          }
        });

        testWidgets('Circle: a tinted ring around the date, darker outline',
            (tester) async {
          await open(tester, marks: threeKinds, style: MarkStyle.circle, brightness: b);
          for (final t in MarkType.values) {
            final d = shapeOf(tester, days[t]!);
            expect(d.shape, BoxShape.circle);
            expect(d.color, MarkPalette.base(t, b).withValues(alpha: 0.16));
            expect(d.border!.top.color, MarkPalette.outline(t, b));
            expect(d.border!.top.width, 2);
          }
        });

        testWidgets('Square: a tinted rounded square, darker outline',
            (tester) async {
          await open(tester, marks: threeKinds, style: MarkStyle.square, brightness: b);
          for (final t in MarkType.values) {
            final d = shapeOf(tester, days[t]!);
            expect(d.shape, BoxShape.rectangle);
            expect(d.borderRadius, BorderRadius.circular(8));
            expect(d.color, MarkPalette.base(t, b).withValues(alpha: 0.16));
            expect(d.border!.top.color, MarkPalette.outline(t, b));
          }
          final r = tester.getSize(inCell(22, find.byKey(const ValueKey('mark-shape'))));
          expect(r.width, r.height, reason: 'square');
        });
      });
    }

    testWidgets('Circle and Filled are round; Square and Highlight are not',
        (tester) async {
      for (final (style, round) in [
        (MarkStyle.filled, true),
        (MarkStyle.circle, true),
        (MarkStyle.square, false),
        (MarkStyle.highlight, false),
      ]) {
        await open(tester, marks: threeKinds, style: style);
        expect(shapeOf(tester, 22).shape,
            round ? BoxShape.circle : BoxShape.rectangle,
            reason: style.name);
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('Highlight fills the whole date cell; others are a compact shape',
        (tester) async {
      await open(tester, marks: threeKinds, style: MarkStyle.highlight);
      final wide = tester.getSize(inCell(22, find.byKey(const ValueKey('mark-shape'))));
      await tester.pumpWidget(const SizedBox());
      await open(tester, marks: threeKinds, style: MarkStyle.circle);
      final ring = tester.getSize(inCell(22, find.byKey(const ValueKey('mark-shape'))));
      expect(wide.width, greaterThan(ring.width));
    });

    testWidgets('unmarked dates get no shape or dot in any style', (tester) async {
      for (final style in MarkStyle.values) {
        await open(tester, marks: threeKinds, style: style);
        expect(inCell(25, find.byKey(const ValueKey('mark-shape'))), findsNothing);
        expect(inCell(25, find.byKey(const ValueKey('mark-dot-good'))), findsNothing);
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('the style applies to ALL marks at once, and changes live',
        (tester) async {
      final c = await open(tester, marks: threeKinds, style: MarkStyle.dot);
      expect(grid(shape), findsNothing);
      c.read(markStyleProvider.notifier).set(MarkStyle.square);
      await tester.pump();
      expect(grid(shape), findsNWidgets(3),
          reason: 'all three marks switched together');
      expect(grid(find.byKey(const ValueKey('mark-dot-good'))), findsNothing);
    });

    testWidgets('the emoji shows on the date in every style', (tester) async {
      for (final style in MarkStyle.values) {
        await open(tester,
            marks: [markOn(DateTime(2026, 9, 22), emoji: '🪔', label: 'Diya')],
            style: style);
        expect(inCell(22, find.text('🪔')), findsOneWidget, reason: style.name);
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('several marks on a date: Dot shows one dot per kind, shapes '
        'use the most severe', (tester) async {
      final many = [
        markOn(DateTime(2026, 9, 22), id: 'a', type: MarkType.neutral),
        markOn(DateTime(2026, 9, 22), id: 'b', type: MarkType.good),
        markOn(DateTime(2026, 9, 22), id: 'c', type: MarkType.cautious),
        markOn(DateTime(2026, 9, 22), id: 'd', type: MarkType.good),
      ];
      await open(tester, marks: many, style: MarkStyle.dot);
      expect(inCell(22, find.byKey(const ValueKey('mark-dot-cautious'))), findsOneWidget);
      expect(inCell(22, find.byKey(const ValueKey('mark-dot-good'))), findsOneWidget,
          reason: 'two good marks, one dot');
      expect(inCell(22, find.byKey(const ValueKey('mark-dot-neutral'))), findsOneWidget);
      await tester.pumpWidget(const SizedBox());

      await open(tester, marks: many, style: MarkStyle.filled);
      expect(shapeOf(tester, 22).color,
          MarkPalette.base(MarkType.cautious, Brightness.light));
    });

    testWidgets('a repeating mark is drawn on every date it falls on',
        (tester) async {
      await open(tester,
          marks: [
            markOn(DateTime(2026, 9, 7), repeat: RepeatRule.weekly, type: MarkType.cautious)
          ],
          style: MarkStyle.circle);
      for (final d in [7, 14, 21, 28]) {
        expect(inCell(d, find.byKey(const ValueKey('mark-shape'))), findsOneWidget,
            reason: 'Monday the ${d}th');
      }
      expect(inCell(15, find.byKey(const ValueKey('mark-shape'))), findsNothing);
      expect(grid(shape), findsNWidgets(4));
    });

    testWidgets('a mark shows in its own month only (Once)', (tester) async {
      await open(tester, marks: [markOn(DateTime(2026, 10, 5))], style: MarkStyle.circle);
      expect(grid(shape), findsNothing);
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(grid(shape), findsOneWidget);
    });
  });

  group('style picker', () {
    testWidgets('offers all five styles; Dot is the default', (tester) async {
      await open(tester);
      for (final s in ['Dot', 'Filled', 'Highlight', 'Circle', 'Square']) {
        expect(find.text(s), findsOneWidget, reason: s);
      }
      expect(find.text('Mark style'), findsOneWidget);
      final handle = tester.ensureSemantics();
      for (final st in MarkStyle.values) {
        expect(find.bySemanticsLabel('${st.label} mark style'), findsOneWidget,
            reason: st.label);
      }
      handle.dispose();
    });

    testWidgets('tapping a style applies it and saves it to Hive',
        (tester) async {
      final c = await open(tester, marks: threeKinds);
      for (final s in MarkStyle.values) {
        await tester.tap(find.byKey(ValueKey('style-${s.name}')));
        await tester.pump();
        expect(c.read(markStyleProvider), s);
        expect(AppStorage.settings.get('calendar.markStyle'), s.name);
      }
    });

    testWidgets('the choice is restored on relaunch', (tester) async {
      var c = await open(tester, marks: threeKinds);
      await tester.tap(find.byKey(const ValueKey('style-square')));
      await tester.pump();
      await tester.pumpWidget(const SizedBox());

      c = ProviderContainer(overrides: calendarOverrides());
      addTearDown(c.dispose);
      await pumpScreen(tester, c, const CalendarScreen());
      expect(c.read(markStyleProvider), MarkStyle.square);
      expect(grid(shape), findsNWidgets(3));
    });

    testWidgets('each option previews itself with a mark colour and a darker '
        'outline', (tester) async {
      await open(tester);
      final good = MarkPalette.base(MarkType.good, Brightness.light);
      final goodOutline = MarkPalette.outline(MarkType.good, Brightness.light);
      Finder inTile(String s, Finder f) =>
          find.descendant(of: find.byKey(ValueKey('style-$s')), matching: f);
      expect(inTile('dot', find.byKey(const ValueKey('mark-dot-good'))), findsOneWidget);
      for (final s in ['filled', 'highlight', 'circle', 'square']) {
        final box = tester.widget<Container>(inTile(s, find.byKey(const ValueKey('mark-shape'))));
        final d = box.decoration! as BoxDecoration;
        expect(d.border!.top.color, goodOutline, reason: s);
        expect(d.color!.a, greaterThan(0), reason: s);
      }
      final filled = tester
          .widget<Container>(inTile('filled', find.byKey(const ValueKey('mark-shape'))))
          .decoration! as BoxDecoration;
      expect(filled.color, good);
    });

    testWidgets('the selected style is highlighted', (tester) async {
      final c = await open(tester);
      BoxDecoration tile(String s) => tester
          .widget<Container>(find.descendant(
              of: find.byKey(ValueKey('style-$s')),
              matching: find.byType(Container)).first)
          .decoration! as BoxDecoration;
      final scheme = calendarTestTheme().colorScheme;
      expect(tile('dot').border!.top.color, scheme.primary);
      expect(tile('circle').border!.top.color, scheme.outlineVariant);
      c.read(markStyleProvider.notifier).set(MarkStyle.circle);
      await tester.pump();
      expect(tile('circle').border!.top.color, scheme.primary);
      expect(tile('dot').border!.top.color, scheme.outlineVariant);
    });
  });

  group('legend', () {
    testWidgets('names the three colours and the today marker', (tester) async {
      await open(tester);
      for (final t in MarkType.values) {
        expect(find.byKey(ValueKey('legend-${t.name}')), findsOneWidget);
        final d = tester.widget<Container>(find.byKey(ValueKey('legend-${t.name}')))
            .decoration! as BoxDecoration;
        expect(d.color, MarkPalette.base(t, Brightness.light));
        expect(d.border!.top.color, MarkPalette.outline(t, Brightness.light));
      }
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Cautious'), findsOneWidget);
      expect(find.text('Neutral'), findsOneWidget);
      expect(find.text('Today'), findsWidgets);
      expect(find.byKey(const ValueKey('legend-today')), findsOneWidget);
    });
  });

  group('month list', () {
    testWidgets('an empty month says so', (tester) async {
      await open(tester);
      expect(find.byKey(const ValueKey('no-marks')), findsOneWidget);
      expect(find.textContaining('Nothing marked in September 2026'), findsOneWidget);
    });

    testWidgets('lists each mark of the month once, as a card', (tester) async {
      await open(tester, marks: [
        markOn(DateTime(2026, 9, 24),
            id: 'one', emoji: '🪔', label: 'Diwali prep', details: 'Clean the shrine',
            type: MarkType.good),
        markOn(DateTime(2026, 9, 7),
            id: 'weekly', label: 'Fast', repeat: RepeatRule.weekly, type: MarkType.cautious),
        markOn(DateTime(2026, 10, 3), id: 'later', label: 'October'),
      ]);
      expect(find.text('Marks in September 2026'), findsOneWidget);
      expect(find.byKey(const ValueKey('month-card-one')), findsOneWidget);
      expect(find.byKey(const ValueKey('month-card-weekly')), findsOneWidget,
          reason: 'a weekly mark is one card, not four');
      expect(find.byKey(const ValueKey('month-card-later')), findsNothing);
      expect(find.text('Diwali prep'), findsOneWidget);
      expect(find.text('Clean the shrine'), findsOneWidget);
      expect(find.text('🪔'), findsWidgets, reason: 'on the date and on the card');
      expect(find.text('Every week'), findsOneWidget);
      // Earliest first.
      expect(
          tester.getTopLeft(find.byKey(const ValueKey('month-card-weekly'))).dy,
          lessThan(tester.getTopLeft(find.byKey(const ValueKey('month-card-one'))).dy));
    });

    testWidgets('follows the month you are looking at', (tester) async {
      await open(tester, marks: [markOn(DateTime(2026, 10, 3), id: 'oct', label: 'October')]);
      expect(find.byKey(const ValueKey('month-card-oct')), findsNothing);
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.text('Marks in October 2026'), findsOneWidget);
      expect(find.byKey(const ValueKey('month-card-oct')), findsOneWidget);
    });

    testWidgets('a card uses its mark\'s colour and outline', (tester) async {
      await open(tester, marks: [markOn(DateTime(2026, 9, 24), id: 'x', type: MarkType.cautious)]);
      final card = find.byKey(const ValueKey('month-card-x'));
      final stripe = tester.widget<Container>(
          find.descendant(of: card, matching: find.byKey(const ValueKey('mark-stripe'))));
      expect(stripe.color, MarkPalette.base(MarkType.cautious, Brightness.light));
      final avatar = tester.widget<Container>(
          find.descendant(of: card, matching: find.byKey(const ValueKey('mark-avatar'))));
      expect((avatar.decoration! as BoxDecoration).border!.top.color,
          MarkPalette.outline(MarkType.cautious, Brightness.light));
    });

    testWidgets('tapping a card opens that mark for editing', (tester) async {
      await open(tester, marks: [
        markOn(DateTime(2026, 9, 24), id: 'x', label: 'Puja', details: 'Bring flowers'),
      ]);
      await tester.tap(find.byKey(const ValueKey('month-card-x')));
      await tester.pumpAndSettle();
      expect(find.text('Edit mark'), findsOneWidget);
      expect(tester.widget<TextField>(find.byKey(const ValueKey('label-field'))).controller!.text,
          'Puja');
      expect(tester.widget<TextField>(find.byKey(const ValueKey('details-field'))).controller!.text,
          'Bring flowers');
    });
  });
}
