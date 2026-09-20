import 'dart:math' as math;

import 'dtw.dart';
import 'mfcc.dart';

/// Fewest recordings a mantra needs before Voice can count with it.
const minTrainingSamples = 3;

/// Most recordings a mantra can have (training stops here, and "Add more
/// samples" tops up to it).
const maxTrainingSamples = 7;

/// A good number to aim for; more is more accurate, up to [maxTrainingSamples].
const recommendedTrainingSamples = 5;

/// Slider default: halfway between Strict and Lenient.
const defaultVoiceSensitivity = 0.5;

/// Outcome of comparing one detected utterance with the trained mantra.
class VoiceCandidate {
  const VoiceCandidate({
    required this.matched,
    required this.distance,
    required this.threshold,
  });

  final bool matched;

  /// Best DTW distance to any template (infinity = far, or length mismatch).
  final double distance;
  final double threshold;

  /// 0..1 for display: 1 is identical to a template, 0.5 is right at the
  /// threshold, 0 is twice the threshold or worse.
  double get closeness =>
      distance.isFinite ? (1 - distance / (threshold * 2)).clamp(0.0, 1.0) : 0.0;
}

/// The trained mantra as a matcher.
///
/// The threshold adapts to the speaker: each template's distance to its
/// nearest sibling (leave-one-out) says how much one person's repeats of this
/// mantra vary, and the threshold is that typical variation × a factor set by
/// the Strict ↔ Lenient slider, kept inside sane absolute bounds.
class MatchModel {
  MatchModel(List<MfccSequence> templates)
      : templates = List.unmodifiable(templates.where((t) => !t.isEmpty)) {
    assert(this.templates.isNotEmpty);
    baseDistance = _leaveOneOut(this.templates);
    final lengths = this.templates.map((t) => t.frames).toList()..sort();
    medianFrames = lengths[lengths.length ~/ 2];
    maxFrames = lengths.last;
  }

  final List<MfccSequence> templates;

  /// Typical distance between two repeats of the mantra by this speaker.
  late final double baseDistance;
  late final int medianFrames;
  late final int maxFrames;

  /// Floor and ceiling for the threshold. The ceiling stays well under the
  /// ~4-5 that unrelated speech scores, so a Lenient slider still rejects
  /// other words.
  static const minThreshold = 1.5;
  static const maxThreshold = 4.0;
  static const _minBase = 1.0;

  /// Slider 0 (Strict) .. 1 (Lenient) -> multiple of the typical distance.
  static double factorFor(double sensitivity) =>
      1.05 + 0.9 * sensitivity.clamp(0.0, 1.0);

  double thresholdFor(double sensitivity) => (math.max(baseDistance, _minBase) *
          factorFor(sensitivity))
      .clamp(minThreshold, maxThreshold);

  /// Utterances much shorter/longer than the trained ones are not this mantra
  /// (checked before the costlier DTW).
  bool lengthPlausible(int frames) =>
      frames >= medianFrames * 0.45 && frames <= medianFrames * 2.2;

  /// Longest an utterance can be and still plausibly match: caps the
  /// detector so a long sentence is dropped, not analysed.
  int get maxPlausibleFrames => (maxFrames * 2.2).ceil();

  VoiceCandidate evaluate(MfccSequence candidate, double sensitivity) {
    final threshold = thresholdFor(sensitivity);
    if (candidate.isEmpty || !lengthPlausible(candidate.frames)) {
      return VoiceCandidate(
          matched: false, distance: double.infinity, threshold: threshold);
    }
    var best = double.infinity;
    for (final t in templates) {
      final d = dtwDistance(candidate, t,
          abandonAbove: math.min(best, threshold * 2));
      if (d < best) best = d;
    }
    return VoiceCandidate(
        matched: best <= threshold, distance: best, threshold: threshold);
  }

  static double _leaveOneOut(List<MfccSequence> t) {
    if (t.length < 2) return _minBase * 2;
    var sum = 0.0;
    for (var i = 0; i < t.length; i++) {
      var nearest = double.infinity;
      for (var j = 0; j < t.length; j++) {
        if (i == j) continue;
        final d = dtwDistance(t[i], t[j]);
        if (d < nearest) nearest = d;
      }
      sum += nearest.isFinite ? nearest : _minBase * 4;
    }
    return sum / t.length;
  }
}
