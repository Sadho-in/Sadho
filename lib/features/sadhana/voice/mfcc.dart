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

/// Subtracts each coefficient's mean and divides by its (regularised) standard
/// deviation, over the whole utterance.
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
