import 'package:advance_calendar/features/clock/data/sun_alarm.dart';
import 'package:advance_calendar/features/clock/data/sun_times.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minutes between [a] and the UTC wall time [h]:[m] on [day] (negative = a is
/// earlier). Works in UTC so the tests do not depend on this machine's zone.
double minutesFrom(
  DateTime a,
  int day,
  int h,
  int m, {
  int month = 6,
  int year = 2026,
}) => a.difference(DateTime.utc(year, month, day, h, m)).inSeconds / 60.0;

void main() {
  // London, 21 June 2026: sunrise 03:43 UTC, sunset 20:21 UTC.
  const lat = 51.5074, lon = -0.1278;
  final day = DateTime(2026, 6, 21);

  group('offset labels', () {
    test('the seven quick options', () {
      expect(
        [for (final m in presetOffsets) offsetLabel(m, SunEventKind.sunrise)],
        [
          '1 hr before',
          '45 min before',
          '30 min before',
          '15 min before',
          'At sunrise',
          '15 min after',
          '30 min after',
        ],
      );
    });

    test('"at" names the chosen event', () {
      expect(offsetLabel(0, SunEventKind.sunset), 'At sunset');
    });

    test('custom offsets read naturally', () {
      expect(offsetLabel(-90, SunEventKind.sunrise), '1 hr 30 min before');
      expect(offsetLabel(120, SunEventKind.sunset), '2 hr after');
      expect(offsetLabel(7, SunEventKind.sunset), '7 min after');
      expect(offsetLabel(-1, SunEventKind.sunset), '1 min before');
    });
  });

  group('settings', () {
    test('survive a round trip through storage', () {
      for (final k in SunEventKind.values) {
        for (final off in [-60, -7, 0, 45, 1440, -1440]) {
          final s = SunAlarmSettings(
            enabled: true,
            event: k,
            offsetMinutes: off,
          );
          final back = SunAlarmSettings.fromMap(s.toMap());
          expect(
            (back.enabled, back.event, back.offsetMinutes),
            (true, k, off),
          );
        }
      }
    });

    test('garbage falls back to the defaults', () {
      for (final junk in [null, 'x', 5, <String, dynamic>{}]) {
        final s = SunAlarmSettings.fromMap(junk);
        expect(s.enabled, isFalse);
        expect(s.event, SunEventKind.sunrise);
        expect(s.offsetMinutes, -30);
      }
      expect(
        SunAlarmSettings.fromMap({'event': 'moonrise', 'offsetMinutes': 'soon'})
            .event,
        SunEventKind.sunrise,
      );
    });

    test('an absurd offset is clamped to a day either side', () {
      expect(
        const SunAlarmSettings().copyWith(offsetMinutes: 99999).offsetMinutes,
        1440,
      );
      expect(
        const SunAlarmSettings().copyWith(offsetMinutes: -99999).offsetMinutes,
        -1440,
      );
      expect(
        SunAlarmSettings.fromMap({'offsetMinutes': 5000}).offsetMinutes,
        1440,
      );
    });

    test('isPreset is true only for the quick options', () {
      for (final m in presetOffsets) {
        expect(
          const SunAlarmSettings().copyWith(offsetMinutes: m).isPreset,
          isTrue,
        );
      }
      for (final m in [-20, -75, 5, 45, 60]) {
        expect(
          const SunAlarmSettings().copyWith(offsetMinutes: m).isPreset,
          isFalse,
          reason: '$m',
        );
      }
    });
  });

  group('the alarm time', () {
    test('sunrise alarms are the sunrise plus each quick offset', () {
      for (final off in presetOffsets) {
        final a = sunAlarmOn(
          SunAlarmSettings(event: SunEventKind.sunrise, offsetMinutes: off),
          day,
          lat,
          lon,
        )!;
        expect(
          minutesFrom(a.alarm, 21, 3, 43 + off).abs(),
          lessThan(3),
          reason: '$off',
        );
        // The offset is exact, whatever the sun's own time.
        expect(a.alarm.difference(a.event).inMinutes, off);
      }
    });

    test('sunset alarms follow the sunset', () {
      final a = sunAlarmOn(
        const SunAlarmSettings(event: SunEventKind.sunset, offsetMinutes: -60),
        day,
        lat,
        lon,
      )!;
      expect(minutesFrom(a.alarm, 21, 19, 21).abs(), lessThan(3));
    });

    test('a custom offset of any number of minutes works, before or after', () {
      for (final off in [-97, -1, 1, 13, 200, -600]) {
        final a = sunAlarmOn(
          SunAlarmSettings(offsetMinutes: off),
          day,
          lat,
          lon,
        )!;
        expect(a.alarm.difference(a.event).inMinutes, off, reason: '$off');
      }
    });

    test('the alarm time changes through the seasons (it follows the sun)', () {
      const s = SunAlarmSettings(offsetMinutes: 0);
      final summer = sunAlarmOn(
        s,
        DateTime(2026, 6, 21),
        lat,
        lon,
      )!.alarm.toUtc();
      final winter = sunAlarmOn(
        s,
        DateTime(2026, 12, 21),
        lat,
        lon,
      )!.alarm.toUtc();
      // London sunrise is about 4h20 later in the winter.
      expect(
        (winter.hour * 60 + winter.minute) - (summer.hour * 60 + summer.minute),
        greaterThan(240),
      );
    });

    test('no sun event (polar night) means no alarm', () {
      expect(
        sunAlarmOn(
          const SunAlarmSettings(),
          DateTime(2026, 12, 21),
          78.2,
          15.6,
        ),
        isNull,
      );
    });
  });

  group('upcoming alarms', () {
    const s = SunAlarmSettings(offsetMinutes: -30);

    test('are 30 days of future times, in order, one per day', () {
      final now = DateTime.utc(2026, 6, 21, 0, 5);
      final list = upcomingSunAlarms(s, now, lat, lon);
      expect(list.length, inInclusiveRange(29, 31));
      expect(list.every((a) => a.alarm.isAfter(now)), isTrue);
      for (var i = 1; i < list.length; i++) {
        expect(list[i].alarm.isAfter(list[i - 1].alarm), isTrue);
      }
      expect({for (final a in list) a.day}.length, list.length);
    });

    test('today\'s alarm is skipped once it has passed', () {
      // Well after London's sunrise on the day.
      // (Times are UTC instants so the test means the same in any time zone.)
      final late = upcomingSunAlarms(
        s,
        DateTime.utc(2026, 6, 21, 12, 0),
        lat,
        lon,
      );
      expect(late.first.day.day, 22);
      // Before it, today's is first.
      final at = DateTime.utc(2026, 6, 20, 23, 0);
      final early = upcomingSunAlarms(s, at, lat, lon, days: 3);
      expect(early.first.day.day, 21);
      expect(early.first.alarm.isAfter(at), isTrue);
    });

    test('the days parameter limits how many', () {
      final l = upcomingSunAlarms(
        s,
        DateTime.utc(2026, 6, 1, 12),
        lat,
        lon,
        days: 7,
      );
      // Today's has passed here, so the 7 days hold 6 alarms still to come.
      expect(l.length, 6);
    });

    test('a large "after" offset can carry yesterday\'s sunset into today', () {
      // Sunset 20:21 UTC + 6 hours is 02:21 the next day.
      const late = SunAlarmSettings(
        event: SunEventKind.sunset,
        offsetMinutes: 360,
      );
      final now = DateTime.utc(2026, 6, 22, 0, 30);
      final list = upcomingSunAlarms(late, now, lat, lon, days: 2);
      expect(
        list.first.day.day,
        21,
        reason: "yesterday's sunset + 6h is still ahead",
      );
    });

    test('polar night gives none', () {
      expect(
        upcomingSunAlarms(s, DateTime(2026, 12, 15), 78.2, 15.6, days: 5),
        isEmpty,
      );
    });
  });

  group('the next sun event', () {
    // Amritsar. Sunset on 21 Sep 2026 is about 18:28 IST = 12:58 UTC.
    const aLat = 31.6340, aLon = 74.8723;
    final sunset21 = sunEventOn(
      SunEventKind.sunset,
      DateTime(2026, 9, 21),
      aLat,
      aLon,
    )!;

    test('is the sunset ahead, and today\'s when it has not happened yet', () {
      final now = sunset21.subtract(const Duration(hours: 3));
      final n = nextSunEvent(SunEventKind.sunset, now, aLat, aLon)!;
      expect(n.time, sunset21);
      expect(n.laterDay, isFalse);
    });

    test('after today\'s sunset it is tomorrow\'s, about a day on', () {
      final now = sunset21.add(const Duration(minutes: 30));
      final n = nextSunEvent(SunEventKind.sunset, now, aLat, aLon)!;
      expect(n.laterDay, isTrue);
      expect(n.time.difference(sunset21).inHours, inInclusiveRange(23, 24));
    });

    // The same instants as seen from phones on the other side of the world:
    // the phone's date can be a day off from the date at the place. The answer
    // must not depend on it.
    for (final minutesBefore in [15, 60, 240, 600, 700]) {
      test('$minutesBefore min before sunset, whatever the phone\'s date', () {
        // A local DateTime made from an instant: its date is this machine's.
        final now = sunset21
            .subtract(Duration(minutes: minutesBefore))
            .toLocal();
        final n = nextSunEvent(SunEventKind.sunset, now, aLat, aLon)!;
        expect(n.time, sunset21);
        expect(n.laterDay, isFalse);
      });
    }

    test('the sunrise works the same way', () {
      final rise = sunEventOn(
        SunEventKind.sunrise,
        DateTime(2026, 9, 21),
        aLat,
        aLon,
      )!;
      final n = nextSunEvent(
        SunEventKind.sunrise,
        rise.subtract(const Duration(minutes: 5)).toLocal(),
        aLat,
        aLon,
      )!;
      expect(n.time, rise);
    });

    // The phone's own date is what the code starts from, so it must not matter
    // where the phone is: for every hour of two days, at places all around the
    // world, the answer must be the earliest real sunset still ahead (worked
    // out here straight from UTC dates, with no reference to the phone's zone).
    test('is the earliest real sunset ahead, at any hour, at any longitude', () {
      for (final lon in [-150.0, -75.0, 0.0, 75.0, 150.0]) {
        for (var h = 0; h < 48; h++) {
          final instant = DateTime.utc(2026, 9, 20).add(Duration(hours: h));
          DateTime? want;
          for (var d = -2; d <= 3; d++) {
            final day = DateTime.utc(instant.year, instant.month, instant.day + d);
            final t = sunTimesFor(day.year, day.month, day.day, 30, lon).sunset!;
            if (t.isAfter(instant) && (want == null || t.isBefore(want))) want = t;
          }
          final got = nextSunEvent(SunEventKind.sunset, instant.toLocal(), 30, lon)!;
          expect(got.time.toUtc(), want, reason: 'lon $lon, +${h}h');
        }
      }
    });

    test('nothing in polar night', () {
      expect(
        nextSunEvent(
          SunEventKind.sunset,
          DateTime.utc(2026, 12, 15, 12),
          78.2,
          15.6,
        ),
        isNull,
      );
    });
  });
}
