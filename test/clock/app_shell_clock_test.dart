import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/clock/application/clock_source.dart';
import 'package:advance_calendar/features/clock/data/sun_alarm.dart';
import 'package:advance_calendar/features/clock/services/location_service.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../sadhana/test_support.dart';
import 'clock_support.dart';

/// The Clock tab inside the real shell.
void main() {
  late FakeScheduler scheduler;

  setUp(() {
    resetStorage();
    scheduler = FakeScheduler();
  });

  Future<ProviderContainer> openShell(WidgetTester tester,
      {Map<String, Object?> saved = const {}}) async {
    tester.view.physicalSize = const Size(411, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    saved.forEach(AppStorage.settings.put);
    final clock = FakeClock(DateTime(2026, 9, 21, 8, 0));
    final container = ProviderContainer(overrides: [
      ...testOverrides(),
      clockNowProvider.overrideWithValue(clock.call),
      reminderSchedulerProvider.overrideWithValue(scheduler),
      locationServiceProvider.overrideWithValue(
          FakeLocationService(state: LocationAccess.denied)),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: calendarTestTheme(), home: const AppShell()),
    ));
    await tester.pump();
    await tester.pump();
    return container;
  }

  testWidgets('the Clock tab is the real thing, not a placeholder', (tester) async {
    await openShell(tester);
    await tester.tap(find.descendant(
        of: find.byType(NavigationBar), matching: find.text('Clock')));
    await tester.pumpAndSettle();
    expect(find.text('Coming soon'), findsNothing);
    for (final t in [
      'Clock',
      'Sun-based alarm',
      'World clock',
      'Sadhana & vrat timer',
      'Paath stopwatch',
    ]) {
      expect(find.text(t), findsWidgets, reason: t);
    }
  });

  testWidgets('a sun alarm that is on is scheduled when the app opens, without '
      'visiting the Clock tab', (tester) async {
    await openShell(tester, saved: {
      'clock.sunAlarm': const SunAlarmSettings(
              enabled: true, event: SunEventKind.sunset, offsetMinutes: -15)
          .toMap(),
    });
    expect(scheduler.alerts[sunAlarmGroup], isNotEmpty);
    expect(scheduler.alerts[sunAlarmGroup]!.first.title, contains('Sunset'));
  });

  testWidgets('with the alarm off, opening the app schedules nothing', (tester) async {
    await openShell(tester);
    expect(scheduler.alerts[sunAlarmGroup] ?? const [], isEmpty);
  });
}
