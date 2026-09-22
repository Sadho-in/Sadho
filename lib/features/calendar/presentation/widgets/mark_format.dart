import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../data/calendar_mark.dart';

/// "6:30 AM" / "18:30" (follows the phone's 12/24-hour setting).
String formatMinutes(BuildContext context, int minutes) =>
    MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60));

/// "Every week", "Every 3 months"...
String repeatSummary(BuildContext context, RepeatRule r) {
  final l = context.l10n;
  return switch (r) {
    RepeatRule.once => l.repeatSummaryOnce,
    RepeatRule.daily => l.repeatSummaryDaily,
    RepeatRule.weekly => l.repeatSummaryWeekly,
    RepeatRule.monthly => l.repeatSummaryMonthly,
    RepeatRule.quarterly => l.repeatSummaryQuarterly,
    RepeatRule.halfYearly => l.repeatSummaryHalfYearly,
    RepeatRule.yearly => l.repeatSummaryYearly,
  };
}

/// "Remind at 6:00 AM, 6:00 PM", or null when there is no reminder.
String? reminderSummary(BuildContext context, CalendarMark m) {
  final times = m.effectiveReminderTimes;
  if (times.isEmpty) return null;
  return context.l10n.reminderSummaryAt(
      times.map((t) => formatMinutes(context, t)).join(', '));
}

/// "On Home: morning 7:00 AM" / "On Home: all day", or null.
String? homeSummary(BuildContext context, CalendarMark m) {
  final l = context.l10n;
  return switch (m.homeMode) {
    HomeMode.none => null,
    HomeMode.morning => l.homeSummaryFrom(formatMinutes(context, m.homeMinutes)),
    HomeMode.allDay => l.homeSummaryAllDay,
  };
}

/// "Mon, 21 Sep 2026".
String formatShortDate(BuildContext context, DateTime d) =>
    MaterialLocalizations.of(context).formatMediumDate(d);
