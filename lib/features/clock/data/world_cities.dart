import 'package:timezone/timezone.dart' as tz;

import '../services/tz_init.dart';

/// A city on the world clock: a fixed, example list for now.
class WorldCity {
  const WorldCity(this.name, this.region, this.zone);

  final String name;
  final String region;

  /// IANA time-zone id (so daylight saving is handled).
  final String zone;
}

const worldCities = [
  WorldCity('Amritsar', 'Punjab, India', 'Asia/Kolkata'),
  WorldCity('Haridwar', 'Uttarakhand, India', 'Asia/Kolkata'),
  WorldCity('London', 'United Kingdom', 'Europe/London'),
  WorldCity('Dubai', 'United Arab Emirates', 'Asia/Dubai'),
  WorldCity('New York', 'United States', 'America/New_York'),
  WorldCity('Toronto', 'Canada', 'America/Toronto'),
  WorldCity('Sydney', 'Australia', 'Australia/Sydney'),
];

/// What a city's clock shows at one instant.
class CityTime {
  const CityTime({
    required this.city,
    required this.time,
    required this.dayOffset,
    required this.aheadBy,
  });

  final WorldCity city;

  /// The city's wall-clock time.
  final tz.TZDateTime time;

  /// -1 yesterday, 0 today, 1 tomorrow, compared with the viewer's own date.
  final int dayOffset;

  /// How far the city's clock is ahead of the viewer's (negative = behind).
  final Duration aheadBy;

  /// 6am to 6pm, city time.
  bool get isDaytime => time.hour >= 6 && time.hour < 18;

  String get dayLabel => switch (dayOffset) {
        0 => 'Today',
        1 => 'Tomorrow',
        -1 => 'Yesterday',
        _ => dayOffset > 0 ? 'In $dayOffset days' : '${-dayOffset} days ago',
      };

  /// "Same time as you", "5 h 30 m ahead of you", "4 h behind you".
  String get relativeLabel => relativeToViewer(aheadBy);
}

String relativeToViewer(Duration d) {
  if (d == Duration.zero) return 'Same time as you';
  final abs = d.abs();
  final h = abs.inHours, m = abs.inMinutes % 60;
  final amount = h == 0 ? '$m m' : (m == 0 ? '$h h' : '$h h $m m');
  return '$amount ${d.isNegative ? 'behind' : 'ahead of'} you';
}

/// The time in [city] at the instant [now] (which is in the viewer's zone).
CityTime cityTimeAt(WorldCity city, DateTime now) {
  ensureTimeZonesLoaded();
  final t = tz.TZDateTime.from(now, tz.getLocation(city.zone));
  // Compare calendar dates by wall clock, each in its own zone.
  final cityDay = DateTime.utc(t.year, t.month, t.day);
  final viewerDay = DateTime.utc(now.year, now.month, now.day);
  return CityTime(
    city: city,
    time: t,
    dayOffset: cityDay.difference(viewerDay).inDays,
    aheadBy: t.timeZoneOffset - now.timeZoneOffset,
  );
}
