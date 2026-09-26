import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../calendar/services/reminder_scheduler.dart';
import '../../sadhana/services/feedback_service.dart';
import '../../sadhana/services/mala_background_service.dart';
import '../services/alarm_ring.dart';

/// Whether (and for which alarm) a Stop control must be on screen.
@immutable
class RingStatus {
  const RingStatus({this.native = RingState.idle, this.inApp = false});

  /// The phone's own ring (AlarmRinger), read back from the native side, so
  /// it is right after the app's activity or process was recreated.
  final RingState native;

  /// The in-app completion alert (the app was on screen at the finish).
  final bool inApp;

  bool get isSadhana =>
      native.group == sadhanaTimerGroup || native.group == malaGroup;

  /// A Stop control is shown while anything rings, and while a finished
  /// Sadhana session has not been acknowledged (unlocking, opening the app or
  /// the 5-minute limit silence it, but only Stop acknowledges it).
  bool get showStop =>
      inApp || native.ringing || (native.unacknowledged && isSadhana);

  /// The alarm the Stop is for (a Sadhana finish when only the app rings).
  String get group => native.ringing || (native.unacknowledged && isSadhana)
      ? (native.group ?? sadhanaTimerGroup)
      : sadhanaTimerGroup;

  RingStatus copyWith({RingState? native, bool? inApp}) =>
      RingStatus(native: native ?? this.native, inApp: inApp ?? this.inApp);

  @override
  bool operator ==(Object other) =>
      other is RingStatus && other.native == native && other.inApp == inApp;

  @override
  int get hashCode => Object.hash(native, inApp);
}

/// ONE Stop for everything that rings: the in-app alert, the phone's alarm
/// ring (sound, vibration) and its notification. Used by the banner on every
/// tab, the Sadhana screen, Focus mode (and the lock-screen alarm screen
/// stops the same native ring).
///
/// P5.1 root cause of "no Stop after unlocking": the Stop button only
/// watched the in-app alert; a session that finished with the phone locked
/// rang through the phone's alarm, which the app knew nothing about, and the
/// in-memory state that remembered it was lost when the activity was
/// recreated. The ring's state now lives natively and is read back here.
class RingController extends Notifier<RingStatus> {
  late AlarmRing _ring;
  late FeedbackService _feedback;
  _Resume? _resume;

  @override
  RingStatus build() {
    _ring = ref.read(alarmRingProvider);
    _feedback = ref.read(feedbackServiceProvider);
    final unlisten = _ring.listen((s) {
      if (ref.mounted) state = state.copyWith(native: s);
    });
    // Deferred: the alert can stop while a screen is being disposed, when
    // providers must not change.
    void inApp() => scheduleMicrotask(() {
          if (ref.mounted) {
            state = state.copyWith(inApp: _feedback.alerting.value);
          }
        });

    _feedback.alerting.addListener(inApp);
    try {
      _resume = _Resume(refresh);
      WidgetsBinding.instance.addObserver(_resume!);
    } catch (_) {
      // No Flutter binding (plain unit tests).
    }
    ref.onDispose(() {
      unlisten();
      _feedback.alerting.removeListener(inApp);
      if (_resume != null) WidgetsBinding.instance.removeObserver(_resume!);
    });
    Future.microtask(refresh);
    return RingStatus(inApp: _feedback.alerting.value);
  }

  /// Reads the native ring again (start, return to the app).
  Future<void> refresh() async {
    final s = await _ring.current();
    if (ref.mounted) state = state.copyWith(native: s);
  }

  /// One tap: stops the sound, the vibration and the notification, in the app
  /// and on the phone, and acknowledges the finish.
  Future<void> stop() async {
    final group = state.group;
    _feedback.stopAlert();
    try {
      await _ring.stop();
    } catch (e) {
      debugPrint('ring: stop failed: $e');
    }
    unawaited(ref
        .read(reminderSchedulerProvider)
        .dismissShown(group)
        .catchError((Object _) {}));
    if (group == malaGroup) {
      unawaited(ref
          .read(malaBackgroundServiceProvider)
          .dismissRing()
          .catchError((Object _) {}));
    }
    if (ref.mounted) {
      state = RingStatus(native: RingState(group: state.native.group));
    }
  }
}

class _Resume with WidgetsBindingObserver {
  _Resume(this.onResume);

  final Future<void> Function() onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(onResume());
  }
}

final ringControllerProvider =
    NotifierProvider<RingController, RingStatus>(RingController.new);
