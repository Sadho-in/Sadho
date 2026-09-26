import 'dart:math' as math;
import 'dart:typed_data';

import 'package:fftea/fftea.dart';

/// A frame's loudness (dBFS) as 0..1 for a level meter: -70 dB (a quiet
/// room on a phone's own microphone) is empty, -15 dB is full. Wide enough
/// that a soft chant on a built-in mic still moves the bar.
double levelFromDb(double db) => ((db + 70) / 55).clamp(0.0, 1.0);

/// Samples per detector frame: 10 ms at 16 kHz.
const gateFrameSamples = 160;

/// Tuning for [EnergyGate]. All durations are in 10 ms frames.
class GateConfig {
  const GateConfig({
    this.calibrationFrames = 50,
    this.onsetFrames = 3,
    this.hangoverFrames = 30,
    this.minVoicedFrames = 20,
    this.maxFrames = 600,
    this.preRollFrames = 12,
    this.trailKeepFrames = 8,
    this.onsetMarginDb = 9,
    this.offsetMarginDb = 5,
    this.minOnsetDb = -50,
    this.quietMicFloorDb = -68,
    this.minOnsetAboveNoiseDb = 15,
    this.maxOnsetZcr = 0.3,
    this.maxOnsetFlatness = 0.2,
  });

  /// Noise-floor calibration at the start (50 = 0.5 s).
  final int calibrationFrames;

  /// Consecutive loud frames that start an utterance (30 ms).
  final int onsetFrames;

  /// Consecutive quiet frames that end it: the trailing silence, which is
  /// also the latency between the last syllable and the count (300 ms).
  final int hangoverFrames;

  /// Fewer loud frames than this is a click/cough, not a mantra (200 ms).
  final int minVoicedFrames;

  /// Longest candidate; longer speech is cut here and the rest ignored until
  /// it goes quiet (6 s).
  final int maxFrames;

  /// Audio kept from before the onset so a soft first consonant survives.
  final int preRollFrames;

  /// Trailing silence kept on the emitted audio.
  final int trailKeepFrames;

  /// dB above the noise floor that counts as speech starting / continuing.
  /// Ending uses the lower margin, so a fading syllable is not cut short.
  final double onsetMarginDb;
  final double offsetMarginDb;

  /// The lowest level that can start an utterance, before the noise floor
  /// is known (and the most it is ever raised to by a quiet room).
  final double minOnsetDb;

  /// A quiet built-in microphone (VOICE_RECOGNITION, no automatic gain)
  /// records a soft chant well under [minOnsetDb]. Once the noise floor is
  /// measured, the minimum follows it: noise + [minOnsetAboveNoiseDb], but
  /// never below [quietMicFloorDb] (digital silence must not make any
  /// whisper an utterance). The voice cues (few zero crossings, a peaky
  /// spectrum) still decide whether a loud frame can start one.
  final double quietMicFloorDb;
  final double minOnsetAboveNoiseDb;

  /// A frame can start an utterance only if it sounds like voice: few zero
  /// crossings (a hiss or a breath crosses zero about every other sample) and
  /// a peaky, harmonic spectrum (spectral flatness near 0; noise is near 0.5).
  final double maxOnsetZcr;
  final double maxOnsetFlatness;

  GateConfig copyWith({int? hangoverFrames, int? maxFrames}) => GateConfig(
        calibrationFrames: calibrationFrames,
        onsetFrames: onsetFrames,
        hangoverFrames: hangoverFrames ?? this.hangoverFrames,
        minVoicedFrames: minVoicedFrames,
        maxFrames: maxFrames ?? this.maxFrames,
        preRollFrames: preRollFrames,
        trailKeepFrames: trailKeepFrames,
        onsetMarginDb: onsetMarginDb,
        offsetMarginDb: offsetMarginDb,
        minOnsetDb: minOnsetDb,
        quietMicFloorDb: quietMicFloorDb,
        minOnsetAboveNoiseDb: minOnsetAboveNoiseDb,
        maxOnsetZcr: maxOnsetZcr,
        maxOnsetFlatness: maxOnsetFlatness,
      );
}

enum GateEvent {
  none,

  /// The noise floor is now known; detection is live.
  calibrated,

  /// Speech began at [EnergyGate.startFrame].
  start,

  /// Speech ended (trailing silence): a candidate is complete.
  end,

  /// Speech ended but was too short to be a mantra.
  tooShort,

  /// Speech hit the length cap and was cut; the rest is ignored until quiet.
  forcedEnd,
}

/// Frame-level speech gate. Feed it one loudness value (dB) per 10 ms frame,
/// and whether the frame sounds like voice ([FrameCues.speechLike]).
///
/// 1. **Calibrating**: the first frames set the noise floor (a low quantile,
///    so speaking during calibration does not ruin it).
/// 2. **Idle**: [GateConfig.onsetFrames] frames in a row above
///    noise + [GateConfig.onsetMarginDb] that sound like voice start an
///    utterance (a breath or a noise burst is loud but not voice, so it never
///    starts one). While idle the floor adapts to the room: it follows quiet
///    frames, and rises (slowly) under loud noise that is not voice.
/// 3. **Active**: it ends after [GateConfig.hangoverFrames] quiet frames, or
///    is cut at [GateConfig.maxFrames].
class EnergyGate {
  EnergyGate([this.config = const GateConfig()]);

  final GateConfig config;

  final List<double> _calibration = [];
  bool _calibrated = false;
  double _noiseDb = -100;
  double _spreadDb = 0;

  _State _state = _State.calibrating;
  int _frame = -1;
  int _run = 0; // consecutive loud frames while idle
  int _quiet = 0; // consecutive quiet frames while active / skipping
  int _voiced = 0;

  int _startFrame = 0;
  int _lastVoicedFrame = 0;

  bool get calibrated => _calibrated;
  double get noiseDb => _noiseDb;

  /// The absolute minimum for an onset: [GateConfig.minOnsetDb] until the
  /// noise floor is measured, then adapted to it (a quieter microphone gets
  /// a lower minimum, see [GateConfig.quietMicFloorDb]).
  double get minOnsetDb => _calibrated
      ? (_noiseDb + config.minOnsetAboveNoiseDb)
          .clamp(config.quietMicFloorDb, config.minOnsetDb)
      : config.minOnsetDb;

  /// Level a frame must exceed to start an utterance.
  double get onsetDb => math.max(
      minOnsetDb, _noiseDb + math.max(config.onsetMarginDb, 3 * _spreadDb));

  /// Level below which a frame counts as silence while an utterance is active.
  double get offsetDb => math.max(minOnsetDb - 3,
      _noiseDb + math.max(config.offsetMarginDb, 2 * _spreadDb));

  bool get active => _state == _State.active;

  /// First frame of the utterance (the one where the loud run began).
  int get startFrame => _startFrame;

  /// Last frame that was still loud.
  int get lastVoicedFrame => _lastVoicedFrame;

  /// Frames processed so far minus one (index of the latest frame).
  int get frame => _frame;

  void reset() {
    _calibration.clear();
    _calibrated = false;
    _state = _State.calibrating;
    _frame = -1;
    _run = _quiet = _voiced = 0;
  }

  GateEvent step(double db, {bool speechLike = true}) {
    _frame++;
    switch (_state) {
      case _State.calibrating:
        _calibration.add(db);
        if (_calibration.length < config.calibrationFrames) return GateEvent.none;
        _finishCalibration();
        return GateEvent.calibrated;

      case _State.idle:
        if (db > onsetDb && !speechLike) {
          // Loud but not voice (a breath, a fan, a clatter): no onset, and the
          // floor creeps up toward a noise that persists.
          _run = 0;
          _noiseDb += 0.03 * (db - _noiseDb);
          return GateEvent.none;
        }
        if (db > onsetDb) {
          if (++_run >= config.onsetFrames) {
            _state = _State.active;
            _startFrame = _frame - _run + 1;
            _lastVoicedFrame = _frame;
            _voiced = _run;
            _quiet = 0;
            return GateEvent.start;
          }
        } else {
          _run = 0;
          // Track the room: fall fast (so a floor learned while the user was
          // already chanting drops to the real room level within moments),
          // rise slowly (a fan or traffic, never speech).
          _noiseDb += (db < _noiseDb ? 0.25 : 0.02) * (db - _noiseDb);
          _spreadDb *= 0.99;
        }
        return GateEvent.none;

      case _State.active:
        if (db > offsetDb) {
          _quiet = 0;
          _voiced++;
          _lastVoicedFrame = _frame;
        } else {
          _quiet++;
        }
        if (_frame - _startFrame + 1 >= config.maxFrames) {
          _state = _State.skipping;
          _quiet = db > offsetDb ? 0 : _quiet;
          return GateEvent.forcedEnd;
        }
        if (_quiet >= config.hangoverFrames) {
          _state = _State.idle;
          _run = 0;
          return _voiced >= config.minVoicedFrames
              ? GateEvent.end
              : GateEvent.tooShort;
        }
        return GateEvent.none;

      case _State.skipping:
        _quiet = db > offsetDb ? 0 : _quiet + 1;
        if (_quiet >= 10) {
          _state = _State.idle;
          _run = 0;
        }
        return GateEvent.none;
    }
  }

  void _finishCalibration() {
    final sorted = [..._calibration]..sort();
    // Lower quartile: robust against speech during calibration.
    _noiseDb = sorted[(sorted.length * 0.25).floor()];
    final lower = sorted.sublist(0, math.max(2, (sorted.length * 0.75).floor()));
    final mean = lower.reduce((a, b) => a + b) / lower.length;
    final variance =
        lower.fold<double>(0, (s, x) => s + (x - mean) * (x - mean)) / lower.length;
    _spreadDb = math.sqrt(variance);
    _calibrated = true;
    _state = _State.idle;
  }
}

enum _State { calibrating, idle, active, skipping }

/// One detected candidate utterance.
class Utterance {
  const Utterance(this.samples, {required this.forced});

  /// Mono samples in -1..1, including a little pre-roll and trailing silence.
  final Float64List samples;

  /// Cut at the length cap rather than ended by silence.
  final bool forced;

  Duration get duration =>
      Duration(microseconds: samples.length * 1000000 ~/ 16000);
}

/// Voice cues of one 10 ms frame: zero-crossing rate and spectral flatness.
class FrameCues {
  FrameCues._(this.zcr, this.flatness);

  /// Share of neighbouring samples that change sign (0..1).
  final double zcr;

  /// Geometric / arithmetic mean of the power spectrum over 125 Hz..4 kHz:
  /// near 0 for a voiced, harmonic sound, about 0.5 for white noise.
  final double flatness;

  bool speechLike(GateConfig c) =>
      zcr <= c.maxOnsetZcr && flatness <= c.maxOnsetFlatness;

  static final _fft = FFT(256);
  static final _buffer = Float64List(256);

  static FrameCues of(Float64List frame) {
    var crossings = 0;
    for (var i = 1; i < frame.length; i++) {
      if ((frame[i] >= 0) != (frame[i - 1] >= 0)) crossings++;
    }
    final n = math.min(frame.length, 256);
    for (var i = 0; i < 256; i++) {
      _buffer[i] = i < n
          ? frame[i] * (0.54 - 0.46 * math.cos(2 * math.pi * i / math.max(1, n - 1)))
          : 0;
    }
    final spectrum = _fft.realFft(_buffer);
    var logSum = 0.0, sum = 0.0, bins = 0;
    for (var k = 2; k <= 64; k++) {
      final c = spectrum[k];
      final p = c.x * c.x + c.y * c.y + 1e-12;
      logSum += math.log(p);
      sum += p;
      bins++;
    }
    final flatness = math.exp(logSum / bins) / (sum / bins);
    return FrameCues._(
        frame.length < 2 ? 0 : crossings / (frame.length - 1), flatness);
  }
}

/// Turns a PCM16 16 kHz stream into [Utterance]s: computes 10 ms loudness
/// values and voice cues ([FrameCues]) for an [EnergyGate] and keeps the audio
/// of the active utterance.
class UtteranceDetector {
  UtteranceDetector({
    GateConfig config = const GateConfig(),
    this.onUtterance,
    this.onCalibrated,
    this.onTooShort,
    this.onLevel,
  }) : _gate = EnergyGate(config);

  final void Function(Utterance u)? onUtterance;
  final void Function(double noiseDb)? onCalibrated;
  final void Function()? onTooShort;

  /// Loudness in dB (about -100 silent .. 0 full scale), roughly every 50 ms.
  final void Function(double db)? onLevel;

  final EnergyGate _gate;

  /// Samples not yet forming a whole frame.
  final Float64List _partial = Float64List(gateFrameSamples);
  int _partialLen = 0;

  /// The most recent frames (pre-roll source).
  final List<Float64List> _ring = [];

  /// Frames of the active utterance (pre-roll included).
  final List<Float64List> _current = [];

  GateConfig get config => _gate.config;
  EnergyGate get gate => _gate;

  void reset() {
    _gate.reset();
    _partialLen = 0;
    _ring.clear();
    _current.clear();
  }

  void addSamples(Int16List pcm) {
    var i = 0;
    while (i < pcm.length) {
      final take = math.min(gateFrameSamples - _partialLen, pcm.length - i);
      for (var k = 0; k < take; k++) {
        _partial[_partialLen + k] = pcm[i + k] / 32768.0;
      }
      _partialLen += take;
      i += take;
      if (_partialLen == gateFrameSamples) {
        _onFrame(Float64List.fromList(_partial));
        _partialLen = 0;
      }
    }
  }

  void _onFrame(Float64List frame) {
    var energy = 0.0;
    for (final s in frame) {
      energy += s * s;
    }
    final db = 10 * math.log(energy / frame.length + 1e-10) / math.ln10;
    final cfg = _gate.config;

    _ring.add(frame);
    final keep = cfg.preRollFrames + cfg.onsetFrames + 1;
    if (_ring.length > keep) _ring.removeAt(0);

    // The voice cues matter only for a loud frame that could start speech.
    final speechLike = _gate.active || db <= _gate.onsetDb
        ? true
        : FrameCues.of(frame).speechLike(cfg);
    final event = _gate.step(db, speechLike: speechLike);
    if (_gate.frame % 5 == 0) onLevel?.call(db);

    switch (event) {
      case GateEvent.calibrated:
        onCalibrated?.call(_gate.noiseDb);
      case GateEvent.start:
        // Pre-roll + the loud run that triggered the start.
        final take = math.min(_ring.length, cfg.preRollFrames + cfg.onsetFrames);
        _current
          ..clear()
          ..addAll(_ring.sublist(_ring.length - take));
      case GateEvent.none:
        if (_gate.active) _current.add(frame);
      case GateEvent.end:
        _current.add(frame);
        _emit(forced: false);
      case GateEvent.forcedEnd:
        _current.add(frame);
        _emit(forced: true);
      case GateEvent.tooShort:
        _current.clear();
        onTooShort?.call();
    }
  }

  void _emit({required bool forced}) {
    final cfg = _gate.config;
    // Trim the trailing silence down to a short tail.
    final loudEnd = _gate.lastVoicedFrame;
    final extra = _gate.frame - loudEnd;
    final drop = forced ? 0 : math.max(0, extra - cfg.trailKeepFrames);
    final frames = _current.sublist(0, _current.length - drop);
    _current.clear();
    final out = Float64List(frames.length * gateFrameSamples);
    for (var f = 0; f < frames.length; f++) {
      out.setRange(f * gateFrameSamples, (f + 1) * gateFrameSamples, frames[f]);
    }
    onUtterance?.call(Utterance(out, forced: forced));
  }
}
