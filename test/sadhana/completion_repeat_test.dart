import 'package:advance_calendar/app.dart';
import 'package:advance_calendar/features/sadhana/application/completion_settings_provider.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/presentation/focus_mode_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/sadhana_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/completion_settings_card.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/counter_section.dart';
import 'package:advance_calendar/features/sadhana/services/feedback_service.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../profile/profile_support.dart';
import 'test_support.dart';

/// The completion alert's repeat options (sound: Once / Repeat / Until
/// stopped; vibration: Once / Until stopped), the Stop control, and that
/// Reset and leaving the screen silence it too.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late FakeHaptics haptics;
  late FakeSound sound;

  /// The ringtone lasts 2 s in these tests.
  const ringLength = Duration(seconds: 2);

  setUp(() {
    resetStorage();
    haptics = FakeHaptics();
    sound = FakeSound(length: ringLength);
  });

  ProviderContainer make() {
    final c = ProviderContainer(
      overrides: testOverrides(haptics: haptics, sound: sound),
    );
    addTearDown(c.dispose);
    return c;
  }

  SadhanaSessionNotifier session(ProviderContainer c) =>
      c.read(sadhanaSessionProvider.notifier);
  CompletionSettingsNotifier settings(ProviderContainer c) =>
      c.read(completionSettingsProvider.notifier);
  bool alerting(ProviderContainer c) =>
      c.read(feedbackServiceProvider).alerting.value;
  int strong() => haptics.calls.where((h) => h.isPattern).length;

  /// Reaches a target of 1 with one tap.
  Future<void> complete(WidgetTester tester, ProviderContainer c) async {
    session(c)
      ..setTargetCount(1)
      ..tap();
    await tester.pump();
  }

  /// Ends the test with nothing left ringing (no pending timers).
  Future<void> silence(WidgetTester tester, ProviderContainer c) async {
    session(c).stopAlert();
    await tester.pump(const Duration(seconds: 5));
  }

  group('defaults and storage', () {
    test('both default to Once', () {
      final s = make().read(completionSettingsProvider);
      expect(s.soundRepeat, SoundRepeat.once);
      expect(s.vibrationRepeat, VibrationRepeat.once);
    });

    test('each choice is saved and comes back after a restart', () {
      for (final sr in SoundRepeat.values) {
        for (final vr in VibrationRepeat.values) {
          settings(make())
            ..setSoundRepeat(sr)
            ..setVibrationRepeat(vr);
          final again = make().read(completionSettingsProvider);
          expect(again.soundRepeat, sr);
          expect(again.vibrationRepeat, vr);
        }
      }
    });
  });

  group('sound', () {
    testWidgets('Once: the ringtone plays one time, then the alert ends', (
      tester,
    ) async {
      final c = make();
      await complete(tester, c);
      expect(sound.plays.length, 1);
      expect(alerting(c), isTrue, reason: 'Stop is offered while it sounds');
      await tester.pump(ringLength);
      expect(alerting(c), isFalse);
      await tester.pump(const Duration(minutes: 1));
      expect(sound.plays.length, 1);
    });

    testWidgets('Repeat: $soundRepeatTimes plays, each after the last ended', (
      tester,
    ) async {
      final c = make();
      settings(c).setSoundRepeat(SoundRepeat.repeat);
      await complete(tester, c);
      expect(sound.plays.length, 1);
      await tester.pump(ringLength); // first one ends...
      expect(sound.plays.length, 1, reason: 'a short gap first');
      await tester.pump(soundRepeatGap);
      expect(sound.plays.length, 2);
      await tester.pump(ringLength + soundRepeatGap);
      expect(sound.plays.length, soundRepeatTimes);
      expect(alerting(c), isTrue);
      await tester.pump(ringLength);
      expect(alerting(c), isFalse);
      await tester.pump(const Duration(minutes: 1));
      expect(sound.plays.length, soundRepeatTimes, reason: 'then it stops');
    });

    testWidgets('Until stopped: keeps playing until Stop', (tester) async {
      final c = make();
      settings(c).setSoundRepeat(SoundRepeat.untilStopped);
      await complete(tester, c);
      await tester.pump(const Duration(minutes: 1));
      final perRing = ringLength + soundRepeatGap;
      expect(
        sound.plays.length,
        greaterThanOrEqualTo(
          const Duration(minutes: 1).inMilliseconds ~/ perRing.inMilliseconds,
        ),
      );
      expect(alerting(c), isTrue);

      session(c).stopAlert();
      await tester.pump();
      expect(sound.isPlaying, isFalse, reason: 'the ringtone is cut at once');
      expect(alerting(c), isFalse);
      final played = sound.plays.length;
      await tester.pump(const Duration(minutes: 2));
      expect(sound.plays.length, played, reason: 'and never comes back');
    });

    testWidgets('Until stopped gives up by itself after $alertMaxDuration', (
      tester,
    ) async {
      final c = make();
      settings(c).setSoundRepeat(SoundRepeat.untilStopped);
      await complete(tester, c);
      await tester.pump(alertMaxDuration + const Duration(seconds: 1));
      expect(alerting(c), isFalse);
      final played = sound.plays.length;
      await tester.pump(const Duration(minutes: 1));
      expect(sound.plays.length, played);
    });

    testWidgets('Ringtone off: no sound whatever the repeat option', (
      tester,
    ) async {
      final c = make();
      settings(c)
        ..setRingtoneEnabled(false)
        ..setSoundRepeat(SoundRepeat.untilStopped);
      await complete(tester, c);
      await tester.pump(const Duration(seconds: 30));
      expect(sound.plays, isEmpty);
      expect(strong(), 1, reason: 'the vibration is independent');
      await silence(tester, c);
    });
  });

  group('vibration', () {
    testWidgets('Once: a single completion buzz', (tester) async {
      final c = make();
      settings(c).setRingtoneEnabled(false);
      await complete(tester, c);
      expect(strong(), 1);
      expect(alerting(c), isFalse, reason: 'nothing left to stop');
      await tester.pump(const Duration(minutes: 1));
      expect(strong(), 1);
    });

    testWidgets(
      'Until stopped: a buzz every ${vibrationRepeatEvery.inSeconds} s '
      'until Stop',
      (tester) async {
        final c = make();
        settings(c)
          ..setRingtoneEnabled(false)
          ..setVibrationRepeat(VibrationRepeat.untilStopped);
        await complete(tester, c);
        expect(strong(), 1);
        expect(alerting(c), isTrue);
        await tester.pump(vibrationRepeatEvery);
        expect(strong(), 2);
        await tester.pump(vibrationRepeatEvery * 3);
        expect(strong(), 5);

        session(c).stopAlert();
        await tester.pump();
        expect(haptics.cancels, 1, reason: 'a buzz still going is cut');
        expect(alerting(c), isFalse);
        await tester.pump(const Duration(minutes: 1));
        expect(strong(), 5, reason: 'no more buzzes');
      },
    );

    testWidgets('Vibration off: no buzz whatever the repeat option', (
      tester,
    ) async {
      final c = make();
      settings(c)
        ..setVibrationEnabled(false)
        ..setVibrationRepeat(VibrationRepeat.untilStopped);
      await complete(tester, c);
      await tester.pump(const Duration(seconds: 30));
      expect(haptics.calls, isEmpty);
      await silence(tester, c);
    });
  });

  group('stopping', () {
    Future<ProviderContainer> ringingForever(WidgetTester tester) async {
      final c = make();
      settings(c)
        ..setSoundRepeat(SoundRepeat.untilStopped)
        ..setVibrationRepeat(VibrationRepeat.untilStopped);
      await complete(tester, c);
      await tester.pump(const Duration(seconds: 9));
      expect(alerting(c), isTrue);
      return c;
    }

    void expectSilentFromNowOn(WidgetTester tester, ProviderContainer c) {
      expect(alerting(c), isFalse);
      expect(sound.isPlaying, isFalse);
      expect(haptics.cancels, greaterThanOrEqualTo(1));
    }

    Future<void> expectNothingMore(WidgetTester tester) async {
      final plays = sound.plays.length, buzzes = strong();
      await tester.pump(const Duration(minutes: 2));
      expect(sound.plays.length, plays);
      expect(strong(), buzzes);
    }

    testWidgets('Stop halts sound AND vibration together', (tester) async {
      final c = await ringingForever(tester);
      session(c).stopAlert();
      await tester.pump();
      expectSilentFromNowOn(tester, c);
      await expectNothingMore(tester);
    });

    testWidgets('Reset halts them', (tester) async {
      final c = await ringingForever(tester);
      session(c).reset();
      await tester.pump();
      expectSilentFromNowOn(tester, c);
      await expectNothingMore(tester);
    });

    testWidgets('the Stop button appears on completion and halts them', (
      tester,
    ) async {
      final c = make();
      settings(c)
        ..setSoundRepeat(SoundRepeat.untilStopped)
        ..setVibrationRepeat(VibrationRepeat.untilStopped);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: CounterSection()),
            ),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('stop-alert')), findsNothing);
      await complete(tester, c);
      await tester.pump(const Duration(seconds: 5));
      expect(find.byKey(const ValueKey('stop-alert')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('stop-alert')));
      await tester.pump();
      expectSilentFromNowOn(tester, c);
      expect(find.byKey(const ValueKey('stop-alert')), findsNothing);
      await expectNothingMore(tester);
    });

    testWidgets(
      'Focus mode: the Stop button halts them and is not a counted tap',
      (tester) async {
        final c = make();
        settings(c)
          ..setSoundRepeat(SoundRepeat.untilStopped)
          ..setVibrationRepeat(VibrationRepeat.untilStopped);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: c,
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => openFocusMode(context),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        session(c).setTargetCount(2);
        await tester.tapAt(const Offset(40, 300));
        await tester.tapAt(const Offset(40, 300));
        await tester.pump(const Duration(seconds: 5));
        expect(find.byKey(const ValueKey('stop-alert')), findsOneWidget);
        final acksBefore = haptics.calls.where((h) => !h.isPattern).length;
        await tester.tap(find.byKey(const ValueKey('stop-alert')));
        await tester.pump();
        expectSilentFromNowOn(tester, c);
        expect(
          haptics.calls.where((h) => !h.isPattern).length,
          acksBefore,
          reason: 'pressing Stop is not a tap after the target',
        );
        expect(c.read(sadhanaSessionProvider).count, 2);
        await expectNothingMore(tester);
      },
    );

    testWidgets('leaving Focus mode halts them', (tester) async {
      final c = make();
      settings(c)
        ..setSoundRepeat(SoundRepeat.untilStopped)
        ..setVibrationRepeat(VibrationRepeat.untilStopped);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => openFocusMode(context),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await complete(tester, c);
      final hold = await tester.startGesture(
        tester.getCenter(find.text('Hold to exit')),
      );
      await tester.pump();
      await tester.pump(focusExitHold + const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      await hold.up();
      expect(find.byType(FocusModeScreen), findsNothing);
      expectSilentFromNowOn(tester, c);
      await expectNothingMore(tester);
    });

    testWidgets('leaving the Sadhana screen halts them', (tester) async {
      final c = make();
      settings(c)
        ..setSoundRepeat(SoundRepeat.untilStopped)
        ..setVibrationRepeat(VibrationRepeat.untilStopped);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(home: Scaffold(body: SadhanaScreen())),
        ),
      );
      await complete(tester, c);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(home: Scaffold(body: Text('elsewhere'))),
        ),
      );
      expectSilentFromNowOn(tester, c);
      await expectNothingMore(tester);
    });

    testWidgets('switching away from the Sadhana tab halts them', (
      tester,
    ) async {
      final rig = profileRig(saved: {'onboarding.done': true});
      addTearDown(rig.container.dispose);
      phoneScreen(tester, height: 2400);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: rig.container,
          child: const SadhoApp(),
        ),
      );
      await tester.pump();
      final fb = rig.container.read(feedbackServiceProvider) as FakeFeedback;
      rig.container.read(shellTabProvider.notifier).select(ShellTab.sadhana);
      await tester.pump();
      expect(fb.alertStops, 0);
      rig.container.read(shellTabProvider.notifier).select(ShellTab.home);
      await tester.pump();
      expect(fb.alertStops, 1);
    });
  });

  group('taps after the target never cut the completion alert short', () {
    testWidgets('no tick while the alert sounds; ticks again once stopped', (
      tester,
    ) async {
      final c = make();
      await complete(tester, c);
      haptics.calls.clear();
      session(c).tap();
      await tester.pump();
      expect(
        haptics.calls,
        isEmpty,
        reason: 'a tick would replace the completion buzz still going',
      );
      session(c).stopAlert();
      await tester.pump();
      session(c).tap();
      await tester.pump();
      expect(haptics.calls.length, 1, reason: 'the usual tick is back');
    });
  });

  group('settings card', () {
    testWidgets('the repeat chips set and show the choices', (tester) async {
      final c = make();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: CompletionSettingsCard()),
            ),
          ),
        ),
      );
      expect(find.text('Once'), findsNWidgets(2));
      expect(find.text('$soundRepeatTimes times'), findsOneWidget);
      expect(find.text('Until stopped'), findsOneWidget);
      expect(
        find.text('Every ${vibrationRepeatEvery.inSeconds} s until stopped'),
        findsOneWidget,
      );

      await tester.ensureVisible(
        find.byKey(const ValueKey('sound-repeat-untilStopped')),
      );
      await tester.tap(find.byKey(const ValueKey('sound-repeat-untilStopped')));
      await tester.pump();
      expect(
        c.read(completionSettingsProvider).soundRepeat,
        SoundRepeat.untilStopped,
      );
      await tester.tap(find.byKey(const ValueKey('sound-repeat-repeat')));
      await tester.pump();
      expect(
        c.read(completionSettingsProvider).soundRepeat,
        SoundRepeat.repeat,
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('vibration-repeat-untilStopped')),
      );
      await tester.tap(
        find.byKey(const ValueKey('vibration-repeat-untilStopped')),
      );
      await tester.pump();
      expect(
        c.read(completionSettingsProvider).vibrationRepeat,
        VibrationRepeat.untilStopped,
      );
      await tester.pump(const Duration(seconds: 5)); // previews finish
    });
  });

  test('the Clock timer\'s completion is unaffected: always once', () async {
    final c = make();
    settings(c)
      ..setSoundRepeat(SoundRepeat.untilStopped)
      ..setVibrationRepeat(VibrationRepeat.untilStopped);
    final fb = c.read(feedbackServiceProvider);
    final done = fb.complete();
    expect(fb.alerting.value, isFalse);
    sound.stop(); // end the (2 s) ringtone now
    await done;
    expect(strong(), 1);
    expect(sound.plays.length, 1);
  });
}
