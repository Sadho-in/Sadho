import 'sun_times.dart';

/// Which sun event the alarm follows.
enum SunEventKind {
  sunrise('Sunrise'),
  sunset('Sunset');

  const SunEventKind(this.label);
  final String label;
}

/// The quick offsets, in minutes from the sun event (negative = before).
const presetOffsets = [-60, -45, -30, -15, 0, 15, 30];

/// The largest offset accepted, in minutes either side (a full day).
const maxOffsetMinutes = 24 * 60;

/// "1 hr before", "45 min before", "At sunrise", "15 min after", "1 hr 30 min
/// before"...
String offsetLabel(int minutes, SunEventKind kind) {
  if (minutes == 0) return 'At ${kind.label.toLowerCase()}';
  final abs = minutes.abs();
  final h = abs ~/ 60, m = abs % 60;
  final amount = h == 0
      ? '$m min'
      : (m == 0 ? '$h hr' : '$h hr $m min');
  return '$amount ${minutes < 0 ? 'before' : 'after'}';
}

/// The sun-alarm choices: on/off, sunrise or sunset, and the offset.
class SunAlarmSettings {
  const SunAlarmSettings({
    this.enabled = false,
    this.event = SunEventKind.sunrise,
    this.offsetMinutes = -30,
  });

  final bool enabled;
  final SunEventKind event;

  /// Minutes from the sun event: negative is before, positive after.
  final int offsetMinutes;

  bool get isPreset => presetOffsets.contains(offsetMinutes);

  SunAlarmSettings copyWith({bool? enabled, SunEventKind? event, int? offsetMinutes}) =>
      SunAlarmSettings(
        enabled: enabled ?? this.enabled,
        event: event ?? this.event,
        offsetMinutes: (offsetMinutes ?? this.offsetMinutes)
            .clamp(-maxOffsetMinutes, maxOffsetMinutes),
      );

  Map<String, dynamic> toMap() =>
      {'enabled': enabled, 'event': event.name, 'offsetMinutes': offsetMinutes};

  factory SunAlarmSettings.fromMap(Object? m) {
    if (m is! Map) return const SunAlarmSettings();
    const d = SunAlarmSettings();
    final off = m['offsetMinutes'];
    return SunAlarmSettings(
      enabled: m['enabled'] == true,
      event: SunEventKind.values
          .firstWhere((e) => e.name == m['event'], orElse: () => d.event),
      offsetMinutes: off is int
          ? off.clamp(-maxOffsetMinutes, maxOffsetMinutes)
          : d.offsetMinutes,
    );
  }
}

/// The sun event itself on the local calendar [day], as a local time (null in
/// polar regions when it does not happen that day).
DateTime? sunEventOn(SunEventKind kind, DateTime day, double lat, double lon) {
  final t = sunTimesFor(day.year, day.month, day.day, lat, lon);
  final utc = kind == SunEventKind.sunrise ? t.sunrise : t.sunset;
  return utc?.toLocal();
}

/// One computed alarm.
class SunAlarmTime {
  const SunAlarmTime({required this.day, required this.event, required this.alarm});

  /// The calendar day it belongs to.
  final DateTime day;

  /// When the sun event happens.
  final DateTime event;

  /// When the alarm rings: [event] plus the offset.
  final DateTime alarm;
}

/// The alarm for [day]: the sun event plus the offset (null if there is no sun
/// event that day).
SunAlarmTime? sunAlarmOn(SunAlarmSettings s, DateTime day, double lat, double lon) {
  final d = DateTime(day.year, day.month, day.day);
  final event = sunEventOn(s.event, d, lat, lon);
  if (event == null) return null;
  return SunAlarmTime(
      day: d, event: event, alarm: event.add(Duration(minutes: s.offsetMinutes)));
}

/// The alarms that are still ahead of [now], starting with the next one, over
/// the next [days] days (each day computed on its own, so the time follows the
/// sun through the seasons).
List<SunAlarmTime> upcomingSunAlarms(
  SunAlarmSettings s,
  DateTime now,
  double lat,
  double lon, {
  int days = 30,
}) {
  final out = <SunAlarmTime>[];
  // Start a day early: a large "after" offset can push yesterday's alarm past
  // midnight into today.
  for (var i = -1; i < days; i++) {
    final a = sunAlarmOn(s, DateTime(now.year, now.month, now.day + i), lat, lon);
    if (a != null && a.alarm.isAfter(now)) out.add(a);
  }
  out.sort((a, b) => a.alarm.compareTo(b.alarm));
  return out;
}

/// The next sun event ahead of [now], and whether it falls on a later day
/// than [now] at that place.
class NextSunEvent {
  const NextSunEvent(this.time, {required this.laterDay});

  final DateTime time;

  /// True when today's event at that place has already happened, so this one
  /// is tomorrow's (or later).
  final bool laterDay;
}

/// The calendar day at longitude [lon] when it is [t] (a solar-time day, so it
/// does not depend on the phone's own time zone).
DateTime _solarDay(DateTime t, double lon) {
  final s = t.toUtc().add(Duration(minutes: (lon * 4).round()));
  return DateTime.utc(s.year, s.month, s.day);
}

/// The first [kind] event after [now] at ([lat], [lon]), or null if there is
/// none in the next few days (polar night or midnight sun).
///
/// The phone's own date can be a day either side of the date at [lon] (a
/// phone abroad, or the Amritsar fallback), so yesterday's and tomorrow's
/// events are considered too and the earliest one still ahead wins.
NextSunEvent? nextSunEvent(SunEventKind kind, DateTime now, double lat, double lon) {
  DateTime? best;
  for (var i = -1; i <= 3; i++) {
    final t = sunEventOn(kind, DateTime(now.year, now.month, now.day + i), lat, lon);
    if (t != null && t.isAfter(now) && (best == null || t.isBefore(best))) best = t;
  }
  if (best == null) return null;
  return NextSunEvent(best, laterDay: _solarDay(best, lon) != _solarDay(now, lon));
}
