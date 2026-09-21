import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../clock/services/tz_init.dart';
import '../data/calendar_mark.dart';
import 'reminder_planner.dart';
import 'reminder_scheduler.dart';

/// Real reminders through `flutter_local_notifications` + `timezone`.
///
/// Reminders are local to the phone: they need no account or network, and are
/// rebuilt on every app start. Android rings at the exact minute when the user
/// has allowed exact alarms and otherwise a little flexibly.
class LocalNotificationsScheduler implements ReminderScheduler {
  LocalNotificationsScheduler({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool? _exactAllowed;

  static const _channelId = 'calendar_reminders';
  static const _alarmChannelId = 'alarms_timers';

  static bool get platformSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  bool get isSupported => platformSupported;

  /// Sets up the timezone database (so 7:00 stays 7:00 across daylight-saving
  /// changes) and the notification plugin. Call once from `main()`.
  Future<void> init() async {
    ensureTimeZonesLoaded();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (e) {
      // Falls back to UTC: reminders still ring, just on UTC wall-clock time.
      debugPrint('Could not read the device time zone: $e');
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permission is asked when the first reminder is saved, not at launch.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Calendar reminders',
          channelDescription: 'Reminders for the dates you marked in Sadho',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

  /// Alarm-style: loud, on the ALARM stream (so a muted media volume does not
  /// silence it), and marked as an alarm/timer for the system.
  NotificationDetails get _alarmDetails => const NotificationDetails(
        android: AndroidNotificationDetails(
          _alarmChannelId,
          'Alarms and timers',
          channelDescription: 'The sun-based alarm and finished timers',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      );

  @override
  Future<bool> requestPermission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        // Null on Android 12 and below, where no permission is needed.
        return await android?.requestNotificationsPermission() ?? true;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, sound: true) ?? false;
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
      return false;
    }
  }

  @override
  Future<void> cancel(String markId) => _cancelWhere((p) => p == markId);

  /// Cancels every pending notification whose payload satisfies [test].
  Future<void> _cancelWhere(bool Function(String? payload) test) async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      for (final r in pending) {
        if (test(r.payload)) await _plugin.cancel(id: r.id);
      }
    } catch (e) {
      debugPrint('Could not cancel notifications: $e');
    }
  }

  @override
  Future<void> schedule(CalendarMark mark) async {
    await cancel(mark.id);
    await _scheduleAll(mark);
  }

  @override
  Future<void> rescheduleAll(Iterable<CalendarMark> marks) async {
    // Only the calendar's own reminders: the sun alarm and timers are kept.
    await _cancelWhere((p) => !alertGroups.contains(p));
    for (final m in marks) {
      await _scheduleAll(m);
    }
  }

  @override
  Future<void> replaceAlerts(String group, List<ScheduledAlert> alerts) async {
    await _cancelWhere((p) => p == group);
    for (final a in alerts) {
      try {
        await _zonedAt(
          id: a.id,
          when: a.when,
          details: _alarmDetails,
          title: a.title,
          body: a.body,
          payload: group,
        );
      } catch (e) {
        debugPrint('Could not schedule alert ${a.id}: $e');
      }
    }
  }

  Future<void> _scheduleAll(CalendarMark mark) async {
    for (final p in planReminders(mark, DateTime.now())) {
      try {
        await _zoned(p);
      } catch (e) {
        // One bad reminder must never stop the mark from being saved.
        debugPrint('Could not schedule reminder ${p.id}: $e');
      }
    }
  }

  Future<void> _zoned(PlannedReminder p) => _zonedAt(
        id: p.id,
        when: p.when,
        details: _details,
        title: p.title,
        body: p.body,
        payload: p.markId,
        repeat: switch (p.repeat) {
          PlannedRepeat.daily => DateTimeComponents.time,
          PlannedRepeat.weekly => DateTimeComponents.dayOfWeekAndTime,
          PlannedRepeat.none => null,
        },
      );

  Future<void> _zonedAt({
    required int id,
    required DateTime when,
    required NotificationDetails details,
    required String title,
    required String body,
    required String payload,
    DateTimeComponents? repeat,
  }) async {
    final at = tz.TZDateTime(
        tz.local, when.year, when.month, when.day, when.hour, when.minute, when.second);

    Future<void> go(AndroidScheduleMode mode) => _plugin.zonedSchedule(
          id: id,
          scheduledDate: at,
          notificationDetails: details,
          androidScheduleMode: mode,
          title: title,
          body: body,
          payload: payload,
          matchDateTimeComponents: repeat,
        );

    _exactAllowed ??= await _canScheduleExact();
    try {
      await go(_exactAllowed!
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle);
    } on PlatformException catch (e) {
      if (e.code != 'exact_alarms_not_permitted') rethrow;
      _exactAllowed = false;
      await go(AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  Future<bool> _canScheduleExact() async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.canScheduleExactNotifications() ??
          false;
    } catch (_) {
      return false;
    }
  }
}
