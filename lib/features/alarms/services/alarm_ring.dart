import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the phone's alarm ring stands (AlarmRinger.kt). Kept natively, so
/// it survives the app's activity or process being recreated.
@immutable
class RingState {
  const RingState({
    this.ringing = false,
    this.unacknowledged = false,
    this.group,
  });

  static const idle = RingState();

  /// Sound and/or vibration are going right now.
  final bool ringing;

  /// An alarm rang and nobody pressed Stop yet (unlocking, opening the app or
  /// the 5-minute limit only silence it).
  final bool unacknowledged;

  /// The alert group that rang (sadhana-timer, mala, timer, sun-alarm).
  final String? group;

  factory RingState.fromMap(Map<Object?, Object?> m) => RingState(
        ringing: m['ringing'] == true,
        unacknowledged: m['unacknowledged'] == true,
        group: m['group'] is String ? m['group'] as String : null,
      );

  @override
  bool operator ==(Object other) =>
      other is RingState &&
      other.ringing == ringing &&
      other.unacknowledged == unacknowledged &&
      other.group == group;

  @override
  int get hashCode => Object.hash(ringing, unacknowledged, group);

  @override
  String toString() => 'RingState(ringing: $ringing, '
      'unacknowledged: $unacknowledged, group: $group)';
}

/// How often a ring's sound / vibration repeats (AlarmRinger.kt):
/// once = one full play (at least 5 s), repeat = three plays, until = until
/// Stop, unlocking, opening the app or 5 minutes.
abstract final class RingRepeat {
  static const once = 'once';
  static const repeat = 'repeat';
  static const until = 'until';
}

/// The phone's default alarm tone (the Clock timer and the sun alarm).
const ringDefaultSound = 'default';

/// One alarm set with AlarmManager.setAlarmClock (AlarmScheduler.kt).
@immutable
class NativeAlarm {
  const NativeAlarm({
    required this.id,
    required this.when,
    required this.title,
    required this.body,
    required this.sound,
    required this.vibrate,
    required this.soundRepeat,
    required this.vibrationRepeat,
    required this.stopLabel,
    this.daily = false,
  });

  final int id;
  final DateTime when;
  final String title;
  final String body;

  /// A raw resource name (`temple_bell`), [ringDefaultSound], or null (silent).
  final String? sound;
  final bool vibrate;
  final String soundRepeat;
  final String vibrationRepeat;
  final String stopLabel;
  final bool daily;

  Map<String, Object?> toMap() => {
        'id': id,
        'at': when.millisecondsSinceEpoch,
        'title': title,
        'body': body,
        'sound': sound,
        'vibrate': vibrate,
        'soundRepeat': soundRepeat,
        'vibrationRepeat': vibrationRepeat,
        'stopLabel': stopLabel,
        'daily': daily,
      };
}

/// The one native alarm ring and the alarms that start it. A seam, so tests
/// run without a phone.
abstract class AlarmRing {
  /// False where there is no native ring (iOS, web, desktop, tests).
  bool get isSupported;

  /// Replaces every alarm of [group] with [alarms] (an empty list cancels).
  Future<bool> replaceGroup(String group, List<NativeAlarm> alarms);

  Future<RingState> current();

  /// A Stop button: silences sound, vibration and the notification, and
  /// acknowledges the finish.
  Future<void> stop();

  /// The app was opened: a ring of [group] stops, unless the phone is locked
  /// (then the alarm screen is showing and its Stop decides).
  Future<void> silenceIfUnlocked(String group);

  /// The notification channels' names, in the app's language.
  Future<void> setChannelNames({required String sadhana, required String alarms});

  /// Calls [onChange] whenever the ring starts or stops, until the returned
  /// function is called.
  VoidCallback listen(void Function(RingState state) onChange);
}

class NoopAlarmRing implements AlarmRing {
  const NoopAlarmRing();

  @override
  bool get isSupported => false;

  @override
  Future<bool> replaceGroup(String group, List<NativeAlarm> alarms) async => false;

  @override
  Future<RingState> current() async => RingState.idle;

  @override
  Future<void> stop() async {}

  @override
  Future<void> silenceIfUnlocked(String group) async {}

  @override
  Future<void> setChannelNames({required String sadhana, required String alarms}) async {}

  @override
  VoidCallback listen(void Function(RingState state) onChange) => () {};
}

/// Over the "sadho/ring" channel (MainActivity).
class AndroidAlarmRing implements AlarmRing {
  AndroidAlarmRing({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('sadho/ring') {
    _channel.setMethodCallHandler(_onCall);
  }

  final MethodChannel _channel;
  final _listeners = <void Function(RingState)>[];

  static bool get platformSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  bool get isSupported => true;

  Future<void> _onCall(MethodCall call) async {
    if (call.method != 'ringChanged' || call.arguments is! Map) return;
    final s = RingState.fromMap(call.arguments as Map<Object?, Object?>);
    for (final l in [..._listeners]) {
      l(s);
    }
  }

  @override
  VoidCallback listen(void Function(RingState state) onChange) {
    _listeners.add(onChange);
    return () => _listeners.remove(onChange);
  }

  @override
  Future<bool> replaceGroup(String group, List<NativeAlarm> alarms) async {
    try {
      return await _channel.invokeMethod<bool>('replaceGroup', {
            'group': group,
            'alarms': [for (final a in alarms) a.toMap()],
          }) ??
          false;
    } catch (e) {
      debugPrint('ring: could not set the $group alarms: $e');
      return false;
    }
  }

  @override
  Future<RingState> current() async {
    try {
      final m = await _channel.invokeMapMethod<Object?, Object?>('state');
      return m == null ? RingState.idle : RingState.fromMap(m);
    } catch (e) {
      debugPrint('ring: state unavailable: $e');
      return RingState.idle;
    }
  }

  @override
  Future<void> stop() => _call('stop');

  @override
  Future<void> silenceIfUnlocked(String group) => _call('silenceIfUnlocked', group);

  @override
  Future<void> setChannelNames({required String sadhana, required String alarms}) =>
      _call('setChannelNames', {'sadhana': sadhana, 'alarms': alarms});

  Future<void> _call(String method, [Object? args]) async {
    try {
      await _channel.invokeMethod<void>(method, args);
    } catch (e) {
      debugPrint('ring: $method failed: $e');
    }
  }
}

/// `main()` overrides this with [AndroidAlarmRing] on Android.
final alarmRingProvider = Provider<AlarmRing>((ref) => const NoopAlarmRing());
