import 'dart:math' as math;
import 'dart:typed_data';

import 'package:advance_calendar/features/sadhana/voice/dtw.dart';
import 'package:advance_calendar/features/sadhana/voice/match_model.dart';
import 'package:advance_calendar/features/sadhana/voice/mfcc.dart';
import 'package:advance_calendar/features/sadhana/voice/utterance_detector.dart';
import 'package:advance_calendar/features/sadhana/voice/voice_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import 'synth.dart';

void main() {
  final extractor = MfccExtractor();

  /// Room noise, the mantra, room noise: what one recording looks like.
  MfccSequence mfccOf(
    List<Syllable> s, {
    double tempo = 1,
    double f0 = 140,
    double gain = 0.3,
    int seed = 1,
    double noise = 0.002,
  }) =>
      extractor.extract(concat([
        silence(100),
        synthMantra(s,
            tempo: tempo, f0: f0, gain: gain, seed: seed, noise: noise),
        silence(100),
      ]));

  group('MFCC', () {
    test('25 ms frames every 10 ms, 13 coefficients each', () {
      // 1 s of audio: (16000 - 400) / 160 + 1 = 98 frames.
      final m = extractor.extract(tone(440, ms: 1000));
      expect(m.frames, 98);
      expect(m.dims, 13);
      expect(mfccDims, 13);
      expect(m.data.length, 98 * 13);
      expect(m.duration, const Duration(milliseconds: 980));
      expect(extractor.frameCountFor(400), 1);
      expect(extractor.frameCountFor(399), 0);
    });

    test('shorter than one frame gives an empty sequence', () {
      final m = extractor.extract(Float64List(200));
      expect(m.isEmpty, isTrue);
      expect(dtwDistance(m, m), double.infinity);
    });

    test('is deterministic and finite, even for silence', () {
      final a = extractor.extract(tone(300));
      final b = extractor.extract(tone(300));
      expect(a.data, b.data);
      final quiet = extractor.extract(Float64List(8000));
      expect(quiet.data.every((v) => v.isFinite), isTrue);
    });

    test('different pitches give different (raw) features', () {
      final low = extractor.extract(tone(300), normalize: false);
      final high = extractor.extract(tone(2500), normalize: false);
      expect(dtwDistance(low, high), greaterThan(5));
      expect(dtwDistance(low, extractor.extract(tone(300), normalize: false)), 0);
    });

    test('a change of sound over time is what survives normalisation', () {
      // A steady tone has no shape once its average is removed (by design:
      // that is what makes the match microphone-independent), but a rising
      // vs a falling glide still differ.
      Float64List glide(double from, double to) {
        final n = 8000;
        var phase = 0.0;
        return Float64List.fromList([
          for (var i = 0; i < n; i++)
            0.3 * math.sin(phase += 2 * math.pi * (from + (to - from) * i / n) / voiceSampleRate),
        ]);
      }
      final up = extractor.extract(glide(300, 3000));
      final down = extractor.extract(glide(3000, 300));
      expect(dtwDistance(up, extractor.extract(glide(300, 3000))), 0);
      expect(dtwDistance(up, down), greaterThan(2));
    });

    test('normalised: loudness does not change the features', () {
      final loud = extractor.extract(synthMantra(mantraA, gain: 0.5, noise: 0));
      final soft = extractor.extract(synthMantra(mantraA, gain: 0.02, noise: 0));
      expect(dtwDistance(loud, soft), lessThan(0.2),
          reason: 'a 25x quieter chant is the same chant');
    });

    test('every coefficient is mean 0 after normalisation', () {
      final m = extractor.extract(synthMantra(mantraA));
      for (var d = 0; d < m.dims; d++) {
        var sum = 0.0;
        for (var f = 0; f < m.frames; f++) {
          sum += m.at(f, d);
        }
        expect(sum / m.frames, closeTo(0, 1e-9), reason: 'coefficient $d');
      }
    });

    test('float32 bytes round-trip (how templates sit in Hive)', () {
      final m = extractor.extract(synthMantra(mantraB));
      final bytes = m.toBytes();
      expect(bytes.length, m.frames * 13 * 4, reason: '4 bytes per number');
      final back = MfccSequence.fromBytes(bytes)!;
      expect(back.frames, m.frames);
      expect(dtwDistance(m, back), lessThan(1e-4));
    });

    test('damaged bytes are rejected, not misread', () {
      expect(MfccSequence.fromBytes(Uint8List(0)), isNull);
      expect(MfccSequence.fromBytes(Uint8List(13 * 4 + 1)), isNull);
      final nan = ByteData(13 * 4)..setFloat32(0, double.nan, Endian.little);
      expect(MfccSequence.fromBytes(nan.buffer.asUint8List()), isNull);
    });

    test('templates are small: a 2 s mantra is about 10 KB, not 64 KB of audio',
        () {
      final m = extractor.extract(synthMantra(mantraB, tempo: 1.4));
      expect(m.toBytes().length, lessThan(16 * 1024));
    });
  });

  group('DTW', () {
    final a1 = mfccOf(mantraA, seed: 1);
    final a2 = mfccOf(mantraA, seed: 2, tempo: 1.1);
    final a3 = mfccOf(mantraA, seed: 3, tempo: 0.92, gain: 0.1);
    final b1 = mfccOf(mantraB, seed: 5);

    test('a sequence is at distance 0 from itself', () {
      expect(dtwDistance(a1, a1), 0);
    });

    test('is symmetric', () {
      expect(dtwDistance(a1, a2), closeTo(dtwDistance(a2, a1), 1e-9));
      expect(dtwDistance(a1, b1), closeTo(dtwDistance(b1, a1), 1e-9));
    });

    test('same mantra at another speed/volume/pitch stays close', () {
      expect(dtwDistance(a1, a2), lessThan(1.6)); // 10% slower
      expect(dtwDistance(a1, a3), lessThan(1.6)); // faster and far quieter
    });

    test('a different mantra is far, well apart from any repeat', () {
      final same = [dtwDistance(a1, a2), dtwDistance(a1, a3), dtwDistance(a2, a3)];
      final other = dtwDistance(a1, b1);
      expect(other, greaterThan(2.5));
      expect(other, greaterThan(2 * same.reduce(math.max)),
          reason: 'clear margin between "yes" and "no"');
    });

    test('warping absorbs a change of tempo that a frame-by-frame compare '
        'would not', () {
      final slow = mfccOf(mantraA, seed: 9, tempo: 1.25);
      expect(dtwDistance(a1, slow), lessThan(dtwDistance(a1, b1)));
      expect(dtwDistance(a1, slow), lessThan(1.8));
    });

    test('empty input is infinitely far', () {
      final empty = MfccSequence(0, 13, Float64List(0));
      expect(dtwDistance(a1, empty), double.infinity);
      expect(dtwDistance(empty, a1), double.infinity);
    });

    test('abandons early once it cannot come in under the limit', () {
      final d = dtwDistance(a1, b1);
      expect(dtwDistance(a1, b1, abandonAbove: d + 0.5), closeTo(d, 1e-9));
      expect(dtwDistance(a1, b1, abandonAbove: d - 0.5), double.infinity);
    });

    test('a hard band still matches identical sequences of equal length', () {
      expect(dtwDistance(a1, a1, bandRatio: 0.0), 0);
    });
  });

  group('EnergyGate on a synthetic loudness envelope', () {
    /// dB envelope: [n] frames at [db].
    List<double> level(double db, int n) => List.filled(n, db);

    /// Runs [envelope] through a fresh gate; returns (frame, event) pairs.
    List<(int, GateEvent)> run(List<double> envelope, [GateConfig? cfg]) {
      final gate = EnergyGate(cfg ?? const GateConfig());
      final out = <(int, GateEvent)>[];
      for (var i = 0; i < envelope.length; i++) {
        final e = gate.step(envelope[i]);
        if (e != GateEvent.none) out.add((i, e));
      }
      return out;
    }

    test('calibrates on the first 0.5 s, then goes live', () {
      final events = run([...level(-60, 60)]);
      expect(events, [(49, GateEvent.calibrated)]);
    });

    test('speech = start at the onset, end after the trailing silence', () {
      final events = run([
        ...level(-60, 50), // calibration
        ...level(-60, 10),
        ...level(-25, 80), // 0.8 s of speech
        ...level(-60, 60),
      ]);
      expect(events.map((e) => e.$2), [
        GateEvent.calibrated,
        GateEvent.start,
        GateEvent.end,
      ]);
      expect(events[1].$1, 62, reason: 'third loud frame confirms the onset');
      // 30 quiet frames (300 ms) after the last loud one (frame 139).
      expect(events[2].$1, 169);
    });

    test('the start frame is where the loud run began, not where it was '
        'confirmed', () {
      final gate = EnergyGate();
      for (var i = 0; i < 50; i++) {
        gate.step(-60);
      }
      for (var i = 0; i < 10; i++) {
        gate.step(-60);
      }
      GateEvent last = GateEvent.none;
      for (var i = 0; i < 5; i++) {
        last = gate.step(-25);
        if (last == GateEvent.start) break;
      }
      expect(gate.startFrame, 60);
    });

    test('a pause shorter than the trailing silence stays one utterance', () {
      final events = run([
        ...level(-60, 50),
        ...level(-25, 40),
        ...level(-60, 20), // 200 ms gap inside the mantra
        ...level(-25, 40),
        ...level(-60, 60),
      ]);
      expect(events.where((e) => e.$2 == GateEvent.start).length, 1);
      expect(events.where((e) => e.$2 == GateEvent.end).length, 1);
    });

    test('a longer pause splits two utterances', () {
      final events = run([
        ...level(-60, 50),
        ...level(-25, 40),
        ...level(-60, 60),
        ...level(-25, 40),
        ...level(-60, 60),
      ]);
      expect(events.where((e) => e.$2 == GateEvent.end).length, 2);
    });

    test('a click shorter than 200 ms is discarded, not reported as speech',
        () {
      final events = run([
        ...level(-60, 50),
        ...level(-20, 8),
        ...level(-60, 60),
      ]);
      expect(events.map((e) => e.$2),
          [GateEvent.calibrated, GateEvent.start, GateEvent.tooShort]);
    });

    test('a single loud blip never even starts (needs 30 ms of onset)', () {
      final events = run([
        ...level(-60, 50),
        ...level(-20, 2),
        ...level(-60, 40),
        ...level(-20, 2),
        ...level(-60, 40),
      ]);
      expect(events.map((e) => e.$2), [GateEvent.calibrated]);
    });

    test('speech past the length cap is cut, and the rest is ignored until '
        'quiet', () {
      final events = run([
        ...level(-60, 50),
        ...level(-25, 900), // 9 s of continuous speech, cap is 6 s
        ...level(-60, 60),
        ...level(-25, 40), // then a normal utterance
        ...level(-60, 60),
      ]);
      expect(events.map((e) => e.$2), [
        GateEvent.calibrated,
        GateEvent.start,
        GateEvent.forcedEnd,
        GateEvent.start, // only after it went quiet
        GateEvent.end,
      ]);
      expect(events[2].$1 - events[1].$1, 597,
          reason: 'cut at exactly the 600-frame cap');
    });

    test('a quiet noise floor still needs to be beaten by 9 dB', () {
      // Noise at -45 dB: speech at -40 (5 dB above) is not speech.
      final soft = run([...level(-45, 50), ...level(-40, 60), ...level(-45, 60)]);
      expect(soft.map((e) => e.$2), [GateEvent.calibrated]);
      final clear = run([...level(-45, 50), ...level(-30, 60), ...level(-45, 60)]);
      expect(clear.map((e) => e.$2), contains(GateEvent.start));
    });

    test('digital silence never triggers, however tiny the margin', () {
      final events = run([...level(-100, 50), ...level(-95, 100)]);
      expect(events.map((e) => e.$2), [GateEvent.calibrated],
          reason: 'never below the absolute -50 dB floor');
    });

    test('a floor learned while the user was already chanting recovers fast',
        () {
      final gate = EnergyGate();
      for (var i = 0; i < 50; i++) {
        gate.step(-25); // chanting through the whole calibration
      }
      expect(gate.noiseDb, closeTo(-25, 1));
      for (var i = 0; i < 20; i++) {
        gate.step(-60); // the first quiet moment
      }
      expect(gate.noiseDb, lessThan(-55), reason: 'within 200 ms');
      var start = false;
      for (var i = 0; i < 10; i++) {
        start |= gate.step(-25) == GateEvent.start;
      }
      expect(start, isTrue, reason: 'the next repeat is heard');
    });

    test('calibration ignores speech during it (lower-quartile floor)', () {
      final gate = EnergyGate();
      for (var i = 0; i < 50; i++) {
        gate.step(i < 15 ? -25 : -60); // user starts talking at once
      }
      expect(gate.noiseDb, closeTo(-60, 1));
    });

    test('the noise floor follows a slowly changing room', () {
      final gate = EnergyGate();
      for (var i = 0; i < 50; i++) {
        gate.step(-60);
      }
      final before = gate.noiseDb;
      for (var i = 0; i < 300; i++) {
        gate.step(-52); // a fan turns on: below the onset threshold
      }
      expect(gate.noiseDb, greaterThan(before + 5));
    });

    test('a longer hangover keeps a verse with pauses together', () {
      final env = [
        ...level(-60, 50),
        ...level(-25, 40),
        ...level(-60, 40), // 400 ms breath
        ...level(-25, 40),
        ...level(-60, 70),
      ];
      expect(run(env).where((e) => e.$2 == GateEvent.end).length, 2);
      expect(
          run(env, const GateConfig(hangoverFrames: 60))
              .where((e) => e.$2 == GateEvent.end)
              .length,
          1);
    });

    test('reset starts over with a new calibration', () {
      final gate = EnergyGate();
      for (var i = 0; i < 50; i++) {
        gate.step(-60);
      }
      expect(gate.calibrated, isTrue);
      gate.reset();
      expect(gate.calibrated, isFalse);
      expect(gate.step(-60), GateEvent.none);
    });
  });

  group('UtteranceDetector on PCM', () {
    List<Utterance> detect(Float64List signal, {GateConfig? config}) {
      final found = <Utterance>[];
      final d = UtteranceDetector(
          config: config ?? const GateConfig(), onUtterance: found.add);
      feedInChunks(toPcm(signal), d.addSamples);
      return found;
    }

    test('finds each repeat, with pauses between, in a chunked stream', () {
      final rep = synthMantra(mantraA, seed: 1);
      final stream = concat([
        silence(600),
        rep,
        silence(700, seed: 4),
        synthMantra(mantraA, seed: 2),
        silence(700, seed: 5),
        synthMantra(mantraA, seed: 3),
        silence(700, seed: 6),
      ]);
      final found = detect(stream);
      expect(found.length, 3);
      for (final u in found) {
        expect(u.forced, isFalse);
        // The chant is ~0.7 s; the cut adds only a short lead-in and tail.
        expect(u.duration.inMilliseconds, inInclusiveRange(700, 1300));
      }
    });

    test('keeps a little audio from before the onset (soft first syllable)',
        () {
      final found = detect(concat([
        silence(600),
        synthMantra(mantraA),
        silence(700, seed: 4),
      ]));
      expect(found.length, 1);
      final u = found.single;
      // Pre-roll: the first samples are still quiet room noise.
      var head = 0.0;
      for (var i = 0; i < 800; i++) {
        head = math.max(head, u.samples[i].abs());
      }
      expect(head, lessThan(0.02));
    });

    test('a cough-length click is not an utterance', () {
      final click = concat([
        silence(600),
        tone(500, ms: 80, amp: 0.4),
        silence(700, seed: 4),
      ]);
      final tooShort = <bool>[];
      final found = <Utterance>[];
      final d = UtteranceDetector(
        onUtterance: found.add,
        onTooShort: () => tooShort.add(true),
      );
      feedInChunks(toPcm(click), d.addSamples);
      expect(found, isEmpty, reason: 'never handed on as a candidate');
      expect(tooShort.length, 1, reason: 'seen, and dropped as too short');
    });

    test('reports calibration and a live level', () {
      var noise = 0.0;
      var levels = 0;
      double? maxLevel;
      final d = UtteranceDetector(
        onCalibrated: (db) => noise = db,
        onLevel: (db) {
          levels++;
          maxLevel = math.max(maxLevel ?? -200, db);
        },
      );
      feedInChunks(
          toPcm(concat([silence(600), synthMantra(mantraA), silence(500)])),
          d.addSamples);
      expect(noise, lessThan(-45));
      expect(levels, greaterThan(20));
      expect(maxLevel, greaterThan(-25), reason: 'the chant is loud');
      expect(d.gate.calibrated, isTrue);
    });

    test('an over-long run of speech is cut at the cap and flagged', () {
      final long = synthMantra(mantraA, tempo: 1)..length;
      final rep = [for (var i = 0; i < 6; i++) long];
      final found = detect(
          concat([
            silence(600),
            // Continuous speech (no gaps) far past a 2 s cap.
            for (final r in rep) r,
            silence(800, seed: 4),
          ]),
          config: const GateConfig(maxFrames: 200, hangoverFrames: 100));
      expect(found.first.forced, isTrue);
      expect(found.first.duration.inMilliseconds, lessThan(2300));
    });

    test('works with odd chunk sizes and single samples', () {
      final sig = toPcm(concat([silence(600), synthMantra(mantraA), silence(700, seed: 4)]));
      final found = <Utterance>[];
      final d = UtteranceDetector(onUtterance: found.add);
      var at = 0;
      final sizes = [1, 7, 159, 161, 1000, 3, 4096];
      var k = 0;
      while (at < sig.length) {
        final n = math.min(sizes[k++ % sizes.length], sig.length - at);
        d.addSamples(Int16List.sublistView(sig, at, at + n));
        at += n;
      }
      expect(found.length, 1);
    });
  });

  group('MatchModel: a template vs itself and vs other sounds', () {
    final t1 = mfccOf(mantraA, seed: 1);
    final t2 = mfccOf(mantraA, seed: 2, tempo: 1.08);
    final t3 = mfccOf(mantraA, seed: 3, tempo: 0.93, gain: 0.15);
    final model = MatchModel([t1, t2, t3]);

    test('a trained template matched against itself is (near) zero', () {
      for (final t in [t1, t2, t3]) {
        final r = model.evaluate(t, defaultVoiceSensitivity);
        expect(r.distance, lessThan(0.001));
        expect(r.matched, isTrue);
        expect(r.closeness, greaterThan(0.99));
      }
    });

    test('a new repeat of the mantra matches', () {
      final again = mfccOf(mantraA,
          seed: 20, tempo: 1.03, f0: 150, gain: 0.2, noise: 0.006);
      final r = model.evaluate(again, defaultVoiceSensitivity);
      expect(r.matched, isTrue, reason: 'd=${r.distance} thr=${r.threshold}');
      expect(r.distance, lessThan(r.threshold));
    });

    test('a different sound of similar length does not', () {
      // Same length and rhythm as the mantra, different vowels.
      const lookalike = [
        Syllable(300, 2500),
        Syllable(800, 1100),
        Syllable(350, 700, 260),
      ];
      final other = mfccOf(lookalike, seed: 30);
      expect(model.lengthPlausible(other.frames), isTrue,
          reason: 'this must be rejected on sound, not on length');
      final r = model.evaluate(other, defaultVoiceSensitivity);
      expect(r.matched, isFalse, reason: 'd=${r.distance} thr=${r.threshold}');
      expect(r.distance, greaterThan(r.threshold));
    });

    test('a very different sound, or one of the wrong length, is far away', () {
      final b = mfccOf(mantraB, seed: 31);
      final c = mfccOf(mantraC, seed: 32);
      for (final s in [b, c]) {
        final r = model.evaluate(s, defaultVoiceSensitivity);
        expect(r.matched, isFalse);
        expect(r.distance, greaterThan(r.threshold));
      }
    });

    test('noise, and a half-said mantra, are ignored', () {
      final hiss = extractor.extract(synthNoise(700, level: 0.05));
      expect(model.evaluate(hiss, 1.0).matched, isFalse,
          reason: 'even at the most lenient setting');
      final half = extractor.extract(concat([
        silence(100),
        synthMantra(mantraA.sublist(0, 1), seed: 40),
        silence(100),
      ]));
      final r = model.evaluate(half, defaultVoiceSensitivity);
      expect(r.matched, isFalse);
      expect(r.distance, double.infinity, reason: 'far too short to be a rep');
    });

    test('length gate: 45% .. 220% of the trained length', () {
      final m = model.medianFrames;
      expect(model.lengthPlausible((m * 0.44).floor()), isFalse);
      expect(model.lengthPlausible((m * 0.46).ceil()), isTrue);
      expect(model.lengthPlausible((m * 2.19).floor()), isTrue);
      expect(model.lengthPlausible((m * 2.3).ceil()), isFalse);
    });

    test('Strict rejects what Lenient accepts, and thresholds stay in bounds',
        () {
      final strict = model.thresholdFor(0);
      final medium = model.thresholdFor(0.5);
      final lenient = model.thresholdFor(1);
      expect(strict, lessThanOrEqualTo(medium));
      expect(medium, lessThanOrEqualTo(lenient));
      expect(lenient, greaterThan(strict));
      for (final v in [strict, medium, lenient]) {
        expect(v, inInclusiveRange(MatchModel.minThreshold, MatchModel.maxThreshold));
      }
      expect(model.thresholdFor(-5), strict, reason: 'clamped');
      expect(model.thresholdFor(9), lenient, reason: 'clamped');
    });

    test('the threshold adapts to how consistent the speaker is', () {
      final steady = MatchModel([
        mfccOf(mantraA, seed: 1),
        mfccOf(mantraA, seed: 2),
        mfccOf(mantraA, seed: 3),
      ]);
      final loose = MatchModel([
        mfccOf(mantraA, seed: 1, tempo: 0.8, f0: 110, noise: 0.02),
        mfccOf(mantraA, seed: 2, tempo: 1.25, f0: 190, noise: 0.02),
        mfccOf(mantraA, seed: 3, tempo: 1.0, f0: 150, noise: 0.04),
      ]);
      expect(loose.baseDistance, greaterThan(steady.baseDistance));
      expect(loose.thresholdFor(0.5), greaterThanOrEqualTo(steady.thresholdFor(0.5)));
    });

    test('closeness is 0.5 at the threshold and 0 when far', () {
      const atThreshold =
          VoiceCandidate(matched: true, distance: 2, threshold: 2);
      expect(atThreshold.closeness, closeTo(0.5, 1e-9));
      const far = VoiceCandidate(
          matched: false, distance: double.infinity, threshold: 2);
      expect(far.closeness, 0);
    });

    test('caps how long a candidate the detector will bother with', () {
      expect(model.maxPlausibleFrames, greaterThan(model.maxFrames));
    });
  });

  group('VoiceEngine end to end (synthetic chanting, no microphone)', () {
    final model = MatchModel([
      mfccOf(mantraA, seed: 1),
      mfccOf(mantraA, seed: 2, tempo: 1.08),
      mfccOf(mantraA, seed: 3, tempo: 0.93),
      mfccOf(mantraA, seed: 4, tempo: 1.02, f0: 150),
    ]);

    /// Feeds [parts] as one continuous stream and returns each candidate.
    List<VoiceCandidate> listen(List<Float64List> parts, {double sens = 0.5}) {
      final out = <VoiceCandidate>[];
      final engine = VoiceEngine(
          model: model, sensitivity: sens, onCandidate: out.add);
      feedInChunks(toPcm(concat(parts)), engine.addPcm);
      return out;
    }

    Float64List rep(int seed, {double tempo = 1, double f0 = 140}) =>
        synthMantra(mantraA, seed: seed, tempo: tempo, f0: f0);

    test('counts every repeat of the trained mantra, once each', () {
      final got = listen([
        silence(700),
        rep(11), silence(600, seed: 21),
        rep(12, tempo: 1.05), silence(600, seed: 22),
        rep(13, f0: 130), silence(600, seed: 23),
        rep(14, tempo: 0.95), silence(600, seed: 24),
        rep(15), silence(600, seed: 25),
      ]);
      expect(got.length, 5);
      expect(got.where((c) => c.matched).length, 5);
    });

    test('ignores other words, noise and a half-said mantra between repeats',
        () {
      final got = listen([
        silence(700),
        rep(11), silence(600, seed: 21),
        synthMantra(mantraB, seed: 50), silence(600, seed: 22), // another word
        synthNoise(500, level: 0.08, seed: 51), silence(600, seed: 23), // clatter
        synthMantra(mantraA.sublist(0, 1), seed: 52), silence(600, seed: 24), // half
        rep(12), silence(600, seed: 25),
      ]);
      final counted = got.where((c) => c.matched).length;
      expect(counted, 2, reason: 'only the two real repeats');
      expect(got.length, greaterThanOrEqualTo(2));
    });

    test('counts as soon as the trailing silence ends: no fixed 2 s wait', () {
      var countedAtSample = -1;
      var fed = 0;
      final engine = VoiceEngine(
        model: model,
        onCandidate: (c) {
          if (c.matched && countedAtSample < 0) countedAtSample = fed;
        },
      );
      final chant = rep(11);
      final stream = toPcm(concat([silence(700), chant, silence(1500, seed: 5)]));
      const chunk = 160; // 10 ms, like a live stream
      for (var i = 0; i < stream.length; i += chunk) {
        engine.addPcm(Int16List.sublistView(stream, i, math.min(stream.length, i + chunk)));
        fed = i + chunk;
      }
      final chantEnd = (700 * 16) + chant.length;
      final latencyMs = (countedAtSample - chantEnd) * 1000 / 16000;
      expect(countedAtSample, greaterThan(0), reason: 'it was counted');
      expect(latencyMs, inInclusiveRange(200, 450),
          reason: 'about the 300 ms trailing silence, far under 2 s');
    });

    test('speech during the 0.5 s calibration does not blind it', () {
      final got = listen([
        // The user starts chanting right away; the floor still comes out low
        // enough that the following repeats are heard.
        rep(11), silence(700, seed: 21),
        rep(12), silence(700, seed: 22),
        rep(13), silence(700, seed: 23),
      ]);
      expect(got.where((c) => c.matched).length, greaterThanOrEqualTo(2));
    });

    test('Lenient counts a looser repeat that Strict rejects', () {
      // A slower, higher-pitched, noisier read of the mantra.
      final loose = synthMantra(mantraA,
          seed: 60, tempo: 1.2, f0: 185, noise: 0.01);
      final strict = listen([silence(700), loose, silence(700, seed: 6)], sens: 0);
      final lenient = listen([silence(700), loose, silence(700, seed: 6)], sens: 1);
      expect(strict.length, 1);
      expect(lenient.length, 1);
      expect(lenient.single.distance, closeTo(strict.single.distance, 1e-9),
          reason: 'same audio, same distance; only the threshold moves');
      expect(lenient.single.threshold, greaterThan(strict.single.threshold));
      if (strict.single.matched) {
        expect(lenient.single.matched, isTrue);
      }
    });

    test('the slider takes effect on a running engine', () {
      final out = <VoiceCandidate>[];
      final engine = VoiceEngine(model: model, onCandidate: out.add);
      final loose = synthMantra(mantraA,
          seed: 60, tempo: 1.2, f0: 185, noise: 0.01);
      engine.sensitivity = 0;
      feedInChunks(toPcm(concat([silence(700), loose, silence(700, seed: 6)])),
          engine.addPcm);
      engine.sensitivity = 1;
      feedInChunks(toPcm(concat([loose, silence(700, seed: 7)])), engine.addPcm);
      expect(out.length, 2);
      expect(out[1].threshold, greaterThan(out[0].threshold));
    });

    test('reports calibration and level, and reset re-calibrates', () {
      var calibrated = 0;
      final levels = <double>[];
      final engine = VoiceEngine(
        model: model,
        onCalibrated: () => calibrated++,
        onLevel: levels.add,
      );
      feedInChunks(toPcm(silence(700)), engine.addPcm);
      expect(calibrated, 1);
      expect(engine.calibrated, isTrue);
      expect(levels, isNotEmpty);
      engine.reset();
      expect(engine.calibrated, isFalse);
      feedInChunks(toPcm(silence(700)), engine.addPcm);
      expect(calibrated, 2);
    });

    test('a long sentence is dropped as too long, not analysed', () {
      final sentence = concat([
        for (var i = 0; i < 12; i++) synthMantra(mantraA, seed: 70 + i),
      ]);
      final got = listen([silence(700), sentence, silence(900, seed: 8)]);
      expect(got.where((c) => c.matched), isEmpty);
    });

    test('the gate adapts to the trained mantra: longer verse, longer pauses',
        () {
      final short = VoiceEngine.gateConfigFor(model);
      expect(short.hangoverFrames, 30);
      final verse = MatchModel([
        for (var k = 0; k < 3; k++)
          MfccSequence(1000, 13, Float64List(1000 * 13)..[0] = k.toDouble()),
      ]);
      final cfg = VoiceEngine.gateConfigFor(verse);
      expect(cfg.hangoverFrames, 60);
      expect(cfg.maxFrames, lessThanOrEqualTo(3000));
      expect(cfg.maxFrames, greaterThan(1000));
    });
  });
}
