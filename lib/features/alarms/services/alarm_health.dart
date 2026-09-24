import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../calendar/services/reminder_scheduler.dart';

/// Everything the phone must allow for alarms to ring on time with the screen
/// off. Each is true when fine.
class AlarmHealthStatus {
  const AlarmHealthStatus({
    required this.android,
    required this.notifications,
    required this.exactAlarms,
    required this.fullScreen,
    required this.battery,
    this.samsung = false,
  });

  /// The Android-only rows (exact alarms, full screen, battery) apply.
  final bool android;
  final bool notifications;
  final bool exactAlarms;

  /// Alarms may show over the lock screen (Android 14+ lets users refuse).
  final bool fullScreen;

  /// The app's battery use is not restricted.
  final bool battery;

  /// A Samsung phone: its "Sleeping apps" list can also hold alarms back.
  final bool samsung;

  bool get allOk =>
      notifications && (!android || (exactAlarms && fullScreen && battery));

  static const unknownOk = AlarmHealthStatus(
      android: false,
      notifications: true,
      exactAlarms: true,
      fullScreen: true,
      battery: true);
}

/// Checks and fixes. The fixes only ever OPEN the phone's own settings page
/// (or its permission dialog); none of them needs a restricted permission.
abstract class AlarmHealth {
  Future<AlarmHealthStatus> check();
  Future<void> fixNotifications();
  Future<void> fixExactAlarms();
  Future<void> fixFullScreen();
  Future<void> fixBattery();
}

class DeviceAlarmHealth implements AlarmHealth {
  DeviceAlarmHealth(this._scheduler, {FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final ReminderScheduler _scheduler;
  final FlutterLocalNotificationsPlugin _plugin;
  static const _native = MethodChannel('sadho/alarm');

  static bool get _android =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  IOSFlutterLocalNotificationsPlugin? get _iosPlugin =>
      _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

  Future<bool> _notificationsOn() async {
    try {
      if (_android) return await _androidPlugin?.areNotificationsEnabled() ?? true;
      final p = await _iosPlugin?.checkPermissions();
      return p?.isEnabled ?? true;
    } catch (_) {
      return true; // unknown: do not raise a false alarm
    }
  }

  @override
  Future<AlarmHealthStatus> check() async {
    if (!_scheduler.isSupported) return AlarmHealthStatus.unknownOk;
    final notifications = await _notificationsOn();
    if (!_android) {
      return AlarmHealthStatus(
          android: false,
          notifications: notifications,
          exactAlarms: true,
          fullScreen: true,
          battery: true);
    }
    var restricted = false, samsung = false, unrestricted = true;
    try {
      final b = await _native.invokeMapMethod<String, Object?>('batteryStatus');
      restricted = b?['restricted'] == true;
      unrestricted = b?['unrestricted'] != false;
      samsung = b?['samsung'] == true;
    } catch (_) {}
    return AlarmHealthStatus(
      android: true,
      notifications: notifications,
      exactAlarms: await _scheduler.canScheduleExact(),
      fullScreen: await _scheduler.canUseFullScreen(),
      // Samsung puts "Optimized" apps to sleep aggressively: there only
      // "Unrestricted" is safe. Elsewhere, anything but "Restricted" is.
      battery: !restricted && (!samsung || unrestricted),
      samsung: samsung,
    );
  }

  @override
  Future<void> fixNotifications() async {
    // Never asked: the system dialog. Refused before: the settings page.
    if (await _scheduler.requestPermission()) return;
    try {
      if (_android) {
        await _androidPlugin?.openAppNotificationSettings();
      } else {
        await _iosPlugin?.openAppNotificationSettings();
      }
    } catch (e) {
      debugPrint('Could not open the notification settings: $e');
    }
  }

  @override
  Future<void> fixExactAlarms() => _scheduler.requestExactAlarms();

  @override
  Future<void> fixFullScreen() => _scheduler.requestFullScreen();

  @override
  Future<void> fixBattery() async {
    try {
      await _native.invokeMethod<void>('openBatterySettings');
    } catch (e) {
      debugPrint('Could not open the battery settings: $e');
    }
  }
}

final alarmHealthProvider = Provider<AlarmHealth>(
    (ref) => DeviceAlarmHealth(ref.watch(reminderSchedulerProvider)));
