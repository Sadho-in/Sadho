import 'dart:math' as math;

/// Sunrise and sunset for one day at one place, as absolute instants (UTC).
///
/// At high latitudes there can be no sunrise or sunset on a given day (the sun
/// stays up, or stays down): then [sunrise]/[sunset] are null and
/// [polarDay]/[polarNight] say which.
class SunTimes {
  const SunTimes({
    this.sunrise,
    this.sunset,
    this.polarDay = false,
    this.polarNight = false,
  });

  final DateTime? sunrise;
  final DateTime? sunset;

  /// The sun does not set today (midnight sun).
  final bool polarDay;

  /// The sun does not rise today.
  final bool polarNight;

  bool get hasBoth => sunrise != null && sunset != null;
}

double _rad(double deg) => deg * math.pi / 180;
double _deg(double rad) => rad * 180 / math.pi;

/// Julian day number of [y]-[m]-[d] 12:00 UTC.
double _julianDay(int y, int m, int d) {
  if (m <= 2) {
    y -= 1;
    m += 12;
  }
  final a = y ~/ 100;
  final b = 2 - a + a ~/ 4;
  return (365.25 * (y + 4716)).floorToDouble() +
      (30.6001 * (m + 1)).floorToDouble() +
      d +
      b -
      1524.5 +
      0.5;
}

/// Sunrise and sunset on the calendar day [year]-[month]-[day] at [latitude]
/// (degrees north) and [longitude] (degrees east), using the NOAA solar
/// position equations. Accurate to about a minute at ordinary latitudes.
///
/// The day is the LOCAL solar day at that longitude, so the result is the
/// sunrise/sunset the people there see on that date, whatever time zone you
/// display it in. "Sunrise" is when the sun's upper edge meets the horizon,
/// with the usual atmospheric refraction (zenith 90.833 degrees).
SunTimes sunTimesFor(int year, int month, int day, double latitude, double longitude) {
  // One refinement pass: the sun's position changes a little between noon and
  // the moment of sunrise or sunset, so evaluate at the first estimate.
  final noon = _solve(year, month, day, latitude, longitude, 12 * 60, null);
  if (noon == null) return const SunTimes();
  if (noon.polar != null) {
    return SunTimes(polarDay: noon.polar == true, polarNight: noon.polar == false);
  }
  final rise = _solve(year, month, day, latitude, longitude, noon.rise!, true)!;
  final set = _solve(year, month, day, latitude, longitude, noon.set!, false)!;
  final base = DateTime.utc(year, month, day);
  return SunTimes(
    sunrise: base.add(Duration(milliseconds: (rise.rise! * 60000).round())),
    sunset: base.add(Duration(milliseconds: (set.set! * 60000).round())),
  );
}

class _Solved {
  _Solved({this.rise, this.set, this.polar});
  final double? rise; // minutes after 00:00 UTC of the date
  final double? set;
  final bool? polar; // true = midnight sun, false = polar night
}

/// Solar equations at [utcMinutes] after 00:00 UTC on the given date.
_Solved? _solve(int y, int m, int d, double lat, double lon, double utcMinutes, bool? forRise) {
  final jd = _julianDay(y, m, d) - 0.5 + utcMinutes / 1440;
  final t = (jd - 2451545.0) / 36525.0;

  final l0 = (280.46646 + t * (36000.76983 + t * 0.0003032)) % 360;
  final mAnom = 357.52911 + t * (35999.05029 - 0.0001537 * t);
  final e = 0.016708634 - t * (0.000042037 + 0.0000001267 * t);
  final mr = _rad(mAnom);
  final c = math.sin(mr) * (1.914602 - t * (0.004817 + 0.000014 * t)) +
      math.sin(2 * mr) * (0.019993 - 0.000101 * t) +
      math.sin(3 * mr) * 0.000289;
  final trueLong = l0 + c;
  final omega = 125.04 - 1934.136 * t;
  final lambda = trueLong - 0.00569 - 0.00478 * math.sin(_rad(omega));
  final epsilon0 = 23 +
      (26 + (21.448 - t * (46.815 + t * (0.00059 - t * 0.001813))) / 60) / 60;
  final epsilon = epsilon0 + 0.00256 * math.cos(_rad(omega));
  final decl = math.asin(math.sin(_rad(epsilon)) * math.sin(_rad(lambda)));

  final yy = math.pow(math.tan(_rad(epsilon) / 2), 2).toDouble();
  final l0r = _rad(l0);
  final eqTime = 4 *
      _deg(yy * math.sin(2 * l0r) -
          2 * e * math.sin(mr) +
          4 * e * yy * math.sin(mr) * math.cos(2 * l0r) -
          0.5 * yy * yy * math.sin(4 * l0r) -
          1.25 * e * e * math.sin(2 * mr));

  final latR = _rad(lat.clamp(-89.99, 89.99));
  final cosHa = math.cos(_rad(90.833)) / (math.cos(latR) * math.cos(decl)) -
      math.tan(latR) * math.tan(decl);
  if (cosHa > 1) return _Solved(polar: false); // the sun never rises
  if (cosHa < -1) return _Solved(polar: true); // the sun never sets
  final ha = _deg(math.acos(cosHa));

  return _Solved(
    rise: 720 - 4 * (lon + ha) - eqTime,
    set: 720 - 4 * (lon - ha) - eqTime,
  );
}
