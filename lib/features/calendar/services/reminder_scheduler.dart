import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/calendar_mark.dart';

/// One alarm-style notification: the sun alarm ringing, a timer finishing.
class ScheduledAlert {
  const ScheduledAlert({
    required this.id,
    required this.when,
    required this.title,
    required this.body,
  });

  /// Stable notification id.
  final int id;

  /// Local wall-clock time it rings.
  final DateTime when;
  final String title;
  final String body;
}

/// Groups of alerts (they share a notification payload, so a whole group can
/// be replaced or cancelled at once, and are left alone when the calendar's
/// reminders are refreshed).
const sunAlarmGroup = 'sun-alarm';
const timerGroup = 'timer';
const alertGroups = {sunAlarmGroup, timerGroup};

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

  /// Replaces every alert of [group] ([sunAlarmGroup] or [timerGroup]) with
  /// [alerts]; an empty list just cancels them. These ring loudly, on the
  /// alarm stream, like an alarm clock.
  Future<void> replaceAlerts(String group, List<ScheduledAlert> alerts);
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
}

/// `main()` overrides this with the real notification scheduler.
final reminderSchedulerProvider =
    Provider<ReminderScheduler>((ref) => NoopReminderScheduler());
