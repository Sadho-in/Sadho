import 'package:flutter/material.dart';

import '../../data/calendar_mark.dart';

/// "6:30 AM" / "18:30" (follows the phone's 12/24-hour setting).
String formatMinutes(BuildContext context, int minutes) =>
    MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60));

/// "Every week", "Every 3 months"...
String repeatSummary(RepeatRule r) => switch (r) {
      RepeatRule.once => 'Once',
      RepeatRule.daily => 'Every day',
      RepeatRule.weekly => 'Every week',
      RepeatRule.monthly => 'Every month',
      RepeatRule.quarterly => 'Every 3 months',
      RepeatRule.halfYearly => 'Every 6 months',
      RepeatRule.yearly => 'Every year',
    };

/// "Remind at 6:00 AM, 6:00 PM", or null when there is no reminder.
String? reminderSummary(BuildContext context, CalendarMark m) {
  final times = m.effectiveReminderTimes;
  if (times.isEmpty) return null;
  return 'Remind at ${times.map((t) => formatMinutes(context, t)).join(', ')}';
}

/// "On Home: morning 7:00 AM" / "On Home: all day", or null.
String? homeSummary(BuildContext context, CalendarMark m) => switch (m.homeMode) {
      HomeMode.none => null,
      HomeMode.morning => 'On Home from ${formatMinutes(context, m.homeMinutes)}',
      HomeMode.allDay => 'On Home all day',
    };

/// "Mon, 21 Sep 2026".
String formatShortDate(BuildContext context, DateTime d) =>
    MaterialLocalizations.of(context).formatMediumDate(d);
