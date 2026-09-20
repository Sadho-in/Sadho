import 'dart:typed_data';

import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/sadhana/application/mantra_library_provider.dart';
import 'package:advance_calendar/features/sadhana/application/voice_training_provider.dart';
import 'package:advance_calendar/features/sadhana/services/voice_counter_service.dart';
import 'package:advance_calendar/features/sadhana/voice/dtw.dart';
import 'package:advance_calendar/features/sadhana/voice/match_model.dart';
import 'package:advance_calendar/features/sadhana/voice/mfcc.dart';
import 'package:advance_calendar/features/sadhana/voice/voice_trainer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'synth.dart';
import 'test_support.dart';

void main() {
  // The voice service watches the app lifecycle, as it does in the real app.
  TestWidgetsFlutterBinding.ensureInitialized();
  final extractor = MfccExtractor();

  MfccSequence mfccOf(List<Syllable> s,
          {int seed = 1, double tempo = 1, double f0 = 140}) =>
      extractor.extract(concat([
        silence(100),
        synthMantra(s, seed: seed, tempo: tempo, f0: f0),
        silence(100),
      ]));

  setUp(resetStorage);

  ProviderContainer makeContainer() {
    final c = ProviderContainer(overrides: testOverrides());
    addTearDown(c.dispose);
    return c;
  }

  group('training store (Hive)', () {
    test('save -> load: templates come back intact', () async {
      final c = makeContainer();
      final templates = [
        for (var k = 1; k <= 4; k++) mfccOf(mantraA, seed: k, tempo: 0.9 + k * 0.05),
      ];
      final saved = await c
          .read(voiceTrainingProvider.notifier)
          .save('seed_waheguru', templates);
      expect(saved.sampleCount, 4);
      expect(saved.isUsable, isTrue);
      expect(c.read(mantraTrainedProvider('seed_waheguru')), isTrue);

      final again = makeContainer(); // a relaunch
      final loaded = again.read(voiceTrainingProvider)['seed_waheguru']!;
      expect(loaded.sampleCount, 4);
      expect(loaded.mantraId, 'seed_waheguru');
      for (var i = 0; i < 4; i++) {
        expect(loaded.templates[i].frames, templates[i].frames);
        expect(dtwDistance(loaded.templates[i], templates[i]), lessThan(1e-4),
            reason: 'float32 storage is lossless enough');
      }
      expect(loaded.trainedAt.difference(saved.trainedAt).inSeconds, 0);
      expect(again.read(mantraTrainedProvider('seed_waheguru')), isTrue);
      expect(again.read(mantraTrainedProvider('seed_gayatri')), isFalse);
    });

    test('stores feature numbers only, never audio', () async {
      final c = makeContainer();
      await c
          .read(voiceTrainingProvider.notifier)
          .save('seed_waheguru', [mfccOf(mantraA), mfccOf(mantraA, seed: 2), mfccOf(mantraA, seed: 3)]);
      final raw = AppStorage.voiceTemplates.get('seed_waheguru') as Map;
      final templates = raw['templates'] as List;
      expect(templates.length, 3);
      for (final t in templates) {
        expect(t, isA<Uint8List>());
        // 13 float32 per 10 ms frame: ~5 KB/s. Raw 16-bit audio is 32 KB/s.
        final seq = mfccOf(mantraA);
        expect((t as Uint8List).length, lessThan(seq.frames * 13 * 4 + 1));
        expect(t.length, lessThan(seq.frames * 160 * 2 ~/ 6),
            reason: 'a small fraction of the size of the audio it came from');
      }
      expect(raw.keys.toSet(),
          {'mantraId', 'v', 'dims', 'trainedAt', 'templates'},
          reason: 'nothing else, in particular no samples');
    });

    test('re-training replaces the previous templates', () async {
      final c = makeContainer();
      final n = c.read(voiceTrainingProvider.notifier);
      await n.save('seed_waheguru', [for (var k = 0; k < 5; k++) mfccOf(mantraA, seed: k)]);
      await n.save('seed_waheguru', [for (var k = 0; k < 3; k++) mfccOf(mantraB, seed: k)]);
      expect(c.read(voiceTrainingProvider)['seed_waheguru']!.sampleCount, 3);
      expect(makeContainer().read(voiceTrainingProvider)['seed_waheguru']!.sampleCount, 3);
    });

    test('clear removes it from memory and from Hive', () async {
      final c = makeContainer();
      final n = c.read(voiceTrainingProvider.notifier);
      await n.save('seed_waheguru', [for (var k = 0; k < 3; k++) mfccOf(mantraA, seed: k)]);
      await n.save('seed_gayatri', [for (var k = 0; k < 3; k++) mfccOf(mantraB, seed: k)]);
      await n.clear('seed_waheguru');
      expect(c.read(mantraTrainedProvider('seed_waheguru')), isFalse);
      expect(c.read(mantraTrainedProvider('seed_gayatri')), isTrue,
          reason: 'other mantras keep their training');
      expect(AppStorage.voiceTemplates.get('seed_waheguru'), isNull);
      expect(makeContainer().read(voiceTrainingProvider).keys, ['seed_gayatri']);
      await n.clear('never_trained'); // harmless
    });

    test('each mantra has its own training', () async {
      final c = makeContainer();
      final n = c.read(voiceTrainingProvider.notifier);
      await n.save('a', [for (var k = 0; k < 3; k++) mfccOf(mantraA, seed: k)]);
      await n.save('b', [for (var k = 0; k < 4; k++) mfccOf(mantraB, seed: k)]);
      final s = c.read(voiceTrainingProvider);
      expect(s['a']!.sampleCount, 3);
      expect(s['b']!.sampleCount, 4);
    });

    test('fewer than 3 recordings is saved but not usable', () async {
      final c = makeContainer();
      await c
          .read(voiceTrainingProvider.notifier)
          .save('seed_waheguru', [mfccOf(mantraA), mfccOf(mantraA, seed: 2)]);
      expect(c.read(voiceTrainingProvider)['seed_waheguru']!.isUsable, isFalse);
      expect(c.read(mantraTrainedProvider('seed_waheguru')), isFalse);
    });

    test('works for a custom mantra, and deleting the mantra clears it',
        () async {
      final c = makeContainer();
      final custom = await c.read(mantraLibraryProvider.notifier).add(
            title: 'My mantra',
            script: '',
            transliteration: '',
            tradition: 'Other',
            defaultCount: 21,
          );
      await c
          .read(voiceTrainingProvider.notifier)
          .save(custom.id, [for (var k = 0; k < 3; k++) mfccOf(mantraC, seed: k)]);
      expect(c.read(mantraTrainedProvider(custom.id)), isTrue,
          reason: 'any mantra, custom ones included');
      await c.read(mantraLibraryProvider.notifier).remove(custom.id);
      expect(c.read(mantraTrainedProvider(custom.id)), isFalse);
      expect(AppStorage.voiceTemplates.values, isEmpty);
    });

    test('damaged records are skipped, never crash the app', () {
      AppStorage.voiceTemplates.put('bad1', 'garbage');
      AppStorage.voiceTemplates.put('bad2', {'mantraId': 'bad2', 'templates': 5});
      AppStorage.voiceTemplates.put('bad3',
          {'mantraId': 'bad3', 'dims': 13, 'templates': [Uint8List(7), 'x']});
      AppStorage.voiceTemplates.put('bad4',
          {'mantraId': 'bad4', 'dims': 40, 'templates': [Uint8List(160)]});
      final good = mfccOf(mantraA);
      AppStorage.voiceTemplates.put('half', {
        'mantraId': 'half',
        'dims': 13,
        'templates': [good.toBytes(), Uint8List(9), good.toBytes(), good.toBytes()],
      });
      final s = makeContainer().read(voiceTrainingProvider);
      expect(s.keys, ['half'], reason: 'only the readable one');
      expect(s['half']!.sampleCount, 3, reason: 'the damaged template is dropped');
      expect(s['half']!.trainedAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('the sensitivity slider persists and is clamped', () {
      final c = makeContainer();
      expect(c.read(voiceSensitivityProvider), defaultVoiceSensitivity);
      final n = c.read(voiceSensitivityProvider.notifier);
      n.set(0.2);
      expect(makeContainer().read(voiceSensitivityProvider), 0.2);
      n.set(7);
      expect(c.read(voiceSensitivityProvider), 1.0);
      n.set(-1);
      expect(c.read(voiceSensitivityProvider), 0.0);
      n.set(double.nan);
      expect(c.read(voiceSensitivityProvider), 0.0, reason: 'NaN is ignored');
      AppStorage.settings.put('voice.sensitivity', 'oops');
      expect(makeContainer().read(voiceSensitivityProvider), defaultVoiceSensitivity);
    });
  });

  group('VoiceTrainer: record the mantra 3 to 7 times', () {
    late FakePcmInput mic;
    late VoiceTrainer trainer;

    setUp(() {
      mic = FakePcmInput();
      trainer = VoiceTrainer(input: mic);
      addTearDown(trainer.dispose);
    });

    Future<void> startAndCalibrate() async {
      expect(await trainer.start(), VoiceStartResult.started);
      expect(trainer.phase, TrainerPhase.calibrating);
      feedInChunks(toPcm(silence(600)), mic.push);
      expect(trainer.phase, TrainerPhase.waiting);
    }

    void say(Float64List chant) => feedInChunks(
        toPcm(concat([chant, silence(900, seed: 9)])), mic.push);

    Float64List rep(int seed, {double tempo = 1}) =>
        synthMantra(mantraA, seed: seed, tempo: tempo);

    test('walks through calibrate -> "Recording 1 of up to 7" ... complete',
        () async {
      await startAndCalibrate();
      expect(trainer.currentIndex, 1);
      expect(trainer.recorded, 0);
      expect(trainer.canSave, isFalse);
      expect(trainer.minimum, 3);
      expect(trainer.maximum, 7);

      for (var i = 1; i <= 7; i++) {
        expect(trainer.currentIndex, i, reason: 'Recording $i of up to 7');
        expect(trainer.phase, TrainerPhase.waiting);
        say(rep(i, tempo: 1 + (i % 3) * 0.04));
        expect(trainer.recorded, i);
        expect(trainer.canSave, i >= 3, reason: '3 is the minimum, not 5');
      }
      expect(trainer.phase, TrainerPhase.complete, reason: '7 is the maximum');
      expect(mic.streaming, isFalse, reason: 'the microphone is off again');
      expect(trainer.samples.length, 7);
      for (final s in trainer.samples) {
        expect(s.dims, 13);
        expect(s.frames, greaterThan(50));
      }
    });

    test('the recordings make a usable model that counts the mantra', () async {
      await startAndCalibrate();
      for (var i = 1; i <= 4; i++) {
        say(rep(i, tempo: 0.95 + i * 0.03));
      }
      final model = MatchModel(trainer.samples);
      final again = mfccOf(mantraA, seed: 99);
      final other = mfccOf(mantraB, seed: 98);
      expect(model.evaluate(again, 0.5).matched, isTrue);
      expect(model.evaluate(other, 0.5).matched, isFalse);
    });

    test('5 is not special: it keeps listening until 7', () async {
      await startAndCalibrate();
      for (var i = 1; i <= 5; i++) {
        say(rep(i));
      }
      expect(trainer.phase, TrainerPhase.waiting);
      expect(trainer.recorded, 5);
      expect(trainer.remaining, 2);
      expect(mic.streaming, isTrue);
    });

    test('any number from 3 to 7 can be saved', () async {
      for (final n in [3, 4, 5, 6, 7]) {
        final m = FakePcmInput();
        final t = VoiceTrainer(input: m);
        addTearDown(t.dispose);
        await t.start();
        feedInChunks(toPcm(silence(600)), m.push);
        for (var i = 1; i <= n; i++) {
          feedInChunks(toPcm(concat([rep(i), silence(900, seed: 9)])), m.push);
        }
        expect(t.recorded, n);
        expect(t.canSave, isTrue, reason: '$n recordings');
      }
      final m = FakePcmInput();
      final few = VoiceTrainer(input: m);
      addTearDown(few.dispose);
      await few.start();
      feedInChunks(toPcm(silence(600)), m.push);
      for (var i = 1; i <= 2; i++) {
        feedInChunks(toPcm(concat([rep(i), silence(900, seed: 9)])), m.push);
      }
      expect(few.canSave, isFalse, reason: '2 is too few');
    });

    test('can stop after 3 or 4 recordings and still save', () async {
      await startAndCalibrate();
      for (var i = 1; i <= 3; i++) {
        say(rep(i));
      }
      expect(trainer.phase, TrainerPhase.waiting);
      expect(trainer.canSave, isTrue);
      await trainer.stop();
      expect(mic.streaming, isFalse);
      expect(trainer.samples.length, 3);
    });

    test('a click or cough is not recorded; the user is told', () async {
      await startAndCalibrate();
      say(tone(500, ms: 90, amp: 0.4));
      expect(trainer.recorded, 0);
      expect(trainer.message, contains('too short'));
      say(rep(1));
      expect(trainer.recorded, 1, reason: 'the real one still counts');
    });

    test('a recording that ran on too long is not kept', () async {
      await startAndCalibrate();
      // 40 s of continuous chanting: past the 30 s cap.
      say(concat([for (var i = 0; i < 40; i++) tone(300 + 20.0 * (i % 5), ms: 1000, amp: 0.3)]));
      expect(trainer.recorded, 0);
      expect(trainer.message, contains('too long'));
    });

    test('a recording that sounds like something else is asked to be redone',
        () async {
      await startAndCalibrate();
      say(rep(1));
      say(rep(2, tempo: 1.05));
      expect(trainer.recorded, 2);
      say(synthMantra(mantraB, seed: 5)); // a different mantra by mistake
      expect(trainer.recorded, 2, reason: 'not added');
      expect(trainer.message, contains('different'));
      say(rep(3, tempo: 0.97));
      expect(trainer.recorded, 3, reason: 'the proper one is');
    });

    test('but if the user insists three times, their way is accepted',
        () async {
      await startAndCalibrate();
      say(rep(1));
      say(rep(2, tempo: 1.05));
      for (var i = 0; i < 3; i++) {
        say(synthMantra(mantraB, seed: 10 + i));
      }
      expect(trainer.recorded, 3, reason: 'third insistence is accepted');
    });

    test('Undo last forgets the previous recording', () async {
      await startAndCalibrate();
      say(rep(1));
      say(rep(2, tempo: 1.03));
      trainer.discardLast();
      expect(trainer.recorded, 1);
      expect(trainer.currentIndex, 2);
      trainer.discardLast();
      trainer.discardLast(); // nothing left: harmless
      expect(trainer.recorded, 0);
    });

    test('exposes a live level for the meter', () async {
      await startAndCalibrate();
      var maxLevel = 0.0;
      trainer.addListener(() => maxLevel = maxLevel < trainer.level ? trainer.level : maxLevel);
      say(rep(1));
      expect(maxLevel, greaterThan(0.5), reason: 'a chant lights the meter');
      expect(trainer.level, inInclusiveRange(0.0, 1.0));
    });

    test('audio is only analysed while listening', () async {
      feedInChunks(toPcm(rep(1)), mic.push); // not started: dropped
      expect(trainer.recorded, 0);
      await startAndCalibrate();
      await trainer.stop();
      mic.streaming = true; // even if the mic misbehaved
      say(rep(1));
      expect(trainer.recorded, 0);
    });

    test('permission denied / blocked / no mic are explained', () async {
      for (final (result, text) in [
        (VoiceStartResult.denied, 'permission was denied'),
        (VoiceStartResult.permanentlyDenied, 'blocked'),
        (VoiceStartResult.unavailable, 'No microphone available on this device'),
        (VoiceStartResult.unsupported, 'Android and iOS only'),
      ]) {
        final m = FakePcmInput(result: result);
        final t = VoiceTrainer(input: m);
        addTearDown(t.dispose);
        expect(await t.start(), result);
        expect(t.phase, TrainerPhase.error);
        expect(t.message, contains(text));
        expect(t.listening, isFalse);
      }
    });

    test('a microphone that dies mid-training is reported', () async {
      await startAndCalibrate();
      say(rep(1));
      mic.fail('Microphone access was lost, so voice counting stopped.');
      expect(trainer.phase, TrainerPhase.error);
      expect(trainer.message, contains('lost'));
      expect(trainer.recorded, 1, reason: 'what was recorded is kept');
    });

    test('Start over clears the recordings', () async {
      await startAndCalibrate();
      say(rep(1));
      trainer.clear();
      expect(trainer.recorded, 0);
    });

    test('disposing releases the microphone', () async {
      final own = FakePcmInput();
      final t = VoiceTrainer(input: own);
      await t.start();
      expect(own.streaming, isTrue);
      t.dispose();
      await pumpEventQueue();
      expect(own.streaming, isFalse);
    });
  });

  group('VoiceTrainer: adding more samples to an existing training', () {
    late FakePcmInput mic;

    setUp(() => mic = FakePcmInput());

    Float64List rep(int seed, {double tempo = 1}) =>
        synthMantra(mantraA, seed: seed, tempo: tempo);

    List<MfccSequence> saved(int n) => [
          for (var k = 1; k <= n; k++) mfccOf(mantraA, seed: k, tempo: 0.95 + k * 0.03),
        ];

    Future<VoiceTrainer> begin(List<MfccSequence> existing) async {
      final t = VoiceTrainer(input: mic, existing: existing);
      addTearDown(t.dispose);
      await t.start();
      feedInChunks(toPcm(silence(600)), mic.push);
      return t;
    }

    void say(Float64List chant) =>
        feedInChunks(toPcm(concat([chant, silence(900, seed: 9)])), mic.push);

    test('starts from what is saved and appends to it', () async {
      final existing = saved(4);
      final t = await begin(existing);
      expect(t.recorded, 4);
      expect(t.added, 0);
      expect(t.currentIndex, 5, reason: 'the next one is Recording 5');
      expect(t.remaining, 3);
      expect(t.canSave, isFalse, reason: 'nothing new to save yet');

      say(rep(21));
      expect(t.recorded, 5);
      expect(t.added, 1);
      expect(t.canSave, isTrue, reason: 'one new recording is enough to save');
      expect(t.samples.length, 5);
      for (var i = 0; i < 4; i++) {
        expect(identical(t.samples[i], existing[i]), isTrue,
            reason: 'the saved templates are kept, in order, untouched');
      }
    });

    test('stops when the total reaches 7, not after 7 new ones', () async {
      final t = await begin(saved(5));
      say(rep(21));
      expect(t.phase, TrainerPhase.waiting);
      say(rep(22));
      expect(t.recorded, 7);
      expect(t.phase, TrainerPhase.complete);
      expect(t.remaining, 0);
      expect(t.added, 2);
      expect(mic.streaming, isFalse);
    });

    test('already at the maximum: nothing more can be added', () async {
      final t = VoiceTrainer(input: mic, existing: saved(7));
      addTearDown(t.dispose);
      await t.start();
      expect(t.phase, TrainerPhase.complete);
      expect(mic.starts, 0, reason: 'the microphone is never opened');
      expect(t.canSave, isFalse);
    });

    test('Undo and Start over only remove NEW recordings', () async {
      final t = await begin(saved(4));
      say(rep(21));
      say(rep(22));
      expect(t.recorded, 6);
      t.discardLast();
      expect(t.recorded, 5);
      t.discardLast();
      t.discardLast(); // nothing new left: the saved ones are safe
      t.discardLast();
      expect(t.recorded, 4, reason: 'never below what was saved');
      say(rep(23));
      t.clear();
      expect(t.recorded, 4);
      expect(t.added, 0);
    });

    test('a recording that sounds like something else is still caught, '
        'against the saved ones', () async {
      final t = await begin(saved(3));
      say(synthMantra(mantraB, seed: 5));
      expect(t.added, 0, reason: 'checked against the existing recordings');
      expect(t.message, contains('different'));
      say(rep(22, tempo: 0.97));
      expect(t.added, 1);
    });

    test('the combined model can only match better, and still rejects '
        'other sounds', () async {
      final existing = saved(3);
      final t = await begin(existing);
      say(synthMantra(mantraA, seed: 40, tempo: 1.3, f0: 105));
      expect(t.added, 1);
      final combined = MatchModel(t.samples);
      final old = MatchModel(existing);
      expect(combined.templates.length, 4);

      // A read of the mantra like the new sample.
      final probe = mfccOf(mantraA, seed: 41, tempo: 1.28, f0: 108);
      final before = old.evaluate(probe, 0.5).distance;
      final after = combined.evaluate(probe, 0.5).distance;
      expect(after, lessThanOrEqualTo(before + 1e-9),
          reason: 'a template added to the set never makes the best match worse');
      expect(combined.evaluate(probe, 0.5).matched, isTrue);
      expect(combined.evaluate(mfccOf(mantraB, seed: 42), 0.5).matched, isFalse);
    });
  });

  group('DeviceVoiceCounterService: microphone -> engine -> counts', () {
    late FakePcmInput mic;

    // Train on 4 repeats, then listen through the real engine.
    final model = MatchModel([
      for (var k = 1; k <= 4; k++) mfccOf(mantraA, seed: k, tempo: 0.94 + k * 0.03),
    ]);

    Future<(DeviceVoiceCounterService, List<VoiceCandidate>, List<String>)> listening(
        {double sens = 0.5}) async {
      final svc = DeviceVoiceCounterService(mic);
      final hits = <VoiceCandidate>[];
      final stops = <String>[];
      final r = await svc.start(
        model: model,
        sensitivity: sens,
        onCandidate: hits.add,
        onStopped: stops.add,
      );
      expect(r, VoiceStartResult.started);
      addTearDown(svc.stop);
      return (svc, hits, stops);
    }

    setUp(() => mic = FakePcmInput());

    test('counts the trained mantra and nothing else', () async {
      final (_, hits, _) = await listening();
      feedInChunks(
          toPcm(concat([
            silence(700),
            synthMantra(mantraA, seed: 21), silence(600, seed: 1),
            synthMantra(mantraB, seed: 22), silence(600, seed: 2),
            synthMantra(mantraA, seed: 23, tempo: 1.04), silence(600, seed: 3),
          ])),
          mic.push);
      expect(hits.where((c) => c.matched).length, 2);
      expect(hits.where((c) => !c.matched).length, greaterThanOrEqualTo(1),
          reason: 'the other mantra was heard and rejected');
    });

    test('unsupported platform / permission / no mic are passed through',
        () async {
      for (final result in [
        VoiceStartResult.unsupported,
        VoiceStartResult.denied,
        VoiceStartResult.permanentlyDenied,
        VoiceStartResult.unavailable,
      ]) {
        final svc = DeviceVoiceCounterService(FakePcmInput(
            supported: result != VoiceStartResult.unsupported, result: result));
        expect(
          await svc.start(
              model: model,
              sensitivity: 0.5,
              onCandidate: (_) {},
              onStopped: (_) {}),
          result,
        );
        expect(svc.isSupported, result != VoiceStartResult.unsupported);
      }
    });

    test('stop releases the microphone and ignores late audio', () async {
      final (svc, hits, _) = await listening();
      await svc.stop();
      expect(mic.streaming, isFalse);
      feedInChunks(toPcm(concat([silence(700), synthMantra(mantraA), silence(600, seed: 1)])),
          mic.push);
      expect(hits, isEmpty);
    });

    test('a microphone that dies reports it and stops', () async {
      final (svc, hits, stops) = await listening();
      mic.fail('No microphone available on this device');
      await pumpEventQueue();
      expect(stops, ['No microphone available on this device']);
      expect(mic.streaming, isFalse);
      mic.fail('again'); // no second report once stopped
      expect(stops.length, 1);
      expect(hits, isEmpty);
      await svc.stop();
    });

    test('the sensitivity can be changed while listening', () async {
      final (svc, hits, _) = await listening(sens: 0);
      final loose = synthMantra(mantraA, seed: 60, tempo: 1.2, f0: 185, noise: 0.01);
      feedInChunks(toPcm(concat([silence(700), loose, silence(700, seed: 6)])), mic.push);
      svc.setSensitivity(1);
      feedInChunks(toPcm(concat([loose, silence(700, seed: 7)])), mic.push);
      expect(hits.length, 2);
      expect(hits[1].threshold, greaterThan(hits[0].threshold));
    });

    test('starting again replaces the previous session', () async {
      final (svc, hits, _) = await listening();
      final r = await svc.start(
          model: model,
          sensitivity: 0.5,
          onCandidate: hits.add,
          onStopped: (_) {});
      expect(r, VoiceStartResult.started);
      expect(mic.starts, 2);
      feedInChunks(toPcm(concat([silence(700), synthMantra(mantraA, seed: 21), silence(700, seed: 1)])),
          mic.push);
      expect(hits.where((c) => c.matched).length, 1,
          reason: 'one engine, not two counting the same rep');
    });
  });
}
