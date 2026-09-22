import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../../../l10n/locale_provider.dart';
import '../../calendar/application/now_provider.dart';
import '../../calendar/services/reminder_planner.dart' show reminderId;
import '../../calendar/services/reminder_scheduler.dart';

/// The daily sadhana reminder: on or off, and the time of day.
class DailyReminder {
  const DailyReminder({this.enabled = false, this.minutes = defaultMinutes});

  /// 6:00 AM.
  static const defaultMinutes = 6 * 60;

  final bool enabled;

  /// Minutes after midnight.
  final int minutes;

  int get hour => minutes ~/ 60;
  int get minute => minutes % 60;

  DailyReminder copyWith({bool? enabled, int? minutes}) => DailyReminder(
        enabled: enabled ?? this.enabled,
        minutes: (minutes ?? this.minutes).clamp(0, 24 * 60 - 1),
      );

  Map<String, dynamic> toMap() => {'enabled': enabled, 'minutes': minutes};

  static DailyReminder fromMap(Object? m) {
    if (m is! Map) return const DailyReminder();
    final mins = m['minutes'];
    return DailyReminder(
      enabled: m['enabled'] == true,
      minutes: mins is int && mins >= 0 && mins < 24 * 60 ? mins : defaultMinutes,
    );
  }
}

/// The next time of day [minutes] after [now] (today if still ahead).
DateTime nextOccurrence(DateTime now, int minutes) {
  final today = DateTime(now.year, now.month, now.day, minutes ~/ 60, minutes % 60);
  return today.isAfter(now)
      ? today
      : DateTime(now.year, now.month, now.day + 1, minutes ~/ 60, minutes % 60);
}

/// Saved in Hive. Turning it on (or changing the time) schedules one daily
/// repeating local notification; the app also re-schedules it on every start.
class DailyReminderNotifier extends Notifier<DailyReminder> {
  static const _key = 'profile.dailyReminder';

  @override
  DailyReminder build() {
    Future.microtask(reschedule);
    return DailyReminder.fromMap(AppStorage.settings.get(_key));
  }

  /// Turns it on or off. Turning it on asks for notification permission; false
  /// means that was refused (the reminder is still saved, but stays silent).
  Future<bool> setEnabled(bool on) async {
    var allowed = true;
    if (on) allowed = await ref.read(reminderSchedulerProvider).requestPermission();
    if (!ref.mounted) return allowed;
    _set(state.copyWith(enabled: on));
    return allowed;
  }

  void setTime(int minutes) => _set(state.copyWith(minutes: minutes));

  void _set(DailyReminder next) {
    state = next;
    AppStorage.settings.put(_key, next.toMap());
    reschedule();
  }

  Future<void> reschedule() async {
    final scheduler = ref.read(reminderSchedulerProvider);
    try {
      if (!state.enabled) {
        await scheduler.replaceAlerts(dailyReminderGroup, const []);
        return;
      }
      final l = ref.read(l10nProvider);
      await scheduler.replaceAlerts(dailyReminderGroup, [
        ScheduledAlert(
          id: reminderId(dailyReminderGroup, 0, 0),
          when: nextOccurrence(ref.read(nowProvider), state.minutes),
          title: l.sadhanaTimeNotifTitle,
          body: l.sadhanaTimeNotifBody,
          repeatsDaily: true,
          gentle: true,
        ),
      ]);
    } catch (e) {
      debugPrint('Could not schedule the daily reminder: $e');
    }
  }
}

final dailyReminderProvider =
    NotifierProvider<DailyReminderNotifier, DailyReminder>(DailyReminderNotifier.new);
