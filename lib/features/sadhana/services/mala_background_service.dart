import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the live Mala count stands in the native service.
enum MalaServiceStatus { running, paused, stopped }

/// What the APP should play for a count the service just made. The service
/// plays nothing itself while the app is on screen (and everything while it
/// is not), so a buzz or a ring is never doubled.
enum MalaAppFeedback {
  none,

  /// The 108 milestone buzz.
  milestone,

  /// A press after the target: the short tick.
  ack,

  /// The target was just reached: the completion alert.
  ring,
}

/// The service's saved state: the Mala bucket's count, what it counts toward,
/// and how the session ended up. Readable after a relaunch too.
@immutable
class MalaServiceState {
  const MalaServiceState({
    required this.sessionId,
    required this.count,
    required this.base,
    required this.target,
    required this.status,
    required this.reached,
    required this.rang,
  });

  /// Which session this is (a stale state from an older session is ignored).
  final String? sessionId;

  /// The Mala bucket's own count.
  final int count;

  /// The other modes' counts added to it for the target (Combined), else 0.
  final int base;
  final int target;
  final MalaServiceStatus status;

  /// base + count reached the target.
  final bool reached;

  /// The service rang the alarm for it (the app must stay quiet).
  final bool rang;

  int get shown => base + count;

  factory MalaServiceState.fromMap(Map<Object?, Object?> m) {
    int number(Object? v, int fallback) => v is num ? v.toInt() : fallback;
    return MalaServiceState(
      sessionId: m['sessionId'] is String ? m['sessionId'] as String : null,
      count: number(m['count'], 0).clamp(0, 1 << 30),
      base: number(m['base'], 0).clamp(0, 1 << 30),
      target: number(m['target'], 108).clamp(1, 1 << 30),
      status: MalaServiceStatus.values.firstWhere(
        (s) => s.name == m['status'],
        orElse: () => MalaServiceStatus.stopped,
      ),
      reached: m['reached'] == true,
      rang: m['rang'] == true,
    );
  }

  @override
  String toString() => 'MalaServiceState($sessionId $count+$base/$target '
      '${status.name}${reached ? ' reached' : ''}${rang ? ' rang' : ''})';
}

/// Something the service did: a count, or a pause / resume / stop (from its
/// notification, or its own auto-stop).
@immutable
class MalaServiceEvent {
  const MalaServiceEvent({
    required this.kind,
    required this.state,
    this.feedback = MalaAppFeedback.none,
  });

  /// count, started, paused, resumed or stopped.
  final String kind;
  final MalaServiceState state;
  final MalaAppFeedback feedback;

  factory MalaServiceEvent.fromMap(Map<Object?, Object?> m) => MalaServiceEvent(
        kind: m['event'] is String ? m['event'] as String : 'count',
        state: MalaServiceState.fromMap(m),
        feedback: MalaAppFeedback.values.firstWhere(
          (f) => f.name == m['feedback'],
          orElse: () => MalaAppFeedback.none,
        ),
      );
}

/// The notification's words, in the app's language.
@immutable
class MalaNotificationText {
  const MalaNotificationText({
    required this.channel,
    required this.title,
    required this.running,
    required this.paused,
    required this.done,
    required this.pause,
    required this.resume,
    required this.stop,
  });

  final String channel;

  /// With `{count}` and `{target}`, filled in by the service ("Mala · 54 / 108").
  final String title;
  final String running;
  final String paused;
  final String done;
  final String pause;
  final String resume;
  final String stop;
}

/// The alarm the service rings at the target when the app is not on screen:
/// the Sadhana finish alarm's channel, sound and vibration.
@immutable
class MalaRing {
  const MalaRing({
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
    required this.sound,
    required this.vibrate,
    required this.insistent,
    required this.title,
    required this.body,
  });

  final String channelId;
  final String channelName;
  final String channelDescription;

  /// Android raw resource name of the ringtone, or null for silent.
  final String? sound;
  final bool vibrate;

  /// Rings until dismissed ("Until stopped").
  final bool insistent;
  final String title;
  final String body;
}

/// Everything the service needs: the count and target, and how it should buzz,
/// ring and read.
@immutable
class MalaServiceConfig {
  const MalaServiceConfig({
    required this.sessionId,
    required this.count,
    required this.base,
    required this.target,
    required this.vibration,
    required this.milestoneEvery,
    required this.milestoneMs,
    required this.milestoneAmplitude,
    required this.ackMs,
    required this.ackAmplitude,
    required this.ring,
    required this.text,
  });

  final String sessionId;
  final int count;
  final int base;
  final int target;
  final bool vibration;
  final int milestoneEvery;
  final int milestoneMs;
  final int milestoneAmplitude;
  final int ackMs;
  final int ackAmplitude;
  final MalaRing ring;
  final MalaNotificationText text;

  /// Flat, as MalaCounterService.writeConfig stores it.
  Map<String, Object?> toMap() => {
        'sessionId': sessionId,
        'count': count,
        'base': base,
        'target': target,
        'vibration': vibration,
        'milestoneEvery': milestoneEvery,
        'milestoneMs': milestoneMs,
        'milestoneAmplitude': milestoneAmplitude,
        'ackMs': ackMs,
        'ackAmplitude': ackAmplitude,
        'alarmChannelId': ring.channelId,
        'alarmChannelName': ring.channelName,
        'alarmChannelDescription': ring.channelDescription,
        'alarmSound': ring.sound,
        'alarmVibrate': ring.vibrate,
        'alarmInsistent': ring.insistent,
        'ringTitle': ring.title,
        'ringBody': ring.body,
        'textChannel': text.channel,
        'textTitle': text.title,
        'textRunning': text.running,
        'textPaused': text.paused,
        'textDone': text.done,
        'textPause': text.pause,
        'textResume': text.resume,
        'textStop': text.stop,
      };
}

/// Mala counting with the screen off (Android): a native foreground service
/// that counts hardware volume-key presses through a MediaSession, rings at
/// the target, and keeps the count while the app is paused or closed (see
/// MalaCounterService.kt). Behind an interface so tests run without a phone.
abstract class MalaBackgroundService {
  /// False where there is no such service (iOS, web, desktop, tests).
  bool get isSupported;

  /// Starts counting (the app must be on screen). False if it could not start.
  Future<bool> start(MalaServiceConfig config);

  /// The count, target or settings changed while it runs.
  Future<void> update(MalaServiceConfig config);

  Future<void> pause();
  Future<void> resume();

  /// Stops counting and removes the notification; the count stays readable.
  Future<void> stop();

  /// The saved state (also after a relaunch), or null if unknown.
  Future<MalaServiceState?> currentState();

  /// Removes the target alarm notification (which also silences it).
  Future<void> dismissRing();

  /// Calls [onEvent] for everything the service does from now on, until the
  /// returned function is called.
  VoidCallback listen(void Function(MalaServiceEvent event) onEvent);
}

/// No service: the app counts volume keys only while it is on screen.
class UnsupportedMalaBackgroundService implements MalaBackgroundService {
  const UnsupportedMalaBackgroundService();

  @override
  bool get isSupported => false;

  @override
  Future<bool> start(MalaServiceConfig config) async => false;

  @override
  Future<void> update(MalaServiceConfig config) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<MalaServiceState?> currentState() async => null;

  @override
  Future<void> dismissRing() async {}

  @override
  VoidCallback listen(void Function(MalaServiceEvent event) onEvent) => () {};
}

/// The real service, over the "sadho/mala" method channel (MainActivity).
class AndroidMalaBackgroundService implements MalaBackgroundService {
  AndroidMalaBackgroundService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('sadho/mala') {
    _channel.setMethodCallHandler(_onCall);
  }

  final MethodChannel _channel;
  final _listeners = <void Function(MalaServiceEvent)>[];

  static bool get platformSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  bool get isSupported => true;

  Future<void> _onCall(MethodCall call) async {
    if (call.method != 'event' || call.arguments is! Map) return;
    final event =
        MalaServiceEvent.fromMap(call.arguments as Map<Object?, Object?>);
    for (final l in [..._listeners]) {
      l(event);
    }
  }

  @override
  VoidCallback listen(void Function(MalaServiceEvent event) onEvent) {
    _listeners.add(onEvent);
    return () => _listeners.remove(onEvent);
  }

  @override
  Future<bool> start(MalaServiceConfig config) async {
    try {
      return await _channel.invokeMethod<bool>('start', config.toMap()) ?? false;
    } catch (e) {
      debugPrint('Mala service could not start: $e');
      return false;
    }
  }

  @override
  Future<void> update(MalaServiceConfig config) =>
      _call('update', config.toMap());

  @override
  Future<void> pause() => _call('pause');

  @override
  Future<void> resume() => _call('resume');

  @override
  Future<void> stop() => _call('stop');

  @override
  Future<void> dismissRing() => _call('dismissRing');

  @override
  Future<MalaServiceState?> currentState() async {
    try {
      final m = await _channel.invokeMapMethod<Object?, Object?>('currentState');
      return m == null ? null : MalaServiceState.fromMap(m);
    } catch (e) {
      debugPrint('Mala service state unavailable: $e');
      return null;
    }
  }

  Future<void> _call(String method, [Object? args]) async {
    try {
      await _channel.invokeMethod<void>(method, args);
    } catch (e) {
      debugPrint('Mala service $method failed: $e');
    }
  }
}

/// `main()` overrides this with [AndroidMalaBackgroundService] on Android.
final malaBackgroundServiceProvider = Provider<MalaBackgroundService>(
    (ref) => const UnsupportedMalaBackgroundService());
