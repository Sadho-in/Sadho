import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart'
    show sunAlarmGroup;
import 'package:advance_calendar/features/clock/application/sun_alarm_provider.dart';
import 'package:advance_calendar/features/clock/data/sun_alarm.dart';
import 'package:advance_calendar/features/clock/presentation/tools/sun_alarm_page.dart';
import 'package:advance_calendar/features/clock/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'clock_ui_support.dart';

void main() {
  const amritsar = (lat: 31.6340, lon: 74.8723);
  const london = (lat: 51.5074, lon: -0.1278);

  /// What the page should show as the next alarm for [s] at [p], computed
  /// straight from the sun functions (whose accuracy is tested on its own).
  SunAlarmTime? nextAlarm(
    SunAlarmSettings s,
    DateTime now,
    ({double lat, double lon}) p,
  ) {
    final l = upcomingSunAlarms(s, now, p.lat, p.lon, days: 3);
    return l.isEmpty ? null : l.first;
  }

  Future<Rig> open(
    WidgetTester tester, {
    DateTime? now,
    FakeLocationService? location,
    FakeScheduler? scheduler,
    Map<String, Object?> saved = const {},
    double width = 411,
    double height = 1800,
  }) => pumpClock(
    tester,
    const SunAlarmPage(),
    now: now,
    location: location,
    scheduler: scheduler,
    saved: saved,
    width: width,
    height: height,
  );

  bool chipSelected(WidgetTester t, String key) =>
      t.widget<ChoiceChip>(byKey(key)).selected;

  group('the computed alarm time', () {
    testWidgets('is shown even before the alarm is switched on', (
      tester,
    ) async {
      final rig = await open(tester);
      final want = nextAlarm(
        const SunAlarmSettings(),
        rig.clock.now,
        amritsar,
      )!;
      expect(textOf(tester, 'sun-alarm-time'), jm(want.alarm));
      expect(find.text('Alarm would ring at'), findsOneWidget);
      expect(find.text('Alarm rings at'), findsNothing);
    });

    testWidgets('describes the sun event and the offset', (tester) async {
      final rig = await open(tester);
      final want = nextAlarm(
        const SunAlarmSettings(),
        rig.clock.now,
        amritsar,
      )!;
      final detail = textOf(tester, 'sun-alarm-detail');
      expect(detail, contains('Sunrise ${jm(want.event)}'));
      expect(detail, contains('30 min before'));
    });

    testWidgets('names the day: Today when it is still ahead, else Tomorrow', (
      tester,
    ) async {
      // 03:00 local: Amritsar's sunrise (about 06:10 IST) has not happened...
      // ...but the day depends on this machine's zone, so pin it from the data.
      final rig = await open(tester);
      final want = nextAlarm(
        const SunAlarmSettings(),
        rig.clock.now,
        amritsar,
      )!;
      final today = DateTime(
        rig.clock.now.year,
        rig.clock.now.month,
        rig.clock.now.day,
      );
      final same =
          DateTime(want.alarm.year, want.alarm.month, want.alarm.day) == today;
      expect(
        textOf(tester, 'sun-alarm-detail'),
        startsWith(same ? 'Today' : 'Tomorrow'),
      );
    });

    testWidgets('shows today\'s sunrise and sunset here', (tester) async {
      final rig = await open(tester);
      final d = DateTime(
        rig.clock.now.year,
        rig.clock.now.month,
        rig.clock.now.day,
      );
      final rise = sunEventOn(
        SunEventKind.sunrise,
        d,
        amritsar.lat,
        amritsar.lon,
      )!;
      final set = sunEventOn(
        SunEventKind.sunset,
        d,
        amritsar.lat,
        amritsar.lon,
      )!;
      expect(
        textOf(tester, 'sun-today'),
        'Today here: sunrise ${jm(rise)} · sunset ${jm(set)}',
      );
    });

    testWidgets('a place with no sunrise says so instead of a time', (
      tester,
    ) async {
      await open(
        tester,
        now: DateTime(2026, 12, 15, 12),
        saved: {
          'clock.location': {'lat': 78.2, 'lon': 15.6},
        },
      );
      expect(textOf(tester, 'sun-alarm-time'), '—');
      expect(textOf(tester, 'sun-alarm-detail'), contains('No sunrise'));
    });
  });

  group('the on/off switch', () {
    testWidgets(
      'is off to begin with; turning on asks permission and schedules',
      (tester) async {
        final rig = await open(tester);
        expect(
          tester.widget<SwitchListTile>(byKey('sun-alarm-switch')).value,
          isFalse,
        );
        expect(rig.scheduler.alerts[sunAlarmGroup] ?? const [], isEmpty);
        await tester.tap(byKey('sun-alarm-switch'));
        await tester.pump();
        await tester.pump();
        expect(rig.scheduler.permissionRequests, 1);
        expect(
          rig.scheduler.alerts[sunAlarmGroup]!.length,
          inInclusiveRange(29, 31),
        );
        expect(find.text('Alarm rings at'), findsOneWidget);
      },
    );

    testWidgets('turning off clears the schedule', (tester) async {
      final rig = await open(tester);
      await tester.tap(byKey('sun-alarm-switch'));
      await tester.pump();
      await tester.tap(byKey('sun-alarm-switch'));
      await tester.pump();
      await tester.pump();
      expect(rig.scheduler.alerts[sunAlarmGroup], isEmpty);
      expect(find.text('Alarm would ring at'), findsOneWidget);
    });

    testWidgets('if notifications are refused it says so', (tester) async {
      final rig = await open(
        tester,
        scheduler: FakeScheduler(permission: false),
      );
      await tester.tap(byKey('sun-alarm-switch'));
      await tester.pump();
      await tester.pump();
      expect(find.textContaining('Allow notifications'), findsOneWidget);
      expect(rig.container.read(sunAlarmProvider).enabled, isTrue);
    });
  });

  group('Sunrise ⟷ Sunset', () {
    testWidgets('a two-way switch, Sunrise to begin with', (tester) async {
      await open(tester);
      final sb = tester.widget<SegmentedButton<SunEventKind>>(
        byKey('sun-event'),
      );
      expect(sb.selected, {SunEventKind.sunrise});
      expect([for (final s in sb.segments) s.value], SunEventKind.values);
      expect(find.text('Sunrise'), findsOneWidget);
      expect(find.text('Sunset'), findsOneWidget);
    });

    testWidgets('switching to Sunset follows the sunset instead', (
      tester,
    ) async {
      final rig = await open(tester);
      await tester.tap(find.text('Sunset'));
      await tester.pump();
      const s = SunAlarmSettings(event: SunEventKind.sunset);
      final want = nextAlarm(s, rig.clock.now, amritsar)!;
      expect(textOf(tester, 'sun-alarm-time'), jm(want.alarm));
      expect(
        textOf(tester, 'sun-alarm-detail'),
        contains('Sunset ${jm(want.event)}'),
      );
      // ... and back.
      await tester.tap(find.text('Sunrise'));
      await tester.pump();
      expect(textOf(tester, 'sun-alarm-detail'), contains('Sunrise'));
    });

    testWidgets('the offset chips name the chosen event', (tester) async {
      await open(tester);
      expect(find.text('At sunrise'), findsOneWidget);
      await tester.tap(find.text('Sunset'));
      await tester.pump();
      expect(find.text('At sunset'), findsOneWidget);
      expect(find.text('At sunrise'), findsNothing);
    });

    testWidgets('an alarm that is on is rescheduled for the other event', (
      tester,
    ) async {
      final rig = await open(tester);
      await tester.tap(byKey('sun-alarm-switch'));
      await tester.pump();
      final rise = rig.scheduler.alerts[sunAlarmGroup]!.first;
      expect(rise.title, contains('Sunrise'));
      await tester.tap(find.text('Sunset'));
      await tester.pump();
      await tester.pump();
      final set = rig.scheduler.alerts[sunAlarmGroup]!.first;
      expect(set.title, contains('Sunset'));
      expect(set.when, isNot(rise.when));
    });
  });

  group('quick offsets', () {
    testWidgets(
      'are 1 hr / 45 / 30 / 15 min before, at, and 15 / 30 min after',
      (tester) async {
        await open(tester);
        for (final label in [
          '1 hr before',
          '45 min before',
          '30 min before',
          '15 min before',
          'At sunrise',
          '15 min after',
          '30 min after',
          'Custom',
        ]) {
          expect(find.text(label), findsOneWidget, reason: label);
        }
      },
    );

    testWidgets('30 min before is chosen to begin with', (tester) async {
      await open(tester);
      expect(chipSelected(tester, 'offset--30'), isTrue);
      for (final m in presetOffsets.where((m) => m != -30)) {
        expect(chipSelected(tester, 'offset-$m'), isFalse, reason: '$m');
      }
      expect(chipSelected(tester, 'offset-custom'), isFalse);
    });

    for (final off in presetOffsets) {
      testWidgets(
        '${offsetLabel(off, SunEventKind.sunrise)}: sets the alarm to '
        'the sunrise ${off >= 0 ? '+' : ''}$off min',
        (tester) async {
          final rig = await open(tester);
          await tester.tap(byKey('offset-$off'));
          await tester.pump();
          final s = SunAlarmSettings(offsetMinutes: off);
          final want = nextAlarm(s, rig.clock.now, amritsar)!;
          expect(textOf(tester, 'sun-alarm-time'), jm(want.alarm));
          expect(want.alarm.difference(want.event).inMinutes, off);
          expect(chipSelected(tester, 'offset-$off'), isTrue);
          expect(rig.container.read(sunAlarmProvider).offsetMinutes, off);
          expect(
            AppStorage.settings.get('clock.sunAlarm')['offsetMinutes'],
            off,
          );
        },
      );
    }

    testWidgets('an alarm that is on is rescheduled with the new offset', (
      tester,
    ) async {
      final rig = await open(tester);
      await tester.tap(byKey('sun-alarm-switch'));
      await tester.pump();
      final before = rig.scheduler.alerts[sunAlarmGroup]!.first.when;
      await tester.tap(byKey('offset--60'));
      await tester.pump();
      await tester.pump();
      final after = rig.scheduler.alerts[sunAlarmGroup]!.first.when;
      expect(before.difference(after).inMinutes, 30);
    });
  });

  group('custom offset', () {
    Future<void> openCustom(WidgetTester tester) async {
      await tester.tap(byKey('offset-custom'));
      await tester.pump();
    }

    Future<void> type(WidgetTester tester, String text) async {
      await tester.enterText(byKey('custom-minutes'), text);
      await tester.pump();
    }

    testWidgets('the field appears only for Custom', (tester) async {
      await open(tester);
      expect(byKey('custom-minutes'), findsNothing);
      await openCustom(tester);
      expect(byKey('custom-minutes'), findsOneWidget);
      expect(byKey('custom-direction'), findsOneWidget);
      expect(chipSelected(tester, 'offset-custom'), isTrue);
      expect(chipSelected(tester, 'offset--30'), isFalse);
      await tester.tap(byKey('offset-15'));
      await tester.pump();
      expect(byKey('custom-minutes'), findsNothing);
    });

    testWidgets('any number of minutes, before', (tester) async {
      final rig = await open(tester);
      await openCustom(tester);
      await type(tester, '97');
      expect(rig.container.read(sunAlarmProvider).offsetMinutes, -97);
      final want = nextAlarm(
        rig.container.read(sunAlarmProvider),
        rig.clock.now,
        amritsar,
      )!;
      expect(textOf(tester, 'sun-alarm-time'), jm(want.alarm));
      expect(
        textOf(tester, 'sun-alarm-detail'),
        contains('1 hr 37 min before'),
      );
    });

    testWidgets('and after', (tester) async {
      final rig = await open(tester);
      await openCustom(tester);
      await type(tester, '20');
      await tester.tap(find.text('After'));
      await tester.pump();
      expect(rig.container.read(sunAlarmProvider).offsetMinutes, 20);
      expect(textOf(tester, 'sun-alarm-detail'), contains('20 min after'));
      await tester.tap(find.text('Before'));
      await tester.pump();
      expect(rig.container.read(sunAlarmProvider).offsetMinutes, -20);
    });

    testWidgets('a big offset such as 3 hours 45 minutes', (tester) async {
      final rig = await open(tester);
      await openCustom(tester);
      await tester.tap(find.text('After'));
      await tester.pump();
      await type(tester, '225');
      expect(rig.container.read(sunAlarmProvider).offsetMinutes, 225);
      expect(textOf(tester, 'sun-alarm-detail'), contains('3 hr 45 min after'));
    });

    testWidgets('only digits are accepted, and never more than a day', (
      tester,
    ) async {
      final rig = await open(tester);
      await openCustom(tester);
      await type(tester, '1x2-3.');
      expect(
        tester.widget<TextField>(byKey('custom-minutes')).controller!.text,
        '123',
      );
      await type(tester, '99999');
      // 4 digits at most, clamped to 24 hours.
      expect(
        rig.container.read(sunAlarmProvider).offsetMinutes.abs(),
        lessThanOrEqualTo(1440),
      );
    });

    testWidgets('an empty field changes nothing', (tester) async {
      final rig = await open(tester);
      await openCustom(tester);
      await type(tester, '45');
      await type(tester, '');
      expect(rig.container.read(sunAlarmProvider).offsetMinutes, -45);
    });

    testWidgets('zero minutes is "at" the event', (tester) async {
      final rig = await open(tester);
      await openCustom(tester);
      await type(tester, '0');
      expect(rig.container.read(sunAlarmProvider).offsetMinutes, 0);
      expect(textOf(tester, 'sun-alarm-detail'), contains('at sunrise'));
      expect(
        byKey('custom-minutes'),
        findsOneWidget,
        reason: 'stays open while editing',
      );
    });

    testWidgets('a saved custom offset reopens in the Custom editor', (
      tester,
    ) async {
      await open(
        tester,
        saved: {
          'clock.sunAlarm': const SunAlarmSettings(offsetMinutes: 20).toMap(),
        },
      );
      expect(chipSelected(tester, 'offset-custom'), isTrue);
      expect(
        tester.widget<TextField>(byKey('custom-minutes')).controller!.text,
        '20',
      );
      final dir = tester.widget<SegmentedButton<bool>>(
        byKey('custom-direction'),
      );
      expect(dir.selected, {true}, reason: 'after');
    });

    testWidgets('a custom offset on an alarm that is on reschedules it', (
      tester,
    ) async {
      final rig = await open(tester);
      await tester.tap(byKey('sun-alarm-switch'));
      await tester.pump();
      await openCustom(tester);
      await type(tester, '7');
      await tester.pump();
      final first = rig.scheduler.alerts[sunAlarmGroup]!.first;
      expect(first.body, contains('7 min before'));
    });
  });

  group('where the sun is measured', () {
    testWidgets(
      'with no permission it uses Amritsar and offers to use the phone',
      (tester) async {
        await open(tester);
        expect(textOf(tester, 'sun-where'), contains('Using Amritsar'));
        expect(find.text('Use my location'), findsOneWidget);
      },
    );

    testWidgets('"Use my location" asks, and the times move to the new place', (
      tester,
    ) async {
      final phone = FakeLocationService(
        state: LocationAccess.denied,
        lat: 51.5074,
        lon: -0.1278,
      );
      final rig = await open(tester, location: phone);
      final before = textOf(tester, 'sun-alarm-time');
      await tester.tap(byKey('use-location'));
      await tester.pump();
      await tester.pump();
      expect(phone.asks, 1);
      expect(textOf(tester, 'sun-where'), 'Using your location');
      final want = nextAlarm(const SunAlarmSettings(), rig.clock.now, london)!;
      expect(textOf(tester, 'sun-alarm-time'), jm(want.alarm));
      expect(textOf(tester, 'sun-alarm-time'), isNot(before));
    });

    testWidgets('a phone that already allows it is used without asking', (
      tester,
    ) async {
      final phone = FakeLocationService(lat: 51.5074, lon: -0.1278);
      await open(tester, location: phone);
      await tester.pump();
      expect(textOf(tester, 'sun-where'), 'Using your location');
      expect(phone.asks, 0);
    });

    testWidgets('when it was blocked the button opens Settings instead', (
      tester,
    ) async {
      final phone = FakeLocationService(state: LocationAccess.deniedForever);
      await open(tester, location: phone);
      await tester.pump();
      expect(find.text('Settings'), findsOneWidget);
      expect(textOf(tester, 'sun-where'), contains('blocked'));
      await tester.tap(byKey('use-location'));
      await tester.pump();
      expect(phone.settingsOpened, 1);
      expect(phone.asks, 0);
    });

    testWidgets('a position that cannot be read is said plainly', (
      tester,
    ) async {
      await open(tester, location: FakeLocationService(hasFix: false));
      await tester.pump();
      expect(
        find.textContaining('could not read your position'),
        findsOneWidget,
      );
    });

    testWidgets(
      'the alarm time is worked out from the place: London vs Amritsar',
      (tester) async {
        final a = await open(tester);
        final amritsarTime = textOf(tester, 'sun-alarm-time');
        expect(a.location.asks, 0);
        await tester.pumpWidget(const SizedBox());
        await open(
          tester,
          location: FakeLocationService(lat: 51.5074, lon: -0.1278),
        );
        await tester.pump();
        expect(textOf(tester, 'sun-alarm-time'), isNot(amritsarTime));
      },
    );
  });

  group('the daily recompute', () {
    testWidgets('the shown day moves on once today\'s alarm has passed', (
      tester,
    ) async {
      // Work from the alarm itself, so this holds in any time zone.
      final alarm = upcomingSunAlarms(
        const SunAlarmSettings(),
        DateTime(2026, 9, 20, 12),
        amritsar.lat,
        amritsar.lon,
        days: 3,
      )[1].alarm;
      final midnight = DateTime(alarm.year, alarm.month, alarm.day, 0, 0, 1);
      await open(tester, now: midnight);
      expect(textOf(tester, 'sun-alarm-detail'), startsWith('Today'));
      await tester.pumpWidget(const SizedBox());
      await open(tester, now: alarm.add(const Duration(minutes: 1)));
      expect(textOf(tester, 'sun-alarm-detail'), startsWith('Tomorrow'));
    });

    testWidgets('the alarm follows the sun through the seasons', (
      tester,
    ) async {
      await open(
        tester,
        now: DateTime(2026, 6, 20, 23, 0),
        location: FakeLocationService(lat: 51.5074, lon: -0.1278),
      );
      await tester.pump();
      final june = textOf(tester, 'sun-alarm-time');
      await tester.pumpWidget(const SizedBox());
      await open(
        tester,
        now: DateTime(2026, 12, 20, 23, 0),
        location: FakeLocationService(lat: 51.5074, lon: -0.1278),
      );
      await tester.pump();
      expect(textOf(tester, 'sun-alarm-time'), isNot(june));
    });
  });

  testWidgets('fits a small phone and the dark theme', (tester) async {
    await pumpClock(
      tester,
      const SunAlarmPage(),
      width: 320,
      height: 568,
      brightness: Brightness.dark,
    );
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(byKey('offset-custom'));
    await tester.pump();
    await tester.tap(byKey('offset-custom'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      byKey('sun-where'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });
}
