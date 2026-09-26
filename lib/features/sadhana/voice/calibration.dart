import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../services/pcm_input.dart';
import 'match_model.dart';
import 'mfcc.dart';
import 'utterance_detector.dart';
import 'voice_engine.dart';
import 'voice_trainer.dart' show voiceStartMessage;

/// Repetitions asked for by the calibration ("Chant your mantra 11 times").
const calibrationReps = 11;

/// Room sound recorded first (the user stays quiet), in ms.
const calibrationQuietMs = 2000;

/// The threshold that counts every one of [same] (the user's own repeats,
/// just chanted) and none of [different] (room noise / silence), from their
/// DTW distances to the trained mantra.
///
/// With a clear gap it sits a third of the way from the loudest "same" toward
/// the nearest "different" (misses cost more than a rare false count, and the
/// Lenient side of the slider is still there). Without anything "different"
/// it is 15% above the highest "same". If the two overlap, noise wins: the
/// threshold stays just under the nearest noise, so the room never counts.
/// Null if nothing usable was heard.
double? calibrateThreshold({
  required List<double> same,
  required List<double> different,
}) {
  final s = same.where((d) => d.isFinite).toList()..sort();
  if (s.isEmpty) return null;
  final sameMax = s.last;
  final diffMin = different.where((d) => d.isFinite).fold(double.infinity, math.min);
  double t;
  if (!diffMin.isFinite) {
    t = sameMax * 1.15;
  } else if (sameMax < diffMin) {
    t = sameMax + (diffMin - sameMax) / 3;
  } else {
    t = math.max(s[s.length ~/ 2], diffMin * 0.95);
  }
  return t.clamp(MatchModel.minThreshold * 0.5, MatchModel.maxThreshold);
}

/// Distances from windows of room sound to the trained mantra: what "not the
/// mantra" scores here. [quiet] is MFCC of the recorded room sound; windows
/// are one trained length long, half overlapping.
List<double> noiseDistances(MatchModel model, MfccSequence quiet) {
  final len = model.medianFrames;
  if (quiet.frames == 0) return const [];
  if (quiet.frames <= len) return [model.distanceTo(quiet)];
  return [
    for (var start = 0; start + len <= quiet.frames; start += math.max(1, len ~/ 2))
      model.distanceTo(segmentOf(quiet, start, start + len)),
  ];
}

enum CalibrationPhase {
  idle,

  /// Opening the microphone.
  starting,

  /// Recording room sound: stay quiet.
  quiet,

  /// Waiting for the repetitions.
  chanting,

  /// All heard; [VoiceCalibrator.threshold] is ready to save.
  done,

  /// The microphone could not be used.
  error,
}

/// One repetition heard during calibration.
class HeardRep {
  const HeardRep(this.distance, {required this.countedBefore});

  /// DTW distance to the trained mantra.
  final double distance;

  /// Whether it would have counted with the threshold used until now.
  final bool countedBefore;
}

/// "Chant your mantra 11 times now": records a moment of room sound, then
/// listens for the repetitions, shows each as it is heard, and works out the
/// threshold that counts them and not the room. Everything is analysed as it
/// arrives; no audio is kept.
class VoiceCalibrator extends ChangeNotifier {
  VoiceCalibrator({
    required this._input,
    required this.model,
    this.reps = calibrationReps,
  }) : _extractor = MfccExtractor() {
    _detector = UtteranceDetector(
      config: VoiceEngine.gateConfigFor(model),
      onUtterance: _onUtterance,
      onLevel: (db) {
        _level = levelFromDb(db);
        notifyListeners();
      },
    );
  }

  double _level = 0;

  /// Live loudness 0..1 for a level meter (can the phone hear you?).
  double get level => _level;

  final PcmInput _input;
  final MfccExtractor _extractor;
  final MatchModel model;
  final int reps;
  late final UtteranceDetector _detector;

  CalibrationPhase _phase = CalibrationPhase.idle;
  final List<HeardRep> _heard = [];
  int _ignored = 0;
  List<double> _noise = const [];
  double? _threshold;
  VoiceStartResult? _startResult;
  String? _error;
  bool _disposed = false;

  /// Room sound, only until it is analysed (then dropped).
  final List<Int16List> _quietAudio = [];
  int _quietSamples = 0;

  CalibrationPhase get phase => _phase;
  List<HeardRep> get heard => List.unmodifiable(_heard);

  /// Sounds heard that were not one repetition (too short or too long).
  int get ignored => _ignored;
  List<double> get noise => _noise;

  /// The calibrated threshold (when [phase] is done).
  double? get threshold => _threshold;
  VoiceStartResult? get startResult => _startResult;
  String? get error => _error;

  bool get listening =>
      _phase == CalibrationPhase.quiet || _phase == CalibrationPhase.chanting;

  Future<VoiceStartResult> start() async {
    if (listening || _phase == CalibrationPhase.starting) {
      return VoiceStartResult.started;
    }
    _heard.clear();
    _ignored = 0;
    _noise = const [];
    _threshold = null;
    _quietAudio.clear();
    _quietSamples = 0;
    _detector.reset();
    _set(CalibrationPhase.starting);
    final r = await _input.start(onSamples: _onPcm, onError: (msg) {
      unawaited(_input.stop());
      _error = msg;
      _set(CalibrationPhase.error);
    });
    _startResult = r;
    if (_disposed) {
      unawaited(_input.stop());
      return r;
    }
    if (r != VoiceStartResult.started) {
      _error = voiceStartMessage(r);
      _set(CalibrationPhase.error);
      return r;
    }
    _set(CalibrationPhase.quiet);
    return r;
  }

  Future<void> stop() async {
    await _input.stop();
    _quietAudio.clear();
    if (listening || _phase == CalibrationPhase.starting) {
      _set(CalibrationPhase.idle);
    }
  }

  void _onPcm(Int16List pcm) {
    if (!listening) return;
    if (_phase == CalibrationPhase.quiet) {
      _quietAudio.add(Int16List.fromList(pcm));
      _quietSamples += pcm.length;
      _detector.addSamples(pcm); // learns the noise floor meanwhile
      if (_quietSamples >= calibrationQuietMs * voiceSampleRate ~/ 1000) {
        _analyseQuiet();
        _set(CalibrationPhase.chanting);
      }
      return;
    }
    _detector.addSamples(pcm);
  }

  void _analyseQuiet() {
    final samples = Float64List(_quietSamples);
    var at = 0;
    for (final chunk in _quietAudio) {
      for (final v in chunk) {
        samples[at++] = v / 32768.0;
      }
    }
    _quietAudio.clear(); // no audio is kept
    _noise = noiseDistances(
        model, _extractor.extract(loudnessNormalized(samples)));
  }

  void _onUtterance(Utterance u) {
    if (_phase != CalibrationPhase.chanting) return;
    if (u.forced) {
      _ignored++;
      notifyListeners();
      return;
    }
    final mfcc = _extractor.extract(loudnessNormalized(u.samples));
    if (!model.lengthPlausible(mfcc.frames)) {
      _ignored++;
      notifyListeners();
      return;
    }
    final d = model.distanceTo(mfcc);
    _heard.add(HeardRep(d,
        countedBefore: d <= model.thresholdFor(defaultVoiceSensitivity)));
    if (_heard.length >= reps) {
      unawaited(_input.stop());
      _threshold = calibrateThreshold(
          same: [for (final h in _heard) h.distance], different: _noise);
      _set(CalibrationPhase.done);
      return;
    }
    notifyListeners();
  }

  void _set(CalibrationPhase p) {
    _phase = p;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_input.stop());
    super.dispose();
  }
}
