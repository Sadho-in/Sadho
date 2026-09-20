import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'match_model.dart';
import 'mfcc.dart';
import 'utterance_detector.dart';

/// Real-time matcher: PCM16 16 kHz mono in, "that was your mantra" out.
///
/// Per utterance (never per sample): the detector cuts the audio at silence,
/// MFCCs are extracted once, and DTW compares them with each template.
class VoiceEngine {
  VoiceEngine({
    required this.model,
    this._sensitivity = defaultVoiceSensitivity,
    this.onCandidate,
    this.onLevel,
    this.onCalibrated,
  }) : _extractor = MfccExtractor() {
    _detector = UtteranceDetector(
      config: gateConfigFor(model),
      onUtterance: _onUtterance,
      onCalibrated: (db) => onCalibrated?.call(),
      onLevel: onLevel,
    );
  }

  final MatchModel model;

  /// Called for every candidate utterance, matched or not.
  final void Function(VoiceCandidate c)? onCandidate;
  final void Function(double db)? onLevel;
  final VoidCallback? onCalibrated;

  final MfccExtractor _extractor;
  late final UtteranceDetector _detector;
  double _sensitivity;

  bool get calibrated => _detector.gate.calibrated;
  UtteranceDetector get detector => _detector;

  set sensitivity(double v) => _sensitivity = v.clamp(0.0, 1.0);

  /// Pause length that ends a rep, and the length cap, from the trained
  /// mantra: a long verse tolerates longer pauses than a one-word mantra.
  static GateConfig gateConfigFor(MatchModel model) {
    final seconds = model.maxFrames / 100;
    final hangover = seconds < 2.5 ? 30 : (seconds < 8 ? 45 : 60);
    return GateConfig(
      hangoverFrames: hangover,
      maxFrames: model.maxPlausibleFrames.clamp(150, 3000),
    );
  }

  void addPcm(Int16List samples) => _detector.addSamples(samples);

  /// Forget the noise floor (after the app was in the background).
  void reset() => _detector.reset();

  void _onUtterance(Utterance u) {
    if (u.forced) {
      // Longer than any trained rep: not a rep, and already cut off.
      onCandidate?.call(VoiceCandidate(
        matched: false,
        distance: double.infinity,
        threshold: model.thresholdFor(_sensitivity),
      ));
      return;
    }
    final mfcc = _extractor.extract(u.samples);
    final result = model.evaluate(mfcc, _sensitivity);
    if (kDebugMode) {
      debugPrint('voice: ${mfcc.frames} frames  d=${result.distance.toStringAsFixed(2)}'
          '  thr=${result.threshold.toStringAsFixed(2)}'
          '  ${result.matched ? 'COUNT' : 'ignore'}');
    }
    onCandidate?.call(result);
  }
}
