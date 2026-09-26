import 'dart:math' as math;
import 'dart:typed_data';

import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/sadhana/application/voice_training_provider.dart';
import 'package:advance_calendar/features/sadhana/services/pcm_input.dart';
import 'package:advance_calendar/features/sadhana/voice/calibration.dart';
import 'package:advance_calendar/features/sadhana/voice/match_model.dart';
import 'package:advance_calendar/features/sadhana/voice/mfcc.dart';
import 'package:advance_calendar/features/sadhana/voice/utterance_detector.dart';
import 'package:advance_calendar/features/sadhana/voice/voice_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'synth.dart';
import 'test_support.dart';

/// P5-5: voice counting Stage A, on synthetic signals: deltas, normalisation,
/// a VAD that ignores breaths and noise bursts, several reps in one breath,
/// and the "chant it 11 times" calibration. Same MFCC + DTW engine, offline.
void main() {
  final extractor = MfccExtractor();

  MfccSequence mfccOf(List<Syllable> s,
          {double tempo = 1, double f0 = 140, int seed = 1, double gain = 0.3}) =>
      extractor.extract(loudnessNormalized(concat([
        silence(100),
        synthMantra(s, tempo: tempo, f0: f0, seed: seed, gain: gain),
        silence(100),
      ])));

  MatchModel trained([double? calibrated]) => MatchModel([
        mfccOf(mantraA, seed: 1),
        mfccOf(mantraA, seed: 2, tempo: 1.08),
        mfccOf(mantraA, seed: 3, tempo: 0.93),
        mfccOf(mantraA, seed: 4, tempo: 1.02, f0: 150),
      ], calibratedThreshold: calibrated);

  /// A breath: noise shaped around 1.5 kHz, swelling and fading.
  Float64List breath(int ms, {double level = 0.2, int seed = 9}) {
    final rng = math.Random(seed);
    final n = ms * 16;
    final out = Float64List(n);
    var y1 = 0.0, y2 = 0.0;
    final a = 1.6 * math.cos(2 * math.pi * 1500 / 16000);
    for (var i = 0; i < n; i++) {
      final y = (rng.nextDouble() - 0.5) * 2 + a * y1 - 0.8 * y2;
      y2 = y1;
      y1 = y;
      out[i] = y * level * 0.2 * math.sin(math.pi * i / n);
    }
    return out;
  }

  group('features', () {
    test('deltas and delta-deltas: three times the coefficients per frame', () {
      final s = mfccOf(mantraA);
      final f = withDeltas(s);
      expect(f.frames, s.frames);
      expect(f.dims, 3 * mfccDims);
      expect(f.data.every((v) => v.isFinite), isTrue);
    });

    test('a steady sound has (near) zero deltas; a changing one does not', () {
      final flat = MfccSequence(
          30, 2, Float64List.fromList([for (var i = 0; i < 60; i++) i.isEven ? 1.0 : 2.0]));
      final ramp = MfccSequence(
          30, 2, Float64List.fromList([for (var i = 0; i < 60; i++) (i ~/ 2) * 0.1]));
      final df = withDeltas(flat), dr = withDeltas(ramp);
      double deltaEnergy(MfccSequence x) {
        var e = 0.0;
        for (var f = 0; f < x.frames; f++) {
          for (var c = 2; c < 4; c++) {
            e += x.at(f, c) * x.at(f, c);
          }
        }
        return e;
      }

      expect(deltaEnergy(df), lessThan(1e-9));
      expect(deltaEnergy(dr), greaterThan(1));
    });

    test('the frame distance stays on the statics scale', () {
      final a = mfccOf(mantraA, seed: 1), b = mfccOf(mantraB, seed: 2);
      double avgNorm(MfccSequence x) {
        var sum = 0.0;
        for (var f = 0; f < x.frames; f++) {
          var sq = 0.0;
          for (var c = 0; c < x.dims; c++) {
            sq += x.at(f, c) * x.at(f, c);
          }
          sum += math.sqrt(sq);
        }
        return sum / x.frames;
      }

      for (final s in [a, b]) {
        expect(avgNorm(withDeltas(s)) / avgNorm(s), inInclusiveRange(0.7, 1.3));
      }
    });

    test('cepstral mean normalisation: every coefficient averages zero', () {
      final raw = extractor.extract(synthMantra(mantraA), normalize: false);
      final cmn = cepstralMeanNormalized(raw);
      for (var c = 0; c < mfccDims; c++) {
        var sum = 0.0;
        for (var f = 0; f < cmn.frames; f++) {
          sum += cmn.at(f, c);
        }
        expect(sum / cmn.frames, closeTo(0, 1e-9));
      }
    });

    test('loudness normalisation: a soft and a loud chant come out alike', () {
      final loud = synthMantra(mantraA, gain: 0.6);
      final soft = synthMantra(mantraA, gain: 0.03);
      double rms(Float64List x) =>
          math.sqrt(x.fold(0.0, (a, v) => a + v * v) / x.length);
      expect(rms(loudnessNormalized(loud)), closeTo(0.1, 1e-6));
      expect(rms(loudnessNormalized(soft)), closeTo(0.1, 1e-6));
      // Digital silence is left alone, not blown up into noise.
      final zero = Float64List(1600);
      expect(loudnessNormalized(zero), same(zero));
    });

    test('old trainings (13-number templates) still load and match', () {
      final model = trained();
      expect(model.templates.first.dims, mfccDims);
      final r = model.evaluate(mfccOf(mantraA, seed: 21, tempo: 1.04), 0.5);
      expect(r.matched, isTrue, reason: 'd=${r.distance} thr=${r.threshold}');
    });
  });

  group('voice-activity detection', () {
    test('voice is voice-like; hiss and breath are not', () {
      const cfg = GateConfig();
      FrameCues cue(Float64List x, int frame) => FrameCues.of(
          Float64List.fromList(x.sublist(frame * 160, frame * 160 + 160)));
      final chant = synthMantra(mantraA);
      expect(cue(chant, 5).speechLike(cfg), isTrue);
      expect(cue(chant, 5).flatness, lessThan(0.1));
      final hiss = synthNoise(300, level: 0.08);
      expect(cue(hiss, 10).speechLike(cfg), isFalse);
      expect(cue(hiss, 10).zcr, greaterThan(0.35));
      final b = breath(400);
      expect(cue(b, 20).speechLike(cfg), isFalse);
    });

    test('a loud frame that is not voice never starts an utterance', () {
      final gate = EnergyGate();
      for (var i = 0; i < 50; i++) {
        gate.step(-60);
      }
      var started = false;
      for (var i = 0; i < 30; i++) {
        started |= gate.step(-25, speechLike: false) == GateEvent.start;
      }
      expect(started, isFalse);
      for (var i = 0; i < 5; i++) {
        started |= gate.step(-20) == GateEvent.start;
      }
      expect(started, isTrue, reason: 'voice louder than the noise still starts');
    });

    test('the noise floor rises under persistent loud non-voice', () {
      final gate = EnergyGate();
      for (var i = 0; i < 50; i++) {
        gate.step(-60);
      }
      final before = gate.noiseDb;
      for (var i = 0; i < 100; i++) {
        gate.step(-35, speechLike: false); // a fan, close by
      }
      expect(gate.noiseDb, greaterThan(before + 10));
    });

    test('breaths and noise bursts between reps start nothing', () {
      final utterances = <int>[];
      final det = UtteranceDetector(onUtterance: (u) => utterances.add(u.samples.length));
      feedInChunks(
          toPcm(concat([
            silence(700),
            breath(450), silence(500, seed: 4),
            synthNoise(300, level: 0.1, seed: 5), silence(500, seed: 6),
            breath(600, level: 0.3, seed: 7), silence(500, seed: 8),
          ])),
          det.addSamples);
      expect(utterances, isEmpty);
      // ...while a real chant is still found.
      feedInChunks(toPcm(concat([synthMantra(mantraA), silence(600, seed: 9)])),
          det.addSamples);
      expect(utterances, hasLength(1));
    });

    test('end to end: breath and clatter between reps are never even candidates',
        () {
      final out = <VoiceCandidate>[];
      final engine = VoiceEngine(model: trained(), onCandidate: out.add);
      feedInChunks(
          toPcm(concat([
            silence(700),
            synthMantra(mantraA, seed: 11), silence(600, seed: 21),
            breath(500), silence(600, seed: 22),
            synthNoise(400, level: 0.08, seed: 51), silence(600, seed: 23),
            synthMantra(mantraA, seed: 12), silence(600, seed: 24),
          ])),
          engine.addPcm);
      expect(out, hasLength(2));
      expect(out.every((c) => c.matched), isTrue);
    });
  });

  group('several repetitions in one breath', () {
    List<VoiceCandidate> listen(Float64List x) {
      final out = <VoiceCandidate>[];
      final engine = VoiceEngine(model: trained(), onCandidate: out.add);
      feedInChunks(toPcm(concat([silence(700), x, silence(800, seed: 8)])),
          engine.addPcm);
      return out;
    }

    /// [n] reps with only a short breath-less gap between them (shorter than
    /// the trailing silence that would end an utterance).
    Float64List inOneBreath(int n) => concat([
          for (var i = 0; i < n; i++) ...[
            synthMantra(mantraA, seed: 80 + i, tempo: i.isEven ? 1.0 : 1.04),
            if (i < n - 1) silence(90, seed: 90 + i),
          ],
        ]);

    for (final n in [2, 3, 4]) {
      test('$n in one breath count $n', () {
        final got = listen(inOneBreath(n));
        expect(got.where((c) => c.matched).length, n,
            reason: got.map((c) => c.distance.toStringAsFixed(2)).join(' '));
      });
    }

    test('one rep is still one', () {
      final got = listen(synthMantra(mantraA, seed: 70));
      expect(got, hasLength(1));
      expect(got.single.matched, isTrue);
    });

    test('two OTHER words in one breath count nothing', () {
      final other = concat([
        synthMantra(mantraB, seed: 1), silence(90), synthMantra(mantraB, seed: 2),
      ]);
      expect(listen(other).where((c) => c.matched), isEmpty);
    });

    test('the split falls in the quiet gap between the reps', () {
      final x = concat([
        silence(100),
        synthMantra(mantraA, seed: 1), silence(90),
        synthMantra(mantraA, seed: 2),
        silence(100),
      ]);
      final m = extractor.extract(loudnessNormalized(x));
      final cuts = MatchModel.splitPoints(m, 2);
      final gapStart = (100 + synthMantra(mantraA, seed: 1).length / 16) / 10;
      expect(cuts.first, 0);
      expect(cuts.last, m.frames);
      expect(cuts[1], inInclusiveRange(gapStart - 4, gapStart + 12));
    });

    test('more than four in one breath is still dropped as too long', () {
      final got = listen(concat([
        for (var i = 0; i < 12; i++) synthMantra(mantraA, seed: 70 + i),
      ]));
      expect(got.where((c) => c.matched), isEmpty);
    });
  });

  group('calibration', () {
    test('picks a threshold between the same and the different distances', () {
      final t = calibrateThreshold(
          same: [0.8, 1.1, 0.9, 1.3, 1.0], different: [3.1, 2.6, 4.0])!;
      expect(t, greaterThanOrEqualTo(1.3), reason: 'all repeats count');
      expect(t, lessThan(2.6), reason: 'no noise counts');
    });

    test('with nothing different heard: a little above the repeats', () {
      final t = calibrateThreshold(same: [1.0, 1.2], different: const [])!;
      expect(t, closeTo(1.38, 1e-9));
    });

    test('when they overlap, the room must not count', () {
      final t = calibrateThreshold(
          same: [1.0, 1.1, 1.2, 2.5], different: [2.0, 3.0])!;
      expect(t, lessThan(2.0));
    });

    test('infinite (rejected) distances are ignored; nothing heard is null', () {
      expect(calibrateThreshold(same: [double.infinity], different: [2]), isNull);
      expect(
          calibrateThreshold(same: [1.0, double.infinity], different: [double.infinity]),
          isNotNull);
    });

    test('the slider still works on top of the calibrated threshold', () {
      final model = trained(1.7);
      expect(model.thresholdFor(defaultVoiceSensitivity), closeTo(1.7, 1e-9));
      expect(model.thresholdFor(0), lessThan(1.7));
      expect(model.thresholdFor(1), greaterThan(1.7));
    });

    test('room noise scores far from the mantra', () {
      final model = trained();
      final quiet = extractor.extract(loudnessNormalized(synthNoise(2000, level: 0.004)));
      final d = noiseDistances(model, quiet);
      expect(d.length, greaterThanOrEqualTo(2));
      for (final v in d) {
        expect(v, greaterThan(model.thresholdFor(1)));
      }
    });

    test('the calibrator: quiet room, 11 reps shown as heard, then a threshold',
        () async {
      final mic = FakePcmInput();
      final model = trained();
      final c = VoiceCalibrator(input: mic, model: model);
      expect(await c.start(), VoiceStartResult.started);
      expect(c.phase, CalibrationPhase.quiet);
      feedInChunks(toPcm(silence(calibrationQuietMs + 100)), mic.push);
      expect(c.phase, CalibrationPhase.chanting);
      expect(c.noise, isNotEmpty);
      for (var i = 0; i < calibrationReps; i++) {
        feedInChunks(
            toPcm(concat([
              synthMantra(mantraA, seed: 100 + i, tempo: 0.95 + 0.01 * i),
              silence(600, seed: 200 + i),
            ])),
            mic.push);
        if (i == 4) expect(c.heard, hasLength(5));
      }
      // P5.1: then "Now say something else 5 times".
      expect(c.phase, CalibrationPhase.others);
      for (var i = 0; i < calibrationOtherReps; i++) {
        feedInChunks(
            toPcm(concat([
              synthMantra(mantraB, seed: 300 + i),
              silence(600, seed: 400 + i),
            ])),
            mic.push);
      }
      expect(c.phase, CalibrationPhase.done);
      expect(c.others, hasLength(calibrationOtherReps));
      expect(c.mantraCounted, calibrationReps);
      expect(c.othersCounted, 0);
      expect(mic.streaming, isFalse, reason: 'microphone released');
      final t = c.threshold!;
      final sameMax = c.heard.map((h) => h.distance).reduce(math.max);
      final noiseMin = c.noise.reduce(math.min);
      expect(t, greaterThanOrEqualTo(sameMax));
      expect(t, lessThan(noiseMin));
      c.dispose();
    });

    test('a sound that is not one repetition is skipped, not counted', () async {
      final mic = FakePcmInput();
      final c = VoiceCalibrator(input: mic, model: trained());
      await c.start();
      feedInChunks(toPcm(silence(calibrationQuietMs + 100)), mic.push);
      feedInChunks(
          toPcm(concat([synthMantra(mantraA.sublist(0, 1)), silence(600)])),
          mic.push);
      expect(c.heard, isEmpty);
      expect(c.ignored, 1);
      c.dispose();
    });

    test('a refused microphone is reported', () async {
      final c = VoiceCalibrator(
          input: FakePcmInput(result: VoiceStartResult.denied), model: trained());
      await c.start();
      expect(c.phase, CalibrationPhase.error);
      expect(c.error, contains('denied'));
      c.dispose();
    });

    test('the calibrated threshold is saved with the training, and cleared '
        'when the recordings change', () async {
      resetStorage();
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final store = container.read(voiceTrainingProvider.notifier);
      final templates = [
        mfccOf(mantraA, seed: 1),
        mfccOf(mantraA, seed: 2),
        mfccOf(mantraA, seed: 3),
      ];
      await store.save('m', templates);
      await store.setCalibration('m', 1.6);
      expect(container.read(voiceTrainingProvider)['m']!.calibratedThreshold, 1.6);
      expect(
          container
              .read(voiceTrainingProvider)['m']!
              .toModel()
              .thresholdFor(defaultVoiceSensitivity),
          closeTo(1.6, 1e-9));
      // Read back from storage.
      final again = ProviderContainer();
      addTearDown(again.dispose);
      expect(again.read(voiceTrainingProvider)['m']!.calibratedThreshold, 1.6);
      expect((AppStorage.voiceTemplates.get('m') as Map)['threshold'], 1.6);
      // New recordings: calibrate again.
      await store.save('m', [...templates, mfccOf(mantraA, seed: 4)]);
      expect(container.read(voiceTrainingProvider)['m']!.calibratedThreshold, isNull);
    });
  });
}
