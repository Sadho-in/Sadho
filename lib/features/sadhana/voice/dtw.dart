import 'dart:math' as math;
import 'dart:typed_data';

import 'mfcc.dart';

/// Dynamic-time-warping distance between two MFCC sequences, so the same
/// mantra chanted a little faster or slower still lines up.
///
/// Symmetric step pattern (diagonal steps count double), Euclidean frame
/// cost, Sakoe-Chiba band of [bandRatio] × the longer sequence around the
/// diagonal, and the total is divided by (n + m) so the result is a per-frame
/// average that does not grow with mantra length. With the mean/variance
/// normalised MFCCs, two unrelated utterances land around 4-5 and repeats of
/// the same mantra clearly lower.
///
/// [abandonAbove]: once no path can finish under this distance the search
/// stops and `double.infinity` is returned (a rejected candidate is the common
/// case, so this keeps the per-utterance cost low).
double dtwDistance(
  MfccSequence a,
  MfccSequence b, {
  double bandRatio = 0.3,
  double abandonAbove = double.infinity,
}) {
  final n = a.frames, m = b.frames;
  if (n == 0 || m == 0 || a.dims != b.dims) return double.infinity;
  final dims = a.dims;
  final ad = a.data, bd = b.data;
  final band = math.max(bandRatio * math.max(n, m), 2.0);
  final limit = abandonAbove * (n + m);

  var prev = Float64List(m + 1)..fillRange(0, m + 1, double.infinity);
  var cur = Float64List(m + 1);
  prev[0] = 0;

  for (var i = 1; i <= n; i++) {
    cur.fillRange(0, m + 1, double.infinity);
    final centre = i * m / n;
    final lo = math.max(1, (centre - band).ceil());
    final hi = math.min(m, (centre + band).floor());
    var rowMin = double.infinity;
    final ai = (i - 1) * dims;
    for (var j = lo; j <= hi; j++) {
      final bj = (j - 1) * dims;
      var sq = 0.0;
      for (var k = 0; k < dims; k++) {
        final diff = ad[ai + k] - bd[bj + k];
        sq += diff * diff;
      }
      final cost = math.sqrt(sq);
      var best = prev[j - 1] + 2 * cost; // diagonal
      final up = prev[j] + cost;
      if (up < best) best = up;
      final left = cur[j - 1] + cost;
      if (left < best) best = left;
      cur[j] = best;
      if (best < rowMin) rowMin = best;
    }
    if (rowMin > limit) return double.infinity;
    final t = prev;
    prev = cur;
    cur = t;
  }
  final total = prev[m];
  return total.isFinite ? total / (n + m) : double.infinity;
}
