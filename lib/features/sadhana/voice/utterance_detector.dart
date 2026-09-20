import 'dart:math' as math;
import 'dart:typed_data';

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

  /// Never trigger below this level, however quiet the room is.
  final double minOnsetDb;

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

/// Frame-level speech gate. Feed it one loudness value (dB) per 10 ms frame.
///
/// 1. **Calibrating**: the first frames set the noise floor (a low quantile,
///    so speaking during calibration does not ruin it).
/// 2. **Idle**: [GateConfig.onsetFrames] frames in a row above
///    noise + [GateConfig.onsetMarginDb] start an utterance. While idle the
///    floor slowly follows the room noise.
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

  /// Level a frame must exceed to start an utterance.
  double get onsetDb => math.max(
      config.minOnsetDb, _noiseDb + math.max(config.onsetMarginDb, 3 * _spreadDb));

  /// Level below which a frame counts as silence while an utterance is active.
  double get offsetDb => math.max(config.minOnsetDb - 3,
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

  GateEvent step(double db) {
    _frame++;
    switch (_state) {
      case _State.calibrating:
        _calibration.add(db);
        if (_calibration.length < config.calibrationFrames) return GateEvent.none;
        _finishCalibration();
        return GateEvent.calibrated;

      case _State.idle:
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

/// Turns a PCM16 16 kHz stream into [Utterance]s: computes 10 ms loudness
/// values for an [EnergyGate] and keeps the audio of the active utterance.
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

    final event = _gate.step(db);
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
