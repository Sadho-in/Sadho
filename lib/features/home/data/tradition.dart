import 'package:flutter/material.dart';
import '../../../l10n/date_formats.dart';

/// Which set of "Today" details the Home tab shows.
enum Tradition {
  hindu('Hindu'),
  sikh('Sikh'),
  place('By place');

  const Tradition(this.label);
  final String label;

  static Tradition? byName(Object? name) {
    for (final t in values) {
      if (t.name == name) return t;
    }
    return null;
  }
}

/// One line of the "Today" card.
class TodayDetail {
  const TodayDetail(
    this.key,
    this.label,
    this.value,
    this.icon, {
    this.example = true,
  });

  /// Stable id (used for widget keys).
  final String key;
  final String label;
  final String value;
  final IconData icon;

  /// True for a made-up EXAMPLE value; false for one worked out for real
  /// (sunrise and sunset, from the phone's location).
  final bool example;
}

/// EXAMPLE panchang values, shown for every day until real panchang data is
/// wired in. They are marked as examples on screen.
///
/// TODO(later-phase): compute or fetch real panchang (tithi, nakshatra, Rahu
/// Kaal, Abhijit muhurat), the Hukamnama Ang, Nitnem timings, Gurpurab dates
/// and local festivals. Nothing here depends on the date yet.
class ExampleValues {
  ExampleValues._();

  static const tithi = 'Shukla Panchami';
  static const nakshatra = 'Rohini';
  static const rahuKaal = '10:30 AM – 12:00 PM';
  static const abhijit = '11:48 AM – 12:36 PM';
  static const hukamnama = 'Ang 634';
  static const nitnem = 'Japji Sahib · Jaap Sahib · Tav-Prasad Savaiye';
  static const nextGurpurab = 'Guru Nanak Dev Ji Prakash Purab';
  static const localFestival = 'Karwa Chauth';
  static const auspiciousWindow = '4:00 AM – 5:30 AM (Amrit Vela)';
}

/// The lines for [tradition]. [sunrise] and [sunset] are the real ones for the
/// phone's location (null where the sun does not rise or set).
List<TodayDetail> todayDetails(
  Tradition tradition, {
  required DateTime? sunrise,
  required DateTime? sunset,
  required AppDates dates,
}) {
  TodayDetail rise() => TodayDetail(
    'sunrise',
    'Sunrise',
    sunrise == null ? '—' : dates.time(sunrise),
    Icons.wb_twilight,
    example: false,
  );
  TodayDetail set() => TodayDetail(
    'sunset',
    'Sunset',
    sunset == null ? '—' : dates.time(sunset),
    Icons.nights_stay_outlined,
    example: false,
  );

  switch (tradition) {
    case Tradition.hindu:
      return [
        const TodayDetail(
          'tithi',
          'Tithi',
          ExampleValues.tithi,
          Icons.brightness_3_outlined,
        ),
        const TodayDetail(
          'nakshatra',
          'Nakshatra',
          ExampleValues.nakshatra,
          Icons.star_outline,
        ),
        const TodayDetail(
          'rahu',
          'Rahu Kaal',
          ExampleValues.rahuKaal,
          Icons.do_not_disturb_on_outlined,
        ),
        const TodayDetail(
          'abhijit',
          'Abhijit muhurat',
          ExampleValues.abhijit,
          Icons.self_improvement_outlined,
        ),
      ];
    case Tradition.sikh:
      return [
        const TodayDetail(
          'hukamnama',
          'Hukamnama',
          ExampleValues.hukamnama,
          Icons.menu_book_outlined,
        ),
        const TodayDetail(
          'nitnem',
          'Nitnem due',
          ExampleValues.nitnem,
          Icons.auto_stories_outlined,
        ),
        rise(),
        const TodayDetail(
          'gurpurab',
          'Next Gurpurab',
          ExampleValues.nextGurpurab,
          Icons.celebration_outlined,
        ),
      ];
    case Tradition.place:
      return [
        rise(),
        set(),
        const TodayDetail(
          'festival',
          'Local festival',
          ExampleValues.localFestival,
          Icons.festival_outlined,
        ),
        const TodayDetail(
          'window',
          'Auspicious window',
          ExampleValues.auspiciousWindow,
          Icons.timelapse,
        ),
      ];
  }
}

/// "Good morning" / "Good afternoon" / "Good evening" / "Good night", by hour.
String greetingFor(int hour) {
  if (hour >= 5 && hour < 12) return 'Good morning';
  if (hour >= 12 && hour < 17) return 'Good afternoon';
  if (hour >= 17 && hour < 21) return 'Good evening';
  return 'Good night';
}
