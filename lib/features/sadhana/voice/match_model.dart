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

/// Slider default: one step (a quarter of the slider) from the middle toward
/// Strict (P5.1: it counted other words and similar-length sounds at 0.5).
/// A calibrated threshold is exactly the threshold at this default.
const defaultVoiceSensitivity = 0.25;

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
///
/// Matching compares static MFCCs plus their deltas and delta-deltas
/// ([withDeltas]); the templates themselves are stored as statics.
///
/// A [calibratedThreshold] (from the "chant it 11 times" calibration) replaces
/// the estimate from the training recordings; the slider still moves it.
class MatchModel {
  MatchModel(List<MfccSequence> templates, {this.calibratedThreshold})
      : templates = List.unmodifiable(templates.where((t) => !t.isEmpty)) {
    assert(this.templates.isNotEmpty);
    _features = [for (final t in this.templates) withDeltas(trimmedToVoice(t))];
    baseDistance = _leaveOneOut(_features);
    final lengths = this.templates.map((t) => t.frames).toList()..sort();
    medianFrames = lengths[lengths.length ~/ 2];
    maxFrames = lengths.last;
  }

  final List<MfccSequence> templates;

  /// The same templates with deltas: what candidates are compared with.
  late final List<MfccSequence> _features;

  /// Set by calibration: the distance between "your mantra" and "not it" for
  /// this speaker, phone and room (at the middle of the slider).
  final double? calibratedThreshold;

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

  double thresholdFor(double sensitivity) {
    final c = calibratedThreshold;
    if (c != null && c.isFinite && c > 0) {
      // The slider moves the calibrated value the same way it moves the
      // estimate: the middle is exactly the calibrated threshold.
      return (c * factorFor(sensitivity) / factorFor(defaultVoiceSensitivity))
          .clamp(minThreshold * 0.5, maxThreshold);
    }
    return (math.max(baseDistance, _minBase) * factorFor(sensitivity))
        .clamp(minThreshold, maxThreshold);
  }

  /// Utterances much shorter/longer than the trained ones are not this mantra
  /// (checked before the costlier DTW).
  bool lengthPlausible(int frames) =>
      frames >= medianFrames * 0.45 && frames <= medianFrames * 2.2;

  /// Most repetitions said in one breath that are split and counted.
  static const maxRepsInOneBreath = 4;

  /// Longest an utterance can be and still plausibly match (up to
  /// [maxRepsInOneBreath] repetitions in one breath): caps the detector so a
  /// long sentence is dropped, not analysed.
  int get maxPlausibleFrames => (maxFrames * 1.1 * maxRepsInOneBreath).ceil();

  VoiceCandidate evaluate(MfccSequence candidate, double sensitivity) {
    final threshold = thresholdFor(sensitivity);
    if (candidate.isEmpty || !lengthPlausible(candidate.frames)) {
      return VoiceCandidate(
          matched: false, distance: double.infinity, threshold: threshold);
    }
    final best = distanceTo(candidate, threshold * 2);
    return VoiceCandidate(
        matched: best <= threshold, distance: best, threshold: threshold);
  }

  /// Best distance from [candidate] (static MFCCs) to any template, or
  /// infinity if none comes under [abandonAbove].
  double distanceTo(MfccSequence candidate, [double abandonAbove = double.infinity]) {
    final f = withDeltas(trimmedToVoice(candidate));
    var best = double.infinity;
    for (final t in _features) {
      final d = dtwDistance(f, t, abandonAbove: math.min(best, abandonAbove));
      if (d < best) best = d;
    }
    return best;
  }

  /// Every repetition in one utterance. Normally one candidate; when the
  /// utterance is about N times the trained length (N = 2..4) and is not one
  /// match on its own, it is cut into N consecutive segments at its quietest
  /// moments near the expected boundaries, and if every segment matches, N
  /// matched candidates come back (several reps said in one breath).
  List<VoiceCandidate> evaluateAll(MfccSequence candidate, double sensitivity) {
    final single = evaluate(candidate, sensitivity);
    if (single.matched || candidate.frames < medianFrames * 1.6) return [single];
    for (var n = 2; n <= maxRepsInOneBreath; n++) {
      final lo = n * medianFrames * 0.7, hi = n * medianFrames * 1.35;
      if (candidate.frames < lo || candidate.frames > hi) continue;
      final parts = splitPoints(candidate, n);
      final results = [
        for (var k = 0; k < n; k++)
          evaluate(segmentOf(candidate, parts[k], parts[k + 1]), sensitivity),
      ];
      if (results.every((r) => r.matched)) return results;
    }
    return [single];
  }

  /// Boundaries (n + 1 frame indices, from 0 to the end) that cut [s] into
  /// [n] parts: each inner cut at the quietest frame (lowest c0) within ±25%
  /// of a part's length around where an even split would put it.
  static List<int> splitPoints(MfccSequence s, int n) {
    final len = s.frames / n;
    final cuts = <int>[0];
    for (var k = 1; k < n; k++) {
      final centre = (k * len).round();
      final reach = (len * 0.25).round();
      final from = math.max(cuts.last + 1, centre - reach);
      final to = math.min(s.frames - 1, centre + reach);
      var best = centre.clamp(from, to);
      var quietest = double.infinity;
      for (var f = from; f <= to; f++) {
        final c0 = s.at(f, 0);
        if (c0 < quietest) {
          quietest = c0;
          best = f;
        }
      }
      cuts.add(best);
    }
    cuts.add(s.frames);
    return cuts;
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
