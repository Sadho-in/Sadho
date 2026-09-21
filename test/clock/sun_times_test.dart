import 'package:advance_calendar/features/clock/data/sun_times.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minutes between [a] and the expected UTC wall time [h]:[m] on [day]
/// (negative = a is earlier).
double minutesFrom(
  DateTime a,
  int day,
  int h,
  int m, {
  int month = 6,
  int year = 2026,
}) => a.difference(DateTime.utc(year, month, day, h, m)).inSeconds / 60.0;

void main() {
  group('against sunrise/sunset times I know', () {
    // London on the summer solstice: 04:43 and 21:21 BST = 03:43 / 20:21 UTC.
    test('London, June solstice', () {
      final s = sunTimesFor(2026, 6, 21, 51.5074, -0.1278);
      expect(minutesFrom(s.sunrise!, 21, 3, 43).abs(), lessThan(3));
      expect(minutesFrom(s.sunset!, 21, 20, 21).abs(), lessThan(3));
    });

    // ... and the winter solstice: 08:04 / 15:53 GMT.
    test('London, December solstice', () {
      final s = sunTimesFor(2026, 12, 21, 51.5074, -0.1278);
      expect(minutesFrom(s.sunrise!, 21, 8, 4, month: 12).abs(), lessThan(3));
      expect(minutesFrom(s.sunset!, 21, 15, 53, month: 12).abs(), lessThan(3));
    });

    // New York, June solstice: 05:25 / 20:31 EDT = 09:25 UTC / 00:31 UTC next day.
    test('New York, June solstice (sunset falls on the next UTC day)', () {
      final s = sunTimesFor(2026, 6, 21, 40.7128, -74.0060);
      expect(minutesFrom(s.sunrise!, 21, 9, 25).abs(), lessThan(3));
      expect(minutesFrom(s.sunset!, 22, 0, 31).abs(), lessThan(3));
    });

    // Sydney, June solstice (winter): 07:00 / 16:54 AEST = 21:00 UTC the day
    // before / 06:54 UTC.
    test('Sydney, June solstice (sunrise falls on the previous UTC day)', () {
      final s = sunTimesFor(2026, 6, 21, -33.8688, 151.2093);
      expect(minutesFrom(s.sunrise!, 20, 21, 0).abs(), lessThan(4));
      expect(minutesFrom(s.sunset!, 21, 6, 54).abs(), lessThan(4));
    });

    // Delhi, June solstice: 05:23 / 19:22 IST = 23:53 UTC (the day before) /
    // 13:52 UTC.
    test('Delhi, June solstice', () {
      final s = sunTimesFor(2026, 6, 21, 28.6139, 77.2090);
      expect(minutesFrom(s.sunrise!, 20, 23, 53).abs(), lessThan(3));
      expect(minutesFrom(s.sunset!, 21, 13, 52).abs(), lessThan(3));
    });

    // Delhi, December solstice: 07:10 / 17:29 IST = 01:40 / 11:59 UTC.
    test('Delhi, December solstice', () {
      final s = sunTimesFor(2026, 12, 21, 28.6139, 77.2090);
      expect(minutesFrom(s.sunrise!, 21, 1, 40, month: 12).abs(), lessThan(3));
      expect(minutesFrom(s.sunset!, 21, 11, 59, month: 12).abs(), lessThan(3));
    });

    // Mumbai, June solstice: 06:02 / 19:19 IST = 00:32 / 13:49 UTC.
    test('Mumbai, June solstice', () {
      final s = sunTimesFor(2026, 6, 21, 19.0760, 72.8777);
      expect(minutesFrom(s.sunrise!, 21, 0, 32).abs(), lessThan(3));
      expect(minutesFrom(s.sunset!, 21, 13, 49).abs(), lessThan(3));
    });

    // Amritsar, the app's home city, checked against Delhi (known above): at
    // 31.6 N the June day is longer than Delhi's, and being 2.3 degrees further
    // west the sun comes about 9 minutes later than at the same latitude.
    test('Amritsar, June solstice: a longer day than Delhi, near 05:25 / 19:38 IST', () {
      final a = sunTimesFor(2026, 6, 21, 31.6340, 74.8723);
      final d = sunTimesFor(2026, 6, 21, 28.6139, 77.2090);
      final aDay = a.sunset!.difference(a.sunrise!);
      final dDay = d.sunset!.difference(d.sunrise!);
      expect((aDay - dDay).inMinutes, inInclusiveRange(10, 30));
      expect(minutesFrom(a.sunrise!, 20, 23, 55).abs(), lessThan(5));
      expect(minutesFrom(a.sunset!, 21, 14, 8).abs(), lessThan(5));
    });
  });

  group('physical sanity', () {
    test(
      'at the equator on an equinox: about 12 hours, noon about 12:00 UTC',
      () {
        final s = sunTimesFor(2026, 3, 20, 0, 0);
        final day = s.sunset!.difference(s.sunrise!);
        expect(day.inMinutes, inInclusiveRange(12 * 60 + 4, 12 * 60 + 12));
        final noon = s.sunrise!.add(day ~/ 2);
        expect(minutesFrom(noon, 20, 12, 0, month: 3).abs(), lessThan(10));
      },
    );

    test('sunrise is always before sunset, all year, at many latitudes', () {
      for (final lat in [-50.0, -20.0, 0.0, 15.0, 31.6, 45.0, 55.0]) {
        for (var month = 1; month <= 12; month++) {
          final s = sunTimesFor(2026, month, 15, lat, 74.87);
          expect(s.hasBoth, isTrue, reason: 'lat $lat month $month');
          expect(
            s.sunrise!.isBefore(s.sunset!),
            isTrue,
            reason: 'lat $lat month $month',
          );
        }
      }
    });

    test('days are longer in summer than in winter (northern hemisphere)', () {
      Duration day(int month) {
        final s = sunTimesFor(2026, month, 21, 31.634, 74.872);
        return s.sunset!.difference(s.sunrise!);
      }

      expect(day(6), greaterThan(day(3)));
      expect(day(3), greaterThan(day(12)));
      expect(day(6).inHours, inInclusiveRange(13, 14));
      expect(day(12).inHours, inInclusiveRange(10, 11));
    });

    test('and the reverse in the southern hemisphere', () {
      Duration day(int month) {
        final s = sunTimesFor(2026, month, 21, -33.87, 151.21);
        return s.sunset!.difference(s.sunrise!);
      }

      expect(day(12), greaterThan(day(6)));
    });

    test('sunrise moves earlier through spring, day by day', () {
      var last = sunTimesFor(2026, 3, 1, 51.5, -0.13).sunrise!;
      for (var d = 2; d <= 28; d++) {
        final t = sunTimesFor(2026, 3, d, 51.5, -0.13).sunrise!;
        // The time of day, not the date, gets earlier.
        final today = t.hour * 60 + t.minute;
        final before = last.hour * 60 + last.minute;
        expect(today, lessThan(before), reason: 'March $d');
        last = t;
      }
    });

    test('a place further east sees the sun earlier (in UTC)', () {
      final west = sunTimesFor(2026, 9, 22, 30, 60);
      final east = sunTimesFor(2026, 9, 22, 30, 90);
      expect(east.sunrise!.isBefore(west.sunrise!), isTrue);
      expect(
        west.sunrise!.difference(east.sunrise!).inMinutes,
        closeTo(120, 3),
        reason: '30 degrees of longitude = 2 hours',
      );
    });

    test('results are UTC instants', () {
      final s = sunTimesFor(2026, 9, 22, 31.6, 74.9);
      expect(s.sunrise!.isUtc, isTrue);
      expect(s.sunset!.isUtc, isTrue);
    });

    test('leap day and year ends work', () {
      expect(sunTimesFor(2028, 2, 29, 31.6, 74.9).hasBoth, isTrue);
      expect(sunTimesFor(2026, 12, 31, 31.6, 74.9).hasBoth, isTrue);
      expect(sunTimesFor(2026, 1, 1, 31.6, 74.9).hasBoth, isTrue);
    });
  });

  group('no sunrise or sunset (polar regions)', () {
    test('midnight sun: the sun does not set (Tromso, June)', () {
      final s = sunTimesFor(2026, 6, 21, 69.65, 18.96);
      expect(s.polarDay, isTrue);
      expect(s.polarNight, isFalse);
      expect(s.sunrise, isNull);
      expect(s.sunset, isNull);
      expect(s.hasBoth, isFalse);
    });

    test('polar night: the sun does not rise (Tromso, December)', () {
      final s = sunTimesFor(2026, 12, 21, 69.65, 18.96);
      expect(s.polarNight, isTrue);
      expect(s.polarDay, isFalse);
      expect(s.sunrise, isNull);
    });

    test('the poles themselves do not crash', () {
      expect(() => sunTimesFor(2026, 6, 21, 90, 0), returnsNormally);
      expect(() => sunTimesFor(2026, 6, 21, -90, 0), returnsNormally);
      expect(sunTimesFor(2026, 6, 21, 90, 0).polarDay, isTrue);
      expect(sunTimesFor(2026, 6, 21, -90, 0).polarNight, isTrue);
    });

    test('ordinary latitudes always have both', () {
      expect(sunTimesFor(2026, 6, 21, 51.5, -0.13).hasBoth, isTrue);
      expect(sunTimesFor(2026, 12, 21, 51.5, -0.13).hasBoth, isTrue);
    });
  });
}
