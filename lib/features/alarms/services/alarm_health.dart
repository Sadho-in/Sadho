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
    this.alarmChannel = true,
    this.alarmChannelId,
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

  /// The alarm notification channels still pop on screen (importance High);
  /// a channel turned down in the settings silences the heads-up and the
  /// full-screen alarm. [alarmChannelId] is the one to fix.
  final bool alarmChannel;
  final String? alarmChannelId;

  bool get allOk =>
      notifications &&
      (!android || (exactAlarms && fullScreen && battery && alarmChannel));

  static const unknownOk = AlarmHealthStatus(
      android: false,
      notifications: true,
      exactAlarms: true,
      fullScreen: true,
      battery: true);
}

/// Checks and fixes. The fixes only ever OPEN the phone's own settings page
/// (or its permission dialog); none of them needs a restricted permission.
/// Each returns whether something opened: false means nothing could, and the
/// page shows written steps instead (never a silent no-op).
abstract class AlarmHealth {
  Future<AlarmHealthStatus> check();
  Future<bool> fixNotifications();
  Future<bool> fixExactAlarms();
  Future<bool> fixFullScreen();
  Future<bool> fixAlarmChannel(String? channelId);
  Future<bool> fixBattery();
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
    String? badChannel;
    try {
      badChannel = await _native.invokeMethod<String>('alarmChannelProblem');
    } catch (_) {}
    return AlarmHealthStatus(
      android: true,
      alarmChannel: badChannel == null,
      alarmChannelId: badChannel,
      notifications: notifications,
      exactAlarms: await _scheduler.canScheduleExact(),
      fullScreen: await _scheduler.canUseFullScreen(),
      // Samsung puts "Optimized" apps to sleep aggressively: there only
      // "Unrestricted" is safe. Elsewhere, anything but "Restricted" is.
      battery: !restricted && (!samsung || unrestricted),
      samsung: samsung,
    );
  }

  // Why Fix used to do nothing on three rows: they called the notification
  // plugin's permission REQUESTS, which open nothing when the permission is
  // already granted (USE_EXACT_ALARM is always granted on Android 13+, and
  // notifications usually are), and refuse to open anything while an earlier
  // request is still "in progress" (its answer lost when the activity was
  // recreated). Now every Fix opens its settings page natively.

  @override
  Future<bool> fixNotifications() async {
    // Never asked before: the system dialog. Otherwise the settings page.
    if (!await _notificationsOn() && await _scheduler.requestPermission()) {
      return true;
    }
    if (!_android) {
      try {
        await _iosPlugin?.openAppNotificationSettings();
        return true;
      } catch (e) {
        debugPrint('fix: notifications failed: $e');
        return false;
      }
    }
    return openSettings('notifications');
  }

  @override
  Future<bool> fixExactAlarms() => openSettings('exact');

  /// Opens a settings page natively ([kind]: notifications, exact,
  /// fullscreen, `channel:<id>`, dnd, battery), with fallbacks (the app's
  /// notification settings, then its details page). False if nothing opened.
  static Future<bool> openSettings(String kind) async {
    try {
      final ok = await _native.invokeMethod<bool>('openSettings', kind) ?? false;
      debugPrint('fix: $kind -> ${ok ? 'opened' : 'nothing opened'}');
      return ok;
    } catch (e) {
      debugPrint('fix: $kind failed: $e');
      return false;
    }
  }

  /// Android 14+: the "Full-screen notifications" switch for Sadho
  /// (ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT). The notification plugin's
  /// request opened nothing when it was already allowed, or while an earlier
  /// request was still pending.
  @override
  Future<bool> fixFullScreen() => openSettings('fullscreen');

  @override
  Future<bool> fixAlarmChannel(String? channelId) =>
      openSettings(channelId == null ? 'notifications' : 'channel:$channelId');

  @override
  Future<bool> fixBattery() => openSettings('battery');
}

final alarmHealthProvider = Provider<AlarmHealth>(
    (ref) => DeviceAlarmHealth(ref.watch(reminderSchedulerProvider)));
