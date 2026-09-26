import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:advance_calendar/core/links.dart';
import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/alarms/services/alarm_health.dart';
import 'package:advance_calendar/features/calendar/application/now_provider.dart';
import 'package:advance_calendar/features/sadhana/application/voice_training_provider.dart';
import 'package:advance_calendar/features/sadhana/data/ringtone.dart';
import 'package:advance_calendar/features/sadhana/services/dnd_driver.dart';
import 'package:advance_calendar/features/sadhana/services/feedback_service.dart';
import 'package:advance_calendar/features/sadhana/services/mala_background_service.dart';
import 'package:advance_calendar/features/sadhana/services/pcm_input.dart';
import 'package:advance_calendar/features/sadhana/services/screen_awake.dart';
import 'package:advance_calendar/features/sadhana/services/voice_counter_service.dart';
import 'package:advance_calendar/features/sadhana/services/volume_button_service.dart';
import 'package:advance_calendar/features/sadhana/voice/match_model.dart';
import 'package:advance_calendar/features/sadhana/voice/mfcc.dart';
import 'package:advance_calendar/features/shell/services/lock_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../calendar/calendar_support.dart' show FakeNow;

class FakeFeedback implements FeedbackService {
  int milestones = 0;
  int completions = 0;
  int acknowledgements = 0;
  int alertStops = 0;

  @override
  final ValueNotifier<bool> alerting = ValueNotifier<bool>(false);

  @override
  Future<void> milestone() async => milestones++;

  @override
  Future<void> complete() async => completions++;

  /// Counted as a completion too: it is the Sadhana session's completion.
  @override
  void completionAlert() => completions++;

  @override
  void stopAlert() {
    alertStops++;
    alerting.value = false;
  }

  @override
  Future<void> acknowledge() async => acknowledgements++;

  @override
  Future<void> previewRingtone(Ringtone ringtone) async {}

  @override
  Future<void> previewVibration({required bool strong}) async {}
}

/// One call made to the vibrator.
class HapticCall {
  const HapticCall({
    required this.duration,
    required this.amplitude,
    required this.pattern,
    required this.intensities,
  });

  final int duration;
  final int amplitude;
  final List<int> pattern;
  final List<int> intensities;

  /// A pattern (the completion buzz) rather than a single pulse.
  bool get isPattern => pattern.isNotEmpty;

  /// How long the buzz lasts in total, in ms.
  int get totalMs => isPattern ? pattern.fold(0, (a, b) => a + b) : duration;
}

/// Scriptable stand-in for the phone's vibrator.
class FakeHaptics implements HapticsDriver {
  FakeHaptics({this.vibrator = true, this.amplitude = true, this.failing = false});

  final bool vibrator;
  final bool amplitude;

  /// Every call throws, like a broken plugin.
  bool failing;
  final calls = <HapticCall>[];

  @override
  Future<bool> hasVibrator() async => vibrator;

  @override
  Future<bool> hasAmplitudeControl() async => amplitude;

  @override
  Future<void> vibrate({
    int duration = 0,
    int amplitude = -1,
    List<int> pattern = const [],
    List<int> intensities = const [],
  }) async {
    if (failing) throw StateError('vibrator failed');
    calls.add(HapticCall(
        duration: duration,
        amplitude: amplitude,
        pattern: pattern,
        intensities: intensities));
  }

  int cancels = 0;

  @override
  Future<void> cancel() async => cancels++;
}

/// Scriptable stand-in for the sound player.
///
/// By default a sound ends as soon as it starts; with [length] it lasts that
/// long (on the test's clock), or until [stop].
class FakeSound implements SoundDriver {
  FakeSound({this.failing = false, this.length});

  bool failing;
  final Duration? length;
  final plays = <String>[];
  int stops = 0;
  Completer<void>? _playing;
  Timer? _end;

  /// A sound is playing right now.
  bool get isPlaying => _playing != null;

  @override
  Future<void> play(String asset) async {
    if (failing) throw StateError('player failed');
    plays.add(asset);
    if (length == null) return;
    _finish();
    final done = _playing = Completer<void>();
    _end = Timer(length!, _finish);
    await done.future;
  }

  @override
  Future<void> stop() async {
    stops++;
    _finish();
  }

  void _finish() {
    _end?.cancel();
    _end = null;
    final p = _playing;
    _playing = null;
    if (p != null && !p.isCompleted) p.complete();
  }
}

/// Stand-in for the keep-screen-on plugin.
class FakeWakelock implements WakelockDriver {
  bool on = false;
  int enables = 0;
  int disables = 0;

  @override
  Future<void> enable() async {
    enables++;
    on = true;
  }

  @override
  Future<void> disable() async {
    disables++;
    on = false;
  }
}

/// Stand-in for the phone's alarm settings ("Alarms & reliability").
class FakeAlarmHealth implements AlarmHealth {
  FakeAlarmHealth({
    this.android = true,
    this.notifications = true,
    this.exactAlarms = true,
    this.fullScreen = true,
    this.battery = true,
    this.samsung = false,
  });

  bool android, notifications, exactAlarms, fullScreen, battery, samsung;
  int checks = 0;

  /// Which Fix buttons opened a settings page, in order.
  final fixes = <String>[];

  @override
  Future<AlarmHealthStatus> check() async {
    checks++;
    return AlarmHealthStatus(
      android: android,
      notifications: notifications,
      exactAlarms: exactAlarms,
      fullScreen: fullScreen,
      battery: battery,
      samsung: samsung,
    );
  }

  @override
  Future<void> fixNotifications() async => fixes.add('notifications');

  @override
  Future<void> fixExactAlarms() async => fixes.add('exact');

  @override
  Future<void> fixFullScreen() async => fixes.add('fullscreen');

  @override
  Future<void> fixBattery() async => fixes.add('battery');
}

/// Stand-in for the phone's lock screen (see MainActivity).
class FakeLockScreen implements LockScreen {
  FakeLockScreen({this.locked = false, this.launch, this.unlockSucceeds = true});

  bool locked;

  /// The alarm group the app is opened for (as MainActivity reports it).
  String? launch;
  bool unlockSucceeds;

  /// Whether the app currently shows over the lock screen. Like the phone,
  /// an alarm launch has already switched it on.
  late bool showing = launch != null;

  /// Every change, in order (true = on).
  final changes = <bool>[];
  int unlockRequests = 0;
  void Function(String)? _onOpened;

  @override
  Future<String?> takeAlarmLaunch() async {
    final g = launch;
    launch = null;
    return g;
  }

  @override
  void listen(void Function(String group) onOpened) => _onOpened = onOpened;

  /// An alarm opens the app while it is already running.
  void alarmOpens(String group) {
    showing = true;
    _onOpened?.call(group);
  }

  @override
  Future<void> setShowOverLockScreen(bool on) async {
    showing = on;
    changes.add(on);
  }

  @override
  Future<bool> isLocked() async => locked;

  @override
  Future<bool> requestUnlock() async {
    unlockRequests++;
    if (unlockSucceeds) locked = false;
    return !locked;
  }
}

/// Fresh in-memory storage; call from setUp.
void resetStorage() => AppStorage.useMemoryForTests();

/// Scriptable stand-in for the Voice matcher (mic + templates + DTW).
class FakeVoice implements VoiceCounterService {
  FakeVoice({this.supported = true, this.result = VoiceStartResult.started});

  final bool supported;
  VoiceStartResult result;
  int starts = 0;
  int stops = 0;
  bool listening = false;
  MatchModel? lastModel;
  double? lastSensitivity;
  void Function(VoiceCandidate)? _onCandidate;
  void Function(String)? _onStopped;

  @override
  bool get isSupported => supported;

  @override
  Future<VoiceStartResult> start({
    required MatchModel model,
    required double sensitivity,
    required void Function(VoiceCandidate candidate) onCandidate,
    required void Function(String message) onStopped,
  }) async {
    starts++;
    lastModel = model;
    lastSensitivity = sensitivity;
    if (result != VoiceStartResult.started) return result;
    listening = true;
    _onCandidate = onCandidate;
    _onStopped = onStopped;
    return result;
  }

  @override
  void setSensitivity(double value) => lastSensitivity = value;

  @override
  Future<void> stop() async {
    stops++;
    listening = false;
  }

  /// The user chants their trained mantra once (a match).
  void hear() => _onCandidate?.call(
      const VoiceCandidate(matched: true, distance: 1.0, threshold: 2.0));

  /// Some other sound is heard (no match).
  void hearOther() => _onCandidate?.call(
      const VoiceCandidate(matched: false, distance: 4.0, threshold: 2.0));

  /// The engine gives up on its own.
  void engineGivesUp(String message) => _onStopped?.call(message);
}

/// A microphone whose start() (e.g. the permission dialog) is still pending
/// until [answer] is called.
class PendingVoice extends FakeVoice {
  final _gate = Completer<VoiceStartResult>();

  @override
  Future<VoiceStartResult> start({
    required MatchModel model,
    required double sensitivity,
    required void Function(VoiceCandidate candidate) onCandidate,
    required void Function(String message) onStopped,
  }) async {
    starts++;
    final r = await _gate.future;
    if (r == VoiceStartResult.started) {
      listening = true;
      _onCandidate = onCandidate;
      _onStopped = onStopped;
    }
    return r;
  }

  void answer(VoiceStartResult r) => _gate.complete(r);
}

/// Scriptable microphone: tests push PCM into it as if the mic delivered it.
class FakePcmInput implements PcmInput {
  FakePcmInput({this.supported = true, this.result = VoiceStartResult.started});

  final bool supported;
  VoiceStartResult result;
  int starts = 0;
  int stops = 0;
  bool streaming = false;
  void Function(Int16List)? _onSamples;
  void Function(String)? _onError;

  @override
  bool get isSupported => supported;

  @override
  Future<VoiceStartResult> start({
    required void Function(Int16List samples) onSamples,
    required void Function(String message) onError,
  }) async {
    starts++;
    if (result != VoiceStartResult.started) return result;
    streaming = true;
    _onSamples = onSamples;
    _onError = onError;
    return result;
  }

  @override
  Future<void> stop() async {
    stops++;
    streaming = false;
  }

  /// Audio arriving from the microphone (dropped when not streaming).
  void push(Int16List pcm) {
    if (streaming) _onSamples?.call(pcm);
  }

  /// The microphone dies on its own.
  void fail(String message) => _onError?.call(message);
}

/// Stores a trained voice (3 made-up templates) for [mantraId], as if the user
/// had finished training. Works before or after a container is created.
void seedTrainedVoice([String mantraId = 'seed_om_namah_shivaya', int samples = 3]) {
  final templates = [
    for (var k = 0; k < samples; k++)
      MfccSequence(
        40,
        mfccDims,
        Float64List.fromList([
          for (var i = 0; i < 40 * mfccDims; i++) math.sin(i * 0.1 + k * 0.05),
        ]),
      ),
  ];
  final training = VoiceTraining(
      mantraId: mantraId, templates: templates, trainedAt: DateTime(2026, 9, 1));
  AppStorage.voiceTemplates
      .put(mantraId, {'mantraId': mantraId, ...training.toMap()});
}

/// Scriptable stand-in for volume-key capture.
class FakeVolume implements VolumeButtonService {
  FakeVolume({this.supported = true, this.startOk = true});

  final bool supported;
  final bool startOk;
  int starts = 0;
  int stops = 0;
  bool capturing = false;
  VoidCallback? _onPress;

  @override
  bool get isSupported => supported;

  @override
  Future<bool> start(VoidCallback onPress) async {
    starts++;
    if (!startOk) return false;
    capturing = true;
    _onPress = onPress;
    return true;
  }

  @override
  Future<void> stop() async {
    stops++;
    capturing = false;
  }

  /// A hardware volume key press (only delivered while capturing).
  void press() {
    if (capturing) _onPress?.call();
  }
}

/// Stand-in for the native Mala service (MalaCounterService.kt). It behaves
/// like the real one: it owns the count while it runs, plays feedback itself
/// only when the app is not on screen ([appInForeground]) and otherwise asks
/// the app to, rings once at the target, and keeps its state after a stop.
class FakeMalaService implements MalaBackgroundService {
  FakeMalaService({this.supported = true, this.startOk = true});

  bool supported;
  bool startOk;
  int starts = 0, updates = 0, pauses = 0, resumes = 0, stops = 0, dismissals = 0;
  MalaServiceConfig? config;

  /// The phone's own idea of whether the app is on screen.
  bool appInForeground = true;

  /// What the service played itself (vibration / the alarm notification).
  int nativeMilestones = 0, nativeTicks = 0, nativeRings = 0;

  String? sessionId;
  int count = 0, base = 0, target = 108;
  MalaServiceStatus status = MalaServiceStatus.stopped;
  bool reached = false, rang = false;
  final _listeners = <void Function(MalaServiceEvent)>[];

  bool get running => status == MalaServiceStatus.running;

  MalaServiceState get state => MalaServiceState(
        sessionId: sessionId,
        count: count,
        base: base,
        target: target,
        status: status,
        reached: reached,
        rang: rang,
      );

  void _adopt(MalaServiceConfig c, {required bool fresh}) {
    config = c;
    sessionId = c.sessionId;
    count = c.count;
    base = c.base;
    target = c.target;
    if (fresh) rang = false;
    reached = base + count >= target;
    if (!reached) rang = false;
  }

  @override
  bool get isSupported => supported;

  @override
  Future<bool> start(MalaServiceConfig c) async {
    starts++;
    if (!startOk) return false;
    _adopt(c, fresh: true);
    status = MalaServiceStatus.running;
    _emit('started');
    return true;
  }

  /// The app that started it was killed (its engine gone, no dispose ran):
  /// nothing it would still send arrives. A relaunched app listens anew.
  bool _oldAppGone = false;

  void appKilled() {
    _listeners.clear();
    _oldAppGone = true;
  }

  @override
  Future<void> update(MalaServiceConfig c) async {
    if (_oldAppGone) return;
    updates++;
    _adopt(c, fresh: false);
  }

  @override
  Future<void> pause() async {
    if (_oldAppGone) return;
    pauses++;
    if (status == MalaServiceStatus.stopped) return;
    status = MalaServiceStatus.paused;
    _emit('paused');
  }

  @override
  Future<void> resume() async {
    resumes++;
    if (status == MalaServiceStatus.stopped) return;
    status = MalaServiceStatus.running;
    _emit('resumed');
  }

  @override
  Future<void> stop() async {
    if (_oldAppGone) return;
    stops++;
    if (status == MalaServiceStatus.stopped) return;
    status = MalaServiceStatus.stopped;
    _emit('stopped');
  }

  @override
  Future<MalaServiceState?> currentState() async => state;

  @override
  Future<void> dismissRing() async => dismissals++;

  @override
  VoidCallback listen(void Function(MalaServiceEvent event) onEvent) {
    _oldAppGone = false; // a relaunched app
    _listeners.add(onEvent);
    return () => _listeners.remove(onEvent);
  }

  /// Whether the app is listening (its engine is attached).
  bool get hasListener => _listeners.isNotEmpty;

  /// A hardware volume-key press (counted only while running).
  void press() {
    if (!running) return;
    if (reached) {
      _feedback(MalaAppFeedback.ack, () => nativeTicks++);
      return;
    }
    count++;
    final shown = base + count;
    reached = shown >= target;
    if (reached) {
      if (appInForeground) {
        _emit('count', MalaAppFeedback.ring);
      } else if (!rang) {
        rang = true;
        nativeRings++;
        _emit('count');
      } else {
        _emit('count');
      }
      return;
    }
    final every = config?.milestoneEvery ?? 108;
    if (every > 0 && shown % every == 0) {
      _feedback(MalaAppFeedback.milestone, () => nativeMilestones++);
    } else {
      _emit('count');
    }
  }

  /// Presses while the app's engine is gone: the count moves on, nobody hears.
  void pressWhileDetached(int times) {
    final saved = [..._listeners];
    _listeners.clear();
    for (var i = 0; i < times; i++) {
      press();
    }
    _listeners.addAll(saved);
  }

  void _feedback(MalaAppFeedback kind, void Function() native) {
    if (appInForeground) {
      _emit('count', kind);
    } else {
      if (config?.vibration ?? true) native();
      _emit('count');
    }
  }

  /// The notification's Pause / Resume / Stop buttons.
  void notificationPause() => pause();
  void notificationResume() => resume();
  void notificationStop() => stop();

  void _emit(String kind, [MalaAppFeedback feedback = MalaAppFeedback.none]) {
    final e = MalaServiceEvent(kind: kind, state: state, feedback: feedback);
    for (final l in [..._listeners]) {
      l(e);
    }
  }
}

/// Stand-in for the browser: records every page asked for.
class FakeLinks implements LinkLauncher {
  FakeLinks({this.succeeds = true});

  bool succeeds;
  final opened = <Uri>[];

  @override
  Future<bool> open(Uri url) async {
    opened.add(url);
    return succeeds;
  }
}

/// Stand-in for the phone's Do Not Disturb.
class FakeDnd implements DndDriver {
  FakeDnd({this.supported = true, this.access = true, this.filter = DndFilter.all});

  bool supported;
  bool access;
  int filter;

  /// Every mode set, in order.
  final sets = <int>[];
  int settingsOpened = 0;

  @override
  bool get isSupported => supported;

  @override
  Future<bool> hasAccess() async => access;

  @override
  Future<int?> currentFilter() async => filter;

  @override
  Future<bool> setFilter(int f) async {
    if (!access) return false;
    sets.add(f);
    filter = f;
    return true;
  }

  @override
  Future<void> openAccessSettings() async => settingsOpened++;
}

/// Provider overrides that replace every plugin-backed service.
///
/// Pass [haptics] and/or [sound] to run the REAL feedback service (settings
/// switches, intensity, wiring) on top of those fake drivers instead of the
/// counting [FakeFeedback].
List<Override> testOverrides({
  FakeFeedback? feedback,
  FakeVoice? voice,
  FakeVolume? volume,
  FakePcmInput? pcm,
  FakeHaptics? haptics,
  FakeSound? sound,
  FakeWakelock? wakelock,
  FakeLockScreen? lockScreen,
  FakeAlarmHealth? alarmHealth,
  FakeMalaService? mala,
  FakeDnd? dnd,
}) =>
    [
      if (dnd != null) dndDriverProvider.overrideWithValue(dnd),
      if (mala != null) malaBackgroundServiceProvider.overrideWithValue(mala),
      alarmHealthProvider.overrideWithValue(alarmHealth ?? FakeAlarmHealth()),
      lockScreenProvider.overrideWithValue(lockScreen ?? FakeLockScreen()),
      wakelockDriverProvider.overrideWithValue(wakelock ?? FakeWakelock()),
      pcmInputProvider.overrideWithValue(pcm ?? FakePcmInput()),
      // The real clock ticks on a timer, which widget tests must not leave
      // running (and a fixed date keeps them independent of today's).
      nowProvider.overrideWith(() => FakeNow(DateTime(2026, 9, 21, 8, 0))),
      if (haptics != null || sound != null) ...[
        hapticsDriverProvider.overrideWithValue(haptics ?? FakeHaptics()),
        soundDriverProvider.overrideWithValue(sound ?? FakeSound()),
      ] else
        feedbackServiceProvider.overrideWithValue(feedback ?? FakeFeedback()),
      voiceCounterServiceProvider.overrideWithValue(voice ?? FakeVoice()),
      volumeButtonServiceProvider.overrideWithValue(volume ?? FakeVolume()),
    ];
