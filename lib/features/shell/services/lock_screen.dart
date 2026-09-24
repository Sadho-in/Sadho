import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Showing over the lock screen, which the app does ONLY for an alarm (see
/// MainActivity). A seam, so tests run without a phone.
abstract class LockScreen {
  /// The alarm group (e.g. `sadhana-timer`) the app was just opened for,
  /// already shown over the lock screen by the phone; null if it was opened
  /// normally. Answers once per opening.
  Future<String?> takeAlarmLaunch();

  /// Calls [onOpened] when an alarm opens the app while it is running.
  void listen(void Function(String group) onOpened);

  Future<void> setShowOverLockScreen(bool on);

  /// Whether the phone is locked (PIN, pattern, fingerprint...).
  Future<bool> isLocked();

  /// Asks the user to unlock the phone. True if it is unlocked afterwards.
  Future<bool> requestUnlock();
}

class NativeLockScreen implements LockScreen {
  static const _channel = MethodChannel('sadho/alarm');

  static bool get _android =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<String?> takeAlarmLaunch() async {
    if (!_android) return null;
    try {
      return await _channel.invokeMethod<String>('takeAlarmLaunch');
    } catch (e) {
      debugPrint('Could not read the alarm launch: $e');
      return null;
    }
  }

  @override
  void listen(void Function(String group) onOpened) {
    if (!_android) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'alarmOpened' && call.arguments is String) {
        onOpened(call.arguments as String);
      }
    });
  }

  @override
  Future<void> setShowOverLockScreen(bool on) async {
    if (!_android) return;
    try {
      await _channel.invokeMethod<void>('setShowOverLockScreen', on);
    } catch (e) {
      debugPrint('Could not change showing over the lock screen: $e');
    }
  }

  @override
  Future<bool> isLocked() async {
    if (!_android) return false;
    try {
      return await _channel.invokeMethod<bool>('isLocked') ?? false;
    } catch (e) {
      // Unknown: treat as locked, so nothing opens without the phone unlocked.
      return true;
    }
  }

  @override
  Future<bool> requestUnlock() async {
    if (!_android) return true;
    try {
      return await _channel.invokeMethod<bool>('requestUnlock') ?? false;
    } catch (e) {
      debugPrint('Could not ask to unlock: $e');
      return false;
    }
  }
}

final lockScreenProvider = Provider<LockScreen>((ref) => NativeLockScreen());
