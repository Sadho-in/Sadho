import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/calendar_mark.dart';

/// One alarm-style notification: the sun alarm ringing, a timer finishing.
class ScheduledAlert {
  const ScheduledAlert({
    required this.id,
    required this.when,
    required this.title,
    required this.body,
    this.repeatsDaily = false,
    this.gentle = false,
    this.style,
  });

  /// Stable notification id.
  final int id;

  /// Local wall-clock time it rings.
  final DateTime when;
  final String title;
  final String body;

  /// Rings again at the same time every day after [when] (one notification,
  /// repeated by the phone), instead of just once.
  final bool repeatsDaily;

  /// An ordinary notification (the calendar's channel) rather than a loud
  /// alarm-style one.
  final bool gentle;

  /// How a Sadhana completion alarm sounds (ringtone, vibration, repeating).
  /// Null: the standard alarm/timer notification.
  final AlarmStyle? style;
}

/// The sound and feel of a Sadhana completion alarm, from the user's
/// completion settings. It always shows over the lock screen where the phone
/// allows it (full-screen intent), like an alarm clock.
class AlarmStyle {
  const AlarmStyle({
    required this.sound,
    required this.soundLabel,
    required this.vibrate,
    required this.insistent,
  });

  /// Android raw resource name of the ringtone (e.g. `temple_bell`), or null
  /// for a silent alarm.
  final String? sound;

  /// The ringtone's name, for the notification channel shown in the phone's
  /// settings.
  final String soundLabel;
  final bool vibrate;

  /// Keeps ringing (and vibrating) until dismissed.
  final bool insistent;

  @override
  bool operator ==(Object other) =>
      other is AlarmStyle &&
      other.sound == sound &&
      other.vibrate == vibrate &&
      other.insistent == insistent;

  @override
  int get hashCode => Object.hash(sound, vibrate, insistent);
}

/// Groups of alerts (they share a notification payload, so a whole group can
/// be replaced or cancelled at once, and are left alone when the calendar's
/// reminders are refreshed).
const sunAlarmGroup = 'sun-alarm';
const timerGroup = 'timer';
const dailyReminderGroup = 'daily-sadhana';

/// The end of a Sadhana session with a time target (rings if the app is not
/// running its own clock, e.g. with the screen off).
const sadhanaTimerGroup = 'sadhana-timer';
const alertGroups = {
  sunAlarmGroup,
  timerGroup,
  dailyReminderGroup,
  sadhanaTimerGroup,
};

/// Puts a mark's reminders on the phone's alarm system (local notifications:
/// no server, works offline). Behind an interface so tests never touch a
/// platform plugin.
abstract class ReminderScheduler {
  /// False where notifications cannot be scheduled (web, desktop).
  bool get isSupported;

  /// Asks the user to allow notifications (first time only). True if allowed
  /// (or if no permission is needed on this OS version).
  Future<bool> requestPermission();

  /// Replaces whatever was scheduled for [mark] with its current reminders.
  Future<void> schedule(CalendarMark mark);

  /// Removes every reminder of the mark with [markId].
  Future<void> cancel(String markId);

  /// Rebuilds all reminders from [marks] (app start: refreshes the rolling
  /// windows and heals anything the OS dropped). Alerts in [alertGroups] are
  /// not touched.
  Future<void> rescheduleAll(Iterable<CalendarMark> marks);

  /// Replaces every alert of [group] (one of [alertGroups]) with [alerts]; an
  /// empty list just cancels them. Unless an alert is [ScheduledAlert.gentle]
  /// it rings loudly, on the alarm stream, like an alarm clock.
  Future<void> replaceAlerts(String group, List<ScheduledAlert> alerts);

  /// Whether alarms ring at the exact second (Android's "Alarms & reminders"
  /// permission). Otherwise they ring a little flexibly. True where there is
  /// no such permission.
  Future<bool> canScheduleExact();

  /// Opens the phone's page to allow exact alarms. True if allowed after.
  Future<bool> requestExactAlarms();

  /// Whether an alarm may show full screen over the lock screen (Android 14+
  /// asks for this). Otherwise it is a normal heads-up notification.
  Future<bool> canUseFullScreen();

  /// Opens the phone's page to allow full-screen alarms. True if allowed.
  Future<bool> requestFullScreen();

  /// The group of every alert notification the user taps (including the one
  /// that launched the app).
  Stream<String> get opened;

  /// Removes alerts of [group] that have ALREADY rung and are still on screen
  /// (which also stops one that keeps ringing until dismissed).
  Future<void> dismissShown(String group);
}

/// Does nothing. Used where notifications are unsupported, and in tests.
class NoopReminderScheduler implements ReminderScheduler {
  @override
  bool get isSupported => false;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> schedule(CalendarMark mark) async {}

  @override
  Future<void> cancel(String markId) async {}

  @override
  Future<void> rescheduleAll(Iterable<CalendarMark> marks) async {}

  @override
  Future<void> replaceAlerts(String group, List<ScheduledAlert> alerts) async {}

  @override
  Future<bool> canScheduleExact() async => true;

  @override
  Future<bool> requestExactAlarms() async => true;

  @override
  Future<bool> canUseFullScreen() async => true;

  @override
  Future<bool> requestFullScreen() async => true;

  @override
  Stream<String> get opened => const Stream.empty();

  @override
  Future<void> dismissShown(String group) async {}
}

/// `main()` overrides this with the real notification scheduler.
final reminderSchedulerProvider =
    Provider<ReminderScheduler>((ref) => NoopReminderScheduler());
