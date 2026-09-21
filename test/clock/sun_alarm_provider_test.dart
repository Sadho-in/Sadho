import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/clock/application/location_provider.dart';
import 'package:advance_calendar/features/clock/application/sun_alarm_provider.dart';
import 'package:advance_calendar/features/clock/data/sun_alarm.dart';
import 'package:advance_calendar/features/clock/services/location_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'clock_support.dart';

void main() {
  // Location: London (the fake phone allows it and knows where it is).
  FakeLocationService london() =>
      FakeLocationService(lat: 51.5074, lon: -0.1278);

  late FakeScheduler scheduler;
  setUp(() => scheduler = FakeScheduler());

  List<ScheduledAlert> alerts() => scheduler.alerts[sunAlarmGroup] ?? const [];

  test('starts switched off, sunrise, 30 min before', () {
    final c = clockContainer(scheduler: scheduler, location: london());
    final s = c.read(sunAlarmProvider);
    expect(
      (s.enabled, s.event, s.offsetMinutes),
      (false, SunEventKind.sunrise, -30),
    );
  });

  test('while off nothing is scheduled', () async {
    final c = clockContainer(scheduler: scheduler, location: london());
    c.read(sunAlarmProvider);
    await pumpEventQueue();
    expect(alerts(), isEmpty);
  });

  test(
    'turning it on asks for notification permission and schedules 30 days',
    () async {
      final c = clockContainer(scheduler: scheduler, location: london());
      final allowed = await c.read(sunAlarmProvider.notifier).setEnabled(true);
      await pumpEventQueue();
      expect(allowed, isTrue);
      expect(scheduler.permissionRequests, 1);
      expect(alerts().length, inInclusiveRange(29, 31));
    },
  );

  test(
    'each scheduled day is the sunrise plus the offset, in the future',
    () async {
      final clock = FakeClock(DateTime.utc(2026, 6, 20, 12, 0));
      final c = clockContainer(
        clock: clock,
        scheduler: scheduler,
        location: london(),
      );
      final n = c.read(sunAlarmProvider.notifier);
      await n.setEnabled(true);
      n.setOffset(-45);
      await pumpEventQueue();
      final first = alerts().first;
      // London 21 June: sunrise 03:43 UTC, so 45 minutes before is 02:58 UTC.
      final d = first.when
          .toUtc()
          .difference(DateTime.utc(2026, 6, 21, 2, 58))
          .inMinutes;
      expect(d.abs(), lessThan(3));
      for (final a in alerts()) {
        expect(a.when.isAfter(clock.now), isTrue);
      }
      for (var i = 1; i < alerts().length; i++) {
        expect(alerts()[i].when.isAfter(alerts()[i - 1].when), isTrue);
      }
      // One notification id per alert.
      expect({for (final a in alerts()) a.id}.length, alerts().length);
    },
  );

  test('the alarm text names the event and the offset', () async {
    final c = clockContainer(scheduler: scheduler, location: london());
    final n = c.read(sunAlarmProvider.notifier);
    await n.setEnabled(true);
    n.setEvent(SunEventKind.sunset);
    n.setOffset(15);
    await pumpEventQueue();
    expect(alerts().first.title, contains('Sunset'));
    expect(alerts().first.body, contains('15 min after'));
    n.setEvent(SunEventKind.sunrise);
    await pumpEventQueue();
    expect(alerts().first.title, contains('Sunrise'));
  });

  test('changing the event, or the offset, replaces the schedule', () async {
    final c = clockContainer(scheduler: scheduler, location: london());
    final n = c.read(sunAlarmProvider.notifier);
    await n.setEnabled(true);
    await pumpEventQueue();
    final rise = alerts().first.when;
    n.setEvent(SunEventKind.sunset);
    await pumpEventQueue();
    final set = alerts().first.when;
    expect(set, isNot(rise));
    n.setOffset(0);
    await pumpEventQueue();
    expect(alerts().first.when, isNot(set));
  });

  test('switching it off removes every scheduled alarm', () async {
    final c = clockContainer(scheduler: scheduler, location: london());
    final n = c.read(sunAlarmProvider.notifier);
    await n.setEnabled(true);
    await pumpEventQueue();
    expect(alerts(), isNotEmpty);
    await n.setEnabled(false);
    await pumpEventQueue();
    expect(alerts(), isEmpty);
    expect(scheduler.permissionRequests, 1, reason: 'off does not ask');
  });

  test('it only touches its own group of notifications', () async {
    final c = clockContainer(scheduler: scheduler, location: london());
    await c.read(sunAlarmProvider.notifier).setEnabled(true);
    await pumpEventQueue();
    expect(scheduler.alertReplacements.toSet(), {sunAlarmGroup});
    expect(scheduler.scheduled, isEmpty);
    expect(scheduler.rescheduledAll, isEmpty);
  });

  test(
    'a refused notification permission is reported, and the alarm still saved',
    () async {
      scheduler.permission = false;
      final c = clockContainer(scheduler: scheduler, location: london());
      final allowed = await c.read(sunAlarmProvider.notifier).setEnabled(true);
      expect(allowed, isFalse);
      expect(c.read(sunAlarmProvider).enabled, isTrue);
    },
  );

  test('settings are saved and come back after a restart', () async {
    final c = clockContainer(scheduler: scheduler, location: london());
    final n = c.read(sunAlarmProvider.notifier);
    await n.setEnabled(true);
    n.setEvent(SunEventKind.sunset);
    n.setOffset(-97);
    final saved = AppStorage.settings.get('clock.sunAlarm');
    final again = clockContainer(
      scheduler: FakeScheduler(),
      location: london(),
      saved: {'clock.sunAlarm': saved},
    );
    final s = again.read(sunAlarmProvider);
    expect(
      (s.enabled, s.event, s.offsetMinutes),
      (true, SunEventKind.sunset, -97),
    );
  });

  test(
    'on app start an enabled alarm is scheduled again (a new day, new times)',
    () async {
      final c = clockContainer(
        scheduler: scheduler,
        location: london(),
        saved: {
          'clock.sunAlarm': const SunAlarmSettings(
            enabled: true,
            offsetMinutes: -15,
          ).toMap(),
        },
      );
      c.read(sunAlarmProvider);
      await pumpEventQueue();
      expect(alerts(), isNotEmpty);
    },
  );

  test('a new location recomputes the alarms', () async {
    final phone = FakeLocationService(state: LocationAccess.denied);
    final c = clockContainer(scheduler: scheduler, location: phone);
    final n = c.read(sunAlarmProvider.notifier);
    await n.setEnabled(true);
    await pumpEventQueue();
    final amritsar = alerts().first.when;
    // The phone now grants location and reports London.
    phone.state = LocationAccess.granted;
    await c.read(locationProvider.notifier).refresh();
    await pumpEventQueue();
    expect(c.read(locationProvider).point.source, LocationSource.device);
    expect(alerts().first.when, isNot(amritsar));
  });

  test('a scheduling failure never crashes the app', () async {
    final broken = _BrokenScheduler();
    final c = clockContainer(scheduler: broken, location: london());
    await c.read(sunAlarmProvider.notifier).setEnabled(true);
    await pumpEventQueue();
    expect(broken.attempts, greaterThan(0));
    expect(c.read(sunAlarmProvider).enabled, isTrue);
  });

  test('the preview list follows the settings and the place', () async {
    final c = clockContainer(location: london());
    c.read(sunAlarmProvider.notifier).setOffset(0);
    final list = c.read(upcomingSunAlarmsProvider);
    expect(list.length, inInclusiveRange(6, 8));
    expect(list.first.alarm, list.first.event);
  });
}

class _BrokenScheduler extends FakeScheduler {
  int attempts = 0;

  @override
  Future<void> replaceAlerts(String group, List<ScheduledAlert> next) async {
    attempts++;
    throw StateError('the alarm system said no');
  }
}
