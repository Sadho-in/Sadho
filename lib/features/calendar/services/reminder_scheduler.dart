import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/calendar_mark.dart';

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
  /// windows and heals anything the OS dropped).
  Future<void> rescheduleAll(Iterable<CalendarMark> marks);
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
}

/// `main()` overrides this with the real notification scheduler.
final reminderSchedulerProvider =
    Provider<ReminderScheduler>((ref) => NoopReminderScheduler());
