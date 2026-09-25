import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../calendar/services/reminder_scheduler.dart';
import '../../sadhana/services/feedback_service.dart';
import '../../sadhana/services/mala_background_service.dart';
import '../services/lock_screen.dart';

/// The alarm groups that may open the app over the lock screen.
const lockScreenAlarmGroups = {
  sadhanaTimerGroup,
  timerGroup,
  sunAlarmGroup,
  malaGroup,
};

/// Which alarm's "finished" screen is showing over the lock screen, or null.
///
/// The app shows over the lock screen ONLY while this is set: when an alarm
/// opened it while the phone was locked. Everything else in the app needs the
/// phone unlocked. Showing over the lock screen is switched off BEFORE the
/// finished screen goes away (Stop, Unlock, back, or leaving the app), so the
/// rest of the app is never shown over the lock screen, not even for a frame.
class AlarmScreenNotifier extends Notifier<String?> {
  late LockScreen _lock;
  _Watcher? _watcher;

  /// An alarm opening is being handled (so a normal-launch check must not
  /// switch the lock screen off underneath it).
  int _opening = 0;

  /// The phone's unlock prompt is up (it can pause the app; that is not
  /// leaving).
  bool _unlocking = false;

  @override
  String? build() {
    _lock = ref.read(lockScreenProvider);
    _lock.listen((group) => unawaited(_opened(group)));
    try {
      _watcher = _Watcher(this);
      // Registered before the app's own navigator, so the back button reaches
      // the finished screen first.
      WidgetsBinding.instance.addObserver(_watcher!);
    } catch (_) {
      // No Flutter binding (plain unit tests).
    }
    ref.onDispose(() {
      if (_watcher != null) WidgetsBinding.instance.removeObserver(_watcher!);
    });
    Future.microtask(_checkLaunch);
    return null;
  }

  /// How the app was opened: by an alarm (the phone already shows it over the
  /// lock screen) or normally (then never over the lock screen).
  Future<void> _checkLaunch() async {
    final group = await _lock.takeAlarmLaunch();
    if (!ref.mounted) return;
    if (group != null) {
      await _opened(group);
    } else if (state == null && _opening == 0) {
      await _lock.setShowOverLockScreen(false);
    }
  }

  Future<void> _opened(String group) async {
    _opening++;
    try {
      if (!lockScreenAlarmGroups.contains(group) || !await _lock.isLocked()) {
        // Unlocked (or not an alarm): the app opens normally.
        if (state == null) await _lock.setShowOverLockScreen(false);
        return;
      }
      await _lock.setShowOverLockScreen(true);
      if (ref.mounted) state = group;
    } finally {
      _opening--;
    }
  }

  /// Stop: silences the alarm and closes the finished screen. The phone stays
  /// locked.
  Future<void> stop() async {
    final group = state;
    if (group == null) return;
    ref.read(feedbackServiceProvider).stopAlert();
    unawaited(ref
        .read(reminderSchedulerProvider)
        .dismissShown(group)
        .catchError((Object _) {}));
    // The Mala ring is posted by the Mala service itself.
    if (group == malaGroup) {
      unawaited(ref
          .read(malaBackgroundServiceProvider)
          .dismissRing()
          .catchError((Object _) {}));
    }
    await _leave();
  }

  /// Continue into the app: the phone must be unlocked first. Returns whether
  /// it was (then the app is shown; otherwise the lock screen is).
  Future<bool> unlockAndContinue() async {
    if (state == null) return false;
    _unlocking = true;
    final bool unlocked;
    try {
      unlocked = await _lock.requestUnlock();
    } finally {
      _unlocking = false;
    }
    await _leave();
    return unlocked;
  }

  /// Switches showing over the lock screen OFF, then closes the screen.
  Future<void> _leave() async {
    if (state == null) return;
    await _lock.setShowOverLockScreen(false);
    if (ref.mounted) state = null;
  }

  void _lifecycle(AppLifecycleState s) {
    // Leaving the screen (switching away, the screen going off) ends it.
    if (s == AppLifecycleState.paused || s == AppLifecycleState.hidden) {
      if (!_unlocking) unawaited(_leave());
    } else if (s == AppLifecycleState.resumed) {
      unawaited(_checkLaunch());
    }
  }

  bool _back() {
    if (state == null) return false;
    unawaited(_leave());
    return true;
  }
}

class _Watcher with WidgetsBindingObserver {
  _Watcher(this.owner);

  final AlarmScreenNotifier owner;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => owner._lifecycle(state);

  @override
  Future<bool> didPopRoute() async => owner._back();
}

final alarmScreenProvider =
    NotifierProvider<AlarmScreenNotifier, String?>(AlarmScreenNotifier.new);
