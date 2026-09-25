import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../../../l10n/labels.dart';
import '../../../l10n/locale_provider.dart';
import '../../calendar/services/reminder_planner.dart' show reminderId;
import '../../calendar/services/reminder_scheduler.dart';
import '../../sadhana/services/feedback_service.dart';
import '../data/sun_alarm.dart';
import '../data/timer_presets.dart';
import 'clock_source.dart';
import 'location_provider.dart';

enum TimerPhase { idle, running, paused, finished }

/// A countdown that has run out this long ago (or less) still rings when the
/// screen sees it; older than that, the phone's notification already rang.
const _ringGrace = Duration(seconds: 5);

class TimerState {
  const TimerState({
    this.presetId = 'aarti',
    this.label = 'Aarti',
    this.totalSeconds = 300,
    this.remainingSeconds = 300,
    this.phase = TimerPhase.idle,
    this.endsAt,
    this.vratTarget,
    this.message,
  });

  /// A [TimerPreset] id, or [vratSunsetId].
  final String presetId;
  final String label;

  /// The length when it was started (what a Reset goes back to).
  final int totalSeconds;

  /// Seconds left when not running (paused / idle / finished = 0).
  final int remainingSeconds;
  final TimerPhase phase;

  /// When it reaches zero, while running.
  final DateTime? endsAt;

  /// For the vrat option: the sunset it counts down to.
  final DateTime? vratTarget;

  /// Something to tell the user (e.g. there is no sunset today).
  final String? message;

  bool get isVrat => presetId == vratSunsetId;
  bool get running => phase == TimerPhase.running;

  /// Seconds left at [now] (whole seconds, rounded up, never negative).
  int remainingAt(DateTime now) {
    if (phase == TimerPhase.running && endsAt != null) {
      final ms = endsAt!.difference(now).inMilliseconds;
      return ms <= 0 ? 0 : (ms + 999) ~/ 1000;
    }
    return remainingSeconds;
  }

  TimerState copyWith({
    String? presetId,
    String? label,
    int? totalSeconds,
    int? remainingSeconds,
    TimerPhase? phase,
    DateTime? endsAt,
    bool clearEndsAt = false,
    DateTime? vratTarget,
    bool clearVrat = false,
    String? message,
    bool clearMessage = false,
  }) =>
      TimerState(
        presetId: presetId ?? this.presetId,
        label: label ?? this.label,
        totalSeconds: totalSeconds ?? this.totalSeconds,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        phase: phase ?? this.phase,
        endsAt: clearEndsAt ? null : (endsAt ?? this.endsAt),
        vratTarget: clearVrat ? null : (vratTarget ?? this.vratTarget),
        message: clearMessage ? null : (message ?? this.message),
      );

  Map<String, dynamic> toMap() => {
        'preset': presetId,
        'label': label,
        'total': totalSeconds,
        'remaining': remainingSeconds,
        'phase': phase.name,
        'endsAt': endsAt?.millisecondsSinceEpoch,
        'vrat': vratTarget?.millisecondsSinceEpoch,
      };

  static TimerState fromMap(Object? m) {
    if (m is! Map) return const TimerState();
    DateTime? ms(Object? v) =>
        v is int ? DateTime.fromMillisecondsSinceEpoch(v) : null;
    int seconds(Object? v, int fallback) =>
        v is int && v >= 0 && v <= 7 * 24 * 3600 ? v : fallback;
    final preset = m['preset'] is String ? m['preset'] as String : 'aarti';
    final total = seconds(m['total'], 300);
    return TimerState(
      presetId: preset,
      label: m['label'] is String ? m['label'] as String : 'Aarti',
      totalSeconds: total,
      remainingSeconds: seconds(m['remaining'], total),
      phase: TimerPhase.values.firstWhere((p) => p.name == m['phase'],
          orElse: () => TimerPhase.idle),
      endsAt: ms(m['endsAt']),
      vratTarget: ms(m['vrat']),
    );
  }
}

/// The Sadhana & vrat countdown.
///
/// It runs on a fixed end time (not on ticks), so it stays right when the app
/// is in the background. A notification is scheduled for the end as well, so it
/// rings even if Sadho is closed; when the screen sees it reach zero it rings
/// through the completion feedback instead (vibration and the alarm-stream
/// sound, following the Completion settings) and cancels the notification so
/// there is one ring, not two.
class TimerNotifier extends Notifier<TimerState> {
  static const _key = 'clock.timer';

  @override
  TimerState build() {
    // The end-of-timer notification is worded in the app's language: a new
    // language re-words the one waiting for a running timer.
    // (After a microtask: inside the listener the texts are still the old
    // language's.)
    ref.listen(localeProvider, (_, _) => Future.microtask(() {
          final t = state;
          if (ref.mounted && t.running && t.endsAt != null) {
            _scheduleRing(t, t.endsAt!);
          }
        }));
    var s = TimerState.fromMap(AppStorage.settings.get(_key));
    final now = ref.read(clockNowProvider)();
    if (s.phase == TimerPhase.running) {
      if (s.endsAt == null || !s.endsAt!.isAfter(now)) {
        // It ended while the app was closed: the notification rang already.
        s = s.copyWith(
            phase: TimerPhase.finished, remainingSeconds: 0, clearEndsAt: true);
      } else {
        // Still counting: make sure the phone will ring at the end.
        final ends = s.endsAt!;
        Future.microtask(() => _scheduleRing(s, ends));
      }
    }
    return s;
  }

  // ---- choosing a length ----------------------------------------------------

  void selectPreset(TimerPreset p) {
    if (state.running) return;
    _set(TimerState(
      presetId: p.id,
      label: p.label,
      totalSeconds: p.minutes * 60,
      remainingSeconds: p.minutes * 60,
    ));
  }

  /// A length the user chose (1 s to 24 h); it is remembered for the
  /// Custom chip. Runs exactly like a preset. False if [seconds] is out of
  /// range or a countdown is running.
  bool selectCustom(int seconds) {
    if (state.running || !isValidCustomSeconds(seconds)) return false;
    ref.read(lastCustomTimerProvider.notifier).set(seconds);
    _set(TimerState(
      presetId: customTimerId,
      label: 'Custom timer',
      totalSeconds: seconds,
      remainingSeconds: seconds,
    ));
    return true;
  }

  /// "Vrat → sunset": counts down to the next sunset at the user's place
  /// (today's if it is still ahead, otherwise tomorrow's).
  void selectVratToSunset() {
    if (state.running) return;
    final now = ref.read(clockNowProvider)();
    final p = ref.read(locationProvider).point;
    final next = nextSunEvent(SunEventKind.sunset, now, p.lat, p.lon);
    if (next == null) {
      _set(state.copyWith(message: ref.read(l10nProvider).clockNoSunsetHere));
      return;
    }
    _set(_vratTo(next, now));
  }

  TimerState _vratTo(NextSunEvent next, DateTime now) {
    final secs = (next.time.difference(now).inMilliseconds + 999) ~/ 1000;
    return TimerState(
      presetId: vratSunsetId,
      label: 'Vrat → sunset',
      totalSeconds: secs,
      remainingSeconds: secs,
      vratTarget: next.time,
      message: next.laterDay ? ref.read(l10nProvider).clockSunsetPassedTomorrow : null,
    );
  }

  // ---- running ---------------------------------------------------------------

  void start() {
    if (state.running) return;
    final now = ref.read(clockNowProvider)();
    var s = state;
    if (s.phase == TimerPhase.finished) s = _fresh(s, now);
    // Vrat counts to the sunset itself, however late Start is pressed.
    final ends = s.isVrat && s.vratTarget != null && s.phase == TimerPhase.idle
        ? s.vratTarget!
        : now.add(Duration(seconds: s.remainingSeconds));
    if (!ends.isAfter(now)) return;
    _set(s.copyWith(phase: TimerPhase.running, endsAt: ends));
    _scheduleRing(state, ends);
  }

  void pause() {
    if (!state.running) return;
    final now = ref.read(clockNowProvider)();
    final left = state.remainingAt(now);
    _set(state.copyWith(
        phase: TimerPhase.paused, remainingSeconds: left, clearEndsAt: true));
    _cancelRing();
  }

  /// Back to the full length (and, for vrat, to the next sunset).
  void reset() {
    final now = ref.read(clockNowProvider)();
    _cancelRing();
    _set(_fresh(state, now));
  }

  /// Called often by the timer screen while it is open. Notices zero.
  void tick() {
    final s = state;
    if (!s.running || s.endsAt == null) return;
    final now = ref.read(clockNowProvider)();
    if (s.endsAt!.isAfter(now)) return;
    final late = now.difference(s.endsAt!);
    _set(s.copyWith(
        phase: TimerPhase.finished, remainingSeconds: 0, clearEndsAt: true));
    // The phone's notification is no longer needed (or has already rung).
    _cancelRing();
    if (late <= _ringGrace) {
      ref.read(feedbackServiceProvider).complete();
    }
  }

  // ---- internals -------------------------------------------------------------

  TimerState _fresh(TimerState s, DateTime now) {
    if (s.isVrat) {
      // Recompute the sunset: the old one may be past.
      final p = ref.read(locationProvider).point;
      final next = nextSunEvent(SunEventKind.sunset, now, p.lat, p.lon);
      if (next != null) {
        // A reset is not news: no "counting to tomorrow's" note.
        return _vratTo(next, now).copyWith(clearMessage: true);
      }
    }
    return TimerState(
      presetId: s.presetId,
      label: s.label,
      totalSeconds: s.totalSeconds,
      remainingSeconds: s.totalSeconds,
    );
  }

  void _set(TimerState next) {
    state = next;
    AppStorage.settings.put(_key, next.toMap());
  }

  Future<void> _scheduleRing(TimerState s, DateTime ends) async {
    try {
      final l = ref.read(l10nProvider);
      final label = presetLabelFor(l, s.presetId, s.label);
      await ref.read(reminderSchedulerProvider).replaceAlerts(timerGroup, [
        ScheduledAlert(
          id: reminderId(timerGroup, 0, 0),
          when: ends,
          title: l.timerFinishedTitle(label),
          body: s.isVrat ? l.sunsetArrived : l.timerTimeUp(label),
        ),
      ]);
    } catch (e) {
      debugPrint('Could not schedule the timer ring: $e');
    }
  }

  Future<void> _cancelRing() async {
    try {
      await ref.read(reminderSchedulerProvider).replaceAlerts(timerGroup, const []);
    } catch (e) {
      debugPrint('Could not cancel the timer ring: $e');
    }
  }
}

final timerProvider =
    NotifierProvider<TimerNotifier, TimerState>(TimerNotifier.new);

/// The last custom timer length in seconds (null until one is chosen), saved
/// so the Custom chip can show it ("Custom · 17 min") after a restart.
class LastCustomTimerNotifier extends Notifier<int?> {
  static const _key = 'clock.timer.custom';

  @override
  int? build() {
    final v = AppStorage.settings.get(_key);
    return v is int && isValidCustomSeconds(v) ? v : null;
  }

  void set(int seconds) {
    if (!isValidCustomSeconds(seconds)) return;
    state = seconds;
    AppStorage.settings.put(_key, seconds);
  }
}

final lastCustomTimerProvider =
    NotifierProvider<LastCustomTimerNotifier, int?>(LastCustomTimerNotifier.new);
