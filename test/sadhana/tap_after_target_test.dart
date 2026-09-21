import 'package:advance_calendar/features/sadhana/application/completion_settings_provider.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/presentation/focus_mode_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/counter_section.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/progress_ring.dart';
import 'package:advance_calendar/features/sadhana/services/feedback_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

/// Once the target is reached, more taps in Tap mode count for nothing, but the
/// phone answers EVERY one of them with a short vibration tick (Vibration on).
void main() {
  late FakeHaptics haptics;
  late FakeSound sound;

  setUp(() {
    resetStorage();
    seedTrainedVoice();
    haptics = FakeHaptics();
    sound = FakeSound();
  });

  ProviderContainer make({FakeHaptics? h}) {
    haptics = h ?? haptics;
    final c = ProviderContainer(overrides: testOverrides(haptics: haptics, sound: sound));
    addTearDown(c.dispose);
    return c;
  }

  SadhanaSessionNotifier notifier(ProviderContainer c) =>
      c.read(sadhanaSessionProvider.notifier);
  SadhanaState state(ProviderContainer c) => c.read(sadhanaSessionProvider);
  CompletionSettingsNotifier settings(ProviderContainer c) =>
      c.read(completionSettingsProvider.notifier);

  /// Vibrations that are a short single pulse (the acknowledgement), not the
  /// completion pattern.
  List<HapticCall> pulses() => haptics.calls.where((h) => !h.isPattern).toList();
  int strong() => haptics.calls.where((h) => h.isPattern || h.totalMs > 300).length;

  /// A finished 3-count session in Tap mode.
  Future<ProviderContainer> finished({CountScope scope = CountScope.combined}) async {
    final c = make();
    notifier(c)
      ..setCountScope(scope)
      ..setTargetCount(3)
      ..tap()
      ..tap()
      ..tap();
    await pumpEventQueue();
    expect(state(c).completed, isTrue);
    haptics.calls.clear(); // forget the completion buzz
    sound.plays.clear();
    return c;
  }

  group('the acknowledgement tick', () {
    for (final scope in CountScope.values) {
      test('EVERY tap after the target buzzes once: ${scope.name}', () async {
        final c = await finished(scope: scope);
        for (var i = 1; i <= 30; i++) {
          notifier(c).tap();
          await pumpEventQueue();
          expect(pulses().length, i, reason: 'tap $i must buzz, not just the first few');
        }
        expect(state(c).count, 3, reason: 'the count stays at the target');
      });
    }

    test('it is a short tick, not a milestone or completion buzz', () async {
      final c = await finished();
      notifier(c).tap();
      await pumpEventQueue();
      final tick = haptics.calls.single;
      expect(tick.isPattern, isFalse);
      expect(tick.duration, DeviceFeedbackService.ackMs(3));
      expect(tick.duration, lessThan(DeviceFeedbackService.pulseMs(1)),
          reason: 'shorter than even the gentlest milestone buzz');
    });

    test('there is no sound, and nothing else fires', () async {
      final c = await finished();
      for (var i = 0; i < 10; i++) {
        notifier(c).tap();
      }
      await pumpEventQueue();
      expect(sound.plays, isEmpty);
      expect(strong(), 0);
    });

    test('with Vibration off there is no tick at all', () async {
      final c = await finished();
      settings(c).setVibrationEnabled(false);
      for (var i = 0; i < 10; i++) {
        notifier(c).tap();
      }
      await pumpEventQueue();
      expect(haptics.calls, isEmpty);
    });

    test('Ringtone off does not affect the tick; Ringtone on adds no sound to it',
        () async {
      final c = await finished();
      settings(c).setRingtoneEnabled(false);
      notifier(c).tap();
      await pumpEventQueue();
      expect(haptics.calls.length, 1);
      settings(c).setRingtoneEnabled(true);
      notifier(c).tap();
      await pumpEventQueue();
      expect(haptics.calls.length, 2);
      expect(sound.plays, isEmpty);
    });

    test('turning Vibration back on brings the tick back', () async {
      final c = await finished();
      settings(c).setVibrationEnabled(false);
      notifier(c).tap();
      settings(c).setVibrationEnabled(true);
      notifier(c).tap();
      await pumpEventQueue();
      expect(haptics.calls.length, 1);
    });

    test('rapid taps are never throttled or dropped', () async {
      final c = await finished();
      for (var i = 0; i < 200; i++) {
        notifier(c).tap(); // no waiting in between, like a fast finger
      }
      await pumpEventQueue();
      expect(pulses().length, 200);
    });

    test('a long pause between taps changes nothing', () async {
      final c = await finished();
      notifier(c).tap();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      notifier(c).tap();
      await pumpEventQueue();
      expect(pulses().length, 2);
    });

    test('the level sets the tick: 50 ms at level 1 up to 90 ms at level 5', () async {
      for (var level = 1; level <= 5; level++) {
        final c = await finished();
        settings(c).setVibrationLevel(level);
        haptics.calls.clear();
        notifier(c).tap();
        await pumpEventQueue();
        expect(haptics.calls.single.duration, 40 + level * 10, reason: 'level $level');
      }
      expect(DeviceFeedbackService.ackMs(0), DeviceFeedbackService.ackMs(1));
      expect(DeviceFeedbackService.ackMs(9), DeviceFeedbackService.ackMs(5));
    });

    test('a phone with strength control gets the level\'s strength; one without '
        'still gets the tick', () async {
      final withAmp = make(h: FakeHaptics(amplitude: true));
      notifier(withAmp)
        ..setTargetCount(1)
        ..tap();
      await pumpEventQueue();
      haptics.calls.clear();
      notifier(withAmp).tap();
      await pumpEventQueue();
      expect(haptics.calls.single.amplitude, DeviceFeedbackService.amplitudeFor(3));

      final without = make(h: FakeHaptics(amplitude: false));
      notifier(without)
        ..setTargetCount(1)
        ..tap();
      await pumpEventQueue();
      haptics.calls.clear();
      notifier(without).tap();
      await pumpEventQueue();
      expect(haptics.calls.single.amplitude, -1);
      expect(haptics.calls.single.duration, DeviceFeedbackService.ackMs(3));
    });

    test('a phone with no vibrator, or a broken one, never crashes', () async {
      final none = make(h: FakeHaptics(vibrator: false));
      notifier(none)
        ..setTargetCount(1)
        ..tap();
      notifier(none).tap();
      await pumpEventQueue();
      expect(haptics.calls, isEmpty);

      final broken = make(h: FakeHaptics(failing: true));
      notifier(broken)
        ..setTargetCount(1)
        ..tap();
      notifier(broken).tap();
      await pumpEventQueue();
      expect(state(broken).count, 1);
    });
  });

  group('only in Tap mode, only once the target is reached', () {
    test('taps before the target count and do not tick', () async {
      final c = make();
      notifier(c).setTargetCount(5);
      for (var i = 0; i < 3; i++) {
        notifier(c).tap();
      }
      await pumpEventQueue();
      expect(state(c).count, 3);
      expect(haptics.calls, isEmpty, reason: 'no milestone, no completion, no tick');
    });

    test('the tap that reaches the target gives the completion buzz, not a tick',
        () async {
      final c = make();
      notifier(c)
        ..setTargetCount(2)
        ..tap()
        ..tap();
      await pumpEventQueue();
      expect(haptics.calls.length, 1);
      expect(haptics.calls.single.isPattern, isTrue);
    });

    for (final mode in [CountMode.rhythm, CountMode.voice, CountMode.mala]) {
      test('${mode.name} mode: a tap does nothing at all, finished or not', () async {
        final c = make();
        notifier(c)
          ..setMode(mode)
          ..setTargetCount(1)
          ..increment(); // reach the target with the + button
        await pumpEventQueue();
        haptics.calls.clear();
        for (var i = 0; i < 5; i++) {
          notifier(c).tap();
        }
        await pumpEventQueue();
        expect(haptics.calls, isEmpty);
        expect(state(c).count, 1);
      });
    }

    test('raising the target re-opens the session: taps count again, no ticks',
        () async {
      final c = await finished();
      notifier(c).tap();
      await pumpEventQueue();
      expect(pulses().length, 1);
      notifier(c).setTargetCount(10);
      notifier(c).tap();
      await pumpEventQueue();
      expect(state(c).count, 4);
      expect(pulses().length, 1, reason: 'a counted tap is not acknowledged');
    });

    test('Reset re-opens it too', () async {
      final c = await finished();
      notifier(c).reset();
      notifier(c).tap();
      await pumpEventQueue();
      expect(state(c).count, 1);
      expect(haptics.calls, isEmpty);
    });

    test('in Separate, only the mode that finished ticks', () async {
      final c = await finished(scope: CountScope.separate);
      // Tap mode is done; Rhythm has its own count and is not.
      notifier(c).setMode(CountMode.rhythm);
      notifier(c).tap();
      await pumpEventQueue();
      expect(haptics.calls, isEmpty);
      notifier(c).setMode(CountMode.tap);
      notifier(c).tap();
      await pumpEventQueue();
      expect(haptics.calls.length, 1);
    });

    test('in Combined, the other modes\' counts finish the target for Tap too',
        () async {
      final c = make();
      notifier(c)
        ..setTargetCount(3)
        ..setMode(CountMode.rhythm)
        ..increment()
        ..increment()
        ..increment()
        ..setMode(CountMode.tap);
      await pumpEventQueue();
      haptics.calls.clear();
      notifier(c).tap();
      await pumpEventQueue();
      expect(haptics.calls.length, 1, reason: 'the shared count is at the target');
      expect(state(c).count, 3);
    });

    test('after a TIME target completes, Tap mode ticks too', () async {
      final c = make();
      final n = notifier(c)
        ..setTargetType(TargetType.time)
        ..setTargetSeconds(2);
      // Reach the time target without waiting: 2 seconds of clock in the Tap mode.
      c.read(sadhanaSessionProvider.notifier).state = state(c).withProgress(
          const ModeProgress(elapsedSeconds: 2));
      await pumpEventQueue();
      expect(state(c).completed, isTrue);
      haptics.calls.clear();
      n.tap();
      n.tap();
      await pumpEventQueue();
      expect(haptics.calls.length, 2);
    });
  });

  group('through the real screens', () {
    testWidgets('tapping the ring after the target ticks every time', (tester) async {
      final fb = FakeFeedback();
      final c = ProviderContainer(overrides: testOverrides(feedback: fb));
      addTearDown(c.dispose);
      c.read(sadhanaSessionProvider.notifier).setTargetCount(2);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: CounterSection()))),
      ));
      await tester.pump();
      await tester.tap(find.byType(ProgressRing));
      await tester.tap(find.byType(ProgressRing));
      await tester.pump();
      expect(fb.completions, 1);
      expect(fb.acknowledgements, 0);
      for (var i = 1; i <= 12; i++) {
        await tester.tap(find.byType(ProgressRing));
        await tester.pump();
        expect(fb.acknowledgements, i);
      }
      expect(c.read(sadhanaSessionProvider).count, 2);
      expect(fb.completions, 1, reason: 'the completion buzz is not repeated');
    });

    testWidgets('a tap anywhere in Focus mode after the target ticks every time',
        (tester) async {
      final fb = FakeFeedback();
      final c = ProviderContainer(overrides: testOverrides(feedback: fb));
      addTearDown(c.dispose);
      c.read(sadhanaSessionProvider.notifier).setTargetCount(1);
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
      await tester.tapAt(const Offset(40, 300));
      await tester.pump();
      expect(fb.completions, 1);
      for (var i = 1; i <= 8; i++) {
        await tester.tapAt(Offset(40.0 + i, 300));
        await tester.pump();
        expect(fb.acknowledgements, i);
      }
    });
  });
}
