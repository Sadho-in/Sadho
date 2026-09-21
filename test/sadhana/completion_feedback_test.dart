import 'package:advance_calendar/features/sadhana/application/completion_settings_provider.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/data/ringtone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

/// Completion and milestone feedback, end to end: a real session -> the REAL
/// feedback service (settings switches, intensity) -> fake vibrator + speaker.
/// In every counting mode and in both Combined and Separate scopes.
void main() {
  late FakeHaptics haptics;
  late FakeSound sound;
  late FakeVoice voice;
  late FakeVolume volume;

  setUp(() {
    resetStorage();
    seedTrainedVoice(); // Voice only counts a trained mantra
    haptics = FakeHaptics();
    sound = FakeSound();
    voice = FakeVoice();
    volume = FakeVolume();
  });

  ProviderContainer make() {
    final c = ProviderContainer(
      overrides: testOverrides(
          haptics: haptics, sound: sound, voice: voice, volume: volume),
    );
    addTearDown(c.dispose);
    return c;
  }

  SadhanaSessionNotifier notifier(ProviderContainer c) =>
      c.read(sadhanaSessionProvider.notifier);
  SadhanaState state(ProviderContainer c) => c.read(sadhanaSessionProvider);
  CompletionSettingsNotifier settings(ProviderContainer c) =>
      c.read(completionSettingsProvider.notifier);

  /// Puts the session in [mode] and [scope], armed if the mode needs Start.
  Future<void> arm(ProviderContainer c, CountMode mode, CountScope scope) async {
    final n = notifier(c)
      ..setCountScope(scope)
      ..setMode(mode);
    if (mode == CountMode.voice || mode == CountMode.mala) {
      n.toggleRunning();
      await pumpEventQueue();
    }
  }

  /// One input in the mode's own way (rhythm has its own timed helper).
  void input(ProviderContainer c, CountMode mode) => switch (mode) {
        CountMode.tap => notifier(c).tap(),
        CountMode.voice => voice.hear(),
        CountMode.mala => volume.press(),
        CountMode.rhythm => throw StateError('rhythm counts by timer'),
      };

  final immediateModes = [CountMode.tap, CountMode.voice, CountMode.mala];
  final scopes = CountScope.values;
  const toggles = [(true, true), (true, false), (false, true), (false, false)];

  String label(CountMode m, CountScope s) => '${m.name} / ${s.name}';

  int buzzes() => haptics.calls.length;
  int strongBuzzes() => haptics.calls.where((h) => h.isPattern).length;
  int pulses() => haptics.calls.where((h) => !h.isPattern).length;

  group('reaching the target (count) fires the completion feedback', () {
    for (final scope in scopes) {
      for (final mode in immediateModes) {
        test(label(mode, scope), () async {
          final c = make();
          await arm(c, mode, scope);
          notifier(c).setTargetCount(3);

          input(c, mode);
          input(c, mode);
          expect(buzzes(), 0, reason: 'nothing before the target');
          expect(sound.plays, isEmpty);
          expect(state(c).completed, isFalse);

          input(c, mode);
          expect(state(c).completed, isTrue);
          await pumpEventQueue();
          expect(strongBuzzes(), 1, reason: 'one strong completion buzz');
          expect(pulses(), 0, reason: 'a completion is not a milestone');
          expect(sound.plays, [Ringtone.templeBell.asset],
              reason: 'the chosen sound (default: temple bell)');

          input(c, mode); // ignored: the target is already reached
          input(c, mode);
          await pumpEventQueue();
          expect(strongBuzzes(), 1, reason: 'fires once, not on every extra input');
          expect(sound.plays.length, 1);
        });
      }

      testWidgets('rhythm / ${scope.name}', (tester) async {
        final c = make();
        final n = notifier(c)
          ..setCountScope(scope)
          ..setMode(CountMode.rhythm)
          ..setRhythmSeconds(1)
          ..setTargetCount(3)
          ..toggleRunning();
        await tester.pump(const Duration(milliseconds: 2500));
        expect(buzzes(), 0);
        await tester.pump(const Duration(seconds: 1));
        expect(state(c).completed, isTrue);
        expect(strongBuzzes(), 1);
        expect(sound.plays.length, 1);
        await tester.pump(const Duration(seconds: 5));
        expect(strongBuzzes(), 1, reason: 'the timer stopped at the target');
        expect(sound.plays.length, 1);
        n.pause();
      });
    }
  });

  group('the Vibration and Ringtone switches are independent', () {
    for (final scope in scopes) {
      for (final mode in immediateModes) {
        for (final (vib, ring) in toggles) {
          test('${label(mode, scope)}: vibration ${vib ? 'ON' : 'OFF'}, '
              'ringtone ${ring ? 'ON' : 'OFF'}', () async {
            final c = make();
            settings(c)
              ..setVibrationEnabled(vib)
              ..setRingtoneEnabled(ring);
            await arm(c, mode, scope);
            notifier(c).setTargetCount(2);
            input(c, mode);
            input(c, mode);
            await pumpEventQueue();
            expect(state(c).completed, isTrue);
            expect(strongBuzzes(), vib ? 1 : 0, reason: 'vibration');
            expect(sound.plays.length, ring ? 1 : 0, reason: 'ringtone');
          });
        }
      }

      for (final (vib, ring) in toggles) {
        testWidgets('rhythm / ${scope.name}: vibration ${vib ? 'ON' : 'OFF'}, '
            'ringtone ${ring ? 'ON' : 'OFF'}', (tester) async {
          final c = make();
          settings(c)
            ..setVibrationEnabled(vib)
            ..setRingtoneEnabled(ring);
          notifier(c)
            ..setCountScope(scope)
            ..setMode(CountMode.rhythm)
            ..setRhythmSeconds(1)
            ..setTargetCount(2)
            ..toggleRunning();
          await tester.pump(const Duration(seconds: 3));
          expect(state(c).completed, isTrue);
          expect(strongBuzzes(), vib ? 1 : 0);
          expect(sound.plays.length, ring ? 1 : 0);
        });
      }
    }

    test('switching a toggle during the session applies at the target',
        () async {
      final c = make();
      await arm(c, CountMode.tap, CountScope.combined);
      notifier(c).setTargetCount(3);
      notifier(c).tap();
      settings(c).setVibrationEnabled(false);
      notifier(c).tap();
      settings(c)
        ..setVibrationEnabled(true)
        ..setRingtoneEnabled(false);
      notifier(c).tap();
      await pumpEventQueue();
      expect(strongBuzzes(), 1, reason: 'vibration was on at the end');
      expect(sound.plays, isEmpty, reason: 'ringtone was off at the end');
    });

    test('the CHOSEN sound and intensity are used', () async {
      final c = make();
      settings(c)
        ..setRingtone(Ringtone.deepGong)
        ..setVibrationLevel(5);
      await arm(c, CountMode.tap, CountScope.combined);
      notifier(c).setTargetCount(1);
      notifier(c).tap();
      await pumpEventQueue();
      expect(sound.plays, [Ringtone.deepGong.asset]);
      final buzz = haptics.calls.single;
      expect(buzz.intensities.where((i) => i > 0).every((i) => i == 255), isTrue,
          reason: 'level 5 is full strength');
    });

    test('on a phone that cannot set strength the buzz is long and clear',
        () async {
      haptics = FakeHaptics(amplitude: false);
      final c = make();
      settings(c).setVibrationLevel(2);
      await arm(c, CountMode.tap, CountScope.combined);
      notifier(c).setTargetCount(1);
      notifier(c).tap();
      await pumpEventQueue();
      expect(haptics.calls.single.totalMs, greaterThanOrEqualTo(1200));
      expect(haptics.calls.single.isPattern, isTrue);
    });

    test('both OFF: silent and still', () async {
      final c = make();
      settings(c)
        ..setVibrationEnabled(false)
        ..setRingtoneEnabled(false);
      await arm(c, CountMode.tap, CountScope.combined);
      notifier(c).setTargetCount(108);
      for (var i = 0; i < 108; i++) {
        notifier(c).tap();
      }
      await pumpEventQueue();
      expect(state(c).completed, isTrue);
      expect(buzzes(), 0);
      expect(sound.plays, isEmpty);
    });
  });

  group('the 108 milestone buzz', () {
    for (final scope in scopes) {
      for (final mode in immediateModes) {
        test(label(mode, scope), () async {
          final c = make();
          await arm(c, mode, scope);
          notifier(c).setTargetCount(1008);
          for (var i = 0; i < 107; i++) {
            input(c, mode);
          }
          await pumpEventQueue();
          expect(buzzes(), 0, reason: '107 counts: nothing yet');

          input(c, mode); // the 108th
          await pumpEventQueue();
          expect(pulses(), 1, reason: 'one milestone pulse at 108');
          expect(strongBuzzes(), 0, reason: 'not the completion buzz');
          expect(sound.plays, isEmpty, reason: 'a milestone never plays a sound');

          for (var i = 0; i < 108; i++) {
            input(c, mode); // up to 216
          }
          await pumpEventQueue();
          expect(pulses(), 2, reason: 'and again at 216');
        });
      }

      testWidgets('rhythm / ${scope.name}', (tester) async {
        final c = make();
        final n = notifier(c)
          ..setCountScope(scope)
          ..setMode(CountMode.rhythm)
          ..setRhythmSeconds(0.2)
          ..setTargetCount(1008)
          ..toggleRunning();
        await tester.pump(const Duration(seconds: 21)); // 105 counts
        expect(buzzes(), 0);
        await tester.pump(const Duration(seconds: 1)); // past 108
        expect(pulses(), 1);
        expect(strongBuzzes(), 0);
        expect(sound.plays, isEmpty);
        n.toggleRunning();
      });
    }

    test('with Vibration off there is no milestone buzz', () async {
      final c = make();
      settings(c).setVibrationEnabled(false);
      await arm(c, CountMode.tap, CountScope.combined);
      notifier(c).setTargetCount(1008);
      for (var i = 0; i < 216; i++) {
        notifier(c).tap();
      }
      expect(buzzes(), 0);
    });

    test('Ringtone off does not affect the milestone buzz', () async {
      final c = make();
      settings(c).setRingtoneEnabled(false);
      await arm(c, CountMode.tap, CountScope.combined);
      notifier(c).setTargetCount(1008);
      for (var i = 0; i < 108; i++) {
        notifier(c).tap();
      }
      await pumpEventQueue();
      expect(pulses(), 1);
    });

    test('a target of 108 gets the completion buzz, not a milestone as well',
        () async {
      final c = make();
      await arm(c, CountMode.tap, CountScope.combined);
      notifier(c).setTargetCount(108);
      for (var i = 0; i < 108; i++) {
        notifier(c).tap();
      }
      await pumpEventQueue();
      expect(strongBuzzes(), 1);
      expect(pulses(), 0);
      expect(sound.plays.length, 1);
    });

    test('the default session (target 108) ends with buzz and sound',
        () async {
      final c = make();
      expect(state(c).targetCount, 108);
      for (var i = 0; i < 108; i++) {
        notifier(c).tap();
      }
      await pumpEventQueue();
      expect(state(c).completed, isTrue);
      expect(strongBuzzes(), 1);
      expect(sound.plays.length, 1);
    });
  });

  group('Combined: one shared count and target', () {
    test('modes together reach the target: one completion, at the last count',
        () async {
      final c = make();
      final n = notifier(c)..setTargetCount(4);
      n.tap();
      n.tap();
      n.setMode(CountMode.voice);
      n.toggleRunning();
      await pumpEventQueue();
      voice.hear();
      await pumpEventQueue();
      expect(buzzes(), 0, reason: '3 of 4');
      voice.hear();
      await pumpEventQueue();
      expect(state(c).completed, isTrue);
      expect(strongBuzzes(), 1);
      expect(sound.plays.length, 1);
    });

    test('the milestone counts every mode together', () async {
      final c = make();
      notifier(c).setTargetCount(1008);
      for (var i = 0; i < 100; i++) {
        notifier(c).tap();
      }
      notifier(c).setMode(CountMode.mala);
      notifier(c).toggleRunning();
      await pumpEventQueue();
      for (var i = 0; i < 7; i++) {
        volume.press();
      }
      expect(buzzes(), 0, reason: '107 together');
      volume.press();
      await pumpEventQueue();
      expect(pulses(), 1, reason: '100 Tap + 8 Mala = 108');
    });
  });

  group('Separate: each mode has its own target', () {
    test('completing the active mode fires; another mode fires again on its own',
        () async {
      final c = make();
      final n = notifier(c)
        ..setCountScope(CountScope.separate)
        ..setTargetCount(3);
      n
        ..tap()
        ..tap()
        ..tap();
      await pumpEventQueue();
      expect(strongBuzzes(), 1, reason: 'Tap reached its own target');
      expect(sound.plays.length, 1);

      n.setMode(CountMode.mala);
      n.toggleRunning();
      await pumpEventQueue();
      expect(state(c).completed, isFalse, reason: 'Mala is a fresh count');
      volume.press();
      volume.press();
      await pumpEventQueue();
      expect(strongBuzzes(), 1, reason: 'Mala is at 2 of 3: nothing yet');
      volume.press();
      await pumpEventQueue();
      expect(strongBuzzes(), 2, reason: 'Mala completed on its own');
      expect(sound.plays.length, 2);
    });

    test('other modes\' counts do not complete this one', () async {
      final c = make();
      final n = notifier(c)
        ..setCountScope(CountScope.separate)
        ..setTargetCount(4);
      n.tap();
      n.tap();
      n.tap();
      n.setMode(CountMode.mala);
      n.toggleRunning();
      await pumpEventQueue();
      volume.press();
      await pumpEventQueue();
      expect(state(c).completed, isFalse, reason: 'Mala 1 of 4 (Tap has 3)');
      expect(buzzes(), 0, reason: '3 + 1 would be 4 in Combined, but not here');
    });

    test('the milestone is each mode\'s own 108', () async {
      final c = make();
      final n = notifier(c)
        ..setCountScope(CountScope.separate)
        ..setTargetCount(1008);
      for (var i = 0; i < 100; i++) {
        n.tap();
      }
      n.setMode(CountMode.mala);
      n.toggleRunning();
      await pumpEventQueue();
      for (var i = 0; i < 100; i++) {
        volume.press();
      }
      await pumpEventQueue();
      expect(buzzes(), 0, reason: '100 + 100 is 200 in total, but neither mode reached 108');
      for (var i = 0; i < 8; i++) {
        volume.press();
      }
      await pumpEventQueue();
      expect(pulses(), 1, reason: 'Mala reached its own 108');
    });

    test('resetting a mode lets it complete (and buzz) again', () async {
      final c = make();
      final n = notifier(c)
        ..setCountScope(CountScope.separate)
        ..setTargetCount(2);
      n
        ..tap()
        ..tap();
      await pumpEventQueue();
      expect(strongBuzzes(), 1);
      n.reset();
      n
        ..tap()
        ..tap();
      await pumpEventQueue();
      expect(strongBuzzes(), 2);
      expect(sound.plays.length, 2);
    });
  });

  group('time targets', () {
    for (final scope in scopes) {
      testWidgets('tap mode / ${scope.name}: the clock reaching the time fires',
          (tester) async {
        final c = make();
        notifier(c)
          ..setCountScope(scope)
          ..setTargetType(TargetType.time)
          ..setTargetSeconds(3)
          ..tap(); // the first tap starts the clock
        await tester.pump(const Duration(seconds: 2));
        expect(buzzes(), 0);
        await tester.pump(const Duration(seconds: 2));
        expect(state(c).completed, isTrue);
        expect(strongBuzzes(), 1);
        expect(sound.plays.length, 1);
        await tester.pump(const Duration(seconds: 5));
        expect(strongBuzzes(), 1, reason: 'once');
      });

      testWidgets('rhythm mode / ${scope.name}', (tester) async {
        final c = make();
        notifier(c)
          ..setCountScope(scope)
          ..setMode(CountMode.rhythm)
          ..setTargetType(TargetType.time)
          ..setTargetSeconds(3)
          ..toggleRunning();
        await tester.pump(const Duration(seconds: 4));
        expect(state(c).completed, isTrue);
        expect(strongBuzzes(), 1);
        expect(sound.plays.length, 1);
      });

      for (final (vib, ring) in toggles) {
        testWidgets('time target / ${scope.name}: vibration ${vib ? 'ON' : 'OFF'}, '
            'ringtone ${ring ? 'ON' : 'OFF'}', (tester) async {
          final c = make();
          settings(c)
            ..setVibrationEnabled(vib)
            ..setRingtoneEnabled(ring);
          notifier(c)
            ..setCountScope(scope)
            ..setMode(CountMode.rhythm)
            ..setTargetType(TargetType.time)
            ..setTargetSeconds(2)
            ..toggleRunning();
          await tester.pump(const Duration(seconds: 3));
          expect(strongBuzzes(), vib ? 1 : 0);
          expect(sound.plays.length, ring ? 1 : 0);
        });
      }
    }
  });
}
