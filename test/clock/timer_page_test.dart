import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart'
    show timerGroup;
import 'package:advance_calendar/features/clock/application/timer_provider.dart';
import 'package:advance_calendar/features/clock/data/sun_alarm.dart';
import 'package:advance_calendar/features/clock/presentation/tools/timer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'clock_ui_support.dart';

void main() {
  Finder inToggle(String t) =>
      find.descendant(of: byKey('timer-toggle'), matching: find.text(t));
  bool enabled(WidgetTester t, String key) =>
      t.widget<ButtonStyleButton>(byKey(key)).onPressed != null;
  Future<void> choose(WidgetTester t, String key) async {
    await t.tap(byKey(key));
    await t.pump();
  }

  double progress(WidgetTester t) =>
      t.widget<CircularProgressIndicator>(byKey('timer-progress')).value!;

  DateTime amritsarSunset() =>
      sunEventOn(SunEventKind.sunset, DateTime(2026, 9, 21), 31.6340, 74.8723)!;
  DateTime threeHoursBeforeSunset() =>
      amritsarSunset().subtract(const Duration(hours: 3));

  group('choosing', () {
    testWidgets(
      'offers Aarti 5, Chalisa 11, Path 21, Havan 30 and Vrat → sunset',
      (tester) async {
        await pumpClock(tester, const TimerPage());
        for (final label in [
          'Aarti · 5 min',
          'Chalisa · 11 min',
          'Path · 21 min',
          'Havan · 30 min',
          'Vrat → sunset',
        ]) {
          expect(find.text(label), findsOneWidget, reason: label);
        }
      },
    );

    testWidgets('starts on Aarti, 05:00, ready', (tester) async {
      await pumpClock(tester, const TimerPage());
      expect(textOf(tester, 'timer-remaining'), '05:00');
      expect(textOf(tester, 'timer-label'), 'Aarti');
      expect(inToggle('Start'), findsOneWidget);
      expect(enabled(tester, 'timer-reset'), isFalse);
    });

    testWidgets('each preset sets its length on the dial', (tester) async {
      await pumpClock(tester, const TimerPage());
      for (final (key, shown, label) in [
        ('preset-chalisa', '11:00', 'Chalisa'),
        ('preset-path', '21:00', 'Path'),
        ('preset-havan', '30:00', 'Havan'),
        ('preset-aarti', '05:00', 'Aarti'),
      ]) {
        await choose(tester, key);
        expect(textOf(tester, 'timer-remaining'), shown, reason: key);
        expect(textOf(tester, 'timer-label'), label);
        expect(progress(tester), 1.0);
      }
    });

    testWidgets('the chosen one is marked selected', (tester) async {
      await pumpClock(tester, const TimerPage());
      await choose(tester, 'preset-path');
      bool sel(String k) => tester.widget<ChoiceChip>(byKey(k)).selected;
      expect(sel('preset-path'), isTrue);
      expect(sel('preset-aarti'), isFalse);
      expect(sel('preset-vrat'), isFalse);
    });
  });

  group('running', () {
    testWidgets('counts down second by second and the ring empties', (
      tester,
    ) async {
      final rig = await pumpClock(tester, const TimerPage());
      await choose(tester, 'preset-chalisa');
      await choose(tester, 'timer-toggle');
      expect(inToggle('Pause'), findsOneWidget);
      await passTime(tester, rig, const Duration(seconds: 30));
      expect(textOf(tester, 'timer-remaining'), '10:30');
      await passTime(tester, rig, const Duration(minutes: 5, seconds: 15));
      expect(textOf(tester, 'timer-remaining'), '05:15');
      expect(progress(tester), closeTo(315 / 660, 0.01));
    });

    testWidgets('the length cannot be changed while it runs', (tester) async {
      await pumpClock(tester, const TimerPage());
      await choose(tester, 'timer-toggle');
      expect(
        tester.widget<ChoiceChip>(byKey('preset-havan')).onSelected,
        isNull,
      );
      await tester.tap(byKey('preset-havan'));
      await tester.pump();
      expect(textOf(tester, 'timer-label'), 'Aarti');
    });

    testWidgets('Pause holds it, Resume carries on', (tester) async {
      final rig = await pumpClock(tester, const TimerPage());
      await choose(tester, 'timer-toggle');
      await passTime(tester, rig, const Duration(minutes: 1));
      await choose(tester, 'timer-toggle'); // Pause
      expect(inToggle('Resume'), findsOneWidget);
      expect(textOf(tester, 'timer-remaining'), '04:00');
      await passTime(tester, rig, const Duration(minutes: 10));
      expect(textOf(tester, 'timer-remaining'), '04:00');
      await choose(tester, 'timer-toggle'); // Resume
      await passTime(tester, rig, const Duration(seconds: 30));
      expect(textOf(tester, 'timer-remaining'), '03:30');
    });

    testWidgets('Reset goes back to the full length', (tester) async {
      final rig = await pumpClock(tester, const TimerPage());
      await choose(tester, 'timer-toggle');
      await passTime(tester, rig, const Duration(minutes: 2));
      await choose(tester, 'timer-reset');
      expect(textOf(tester, 'timer-remaining'), '05:00');
      expect(inToggle('Start'), findsOneWidget);
      // Presets are free to change again.
      expect(
        tester.widget<ChoiceChip>(byKey('preset-havan')).onSelected,
        isNotNull,
      );
    });

    testWidgets('an hour-long vrat shows h:mm:ss', (tester) async {
      await pumpClock(
        tester,
        const TimerPage(),
        saved: {
          'clock.timer': {
            'preset': 'path',
            'label': 'Path',
            'total': 5400,
            'remaining': 5400,
          },
        },
      );
      expect(textOf(tester, 'timer-remaining'), '1:30:00');
    });
  });

  group('at zero', () {
    testWidgets('it says so, vibrates and rings once, and offers Start again', (
      tester,
    ) async {
      final rig = await pumpClock(tester, const TimerPage());
      await choose(tester, 'timer-toggle');
      await passTime(tester, rig, const Duration(minutes: 4, seconds: 59));
      expect(rig.feedback.completions, 0);
      await passTime(tester, rig, const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 300));
      expect(rig.feedback.completions, 1);
      expect(textOf(tester, 'timer-label'), 'Time’s up 🙏');
      expect(textOf(tester, 'timer-remaining'), '00:00');
      expect(inToggle('Start again'), findsOneWidget);
      // ...and it does not keep ringing.
      await passTime(tester, rig, const Duration(seconds: 30));
      expect(rig.feedback.completions, 1);
    });

    testWidgets('Start again begins a fresh countdown', (tester) async {
      final rig = await pumpClock(tester, const TimerPage());
      await choose(tester, 'timer-toggle');
      await passTime(tester, rig, const Duration(minutes: 5));
      await tester.pump(const Duration(milliseconds: 300));
      await choose(tester, 'timer-toggle');
      expect(textOf(tester, 'timer-remaining'), '05:00');
      expect(textOf(tester, 'timer-label'), 'Aarti');
      await passTime(tester, rig, const Duration(minutes: 5));
      await tester.pump(const Duration(milliseconds: 300));
      expect(rig.feedback.completions, 2);
    });

    testWidgets(
      'the phone\'s notification is set for the end, and dropped at zero',
      (tester) async {
        final rig = await pumpClock(tester, const TimerPage());
        await choose(tester, 'preset-chalisa');
        await choose(tester, 'timer-toggle');
        await tester.pump();
        final ring = rig.scheduler.alerts[timerGroup]!;
        expect(
          ring.single.when,
          rig.clock.now.add(const Duration(minutes: 11)),
        );
        await passTime(tester, rig, const Duration(minutes: 11));
        await tester.pump(const Duration(milliseconds: 300));
        expect(rig.scheduler.alerts[timerGroup], isEmpty);
      },
    );
  });

  group('Vrat → sunset', () {
    testWidgets('shows the sunset it counts to, and whose sky it is', (
      tester,
    ) async {
      final rig = await pumpClock(
        tester,
        const TimerPage(),
        now: threeHoursBeforeSunset(),
      );
      await choose(tester, 'preset-vrat');
      final t = rig.container.read(timerProvider);
      expect(t.isVrat, isTrue);
      expect(textOf(tester, 'vrat-sunset'), 'Sunset at ${jm(t.vratTarget!)}');
      expect(textOf(tester, 'vrat-where'), contains('Amritsar'));
      expect(textOf(tester, 'timer-label'), 'Vrat → sunset');
      // The dial counts the time to that sunset.
      final left = t.vratTarget!.difference(rig.clock.now);
      final h = left.inHours, m = left.inMinutes % 60;
      expect(h, 3);
      expect(
        textOf(tester, 'timer-remaining'),
        startsWith('$h:${m.toString().padLeft(2, '0')}'),
      );
    });

    testWidgets('counts down to the sunset and rings at it', (tester) async {
      final rig = await pumpClock(
        tester,
        const TimerPage(),
        now: threeHoursBeforeSunset(),
      );
      await choose(tester, 'preset-vrat');
      await choose(tester, 'timer-toggle');
      final target = rig.container.read(timerProvider).vratTarget!;
      // Jump to 10 minutes before, then to the sunset itself.
      rig.clock.now = target.subtract(const Duration(minutes: 10));
      await tester.pump(const Duration(milliseconds: 300));
      expect(textOf(tester, 'timer-remaining'), '10:00');
      expect(rig.feedback.completions, 0);
      rig.clock.now = target;
      await tester.pump(const Duration(milliseconds: 300));
      expect(rig.feedback.completions, 1);
      expect(textOf(tester, 'timer-label'), 'Time’s up 🙏');
    });

    testWidgets('after sunset it says it is counting to tomorrow\'s', (
      tester,
    ) async {
      final late = amritsarSunset().add(const Duration(minutes: 45));
      await pumpClock(tester, const TimerPage(), now: late);
      await choose(tester, 'preset-vrat');
      await tester.scrollUntilVisible(byKey('timer-message'), 100);
      expect(textOf(tester, 'timer-message'), contains('tomorrow'));
    });

    testWidgets('uses the phone\'s location when it has one', (tester) async {
      final rig = await pumpClock(
        tester,
        const TimerPage(),
        location: FakeLocationService(lat: 51.5074, lon: -0.1278),
      );
      await tester.pump();
      await choose(tester, 'preset-vrat');
      expect(textOf(tester, 'vrat-where'), 'Using your location');
      final expected = sunEventOn(
        SunEventKind.sunset,
        DateTime(rig.clock.now.year, rig.clock.now.month, rig.clock.now.day),
        51.5074,
        -0.1278,
      );
      // London's sunset today or, if that has passed here, tomorrow's.
      final got = rig.container.read(timerProvider).vratTarget!;
      expect(got.difference(expected!).inHours.abs() <= 24, isTrue);
      expect(got.isAfter(rig.clock.now), isTrue);
    });
  });

  testWidgets('leaving the page does not stop the countdown', (tester) async {
    final rig = await pumpClock(tester, const TimerPage());
    await choose(tester, 'timer-toggle');
    await tester.pumpWidget(const SizedBox());
    rig.clock.advance(const Duration(minutes: 2));
    expect(rig.container.read(timerProvider).remainingAt(rig.clock.now), 180);
  });

  testWidgets('fits a small phone, and dark theme', (tester) async {
    await pumpClock(
      tester,
      const TimerPage(),
      width: 320,
      height: 568,
      brightness: Brightness.dark,
    );
    expect(tester.takeException(), isNull);
    await choose(tester, 'preset-vrat');
    expect(tester.takeException(), isNull);
  });
}
