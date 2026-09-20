import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../services/feedback_service.dart';
import '../services/voice_counter_service.dart';
import '../services/volume_button_service.dart';
import '../voice/match_model.dart';
import 'rhythm_pace.dart';
import 'session_notice_provider.dart';
import 'voice_training_provider.dart';

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
class SadhanaSessionNotifier extends Notifier<SadhanaState> {
  static const _storageKey = 'sadhana.session';

  Timer? _clock;
  Timer? _rhythm;

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

  @override
  SadhanaState build() {
    // Read once here: ref cannot be used inside onDispose.
    _voice = ref.read(voiceCounterServiceProvider);
    _volume = ref.read(volumeButtonServiceProvider);
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _cancelTimers();
      if (_voiceActive) unawaited(_voice.stop());
      if (_malaActive) unawaited(_volume.stop());
    });
    // The Strict ↔ Lenient slider takes effect on a listening session at once.
    ref.listen(voiceSensitivityProvider, (_, v) {
      if (_voiceActive) _voice.setSensitivity(v);
    });
    return SadhanaState.fromMap(AppStorage.settings.get(_storageKey) as Map?);
  }

  // ---- counting ----------------------------------------------------------

  /// A tap on the screen (the ring, or anywhere in Focus mode). It counts ONLY
  /// in Tap mode: in Voice, Rhythm and Mala the only things that count are that
  /// mode's own input (a voice match, the rhythm timer, a volume key), plus the
  /// deliberate + / − buttons, which call [increment] / [decrement] directly.
  void tap() {
    if (state.mode == CountMode.tap) increment();
  }

  /// Adds one count to the active mode. Ignored once the target has been
  /// reached. Called by every mode's own input and by the + button.
  void increment() {
    final s = state;
    if (s.completed) return;

    var next = s.withProgress(
        s.activeProgress.copyWith(count: s.activeProgress.count + 1));
    // In Tap mode with a time target the clock starts on the first tap.
    if (s.isTimeTarget && s.mode == CountMode.tap && !s.running) {
      next = next.copyWith(running: true);
    }

    final reachedTarget = !next.isTimeTarget && next.completed;
    if (reachedTarget) next = next.copyWith(running: false);
    _emit(next);

    final feedback = ref.read(feedbackServiceProvider);
    if (reachedTarget) {
      feedback.complete();
    } else if (next.count % milestoneEvery == 0) {
      feedback.milestone();
    }
  }

  /// Manual correction: takes one off the shown count (never below zero).
  /// Available in every mode, e.g. when Voice counted a rep that was not one.
  void decrement() {
    final next = state.decremented();
    if (next != null) _emit(next);
  }

  /// Stops whatever is running (microphone, volume keys, timers), keeping the
  /// count. Used before another screen needs the microphone.
  void pause() {
    if (state.running) _emit(state.copyWith(running: false));
  }

  /// Zeroes the shown count: every mode's (Combined) or only the active
  /// mode's own (Separate).
  void reset() => _emit(state.cleared().copyWith(running: false));

  /// Starts/pauses whatever the mode runs: the rhythm pace, the microphone
  /// (Voice), volume-key capture (Mala) and/or the session clock.
  void toggleRunning() {
    if (state.completed) return;
    if (!state.running && state.mode == CountMode.voice && !_voiceTrained()) {
      // Voice only counts a mantra it has been trained on.
      ref.read(sessionNoticeProvider.notifier).show(
            'Train your voice for this mantra first: record it $minTrainingSamples to $maxTrainingSamples times.',
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
    final unsupported = switch (mode) {
      CountMode.voice when !_voice.isSupported =>
        '$voiceUnsupportedText. Using Tap mode.',
      CountMode.mala when !_volume.isSupported =>
        '$malaUnsupportedText. Using Tap mode.',
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
    AppStorage.settings.put(_storageKey, next.toMap());
    if (previous.running != next.running ||
        previous.mode != next.mode ||
        previous.targetType != next.targetType ||
        previous.rhythmSeconds != next.rhythmSeconds ||
        previous.completed != next.completed) {
      _syncTimers();
      _syncInputs();
    }
  }

  void _syncTimers() {
    _cancelTimers();
    final s = state;
    if (!s.running || s.completed) return;

    if (s.isTimeTarget) {
      _clock = Timer.periodic(const Duration(seconds: 1), (_) => _tickClock());
    }
    if (s.mode == CountMode.rhythm) {
      _rhythm = Timer.periodic(
        Duration(milliseconds: (s.rhythmSeconds * 1000).round()),
        (_) => increment(),
      );
    }
  }

  void _tickClock() {
    final s = state;
    if (!s.running || s.completed) return;
    var next = s.withProgress(s.activeProgress
        .copyWith(elapsedSeconds: s.activeProgress.elapsedSeconds + 1));
    final done = next.elapsedSeconds >= next.targetSeconds;
    if (done) next = next.copyWith(running: false);
    _emit(next);
    if (done) ref.read(feedbackServiceProvider).complete();
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
            'Train your voice for this mantra first: record it $minTrainingSamples to $maxTrainingSamples times.',
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
        ref.read(sessionNoticeProvider.notifier).show(message);
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
    _fallbackToTap(
      switch (result) {
        VoiceStartResult.denied =>
          'Microphone permission was denied, so Voice counting cannot listen. Using Tap mode.',
        VoiceStartResult.permanentlyDenied =>
          'Microphone access is blocked. Allow it in Settings to use Voice counting. Using Tap mode.',
        VoiceStartResult.unsupported => '$voiceUnsupportedText. Using Tap mode.',
        _ => '$voiceNoMicText. Using Tap mode.',
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
    _fallbackToTap(
      '$malaUnsupportedText. Using Tap mode.',
    );
  }

  void _stopMala() {
    _malaActive = false;
    _malaGen++;
    unawaited(_volume.stop());
    if (state.inputActive) state = state.copyWith(inputActive: false);
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
