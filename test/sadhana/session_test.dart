import 'dart:typed_data';

import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/sadhana/application/completion_settings_provider.dart';
import 'package:advance_calendar/features/sadhana/application/mantra_library_provider.dart';
import 'package:advance_calendar/features/sadhana/application/rhythm_pace.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/application/session_notice_provider.dart';
import 'package:advance_calendar/features/sadhana/application/voice_training_provider.dart';
import 'package:advance_calendar/features/sadhana/voice/mfcc.dart';
import 'package:advance_calendar/features/sadhana/data/ringtone.dart';
import 'package:advance_calendar/features/sadhana/services/feedback_service.dart';
import 'package:advance_calendar/features/sadhana/services/voice_counter_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

void main() {
  late FakeFeedback feedback;
  late FakeVoice voice;
  late FakeVolume volume;

  setUp(() {
    resetStorage();
    seedTrainedVoice(); // Voice only counts a trained mantra
    feedback = FakeFeedback();
    voice = FakeVoice();
    volume = FakeVolume();
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: testOverrides(feedback: feedback, voice: voice, volume: volume),
    );
    addTearDown(c.dispose);
    return c;
  }

  SadhanaState read(ProviderContainer c) => c.read(sadhanaSessionProvider);

  group('count target', () {
    test('completes exactly at target with one strong-feedback call', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)..setTargetCount(3);
      for (var i = 0; i < 5; i++) {
        n.increment(); // extra taps after completion are ignored
      }
      final s = c.read(sadhanaSessionProvider);
      expect(s.count, 3);
      expect(s.completed, isTrue);
      expect(s.progress, 1.0);
      expect(feedback.completions, 1);
      expect(feedback.milestones, 0);
    });

    test('milestone buzz every 108 counts, but not at the target', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)..setTargetCount(216);
      for (var i = 0; i < 216; i++) {
        n.increment();
      }
      expect(feedback.milestones, 1); // at 108
      expect(feedback.completions, 1); // at 216 (replaces a second milestone)
    });

    test('raising the target re-opens a finished session', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)..setTargetCount(2);
      n.increment();
      n.increment();
      expect(c.read(sadhanaSessionProvider).completed, isTrue);
      n.setTargetCount(1008);
      expect(c.read(sadhanaSessionProvider).completed, isFalse);
      n.increment();
      expect(c.read(sadhanaSessionProvider).count, 3);
    });

    test('reset clears count and completion', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)..setTargetCount(1);
      n.increment();
      n.reset();
      final s = c.read(sadhanaSessionProvider);
      expect(s.count, 0);
      expect(s.completed, isFalse);
    });

    test('selecting a mantra adopts its default count and resets', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)..increment();
      n.selectMantra('seed_mool_mantar', 11);
      final s = c.read(sadhanaSessionProvider);
      expect(s.mantraId, 'seed_mool_mantar');
      expect(s.targetCount, 11);
      expect(s.count, 0);
    });
  });

  group('manual correction (-1) and pause', () {
    test('decrement takes one off, never below zero', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..increment()
        ..increment();
      n.decrement();
      expect(read(c).count, 1);
      n
        ..decrement()
        ..decrement()
        ..decrement();
      expect(read(c).count, 0);
      expect(feedback.milestones + feedback.completions, 0,
          reason: 'a correction never buzzes');
    });

    test('decrement on a finished session re-opens it', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setTargetCount(2)
        ..increment()
        ..increment();
      expect(read(c).completed, isTrue);
      n.decrement();
      expect(read(c).completed, isFalse);
      n.increment();
      expect(read(c).completed, isTrue);
      expect(feedback.completions, 2, reason: 'reaching it again is a new finish');
    });

    test('in Separate scope it corrects only the active mode', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setCountScope(CountScope.separate)
        ..increment()
        ..increment()
        ..setMode(CountMode.rhythm)
        ..increment();
      n.decrement();
      expect(read(c).count, 0);
      n.setMode(CountMode.tap);
      expect(read(c).count, 2, reason: 'Tap untouched');
    });

    test('decrement persists', () {
      final c1 = makeContainer();
      c1.read(sadhanaSessionProvider.notifier)
        ..increment()
        ..increment()
        ..decrement();
      c1.dispose();
      expect(read(makeContainer()).count, 1);
    });

    test('pause stops a running Rhythm session and keeps the count', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.rhythm)
        ..increment()
        ..toggleRunning();
      expect(read(c).running, isTrue);
      n.pause();
      expect(read(c).running, isFalse);
      expect(read(c).count, 1);
      n.pause(); // harmless when already paused
      expect(read(c).running, isFalse);
    });

    test('pause releases the microphone', () async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await pumpEventQueue();
      expect(voice.listening, isTrue);
      n.pause();
      await pumpEventQueue();
      expect(voice.listening, isFalse);
    });
  });

  group('rhythm mode', () {
    testWidgets('auto-increments at the set pace and stops at the target',
        (tester) async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.rhythm)
        ..setRhythmSeconds(1.0)
        ..setTargetCount(3);

      await tester.pump(const Duration(seconds: 5));
      expect(read(c).count, 0, reason: 'starts paused');

      n.toggleRunning();
      await tester.pump(const Duration(milliseconds: 2500));
      expect(read(c).count, 2);

      await tester.pump(const Duration(seconds: 2));
      final s = read(c);
      expect(s.count, 3);
      expect(s.completed, isTrue);
      expect(s.running, isFalse, reason: 'rhythm stops at the target');
      expect(feedback.completions, 1);

      await tester.pump(const Duration(seconds: 5));
      expect(read(c).count, 3);
    });

    test('default pace is 2 seconds', () {
      expect(read(makeContainer()).rhythmSeconds, 2.0);
    });

    testWidgets('sub-second pace (0.2 s, the minimum)', (tester) async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.rhythm)
        ..setRhythmSeconds(0.2)
        ..setTargetCount(1000)
        ..toggleRunning();
      await tester.pump(const Duration(seconds: 1));
      expect(read(c).count, 5);
      n.toggleRunning();
    });

    testWidgets('minutes pace: 5 min', (tester) async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.rhythm)
        ..setRhythmSeconds(5 * 60)
        ..setTargetCount(1000)
        ..toggleRunning();
      await tester.pump(const Duration(minutes: 4, seconds: 59));
      expect(read(c).count, 0);
      await tester.pump(const Duration(seconds: 2));
      expect(read(c).count, 1);
      await tester.pump(const Duration(minutes: 10));
      expect(read(c).count, 3);
      n.toggleRunning();
    });

    testWidgets('hours pace: 1 hr', (tester) async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.rhythm)
        ..setRhythmSeconds(3600)
        ..setTargetCount(1000)
        ..toggleRunning();
      await tester.pump(const Duration(minutes: 59));
      expect(read(c).count, 0);
      await tester.pump(const Duration(minutes: 2));
      expect(read(c).count, 1);
      n.toggleRunning();
    });

    testWidgets('changing the pace while running takes effect immediately',
        (tester) async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.rhythm)
        ..setRhythmSeconds(60)
        ..setTargetCount(1000)
        ..toggleRunning();
      await tester.pump(const Duration(seconds: 30));
      expect(read(c).count, 0);
      n.setRhythmSeconds(1);
      await tester.pump(const Duration(seconds: 3));
      expect(read(c).count, 3);
      n.toggleRunning();
    });

    test('pace is clamped to 0.2 s .. max and ignores non-finite values', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier);
      n.setRhythmSeconds(0.01);
      expect(read(c).rhythmSeconds, minRhythmSeconds);
      n.setRhythmSeconds(1e9);
      expect(read(c).rhythmSeconds, maxRhythmSeconds);
      n.setRhythmSeconds(5);
      n.setRhythmSeconds(double.nan);
      n.setRhythmSeconds(double.infinity);
      expect(read(c).rhythmSeconds, 5);
    });
  });

  group('voice mode', () {
    Future<void> settle() => pumpEventQueue();

    test('Start listens; each spoken phrase adds one count', () async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setTargetCount(108)
        ..setMode(CountMode.voice);
      expect(voice.starts, 0, reason: 'nothing listens until Start');

      n.toggleRunning();
      await settle();
      expect(voice.listening, isTrue);
      expect(read(c).inputActive, isTrue, reason: 'drives the Listening… UI');

      voice.hear();
      voice.hear();
      voice.hear();
      expect(read(c).count, 3);
    });

    test('starts with the selected mantra\'s own trained templates', () async {
      seedTrainedVoice('seed_waheguru');
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await settle();
      final first = voice.lastModel!;
      expect(first.templates.length, 3);
      n.toggleRunning();
      n.selectMantra('seed_waheguru', 108);
      n.toggleRunning();
      await settle();
      expect(voice.starts, 2);
      expect(identical(voice.lastModel, first), isFalse,
          reason: 'a different mantra is matched against its own recordings');
      expect(read(c).running, isTrue);
    });

    test('an untrained mantra is refused with a prompt to train', () async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..selectMantra('seed_gayatri', 108) // never trained
        ..setMode(CountMode.voice);
      var everRunning = false;
      c.listen(sadhanaSessionProvider, (_, s) => everRunning |= s.running);
      n.toggleRunning();
      await settle();
      expect(everRunning, isFalse,
          reason: 'refused up front: never even flickers to "running"');
      expect(voice.starts, 0, reason: 'the microphone is never opened');
      expect(read(c).running, isFalse);
      expect(read(c).mode, CountMode.voice, reason: 'stays put, not Tap');
      final notice = c.read(sessionNoticeProvider)!;
      expect(notice.message, contains('Train your voice'));
      expect(notice.trainMantraId, 'seed_gayatri');
      n.increment(); // Tap fallback: manual counting still works
      expect(read(c).count, 1);
    });

    test('clearing the training while paused refuses the next Start',
        () async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice);
      await c
          .read(voiceTrainingProvider.notifier)
          .clear('seed_om_namah_shivaya');
      n.toggleRunning();
      await settle();
      expect(voice.starts, 0);
      expect(c.read(sessionNoticeProvider)!.trainMantraId,
          'seed_om_namah_shivaya');
    });

    test('a trained mantra with too few recordings is not usable', () async {
      AppStorage.voiceTemplates.delete('seed_om_namah_shivaya');
      final c = makeContainer();
      final only2 = [
        for (var k = 0; k < 2; k++) MfccSequence(30, mfccDims, Float64List(30 * mfccDims)),
      ];
      await c
          .read(voiceTrainingProvider.notifier)
          .save('seed_om_namah_shivaya', only2);
      c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await settle();
      expect(voice.starts, 0);
    });

    test('only matching utterances count; other sounds are ignored',
        () async {
      final c = makeContainer();
      c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await settle();
      voice.hearOther();
      voice.hearOther();
      expect(read(c).count, 0, reason: 'not the mantra');
      expect(read(c).lastVoice!.counted, isFalse);
      voice.hear();
      expect(read(c).count, 1);
      expect(read(c).lastVoice!.counted, isTrue);
      expect(read(c).lastVoice!.seq, 3, reason: 'every utterance is reported');
    });

    test('the sensitivity slider reaches a running session and the next start',
        () async {
      final c = makeContainer();
      c.read(voiceSensitivityProvider.notifier).set(0.2);
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await settle();
      expect(voice.lastSensitivity, 0.2);
      c.read(voiceSensitivityProvider.notifier).set(0.9);
      expect(voice.lastSensitivity, 0.9, reason: 'applied live, no restart');
      n.toggleRunning(); // pause
      c.read(voiceSensitivityProvider.notifier).set(0.4);
      n.toggleRunning();
      await settle();
      expect(voice.lastSensitivity, 0.4);
    });

    test('pausing stops listening and phrases are no longer counted', () async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await settle();
      voice.hear();
      n.toggleRunning();
      await settle();
      expect(voice.listening, isFalse);
      expect(read(c).inputActive, isFalse);
      voice.hear();
      expect(read(c).count, 1);
    });

    test('reaching the target stops the microphone', () async {
      final c = makeContainer();
      c.read(sadhanaSessionProvider.notifier)
        ..setTargetCount(2)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await settle();
      voice.hear();
      voice.hear();
      await settle();
      expect(read(c).completed, isTrue);
      expect(voice.listening, isFalse);
      expect(feedback.completions, 1);
    });

    test('permission denied falls back to Tap with a message', () async {
      voice.result = VoiceStartResult.denied;
      final c = makeContainer();
      c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await settle();
      final s = read(c);
      expect(s.mode, CountMode.tap);
      expect(s.running, isFalse);
      expect(s.inputActive, isFalse);
      final notice = c.read(sessionNoticeProvider)!;
      expect(notice.message, contains('Microphone permission was denied'));
      expect(notice.openSettings, isFalse);
    });

    test('permanently denied also offers Settings', () async {
      voice.result = VoiceStartResult.permanentlyDenied;
      final c = makeContainer();
      c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await settle();
      expect(read(c).mode, CountMode.tap);
      expect(c.read(sessionNoticeProvider)!.openSettings, isTrue);
    });

    test('unavailable recogniser falls back to Tap', () async {
      voice.result = VoiceStartResult.unavailable;
      final c = makeContainer();
      c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await settle();
      expect(read(c).mode, CountMode.tap);
      expect(c.read(sessionNoticeProvider)!.message,
          contains('No microphone available on this device'));
    });

    test('unsupported platform: selecting Voice stays on Tap with a message',
        () {
      voice = FakeVoice(supported: false);
      final c = makeContainer();
      c.read(sadhanaSessionProvider.notifier).setMode(CountMode.voice);
      expect(read(c).mode, CountMode.tap);
      expect(c.read(sessionNoticeProvider)!.message,
          contains('Android and iOS only'));
    });

    test('engine giving up pauses the session and explains why', () async {
      final c = makeContainer();
      c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await settle();
      voice.engineGivesUp('Speech recognition keeps failing');
      final s = read(c);
      expect(s.running, isFalse);
      expect(s.mode, CountMode.voice, reason: 'paused, so the user can retry');
      expect(c.read(sessionNoticeProvider)!.message, contains('keeps failing'));
    });

    test('pausing while the permission dialog is up cancels the start',
        () async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning(); // start() is now awaiting
      n.toggleRunning(); // user pauses before it resolves
      await settle();
      expect(voice.listening, isFalse);
      expect(read(c).inputActive, isFalse);
    });
  });

  group('mala mode (volume buttons)', () {
    Future<void> settle() => pumpEventQueue();

    test('Start captures the keys; each press adds one count', () async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.mala);
      volume.press();
      expect(read(c).count, 0, reason: 'keys are untouched until Start');

      n.toggleRunning();
      await settle();
      expect(volume.capturing, isTrue);
      expect(read(c).inputActive, isTrue);

      volume.press();
      volume.press();
      expect(read(c).count, 2);
    });

    test('pausing releases the volume keys back to the system', () async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.mala)
        ..toggleRunning();
      await settle();
      volume.press();
      n.toggleRunning();
      await settle();
      expect(volume.capturing, isFalse);
      volume.press();
      expect(read(c).count, 1);
    });

    test('switching mode releases the keys', () async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.mala)
        ..toggleRunning();
      await settle();
      n.setMode(CountMode.tap);
      await settle();
      expect(volume.capturing, isFalse);
    });

    test('target reached: milestone/complete feedback and keys released',
        () async {
      final c = makeContainer();
      c.read(sadhanaSessionProvider.notifier)
        ..setTargetCount(2)
        ..setMode(CountMode.mala)
        ..toggleRunning();
      await settle();
      volume.press();
      volume.press();
      await settle();
      expect(read(c).completed, isTrue);
      expect(volume.capturing, isFalse);
      expect(feedback.completions, 1);
    });

    test('unsupported platform: selecting Mala stays on Tap with a message',
        () {
      volume = FakeVolume(supported: false);
      final c = makeContainer();
      c.read(sadhanaSessionProvider.notifier).setMode(CountMode.mala);
      expect(read(c).mode, CountMode.tap);
      expect(c.read(sessionNoticeProvider)!.message, contains('needs a physical device'));
    });

    test('capture failure falls back to Tap with a message', () async {
      volume = FakeVolume(startOk: false);
      final c = makeContainer();
      c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.mala)
        ..toggleRunning();
      await settle();
      expect(read(c).mode, CountMode.tap);
      expect(read(c).running, isFalse);
      expect(c.read(sessionNoticeProvider)!.message,
          contains('Volume-key counting needs a physical device'));
    });
  });

  group('time target', () {
    testWidgets('clock runs from first tap and completes at duration',
        (tester) async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setTargetType(TargetType.time)
        ..setTargetSeconds(3);

      await tester.pump(const Duration(seconds: 2));
      expect(c.read(sadhanaSessionProvider).elapsedSeconds, 0);

      n.increment(); // first tap starts the clock (tap mode)
      expect(c.read(sadhanaSessionProvider).running, isTrue);

      await tester.pump(const Duration(seconds: 3));
      final s = c.read(sadhanaSessionProvider);
      expect(s.elapsedSeconds, 3);
      expect(s.completed, isTrue);
      expect(s.remainingSeconds, 0);
      expect(feedback.completions, 1);
    });

    testWidgets('pausing stops the clock', (tester) async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setTargetType(TargetType.time)
        ..setTargetSeconds(60)
        ..toggleRunning();
      await tester.pump(const Duration(seconds: 2));
      n.toggleRunning();
      await tester.pump(const Duration(seconds: 5));
      expect(c.read(sadhanaSessionProvider).elapsedSeconds, 2);
    });
  });

  test('session persists across restarts, always reopening paused', () {
    final c1 = makeContainer();
    c1.read(sadhanaSessionProvider.notifier)
      ..setSankalp('Peace for all')
      ..setMode(CountMode.rhythm)
      ..setRhythmSeconds(90 * 60) // 1 hr 30 min
      ..setTargetCount(1008)
      ..increment()
      ..increment()
      ..toggleRunning();
    c1.dispose();

    final c2 = makeContainer();
    final s = c2.read(sadhanaSessionProvider);
    expect(s.sankalp, 'Peace for all');
    expect(s.targetCount, 1008);
    expect(s.count, 2);
    expect(s.running, isFalse);
    expect(s.mode, CountMode.rhythm);
    expect(s.rhythmSeconds, 5400, reason: 'custom pace survives a relaunch');
    expect(s.inputActive, isFalse);
  });

  group('count scope: Combined (default)', () {
    Future<void> settle() => pumpEventQueue();

    test('defaults to Combined with nothing counted', () {
      final s = read(makeContainer());
      expect(s.scope, CountScope.combined);
      expect(s.isSeparate, isFalse);
      expect(s.perMode, isEmpty);
      expect(s.count, 0);
    });

    test('Tap, Rhythm, Voice and Mala all add to ONE shared count', () async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)..setTargetCount(6);
      n.increment(); // Tap
      n.increment();

      n.setMode(CountMode.voice);
      n.toggleRunning();
      await settle();
      voice.hear(); // Voice
      expect(read(c).count, 3);

      n.setMode(CountMode.mala);
      n.toggleRunning();
      await settle();
      volume.press(); // Mala
      volume.press();
      expect(read(c).count, 5, reason: 'switching mode keeps the shared count');

      n.setMode(CountMode.rhythm);
      n.increment(); // manual + in Rhythm mode
      final s = read(c);
      expect(s.count, 6);
      expect(s.completed, isTrue, reason: 'one target for every mode');
      expect(feedback.completions, 1);
    });

    test('Reset zeroes the shared count whichever mode is active', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..increment()
        ..increment()
        ..setMode(CountMode.rhythm);
      n.reset();
      expect(read(c).count, 0);
      n.setMode(CountMode.tap);
      expect(read(c).count, 0);
    });
  });

  group('count scope: Separate', () {
    Future<void> settle() => pumpEventQueue();

    SadhanaSessionNotifier separate(ProviderContainer c) =>
        c.read(sadhanaSessionProvider.notifier)..setCountScope(CountScope.separate);

    test('each mode keeps its own count; switching shows that mode\'s count',
        () async {
      final c = makeContainer();
      final n = separate(c)..setTargetCount(100);
      n
        ..increment()
        ..increment()
        ..increment();
      expect(read(c).count, 3);

      n.setMode(CountMode.voice);
      expect(read(c).count, 0, reason: 'Voice has not counted anything yet');
      n.toggleRunning();
      await settle();
      voice.hear();
      voice.hear();
      expect(read(c).count, 2);

      n.setMode(CountMode.mala);
      expect(read(c).count, 0);
      n.toggleRunning();
      await settle();
      volume.press();
      expect(read(c).count, 1);

      n.setMode(CountMode.tap);
      expect(read(c).count, 3, reason: 'Tap is exactly as it was left');
      n.setMode(CountMode.voice);
      expect(read(c).count, 2);
      expect(read(c).perMode[CountMode.mala]!.count, 1);
    });

    test('manual +/taps add to the active mode only', () {
      final c = makeContainer();
      final n = separate(c)..setMode(CountMode.rhythm);
      n.increment();
      n.increment();
      expect(read(c).count, 2);
      n.setMode(CountMode.tap);
      expect(read(c).count, 0, reason: 'nothing leaked into Tap');
    });

    test('completion applies only to the active mode', () {
      final c = makeContainer();
      final n = separate(c)..setTargetCount(3);
      n
        ..increment()
        ..increment()
        ..increment()
        ..increment(); // ignored: Tap is already complete
      var s = read(c);
      expect(s.count, 3);
      expect(s.completed, isTrue);
      expect(s.progress, 1.0);
      expect(feedback.completions, 1);

      n.setMode(CountMode.rhythm);
      s = read(c);
      expect(s.completed, isFalse, reason: 'Rhythm is its own fresh session');
      expect(s.progress, 0.0);
      n.increment();
      expect(read(c).count, 1);

      n.setMode(CountMode.tap);
      expect(read(c).completed, isTrue, reason: 'Tap stays complete');
      expect(read(c).count, 3);
    });

    test('a completed mode can be reset without touching the others', () {
      final c = makeContainer();
      final n = separate(c)..setTargetCount(2);
      n
        ..increment()
        ..increment()
        ..setMode(CountMode.rhythm)
        ..increment();
      n.setMode(CountMode.tap);
      n.reset();
      var s = read(c);
      expect(s.count, 0);
      expect(s.completed, isFalse);
      n.increment();
      expect(read(c).count, 1, reason: 'counting works again after reset');

      n.setMode(CountMode.rhythm);
      expect(read(c).count, 1, reason: 'Rhythm untouched by Tap\'s reset');
      n.reset();
      n.setMode(CountMode.tap);
      s = read(c);
      expect(s.count, 1, reason: 'and vice versa');
    });

    test('raising the target re-opens only the modes that are now short of it',
        () {
      final c = makeContainer();
      final n = separate(c)..setTargetCount(2);
      n
        ..increment()
        ..increment()
        ..setMode(CountMode.rhythm)
        ..increment()
        ..increment();
      expect(read(c).completed, isTrue);
      n.setTargetCount(5);
      expect(read(c).completed, isFalse);
      n.setMode(CountMode.tap);
      expect(read(c).completed, isFalse);
      expect(read(c).count, 2);
    });

    test('milestone buzz follows the active mode\'s own count', () {
      final c = makeContainer();
      final n = separate(c)..setTargetCount(500);
      for (var i = 0; i < 100; i++) {
        n.increment();
      }
      n.setMode(CountMode.rhythm);
      for (var i = 0; i < 100; i++) {
        n.increment();
      }
      expect(feedback.milestones, 0,
          reason: '100 + 100 across two modes is not 108 in either');
      for (var i = 0; i < 8; i++) {
        n.increment();
      }
      expect(feedback.milestones, 1);
    });

    testWidgets('each mode has its own Start/Pause state; rhythm never counts '
        'in the background', (tester) async {
      final c = makeContainer();
      final n = separate(c)
        ..setRhythmSeconds(1)
        ..setTargetCount(100)
        ..setMode(CountMode.rhythm);
      n.toggleRunning();
      await tester.pump(const Duration(milliseconds: 2500));
      expect(read(c).count, 2);
      expect(read(c).running, isTrue);

      n.setMode(CountMode.tap);
      expect(read(c).running, isFalse, reason: 'Tap opens on its own state');
      expect(read(c).count, 0);
      await tester.pump(const Duration(seconds: 5));
      n.setMode(CountMode.rhythm);
      final s = read(c);
      expect(s.count, 2, reason: 'paused while away; nothing counted for it');
      expect(s.running, isFalse, reason: 'shows Resume, not silently running');
      expect(s.activeProgress.count, 2);

      n.toggleRunning();
      await tester.pump(const Duration(seconds: 1));
      expect(read(c).count, 3, reason: 'Resume continues from its own count');
      n.toggleRunning();
    });

    test('switching mode releases the mic/keys and does not carry the count',
        () async {
      final c = makeContainer();
      final n = separate(c)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await settle();
      voice.hear();
      expect(voice.listening, isTrue);
      n.setMode(CountMode.mala);
      await settle();
      expect(voice.listening, isFalse);
      expect(read(c).count, 0);
      voice.hear();
      expect(read(c).perMode[CountMode.voice]!.count, 1,
          reason: 'a stale phrase after leaving Voice is not counted');
    });

    test('Voice unavailable falls back to Tap and Voice keeps its count',
        () async {
      final c = makeContainer();
      final n = separate(c)..setMode(CountMode.voice);
      n.increment(); // 1 manual count in Voice
      voice.result = VoiceStartResult.unavailable;
      n.toggleRunning();
      await settle();
      expect(read(c).mode, CountMode.tap);
      expect(read(c).count, 0, reason: 'Tap\'s own count');
      expect(read(c).perMode[CountMode.voice]!.count, 1);
      expect(c.read(sessionNoticeProvider)!.message,
          contains('No microphone available on this device'));
    });

    testWidgets('time target: each mode has its own clock', (tester) async {
      final c = makeContainer();
      final n = separate(c)
        ..setTargetType(TargetType.time)
        ..setTargetSeconds(5);
      n.increment(); // first Tap starts Tap's clock
      await tester.pump(const Duration(seconds: 2));
      expect(read(c).elapsedSeconds, 2);

      n.setMode(CountMode.rhythm);
      expect(read(c).elapsedSeconds, 0, reason: 'Rhythm has its own clock');
      expect(read(c).running, isFalse);
      await tester.pump(const Duration(seconds: 10));
      expect(read(c).elapsedSeconds, 0, reason: 'Tap\'s clock is not running');

      n.setMode(CountMode.tap);
      expect(read(c).elapsedSeconds, 2);
      expect(read(c).completed, isFalse);
      n.toggleRunning();
      await tester.pump(const Duration(seconds: 3));
      expect(read(c).completed, isTrue);
      expect(feedback.completions, 1);
      n.setMode(CountMode.rhythm);
      expect(read(c).completed, isFalse, reason: 'Rhythm did not complete');
    });

    test('choosing another mantra starts fresh in every mode', () {
      final c = makeContainer();
      final n = separate(c)..increment();
      n.setMode(CountMode.rhythm);
      n.increment();
      n.selectMantra('seed_mool_mantar', 11);
      expect(read(c).scope, CountScope.separate, reason: 'the choice is kept');
      expect(read(c).perMode, isEmpty);
      n.setMode(CountMode.tap);
      expect(read(c).count, 0);
    });
  });

  group('a screen tap counts only in Tap mode', () {
    Future<void> settle() => pumpEventQueue();

    test('in Tap mode a tap counts', () {
      final c = makeContainer();
      c.read(sadhanaSessionProvider.notifier)
        ..tap()
        ..tap();
      expect(read(c).count, 2);
    });

    test('in Voice, Rhythm and Mala a tap adds nothing', () async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier);
      for (final mode in [CountMode.voice, CountMode.rhythm, CountMode.mala]) {
        n.setMode(mode);
        n
          ..tap()
          ..tap()
          ..tap();
        expect(read(c).count, 0, reason: 'a tap in ${mode.name} mode');
      }
    });

    test('nor while Voice / Mala are actually listening', () async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await settle();
      n.tap();
      expect(read(c).count, 0);
      voice.hear();
      expect(read(c).count, 1, reason: 'only the voice match counts');
      n
        ..setMode(CountMode.mala)
        ..toggleRunning();
      await settle();
      n.tap();
      expect(read(c).count, 1);
      volume.press();
      expect(read(c).count, 2, reason: 'only the volume key counts');
    });

    testWidgets('nor while Rhythm runs: only its own timer counts',
        (tester) async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.rhythm)
        ..setRhythmSeconds(1)
        ..setTargetCount(100)
        ..toggleRunning();
      n.tap();
      n.tap();
      expect(read(c).count, 0);
      await tester.pump(const Duration(milliseconds: 2500));
      expect(read(c).count, 2, reason: 'the timer counted; the taps did not');
      n.toggleRunning();
    });

    test('the + and - buttons still work in every mode', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier);
      for (final mode in CountMode.values) {
        n.setMode(mode);
        n.increment(); // the + button
      }
      expect(read(c).count, 4, reason: 'one manual count in each mode');
      n.decrement(); // the - button
      expect(read(c).count, 3);
    });

    test('time target: a tap starts the clock only in Tap mode', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setTargetType(TargetType.time)
        ..setMode(CountMode.rhythm)
        ..tap();
      expect(read(c).running, isFalse);
      n.setMode(CountMode.tap);
      n.tap();
      expect(read(c).running, isTrue, reason: 'first Tap-mode tap starts it');
      n.toggleRunning();
    });

    test('a finished target ignores taps too', () {
      final c = makeContainer();
      c.read(sadhanaSessionProvider.notifier)
        ..setTargetCount(2)
        ..tap()
        ..tap()
        ..tap();
      expect(read(c).count, 2);
    });
  });

  group('Combined is the SUM, Separate is per mode (lossless switching)', () {
    Future<void> settle() => pumpEventQueue();

    /// Tap 3, Rhythm 2, Mala 1 counted, through each mode's own route.
    Future<SadhanaSessionNotifier> countedInThreeModes(ProviderContainer c) async {
      final n = c.read(sadhanaSessionProvider.notifier)..setTargetCount(100);
      n
        ..tap()
        ..tap()
        ..tap()
        ..setMode(CountMode.rhythm)
        ..increment()
        ..increment()
        ..setMode(CountMode.mala)
        ..toggleRunning();
      await settle();
      volume.press();
      n.toggleRunning();
      return n;
    }

    test('Combined: every mode adds to ONE shared count and ONE target',
        () async {
      final c = makeContainer();
      final n = await countedInThreeModes(c);
      expect(read(c).scope, CountScope.combined);
      expect(read(c).count, 6, reason: '3 + 2 + 1');
      for (final mode in CountMode.values) {
        n.setMode(mode);
        expect(read(c).count, 6, reason: 'the same total in ${mode.name}');
        expect(read(c).progress, closeTo(6 / 100, 1e-9));
      }
    });

    test('Combined: the shared target is reached by all modes together',
        () async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)..setTargetCount(4);
      n
        ..tap()
        ..tap()
        ..setMode(CountMode.rhythm)
        ..increment();
      expect(read(c).completed, isFalse);
      n
        ..setMode(CountMode.voice)
        ..increment(); // the 4th, from a different mode
      expect(read(c).completed, isTrue);
      expect(feedback.completions, 1);
      n.setMode(CountMode.tap);
      expect(read(c).completed, isTrue, reason: 'finished for every mode');
      n.tap();
      expect(read(c).count, 4, reason: 'and nothing more is counted');
    });

    test('Separate: each mode shows and keeps its OWN count', () async {
      final c = makeContainer();
      final n = await countedInThreeModes(c);
      n.setCountScope(CountScope.separate);
      n.setMode(CountMode.tap);
      expect(read(c).count, 3);
      n.setMode(CountMode.rhythm);
      expect(read(c).count, 2);
      n.setMode(CountMode.mala);
      expect(read(c).count, 1);
      n.setMode(CountMode.voice);
      expect(read(c).count, 0, reason: 'never used');
      n
        ..increment()
        ..increment()
        ..increment()
        ..increment();
      n.setMode(CountMode.tap);
      expect(read(c).count, 3, reason: 'Voice\'s counts did not leak into Tap');
    });

    test('Separate: progress and completion are per mode', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setCountScope(CountScope.separate)
        ..setTargetCount(4)
        ..tap()
        ..tap()
        ..tap()
        ..tap();
      expect(read(c).completed, isTrue);
      expect(read(c).progress, 1.0);
      n.setMode(CountMode.rhythm);
      expect(read(c).completed, isFalse);
      expect(read(c).progress, 0.0, reason: 'Rhythm has its own progress');
      n.increment();
      expect(read(c).progress, closeTo(0.25, 1e-9));
    });

    test('Separate: Reset clears only the active mode', () async {
      final c = makeContainer();
      final n = await countedInThreeModes(c);
      n.setCountScope(CountScope.separate);
      n.setMode(CountMode.rhythm);
      n.reset();
      expect(read(c).count, 0);
      n.setMode(CountMode.tap);
      expect(read(c).count, 3);
      n.setMode(CountMode.mala);
      expect(read(c).count, 1);
    });

    test('Combined: Reset clears every mode', () async {
      final c = makeContainer();
      final n = await countedInThreeModes(c);
      n.reset();
      expect(read(c).count, 0);
      n.setCountScope(CountScope.separate);
      for (final mode in CountMode.values) {
        n.setMode(mode);
        expect(read(c).count, 0, reason: '${mode.name} was cleared too');
      }
    });

    test('switching scope loses NOTHING, and switching back restores it',
        () async {
      final c = makeContainer();
      final n = await countedInThreeModes(c);
      Map<String, int> all() => {
            for (final m in CountMode.values) m.name: read(c).progressOf(m).count,
          };
      final before = all();
      expect(before, {'tap': 3, 'rhythm': 2, 'voice': 0, 'mala': 1});

      for (var i = 0; i < 3; i++) {
        n.setCountScope(CountScope.separate);
        expect(all(), before, reason: 'Separate keeps every bucket');
        n.setCountScope(CountScope.combined);
        expect(all(), before, reason: 'and so does Combined');
        expect(read(c).count, 6);
      }
    });

    test('the view follows the scope: sum vs own', () async {
      final c = makeContainer();
      final n = await countedInThreeModes(c);
      n.setMode(CountMode.rhythm);
      expect(read(c).count, 6);
      n.setCountScope(CountScope.separate);
      expect(read(c).count, 2, reason: 'Rhythm\'s own');
      n.setCountScope(CountScope.combined);
      expect(read(c).count, 6);
    });

    test('a mode keeps counting into its own bucket in either scope', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.mala)
        ..increment()
        ..setCountScope(CountScope.separate)
        ..increment();
      expect(read(c).count, 2, reason: 'Mala\'s own count');
      n.setCountScope(CountScope.combined);
      n.setMode(CountMode.tap);
      n.tap();
      expect(read(c).count, 3, reason: 'sum of Mala 2 + Tap 1');
    });

    test('Combined -> Separate on a fresh session: the count is the active '
        'mode\'s, the others start at 0', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..tap()
        ..tap()
        ..tap()
        ..setCountScope(CountScope.separate);
      expect(read(c).count, 3, reason: 'the number on screen is unchanged');
      n.setMode(CountMode.mala);
      expect(read(c).count, 0);
    });

    test('a target reached only in the sum stops Combined, not Separate',
        () async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setCountScope(CountScope.separate)
        ..setTargetCount(3)
        ..tap()
        ..tap()
        ..setMode(CountMode.rhythm)
        ..increment()
        ..increment();
      expect(read(c).completed, isFalse, reason: 'each mode is at 2 of 3');
      n.setCountScope(CountScope.combined);
      expect(read(c).count, 4);
      expect(read(c).completed, isTrue, reason: '4 of 3 together');
      n.setCountScope(CountScope.separate);
      expect(read(c).completed, isFalse, reason: 'and back to 2 of 3');
    });

    test('a running session stops if the new view is already finished',
        () async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setCountScope(CountScope.separate)
        ..setTargetCount(3)
        ..tap()
        ..tap()
        ..setMode(CountMode.voice)
        ..increment()
        ..increment()
        ..toggleRunning();
      await settle();
      expect(voice.listening, isTrue);
      n.setCountScope(CountScope.combined); // 4 of 3 together
      await settle();
      expect(read(c).completed, isTrue);
      expect(read(c).running, isFalse);
      expect(voice.listening, isFalse, reason: 'the microphone is released');
    });

    test('the running state survives a switch that changes nothing', () async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setTargetCount(50)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await settle();
      n.setCountScope(CountScope.separate);
      expect(read(c).running, isTrue);
      expect(voice.listening, isTrue);
    });

    test('switching mode pauses; each mode has its own Start/Resume state',
        () async {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setCountScope(CountScope.separate)
        ..setMode(CountMode.rhythm)
        ..increment()
        ..toggleRunning();
      expect(read(c).running, isTrue);
      n.setMode(CountMode.mala);
      expect(read(c).running, isFalse);
      expect(read(c).activeProgress.count, 0, reason: 'a fresh mode: "Start"');
      n.setMode(CountMode.rhythm);
      expect(read(c).running, isFalse);
      expect(read(c).activeProgress.count, 1, reason: 'its own: "Resume"');
    });

    test('Combined decrement takes one off the total, from whichever mode '
        'has it', () async {
      final c = makeContainer();
      final n = await countedInThreeModes(c); // tap 3, rhythm 2, mala 1
      n.setMode(CountMode.voice); // holds nothing itself
      n.decrement();
      expect(read(c).count, 5);
      expect(read(c).progressOf(CountMode.tap).count, 2,
          reason: 'taken from the mode with the most');
      n.setMode(CountMode.mala);
      n.decrement();
      expect(read(c).progressOf(CountMode.mala).count, 0,
          reason: 'the active mode gives up its own first');
      expect(read(c).count, 4);
    });

    test('Combined decrement stops at zero', () {
      final c = makeContainer();
      c.read(sadhanaSessionProvider.notifier)
        ..increment()
        ..decrement()
        ..decrement()
        ..decrement();
      expect(read(c).count, 0);
      expect(read(c).perMode.values.every((p) => p.count >= 0), isTrue);
    });

    test('Separate decrement never borrows from another mode', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..tap()
        ..tap()
        ..setCountScope(CountScope.separate)
        ..setMode(CountMode.voice)
        ..decrement();
      expect(read(c).count, 0);
      n.setMode(CountMode.tap);
      expect(read(c).count, 2, reason: 'Tap keeps its two');
    });

    test('time target: Combined adds every mode\'s clock, Separate is per mode',
        () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setTargetType(TargetType.time)
        ..setTargetSeconds(600);
      final s0 = read(c);
      c.read(sadhanaSessionProvider.notifier).state = s0
          .withProgress(const ModeProgress(count: 4, elapsedSeconds: 30))
          .copyWith(mode: CountMode.rhythm)
          .withProgress(const ModeProgress(count: 1, elapsedSeconds: 12));
      expect(read(c).elapsedSeconds, 42, reason: 'Combined: 30 + 12');
      expect(read(c).count, 5);
      n.setCountScope(CountScope.separate);
      expect(read(c).elapsedSeconds, 12, reason: 'Rhythm\'s own clock');
      n.setMode(CountMode.tap);
      expect(read(c).elapsedSeconds, 30);
    });
  });

  group('count scope persistence (Hive)', () {
    test('Combined and every mode\'s count survive a restart', () async {
      final c1 = makeContainer();
      c1.read(sadhanaSessionProvider.notifier)
        ..tap()
        ..tap()
        ..setMode(CountMode.rhythm)
        ..increment();
      c1.dispose();
      final s = read(makeContainer());
      expect(s.scope, CountScope.combined);
      expect(s.count, 3, reason: '2 + 1');
      expect(s.mode, CountMode.rhythm);
      expect(s.progressOf(CountMode.tap).count, 2);
      expect(s.progressOf(CountMode.rhythm).count, 1);
    });

    test('Separate and each mode\'s own count survive a restart', () {
      final c1 = makeContainer();
      c1.read(sadhanaSessionProvider.notifier)
        ..setCountScope(CountScope.separate)
        ..setTargetCount(50)
        ..tap()
        ..tap()
        ..setMode(CountMode.rhythm)
        ..increment()
        ..setMode(CountMode.mala)
        ..increment()
        ..increment()
        ..increment()
        ..setMode(CountMode.rhythm);
      c1.dispose();

      final c2 = makeContainer();
      var s = read(c2);
      expect(s.scope, CountScope.separate);
      expect(s.mode, CountMode.rhythm);
      expect(s.count, 1, reason: 'reopens on the active mode\'s own count');
      expect(s.running, isFalse);
      final n = c2.read(sadhanaSessionProvider.notifier);
      n.setMode(CountMode.tap);
      expect(read(c2).count, 2);
      n.setMode(CountMode.mala);
      expect(read(c2).count, 3);
      n.setMode(CountMode.voice);
      expect(read(c2).count, 0);
      n.setCountScope(CountScope.combined);
      s = read(c2);
      expect(s.count, 6, reason: 'and the sum is intact after the restart');
    });

    test('the choice itself is persisted in Hive', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier);
      n.setCountScope(CountScope.separate);
      var saved = AppStorage.settings.get('sadhana.session') as Map;
      expect(saved['countScope'], 'separate');
      n.setCountScope(CountScope.combined);
      saved = AppStorage.settings.get('sadhana.session') as Map;
      expect(saved['countScope'], 'combined');
      n.setCountScope(CountScope.separate);
      expect(read(makeContainer()).scope, CountScope.separate);
    });

    test('the stored map holds one entry per mode that has counted', () {
      final c = makeContainer();
      c.read(sadhanaSessionProvider.notifier)
        ..tap()
        ..setMode(CountMode.mala)
        ..increment()
        ..increment();
      final saved = AppStorage.settings.get('sadhana.session') as Map;
      final per = saved['modeProgress'] as Map;
      expect(per.keys.toSet(), {'tap', 'mala'}, reason: 'idle modes are omitted');
      expect((per['mala'] as Map)['count'], 2);
      expect((per['tap'] as Map)['count'], 1);
    });

    test('a session saved before per-mode counts (one shared count) loads',
        () {
      AppStorage.settings.put('sadhana.session', {
        'mantraId': 'seed_waheguru',
        'mode': 'rhythm',
        'count': 41,
        'elapsedSeconds': 7,
        'completed': false,
      });
      final s = read(makeContainer());
      expect(s.scope, CountScope.combined);
      expect(s.count, 41);
      expect(s.elapsedSeconds, 7);
      expect(s.mode, CountMode.rhythm);
      expect(s.progressOf(CountMode.rhythm).count, 41,
          reason: 'it belongs to the mode that was active');
    });

    test('the previous format (combined count + an empty per-mode map) loads',
        () {
      AppStorage.settings.put('sadhana.session', {
        'countScope': 'combined',
        'mode': 'tap',
        'count': 12,
        'modeProgress': <String, dynamic>{},
      });
      final s = read(makeContainer());
      expect(s.count, 12);
      // ... and it keeps working from there.
      final c = makeContainer();
      c.read(sadhanaSessionProvider.notifier).tap();
      expect(read(c).count, 13);
    });

    test('the previous Separate format loads unchanged', () {
      AppStorage.settings.put('sadhana.session', {
        'countScope': 'separate',
        'mode': 'voice',
        'count': 0,
        'modeProgress': {
          'voice': {'count': 5, 'elapsedSeconds': 0},
          'tap': {'count': 2, 'elapsedSeconds': 0},
        },
      });
      final s = read(makeContainer());
      expect(s.scope, CountScope.separate);
      expect(s.count, 5);
      expect(s.progressOf(CountMode.tap).count, 2);
    });

    test('a damaged saved map cannot go negative or invent counts', () {
      AppStorage.settings.put('sadhana.session', {
        'countScope': 'separate',
        'mode': 'voice',
        'count': 77,
        'modeProgress': {
          'voice': {'count': -4, 'elapsedSeconds': 'x'},
          'tap': 'nonsense',
          'mala': {'count': 3},
        },
      });
      final s = read(makeContainer());
      expect(s.scope, CountScope.separate);
      expect(s.count, 0, reason: 'Voice: -4 clamps to 0');
      expect(s.elapsedSeconds, 0);
      expect(s.progressOf(CountMode.tap).count, 0);
      expect(s.progressOf(CountMode.mala).count, 3);
      expect(s.perMode.keys, containsAll([CountMode.voice, CountMode.mala]));
    });

    test('an unknown saved scope falls back to Combined', () {
      AppStorage.settings.put('sadhana.session', {'countScope': 'weird'});
      expect(read(makeContainer()).scope, CountScope.combined);
    });

    test('choosing another mantra clears every mode, in either scope', () {
      final c = makeContainer();
      final n = c.read(sadhanaSessionProvider.notifier)
        ..tap()
        ..setMode(CountMode.rhythm)
        ..increment()
        ..setCountScope(CountScope.separate);
      n.selectMantra('seed_mool_mantar', 11);
      expect(read(c).scope, CountScope.separate, reason: 'the choice is kept');
      expect(read(c).perMode, isEmpty);
      n.setMode(CountMode.tap);
      expect(read(c).count, 0);
    });
  });

  group('completion settings', () {
    test('vibration and ringtone switches are independent and persisted', () {
      final c = makeContainer();
      final n = c.read(completionSettingsProvider.notifier);

      n.setVibrationEnabled(false);
      var s = c.read(completionSettingsProvider);
      expect(s.vibrationEnabled, isFalse);
      expect(s.ringtoneEnabled, isTrue);

      n
        ..setVibrationEnabled(true)
        ..setRingtoneEnabled(false)
        ..setVibrationLevel(9) // clamped to 5
        ..setRingtone(Ringtone.deepGong);
      s = c.read(completionSettingsProvider);
      expect(s.vibrationEnabled, isTrue);
      expect(s.ringtoneEnabled, isFalse);
      expect(s.vibrationLevel, 5);

      final reloaded = ProviderContainer();
      addTearDown(reloaded.dispose);
      final r = reloaded.read(completionSettingsProvider);
      expect(r.ringtoneEnabled, isFalse);
      expect(r.ringtone, Ringtone.deepGong);
    });

    test('amplitude levels are five strictly increasing steps up to 255', () {
      final amps = [for (var l = 1; l <= 5; l++) DeviceFeedbackService.amplitudeFor(l)];
      expect(amps.length, 5);
      expect(amps.last, 255);
      for (var i = 1; i < amps.length; i++) {
        expect(amps[i], greaterThan(amps[i - 1]));
      }
    });
  });

  group('library', () {
    test('seeds four mantras with the specified defaults', () {
      final c = makeContainer();
      final lib = c.read(mantraLibraryProvider);
      expect(lib.map((m) => m.title), [
        'Om Namah Shivaya',
        'Gayatri Mantra',
        'Waheguru',
        'Mool Mantar',
      ]);
      expect(lib.map((m) => m.defaultCount), [108, 108, 108, 11]);
    });

    test('custom entries persist, search matches, and can be removed', () async {
      final c = makeContainer();
      final added = await c.read(mantraLibraryProvider.notifier).add(
            title: 'Hanuman Chalisa',
            script: 'श्री हनुमान चालीसा',
            transliteration: 'Shri Hanuman Chalisa',
            tradition: 'Awadhi · Hindu',
            defaultCount: 40,
          );
      expect(c.read(mantraLibraryProvider).length, 5);

      final again = ProviderContainer();
      addTearDown(again.dispose);
      final lib = again.read(mantraLibraryProvider);
      final loaded = lib.last;
      expect(loaded.id, added.id);
      expect(loaded.isCustom, isTrue);
      expect(loaded.defaultCount, 40);

      expect(lib.where((m) => m.matches('chalisa')).length, 1);
      expect(lib.where((m) => m.matches('sikh')).length, 2);
      expect(lib.where((m) => m.matches('ਵਾਹਿਗੁਰੂ')).length, 1);

      await c.read(mantraLibraryProvider.notifier).remove(added.id);
      expect(c.read(mantraLibraryProvider).length, 4);
    });
  });
}
