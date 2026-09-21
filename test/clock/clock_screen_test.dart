import 'package:advance_calendar/features/clock/application/stopwatch_provider.dart';
import 'package:advance_calendar/features/clock/application/sun_alarm_provider.dart';
import 'package:advance_calendar/features/clock/application/timer_provider.dart';
import 'package:advance_calendar/features/clock/data/clock_tool.dart';
import 'package:advance_calendar/features/clock/presentation/clock_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'clock_ui_support.dart';

void main() {
  group('the tool list', () {
    testWidgets('has the five tools, in order, each with its blurb', (
      tester,
    ) async {
      await pumpClock(tester, const ClockScreen());
      final tools = [
        ('Clock', 'A large, live time and date'),
        ('Sun-based alarm', 'Wake at sunrise or sunset, with an offset'),
        ('World clock', 'Amritsar, Haridwar, London and more'),
        (
          'Sadhana & vrat timer',
          'Aarti, Chalisa, Path, Havan, or until sunset',
        ),
        ('Paath stopwatch', 'Start, stop and lap'),
      ];
      var lastY = -1.0;
      for (final (title, blurb) in tools) {
        expect(find.text(title), findsOneWidget, reason: title);
        expect(find.text(blurb), findsOneWidget, reason: blurb);
        final y = tester.getTopLeft(find.text(title)).dy;
        expect(y, greaterThan(lastY), reason: '$title is below the one before');
        lastY = y;
      }
      expect(ClockTool.values.length, 5);
    });

    testWidgets('no longer shows the "Coming soon" placeholder', (
      tester,
    ) async {
      await pumpClock(tester, const ClockScreen());
      expect(find.text('Coming soon'), findsNothing);
    });

    testWidgets('fits a narrow phone and a large text size', (tester) async {
      await pumpClock(tester, const ClockScreen(), width: 320, height: 640);
      expect(tester.takeException(), isNull);
    });

    for (final (tool, title) in [
      (ClockTool.clock, 'Clock'),
      (ClockTool.sunAlarm, 'Sun-based alarm'),
      (ClockTool.worldClock, 'World clock'),
      (ClockTool.timer, 'Sadhana & vrat timer'),
      (ClockTool.stopwatch, 'Paath stopwatch'),
    ]) {
      testWidgets('$title opens full-screen and can be closed', (tester) async {
        await pumpClock(tester, const ClockScreen());
        await tester.tap(byKey('tool-${tool.name}'));
        await tester.pumpAndSettle(const Duration(milliseconds: 50));
        // A full-screen dialog route: its own app bar with a close button and
        // nothing of the Clock list underneath showing through.
        expect(find.byType(CloseButton), findsOneWidget);
        expect(
          find.descendant(of: find.byType(AppBar), matching: find.text(title)),
          findsOneWidget,
        );
        final route = ModalRoute.of(tester.element(find.byType(CloseButton)))!;
        expect(route, isA<PageRoute<void>>());
        expect((route as MaterialPageRoute<void>).fullscreenDialog, isTrue);

        await tester.tap(find.byType(CloseButton));
        await tester.pumpAndSettle(const Duration(milliseconds: 50));
        expect(find.byType(CloseButton), findsNothing);
        expect(byKey('tool-${tool.name}'), findsOneWidget);
      });
    }
  });

  group('live status under the tools', () {
    testWidgets('nothing extra when nothing is running', (tester) async {
      await pumpClock(tester, const ClockScreen());
      for (final t in ClockTool.values) {
        expect(byKey('status-${t.name}'), findsNothing, reason: t.name);
      }
    });

    testWidgets('an alarm that is on shows its offset and time', (
      tester,
    ) async {
      final rig = await pumpClock(tester, const ClockScreen());
      await rig.container.read(sunAlarmProvider.notifier).setEnabled(true);
      await tester.pump();
      final line = textOf(tester, 'status-sunAlarm');
      expect(line, startsWith('On · 30 min before'));
      expect(line, contains(RegExp(r'\d{1,2}:\d{2}')));
    });

    testWidgets('a running timer counts down on the list', (tester) async {
      final rig = await pumpClock(tester, const ClockScreen());
      rig.container.read(timerProvider.notifier).start();
      await tester.pump();
      expect(textOf(tester, 'status-timer'), 'Aarti · 05:00 left');
      await passTime(tester, rig, const Duration(seconds: 90));
      expect(textOf(tester, 'status-timer'), 'Aarti · 03:30 left');
    });

    testWidgets(
      'a timer that ran out shows as finished, not as negative time',
      (tester) async {
        final rig = await pumpClock(tester, const ClockScreen());
        rig.container.read(timerProvider.notifier).start();
        await tester.pump();
        await passTime(tester, rig, const Duration(minutes: 6));
        expect(textOf(tester, 'status-timer'), 'Aarti · finished');
      },
    );

    testWidgets('a stopwatch shows its time, running or stopped', (
      tester,
    ) async {
      final rig = await pumpClock(tester, const ClockScreen());
      final n = rig.container.read(stopwatchProvider.notifier)..start();
      await tester.pump();
      await passTime(tester, rig, const Duration(seconds: 12));
      expect(textOf(tester, 'status-stopwatch'), startsWith('Running · 00:12'));
      n.stop();
      await tester.pump();
      expect(textOf(tester, 'status-stopwatch'), startsWith('Stopped · 00:12'));
    });
  });
}
