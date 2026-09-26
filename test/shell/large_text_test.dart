import 'package:advance_calendar/app.dart';
import 'package:advance_calendar/features/alarms/presentation/alarms_reliability_page.dart';
import 'package:advance_calendar/features/alarms/services/alarm_health.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile/profile_support.dart';
import '../sadhana/test_support.dart';

/// P4.3-2e: the lock-screen alarm screen and "Alarms & reliability" at a
/// large text size on a small phone.
void main() {

  void smallPhoneLargeText(WidgetTester tester) {
    phoneScreen(tester, width: 360, height: 640);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  testWidgets('the alarm screen scrolls at 1.6 and every button is reachable',
      (tester) async {
    smallPhoneLargeText(tester);
    final rig = profileRig(
        saved: {'onboarding.done': true},
        lockScreen: FakeLockScreen(locked: true, launch: sadhanaTimerGroup));
    await tester.pumpWidget(UncontrolledProviderScope(
        container: rig.container, child: const SadhoApp()));
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    for (final k in ['alarm-result', 'alarm-stop', 'alarm-unlock']) {
      final f = find.byKey(ValueKey(k));
      await tester.ensureVisible(f);
      await tester.pump();
      final r = tester.getRect(f);
      expect(r.top, greaterThanOrEqualTo(0), reason: k);
      expect(r.bottom, lessThanOrEqualTo(640), reason: k);
    }
  });

  testWidgets('the alarm screen is still centred at the default size',
      (tester) async {
    phoneScreen(tester, width: 360, height: 640);
    final rig = profileRig(
        saved: {'onboarding.done': true},
        lockScreen: FakeLockScreen(locked: true, launch: timerGroup));
    await tester.pumpWidget(UncontrolledProviderScope(
        container: rig.container, child: const SadhoApp()));
    await tester.pump();
    await tester.pump();
    // The buttons at the bottom, the hint under them near the bottom edge.
    expect(tester.getRect(find.byKey(const ValueKey('alarm-unlock'))).bottom,
        greaterThan(640 * 0.75));
  });

  testWidgets('a health row wraps its status instead of overflowing',
      (tester) async {
    smallPhoneLargeText(tester);
    phoneScreen(tester, width: 360, height: 3000); // every row built
    final c = ProviderContainer(
        overrides: testOverrides(
            alarmHealth: FakeAlarmHealth(battery: false, samsung: true)));
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: AlarmsReliabilityPage()),
    ));
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    final fix = find.byKey(const ValueKey('health-battery-fix'));
    expect(tester.getRect(fix).right, lessThanOrEqualTo(360));
    expect(c.read(alarmHealthProvider), isA<FakeAlarmHealth>());
  });
}
