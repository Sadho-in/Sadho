import 'dart:math' as math;
import 'dart:typed_data';

import 'package:advance_calendar/features/sadhana/voice/mfcc.dart';

/// One vowel-like syllable: a harmonic tone shaped by two formants.
class Syllable {
  const Syllable(this.f1, this.f2, [this.ms = 220]);
  final double f1;
  final double f2;
  final double ms;
}

// Made-up "mantras": different vowel sequences, so different spectral paths.
const mantraA = [Syllable(700, 1200), Syllable(300, 2300), Syllable(500, 900, 260)];
const mantraB = [Syllable(350, 800), Syllable(900, 1500), Syllable(400, 2000), Syllable(650, 1100)];
const mantraC = [Syllable(300, 900, 400), Syllable(800, 2500, 300)];

/// A voiced "chant" of [syllables]. [tempo] > 1 is slower, [f0] the pitch,
/// [gain] the loudness (peak ≈ gain), [noise] the background noise level.
Float64List synthMantra(
  List<Syllable> syllables, {
  double tempo = 1.0,
  double f0 = 140,
  double gain = 0.3,
  double noise = 0.002,
  int seed = 1,
}) {
  final rng = math.Random(seed);
  final gap = (0.06 * voiceSampleRate * tempo).round();
  final out = <double>[];
  var phase = 0.0;
  for (var s = 0; s < syllables.length; s++) {
    final syl = syllables[s];
    final n = (syl.ms / 1000 * voiceSampleRate * tempo).round();
    // A little natural pitch drift, different on every repeat.
    final drift = 1 + 0.04 * (rng.nextDouble() - 0.5);
    final base = f0 * drift;
    final harmonics = <double>[];
    for (var k = 1; base * k < 4500; k++) {
      final f = base * k;
      double bump(double centre, double bw) =>
          math.exp(-math.pow((f - centre) / bw, 2).toDouble());
      harmonics.add(bump(syl.f1, 150) + 0.6 * bump(syl.f2, 250) + 0.02);
    }
    for (var i = 0; i < n; i++) {
      final t = i / voiceSampleRate;
      final attack = math.min(1.0, i / (0.02 * voiceSampleRate));
      final decay = math.min(1.0, (n - i) / (0.04 * voiceSampleRate));
      final env = attack * decay;
      var v = 0.0;
      for (var k = 0; k < harmonics.length; k++) {
        v += harmonics[k] * math.sin(2 * math.pi * base * (k + 1) * t + phase * (k + 1));
      }
      out.add(v * env);
    }
    phase += 0.7;
    if (s < syllables.length - 1) out.addAll(List.filled(gap, 0.0));
  }
  var peak = 1e-9;
  for (final v in out) {
    peak = math.max(peak, v.abs());
  }
  return Float64List.fromList([
    for (final v in out) v / peak * gain + noise * (rng.nextDouble() - 0.5) * 2,
  ]);
}

/// A pure tone: a signal simple enough to reason about exactly.
Float64List tone(double hz, {int ms = 500, double amp = 0.3}) =>
    Float64List.fromList([
      for (var i = 0; i < ms * voiceSampleRate ~/ 1000; i++)
        amp * math.sin(2 * math.pi * hz * i / voiceSampleRate),
    ]);

/// A steady hiss.
Float64List synthNoise(int ms, {double level = 0.003, int seed = 7}) {
  final rng = math.Random(seed);
  return Float64List.fromList([
    for (var i = 0; i < ms * voiceSampleRate ~/ 1000; i++)
      level * (rng.nextDouble() - 0.5) * 2,
  ]);
}

/// Quiet room noise.
Float64List silence(int ms, {double noise = 0.002, int seed = 3}) =>
    synthNoise(ms, level: noise, seed: seed);

Float64List concat(List<Float64List> parts) {
  final out = Float64List(parts.fold(0, (a, p) => a + p.length));
  var at = 0;
  for (final p in parts) {
    out.setRange(at, at + p.length, p);
    at += p.length;
  }
  return out;
}

/// What the microphone would deliver: 16-bit PCM.
Int16List toPcm(Float64List x) => Int16List.fromList([
      for (final v in x) (v.clamp(-1.0, 1.0) * 32767).round(),
    ]);

/// Feeds [pcm] to [sink] in mic-sized chunks (uneven, like a real stream).
void feedInChunks(Int16List pcm, void Function(Int16List) sink,
    {int chunk = 1600}) {
  for (var i = 0; i < pcm.length; i += chunk) {
    sink(Int16List.sublistView(pcm, i, math.min(pcm.length, i + chunk)));
    chunk = chunk == 1600 ? 1333 : 1600;
  }
}
