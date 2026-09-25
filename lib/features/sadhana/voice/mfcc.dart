import 'dart:math' as math;
import 'dart:typed_data';

import 'package:fftea/fftea.dart';

/// Audio the whole voice pipeline works on: 16 kHz, mono.
const voiceSampleRate = 16000;

/// Coefficients per frame.
const mfccDims = 13;

/// A sequence of MFCC frames (one 13-number row per 10 ms of audio).
///
/// This is what "training" stores instead of audio: small (a 2 s mantra is
/// ~10 KB as float32) and it cannot be turned back into speech.
class MfccSequence {
  MfccSequence(this.frames, this.dims, this.data)
      : assert(data.length == frames * dims);

  final int frames;
  final int dims;

  /// Row-major: frame `f`, coefficient `d` at `f * dims + d`.
  final Float64List data;

  bool get isEmpty => frames == 0;

  /// Length of the audio this was made from (10 ms hop).
  Duration get duration => Duration(milliseconds: frames * 10);

  double at(int frame, int dim) => data[frame * dims + dim];

  /// Little-endian float32, the compact form kept in Hive.
  Uint8List toBytes() {
    final bytes = ByteData(data.length * 4);
    for (var i = 0; i < data.length; i++) {
      bytes.setFloat32(i * 4, data[i], Endian.little);
    }
    return bytes.buffer.asUint8List();
  }

  /// Inverse of [toBytes]; null if [bytes] is not a whole number of frames.
  static MfccSequence? fromBytes(Uint8List bytes, {int dims = mfccDims}) {
    final rowBytes = dims * 4;
    if (bytes.isEmpty || bytes.length % rowBytes != 0) return null;
    final view = ByteData.sublistView(bytes);
    final data = Float64List(bytes.length ~/ 4);
    for (var i = 0; i < data.length; i++) {
      final v = view.getFloat32(i * 4, Endian.little);
      if (!v.isFinite) return null;
      data[i] = v;
    }
    return MfccSequence(data.length ~/ dims, dims, data);
  }
}

/// MFCC front end: 25 ms Hamming frames every 10 ms, 512-point FFT, 26 mel
/// filters, 13 cepstral coefficients (DCT-II), sinusoidal liftering, then
/// per-utterance mean/variance normalisation so the result does not depend
/// on how loud the recording was or on the microphone's frequency response.
///
/// Instances keep scratch buffers, so use one per isolate/thread.
class MfccExtractor {
  MfccExtractor({
    this.sampleRate = voiceSampleRate,
    this.frameLength = 400, // 25 ms at 16 kHz
    this.hop = 160, // 10 ms
    this.fftSize = 512,
    this.melFilters = 26,
    this.coeffs = mfccDims,
    this.lowHz = 100,
    this.preEmphasis = 0.97,
    this.lifter = 22,
  })  : _fft = FFT(fftSize),
        _window = Window.hamming(frameLength),
        _bank = _melBank(sampleRate, fftSize, melFilters, lowHz,
            sampleRate / 2),
        _dct = _dctMatrix(coeffs, melFilters, lifter),
        _frame = Float64List(fftSize),
        _logMel = Float64List(melFilters);

  final int sampleRate;
  final int frameLength;
  final int hop;
  final int fftSize;
  final int melFilters;
  final int coeffs;
  final double lowHz;
  final double preEmphasis;
  final double lifter;

  final FFT _fft;
  final Float64List _window;
  final List<Float64List> _bank;
  final List<Float64List> _dct;
  final Float64List _frame;
  final Float64List _logMel;

  /// Frames [extract] will produce for [sampleCount] samples.
  int frameCountFor(int sampleCount) =>
      sampleCount < frameLength ? 0 : 1 + (sampleCount - frameLength) ~/ hop;

  /// MFCCs of [samples] (each in -1..1). Empty if shorter than one frame.
  MfccSequence extract(Float64List samples, {bool normalize = true}) {
    final n = frameCountFor(samples.length);
    final out = Float64List(n * coeffs);
    final bins = fftSize ~/ 2 + 1;

    for (var f = 0; f < n; f++) {
      final start = f * hop;
      // Pre-emphasis + window, zero-padded up to the FFT size.
      for (var i = 0; i < frameLength; i++) {
        final prev = start + i > 0 ? samples[start + i - 1] : 0.0;
        _frame[i] = (samples[start + i] - preEmphasis * prev) * _window[i];
      }
      for (var i = frameLength; i < fftSize; i++) {
        _frame[i] = 0;
      }
      final spectrum = _fft.realFft(_frame);

      for (var m = 0; m < melFilters; m++) {
        final w = _bank[m];
        var e = 0.0;
        for (var k = 0; k < bins; k++) {
          final wk = w[k];
          if (wk == 0) continue;
          final c = spectrum[k];
          e += wk * (c.x * c.x + c.y * c.y);
        }
        _logMel[m] = math.log(e < 1e-10 ? 1e-10 : e);
      }
      for (var c = 0; c < coeffs; c++) {
        final row = _dct[c];
        var s = 0.0;
        for (var m = 0; m < melFilters; m++) {
          s += row[m] * _logMel[m];
        }
        out[f * coeffs + c] = s;
      }
    }
    final seq = MfccSequence(n, coeffs, out);
    return normalize ? normalized(seq) : seq;
  }
}

/// Loudness normalisation: [samples] scaled so their RMS is [targetRms]
/// (about -20 dBFS), with the gain kept within 1/20..50 so digital silence is
/// not blown up into noise. A soft and a loud repeat of the mantra then reach
/// the front end (and its log floor) the same way.
Float64List loudnessNormalized(Float64List samples, {double targetRms = 0.1}) {
  if (samples.isEmpty) return samples;
  var sum = 0.0;
  for (final v in samples) {
    sum += v * v;
  }
  final rms = math.sqrt(sum / samples.length);
  if (rms < 1e-6) return samples;
  final gain = (targetRms / rms).clamp(0.05, 50.0);
  return Float64List.fromList([for (final v in samples) v * gain]);
}

/// Cepstral mean normalisation: each coefficient minus its mean over the
/// utterance, which removes the microphone's (and the room's) fixed colouring.
MfccSequence cepstralMeanNormalized(MfccSequence s) {
  if (s.frames == 0) return s;
  final d = s.dims;
  final mean = Float64List(d);
  for (var f = 0; f < s.frames; f++) {
    for (var c = 0; c < d; c++) {
      mean[c] += s.data[f * d + c];
    }
  }
  final out = Float64List(s.data.length);
  for (var f = 0; f < s.frames; f++) {
    for (var c = 0; c < d; c++) {
      out[f * d + c] = s.data[f * d + c] - mean[c] / s.frames;
    }
  }
  return MfccSequence(s.frames, d, out);
}

/// Cepstral mean normalisation ([cepstralMeanNormalized]), then each
/// coefficient divided by its (regularised) standard deviation, over the
/// whole utterance.
MfccSequence normalized(MfccSequence s) {
  if (s.frames < 2) return s;
  final d = s.dims;
  final mean = Float64List(d);
  final variance = Float64List(d);
  for (var f = 0; f < s.frames; f++) {
    for (var c = 0; c < d; c++) {
      mean[c] += s.data[f * d + c];
    }
  }
  for (var c = 0; c < d; c++) {
    mean[c] /= s.frames;
  }
  for (var f = 0; f < s.frames; f++) {
    for (var c = 0; c < d; c++) {
      final x = s.data[f * d + c] - mean[c];
      variance[c] += x * x;
    }
  }
  var avg = 0.0;
  for (var c = 0; c < d; c++) {
    variance[c] /= s.frames;
    avg += variance[c];
  }
  // A coefficient that barely moves (pure tone, digital silence) must not be
  // blown up into noise: regularise with a fraction of the average variance.
  final eps = 0.01 * (avg / d) + 1e-9;
  final out = Float64List(s.data.length);
  for (var f = 0; f < s.frames; f++) {
    for (var c = 0; c < d; c++) {
      out[f * d + c] = (s.data[f * d + c] - mean[c]) / math.sqrt(variance[c] + eps);
    }
  }
  return MfccSequence(s.frames, d, out);
}

double _hzToMel(double hz) => 2595 * math.log(1 + hz / 700) / math.ln10;
double _melToHz(double mel) => 700 * (math.pow(10, mel / 2595) - 1);

/// Triangular filters, evenly spaced on the mel scale, one weight per FFT bin.
List<Float64List> _melBank(
    int sampleRate, int fftSize, int filters, double lowHz, double highHz) {
  final bins = fftSize ~/ 2 + 1;
  final lowMel = _hzToMel(lowHz);
  final highMel = _hzToMel(highHz);
  final points = [
    for (var i = 0; i < filters + 2; i++)
      _melToHz(lowMel + (highMel - lowMel) * i / (filters + 1)),
  ];
  return [
    for (var m = 1; m <= filters; m++)
      Float64List.fromList([
        for (var k = 0; k < bins; k++)
          () {
            final hz = k * sampleRate / fftSize;
            final left = points[m - 1], mid = points[m], right = points[m + 1];
            if (hz <= left || hz >= right) return 0.0;
            return hz <= mid
                ? (hz - left) / (mid - left)
                : (right - hz) / (right - mid);
          }(),
      ]),
  ];
}

/// Orthonormal DCT-II rows with the HTK sinusoidal lifter folded in.
List<Float64List> _dctMatrix(int coeffs, int inputs, double lifter) => [
      for (var c = 0; c < coeffs; c++)
        Float64List.fromList([
          for (var m = 0; m < inputs; m++)
            math.sqrt((c == 0 ? 1.0 : 2.0) / inputs) *
                math.cos(math.pi * c * (m + 0.5) / inputs) *
                (lifter > 0 ? 1 + lifter / 2 * math.sin(math.pi * c / lifter) : 1),
        ]),
    ];

/// Weights of the static, delta and delta-delta parts in [withDeltas].
const deltaWeight = 0.4;
const deltaDeltaWeight = 0.25;

/// The matching features of a (normalised) static MFCC sequence: the statics,
/// their deltas (how each coefficient is changing, a ±[window]-frame
/// regression) and delta-deltas (how that change is changing), 3 × dims per
/// frame. The deltas are variance-normalised per utterance like the statics,
/// weighted by [deltaWeight] / [deltaDeltaWeight], and the whole row scaled so
/// a frame distance stays on the same scale as the statics alone (the
/// thresholds were set on that scale).
///
/// Templates are stored as statics only (13 per frame) and extended here, so
/// trainings saved before deltas existed keep working.
MfccSequence withDeltas(MfccSequence s, {int window = 2}) {
  final n = s.frames, d = s.dims;
  if (n == 0) return MfccSequence(0, d * 3, Float64List(0));
  final delta = _regression(s.data, n, d, window);
  final ddelta = _regression(delta, n, d, window);
  final dn = _varianceNormalized(delta, n, d);
  final ddn = _varianceNormalized(ddelta, n, d);
  final scale =
      1 / math.sqrt(1 + deltaWeight * deltaWeight + deltaDeltaWeight * deltaDeltaWeight);
  final out = Float64List(n * d * 3);
  for (var f = 0; f < n; f++) {
    for (var c = 0; c < d; c++) {
      out[f * d * 3 + c] = s.data[f * d + c] * scale;
      out[f * d * 3 + d + c] = dn[f * d + c] * deltaWeight * scale;
      out[f * d * 3 + 2 * d + c] = ddn[f * d + c] * deltaDeltaWeight * scale;
    }
  }
  return MfccSequence(n, d * 3, out);
}

/// The standard delta: sum_k k·(x[t+k] − x[t−k]) / (2·sum_k k²), edges clamped.
Float64List _regression(Float64List x, int n, int d, int window) {
  final out = Float64List(n * d);
  var denom = 0.0;
  for (var k = 1; k <= window; k++) {
    denom += 2 * k * k;
  }
  for (var f = 0; f < n; f++) {
    for (var c = 0; c < d; c++) {
      var acc = 0.0;
      for (var k = 1; k <= window; k++) {
        final a = math.min(n - 1, f + k), b = math.max(0, f - k);
        acc += k * (x[a * d + c] - x[b * d + c]);
      }
      out[f * d + c] = acc / denom;
    }
  }
  return out;
}

Float64List _varianceNormalized(Float64List x, int n, int d) {
  final out = Float64List(x.length);
  if (n < 2) return out;
  final mean = Float64List(d), variance = Float64List(d);
  for (var f = 0; f < n; f++) {
    for (var c = 0; c < d; c++) {
      mean[c] += x[f * d + c] / n;
    }
  }
  var avg = 0.0;
  for (var f = 0; f < n; f++) {
    for (var c = 0; c < d; c++) {
      final v = x[f * d + c] - mean[c];
      variance[c] += v * v / n;
    }
  }
  for (var c = 0; c < d; c++) {
    avg += variance[c] / d;
  }
  final eps = 0.01 * avg + 1e-9;
  for (var f = 0; f < n; f++) {
    for (var c = 0; c < d; c++) {
      out[f * d + c] = (x[f * d + c] - mean[c]) / math.sqrt(variance[c] + eps);
    }
  }
  return out;
}

/// Frames [from, to) of [s], normalised again on their own (a segment is
/// matched as its own utterance).
MfccSequence segmentOf(MfccSequence s, int from, int to) {
  final d = s.dims;
  final part = MfccSequence(
      to - from, d, Float64List.sublistView(s.data, from * d, to * d));
  return normalized(MfccSequence(part.frames, d, Float64List.fromList(part.data)));
}

/// [s] without the quiet frames at its start and end (lead-in and trailing
/// silence), keeping [margin] frames of each: the voiced part is what is
/// matched, whatever padding the recording or the live detector left around
/// it. A frame is quiet when its c0 (log energy, normalised) is in the lowest
/// [quietShare] of the utterance's range. Short or flat input is returned as is.
MfccSequence trimmedToVoice(MfccSequence s,
    {double quietShare = 0.25, int margin = 2}) {
  if (s.frames < 10) return s;
  var lo = double.infinity, hi = -double.infinity;
  for (var f = 0; f < s.frames; f++) {
    final c0 = s.at(f, 0);
    if (c0 < lo) lo = c0;
    if (c0 > hi) hi = c0;
  }
  if (hi - lo < 1e-6) return s;
  final cut = lo + (hi - lo) * quietShare;
  var first = 0, last = s.frames - 1;
  while (first < last && s.at(first, 0) < cut) {
    first++;
  }
  while (last > first && s.at(last, 0) < cut) {
    last--;
  }
  first = math.max(0, first - margin);
  last = math.min(s.frames - 1, last + margin);
  if (last - first + 1 < s.frames ~/ 3) return s; // most of it is "quiet": keep
  if (first == 0 && last == s.frames - 1) return s;
  final d = s.dims;
  return MfccSequence(last - first + 1, d,
      Float64List.fromList(s.data.sublist(first * d, (last + 1) * d)));
}
