import 'package:advance_calendar/features/clock/presentation/clock_screen.dart';
import 'package:advance_calendar/features/clock/data/clock_tool.dart';
import 'package:advance_calendar/features/clock/presentation/tools/stopwatch_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'clock_ui_support.dart';

void main() {
  bool enabled(WidgetTester t, String key) =>
      t.widget<ButtonStyleButton>(byKey(key)).onPressed != null;

  testWidgets('starts at zero: Start, and a disabled Reset', (tester) async {
    await pumpClock(tester, const StopwatchPage());
    expect(textOf(tester, 'sw-time'), '00:00.00');
    expect(
      find.descendant(of: byKey('sw-toggle'), matching: find.text('Start')),
      findsOneWidget,
    );
    expect(byKey('sw-reset'), findsOneWidget);
    expect(enabled(tester, 'sw-reset'), isFalse);
    expect(byKey('sw-lap'), findsNothing);
    expect(byKey('sw-empty'), findsOneWidget);
  });

  testWidgets('Start counts up, showing hundredths', (tester) async {
    final rig = await pumpClock(tester, const StopwatchPage());
    await tester.tap(byKey('sw-toggle'));
    await tester.pump();
    expect(
      find.descendant(of: byKey('sw-toggle'), matching: find.text('Stop')),
      findsOneWidget,
    );
    await passTime(tester, rig, const Duration(seconds: 1, milliseconds: 500));
    expect(textOf(tester, 'sw-time'), '00:01.50');
    await passTime(
      tester,
      rig,
      const Duration(minutes: 2, seconds: 3, milliseconds: 250),
    );
    expect(textOf(tester, 'sw-time'), '02:04.75');
  });

  testWidgets('Stop holds the time; Start carries on from it', (tester) async {
    final rig = await pumpClock(tester, const StopwatchPage());
    await tester.tap(byKey('sw-toggle'));
    await passTime(tester, rig, const Duration(seconds: 3));
    await tester.tap(byKey('sw-toggle')); // Stop
    await tester.pump();
    final held = textOf(tester, 'sw-time');
    expect(held, '00:03.00');
    await passTime(tester, rig, const Duration(minutes: 1));
    expect(textOf(tester, 'sw-time'), held);
    await tester.tap(byKey('sw-toggle')); // Start again
    await passTime(tester, rig, const Duration(seconds: 2));
    expect(textOf(tester, 'sw-time'), '00:05.00');
  });

  testWidgets('Lap is offered only while running; Reset only while stopped', (
    tester,
  ) async {
    final rig = await pumpClock(tester, const StopwatchPage());
    await tester.tap(byKey('sw-toggle'));
    await tester.pump();
    expect(byKey('sw-lap'), findsOneWidget);
    expect(byKey('sw-reset'), findsNothing);
    await passTime(tester, rig, const Duration(seconds: 2));
    await tester.tap(byKey('sw-toggle'));
    await tester.pump();
    expect(byKey('sw-lap'), findsNothing);
    expect(enabled(tester, 'sw-reset'), isTrue);
  });

  testWidgets('laps are listed newest first with lap time and total', (
    tester,
  ) async {
    final rig = await pumpClock(tester, const StopwatchPage());
    await tester.tap(byKey('sw-toggle'));
    await tester.pump();
    for (final secs in [30, 45, 20]) {
      await passTime(tester, rig, Duration(seconds: secs));
      await tester.tap(byKey('sw-lap'));
      await tester.pump();
    }
    expect(textOf(tester, 'lap-1-time'), '00:30.00');
    expect(textOf(tester, 'lap-2-time'), '00:45.00');
    expect(textOf(tester, 'lap-3-time'), '00:20.00');
    expect(textOf(tester, 'lap-1-total'), '00:30.00');
    expect(textOf(tester, 'lap-2-total'), '01:15.00');
    expect(textOf(tester, 'lap-3-total'), '01:35.00');
    // Newest on top.
    expect(
      tester.getTopLeft(byKey('lap-3')).dy,
      lessThan(tester.getTopLeft(byKey('lap-2')).dy),
    );
    expect(
      tester.getTopLeft(byKey('lap-2')).dy,
      lessThan(tester.getTopLeft(byKey('lap-1')).dy),
    );
    expect(byKey('sw-empty'), findsNothing);
  });

  testWidgets('with three laps the fastest and slowest are marked', (
    tester,
  ) async {
    final rig = await pumpClock(tester, const StopwatchPage());
    await tester.tap(byKey('sw-toggle'));
    await tester.pump();
    for (final secs in [30, 45, 20]) {
      await passTime(tester, rig, Duration(seconds: secs));
      await tester.tap(byKey('sw-lap'));
      await tester.pump();
    }
    expect(find.text('Fastest'), findsOneWidget);
    expect(find.text('Slowest'), findsOneWidget);
    // On the right laps: 20 s is fastest, 45 s slowest.
    expect(
      find.descendant(of: byKey('lap-3'), matching: find.text('Fastest')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: byKey('lap-2'), matching: find.text('Slowest')),
      findsOneWidget,
    );
  });

  testWidgets('two laps are not ranked, and equal laps are not either', (tester) async {
    final rig = await pumpClock(tester, const StopwatchPage());
    await tester.tap(byKey('sw-toggle'));
    await tester.pump();
    for (final secs in [10, 25]) {
      await passTime(tester, rig, Duration(seconds: secs));
      await tester.tap(byKey('sw-lap'));
      await tester.pump();
    }
    expect(find.text('Fastest'), findsNothing, reason: 'two laps: nothing to rank');
    expect(find.text('Slowest'), findsNothing);
  });

  testWidgets('three equal laps have no fastest or slowest', (tester) async {
    final rig = await pumpClock(tester, const StopwatchPage());
    await tester.tap(byKey('sw-toggle'));
    await tester.pump();
    for (var i = 0; i < 3; i++) {
      await passTime(tester, rig, const Duration(seconds: 10));
      await tester.tap(byKey('sw-lap'));
      await tester.pump();
    }
    expect(find.text('Fastest'), findsNothing);
    expect(find.text('Slowest'), findsNothing);
  });

  testWidgets('Reset clears the time and the laps', (tester) async {
    final rig = await pumpClock(tester, const StopwatchPage());
    await tester.tap(byKey('sw-toggle'));
    await passTime(tester, rig, const Duration(seconds: 8));
    await tester.tap(byKey('sw-lap'));
    await tester.tap(byKey('sw-toggle')); // stop
    await tester.pump();
    await tester.tap(byKey('sw-reset'));
    await tester.pump();
    expect(textOf(tester, 'sw-time'), '00:00.00');
    expect(byKey('lap-1'), findsNothing);
    expect(byKey('sw-empty'), findsOneWidget);
    expect(enabled(tester, 'sw-reset'), isFalse);
  });

  testWidgets('it keeps running when you close the screen', (tester) async {
    final rig = await pumpClock(tester, const ClockScreen());
    await tester.tap(byKey('tool-${ClockTool.stopwatch.name}'));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    await tester.tap(byKey('sw-toggle'));
    await tester.pump();
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    rig.clock.advance(const Duration(minutes: 3));
    await tester.tap(byKey('tool-${ClockTool.stopwatch.name}'));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(textOf(tester, 'sw-time'), '03:00.00');
    expect(
      find.descendant(of: byKey('sw-toggle'), matching: find.text('Stop')),
      findsOneWidget,
    );
  });

  testWidgets('a long run shows hours; many laps scroll', (tester) async {
    final rig = await pumpClock(tester, const StopwatchPage(), height: 600);
    await tester.tap(byKey('sw-toggle'));
    await tester.pump();
    for (var i = 0; i < 20; i++) {
      await passTime(tester, rig, const Duration(minutes: 5));
      await tester.tap(byKey('sw-lap'));
      await tester.pump();
    }
    expect(textOf(tester, 'sw-time'), '1:40:00.00');
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(byKey('lap-1'), 200);
    expect(byKey('lap-1'), findsOneWidget);
  });

  testWidgets('fits a narrow phone with a big time', (tester) async {
    final rig = await pumpClock(
      tester,
      const StopwatchPage(),
      width: 320,
      height: 568,
    );
    await tester.tap(byKey('sw-toggle'));
    await passTime(
      tester,
      rig,
      const Duration(hours: 1, minutes: 23, seconds: 45),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getRect(byKey('sw-time')).right, lessThanOrEqualTo(320));
  });
}
