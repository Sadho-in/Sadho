import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';

/// Smallest and largest mantra text size, as a multiple of the base size.
const minMantraTextScale = 0.8;
const maxMantraTextScale = 2.0;

/// The starting size: comfortably larger than the base (1.0), so a mantra is
/// easy to read at a glance.
const defaultMantraTextScale = 1.3;

/// One tap of A− / A+.
const mantraTextScaleStep = 0.1;

/// How big the mantra's script, transliteration and name are drawn: a
/// multiple of their base size, between [minMantraTextScale] and
/// [maxMantraTextScale]. Saved in Hive and used everywhere the mantra shows
/// (the Sadhana card and Focus mode).
class MantraTextScaleNotifier extends Notifier<double> {
  static const _key = 'sadhana.mantraTextScale';

  /// Snaps to the nearest 0.05 inside the allowed range, so repeated steps
  /// and pinching never drift by floating-point crumbs.
  static double snap(double v) =>
      (v.clamp(minMantraTextScale, maxMantraTextScale) * 20).round() / 20;

  @override
  double build() {
    final saved = AppStorage.settings.get(_key);
    return saved is num && saved.isFinite
        ? snap(saved.toDouble())
        : defaultMantraTextScale;
  }

  /// Sets the size. Pass `persist: false` while a pinch is in progress and call
  /// [commit] when it ends, so Hive is written once, not on every frame.
  void set(double value, {bool persist = true}) {
    if (!value.isFinite) return;
    state = snap(value);
    if (persist) commit();
  }

  /// Saves the current size.
  void commit() => AppStorage.settings.put(_key, state);

  void larger() => set(state + mantraTextScaleStep);
  void smaller() => set(state - mantraTextScaleStep);

  void reset() => set(defaultMantraTextScale);
}

final mantraTextScaleProvider =
    NotifierProvider<MantraTextScaleNotifier, double>(
  MantraTextScaleNotifier.new,
);

/// [base] with its font size multiplied by [scale] (line height is a ratio, so
/// it scales along with it).
TextStyle? scaledMantraStyle(TextStyle? base, double scale) {
  if (base == null) return null;
  return base.copyWith(fontSize: (base.fontSize ?? 14) * scale);
}
