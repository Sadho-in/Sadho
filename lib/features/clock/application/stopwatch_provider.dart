import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'clock_source.dart';

/// One recorded lap.
class LapEntry {
  const LapEntry({required this.number, required this.lap, required this.total});

  /// 1 for the first lap.
  final int number;

  /// How long this lap took.
  final Duration lap;

  /// The stopwatch reading when the lap was taken.
  final Duration total;
}

class StopwatchState {
  const StopwatchState({
    this.running = false,
    this.startedAt,
    this.base = Duration.zero,
    this.laps = const [],
  });

  final bool running;

  /// When the current run began (while running).
  final DateTime? startedAt;

  /// Time banked from earlier runs (before the last stop).
  final Duration base;

  /// Newest lap first.
  final List<LapEntry> laps;

  Duration elapsedAt(DateTime now) =>
      base + (running && startedAt != null ? now.difference(startedAt!) : Duration.zero);

  bool get isZero => !running && base == Duration.zero && laps.isEmpty;

  StopwatchState copyWith({
    bool? running,
    DateTime? startedAt,
    bool clearStart = false,
    Duration? base,
    List<LapEntry>? laps,
  }) =>
      StopwatchState(
        running: running ?? this.running,
        startedAt: clearStart ? null : (startedAt ?? this.startedAt),
        base: base ?? this.base,
        laps: laps ?? this.laps,
      );
}

/// The Paath stopwatch. It keeps running (from start timestamps, not ticks)
/// when you leave the screen.
class StopwatchNotifier extends Notifier<StopwatchState> {
  @override
  StopwatchState build() => const StopwatchState();

  DateTime get _now => ref.read(clockNowProvider)();

  void start() {
    if (state.running) return;
    state = state.copyWith(running: true, startedAt: _now);
  }

  void stop() {
    if (!state.running) return;
    state = state.copyWith(
        running: false, base: state.elapsedAt(_now), clearStart: true);
  }

  /// Records a lap (only while running).
  void lap() {
    if (!state.running) return;
    final total = state.elapsedAt(_now);
    final previous = state.laps.isEmpty ? Duration.zero : state.laps.first.total;
    state = state.copyWith(laps: [
      LapEntry(number: state.laps.length + 1, lap: total - previous, total: total),
      ...state.laps,
    ]);
  }

  /// Clears everything (only while stopped).
  void reset() {
    if (state.running) return;
    state = const StopwatchState();
  }
}

final stopwatchProvider =
    NotifierProvider<StopwatchNotifier, StopwatchState>(StopwatchNotifier.new);

/// "12:34.56" (minutes:seconds.hundredths), or "1:02:03.45" past an hour.
String formatStopwatch(Duration d) {
  final ms = d.inMilliseconds < 0 ? 0 : d.inMilliseconds;
  final h = ms ~/ 3600000;
  final m = (ms % 3600000) ~/ 60000;
  final s = (ms % 60000) ~/ 1000;
  final cs = (ms % 1000) ~/ 10;
  String two(int n) => n.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}.${two(cs)}' : '${two(m)}:${two(s)}.${two(cs)}';
}
