import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../../alarms/services/alarm_health.dart';
import '../../calendar/services/local_notifications_scheduler.dart'
    show sadhanaAlarmChannel;
import '../../calendar/services/reminder_planner.dart' show reminderId;
import '../../calendar/services/reminder_scheduler.dart';
import '../../clock/application/clock_source.dart';
import '../services/feedback_service.dart';
import '../services/mala_background_service.dart';
import '../services/voice_counter_service.dart';
import '../services/volume_button_service.dart';
import '../voice/match_model.dart';
import 'completion_settings_provider.dart';
import 'rhythm_pace.dart';
import 'session_notice_provider.dart';
import 'voice_training_provider.dart';
import '../../../l10n/labels.dart';
import '../../../l10n/locale_provider.dart';

enum TargetType { count, time }

/// How counts are produced:
/// - tap: touch the ring / focus screen
/// - rhythm: automatic, at the user-set pace
/// - voice: speech recognition, one count per spoken phrase
/// - mala: hardware volume-button presses
enum CountMode { tap, rhythm, voice, mala }

/// How the four modes relate to each other. Every mode ALWAYS keeps its own
/// count; the scope only decides what is shown and measured against the target:
/// - combined: the SUM of all four modes, toward one target
/// - separate: only the active mode's own count, toward its own target;
///   Reset and completion affect only the active mode
///
/// Because nothing is ever merged or split, switching scope loses nothing and
/// switching back restores exactly what was there.
enum CountScope { combined, separate }

/// Count + session-clock time of one mode.
class ModeProgress {
  const ModeProgress({this.count = 0, this.elapsedSeconds = 0});

  static const zero = ModeProgress();

  final int count;
  final int elapsedSeconds;

  ModeProgress copyWith({int? count, int? elapsedSeconds}) => ModeProgress(
        count: count ?? this.count,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      );

  Map<String, int> toMap() => {'count': count, 'elapsedSeconds': elapsedSeconds};

  factory ModeProgress.fromMap(Object? m) => m is Map
      ? ModeProgress(
          count: _nonNegative(m['count']),
          elapsedSeconds: _nonNegative(m['elapsedSeconds']),
        )
      : zero;
}

int _nonNegative(Object? v) => v is num && v > 0 ? v.toInt() : 0;

/// Why a mode cannot be used on this device. Shown in the setup card and,
/// with "Using Tap mode.", in the snackbar when a mode has to be left.
const voiceUnsupportedText = 'Voice counting works on Android and iOS only';
const voiceNoMicText = 'No microphone available on this device';
const malaUnsupportedText = 'Volume-key counting needs a physical device';

/// Buzz every N counts (vibration only).
const milestoneEvery = 108;

/// The latest thing Voice heard, for the live indicator. Transient.
class VoiceHitInfo {
  const VoiceHitInfo({
    required this.seq,
    required this.counted,
    required this.closeness,
  });

  /// Increases with every utterance heard, so the UI can animate on change.
  final int seq;

  /// It matched the trained mantra and was counted (otherwise ignored).
  final bool counted;

  /// 0..1 how close it was to the trained mantra.
  final double closeness;
}

class SadhanaState {
  const SadhanaState({
    this.mantraId = 'seed_om_namah_shivaya',
    this.sankalp = '',
    this.targetType = TargetType.count,
    this.targetCount = 108,
    this.targetSeconds = 600,
    this.mode = CountMode.tap,
    this.scope = CountScope.combined,
    this.perMode = const {},
    this.running = false,
    this.rhythmSeconds = defaultRhythmSeconds,
    this.inputActive = false,
    this.lastVoice,
    this.alarmMayBeLate = false,
    this.malaScreenOff = false,
  });

  final String mantraId;
  final String sankalp;
  final TargetType targetType;
  final int targetCount;
  final int targetSeconds;
  final CountMode mode;
  final CountScope scope;

  /// Each mode's own count and clock (a mode never used is absent = zero).
  /// Kept in BOTH scopes; Combined just adds them up.
  final Map<CountMode, ModeProgress> perMode;

  /// Drives the auto-incrementing rhythm (Rhythm mode) and the session clock
  /// (time target). Never persisted as true: sessions reopen paused.
  final bool running;

  /// Seconds between automatic counts in Rhythm mode.
  final double rhythmSeconds;

  /// Voice matcher / volume-key capture is live. Transient: never saved.
  final bool inputActive;

  /// Last utterance Voice heard while listening. Transient: never saved.
  final VoiceHitInfo? lastVoice;

  /// The finish alarm is set, but the phone does not allow exact alarms, so
  /// it may ring a little late. Transient: never saved.
  final bool alarmMayBeLate;

  /// Mala is counted by the background service, so the volume keys count
  /// with the screen off too. Transient: never saved.
  final bool malaScreenOff;

  /// The finish time is known in advance, so the phone can ring at the end
  /// even with the screen off or the app closed: a time target (any mode), or
  /// a count target in Rhythm (the remaining count × the pace). Tap, Voice and
  /// Mala count targets finish on the user's input instead.
  bool get hasPredictableEnd => isTimeTarget || mode == CountMode.rhythm;

  bool get isSeparate => scope == CountScope.separate;

  ModeProgress progressOf(CountMode m) => perMode[m] ?? ModeProgress.zero;

  /// The active mode's OWN count and clock: where its input adds to.
  ModeProgress get activeProgress => progressOf(mode);

  /// All four modes added together (what Combined shows).
  ModeProgress get totalProgress => ModeProgress(
        count: perMode.values.fold(0, (a, p) => a + p.count),
        elapsedSeconds: perMode.values.fold(0, (a, p) => a + p.elapsedSeconds),
      );

  /// What the ring shows and the target is measured against: the sum in
  /// Combined, the active mode's own in Separate.
  ModeProgress get shownProgress => isSeparate ? activeProgress : totalProgress;

  int get count => shownProgress.count;
  int get elapsedSeconds => shownProgress.elapsedSeconds;

  /// Target reached (by the shown count). Derived, so it can never disagree
  /// with the count or the target.
  bool get completed =>
      isTimeTarget ? elapsedSeconds >= targetSeconds : count >= targetCount;

  /// This state with [p] stored as the active mode's own progress.
  SadhanaState withProgress(ModeProgress p) =>
      copyWith(perMode: {...perMode, mode: p});

  /// Reset: everything in Combined, only the active mode in Separate.
  SadhanaState cleared() => copyWith(
        perMode: isSeparate ? ({...perMode}..remove(mode)) : const {},
      );

  /// One off the shown count, or null if it is already zero. In Combined the
  /// active mode gives up a count if it has one, otherwise the mode holding
  /// the most does, so the shared total always goes down by exactly one.
  SadhanaState? decremented() {
    var from = mode;
    if (progressOf(from).count == 0) {
      if (isSeparate) return null;
      final holders = perMode.entries.where((e) => e.value.count > 0).toList()
        ..sort((a, b) => b.value.count.compareTo(a.value.count));
      if (holders.isEmpty) return null;
      from = holders.first.key;
    }
    final p = progressOf(from);
    return copyWith(perMode: {
      ...perMode,
      from: p.copyWith(count: p.count - 1),
    });
  }

  /// Whether the Start/Pause control applies: every mode except Tap arms an
  /// input, and a time target has a clock to run.
  bool get usesRunToggle => mode != CountMode.tap || isTimeTarget;

  bool get isTimeTarget => targetType == TargetType.time;

  /// 0..1 progress toward the current target.
  double get progress {
    final p = isTimeTarget
        ? elapsedSeconds / targetSeconds
        : count / targetCount;
    return p.clamp(0.0, 1.0);
  }

  int get remainingSeconds =>
      (targetSeconds - elapsedSeconds).clamp(0, targetSeconds);

  SadhanaState copyWith({
    String? mantraId,
    String? sankalp,
    TargetType? targetType,
    int? targetCount,
    int? targetSeconds,
    CountMode? mode,
    CountScope? scope,
    Map<CountMode, ModeProgress>? perMode,
    bool? running,
    double? rhythmSeconds,
    bool? inputActive,
    VoiceHitInfo? lastVoice,
    bool clearLastVoice = false,
    bool? alarmMayBeLate,
    bool? malaScreenOff,
  }) =>
      SadhanaState(
        mantraId: mantraId ?? this.mantraId,
        sankalp: sankalp ?? this.sankalp,
        targetType: targetType ?? this.targetType,
        targetCount: targetCount ?? this.targetCount,
        targetSeconds: targetSeconds ?? this.targetSeconds,
        mode: mode ?? this.mode,
        scope: scope ?? this.scope,
        perMode: perMode ?? this.perMode,
        running: running ?? this.running,
        rhythmSeconds: rhythmSeconds ?? this.rhythmSeconds,
        inputActive: inputActive ?? this.inputActive,
        lastVoice: clearLastVoice ? null : (lastVoice ?? this.lastVoice),
        alarmMayBeLate: alarmMayBeLate ?? this.alarmMayBeLate,
        malaScreenOff: malaScreenOff ?? this.malaScreenOff,
      );

  Map<String, dynamic> toMap() => {
        'mantraId': mantraId,
        'sankalp': sankalp,
        'targetType': targetType.name,
        'targetCount': targetCount,
        'targetSeconds': targetSeconds,
        'mode': mode.name,
        'countScope': scope.name,
        // Each mode's own count and clock, in both scopes.
        'modeProgress': {
          for (final e in perMode.entries)
            if (e.value.count > 0 || e.value.elapsedSeconds > 0)
              e.key.name: e.value.toMap(),
        },
        'rhythmSeconds': rhythmSeconds,
      };

  factory SadhanaState.fromMap(Map<dynamic, dynamic>? m) {
    if (m == null) return const SadhanaState();
    const d = SadhanaState();
    T pick<T extends Enum>(List<T> values, Object? name, T fallback) =>
        values.firstWhere((v) => v.name == name, orElse: () => fallback);
    final scope = pick(CountScope.values, m['countScope'], d.scope);
    final mode = pick(CountMode.values, m['mode'], d.mode);
    final saved = m['modeProgress'];
    var perMode = <CountMode, ModeProgress>{
      if (saved is Map)
        for (final k in CountMode.values)
          if (saved[k.name] is Map) k: ModeProgress.fromMap(saved[k.name]),
    };
    if (perMode.isEmpty) {
      // Saved before every mode kept its own count: one shared `count`, which
      // belongs to the mode that was active.
      final legacy = ModeProgress.fromMap(m);
      if (legacy.count > 0 || legacy.elapsedSeconds > 0) {
        perMode = {mode: legacy};
      }
    }
    return SadhanaState(
      mantraId: (m['mantraId'] as String?) ?? d.mantraId,
      sankalp: (m['sankalp'] as String?) ?? '',
      targetType: pick(TargetType.values, m['targetType'], d.targetType),
      targetCount: ((m['targetCount'] as int?) ?? d.targetCount).clamp(1, 9999999),
      targetSeconds: ((m['targetSeconds'] as int?) ?? d.targetSeconds).clamp(1, 359999),
      mode: mode,
      scope: scope,
      perMode: perMode,
      rhythmSeconds: ((m['rhythmSeconds'] as num?) ?? d.rhythmSeconds)
          .toDouble()
          .clamp(minRhythmSeconds, maxRhythmSeconds),
    );
  }
}

/// The in-progress japa/paath session. Owns the rhythm + clock timers and
/// fires milestone/completion feedback.
///
/// ALL completion feedback starts here ([_targetReached]), whichever way the
/// target was reached (a tap, the rhythm, a voice match, a volume key, the +
/// button or the clock) and whichever screen is showing (the Sadhana tab or
/// Focus mode): the screens only display the session, they never ring.
class SadhanaSessionNotifier extends Notifier<SadhanaState> {
  static const _storageKey = 'sadhana.session';

  /// Hive keys: each alarm permission is explained (and offered) only once.
  static const askedExactKey = 'sadhana.askedExactAlarms';
  static const askedFullScreenKey = 'sadhana.askedFullScreen';

  /// Hive key: the one-time "this will ring like an alarm" explainer was shown.
  static const alarmExplainedKey = 'sadhana.alarmExplained';

  /// The phone's alarm is set this much AFTER the predicted end, so when the
  /// app is open its own clock finishes first, rings in the app and cancels
  /// the alarm (one ring, not two).
  static const alarmMargin = Duration(seconds: 2);

  /// Without a phone alarm (notifications refused), a session found finished
  /// on return still rings in the app if it ended at most this long ago.
  static const lateRingLimit = Duration(minutes: 10);

  Timer? _clock;
  Timer? _rhythm;

  // Time and Rhythm beats are measured against the real clock, not just
  // against ticks: a phone with the screen off can stop the app's timers for
  // minutes, and the app can even be closed. These are the moments the last
  // counted second / beat fell due. They are saved with the session, so a
  // relaunch continues from them.
  DateTime? _lastTickAt;
  DateTime? _lastBeatAt;

  /// When the running session will reach its target (predictable ends only).
  DateTime? _endsAt;
  bool _alarmScheduled = false;
  bool _askedNotifications = false;
  int _alarmGen = 0;

  /// The session finished while the app was in the background, before the
  /// phone's alarm rang: the alarm is left to ring (at this time) and the app
  /// stays quiet.
  DateTime? _heldAlarmAt;

  /// The app is on screen (not in the background, locked or closed).
  bool _foreground = true;

  /// A relaunch found the session just finished, before the phone rang.
  bool _ringOnRestore = false;
  late ReminderScheduler _scheduler;
  _ResumeWatcher? _watcher;

  late VoiceCounterService _voice;
  late VolumeButtonService _volume;

  // Whether each input engine is (or is being) started. The generation
  // counters invalidate a start() that is still awaiting (e.g. the permission
  // dialog) when the user pauses or switches mode in the meantime.
  bool _voiceActive = false;
  bool _malaActive = false;
  int _voiceGen = 0;
  int _malaGen = 0;
  bool _disposed = false;

  // ---- Mala in the background (screen off, Android) ----
  // While a Mala session runs, the native service is the ONLY Mala counter
  // (screen on or off); the in-app volume-key listener is only the fallback.
  late MalaBackgroundService _mala;
  VoidCallback? _malaUnlisten;
  _MalaVia _malaVia = _MalaVia.none;

  /// The service holds a session (counting, paused, or ticking after the
  /// target), identified by [_malaSessionId] (saved, so a relaunch can take
  /// it over and catch up).
  bool _malaServiceAlive = false;
  String? _malaSessionId;
  String? _malaMantraId;

  /// Paused from the service's notification: it stays paused there (with
  /// Resume) until the session changes in the app.
  bool _malaPausedByService = false;

  /// The service reached the target: it stays on, so further presses give
  /// only the short tick (and never change the volume).
  bool _malaReachedViaService = false;

  /// The count, base and target the service last knew.
  (int, int, int)? _malaPushed;

  /// Catching up with the service: it is not settled until that is done.
  bool _malaCatchingUp = false;

  /// Hive key: the "screen-off counting is not available" notice was shown.
  static const malaFallbackNoticeKey = 'sadhana.malaFallbackNoticed';

  @override
  SadhanaState build() {
    // Read once here: ref cannot be used inside onDispose.
    _voice = ref.read(voiceCounterServiceProvider);
    _volume = ref.read(volumeButtonServiceProvider);
    _scheduler = ref.read(reminderSchedulerProvider);
    _mala = ref.read(malaBackgroundServiceProvider);
    _malaUnlisten = _mala.listen(_onMalaEvent);
    _disposed = false;
    // Catch the clock up when the app comes back to the front.
    try {
      _watcher = _ResumeWatcher(_onLifecycle);
      WidgetsBinding.instance.addObserver(_watcher!);
      final now = WidgetsBinding.instance.lifecycleState;
      _foreground = now == null || _isForeground(now);
    } catch (_) {
      // No Flutter binding (plain unit tests): nothing to watch.
    }
    final saved = AppStorage.settings.get(_storageKey) as Map?;
    final malaSession = saved?['malaSession'];
    _malaSessionId = malaSession is String ? malaSession : null;
    final restored = _restore(SadhanaState.fromMap(saved), saved);
    // Pick up where a relaunch left off, or remove an alarm left over from a
    // session that no longer runs (unless a run has started meanwhile).
    Future.microtask(() {
      // A Mala session the service may still be counting (or finished).
      if (_malaSessionId != null && !_disposed) unawaited(_reconnectMala());
      if (_alarmGen != 0 || _disposed) return;
      if (state.running) {
        _syncTimers(fresh: false);
        _syncInputs();
        _persist();
        return;
      }
      if (_ringOnRestore) _targetReached();
      _setAlarm(null);
      unawaited(_scheduler
          .dismissShown(sadhanaTimerGroup)
          .catchError((Object _) {}));
    });
    // A new ringtone, vibration or repeat choice applies to the alarm at once.
    ref.listen(completionSettingsProvider, (_, _) {
      if (_alarmScheduled && _endsAt != null) _setAlarm(_endsAt!.add(alarmMargin));
      if (_malaServiceAlive) _pushMala(force: true);
    });
    ref.onDispose(() {
      _disposed = true;
      _cancelTimers();
      if (_watcher != null) WidgetsBinding.instance.removeObserver(_watcher!);
      unawaited(_scheduler
          .replaceAlerts(sadhanaTimerGroup, const [])
          .catchError((Object _) {}));
      if (_voiceActive) unawaited(_voice.stop());
      if (_malaActive) unawaited(_volume.stop());
      _malaUnlisten?.call();
      if (_malaServiceAlive) unawaited(_mala.stop());
    });
    // The Strict ↔ Lenient slider takes effect on a listening session at once.
    ref.listen(voiceSensitivityProvider, (_, v) {
      if (_voiceActive) _voice.setSensitivity(v);
    });
    return restored;
  }

  DateTime _now() => ref.read(clockNowProvider)();

  /// A saved session that was running when the app closed: caught up to the
  /// real clock, so the screen shows the right number at once. A Rhythm or
  /// timed Tap session keeps running; Voice and Mala wait for Start (their
  /// input has to be switched on again). One that finished meanwhile is shown
  /// finished; the phone's alarm has rung for it.
  SadhanaState _restore(SadhanaState s, Map? saved) {
    if (saved == null || saved['running'] != true) return s;
    DateTime? at(String key) => saved[key] is int
        ? DateTime.fromMillisecondsSinceEpoch(saved[key] as int)
        : null;
    _lastTickAt = at('tickAt');
    _lastBeatAt = at('beatAt');
    _endsAt = at('endsAt');
    _alarmScheduled = saved['alarmSet'] == true;
    if (_lastTickAt == null && _lastBeatAt == null) return s;

    final now = _now();
    var next = _caughtUp(s.copyWith(running: true), now);
    if (next.completed) {
      _ringOnRestore = _shouldRing(now) == _Ring.app;
      return next.copyWith(running: false);
    }
    if (next.mode == CountMode.voice || next.mode == CountMode.mala) {
      next = next.copyWith(running: false);
    }
    return next;
  }

  // ---- counting ----------------------------------------------------------

  /// A tap on the screen (the ring, or anywhere in Focus mode). It counts ONLY
  /// in Tap mode: in Voice, Rhythm and Mala the only things that count are that
  /// mode's own input (a voice match, the rhythm timer, a volume key), plus the
  /// deliberate + / − buttons, which call [increment] / [decrement] directly.
  ///
  /// Once the target is reached a tap counts for nothing, but the phone still
  /// answers with a short vibration tick on EVERY tap (see
  /// [FeedbackService.acknowledge]).
  void tap() {
    if (state.mode != CountMode.tap) return;
    if (state.completed) {
      ref.read(feedbackServiceProvider).acknowledge();
      return;
    }
    increment();
  }

  /// Adds one count to the active mode. Ignored once the target has been
  /// reached. Called by every mode's own input and by the + button.
  void increment() {
    if (state.completed) return;
    _addCounts(1);
    // A + in Rhythm moves its finish (and so the alarm) one beat earlier.
    _rhythmCountChanged();
  }

  /// Adds [n] counts to the active mode; the target (if reached) finishes
  /// the session. The 108 milestone buzz is for single counts only, not for
  /// a batch caught up after the app was away.
  void _addCounts(int n) {
    final s = state;
    var next = s.withProgress(
        s.activeProgress.copyWith(count: s.activeProgress.count + n));
    // In Tap mode with a time target the clock starts on the first tap.
    if (s.isTimeTarget && s.mode == CountMode.tap && !s.running) {
      next = next.copyWith(running: true);
    }
    if (!next.isTimeTarget && next.completed) {
      _finish(next);
      return;
    }
    _emit(next);
    if (n == 1 && next.count % milestoneEvery == 0) {
      ref.read(feedbackServiceProvider).milestone();
    }
  }

  /// The session just reached its target: vibration and ringtone, each per
  /// its own switch and repeat setting.
  void _targetReached() => ref.read(feedbackServiceProvider).completionAlert();

  /// Silences a completion alert that is still sounding or repeating (the
  /// Stop control, and leaving the Sadhana screen).
  void stopAlert() {
    if (ref.mounted) ref.read(feedbackServiceProvider).stopAlert();
  }

  /// Manual correction: takes one off the shown count (never below zero).
  /// Available in every mode, e.g. when Voice counted a rep that was not one.
  void decrement() {
    final next = state.decremented();
    if (next == null) return;
    _emit(next);
    _rhythmCountChanged();
  }

  /// A manual + / − while a Rhythm count target runs: the finish moves, so
  /// the alarm follows it.
  void _rhythmCountChanged() {
    final s = state;
    if (!s.running || s.completed || s.isTimeTarget || s.mode != CountMode.rhythm) {
      return;
    }
    _endsAt = _predictEnd(s);
    _setAlarm(_endsAt?.add(alarmMargin));
  }

  /// Stops whatever is running (microphone, volume keys, timers), keeping the
  /// count. Used before another screen needs the microphone.
  void pause() {
    if (state.running) _emit(state.copyWith(running: false));
  }

  /// Zeroes the shown count: every mode's (Combined) or only the active
  /// mode's own (Separate). Also silences a completion alert.
  void reset() {
    stopAlert();
    // A Mala service paused from its notification is stopped too.
    _malaPausedByService = false;
    _emit(state.cleared().copyWith(running: false));
  }

  /// Starts/pauses whatever the mode runs: the rhythm pace, the microphone
  /// (Voice), volume-key capture (Mala) and/or the session clock.
  void toggleRunning() {
    if (state.completed) return;
    if (!state.running && state.mode == CountMode.voice && !_voiceTrained()) {
      // Voice only counts a mantra it has been trained on.
      ref.read(sessionNoticeProvider.notifier).show(
            ref.read(l10nProvider).trainFirstPrompt(minTrainingSamples, maxTrainingSamples),
            trainMantraId: state.mantraId,
          );
      return;
    }
    _emit(state.copyWith(running: !state.running));
  }

  bool _voiceTrained() => ref.read(mantraTrainedProvider(state.mantraId));

  // ---- configuration -----------------------------------------------------

  /// Picks a mantra. Starts a fresh session on it (every mode's count, in
  /// either scope), adopting its default count.
  void selectMantra(String id, int defaultCount) {
    if (id == state.mantraId) return;
    _emit(state.copyWith(
      mantraId: id,
      targetCount: defaultCount,
      perMode: const {},
      running: false,
    ));
  }

  void setSankalp(String text) => _emit(state.copyWith(sankalp: text));

  void setTargetType(TargetType type) =>
      _emit(_retarget(state.copyWith(targetType: type)));

  void setTargetCount(int count) =>
      _emit(_retarget(state.copyWith(targetCount: count.clamp(1, 9999999))));

  void setTargetSeconds(int seconds) => _emit(
      _retarget(state.copyWith(targetSeconds: seconds.clamp(1, 359999))));

  void setMode(CountMode mode) {
    if (mode == state.mode) return;
    final fallbackL10n = ref.read(l10nProvider);
    final unsupported = switch (mode) {
      CountMode.voice when !_voice.isSupported => fallbackL10n.fallbackVoiceUnsupported,
      CountMode.mala when !_volume.isSupported => fallbackL10n.fallbackMalaUnsupported,
      _ => null,
    };
    if (unsupported != null) {
      _fallbackToTap(unsupported);
      return;
    }
    _emit(state.copyWith(mode: mode, running: false, inputActive: false));
  }

  /// Switches between the sum of all modes (Combined) and the active mode's
  /// own count (Separate). Nothing is merged or split, so nothing is lost and
  /// switching back shows exactly what was there. A session that is finished
  /// under the new view stops.
  void setCountScope(CountScope scope) {
    if (scope == state.scope) return;
    _emit(_retarget(state.copyWith(scope: scope)));
  }

  /// Sets the Rhythm pace. Out-of-range values are clamped; callers should
  /// validate user input first (see `checkPace`) and ignore invalid text.
  void setRhythmSeconds(double seconds) {
    if (!seconds.isFinite) return;
    _emit(state.copyWith(
        rhythmSeconds: seconds.clamp(minRhythmSeconds, maxRhythmSeconds)));
  }

  // ---- internals ---------------------------------------------------------

  /// After the target (or the counting scope) changed: `completed` is derived
  /// so a raised target re-opens a finished session by itself; here we only
  /// stop anything that is still running on a session that is now done.
  SadhanaState _retarget(SadhanaState s) =>
      s.completed && s.running ? s.copyWith(running: false) : s;

  void _emit(SadhanaState next) {
    final previous = state;
    state = next;
    if (previous.running != next.running ||
        previous.mode != next.mode ||
        previous.targetType != next.targetType ||
        previous.rhythmSeconds != next.rhythmSeconds ||
        previous.targetSeconds != next.targetSeconds ||
        previous.targetCount != next.targetCount ||
        previous.scope != next.scope ||
        previous.completed != next.completed) {
      _syncTimers(fresh: !previous.running);
      _syncInputs();
    }
    _syncMalaService();
    _persist();
  }

  /// Saves the session, and while it runs, the moments it is measured from
  /// (so a relaunch after the app was closed can catch up).
  void _persist() {
    final s = state;
    final running = s.running && !s.completed;
    int? ms(DateTime? t) => t?.millisecondsSinceEpoch;
    AppStorage.settings.put(_storageKey, {
      ...s.toMap(),
      if (running) ...{
        'running': true,
        'tickAt': ms(_lastTickAt),
        'beatAt': ms(_lastBeatAt),
        'endsAt': ms(_endsAt),
        'alarmSet': _alarmScheduled,
      },
      if (_malaSessionId != null) 'malaSession': _malaSessionId,
    });
  }

  /// Starts or stops the clock and rhythm timers, and sets or removes the
  /// phone's finish alarm, to match the state. [fresh]: the session has just
  /// been started or resumed, so it is measured from now; otherwise (the
  /// target or pace changed mid-run, or a relaunch) from where it was.
  void _syncTimers({required bool fresh}) {
    _cancelTimers();
    final s = state;
    if (!s.running || s.completed) {
      _lastTickAt = _lastBeatAt = _endsAt = null;
      // Finished in the background: that alarm is left to ring.
      if (_heldAlarmAt == null) _setAlarm(null);
      return;
    }
    _heldAlarmAt = null;
    final now = _now();
    if (fresh) _lastTickAt = _lastBeatAt = null;
    _lastTickAt ??= now;
    _lastBeatAt ??= now;
    _endsAt = _predictEnd(s);
    if (s.isTimeTarget) _scheduleClockTick();
    if (s.mode == CountMode.rhythm) _scheduleBeat();
    _setAlarm(_endsAt?.add(alarmMargin));
  }

  Duration _pace(SadhanaState s) =>
      Duration(microseconds: (s.rhythmSeconds * 1000000).round());

  /// When the running session will reach its target, or null when that
  /// depends on the user (Tap, Voice and Mala count targets).
  DateTime? _predictEnd(SadhanaState s) {
    if (s.isTimeTarget) {
      return _lastTickAt?.add(Duration(seconds: s.targetSeconds - s.elapsedSeconds));
    }
    if (s.mode == CountMode.rhythm) {
      final left = math.max(0, s.targetCount - s.count);
      return _lastBeatAt?.add(_pace(s) * left);
    }
    return null;
  }

  /// The next clock tick, when the next whole second falls due (never
  /// longer than a second away).
  void _scheduleClockTick() {
    _clock?.cancel();
    _clock = Timer(_until(_lastTickAt!.add(const Duration(seconds: 1)),
        const Duration(seconds: 1)), _tickClock);
  }

  /// The next Rhythm beat, when it falls due (never longer than a pace away).
  void _scheduleBeat() {
    _rhythm?.cancel();
    final pace = _pace(state);
    _rhythm = Timer(_until(_lastBeatAt!.add(pace), pace), _beat);
  }

  Duration _until(DateTime due, Duration max) {
    final d = due.difference(_now());
    if (d.isNegative) return Duration.zero;
    return d > max ? max : d;
  }

  /// One second of the time target has passed (or, if the timer was held
  /// back, a whole stretch of them: the real clock decides how many).
  void _tickClock() {
    _clock = null;
    final s = state;
    if (!s.running || s.completed || !s.isTimeTarget) return;
    final now = _now();
    final last = _lastTickAt ?? now;
    var add = now.difference(last).inSeconds;
    if (add < 1) add = 1; // a normal tick (and tests with a frozen clock)
    _lastTickAt = last.add(Duration(seconds: add));
    add = math.min(add, s.remainingSeconds);
    final next = s.withProgress(s.activeProgress
        .copyWith(elapsedSeconds: s.activeProgress.elapsedSeconds + add));
    if (next.completed) {
      _finish(next);
      return;
    }
    _emit(next);
    _scheduleClockTick();
  }

  /// One Rhythm beat (or, if the timer was held back, as many as fell due).
  void _beat() {
    _rhythm = null;
    final s = state;
    if (!s.running || s.completed || s.mode != CountMode.rhythm) return;
    final now = _now();
    final last = _lastBeatAt ?? now;
    final pace = _pace(s);
    var beats = now.difference(last).inMicroseconds ~/ pace.inMicroseconds;
    if (beats < 1) beats = 1; // a normal beat (and tests with a frozen clock)
    _lastBeatAt = last.add(pace * beats);
    if (!s.isTimeTarget) beats = math.min(beats, s.targetCount - s.count);
    _addCounts(beats);
    if (state.running && !state.completed) _scheduleBeat();
  }

  /// [s] moved on to [now] by the real clock: the time elapsed (time target)
  /// and the Rhythm beats that fell due (never past the target, and for a
  /// time target never past its end). Advances the anchors to match.
  SadhanaState _caughtUp(SadhanaState s, DateTime now) {
    var next = s;
    if (s.isTimeTarget && _lastTickAt != null) {
      final add = now.difference(_lastTickAt!).inSeconds;
      if (add > 0) {
        _lastTickAt = _lastTickAt!.add(Duration(seconds: add));
        final p = next.activeProgress;
        next = next.withProgress(p.copyWith(
            elapsedSeconds: p.elapsedSeconds + math.min(add, next.remainingSeconds)));
      }
    }
    if (s.mode == CountMode.rhythm && _lastBeatAt != null) {
      final end = _endsAt;
      final until = s.isTimeTarget && end != null && end.isBefore(now) ? end : now;
      final pace = _pace(s);
      var beats = until.difference(_lastBeatAt!).inMicroseconds ~/ pace.inMicroseconds;
      if (beats > 0) {
        _lastBeatAt = _lastBeatAt!.add(pace * beats);
        if (!s.isTimeTarget) beats = math.min(beats, s.targetCount - s.count);
        final p = next.activeProgress;
        next = next.withProgress(p.copyWith(count: p.count + math.max(0, beats)));
      }
    }
    return next;
  }

  /// The app is back on screen: bring a running session up to the real clock
  /// at once (the screen shows the right number immediately).
  void _catchUp() {
    final s = state;
    if (!s.running || s.completed) return;
    final next = _caughtUp(s, _now());
    if (identical(next, s)) return;
    if (next.completed) {
      _finish(next);
      return;
    }
    _emit(next);
    // The anchors moved: re-align the pending tick and beat to them.
    if (next.isTimeTarget) _scheduleClockTick();
    if (next.mode == CountMode.rhythm) _scheduleBeat();
  }

  /// The target was reached: stop, and ring ONCE, in the app or on the phone.
  void _finish(SadhanaState next) {
    final ring = _shouldRing(_now());
    if (ring == _Ring.phone) _heldAlarmAt = _endsAt!.add(alarmMargin);
    _emit(next.copyWith(running: false));
    if (ring == _Ring.app) _targetReached();
  }

  /// Who rings for a session that finishes now:
  /// - the app is on screen and the phone's alarm has not rung yet: the app
  ///   (the alarm is cancelled);
  /// - in the background before the alarm: the phone's alarm (the app may not
  ///   be allowed to make sound or vibrate from the background);
  /// - the alarm has already rung (the app was away): nobody again;
  /// - no alarm could be set: the app, unless it is very late.
  _Ring _shouldRing(DateTime now) {
    final end = _endsAt;
    if (end == null) return _Ring.app; // not a scheduled finish
    if (!_alarmScheduled) {
      return now.difference(end) <= lateRingLimit ? _Ring.app : _Ring.none;
    }
    if (!now.isBefore(end.add(alarmMargin))) return _Ring.none;
    return _foreground ? _Ring.app : _Ring.phone;
  }

  static bool _isForeground(AppLifecycleState s) =>
      s == AppLifecycleState.resumed || s == AppLifecycleState.inactive;

  void _onLifecycle(AppLifecycleState s) {
    _foreground = _isForeground(s);
    if (s == AppLifecycleState.resumed && !_disposed) _onResume();
  }

  /// Back on screen (unlocked, switched back, or opened from the alarm).
  void _onResume() {
    // Mala counted on in the background: catch up.
    if (_malaSessionId != null) unawaited(_reconnectMala());
    final held = _heldAlarmAt;
    if (held != null) {
      // Finished while away. If the phone has not rung yet, ring here instead.
      _heldAlarmAt = null;
      if (_now().isBefore(held)) _targetReached();
      _setAlarm(null);
    }
    _catchUp();
    if (!state.running) {
      // An alarm that rang while away is still on screen: dismissing it also
      // stops one that keeps ringing until dismissed.
      unawaited(_scheduler
          .dismissShown(sadhanaTimerGroup)
          .catchError((Object _) {}));
    } else if (state.alarmMayBeLate && _endsAt != null) {
      // Exact alarms may have been allowed in the settings meanwhile.
      _setAlarm(_endsAt!.add(alarmMargin));
    }
  }

  /// How the finish alarm sounds, from the completion settings: the chosen
  /// ringtone (or silent), vibration on/off, and ringing until dismissed when
  /// the sound or the vibration is set to "Until stopped".
  AlarmStyle _alarmStyle() {
    final c = ref.read(completionSettingsProvider);
    final ring = c.ringtoneEnabled;
    final vib = c.vibrationEnabled;
    return AlarmStyle(
      sound: ring ? c.ringtone.rawName : null,
      soundLabel: c.ringtone.localized(ref.read(l10nProvider)),
      vibrate: vib,
      insistent: (ring && c.soundRepeat == SoundRepeat.untilStopped) ||
          (vib && c.vibrationRepeat == VibrationRepeat.untilStopped),
    );
  }

  /// Puts (or, with null, removes) the phone alarm that rings at the end of a
  /// session with a predictable end, even when the app is not running.
  Future<void> _setAlarm(DateTime? at) async {
    final gen = ++_alarmGen;
    if (at == null) {
      final had = _alarmScheduled;
      _alarmScheduled = false;
      if (state.alarmMayBeLate) state = state.copyWith(alarmMayBeLate: false);
      if (had || gen == 1) {
        try {
          await _scheduler.replaceAlerts(sadhanaTimerGroup, const []);
        } catch (e) {
          debugPrint('Could not cancel the session ring: $e');
        }
      }
      return;
    }
    try {
      if (!_askedNotifications) {
        _askedNotifications = true;
        if (!await _scheduler.requestPermission()) {
          unawaited(_explainOnce());
          return;
        }
      }
      if (gen != _alarmGen || _disposed) return; // paused or changed meanwhile
      final l = ref.read(l10nProvider);
      await _scheduler.replaceAlerts(sadhanaTimerGroup, [
        ScheduledAlert(
          id: reminderId(sadhanaTimerGroup, 0, 0),
          when: at,
          title: l.sadhanaRingTitle,
          body: l.sadhanaRingBody,
          style: _alarmStyle(),
        ),
      ]);
      if (gen != _alarmGen || _disposed) return;
      _alarmScheduled = true;
      _persist();
      await _checkAlarmPermissions(gen);
    } catch (e) {
      debugPrint('Could not schedule the session ring: $e');
    }
  }

  /// Exact alarms, then full-screen alarms: each is explained and offered
  /// once. Without exact alarms the alarm still rings, a little flexibly, and
  /// the screen says so; without full screen it is a heads-up notification.
  Future<void> _checkAlarmPermissions(int gen) async {
    final exact = await _scheduler.canScheduleExact();
    if (gen != _alarmGen || _disposed) return;
    if (state.alarmMayBeLate == exact) {
      state = state.copyWith(alarmMayBeLate: !exact);
    }
    if (await _explainOnce()) return;
    if (gen != _alarmGen || _disposed) return;
    final l = ref.read(l10nProvider);
    if (!exact) {
      _offerOnce(askedExactKey, l.exactAlarmNotice, () async {
        if (await _scheduler.requestExactAlarms() &&
            !_disposed &&
            _alarmScheduled &&
            _endsAt != null) {
          _setAlarm(_endsAt!.add(alarmMargin)); // now exact
        }
      });
      return;
    }
    if (!await _scheduler.canUseFullScreen()) {
      if (gen != _alarmGen || _disposed) return;
      _offerOnce(askedFullScreenKey, l.fullScreenNotice,
          () => unawaited(_scheduler.requestFullScreen()));
    }
  }

  /// The first time a session with a predictable end starts: a short note
  /// that it will ring like an alarm, and, if the phone is not set up for
  /// that, a button to "Alarms & reliability" (which also covers the separate
  /// exact-alarm and full-screen offers). True if it was shown now.
  Future<bool> _explainOnce() async {
    if (AppStorage.settings.get(alarmExplainedKey) == true) return false;
    AppStorage.settings.put(alarmExplainedKey, true);
    AlarmHealthStatus health;
    try {
      health = await ref.read(alarmHealthProvider).check();
    } catch (_) {
      health = AlarmHealthStatus.unknownOk;
    }
    if (_disposed) return true;
    final l = ref.read(l10nProvider);
    final notices = ref.read(sessionNoticeProvider.notifier);
    if (health.allOk) {
      notices.show(l.alarmExplainerOk);
    } else {
      AppStorage.settings.put(askedExactKey, true);
      AppStorage.settings.put(askedFullScreenKey, true);
      notices.show(l.alarmExplainerAttention,
          actionLabel: l.alarmExplainerCheck, openAlarmsPage: true);
    }
    return true;
  }

  void _offerOnce(String key, String message, void Function() allow) {
    if (AppStorage.settings.get(key) == true) return;
    AppStorage.settings.put(key, true);
    ref.read(sessionNoticeProvider.notifier).show(
          message,
          actionLabel: ref.read(l10nProvider).allowAction,
          onAction: () {
            try {
              allow();
            } catch (e) {
              debugPrint('Permission request failed: $e');
            }
          },
        );
  }

  void _cancelTimers() {
    _clock?.cancel();
    _rhythm?.cancel();
    _clock = _rhythm = null;
  }

  // ---- voice + volume-button inputs -----------------------------------------

  /// Starts/stops the microphone and volume-key capture to match the state:
  /// each is live only while Start is on, the target is not yet reached, and
  /// its mode is selected.
  void _syncInputs() {
    final s = state;
    final active = s.running && !s.completed;
    final wantVoice = active && s.mode == CountMode.voice;
    final wantMala = active && s.mode == CountMode.mala;

    if (wantVoice && !_voiceActive) unawaited(_startVoice());
    if (!wantVoice && _voiceActive) _stopVoice();
    if (wantMala && !_malaActive) unawaited(_startMala());
    if (!wantMala && _malaActive) _stopMala();
  }

  Future<void> _startVoice() async {
    _voiceActive = true;
    final gen = ++_voiceGen;
    final training = ref.read(voiceTrainingProvider)[state.mantraId];
    if (training == null || !training.isUsable) {
      // Cleared while paused, or reached without going through Start.
      _voiceActive = false;
      _emit(state.copyWith(running: false));
      ref.read(sessionNoticeProvider.notifier).show(
            ref.read(l10nProvider).trainFirstPrompt(minTrainingSamples, maxTrainingSamples),
            trainMantraId: state.mantraId,
          );
      return;
    }
    var heard = 0;
    final result = await _voice.start(
      model: training.toModel(),
      sensitivity: ref.read(voiceSensitivityProvider),
      onCandidate: (c) {
        if (!_voiceActive || gen != _voiceGen) return;
        state = state.copyWith(
          lastVoice: VoiceHitInfo(
            seq: ++heard,
            counted: c.matched,
            closeness: c.closeness,
          ),
        );
        // Count IMMEDIATELY on a match; everything else is ignored.
        if (c.matched) increment();
      },
      onStopped: (message) {
        if (_disposed || !_voiceActive || gen != _voiceGen) return;
        // The microphone gave up by itself: pause (not Tap) so the user can retry.
        _voiceActive = false;
        _emit(state.copyWith(
            running: false, inputActive: false, clearLastVoice: true));
        // `message` comes from the pure-Dart mic engine (always in English);
        // translate it for display here, where it turns into a user-facing
        // notice.
        ref.read(sessionNoticeProvider.notifier).show(
            sadhanaEngineMessage(ref.read(l10nProvider), message));
      },
    );
    if (_disposed) return;
    if (!_voiceActive || gen != _voiceGen) {
      // Paused or switched while the permission dialog was up.
      if (result == VoiceStartResult.started) unawaited(_voice.stop());
      return;
    }
    if (result == VoiceStartResult.started) {
      state = state.copyWith(inputActive: true);
      return;
    }
    _voiceActive = false;
    final startL10n = ref.read(l10nProvider);
    _fallbackToTap(
      switch (result) {
        VoiceStartResult.denied => startL10n.fallbackVoiceDenied,
        VoiceStartResult.permanentlyDenied => startL10n.fallbackVoiceBlocked,
        VoiceStartResult.unsupported => startL10n.fallbackVoiceUnsupported,
        _ => startL10n.fallbackVoiceNoMic,
      },
      openSettings: result == VoiceStartResult.permanentlyDenied,
    );
  }

  void _stopVoice() {
    _voiceActive = false;
    _voiceGen++;
    unawaited(_voice.stop());
    if (state.inputActive || state.lastVoice != null) {
      state = state.copyWith(inputActive: false, clearLastVoice: true);
    }
  }

  Future<void> _startMala() async {
    _malaActive = true;
    final gen = ++_malaGen;
    if (_mala.isSupported) {
      if (await _startMalaService(gen)) return;
      if (_disposed || !_malaActive || gen != _malaGen) return;
    }
    _malaVia = _MalaVia.listener;
    final ok = await _volume.start(() {
      if (_malaActive && gen == _malaGen) increment();
    });
    if (_disposed) return;
    if (!_malaActive || gen != _malaGen) {
      if (ok) unawaited(_volume.stop());
      return;
    }
    if (ok) {
      state = state.copyWith(inputActive: true);
      return;
    }
    _malaActive = false;
    _malaVia = _MalaVia.none;
    _fallbackToTap(ref.read(l10nProvider).fallbackMalaUnsupported);
  }

  /// Starts (or takes back from its notification's pause) the background
  /// counter. True if it counts now, or the start was overtaken by a pause
  /// or a switch; false to fall back to the in-app listener.
  Future<bool> _startMalaService(int gen) async {
    if (!_malaServiceAlive || _malaSessionId == null) {
      _malaSessionId = 'mala-${_now().microsecondsSinceEpoch}';
    }
    _malaMantraId = state.mantraId;
    _malaVia = _MalaVia.service;
    _malaPausedByService = false;
    _malaReachedViaService = false;
    final ok = await _mala.start(_malaConfig());
    if (_disposed) return true;
    if (ok) {
      _malaServiceAlive = true;
      _malaPushed = _malaNumbers(state);
    }
    if (!_malaActive || gen != _malaGen) {
      // Paused or switched while it started: settle it to the session now.
      _syncMalaService();
      return true;
    }
    if (ok) {
      state = state.copyWith(inputActive: true, malaScreenOff: true);
      _persist();
      return true;
    }
    _malaVia = _MalaVia.none;
    _malaSessionId = null;
    _noticeMalaFallbackOnce();
    return false;
  }

  void _stopMala() {
    _malaActive = false;
    _malaGen++;
    // The service is settled by _syncMalaService (it may stay on).
    if (_malaVia != _MalaVia.service) {
      _malaVia = _MalaVia.none;
      unawaited(_volume.stop());
    }
    if (state.inputActive || state.malaScreenOff) {
      state = state.copyWith(inputActive: false, malaScreenOff: false);
    }
  }

  /// Screen-off counting could not start: said once, then the volume keys
  /// count only while the app is on screen.
  void _noticeMalaFallbackOnce() {
    if (AppStorage.settings.get(malaFallbackNoticeKey) == true) return;
    AppStorage.settings.put(malaFallbackNoticeKey, true);
    ref
        .read(sessionNoticeProvider.notifier)
        .show(ref.read(l10nProvider).malaScreenOffUnavailable);
  }

  // ---- the background Mala service ----------------------------------------

  /// Other modes' counts that add to Mala's toward the target (Combined).
  int _malaBase(SadhanaState s) => s.isSeparate
      ? 0
      : s.totalProgress.count - s.progressOf(CountMode.mala).count;

  /// A time target never finishes on a count: the service never "reaches".
  static const _noCountTarget = 1 << 30;

  int _malaTarget(SadhanaState s) =>
      s.isTimeTarget ? _noCountTarget : s.targetCount;

  (int, int, int) _malaNumbers(SadhanaState s) =>
      (s.progressOf(CountMode.mala).count, _malaBase(s), _malaTarget(s));

  MalaServiceConfig _malaConfig() {
    final s = state;
    final c = ref.read(completionSettingsProvider);
    final l = ref.read(l10nProvider);
    final style = _alarmStyle();
    final channel = sadhanaAlarmChannel(style, l);
    return MalaServiceConfig(
      sessionId: _malaSessionId!,
      count: s.progressOf(CountMode.mala).count,
      base: _malaBase(s),
      target: _malaTarget(s),
      vibration: c.vibrationEnabled,
      milestoneEvery: milestoneEvery,
      milestoneMs: DeviceFeedbackService.pulseMs(c.vibrationLevel),
      milestoneAmplitude: DeviceFeedbackService.amplitudeFor(c.vibrationLevel),
      ackMs: DeviceFeedbackService.ackMs(c.vibrationLevel),
      ackAmplitude: DeviceFeedbackService.amplitudeFor(c.vibrationLevel),
      ring: MalaRing(
        channelId: channel.id,
        channelName: channel.name,
        channelDescription: channel.description,
        sound: style.sound,
        vibrate: style.vibrate,
        insistent: style.insistent,
        title: l.malaRingTitle,
        body: l.malaRingBody(s.targetCount),
      ),
      text: MalaNotificationText(
        channel: l.malaNotificationChannel,
        title: s.isTimeTarget
            ? l.malaNotificationTitleCount('{count}')
            : l.malaNotificationTitle('{count}', '{target}'),
        running: l.malaNotificationRunning,
        paused: l.pausedHeadline,
        done: l.malaNotificationDone,
        pause: l.pause,
        resume: l.resume,
        stop: l.stop,
      ),
    );
  }

  /// Keeps the service in step with the session: it stays on only while this
  /// Mala session runs, is paused from its notification, or ticks after the
  /// target; anything else (Pause, Reset, another mode or mantra, a raised
  /// target...) stops it. Otherwise it gets the new count / target.
  void _syncMalaService() {
    if (!_malaServiceAlive || _malaCatchingUp) return;
    final s = state;
    final keep = s.mode == CountMode.mala &&
        s.mantraId == _malaMantraId &&
        ((_malaActive && s.running && !s.completed) ||
            (_malaPausedByService && !s.running && !s.completed) ||
            (_malaReachedViaService && s.completed && !s.isTimeTarget));
    if (!keep) {
      _stopMalaService();
      return;
    }
    _pushMala();
  }

  void _pushMala({bool force = false}) {
    final n = _malaNumbers(state);
    if (!force && n == _malaPushed) return;
    _malaPushed = n;
    unawaited(_mala.update(_malaConfig()));
  }

  void _stopMalaService({bool tell = true}) {
    _malaServiceAlive = false;
    _malaPausedByService = false;
    _malaReachedViaService = false;
    _malaPushed = null;
    _malaSessionId = null;
    if (_malaVia == _MalaVia.service) _malaVia = _MalaVia.none;
    if (tell) unawaited(_mala.stop());
    if (state.malaScreenOff) state = state.copyWith(malaScreenOff: false);
  }

  /// Something the service did: counted a press, or was paused, resumed or
  /// stopped from its notification.
  void _onMalaEvent(MalaServiceEvent e) {
    if (_disposed || !ref.mounted) return;
    final id = e.state.sessionId;
    if (id == null || id != _malaSessionId) return; // an older session
    switch (e.kind) {
      case 'count':
        _adoptMala(e.state, feedback: e.feedback);
      case 'paused':
        _adoptMala(e.state);
        _malaPausedByService = true;
        if (state.running && state.mode == CountMode.mala) {
          _emit(state.copyWith(running: false));
        }
      case 'resumed':
        _malaPausedByService = false;
        final s = state;
        if (!s.running && !s.completed && s.mode == CountMode.mala) {
          _malaActive = true;
          _malaGen++;
          _malaVia = _MalaVia.service;
          _emit(s.copyWith(running: true, inputActive: true, malaScreenOff: true));
        }
      case 'stopped':
        _adoptMala(e.state);
        _stopMalaService(tell: false);
        _malaActive = false;
        if (state.running && state.mode == CountMode.mala) {
          _emit(state.copyWith(running: false));
        } else {
          _persist();
        }
    }
  }

  /// Takes the service's count as the Mala count (capped at the target). If
  /// that reaches the target, the session finishes; the app rings only if
  /// the service says so ([feedback]), or, catching up, if it did not ring.
  void _adoptMala(MalaServiceState st,
      {MalaAppFeedback feedback = MalaAppFeedback.none, bool catchUp = false}) {
    final s = state;
    if (s.mode != CountMode.mala) return;
    var count = st.count;
    if (!s.isTimeTarget) {
      count = math.min(count, math.max(0, s.targetCount - _malaBase(s)));
    }
    final p = s.progressOf(CountMode.mala);
    if (count != p.count) {
      final next = s.withProgress(p.copyWith(count: count));
      _malaPushed = _malaNumbers(next);
      if (!s.completed && next.completed && !next.isTimeTarget) {
        _malaReachedViaService = _malaServiceAlive;
        _emit(next.copyWith(running: false));
        final ringHere = catchUp ? !st.rang : feedback == MalaAppFeedback.ring;
        if (ringHere) _targetReached();
        return;
      }
      _emit(next);
    }
    final fb = ref.read(feedbackServiceProvider);
    switch (feedback) {
      case MalaAppFeedback.milestone:
        fb.milestone();
      case MalaAppFeedback.ack:
        fb.acknowledge();
      case MalaAppFeedback.ring:
      case MalaAppFeedback.none:
        break;
    }
  }

  /// Back on screen, or relaunched: reads the service's saved state and
  /// catches up (the service may have counted, paused, stopped or rung while
  /// the app was away or closed).
  Future<void> _reconnectMala() async {
    final id = _malaSessionId;
    if (id == null) return;
    final st = await _mala.currentState();
    if (_disposed || !ref.mounted || id != _malaSessionId) return;
    if (st == null || st.sessionId != id) {
      // The service knows nothing of it (the phone restarted, say).
      if (!_malaServiceAlive) {
        _malaSessionId = null;
        _persist();
      }
      return;
    }
    if (st.status != MalaServiceStatus.stopped && !_malaServiceAlive) {
      // Relaunched while it still counts: take it over.
      _malaServiceAlive = true;
      _malaVia = _MalaVia.service;
      _malaMantraId = state.mantraId;
    }
    _malaCatchingUp = true;
    try {
      switch (st.status) {
        case MalaServiceStatus.running:
          _malaPausedByService = false;
        case MalaServiceStatus.paused:
          _malaPausedByService = true;
        case MalaServiceStatus.stopped:
          break;
      }
      _adoptMala(st, catchUp: true);
      if (!ref.mounted || _malaSessionId != id) return;
      final s = state;
      if (st.status == MalaServiceStatus.running &&
          s.mode == CountMode.mala &&
          !s.completed) {
        _malaActive = true;
        _malaGen++;
        if (!s.running) {
          _emit(s.copyWith(running: true, inputActive: true, malaScreenOff: true));
        }
      } else if (st.status == MalaServiceStatus.running && s.completed) {
        _malaReachedViaService = true;
      }
    } finally {
      _malaCatchingUp = false;
    }
    if (st.status == MalaServiceStatus.stopped) {
      _stopMalaService(tell: false);
      _persist();
    } else {
      _syncMalaService();
    }
    // An alarm that rang while away stops when the app is back.
    if (st.rang) unawaited(_mala.dismissRing());
  }

  /// Leaves Voice/Mala for Tap and tells the user why.
  void _fallbackToTap(String message, {bool openSettings = false}) {
    _emit(state.copyWith(
      mode: CountMode.tap,
      running: false,
      inputActive: false,
    ));
    ref
        .read(sessionNoticeProvider.notifier)
        .show(message, openSettings: openSettings);
  }
}

final sadhanaSessionProvider =
    NotifierProvider<SadhanaSessionNotifier, SadhanaState>(
  SadhanaSessionNotifier.new,
);

/// Who rings when a session finishes (see `_shouldRing`).
enum _Ring { app, phone, none }

/// What counts Mala's volume keys right now.
enum _MalaVia {
  none,

  /// The native background service (screen on or off).
  service,

  /// The in-app listener (the fallback; the screen must stay on).
  listener,
}

/// Tells the session when the app goes to the background and comes back, so
/// a session that ran on (or out) while the phone was locked is caught up at
/// once, and rings only once.
class _ResumeWatcher with WidgetsBindingObserver {
  _ResumeWatcher(this.onChange);

  final void Function(AppLifecycleState state) onChange;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => onChange(state);
}
