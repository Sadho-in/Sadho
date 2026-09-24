import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/clock/application/clock_source.dart';
import 'package:advance_calendar/features/sadhana/application/completion_settings_provider.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/data/ringtone.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clock/clock_support.dart' show FakeClock;
import '../calendar/calendar_support.dart' show FakeScheduler;
import 'test_support.dart';

/// A session with a TIME target ("chant for 20 minutes"): the completion
/// feedback (vibration + ringtone, per their switches) must fire in every mode
/// and both scopes, and must still fire when the phone was locked for a while.
void main() {
  late FakeHaptics haptics;
  late FakeSound sound;
  late FakeVoice voice;
  late FakeVolume volume;
  late FakeClock clock;
  late FakeScheduler scheduler;

  setUp(() {
    resetStorage();
    seedTrainedVoice();
    haptics = FakeHaptics();
    sound = FakeSound();
    voice = FakeVoice();
    volume = FakeVolume();
    clock = FakeClock(DateTime(2026, 9, 22, 8, 0));
    scheduler = FakeScheduler();
  });

  ProviderContainer? current;

  /// A widget test that, when it ends, stops whatever session is still running
  /// (a running session owns a periodic timer, which a test must not leave).
  void tw(String name, Future<void> Function(WidgetTester) body) =>
      testWidgets(name, (tester) async {
        await body(tester);
        current?.read(sadhanaSessionProvider.notifier).pause();
        await tester.pump();
      });

  ProviderContainer make({FakeScheduler? sched}) {
    final c = ProviderContainer(overrides: [
      ...testOverrides(haptics: haptics, sound: sound, voice: voice, volume: volume),
      clockNowProvider.overrideWithValue(clock.call),
      reminderSchedulerProvider.overrideWithValue(sched ?? scheduler),
    ]);
    addTearDown(c.dispose);
    current = c;
    return c;
  }

  SadhanaSessionNotifier notifier(ProviderContainer c) =>
      c.read(sadhanaSessionProvider.notifier);
  SadhanaState state(ProviderContainer c) => c.read(sadhanaSessionProvider);
  CompletionSettingsNotifier settings(ProviderContainer c) =>
      c.read(completionSettingsProvider.notifier);

  int strong() => haptics.calls.where((h) => h.isPattern).length;
  List<ScheduledAlert> ring() => scheduler.alerts[sadhanaTimerGroup] ?? const [];

  /// Starts a time session in [mode]: Tap starts with its first tap, the rest
  /// with Start.
  Future<void> begin(WidgetTester tester, ProviderContainer c, CountMode mode,
      CountScope scope, {int seconds = 3}) async {
    final n = notifier(c)
      ..setCountScope(scope)
      ..setMode(mode)
      ..setTargetType(TargetType.time)
      ..setTargetSeconds(seconds);
    if (mode == CountMode.tap) {
      n.tap();
    } else {
      n.toggleRunning();
    }
    await tester.pump();
  }

  /// Time passes in the app: the clock and its timers move together, a second
  /// at a time (as they do on a phone).
  Future<void> pass(WidgetTester tester, Duration d) async {
    var left = d;
    while (left > Duration.zero) {
      final step = left > const Duration(seconds: 1) ? const Duration(seconds: 1) : left;
      clock.advance(step);
      await tester.pump(step);
      left -= step;
    }
  }

  /// The phone was locked: real time passes but the app's timers do not run.
  /// Then the app comes back to the front.
  Future<void> lockedFor(WidgetTester tester, Duration d) async {
    clock.advance(d);
    TestWidgetsFlutterBinding.instance
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
  }

  group('a time target fires the completion feedback in EVERY mode and scope', () {
    for (final scope in CountScope.values) {
      for (final mode in CountMode.values) {
        tw('${mode.name} / ${scope.name}', (tester) async {
          final c = make();
          await begin(tester, c, mode, scope);
          await pass(tester, const Duration(seconds: 2));
          expect(haptics.calls, isEmpty, reason: 'not before the time is up');
          expect(sound.plays, isEmpty);
          await pass(tester, const Duration(seconds: 2));
          expect(state(c).completed, isTrue);
          expect(state(c).running, isFalse);
          await tester.pump();
          expect(strong(), 1, reason: 'one strong completion buzz');
          expect(sound.plays, [Ringtone.templeBell.asset]);
          await pass(tester, const Duration(seconds: 30));
          expect(strong(), 1, reason: 'once');
          expect(sound.plays.length, 1);
        });

        for (final (vib, ring) in const [(true, true), (true, false), (false, true), (false, false)]) {
          tw('${mode.name} / ${scope.name}: vibration ${vib ? 'ON' : 'OFF'}, '
              'ringtone ${ring ? 'ON' : 'OFF'}', (tester) async {
            final c = make();
            settings(c)
              ..setVibrationEnabled(vib)
              ..setRingtoneEnabled(ring);
            await begin(tester, c, mode, scope, seconds: 2);
            await pass(tester, const Duration(seconds: 3));
            await tester.pump();
            expect(strong(), vib ? 1 : 0);
            expect(sound.plays.length, ring ? 1 : 0);
          });
        }
      }
    }
  });

  group('time counts from the real clock, so a locked phone still finishes', () {
    tw('locked for longer than the target: caught up on return', (tester) async {
      final c = make();
      await begin(tester, c, CountMode.tap, CountScope.combined, seconds: 60);
      await pass(tester, const Duration(seconds: 10));
      expect(state(c).elapsedSeconds, 10);
      await lockedFor(tester, const Duration(minutes: 5)); // no ticks happened
      expect(state(c).completed, isTrue, reason: 'the target passed while locked');
      expect(state(c).elapsedSeconds, 60, reason: 'never past the target');
      expect(state(c).running, isFalse);
    });

    tw('locked part of the time: the count moves on by the real gap',
        (tester) async {
      final c = make();
      await begin(tester, c, CountMode.rhythm, CountScope.combined, seconds: 600);
      await pass(tester, const Duration(seconds: 5));
      await lockedFor(tester, const Duration(seconds: 100));
      expect(state(c).elapsedSeconds, 105);
      expect(state(c).completed, isFalse);
      expect(state(c).running, isTrue);
      // ...and it keeps counting normally afterwards.
      await pass(tester, const Duration(seconds: 3));
      expect(state(c).elapsedSeconds, 108);
    });

    tw('coming back just after the end still rings (the phone had not '
        'yet)', (tester) async {
      final c = make();
      await begin(tester, c, CountMode.tap, CountScope.combined, seconds: 60);
      await pass(tester, const Duration(seconds: 58));
      await lockedFor(tester, const Duration(seconds: 3)); // 1 s after the end
      await tester.pump();
      expect(state(c).completed, isTrue);
      expect(strong(), 1);
      expect(sound.plays.length, 1);
    });

    tw('coming back long after: the phone\'s notification rang, so the '
        'app stays quiet (no double ring)', (tester) async {
      final c = make();
      await begin(tester, c, CountMode.tap, CountScope.combined, seconds: 60);
      expect(ring(), isNotEmpty, reason: 'the notification was set');
      await lockedFor(tester, const Duration(minutes: 5));
      await tester.pump();
      expect(state(c).completed, isTrue);
      expect(strong(), 0);
      expect(sound.plays, isEmpty);
    });

    tw('...but if no notification could be set, the app rings when it '
        'is back (better late than never)', (tester) async {
      final refused = FakeScheduler(permission: false);
      final c = make(sched: refused);
      await begin(tester, c, CountMode.tap, CountScope.combined, seconds: 60);
      expect(refused.alerts[sadhanaTimerGroup] ?? const [], isEmpty);
      await lockedFor(tester, const Duration(minutes: 5));
      await tester.pump();
      expect(strong(), 1);
      expect(sound.plays.length, 1);
    });

    tw('...unless it is hours late: then it just finishes', (tester) async {
      final refused = FakeScheduler(permission: false);
      final c = make(sched: refused);
      await begin(tester, c, CountMode.tap, CountScope.combined, seconds: 60);
      await lockedFor(tester, const Duration(hours: 3));
      await tester.pump();
      expect(state(c).completed, isTrue);
      expect(strong(), 0);
    });

    tw('a pause keeps the time: the gap while paused is not counted',
        (tester) async {
      final c = make();
      await begin(tester, c, CountMode.rhythm, CountScope.combined, seconds: 100);
      await pass(tester, const Duration(seconds: 10));
      notifier(c).pause();
      clock.advance(const Duration(hours: 1));
      notifier(c).toggleRunning();
      await tester.pump();
      await pass(tester, const Duration(seconds: 5));
      expect(state(c).elapsedSeconds, 15);
    });

    tw('returning to the app when nothing is running changes nothing',
        (tester) async {
      final c = make();
      notifier(c).setTargetType(TargetType.time);
      await lockedFor(tester, const Duration(hours: 2));
      expect(state(c).elapsedSeconds, 0);
    });

    tw('a count-target session is not touched by returning to the app',
        (tester) async {
      final c = make();
      notifier(c)
        ..setTargetCount(5)
        ..tap();
      await lockedFor(tester, const Duration(hours: 2));
      expect(state(c).count, 1);
      expect(haptics.calls, isEmpty);
    });

    tw('a normal tick is one second even if the clock stands still',
        (tester) async {
      final c = make();
      await begin(tester, c, CountMode.rhythm, CountScope.combined, seconds: 100);
      await tester.pump(const Duration(seconds: 4)); // the clock did not move
      expect(state(c).elapsedSeconds, 4);
    });

    tw('in Separate the catch-up goes to the active mode only',
        (tester) async {
      final c = make();
      await begin(tester, c, CountMode.rhythm, CountScope.separate, seconds: 600);
      await pass(tester, const Duration(seconds: 5));
      await lockedFor(tester, const Duration(seconds: 55));
      expect(state(c).progressOf(CountMode.rhythm).elapsedSeconds, 60);
      expect(state(c).progressOf(CountMode.tap).elapsedSeconds, 0);
    });
  });

  group('the notification that rings when the app is not running its clock', () {
    tw('a time run schedules one, just after the end', (tester) async {
      final c = make();
      await begin(tester, c, CountMode.tap, CountScope.combined, seconds: 300);
      final a = ring().single;
      expect(a.when, clock.now.add(const Duration(seconds: 300)).add(SadhanaSessionNotifier.alarmMargin));
      expect(a.title, contains('Sadhana'));
      expect(scheduler.alertReplacements.toSet().difference({sadhanaTimerGroup}), isEmpty,
          reason: 'it touches only its own notifications');
    });

    test('the notification waits a moment past the end, so the app\'s own clock '
        '(1 s ticks) gets to finish first and cancel it', () {
      expect(SadhanaSessionNotifier.alarmMargin, greaterThan(const Duration(seconds: 1)));
      expect(SadhanaSessionNotifier.alarmMargin, lessThanOrEqualTo(const Duration(seconds: 10)));
    });

    tw('asks for the notification permission once, only for a time run',
        (tester) async {
      final c = make();
      notifier(c)
        ..setTargetCount(9)
        ..tap();
      await tester.pump();
      expect(scheduler.permissionRequests, 0, reason: 'a count target needs none');
      await begin(tester, c, CountMode.tap, CountScope.combined, seconds: 30);
      notifier(c).pause();
      notifier(c).toggleRunning();
      await tester.pump();
      expect(scheduler.permissionRequests, 1);
    });

    tw('a count-target session never schedules one', (tester) async {
      final c = make();
      notifier(c)
        ..setTargetCount(3)
        ..tap()
        ..tap();
      await tester.pump();
      expect(ring(), isEmpty);
    });

    tw('Pause cancels it; Start sets it for the time that is left',
        (tester) async {
      final c = make();
      await begin(tester, c, CountMode.rhythm, CountScope.combined, seconds: 100);
      await pass(tester, const Duration(seconds: 30));
      notifier(c).pause();
      await tester.pump();
      expect(ring(), isEmpty);
      notifier(c).toggleRunning();
      await tester.pump();
      expect(ring().single.when,
          clock.now.add(const Duration(seconds: 70)).add(SadhanaSessionNotifier.alarmMargin));
    });

    tw('Reset cancels it', (tester) async {
      final c = make();
      await begin(tester, c, CountMode.rhythm, CountScope.combined, seconds: 100);
      notifier(c).reset();
      await tester.pump();
      expect(ring(), isEmpty);
    });

    tw('finishing in the app cancels it, so it does not ring twice',
        (tester) async {
      final c = make();
      await begin(tester, c, CountMode.tap, CountScope.combined, seconds: 3);
      expect(ring(), hasLength(1));
      await pass(tester, const Duration(seconds: 3));
      await tester.pump();
      expect(state(c).completed, isTrue);
      expect(ring(), isEmpty);
      expect(strong(), 1);
    });

    tw('changing the target while running moves it', (tester) async {
      final c = make();
      await begin(tester, c, CountMode.rhythm, CountScope.combined, seconds: 100);
      notifier(c).setTargetSeconds(500);
      await tester.pump();
      expect(ring().single.when,
          clock.now.add(const Duration(seconds: 500)).add(SadhanaSessionNotifier.alarmMargin));
    });

    tw('switching to a count target cancels it (Tap: no predictable end)',
        (tester) async {
      final c = make();
      await begin(tester, c, CountMode.tap, CountScope.combined, seconds: 100);
      expect(ring(), isNotEmpty);
      notifier(c).setTargetType(TargetType.count);
      await tester.pump();
      expect(ring(), isEmpty);
    });

    tw('a session that was running when the app died leaves no stale '
        'ring behind', (tester) async {
      scheduler.alerts[sadhanaTimerGroup] = [
        ScheduledAlert(id: 1, when: DateTime(2030), title: 'old', body: 'old'),
      ];
      final c = make();
      c.read(sadhanaSessionProvider); // the app starts
      await tester.pump();
      expect(ring(), isEmpty);
    });

    tw('a scheduling failure does not stop the session or its ring',
        (tester) async {
      final c = make(sched: _BrokenScheduler());
      await begin(tester, c, CountMode.tap, CountScope.combined, seconds: 3);
      await pass(tester, const Duration(seconds: 3));
      await tester.pump();
      expect(state(c).completed, isTrue);
      expect(strong(), 1);
    });
  });
}

class _BrokenScheduler extends FakeScheduler {
  @override
  Future<void> replaceAlerts(String group, List<ScheduledAlert> next) async {
    throw StateError('no');
  }
}
