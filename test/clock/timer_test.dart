import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/clock/application/sun_alarm_provider.dart';
import 'package:advance_calendar/features/clock/application/timer_provider.dart';
import 'package:advance_calendar/features/clock/data/sun_alarm.dart';
import 'package:advance_calendar/features/clock/data/timer_presets.dart';
import 'package:advance_calendar/features/clock/services/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'clock_support.dart';

void main() {
  late FakeClock clock;
  late FakeScheduler scheduler;
  late FakeFeedback feedback;

  setUp(() {
    clock = FakeClock(DateTime(2026, 9, 21, 8, 0));
    scheduler = FakeScheduler();
    feedback = FakeFeedback();
  });

  ProviderContainer make({
    Map<String, Object?> saved = const {},
    FakeLocationService? location,
  }) {
    final c = clockContainer(
      clock: clock,
      scheduler: scheduler,
      feedback: feedback,
      location: location ?? FakeLocationService(state: LocationAccess.denied),
      saved: saved,
    );
    return c;
  }

  TimerPreset preset(String id) => timerPresets.firstWhere((p) => p.id == id);
  List<ScheduledAlert> ring() => scheduler.alerts[timerGroup] ?? const [];

  group('the presets', () {
    test('are Aarti 5, Chalisa 11, Path 21 and Havan 30 minutes', () {
      expect(
        [for (final p in timerPresets) (p.label, p.minutes)],
        [('Aarti', 5), ('Chalisa', 11), ('Path', 21), ('Havan', 30)],
      );
    });

    test('choosing one sets its length, ready to start', () {
      final c = make();
      final n = c.read(timerProvider.notifier);
      for (final p in timerPresets) {
        n.selectPreset(p);
        final t = c.read(timerProvider);
        expect(t.remainingSeconds, p.minutes * 60);
        expect(t.totalSeconds, p.minutes * 60);
        expect(t.label, p.label);
        expect(t.phase, TimerPhase.idle);
      }
    });
  });

  group('the countdown', () {
    test('formats as mm:ss and h:mm:ss', () {
      expect(formatCountdown(300), '05:00');
      expect(formatCountdown(65), '01:05');
      expect(formatCountdown(3725), '1:02:05');
      expect(formatCountdown(0), '00:00');
      expect(formatCountdown(-4), '00:00');
    });

    test('runs from a fixed end time, so it counts down with the clock', () {
      final c = make();
      final n = c.read(timerProvider.notifier)..selectPreset(preset('chalisa'));
      n.start();
      final t = c.read(timerProvider);
      expect(t.running, isTrue);
      expect(t.endsAt, clock.now.add(const Duration(minutes: 11)));
      expect(t.remainingAt(clock.now), 660);
      clock.advance(const Duration(minutes: 4, seconds: 30));
      expect(c.read(timerProvider).remainingAt(clock.now), 390);
      // Rounds up: 0.4 s left still shows 1 second.
      expect(
        t.remainingAt(t.endsAt!.subtract(const Duration(milliseconds: 400))),
        1,
      );
      expect(t.remainingAt(t.endsAt!.add(const Duration(seconds: 9))), 0);
    });

    test('pause keeps the time left; resume carries on from it', () {
      final c = make();
      final n = c.read(timerProvider.notifier)..selectPreset(preset('aarti'));
      n.start();
      clock.advance(const Duration(minutes: 2));
      n.pause();
      expect(c.read(timerProvider).phase, TimerPhase.paused);
      expect(c.read(timerProvider).remainingSeconds, 180);
      clock.advance(const Duration(minutes: 10)); // time passes while paused
      expect(c.read(timerProvider).remainingAt(clock.now), 180);
      n.start();
      expect(
        c.read(timerProvider).endsAt,
        clock.now.add(const Duration(minutes: 3)),
      );
    });

    test('reset goes back to the full length', () {
      final c = make();
      final n = c.read(timerProvider.notifier)..selectPreset(preset('path'));
      n.start();
      clock.advance(const Duration(minutes: 5));
      n.reset();
      final t = c.read(timerProvider);
      expect((t.phase, t.remainingSeconds), (TimerPhase.idle, 21 * 60));
      expect(t.endsAt, isNull);
    });

    test('the length cannot be changed while it runs', () {
      final c = make();
      final n = c.read(timerProvider.notifier)..selectPreset(preset('aarti'));
      n.start();
      n.selectPreset(preset('havan'));
      n.selectVratToSunset();
      expect(c.read(timerProvider).presetId, 'aarti');
    });

    test('starting twice does not restart it', () {
      final c = make();
      final n = c.read(timerProvider.notifier)..selectPreset(preset('aarti'));
      n.start();
      final ends = c.read(timerProvider).endsAt;
      clock.advance(const Duration(minutes: 1));
      n.start();
      expect(c.read(timerProvider).endsAt, ends);
    });
  });

  group('at zero', () {
    test('it vibrates and rings once (the completion feedback)', () {
      final c = make();
      final n = c.read(timerProvider.notifier)..selectPreset(preset('aarti'));
      n.start();
      clock.advance(const Duration(minutes: 5));
      n.tick();
      expect(feedback.completions, 1);
      expect(c.read(timerProvider).phase, TimerPhase.finished);
      n.tick();
      n.tick();
      expect(feedback.completions, 1, reason: 'only once');
    });

    test('not a moment early', () {
      final c = make();
      final n = c.read(timerProvider.notifier)..selectPreset(preset('aarti'));
      n.start();
      clock.advance(const Duration(minutes: 4, seconds: 59));
      n.tick();
      expect(feedback.completions, 0);
      expect(c.read(timerProvider).running, isTrue);
    });

    test(
      'through the real feedback: a strong buzz and the alarm-stream sound',
      () {
        final haptics = FakeHaptics();
        final sound = FakeSound();
        final c = clockContainer(
          clock: clock,
          scheduler: scheduler,
          location: FakeLocationService(state: LocationAccess.denied),
          haptics: haptics,
          sound: sound,
        );
        final n = c.read(timerProvider.notifier)..selectPreset(preset('aarti'));
        n.start();
        clock.advance(const Duration(minutes: 5));
        n.tick();
        return pumpEventQueue().then((_) {
          expect(haptics.calls.where((h) => h.isPattern).length, 1);
          expect(sound.plays.length, 1);
        });
      },
    );

    test(
      'the phone\'s own notification is dropped so it does not ring twice',
      () async {
        final c = make();
        final n = c.read(timerProvider.notifier)..selectPreset(preset('aarti'));
        n.start();
        await pumpEventQueue();
        expect(ring().length, 1);
        clock.advance(const Duration(minutes: 5));
        n.tick();
        await pumpEventQueue();
        expect(ring(), isEmpty);
      },
    );

    test(
      'noticed long afterwards: finished, but no ring (the phone did that)',
      () {
        final c = make();
        final n = c.read(timerProvider.notifier)..selectPreset(preset('aarti'));
        n.start();
        clock.advance(const Duration(minutes: 30));
        n.tick();
        expect(c.read(timerProvider).phase, TimerPhase.finished);
        expect(feedback.completions, 0);
      },
    );

    test('Start again after finishing gives a fresh full countdown', () {
      final c = make();
      final n = c.read(timerProvider.notifier)..selectPreset(preset('aarti'));
      n.start();
      clock.advance(const Duration(minutes: 5));
      n.tick();
      n.start();
      final t = c.read(timerProvider);
      expect(t.running, isTrue);
      expect(t.endsAt, clock.now.add(const Duration(minutes: 5)));
    });
  });

  group('the phone rings even if Sadho is closed', () {
    test('starting schedules a notification for the end time', () async {
      final c = make();
      final n = c.read(timerProvider.notifier)..selectPreset(preset('chalisa'));
      n.start();
      await pumpEventQueue();
      expect(ring().length, 1);
      expect(ring().first.when, clock.now.add(const Duration(minutes: 11)));
      expect(ring().first.title, contains('Chalisa'));
    });

    test('pause and reset cancel it; resume schedules the new end', () async {
      final c = make();
      final n = c.read(timerProvider.notifier)..selectPreset(preset('aarti'));
      n.start();
      await pumpEventQueue();
      clock.advance(const Duration(minutes: 1));
      n.pause();
      await pumpEventQueue();
      expect(ring(), isEmpty);
      n.start();
      await pumpEventQueue();
      expect(ring().first.when, clock.now.add(const Duration(minutes: 4)));
      n.reset();
      await pumpEventQueue();
      expect(ring(), isEmpty);
    });

    test('its notification never shares an id with a sun-alarm one', () async {
      final c = make();
      await c.read(sunAlarmProvider.notifier).setEnabled(true);
      c.read(timerProvider.notifier)
        ..selectPreset(preset('aarti'))
        ..start();
      await pumpEventQueue();
      final sun = {for (final a in scheduler.alerts[sunAlarmGroup]!) a.id};
      expect(sun, isNotEmpty);
      expect(ring().map((a) => a.id).toSet().intersection(sun), isEmpty);
    });

    test('it only uses the timer group', () async {
      final c = make();
      c.read(timerProvider.notifier)
        ..selectPreset(preset('aarti'))
        ..start();
      await pumpEventQueue();
      expect(scheduler.alertReplacements.toSet(), {timerGroup});
    });
  });

  group('after the app was closed', () {
    Map<String, Object?> saved(Map<String, dynamic> t) => {'clock.timer': t};

    test('a running timer carries on and is scheduled again', () async {
      final ends = clock.now.add(const Duration(minutes: 3));
      final c = make(
        saved: saved({
          'preset': 'aarti',
          'label': 'Aarti',
          'total': 300,
          'remaining': 300,
          'phase': 'running',
          'endsAt': ends.millisecondsSinceEpoch,
        }),
      );
      final t = c.read(timerProvider);
      expect(t.running, isTrue);
      expect(t.remainingAt(clock.now), 180);
      await pumpEventQueue();
      expect(ring().first.when, ends);
    });

    test('one that ran out meanwhile is finished, silently', () async {
      final c = make(
        saved: saved({
          'preset': 'aarti',
          'label': 'Aarti',
          'total': 300,
          'remaining': 300,
          'phase': 'running',
          'endsAt': clock.now
              .subtract(const Duration(minutes: 1))
              .millisecondsSinceEpoch,
        }),
      );
      expect(c.read(timerProvider).phase, TimerPhase.finished);
      await pumpEventQueue();
      expect(feedback.completions, 0);
    });

    test('a paused one keeps its time', () {
      final c = make(
        saved: saved({
          'preset': 'path',
          'label': 'Path',
          'total': 1260,
          'remaining': 700,
          'phase': 'paused',
        }),
      );
      final t = c.read(timerProvider);
      expect(
        (t.phase, t.remainingSeconds, t.label),
        (TimerPhase.paused, 700, 'Path'),
      );
    });

    test('damaged data gives the default 5-minute Aarti', () {
      for (final junk in [
        null,
        'x',
        <String, dynamic>{'total': -5, 'phase': 'flying'},
      ]) {
        final c = make(saved: {'clock.timer': junk});
        final t = c.read(timerProvider);
        expect(t.phase, TimerPhase.idle);
        expect(t.remainingSeconds, greaterThan(0));
      }
    });

    test('changes are saved', () {
      final c = make();
      c.read(timerProvider.notifier)
        ..selectPreset(preset('havan'))
        ..start();
      final m = AppStorage.settings.get('clock.timer') as Map;
      expect((m['preset'], m['phase'], m['total']), ('havan', 'running', 1800));
    });
  });

  group('Vrat → sunset', () {
    // Amritsar (the default place). Late morning: today's sunset is ahead.
    DateTime? sunsetOn(DateTime d) => sunEventOn(
      SunEventKind.sunset,
      DateTime(d.year, d.month, d.day),
      31.6340,
      74.8723,
    );

    // Three hours before that day's sunset in Amritsar, wherever the test runs.
    setUp(
      () =>
          clock.now = sunsetOn(DateTime(2026, 9, 21))!
              .subtract(const Duration(hours: 3)),
    );

    test('counts down to today\'s sunset', () {
      final c = make();
      c.read(timerProvider.notifier).selectVratToSunset();
      final t = c.read(timerProvider);
      final sunset = sunsetOn(DateTime(2026, 9, 21))!;
      expect(t.isVrat, isTrue);
      expect(t.label, 'Vrat → sunset');
      expect(t.vratTarget, sunset);
      expect(
        (t.remainingSeconds - sunset.difference(clock.now).inSeconds).abs(),
        lessThanOrEqualTo(1),
      );
      expect(t.message, isNull);
    });

    test(
      'starting runs to the sunset itself and schedules the ring there',
      () async {
        final c = make();
        final n = c.read(timerProvider.notifier)..selectVratToSunset();
        final sunset = c.read(timerProvider).vratTarget!;
        clock.advance(const Duration(minutes: 20)); // Start pressed a bit later
        n.start();
        expect(c.read(timerProvider).endsAt, sunset);
        await pumpEventQueue();
        expect(ring().first.when, sunset);
        expect(ring().first.body, contains('Sunset'));
      },
    );

    test('rings at sunset like any other countdown', () {
      final c = make();
      final n = c.read(timerProvider.notifier)..selectVratToSunset();
      n.start();
      clock.now = c.read(timerProvider).endsAt!;
      n.tick();
      expect(feedback.completions, 1);
      expect(c.read(timerProvider).phase, TimerPhase.finished);
    });

    test('after today\'s sunset it counts to tomorrow\'s, and says so', () {
      final sunset = sunsetOn(DateTime(2026, 9, 21))!;
      clock.now = sunset.add(const Duration(minutes: 30));
      final c = make();
      c.read(timerProvider.notifier).selectVratToSunset();
      final t = c.read(timerProvider);
      expect(t.vratTarget!.isAfter(clock.now), isTrue);
      expect(
        t.vratTarget!.difference(sunset).inHours,
        inInclusiveRange(23, 25),
      );
      expect(t.message, contains('tomorrow'));
    });

    test(
      'with no sunset at all (polar night) it says so and does not start',
      () {
        clock.now = DateTime.utc(2026, 12, 15, 12);
        final c = make(
          saved: {
            'clock.location': {'lat': 78.2, 'lon': 15.6},
          },
          location: FakeLocationService(state: LocationAccess.denied),
        );
        final n = c.read(timerProvider.notifier)..selectVratToSunset();
        final t = c.read(timerProvider);
        expect(t.message, contains('no sunset'));
        expect(t.isVrat, isFalse);
        n.start(); // starts the previous (default) preset, not a vrat
        expect(c.read(timerProvider).isVrat, isFalse);
      },
    );

    test('a phone whose date differs from the place\'s still counts to the right sunset', () {
      // 10 minutes of the "same" moment expressed as this machine's local date.
      final sunset = sunsetOn(DateTime(2026, 9, 21))!;
      clock.now = sunset.subtract(const Duration(minutes: 10)).toLocal();
      final c = make();
      c.read(timerProvider.notifier).selectVratToSunset();
      final t = c.read(timerProvider);
      expect(t.vratTarget, sunset);
      expect(t.remainingSeconds, 600);
      expect(t.message, isNull);
    });

    test('reset re-aims at the next sunset', () {
      final c = make();
      final n = c.read(timerProvider.notifier)..selectVratToSunset();
      n.start();
      clock.now = c
          .read(timerProvider)
          .endsAt!
          .add(const Duration(minutes: 10));
      n.tick();
      n.reset();
      final t = c.read(timerProvider);
      expect(t.phase, TimerPhase.idle);
      expect(t.vratTarget!.isAfter(clock.now), isTrue);
    });

    test(
      'the place it uses is the phone\'s, when known (London vs Amritsar)',
      () {
        final amritsar = make();
        amritsar.read(timerProvider.notifier).selectVratToSunset();
        final a = amritsar.read(timerProvider).vratTarget!;
        final london = clockContainer(
          clock: clock,
          scheduler: FakeScheduler(),
          feedback: feedback,
          location: FakeLocationService(state: LocationAccess.denied),
          saved: {
            'clock.location': {'lat': 51.5074, 'lon': -0.1278},
          },
        );
        london.read(timerProvider.notifier).selectVratToSunset();
        expect(london.read(timerProvider).vratTarget, isNot(a));
      },
    );
  });
}
