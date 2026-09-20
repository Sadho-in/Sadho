import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/pcm_input.dart';
import 'dtw.dart';
import 'match_model.dart';
import 'mfcc.dart';
import 'utterance_detector.dart';

enum TrainerPhase {
  /// Not listening yet.
  idle,

  /// Opening the microphone (and its permission prompt).
  starting,

  /// Measuring the room's noise (~0.5 s). Stay quiet.
  calibrating,

  /// Waiting for the next recording.
  waiting,

  /// All recordings captured; the microphone is off.
  complete,

  /// The microphone could not be used; see [VoiceTrainer.message].
  error,
}

/// Records a mantra 3-7 times and turns each recording into an MFCC template.
/// Only features are kept; the audio is thrown away as soon as it is analysed.
///
/// Pass [existing] to add to a mantra that is already trained: those templates
/// count toward the total and toward the consistency check, are never removed
/// by Undo/Start over, and only the new recordings are ever discarded.
class VoiceTrainer extends ChangeNotifier {
  VoiceTrainer({
    required this._input,
    List<MfccSequence> existing = const [],
    this.maximum = maxTrainingSamples,
    this.minimum = minTrainingSamples,
  })  : _existing = existing.length,
        _extractor = MfccExtractor() {
    _samples.addAll(existing);
    _detector = UtteranceDetector(
      // Long enough for a verse with pauses; short mantras just end sooner.
      config: const GateConfig(hangoverFrames: 55, maxFrames: 3000),
      onCalibrated: (_) => _set(TrainerPhase.waiting, null),
      onUtterance: _onUtterance,
      onTooShort: () => _say('That was too short. Say the whole mantra.'),
      onLevel: (db) {
        _level = ((db + 60) / 45).clamp(0.0, 1.0);
        notifyListeners();
      },
    );
  }

  final PcmInput _input;
  final MfccExtractor _extractor;
  late final UtteranceDetector _detector;

  /// Most recordings allowed in total, and the fewest that can be saved.
  final int maximum;
  final int minimum;

  /// Templates that were already saved when this session began.
  final int _existing;

  TrainerPhase _phase = TrainerPhase.idle;
  String? _message;
  double _level = 0;
  final List<MfccSequence> _samples = [];
  int _consecutiveRejects = 0;
  bool _disposed = false;

  TrainerPhase get phase => _phase;

  /// Guidance or the reason for the last problem.
  String? get message => _message;

  /// Live loudness 0..1 for a level meter.
  double get level => _level;
  List<MfccSequence> get samples => List.unmodifiable(_samples);
  int get recorded => _samples.length;

  /// Recordings made in this session (not counting [existing] ones).
  int get added => _samples.length - _existing;

  /// Room left before [maximum].
  int get remaining => maximum - _samples.length;

  /// Enough in total, and something new to save.
  bool get canSave => _samples.length >= minimum && added > 0;
  bool get listening =>
      _phase == TrainerPhase.calibrating || _phase == TrainerPhase.waiting;

  /// "Recording 2 of 5" while waiting for the 2nd rep.
  int get currentIndex => _samples.length + 1;

  Future<VoiceStartResult> start() async {
    if (listening || _phase == TrainerPhase.starting) return VoiceStartResult.started;
    if (remaining <= 0) {
      _set(TrainerPhase.complete, null);
      return VoiceStartResult.started;
    }
    _detector.reset();
    _set(TrainerPhase.starting, null);
    final result = await _input.start(
      onSamples: (pcm) {
        if (listening) _detector.addSamples(pcm);
      },
      onError: (msg) {
        _stopInput();
        _set(TrainerPhase.error, msg);
      },
    );
    if (_disposed) {
      unawaited(_input.stop());
      return result;
    }
    if (result != VoiceStartResult.started) {
      _set(TrainerPhase.error, voiceStartMessage(result));
      return result;
    }
    _set(TrainerPhase.calibrating, null);
    return result;
  }

  Future<void> stop() async {
    await _input.stop();
    if (listening || _phase == TrainerPhase.starting) {
      _set(_samples.length >= maximum ? TrainerPhase.complete : TrainerPhase.idle, null);
    }
  }

  /// Forget the last recording of this session (the user fumbled it).
  /// Recordings that were already saved are never touched.
  void discardLast() {
    if (added <= 0) return;
    _samples.removeLast();
    if (_phase == TrainerPhase.complete) _set(TrainerPhase.idle, null);
    notifyListeners();
  }

  /// Start over: drops this session's recordings (all of them, or, when adding
  /// to an existing training, only the new ones).
  void clear() {
    _samples.removeRange(_existing, _samples.length);
    _consecutiveRejects = 0;
    if (_phase == TrainerPhase.complete) _set(TrainerPhase.idle, null);
    notifyListeners();
  }

  void _onUtterance(Utterance u) {
    if (_phase != TrainerPhase.waiting) return;
    if (u.forced) {
      _say('That ran too long. Say the mantra once, then stop.');
      return;
    }
    final mfcc = _extractor.extract(u.samples);
    if (mfcc.frames < 25) {
      _say('That was too short. Say the whole mantra.');
      return;
    }
    if (_looksDifferent(mfcc)) {
      // Two misses in a row: the user's pace/style changed, so trust them.
      if (++_consecutiveRejects <= 2) {
        _say('That sounded different from the others. '
            'Say it the same way again.');
        return;
      }
    }
    _consecutiveRejects = 0;
    _samples.add(mfcc);
    if (_samples.length >= maximum) {
      _stopInput();
      _set(TrainerPhase.complete, null);
    } else {
      _say('Got it. Say it again.');
    }
  }

  /// Compares a new recording with the ones already taken (from the 3rd on).
  bool _looksDifferent(MfccSequence s) {
    if (_samples.length < 2) return false;
    var typical = 0.0, pairs = 0;
    for (var i = 0; i < _samples.length; i++) {
      for (var j = i + 1; j < _samples.length; j++) {
        typical += dtwDistance(_samples[i], _samples[j]);
        pairs++;
      }
    }
    typical /= pairs;
    var nearest = double.infinity;
    for (final t in _samples) {
      final d = dtwDistance(s, t);
      if (d < nearest) nearest = d;
    }
    return nearest > 1.0 && nearest > typical * 2.2;
  }

  void _stopInput() => unawaited(_input.stop());

  void _say(String text) {
    _message = text;
    notifyListeners();
  }

  void _set(TrainerPhase phase, String? message) {
    _phase = phase;
    _message = message;
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

/// User-facing reason a microphone start failed.
String voiceStartMessage(VoiceStartResult r) => switch (r) {
      VoiceStartResult.started => '',
      VoiceStartResult.denied =>
        'Microphone permission was denied, so Voice counting cannot listen.',
      VoiceStartResult.permanentlyDenied =>
        'Microphone access is blocked. Allow it in Settings to use Voice counting.',
      VoiceStartResult.unsupported => 'Voice counting works on Android and iOS only',
      VoiceStartResult.unavailable => 'No microphone available on this device',
    };
