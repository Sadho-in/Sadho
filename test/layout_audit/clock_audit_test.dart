import 'package:advance_calendar/features/clock/application/stopwatch_provider.dart';
import 'package:advance_calendar/features/clock/application/sun_alarm_provider.dart';
import 'package:advance_calendar/features/clock/application/timer_provider.dart';
import 'package:advance_calendar/features/clock/application/location_provider.dart';
import 'package:advance_calendar/features/clock/data/clock_tool.dart';
import 'package:advance_calendar/features/clock/data/sun_alarm.dart';
import 'package:advance_calendar/features/clock/data/timer_presets.dart';
import 'package:advance_calendar/features/clock/presentation/clock_screen.dart';
import 'package:advance_calendar/features/clock/services/location_service.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'audit_harness.dart';

/// P4.3-2d: the Clock tab's tool list and every full-screen tool, in every
/// language, text size and theme.
void main() {
  setUpAll(setUpLayoutAudit);

  Finder key(String k) => find.byKey(ValueKey(k));

  Future<void> openTool(WidgetTester tester, ClockTool tool) async {
    openClockTool(appContext(tester), tool);
    await settle(tester);
  }

  testWidgets('Clock tool list', (tester) async {
    await auditApp(tester, 'Clock tool list', (rig) async {
      await selectTab(tester, rig, ShellTab.clock);
      expect(await reveal(tester, key('tool-stopwatch')), findsOneWidget);
    });
  });

  testWidgets('Clock tool list with every status line showing', (tester) async {
    await auditApp(tester, 'Clock tool list (busy)', (rig) async {
      await rig.container.read(sunAlarmProvider.notifier).setEnabled(true);
      rig.container.read(timerProvider.notifier).start();
      rig.container.read(stopwatchProvider.notifier).start();
      await selectTab(tester, rig, ShellTab.clock);
      expect(await reveal(tester, key('status-stopwatch')), findsOneWidget);
    }, location: FakeLocationService());
  });

  testWidgets('Big clock', (tester) async {
    await auditApp(tester, 'Big clock', (rig) async {
      await openTool(tester, ClockTool.clock);
    });
  });

  for (final located in [false, true]) {
    testWidgets('Sun alarm (${located ? 'located' : 'no location'})',
        (tester) async {
      await auditApp(tester, 'Sun alarm', (rig) async {
        if (located) {
          await rig.container.read(sunAlarmProvider.notifier).setEnabled(true);
        }
        await openTool(tester, ClockTool.sunAlarm);
      },
          location: located
              ? FakeLocationService()
              : FakeLocationService(state: LocationAccess.denied));
    });
  }

  testWidgets('Sun alarm, custom offset open', (tester) async {
    await auditApp(tester, 'Sun alarm (custom offset)', (rig) async {
      await rig.container.read(sunAlarmProvider.notifier).setEnabled(true);
      rig.container.read(sunAlarmProvider.notifier).setOffset(-95);
      await openTool(tester, ClockTool.sunAlarm);
      await tester.tap(await reveal(tester, key('offset-custom')));
      await settle(tester);
      expect(await reveal(tester, key('custom-minutes')), findsOneWidget);
    }, location: FakeLocationService());
  });

  testWidgets('World clock', (tester) async {
    await auditApp(tester, 'World clock', (rig) async {
      await openTool(tester, ClockTool.worldClock);
    });
  });

  testWidgets('Timer, idle (a preset)', (tester) async {
    await auditApp(tester, 'Timer (idle)', (rig) async {
      rig.container.read(timerProvider.notifier).selectPreset(timerPresets[2]);
      await openTool(tester, ClockTool.timer);
    });
  });

  testWidgets('Timer, a custom length chosen (long chip label)', (tester) async {
    await auditApp(tester, 'Timer (custom)', (rig) async {
      rig.container
          .read(timerProvider.notifier)
          .selectCustom(23 * 3600 + 59 * 60 + 59);
      await openTool(tester, ClockTool.timer);
      expect(key('preset-custom'), findsOneWidget);
    });
  });

  testWidgets('Timer, custom-duration picker', (tester) async {
    await auditApp(tester, 'Custom duration dialog', (rig) async {
      await openTool(tester, ClockTool.timer);
      await tester.tap(await reveal(tester, key('preset-custom')));
      await settle(tester);
      expect(key('custom-ok'), findsOneWidget);
    });
  });

  testWidgets('Timer, Vrat -> sunset, running', (tester) async {
    await auditApp(tester, 'Timer (vrat, running)', (rig) async {
      rig.container.read(timerProvider.notifier)
        ..selectVratToSunset()
        ..start();
      await openTool(tester, ClockTool.timer);
      expect(rig.container.read(timerProvider).isVrat, isTrue);
    }, location: FakeLocationService());
  });

  testWidgets('Timer, Vrat -> sunset with the "tomorrow" note', (tester) async {
    await auditApp(tester, 'Timer (vrat, tomorrow)', (rig) async {
      await openTool(tester, ClockTool.timer);
      final p = rig.container.read(locationProvider).point;
      rig.clock.now = sunEventOn(
              SunEventKind.sunset, DateTime(2026, 9, 21), p.lat, p.lon)!
          .add(const Duration(hours: 1));
      rig.container.read(timerProvider.notifier).selectVratToSunset();
      await settle(tester);
      expect(rig.container.read(timerProvider).message, isNotNull);
    }, location: FakeLocationService());
  });

  testWidgets('Timer, finished', (tester) async {
    await auditApp(tester, 'Timer (finished)', (rig) async {
      final t = rig.container.read(timerProvider.notifier)
        ..selectPreset(timerPresets.first)
        ..start();
      rig.clock.advance(const Duration(minutes: 6));
      t.tick();
      await openTool(tester, ClockTool.timer);
      expect(rig.container.read(timerProvider).phase, TimerPhase.finished);
    });
  });

  testWidgets('Stopwatch with 20 laps', (tester) async {
    await auditApp(tester, 'Stopwatch (20 laps)', (rig) async {
      final sw = rig.container.read(stopwatchProvider.notifier)..start();
      for (var i = 0; i < 20; i++) {
        rig.clock.advance(Duration(minutes: 3 + i * 7, seconds: 13));
        sw.lap();
      }
      sw.stop();
      await openTool(tester, ClockTool.stopwatch);
      expect(rig.container.read(stopwatchProvider).laps.length, 20);
    });
  });
}
