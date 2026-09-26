import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../l10n/app_localizations.dart';
import '../../../l10n/labels.dart';
import '../../clock/services/tz_init.dart';
import '../data/calendar_mark.dart';
import 'reminder_planner.dart';
import 'reminder_scheduler.dart';

/// How Android is asked to ring a notification.
///
/// A real alarm (the Sadhana finish, the Clock timer, the sun alarm) is set as
/// an ALARM CLOCK: Android then treats it as an alarm the user set (it shows
/// the alarm icon, and Doze and battery savers such as Samsung's let it ring
/// on time). Calendar reminders and other gentle notifications are exact but
/// ordinary. Without exact-alarm permission both fall back to a slightly
/// flexible time.
AndroidScheduleMode scheduleModeFor({required bool alarm, required bool exact}) {
  if (!exact) return AndroidScheduleMode.inexactAllowWhileIdle;
  return alarm ? AndroidScheduleMode.alarmClock : AndroidScheduleMode.exactAllowWhileIdle;
}

/// The small icon of EVERY Sadho notification (res/drawable-*/ic_stat_sadho,
/// made from assets/branding/notification-icon.png), and its accent colour:
/// saffron, from the logo's bead. The Mala service uses the same pair.
const notificationIcon = 'ic_stat_sadho';
const notificationAccent = Color(0xFFFF9933);

/// The Android notification channel of a Sadhana completion alarm with
/// [style]. Android fixes a channel's sound and vibration when it is first
/// created, so every combination gets its own channel (e.g. "Sadhana alarm ·
/// Temple bell"). The Mala service rings on the same channel.
({String id, String name, String description}) sadhanaAlarmChannel(
    AlarmStyle style, AppLocalizations l) {
  final sound = style.sound;
  final name = sound == null
      ? l.channelSadhanaAlarmSilentName
      : l.channelSadhanaAlarmName(style.soundLabel);
  return (
    id: 'sadhana_alarm_${sound ?? 'silent'}_${style.vibrate ? 'v' : 'nv'}',
    name: style.vibrate ? name : '$name · ${l.channelNoVibration}',
    description: l.channelSadhanaAlarmDesc,
  );
}

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

  /// Asks Android what the notification plugin cannot (see MainActivity).
  static const _native = MethodChannel('sadho/alarm');

  /// Android's FLAG_INSISTENT: the sound (and vibration) repeat until the
  /// notification is dismissed.
  static const _flagInsistent = 4;

  /// A long-short alarm buzz, repeated by FLAG_INSISTENT when that is on.
  static final _alarmVibration =
      Int64List.fromList([0, 700, 300, 700, 300, 1200]);

  final _opened = StreamController<String>.broadcast();
  String? _launchPayload;

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
        android: AndroidInitializationSettings(notificationIcon),
        // Permission is asked when the first reminder is saved, not at launch.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        final p = r.payload;
        if (p != null) _opened.add(p);
      },
    );
    try {
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        _launchPayload = launch!.notificationResponse?.payload;
      }
    } catch (e) {
      debugPrint('Could not read how the app was launched: $e');
    }
  }

  @override
  Stream<String> get opened async* {
    // The tap that launched the app is delivered once, to the first listener.
    final launch = _launchPayload;
    _launchPayload = null;
    if (launch != null) yield launch;
    yield* _opened.stream;
  }

  NotificationDetails get _details {
    final l = currentL10n();
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        l.channelCalendarRemindersName,
        channelDescription: l.channelCalendarRemindersDesc,
        icon: notificationIcon,
        color: notificationAccent,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  /// Alarm-style: loud, on the ALARM stream (so a muted media volume does not
  /// silence it), and marked as an alarm/timer for the system.
  NotificationDetails get _alarmDetails {
    final l = currentL10n();
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _alarmChannelId,
        l.channelAlarmsName,
        channelDescription: l.channelAlarmsDesc,
        icon: notificationIcon,
        color: notificationAccent,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  /// A Sadhana completion alarm, on its [sadhanaAlarmChannel].
  NotificationDetails _styledAlarmDetails(AlarmStyle style) {
    final sound = style.sound;
    final channel = sadhanaAlarmChannel(style, currentL10n());
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: notificationIcon,
        color: notificationAccent,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        playSound: sound != null,
        sound: sound == null ? null : RawResourceAndroidNotificationSound(sound),
        enableVibration: style.vibrate,
        vibrationPattern: style.vibrate ? _alarmVibration : null,
        additionalFlags:
            style.insistent ? Int32List.fromList([_flagInsistent]) : null,
      ),
      // Time-sensitive breaks through Focus where allowed; without that
      // entitlement iOS shows it as a normal notification.
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentSound: sound != null,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      defaultTargetPlatform == TargetPlatform.android
          ? _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          : null;

  @override
  Future<bool> canScheduleExact() async {
    // Asked afresh: the user may have just allowed it in the settings.
    _exactAllowed = await _canScheduleExact();
    return _exactAllowed! || defaultTargetPlatform != TargetPlatform.android;
  }

  @override
  Future<bool> requestExactAlarms() async {
    try {
      await _android?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint('Exact alarm permission request failed: $e');
    }
    return canScheduleExact();
  }

  @override
  Future<bool> canUseFullScreen() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    try {
      return await _native.invokeMethod<bool>('canUseFullScreenIntent') ?? true;
    } catch (e) {
      // Unknown: assume allowed (Android then shows a heads-up if it is not).
      return true;
    }
  }

  @override
  Future<bool> requestFullScreen() async {
    try {
      return await _android?.requestFullScreenIntentPermission() ?? true;
    } catch (e) {
      debugPrint('Full-screen permission request failed: $e');
      return false;
    }
  }

  @override
  Future<void> dismissShown(String group) async {
    try {
      final shown = await _plugin.getActiveNotifications();
      for (final n in shown) {
        if (n.payload == group && n.id != null) await _plugin.cancel(id: n.id!);
      }
    } catch (e) {
      debugPrint('Could not dismiss shown alerts: $e');
    }
  }

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
          details: a.style != null
              ? _styledAlarmDetails(a.style!)
              : (a.gentle ? _details : _alarmDetails),
          title: a.title,
          body: a.body,
          payload: group,
          repeat: a.repeatsDaily ? DateTimeComponents.time : null,
          alarm: !a.gentle,
        );
      } catch (e) {
        debugPrint('Could not schedule alert ${a.id}: $e');
      }
    }
  }

  Future<void> _scheduleAll(CalendarMark mark) async {
    for (final p in planReminders(mark, DateTime.now(), l10n: currentL10n())) {
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
    bool alarm = false,
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
      await go(scheduleModeFor(alarm: alarm, exact: _exactAllowed!));
    } on PlatformException catch (e) {
      if (e.code != 'exact_alarms_not_permitted') rethrow;
      _exactAllowed = false;
      await go(scheduleModeFor(alarm: alarm, exact: false));
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
