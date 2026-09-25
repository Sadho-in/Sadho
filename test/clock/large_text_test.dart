import 'package:advance_calendar/features/clock/application/stopwatch_provider.dart';
import 'package:advance_calendar/features/clock/presentation/tools/big_clock_page.dart';
import 'package:advance_calendar/features/clock/presentation/tools/stopwatch_page.dart';
import 'package:advance_calendar/features/clock/presentation/tools/sun_alarm_page.dart';
import 'package:advance_calendar/features/clock/presentation/tools/world_clock_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'clock_ui_support.dart';

/// P4.3-2d: at a large text size the Clock tools stack what no longer fits
/// side by side, instead of overflowing; at the default size nothing moves.
void main() {
  void textScale(WidgetTester tester, double s) {
    tester.platformDispatcher.textScaleFactorTestValue = s;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  Future<void> threeLaps(WidgetTester tester, Rig rig) async {
    final sw = rig.container.read(stopwatchProvider.notifier)..start();
    for (var i = 0; i < 3; i++) {
      rig.clock.advance(const Duration(minutes: 12, seconds: 34));
      sw.lap();
    }
    sw.stop();
    await tester.pump();
  }

  for (final (scale, beside) in [(1.0, true), (1.6, false)]) {
    testWidgets('stopwatch lap: total ${beside ? 'beside' : 'under'} the lap '
        'time at $scale on a 360 px phone', (tester) async {
      textScale(tester, scale);
      final rig =
          await pumpClock(tester, const StopwatchPage(), width: 360);
      await threeLaps(tester, rig);
      expect(tester.takeException(), isNull);
      final lap = tester.getRect(byKey('lap-1-time'));
      final total = tester.getRect(byKey('lap-1-total'));
      if (beside) {
        expect(total.left, greaterThan(lap.right));
        expect(total.top, closeTo(lap.top, 1));
      } else {
        expect(total.top, greaterThanOrEqualTo(lap.bottom - 0.5));
      }
      expect(total.right, lessThanOrEqualTo(360));
    });
  }

  testWidgets('world clock: time beside the city when there is room, fits at '
      '1.6 on a 360 px phone', (tester) async {
    await pumpClock(tester, const WorldClockPage(), width: 700);
    final name = find.byKey(const ValueKey('city-London-note'));
    final time = find.byKey(const ValueKey('city-London-time'));
    expect(tester.getRect(time).left, greaterThan(tester.getRect(name).right));
    expect(tester.getRect(time).top, lessThan(tester.getRect(name).top));
    textScale(tester, 1.6);
    await pumpClock(tester, const WorldClockPage(), width: 360, height: 3000);
    expect(tester.takeException(), isNull);
    expect(tester.getRect(time).right, lessThanOrEqualTo(360));
  });

  testWidgets('big clock: seconds and AM/PM fit at 1.6', (tester) async {
    textScale(tester, 1.6);
    await pumpClock(tester, const BigClockPage(), width: 360);
    expect(tester.takeException(), isNull);
    for (final k in ['clock-seconds', 'clock-period']) {
      expect(tester.getRect(byKey(k)).right, lessThanOrEqualTo(360), reason: k);
    }
  });

  testWidgets('sun alarm: "Use my location" is a full button under the place',
      (tester) async {
    textScale(tester, 1.6);
    await pumpClock(tester, const SunAlarmPage(), width: 360, height: 3000);
    expect(tester.takeException(), isNull);
    final button = tester.getRect(byKey('use-location'));
    expect(button.top, greaterThan(tester.getRect(byKey('sun-where')).bottom));
    expect(button.right, lessThanOrEqualTo(360));
  });
}
