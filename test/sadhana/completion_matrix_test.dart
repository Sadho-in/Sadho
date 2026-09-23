import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/clock/application/clock_source.dart';
import 'package:advance_calendar/features/sadhana/application/completion_settings_provider.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/data/ringtone.dart';
import 'package:advance_calendar/features/sadhana/presentation/focus_mode_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/counter_section.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../calendar/calendar_support.dart' show FakeScheduler;
import '../clock/clock_support.dart' show FakeClock;
import 'test_support.dart';

/// Where the session is being watched: the Sadhana tab's counter, or the
/// full-screen Focus mode.
enum View { normal, focus }

/// The completion feedback (vibration + ringtone, each per its own switch)
/// fires for EVERY combination of mode × target type × view × scope, driven
/// through the real screens, the real session and the real feedback service
/// (only the vibrator and speaker are fakes).
void main() {
  late FakeHaptics haptics;
  late FakeSound sound;
  late FakeVoice voice;
  late FakeVolume volume;
  late FakeClock clock;

  setUp(() {
    resetStorage();
    seedTrainedVoice(); // Voice only counts a trained mantra
    haptics = FakeHaptics();
    sound = FakeSound();
    voice = FakeVoice();
    volume = FakeVolume();
    clock = FakeClock(DateTime(2026, 9, 24, 7, 0));
  });

  /// A count target of 3, or a time target of 3 seconds.
  const target = 3;

  Future<ProviderContainer> open(WidgetTester tester, View view) async {
    final c = ProviderContainer(
      overrides: [
        ...testOverrides(
          haptics: haptics,
          sound: sound,
          voice: voice,
          volume: volume,
        ),
        clockNowProvider.overrideWithValue(clock.call),
        reminderSchedulerProvider.overrideWithValue(FakeScheduler()),
      ],
    );
    addTearDown(c.dispose);
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: view == View.normal
                  ? const SingleChildScrollView(child: CounterSection())
                  : TextButton(
                      onPressed: () => openFocusMode(context),
                      child: const Text('open'),
                    ),
            ),
          ),
        ),
      ),
    );
    if (view == View.focus) {
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(FocusModeScreen), findsOneWidget);
    }
    return c;
  }

  /// Time passes: the clock and the app's timers move together.
  Future<void> pass(WidgetTester tester, Duration d) async {
    var left = d;
    while (left > Duration.zero) {
      final step = left > const Duration(seconds: 1)
          ? const Duration(seconds: 1)
          : left;
      clock.advance(step);
      await tester.pump(step);
      left -= step;
    }
  }

  /// One screen tap, the way the view takes it: on the ring, or anywhere in
  /// Focus mode.
  Future<void> screenTap(WidgetTester tester, View view) async {
    if (view == View.normal) {
      await tester.tap(find.byType(ProgressRing));
    } else {
      await tester.tapAt(const Offset(40, 300));
    }
    await tester.pump();
  }

  /// Runs a whole session in [mode] until the target must have been reached.
  Future<void> runToTarget(
    WidgetTester tester,
    ProviderContainer c,
    View view,
    CountMode mode,
    TargetType type,
  ) async {
    final n = c.read(sadhanaSessionProvider.notifier);
    if (type == TargetType.time) {
      if (mode == CountMode.tap) {
        await screenTap(tester, view); // the first tap starts the clock
      } else {
        n.toggleRunning();
        await tester.pump();
      }
      await pass(tester, const Duration(seconds: target + 1));
      return;
    }
    switch (mode) {
      case CountMode.tap:
        for (var i = 0; i < target; i++) {
          await screenTap(tester, view);
        }
      case CountMode.rhythm:
        n.toggleRunning();
        await tester.pump();
        await pass(tester, const Duration(seconds: target + 1));
      case CountMode.voice:
        n.toggleRunning();
        await tester.pump();
        for (var i = 0; i < target; i++) {
          voice.hear();
        }
      case CountMode.mala:
        n.toggleRunning();
        await tester.pump();
        for (var i = 0; i < target; i++) {
          volume.press();
        }
    }
    await tester.pump();
  }

  int strong() => haptics.calls.where((h) => h.isPattern).length;

  for (final view in View.values) {
    for (final scope in CountScope.values) {
      for (final mode in CountMode.values) {
        for (final type in TargetType.values) {
          for (final (vib, ring) in const [
            (true, true),
            (true, false),
            (false, true),
            (false, false),
          ]) {
            testWidgets(
              '${view.name} / ${scope.name} / ${mode.name} / ${type.name}: '
              'vibration ${vib ? 'ON' : 'OFF'}, ringtone ${ring ? 'ON' : 'OFF'}',
              (tester) async {
                final c = await open(tester, view);
                c.read(completionSettingsProvider.notifier)
                  ..setVibrationEnabled(vib)
                  ..setRingtoneEnabled(ring);
                c.read(sadhanaSessionProvider.notifier)
                  ..setCountScope(scope)
                  ..setMode(mode)
                  ..setRhythmSeconds(1)
                  ..setTargetType(type)
                  ..setTargetCount(target)
                  ..setTargetSeconds(target);
                await tester.pump();

                await runToTarget(tester, c, view, mode, type);

                final s = c.read(sadhanaSessionProvider);
                expect(s.completed, isTrue, reason: 'the target was reached');
                expect(strong(), vib ? 1 : 0, reason: 'completion buzz');
                expect(
                  sound.plays,
                  ring ? [Ringtone.templeBell.asset] : isEmpty,
                  reason: 'completion ringtone',
                );

                // Nothing more fires afterwards.
                await pass(tester, const Duration(seconds: 10));
                expect(strong(), vib ? 1 : 0, reason: 'once');
                expect(sound.plays.length, ring ? 1 : 0, reason: 'once');

                c.read(sadhanaSessionProvider.notifier).pause();
                await tester.pump();
              },
            );
          }
        }
      }
    }
  }

  group('every count target fires exactly at the target', () {
    for (final count in [27, 108, 1008, 7]) {
      test('$count', () async {
        final c = ProviderContainer(
          overrides: testOverrides(haptics: haptics, sound: sound),
        );
        addTearDown(c.dispose);
        final n = c.read(sadhanaSessionProvider.notifier)
          ..setTargetCount(count);
        for (var i = 1; i < count; i++) {
          n.tap();
        }
        await pumpEventQueue();
        expect(strong(), 0, reason: 'not before the target');
        expect(sound.plays, isEmpty);
        n.tap();
        await pumpEventQueue();
        expect(strong(), 1);
        expect(sound.plays.length, 1);
      });
    }
  });

  group('every time target fires exactly at the end', () {
    for (final (label, seconds) in const [
      ('45 seconds', 45),
      ('5 minutes', 5 * 60),
      ('1 hour', 60 * 60),
      ('custom 1 min 17 s', 77),
    ]) {
      for (final view in View.values) {
        testWidgets('$label / ${view.name}', (tester) async {
          final c = await open(tester, view);
          c.read(sadhanaSessionProvider.notifier)
            ..setTargetType(TargetType.time)
            ..setTargetSeconds(seconds);
          await tester.pump();
          await screenTap(tester, view); // Tap mode: the first tap starts it
          await pass(tester, Duration(seconds: seconds - 1));
          expect(strong(), 0, reason: 'not before the end');
          expect(sound.plays, isEmpty);
          await pass(tester, const Duration(seconds: 2));
          expect(c.read(sadhanaSessionProvider).completed, isTrue);
          expect(strong(), 1);
          expect(sound.plays.length, 1);
        });
      }
    }
  });
}
