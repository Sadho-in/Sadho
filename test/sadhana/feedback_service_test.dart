import 'package:advance_calendar/features/sadhana/application/completion_settings_provider.dart';
import 'package:advance_calendar/features/sadhana/data/ringtone.dart';
import 'package:advance_calendar/features/sadhana/services/feedback_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

/// The REAL feedback service (settings switches, intensity) on fake hardware.
void main() {
  late FakeHaptics haptics;
  late FakeSound sound;
  CompletionSettings settings = const CompletionSettings();

  DeviceFeedbackService service({
    bool vibrator = true,
    bool amplitude = true,
  }) {
    haptics = FakeHaptics(vibrator: vibrator, amplitude: amplitude);
    sound = FakeSound();
    return DeviceFeedbackService(() => settings, haptics: haptics, sound: sound);
  }

  setUp(() => settings = const CompletionSettings());

  group('target reached: complete()', () {
    for (final (vib, ring) in [(true, true), (true, false), (false, true), (false, false)]) {
      test('vibration ${vib ? 'ON' : 'OFF'}, ringtone ${ring ? 'ON' : 'OFF'}',
          () async {
        settings = CompletionSettings(vibrationEnabled: vib, ringtoneEnabled: ring);
        final s = service();
        await s.complete();
        expect(haptics.calls.length, vib ? 1 : 0,
            reason: 'the buzz follows the Vibration switch only');
        expect(sound.plays.length, ring ? 1 : 0,
            reason: 'the sound follows the Ringtone switch only');
        if (vib) expect(haptics.calls.single.isPattern, isTrue, reason: 'the strong buzz');
      });
    }

    test('plays the CHOSEN sound', () async {
      for (final r in Ringtone.values) {
        settings = CompletionSettings(ringtone: r);
        final s = service();
        await s.complete();
        expect(sound.plays, [r.asset], reason: r.label);
      }
      expect(Ringtone.values.map((r) => r.asset).toSet().length, 4,
          reason: 'four different sounds');
    });

    test('the sound is stopped first so a repeat does not overlap', () async {
      final s = service();
      await s.complete();
      await s.complete();
      expect(sound.stops, 2);
      expect(sound.plays.length, 2);
    });

    test('a vibrator that fails never stops the sound', () async {
      final s = service();
      haptics.failing = true;
      await s.complete();
      expect(sound.plays.length, 1);
    });

    test('a sound player that fails never breaks the buzz or throws', () async {
      final s = service();
      sound.failing = true;
      await s.complete();
      expect(haptics.calls.length, 1);
    });

    test('a phone with no vibrator still plays the sound', () async {
      final s = service(vibrator: false);
      await s.complete();
      expect(haptics.calls, isEmpty);
      expect(sound.plays.length, 1);
    });

    test('the switches are read fresh each time', () async {
      final s = service();
      settings = const CompletionSettings(vibrationEnabled: false);
      await s.complete();
      expect(haptics.calls, isEmpty);
      settings = const CompletionSettings();
      await s.complete();
      expect(haptics.calls.length, 1);
    });
  });

  group('every 108 counts: milestone()', () {
    test('a single buzz when Vibration is on, and no sound ever', () async {
      final s = service();
      await s.milestone();
      expect(haptics.calls.length, 1);
      expect(haptics.calls.single.isPattern, isFalse, reason: 'one short pulse');
      expect(sound.plays, isEmpty);
      expect(sound.stops, 0);
    });

    test('nothing when Vibration is off, even with Ringtone on', () async {
      settings = const CompletionSettings(vibrationEnabled: false, ringtoneEnabled: true);
      final s = service();
      await s.milestone();
      expect(haptics.calls, isEmpty);
      expect(sound.plays, isEmpty);
    });

    test('Ringtone off does not affect the milestone buzz', () async {
      settings = const CompletionSettings(ringtoneEnabled: false);
      final s = service();
      await s.milestone();
      expect(haptics.calls.length, 1);
    });
  });

  group('intensity on a phone WITH strength control', () {
    test('the level sets the strength; completion is stronger and longer',
        () async {
      for (var level = 1; level <= 5; level++) {
        settings = CompletionSettings(vibrationLevel: level);
        final s = service();
        await s.milestone();
        await s.complete();
        final milestone = haptics.calls[0];
        final done = haptics.calls[1];
        expect(milestone.amplitude, DeviceFeedbackService.amplitudeFor(level),
            reason: 'level $level');
        expect(done.intensities.where((i) => i > 0).every((i) => i >= milestone.amplitude), isTrue,
            reason: 'level $level: the target buzz is at least as strong');
        expect(done.totalMs, greaterThan(milestone.totalMs * 3));
      }
    });

    test('five levels are strictly increasing up to full strength', () {
      final amps = [for (var l = 1; l <= 5; l++) DeviceFeedbackService.amplitudeFor(l)];
      for (var i = 1; i < 5; i++) {
        expect(amps[i], greaterThan(amps[i - 1]));
      }
      expect(amps.last, 255);
    });
  });

  group('intensity on a phone WITHOUT strength control (like a Galaxy A23)', () {
    test('a level is the LENGTH of the buzz, growing with the level', () async {
      final ms = <int>[];
      for (var level = 1; level <= 5; level++) {
        settings = CompletionSettings(vibrationLevel: level);
        final s = service(amplitude: false);
        await s.milestone();
        ms.add(haptics.calls.single.totalMs);
        expect(haptics.calls.single.amplitude, -1, reason: 'no strength requested');
      }
      for (var i = 1; i < ms.length; i++) {
        expect(ms[i], greaterThan(ms[i - 1]));
      }
      expect(ms.first, greaterThanOrEqualTo(200), reason: 'long enough to notice');
      expect(ms.last, lessThanOrEqualTo(600));
    });

    test('the completion buzz is three long pulses, clearly longer than the '
        'milestone', () async {
      for (var level = 1; level <= 5; level++) {
        settings = CompletionSettings(vibrationLevel: level);
        final s = service(amplitude: false);
        await s.milestone();
        await s.complete();
        final milestone = haptics.calls[0].totalMs;
        final done = haptics.calls[1];
        expect(done.isPattern, isTrue);
        expect(done.pattern.first, 0, reason: 'starts at once');
        expect(done.pattern.length, 6, reason: 'pulse, gap, pulse, gap, pulse');
        expect(done.totalMs, greaterThan(milestone * 4), reason: 'level $level');
        expect(done.totalMs, greaterThanOrEqualTo(1200), reason: 'a felt buzz, level $level');
        expect(done.totalMs, lessThanOrEqualTo(4000), reason: 'not endless');
        expect(done.intensities, isEmpty);
      }
    });

    test('the completion pattern grows with the level but is capped', () {
      final totals = [
        for (var l = 1; l <= 5; l++)
          DeviceFeedbackService.completionPattern(l).fold<int>(0, (a, b) => a + b)
      ];
      for (var i = 1; i < totals.length; i++) {
        expect(totals[i], greaterThan(totals[i - 1]));
      }
      for (final p in DeviceFeedbackService.completionPattern(5).where((v) => v > 150)) {
        expect(p, lessThanOrEqualTo(1200));
      }
    });

    test('out-of-range levels are clamped', () {
      expect(DeviceFeedbackService.pulseMs(0), DeviceFeedbackService.pulseMs(1));
      expect(DeviceFeedbackService.pulseMs(99), DeviceFeedbackService.pulseMs(5));
    });
  });

  group('previews (Settings screen)', () {
    test('ignore the on/off switches', () async {
      settings = const CompletionSettings(vibrationEnabled: false, ringtoneEnabled: false);
      final s = service();
      await s.previewVibration(strong: false);
      await s.previewVibration(strong: true);
      await s.previewRingtone(Ringtone.deepGong);
      expect(haptics.calls.length, 2);
      expect(sound.plays, [Ringtone.deepGong.asset]);
    });
  });

  group('completion sounds play on the ALARM stream', () {
    // The reported bug: the media stream was used, and a phone with its media
    // volume down played the bell silently.
    test('the audio context is alarm usage, not media', () {
      final android = PluginSound.completionContext.android;
      expect(android.usageType, AndroidUsageType.alarm);
      expect(android.usageType, isNot(AndroidUsageType.media));
      expect(android.contentType, AndroidContentType.sonification);
      expect(android.audioFocus, AndroidAudioFocus.gainTransientMayDuck,
          reason: 'ducks other audio and lets it resume');
    });
  });
}
