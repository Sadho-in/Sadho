import 'package:advance_calendar/features/clock/data/world_cities.dart';
import 'package:advance_calendar/features/clock/presentation/tools/big_clock_page.dart';
import 'package:advance_calendar/features/clock/presentation/tools/world_clock_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'clock_ui_support.dart';

void main() {
  group('the big clock', () {
    testWidgets('shows the time, seconds, AM/PM and the full date', (
      tester,
    ) async {
      await pumpClock(
        tester,
        const BigClockPage(),
        now: DateTime(2026, 9, 21, 8, 5, 7),
      );
      expect(textOf(tester, 'clock-time'), '8:05');
      expect(textOf(tester, 'clock-seconds'), ':07');
      expect(textOf(tester, 'clock-period'), 'AM');
      expect(textOf(tester, 'clock-date'), 'Monday, 21 September 2026');
    });

    testWidgets(
      'is large: bigger than any body text, and still inside the screen',
      (tester) async {
        await pumpClock(tester, const BigClockPage());
        // (getRect applies the scale-to-fit; getSize would give the unscaled box)
        final r = tester.getRect(byKey('clock-time'));
        expect(r.height, greaterThan(80)); // body text is ~14–16
        expect(r.left, greaterThanOrEqualTo(0));
        expect(
          tester.getRect(byKey('clock-period')).right,
          lessThanOrEqualTo(411),
        );
        final date = tester.getRect(byKey('clock-date'));
        expect(r.height, greaterThan(date.height));
      },
    );

    testWidgets('is live: it moves on by itself every second', (tester) async {
      final rig = await pumpClock(
        tester,
        const BigClockPage(),
        now: DateTime(2026, 9, 21, 8, 5, 7),
      );
      await passTime(tester, rig, const Duration(seconds: 1));
      expect(textOf(tester, 'clock-seconds'), ':08');
      await passTime(tester, rig, const Duration(seconds: 55));
      expect(textOf(tester, 'clock-time'), '8:06');
      expect(textOf(tester, 'clock-seconds'), ':03');
    });

    testWidgets('rolls over noon and midnight, and the date', (tester) async {
      final rig = await pumpClock(
        tester,
        const BigClockPage(),
        now: DateTime(2026, 9, 21, 11, 59, 59),
      );
      await passTime(tester, rig, const Duration(seconds: 1));
      expect(textOf(tester, 'clock-time'), '12:00');
      expect(textOf(tester, 'clock-period'), 'PM');
      rig.clock.now = DateTime(2026, 9, 21, 23, 59, 59);
      await passTime(tester, rig, const Duration(seconds: 1));
      expect(textOf(tester, 'clock-time'), '12:00');
      expect(textOf(tester, 'clock-period'), 'AM');
      expect(textOf(tester, 'clock-date'), 'Tuesday, 22 September 2026');
    });

    testWidgets('follows a 24-hour phone setting', (tester) async {
      await pumpClock(
        tester,
        const BigClockPage(),
        now: DateTime(2026, 9, 21, 20, 5, 7),
        use24: true,
      );
      expect(textOf(tester, 'clock-time'), '20:05');
      expect(byKey('clock-period'), findsNothing);
    });

    testWidgets('fits a small phone, sideways too, in dark theme', (
      tester,
    ) async {
      await pumpClock(
        tester,
        const BigClockPage(),
        width: 320,
        height: 568,
        brightness: Brightness.dark,
      );
      expect(tester.takeException(), isNull);
      await pumpClock(tester, const BigClockPage(), width: 800, height: 360);
      expect(tester.takeException(), isNull);
      expect(
        tester.getRect(byKey('clock-period')).right,
        lessThanOrEqualTo(800),
      );
      expect(
        tester.getRect(byKey('clock-time')).height,
        greaterThan(80),
        reason: 'sideways it grows to fill the wide screen',
      );
    });
  });

  group('the world clock', () {
    // 12:00 UTC on a Monday; the viewer's own clock is on UTC.
    final noon = DateTime.utc(2026, 9, 21, 12);

    testWidgets('lists Amritsar, Haridwar and London (and the rest)', (
      tester,
    ) async {
      await pumpClock(tester, const WorldClockPage(), now: noon, height: 1600);
      for (final c in worldCities) {
        expect(byKey('city-${c.name}'), findsOneWidget, reason: c.name);
        expect(find.text(c.region), findsOneWidget);
      }
    });

    testWidgets('each city shows its own time', (tester) async {
      await pumpClock(tester, const WorldClockPage(), now: noon, height: 1600);
      String at(int h, int m) => jm(DateTime(2026, 1, 1, h, m));
      expect(textOf(tester, 'city-Amritsar-time'), at(17, 30));
      expect(textOf(tester, 'city-Haridwar-time'), at(17, 30));
      expect(textOf(tester, 'city-London-time'), at(13, 0));
      expect(textOf(tester, 'city-Dubai-time'), at(16, 0));
      expect(textOf(tester, 'city-New York-time'), at(8, 0));
      expect(textOf(tester, 'city-Sydney-time'), at(22, 0));
    });

    testWidgets('says how far each is from you, and which day it is there', (
      tester,
    ) async {
      await pumpClock(
        tester,
        const WorldClockPage(),
        now: DateTime.utc(2026, 9, 21, 20),
        height: 1600,
      );
      expect(
        textOf(tester, 'city-Amritsar-note'),
        'Tomorrow · 5 h 30 m ahead of you',
      );
      expect(textOf(tester, 'city-London-note'), 'Today · 1 h ahead of you');
      expect(textOf(tester, 'city-New York-note'), 'Today · 4 h behind you');
    });

    testWidgets('is live: the minute changes without leaving the page', (
      tester,
    ) async {
      final rig = await pumpClock(
        tester,
        const WorldClockPage(),
        now: noon,
        height: 1600,
      );
      await passTime(tester, rig, const Duration(minutes: 31));
      expect(
        textOf(tester, 'city-Amritsar-time'),
        jm(DateTime(2026, 1, 1, 18, 1)),
      );
      expect(
        textOf(tester, 'city-London-time'),
        jm(DateTime(2026, 1, 1, 13, 31)),
      );
    });

    testWidgets('follows a 24-hour setting', (tester) async {
      await pumpClock(
        tester,
        const WorldClockPage(),
        now: noon,
        use24: true,
        height: 1600,
      );
      expect(textOf(tester, 'city-Amritsar-time'), '17:30');
      expect(textOf(tester, 'city-Sydney-time'), '22:00');
    });

    testWidgets('scrolls on a short screen without overflow', (tester) async {
      await pumpClock(
        tester,
        const WorldClockPage(),
        now: noon,
        width: 320,
        height: 480,
      );
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(byKey('city-Sydney'), 200);
      expect(tester.takeException(), isNull);
      expect(byKey('city-Sydney'), findsOneWidget);
    });
  });
}
