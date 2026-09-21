import 'package:advance_calendar/features/clock/application/stopwatch_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'clock_support.dart';

void main() {
  late FakeClock clock;
  setUp(() => clock = FakeClock(DateTime(2026, 9, 21, 8, 0)));

  test('formatting: mm:ss.cc, and h:mm:ss.cc past an hour', () {
    expect(formatStopwatch(Duration.zero), '00:00.00');
    expect(formatStopwatch(const Duration(milliseconds: 1234)), '00:01.23');
    expect(
      formatStopwatch(
        const Duration(minutes: 12, seconds: 34, milliseconds: 560),
      ),
      '12:34.56',
    );
    expect(
      formatStopwatch(
        const Duration(hours: 1, minutes: 2, seconds: 3, milliseconds: 450),
      ),
      '1:02:03.45',
    );
    expect(formatStopwatch(const Duration(milliseconds: -50)), '00:00.00');
    expect(formatStopwatch(const Duration(milliseconds: 999)), '00:00.99');
  });

  test('starts at zero and stopped', () {
    final s = clockContainer(clock: clock).read(stopwatchProvider);
    expect((s.running, s.isZero), (false, true));
    expect(s.laps, isEmpty);
    expect(s.elapsedAt(clock.now), Duration.zero);
  });

  test('start, stop: shows the time between, and holds it', () {
    final c = clockContainer(clock: clock);
    final n = c.read(stopwatchProvider.notifier)..start();
    clock.advance(const Duration(seconds: 42, milliseconds: 500));
    expect(
      c.read(stopwatchProvider).elapsedAt(clock.now),
      const Duration(seconds: 42, milliseconds: 500),
    );
    n.stop();
    clock.advance(const Duration(minutes: 5));
    expect(
      c.read(stopwatchProvider).elapsedAt(clock.now),
      const Duration(seconds: 42, milliseconds: 500),
    );
    expect(c.read(stopwatchProvider).running, isFalse);
  });

  test('start again after a stop carries on from where it stopped', () {
    final c = clockContainer(clock: clock);
    final n = c.read(stopwatchProvider.notifier)..start();
    clock.advance(const Duration(seconds: 10));
    n.stop();
    clock.advance(const Duration(minutes: 3));
    n.start();
    clock.advance(const Duration(seconds: 5));
    expect(
      c.read(stopwatchProvider).elapsedAt(clock.now),
      const Duration(seconds: 15),
    );
  });

  test('laps record the lap time and the total, newest first', () {
    final c = clockContainer(clock: clock);
    final n = c.read(stopwatchProvider.notifier)..start();
    clock.advance(const Duration(seconds: 30));
    n.lap();
    clock.advance(const Duration(seconds: 45));
    n.lap();
    clock.advance(const Duration(seconds: 20));
    n.lap();
    final laps = c.read(stopwatchProvider).laps;
    expect([for (final l in laps) l.number], [3, 2, 1]);
    expect([for (final l in laps) l.lap.inSeconds], [20, 45, 30]);
    expect([for (final l in laps) l.total.inSeconds], [95, 75, 30]);
  });

  test('laps are only taken while running', () {
    final c = clockContainer(clock: clock);
    final n = c.read(stopwatchProvider.notifier)..lap();
    expect(c.read(stopwatchProvider).laps, isEmpty);
    n.start();
    clock.advance(const Duration(seconds: 5));
    n.stop();
    n.lap();
    expect(c.read(stopwatchProvider).laps, isEmpty);
  });

  test(
    'laps carry across a stop and start (lap time counts running time only)',
    () {
      final c = clockContainer(clock: clock);
      final n = c.read(stopwatchProvider.notifier)..start();
      clock.advance(const Duration(seconds: 10));
      n.lap();
      n.stop();
      clock.advance(const Duration(hours: 1));
      n.start();
      clock.advance(const Duration(seconds: 7));
      n.lap();
      final laps = c.read(stopwatchProvider).laps;
      expect(laps.first.lap.inSeconds, 7);
      expect(laps.first.total.inSeconds, 17);
    },
  );

  test('reset clears time and laps, but only while stopped', () {
    final c = clockContainer(clock: clock);
    final n = c.read(stopwatchProvider.notifier)..start();
    clock.advance(const Duration(seconds: 9));
    n.lap();
    n.reset(); // running: ignored
    expect(c.read(stopwatchProvider).laps.length, 1);
    n.stop();
    n.reset();
    final s = c.read(stopwatchProvider);
    expect((s.isZero, s.base), (true, Duration.zero));
    expect(s.laps, isEmpty);
  });

  test('starting twice does not lose the time already counted', () {
    final c = clockContainer(clock: clock);
    final n = c.read(stopwatchProvider.notifier)..start();
    clock.advance(const Duration(seconds: 4));
    n.start();
    expect(
      c.read(stopwatchProvider).elapsedAt(clock.now),
      const Duration(seconds: 4),
    );
  });

  test('it keeps counting while nobody watches (it lives in the provider)', () {
    final c = clockContainer(clock: clock);
    c.read(stopwatchProvider.notifier).start();
    clock.advance(const Duration(minutes: 20));
    expect(
      c.read(stopwatchProvider).elapsedAt(clock.now),
      const Duration(minutes: 20),
    );
  });
}
