import 'package:advance_calendar/app.dart';
import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/clock/application/clock_source.dart';
import 'package:advance_calendar/features/sadhana/application/completion_settings_provider.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/application/session_notice_provider.dart';
import 'package:advance_calendar/features/sadhana/presentation/focus_mode_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/sadhana_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/completion_settings_card.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile/profile_support.dart';
import 'test_support.dart';

/// Alarm-style completion: a session whose finish time is predictable (a
/// time target in any mode, or a Rhythm count target) sets a phone alarm for
/// that moment, so it rings with the screen off, the app in the background or
/// closed; it rings exactly once; and the session catches up with the real
/// clock on return. Plus the keep-screen-on setting.
void main() {

  late FakeHaptics haptics;
  late FakeSound sound;
  late FakeVoice voice;
  late FakeVolume volume;
  late FakeClock clock;
  late FakeScheduler scheduler;
  late FakeWakelock wakelock;

  setUp(() {
    resetStorage();
    seedTrainedVoice();
    haptics = FakeHaptics();
    sound = FakeSound();
    voice = FakeVoice();
    volume = FakeVolume();
    clock = FakeClock(DateTime(2026, 9, 24, 6, 0));
    scheduler = FakeScheduler();
    wakelock = FakeWakelock();
  });

  final containers = <ProviderContainer>[];

  ProviderContainer make() {
    final c = ProviderContainer(overrides: [
      ...testOverrides(
          haptics: haptics,
          sound: sound,
          voice: voice,
          volume: volume,
          wakelock: wakelock),
      clockNowProvider.overrideWithValue(clock.call),
      reminderSchedulerProvider.overrideWithValue(scheduler),
    ]);
    containers.add(c);
    return c;
  }

  /// A widget test that leaves nothing running and the app in the front.
  void tw(String name, Future<void> Function(WidgetTester) body) =>
      testWidgets(name, (tester) async {
        try {
          await body(tester);
        } finally {
          tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
          for (final c in containers) {
            c.read(sadhanaSessionProvider.notifier).pause();
            c.read(sadhanaSessionProvider.notifier).stopAlert();
          }
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpWidget(const SizedBox()); // unmount before disposing
          for (final c in containers) {
            c.dispose();
          }
          containers.clear();
        }
      });

  SadhanaSessionNotifier notifier(ProviderContainer c) =>
      c.read(sadhanaSessionProvider.notifier);
  SadhanaState state(ProviderContainer c) => c.read(sadhanaSessionProvider);
  CompletionSettingsNotifier settings(ProviderContainer c) =>
      c.read(completionSettingsProvider.notifier);

  List<ScheduledAlert> alarms() => scheduler.alerts[sadhanaTimerGroup] ?? const [];
  ScheduledAlert alarm() => alarms().single;
  int rings() => sound.plays.length;
  const margin = SadhanaSessionNotifier.alarmMargin;

  /// Time passes with the app's timers running (a second at a time).
  Future<void> pass(WidgetTester tester, Duration d) async {
    var left = d;
    while (left > Duration.zero) {
      final step = left > const Duration(seconds: 1) ? const Duration(seconds: 1) : left;
      clock.advance(step);
      await tester.pump(step);
      left -= step;
    }
  }

  void toBackground(WidgetTester tester) =>
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);

  void toFront(WidgetTester tester) =>
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

  /// Starts [mode] with a time target of [seconds].
  Future<void> startTime(WidgetTester tester, ProviderContainer c, CountMode mode,
      int seconds) async {
    final n = notifier(c)
      ..setMode(mode)
      ..setTargetType(TargetType.time)
      ..setTargetSeconds(seconds);
    mode == CountMode.tap ? n.tap() : n.toggleRunning();
    await tester.pump();
  }

  /// Starts Rhythm with a count target of [target] at [pace] seconds.
  Future<void> startRhythm(WidgetTester tester, ProviderContainer c,
      {int target = 10, double pace = 2}) async {
    notifier(c)
      ..setMode(CountMode.rhythm)
      ..setRhythmSeconds(pace)
      ..setTargetCount(target)
      ..toggleRunning();
    await tester.pump();
  }

  group('scheduled at the finish', () {
    for (final mode in CountMode.values) {
      tw('time target, ${mode.name} mode: at start + time', (tester) async {
        final c = make();
        final start = clock.now;
        await startTime(tester, c, mode, 17 * 60 + 5); // custom 17 min 5 s
        expect(alarm().when, start.add(const Duration(minutes: 17, seconds: 5)).add(margin));
        expect(alarm().style, isNotNull, reason: 'the alarm-style Sadhana alarm');
      });
    }

    tw('Rhythm count target: at start + remaining count × pace', (tester) async {
      final c = make();
      notifier(c)
        ..setMode(CountMode.rhythm)
        ..increment()
        ..increment()
        ..increment(); // 3 already counted
      final start = clock.now;
      await startRhythm(tester, c, target: 10, pace: 2.5);
      expect(alarm().when,
          start.add(const Duration(milliseconds: 7 * 2500)).add(margin));
    });

    for (final mode in [CountMode.tap, CountMode.voice, CountMode.mala]) {
      tw('never for a ${mode.name} COUNT target (it ends on the user\'s input)',
          (tester) async {
        final c = make();
        notifier(c)
          ..setMode(mode)
          ..setTargetCount(5);
        if (mode == CountMode.tap) {
          notifier(c).tap();
        } else {
          notifier(c).toggleRunning();
        }
        await tester.pump();
        expect(alarms(), isEmpty);
        // ...and its in-app completion still rings.
        for (var i = 0; i < 5; i++) {
          switch (mode) {
            case CountMode.tap:
              notifier(c).tap();
            case CountMode.voice:
              voice.hear();
            case CountMode.mala:
              volume.press();
            case CountMode.rhythm:
          }
        }
        await tester.pump();
        expect(state(c).completed, isTrue);
        expect(rings(), 1);
        expect(alarms(), isEmpty);
      });
    }
  });

  group('rescheduled when the finish moves', () {
    tw('the time target changes mid-run', (tester) async {
      final c = make();
      final start = clock.now;
      await startTime(tester, c, CountMode.rhythm, 600);
      await pass(tester, const Duration(seconds: 10));
      notifier(c).setTargetSeconds(900);
      await tester.pump();
      expect(alarm().when, start.add(const Duration(seconds: 900)).add(margin));
    });

    tw('the Rhythm pace changes mid-run', (tester) async {
      final c = make();
      await startRhythm(tester, c, target: 10, pace: 2);
      await pass(tester, const Duration(seconds: 4)); // 2 counted
      expect(state(c).count, 2);
      final lastBeat = clock.now;
      notifier(c).setRhythmSeconds(3);
      await tester.pump();
      expect(alarm().when, lastBeat.add(const Duration(seconds: 8 * 3)).add(margin));
    });

    tw('the Rhythm count target changes mid-run', (tester) async {
      final c = make();
      final start = clock.now;
      await startRhythm(tester, c, target: 10, pace: 2);
      notifier(c).setTargetCount(20);
      await tester.pump();
      expect(alarm().when, start.add(const Duration(seconds: 40)).add(margin));
    });

    tw('a manual + or − moves a Rhythm finish by one beat', (tester) async {
      final c = make();
      final start = clock.now;
      await startRhythm(tester, c, target: 10, pace: 2);
      notifier(c)
        ..increment()
        ..increment();
      await tester.pump();
      expect(alarm().when, start.add(const Duration(seconds: 16)).add(margin));
      notifier(c).decrement();
      await tester.pump();
      expect(alarm().when, start.add(const Duration(seconds: 18)).add(margin));
    });

    tw('a new ringtone or repeat setting applies to the alarm at once',
        (tester) async {
      final c = make();
      await startTime(tester, c, CountMode.tap, 60);
      expect(alarm().style!.insistent, isFalse);
      settings(c).setSoundRepeat(SoundRepeat.untilStopped);
      await tester.pump();
      expect(alarm().style!.insistent, isTrue);
    });
  });

  group('cancelled', () {
    tw('on pause', (tester) async {
      final c = make();
      await startTime(tester, c, CountMode.rhythm, 60);
      notifier(c).pause();
      await tester.pump();
      expect(alarms(), isEmpty);
    });

    tw('on reset', (tester) async {
      final c = make();
      await startRhythm(tester, c);
      notifier(c).reset();
      await tester.pump();
      expect(alarms(), isEmpty);
    });

    tw('on a mode change', (tester) async {
      final c = make();
      await startRhythm(tester, c);
      notifier(c).setMode(CountMode.tap);
      await tester.pump();
      expect(alarms(), isEmpty);
    });

    tw('on switching to an unpredictable target (Tap count)', (tester) async {
      final c = make();
      await startTime(tester, c, CountMode.tap, 60);
      notifier(c).setTargetType(TargetType.count);
      await tester.pump();
      expect(alarms(), isEmpty);
    });

    for (final (label, begin) in [
      ('time target', (WidgetTester t, ProviderContainer c) => startTime(t, c, CountMode.tap, 5)),
      ('Rhythm count', (WidgetTester t, ProviderContainer c) => startRhythm(t, c, target: 3, pace: 1)),
    ]) {
      tw('$label: finishing with the app open rings in the app once and '
          'cancels the phone alarm', (tester) async {
        final c = make();
        await begin(tester, c);
        expect(alarms(), isNotEmpty);
        await pass(tester, const Duration(seconds: 6));
        expect(state(c).completed, isTrue);
        expect(rings(), 1);
        expect(alarms(), isEmpty, reason: 'no second ring from the phone');
      });
    }
  });

  group('rings once: the phone rang, so the app stays quiet', () {
    tw('finished in the background (timers still running): the phone alarm '
        'is left to ring; nothing in the app, then or on return', (tester) async {
      final c = make();
      await startRhythm(tester, c, target: 5, pace: 1);
      toBackground(tester);
      await pass(tester, const Duration(seconds: 5));
      expect(state(c).completed, isTrue);
      expect(rings(), 0, reason: 'the app does not ring from the background');
      expect(alarms(), isNotEmpty, reason: 'the phone alarm still rings');
      await pass(tester, const Duration(seconds: 30)); // the phone rang
      toFront(tester);
      await tester.pump();
      expect(rings(), 0);
      expect(alarms(), isEmpty);
      expect(scheduler.dismissed, contains(sadhanaTimerGroup),
          reason: 'the rung alarm is cleared (stops an insistent one)');
    });

    tw('back just after the finish, before the phone rang: the app rings '
        'instead, once', (tester) async {
      final c = make();
      await startTime(tester, c, CountMode.tap, 5);
      toBackground(tester);
      await pass(tester, const Duration(seconds: 5));
      expect(rings(), 0);
      clock.advance(const Duration(milliseconds: 500)); // before end + margin
      toFront(tester);
      await tester.pump();
      expect(rings(), 1);
      expect(alarms(), isEmpty);
    });

    tw('locked (timers held back) past the alarm: caught up on return, quiet',
        (tester) async {
      final c = make();
      await startTime(tester, c, CountMode.rhythm, 60);
      toBackground(tester);
      clock.advance(const Duration(minutes: 5)); // no ticks meanwhile
      toFront(tester);
      await tester.pump();
      expect(state(c).completed, isTrue);
      expect(rings(), 0);
      expect(haptics.calls.where((h) => h.isPattern), isEmpty);
    });

    tw('the notification is tapped: the app opens on the finished session, '
        'quiet', (tester) async {
      final c = make();
      await startRhythm(tester, c, target: 4, pace: 1);
      toBackground(tester);
      clock.advance(const Duration(seconds: 20));
      scheduler.tapNotification(sadhanaTimerGroup);
      toFront(tester);
      await tester.pump();
      expect(state(c).completed, isTrue);
      expect(state(c).count, 4);
      expect(rings(), 0);
    });
  });

  group('caught up on return, never past the target', () {
    tw('Rhythm count = elapsed ÷ pace, shown at once', (tester) async {
      final c = make();
      await startRhythm(tester, c, target: 100, pace: 2);
      toBackground(tester);
      clock.advance(const Duration(seconds: 21));
      toFront(tester); // no pump: the number is right immediately
      expect(state(c).count, 10);
      expect(state(c).running, isTrue);
      await pass(tester, const Duration(seconds: 1));
      expect(state(c).count, 11, reason: 'the next beat is due 2 s after beat 10');
    });

    tw('Rhythm count is capped at the target', (tester) async {
      final c = make();
      await startRhythm(tester, c, target: 12, pace: 2);
      toBackground(tester);
      clock.advance(const Duration(hours: 1));
      toFront(tester);
      expect(state(c).count, 12);
      expect(state(c).completed, isTrue);
    });

    tw('time target: elapsed capped at the target; Rhythm beats counted only '
        'up to the end', (tester) async {
      final c = make();
      notifier(c).setRhythmSeconds(2);
      await startTime(tester, c, CountMode.rhythm, 30);
      toBackground(tester);
      clock.advance(const Duration(minutes: 10));
      toFront(tester);
      expect(state(c).elapsedSeconds, 30);
      expect(state(c).count, 15);
      expect(state(c).completed, isTrue);
    });
  });

  group('the app was closed', () {
    tw('reopened after the finish: shows it finished, stays quiet',
        (tester) async {
      final c1 = make();
      await startRhythm(tester, c1, target: 6, pace: 10);
      await pass(tester, const Duration(seconds: 10)); // 1 counted
      containers.remove(c1);
      c1.dispose(); // the app is closed

      clock.advance(const Duration(minutes: 5)); // the phone alarm rang
      final c2 = make();
      final s = state(c2);
      expect(s.count, 6);
      expect(s.completed, isTrue);
      expect(s.running, isFalse);
      await tester.pump();
      expect(rings(), 0);
      expect(scheduler.dismissed, contains(sadhanaTimerGroup));
    });

    tw('reopened mid-session: caught up and still running, alarm unchanged',
        (tester) async {
      final c1 = make();
      final start = clock.now;
      await startTime(tester, c1, CountMode.tap, 600);
      containers.remove(c1);
      c1.dispose();

      clock.advance(const Duration(seconds: 125));
      final c2 = make();
      expect(state(c2).elapsedSeconds, 125);
      expect(state(c2).running, isTrue);
      await tester.pump();
      expect(alarm().when, start.add(const Duration(seconds: 600)).add(margin));
      await pass(tester, const Duration(seconds: 5));
      expect(state(c2).elapsedSeconds, 130);
    });
  });

  group('permissions: asked when first needed, refusals never crash', () {
    tw('notifications refused: no alarm, the app still rings at the end',
        (tester) async {
      scheduler.permission = false;
      final c = make();
      await startTime(tester, c, CountMode.tap, 3);
      expect(alarms(), isEmpty);
      await pass(tester, const Duration(seconds: 4));
      expect(rings(), 1);
    });

    tw('exact alarms refused: a flexible alarm, a one-line note, and an '
        'offer to allow (once)', (tester) async {
      scheduler
        ..exact = false
        ..grantExact = false;
      AppStorage.settings.put(SadhanaSessionNotifier.alarmExplainedKey, true); // seen
      final c = make();
      await startTime(tester, c, CountMode.rhythm, 60);
      await tester.pump();
      expect(alarms(), isNotEmpty, reason: 'still set, just not exact');
      expect(state(c).alarmMayBeLate, isTrue);
      final notice = c.read(sessionNoticeProvider)!;
      expect(notice.onAction, isNotNull);
      notice.onAction!();
      await tester.pump();
      expect(scheduler.exactRequests, 1);
      expect(state(c).alarmMayBeLate, isTrue, reason: 'still refused');

      notifier(c).pause();
      notifier(c).toggleRunning();
      await tester.pump();
      expect(c.read(sessionNoticeProvider), same(notice), reason: 'offered once only');
      expect(AppStorage.settings.get(SadhanaSessionNotifier.askedExactKey), isTrue);
    });

    tw('exact alarms allowed from the offer: the note goes away', (tester) async {
      scheduler.exact = false;
      AppStorage.settings.put(SadhanaSessionNotifier.alarmExplainedKey, true); // seen
      final c = make();
      await startTime(tester, c, CountMode.rhythm, 60);
      await tester.pump();
      c.read(sessionNoticeProvider)!.onAction!();
      await tester.pump();
      await tester.pump();
      expect(state(c).alarmMayBeLate, isFalse);
      expect(alarms(), isNotEmpty);
    });

    tw('full-screen refused: offered once; the alarm is a heads-up instead',
        (tester) async {
      scheduler
        ..fullScreen = false
        ..grantFullScreen = false;
      AppStorage.settings.put(SadhanaSessionNotifier.alarmExplainedKey, true); // seen
      final c = make();
      await startTime(tester, c, CountMode.tap, 60);
      await tester.pump();
      expect(alarms(), isNotEmpty);
      c.read(sessionNoticeProvider)!.onAction!();
      await tester.pump();
      expect(scheduler.fullScreenRequests, 1);
      expect(AppStorage.settings.get(SadhanaSessionNotifier.askedFullScreenKey), isTrue);
    });

    tw('a scheduler that throws: no crash, the app still rings', (tester) async {
      scheduler = _ThrowingScheduler();
      final c = make();
      await startTime(tester, c, CountMode.tap, 2);
      await pass(tester, const Duration(seconds: 3));
      expect(state(c).completed, isTrue);
      expect(rings(), 1);
    });
  });

  group('the alarm follows the completion settings', () {
    tw('defaults: the chosen ringtone, vibration, played once', (tester) async {
      final c = make();
      await startTime(tester, c, CountMode.tap, 60);
      final style = alarm().style!;
      expect(style.sound, 'temple_bell');
      expect(style.vibrate, isTrue);
      expect(style.insistent, isFalse);
    });

    tw('Ringtone off: silent; Vibration off: no vibration', (tester) async {
      final c = make();
      settings(c)
        ..setRingtoneEnabled(false)
        ..setVibrationEnabled(false);
      await startTime(tester, c, CountMode.tap, 60);
      expect(alarm().style!.sound, isNull);
      expect(alarm().style!.vibrate, isFalse);
      expect(alarm().style!.insistent, isFalse);
    });

    tw('"Until stopped" (sound or vibration): rings until dismissed',
        (tester) async {
      final c = make();
      settings(c).setVibrationRepeat(VibrationRepeat.untilStopped);
      await startTime(tester, c, CountMode.tap, 60);
      expect(alarm().style!.insistent, isTrue);
      settings(c).setSoundRepeat(SoundRepeat.repeat); // a few times: not native
      settings(c).setVibrationRepeat(VibrationRepeat.once);
      await tester.pump();
      expect(alarm().style!.insistent, isFalse);
    });
  });

  tw('tapping the Sadhana alarm opens the Sadhana tab', (tester) async {
    final rig = profileRig(saved: {'onboarding.done': true});
    addTearDown(rig.container.dispose);
    phoneScreen(tester, height: 2400);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: rig.container, child: const SadhoApp()));
    await tester.pump();
    expect(rig.container.read(shellTabProvider), ShellTab.home);
    rig.scheduler.tapNotification(sadhanaTimerGroup);
    await tester.pump();
    expect(rig.container.read(shellTabProvider), ShellTab.sadhana);
  });

  group('keep screen on while counting', () {
    test('defaults to ON and is saved', () {
      final c = ProviderContainer(overrides: testOverrides());
      addTearDown(c.dispose);
      expect(c.read(completionSettingsProvider).keepScreenOn, isTrue);
      c.read(completionSettingsProvider.notifier).setKeepScreenOn(false);
      final again = ProviderContainer(overrides: testOverrides());
      addTearDown(again.dispose);
      expect(again.read(completionSettingsProvider).keepScreenOn, isFalse);
    });

    Future<ProviderContainer> sadhanaScreen(WidgetTester tester) async {
      final c = make();
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: Scaffold(body: SadhanaScreen())),
      ));
      return c;
    }

    tw('on only while running; off on pause, completion and reset',
        (tester) async {
      final c = await sadhanaScreen(tester);
      expect(wakelock.on, isFalse, reason: 'not running');
      await startRhythm(tester, c, target: 3, pace: 1);
      expect(wakelock.on, isTrue);
      notifier(c).pause();
      await tester.pump();
      expect(wakelock.on, isFalse, reason: 'paused');
      notifier(c).toggleRunning();
      await tester.pump();
      expect(wakelock.on, isTrue);
      await pass(tester, const Duration(seconds: 4));
      expect(state(c).completed, isTrue);
      expect(wakelock.on, isFalse, reason: 'completed');
      notifier(c).reset();
      notifier(c).toggleRunning();
      await tester.pump();
      expect(wakelock.on, isTrue);
      notifier(c).reset();
      await tester.pump();
      expect(wakelock.on, isFalse, reason: 'reset');
    });

    tw('never with the setting off', (tester) async {
      final c = await sadhanaScreen(tester);
      settings(c).setKeepScreenOn(false);
      await startTime(tester, c, CountMode.tap, 60);
      expect(state(c).running, isTrue);
      expect(wakelock.enables, 0);
      settings(c).setKeepScreenOn(true);
      await tester.pump();
      expect(wakelock.on, isTrue, reason: 'turned on mid-run applies at once');
      settings(c).setKeepScreenOn(false);
      await tester.pump();
      expect(wakelock.on, isFalse);
    });

    tw('released on leaving the screen, and while it is hidden',
        (tester) async {
      final c = await sadhanaScreen(tester);
      await startTime(tester, c, CountMode.rhythm, 60);
      expect(wakelock.on, isTrue);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
            home: Scaffold(
                body: TickerMode(enabled: false, child: SadhanaScreen()))),
      ));
      expect(wakelock.on, isFalse, reason: 'another tab or page covers it');
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: Scaffold(body: Text('elsewhere'))),
      ));
      expect(wakelock.on, isFalse);
    });

    tw('Focus mode keeps it on while running; exiting releases it',
        (tester) async {
      final c = make();
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                  onPressed: () => openFocusMode(context), child: const Text('open')),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await startTime(tester, c, CountMode.tap, 60);
      expect(wakelock.on, isTrue);
      final hold =
          await tester.startGesture(tester.getCenter(find.text('Hold to exit')));
      await tester.pump();
      await tester.pump(focusExitHold + const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      await hold.up();
      expect(find.byType(FocusModeScreen), findsNothing);
      expect(wakelock.on, isFalse);
    });

    tw('the Completion card has the switch', (tester) async {
      final c = make();
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
            home: Scaffold(body: SingleChildScrollView(child: CompletionSettingsCard()))),
      ));
      expect(find.text('Keep screen on while counting'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('keep-screen-on')));
      await tester.pump();
      expect(c.read(completionSettingsProvider).keepScreenOn, isFalse);
    });
  });
}

/// An alarm system that fails every call.
class _ThrowingScheduler extends FakeScheduler {
  @override
  Future<void> replaceAlerts(String group, List<ScheduledAlert> next) async =>
      throw StateError('the alarm system said no');

  @override
  Future<bool> canScheduleExact() async => throw StateError('no');
}
