// Rhythm-mode pace: how long between automatic counts.
// Pure Dart (no Flutter) so the parsing/formatting is easy to unit test.

/// Shortest allowed interval, in seconds.
const minRhythmSeconds = 0.2;

/// Longest allowed interval: 6 hours.
const maxRhythmSeconds = 6 * 3600.0;

/// Pace used until the user changes it.
const defaultRhythmSeconds = 2.0;

enum PaceUnit {
  seconds('Seconds', 1),
  minutes('Minutes', 60),
  hours('Hours', 3600);

  const PaceUnit(this.label, this.inSeconds);
  final String label;
  final int inSeconds;
}

/// Human-readable bounds, e.g. for helper text.
String get paceRangeText =>
    '${formatPace(minRhythmSeconds)} to ${formatPace(maxRhythmSeconds)}';

/// Interval = value × unit. Returns the interval in seconds, or an [error]
/// message when [text] is empty, not a number, or outside the allowed range.
({double? seconds, String? error}) checkPace(String text, PaceUnit unit) {
  final raw = text.trim().replaceAll(',', '.');
  if (raw.isEmpty) return (seconds: null, error: 'Enter a pace.');
  final value = double.tryParse(raw);
  if (value == null || !value.isFinite) {
    return (seconds: null, error: 'That is not a number.');
  }
  final seconds = value * unit.inSeconds;
  if (seconds < minRhythmSeconds - 1e-9) {
    return (seconds: null, error: 'Too fast. The minimum is ${formatPace(minRhythmSeconds)}.');
  }
  if (seconds > maxRhythmSeconds + 1e-9) {
    return (seconds: null, error: 'Too slow. The maximum is ${formatPace(maxRhythmSeconds)}.');
  }
  return (seconds: seconds, error: null);
}

/// The largest unit that shows [seconds] as a whole number (2s -> Seconds,
/// 300s -> Minutes, 7200s -> Hours).
PaceUnit bestPaceUnit(double seconds) {
  bool whole(double v) => (v - v.roundToDouble()).abs() < 1e-9;
  if (seconds >= 3600 && whole(seconds / 3600)) return PaceUnit.hours;
  if (seconds >= 60 && whole(seconds / 60)) return PaceUnit.minutes;
  return PaceUnit.seconds;
}

/// [seconds] expressed in [unit], without trailing zeros ("2", "0.2", "1.5").
String paceValueText(double seconds, PaceUnit unit) =>
    _number(seconds / unit.inSeconds);

/// "2s", "0.5s", "5 min", "1 hr", "1 hr 30 min", "1 min 30s".
String formatPace(double seconds) {
  if (seconds < 60) return '${_number(seconds)}s';
  final total = seconds.round();
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  return [
    if (h > 0) '$h hr',
    if (m > 0) '$m min',
    if (s > 0) '${s}s',
  ].join(' ');
}

/// "every 2s", "every 5 min", "every 1 hr".
String formatPaceEvery(double seconds) => 'every ${formatPace(seconds)}';

String _number(double v) {
  if ((v - v.roundToDouble()).abs() < 1e-9) return v.round().toString();
  var s = v.toStringAsFixed(2);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  return s;
}
