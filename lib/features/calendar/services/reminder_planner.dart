import '../../../l10n/l10n.dart';
import '../../../l10n/labels.dart';
import '../data/calendar_mark.dart';

/// How a planned reminder repeats on its own (handled by the phone's alarm
/// system, so it keeps ringing without the app being opened).
enum PlannedRepeat { none, daily, weekly }

/// One notification to hand to the system.
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.markId,
    required this.when,
    required this.repeat,
    required this.title,
    required this.body,
  });

  /// Stable notification id (same inputs always give the same id).
  final int id;
  final String markId;

  /// Local wall-clock time of the first ring.
  final DateTime when;
  final PlannedRepeat repeat;
  final String title;
  final String body;
}

/// How many upcoming dates are handed to the system at once for the rules the
/// alarm system cannot repeat itself. Refreshed every time the app starts and
/// whenever a mark changes, so each covers a long stretch (monthly: a year).
int upcomingWindow(RepeatRule rule) => switch (rule) {
      RepeatRule.monthly => 12,
      RepeatRule.quarterly => 8,
      RepeatRule.halfYearly => 6,
      RepeatRule.yearly => 5,
      _ => 1,
    };

/// A stable 31-bit id for one notification of one mark.
int reminderId(String markId, int timeIndex, int occurrence) {
  // FNV-1a over "markId#time#occurrence".
  var h = 0x811c9dc5;
  for (final c in '$markId#$timeIndex#$occurrence'.codeUnits) {
    h = ((h ^ c) * 0x01000193) & 0xffffffff;
  }
  return h & 0x7fffffff;
}

String _oneLine(String s, int max) {
  final t = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return t.length <= max ? t : '${t.substring(0, max - 1).trimRight()}…';
}

/// Title and body of a mark's notification, in [l10n] (English by default,
/// which is what every existing caller and test expects).
({String title, String body}) reminderText(CalendarMark m, [AppLocalizations? l10n]) {
  final l = l10n ?? englishL10n;
  final title = m.emoji == null ? m.titleIn(l) : '${m.emoji} ${m.titleIn(l)}';
  final body = m.details.trim().isNotEmpty
      ? _oneLine(m.details, 140)
      : switch (m.type) {
          MarkType.good => l.reminderBodyGood,
          MarkType.cautious => l.reminderBodyCautious,
          MarkType.neutral => l.reminderBodyNeutral,
        };
  return (title: title, body: body);
}

/// What to schedule for [m], given the current time [now].
///
/// - Once: one notification, if it is still ahead.
/// - Daily / Weekly: ONE repeating notification starting at the next ring.
/// - Monthly ... Yearly: the next few dates as separate notifications.
///
/// Nothing is planned in the past, and never before the mark's first date.
/// Capped at [maxTotal] notifications per mark.
List<PlannedReminder> planReminders(
  CalendarMark m,
  DateTime now, {
  int maxTotal = 60,
  AppLocalizations? l10n,
}) {
  final times = m.effectiveReminderTimes;
  if (times.isEmpty) return const [];
  final today = dateOnly(now);
  final text = reminderText(m, l10n);
  final out = <PlannedReminder>[];

  DateTime at(DateTime d, int minutes) =>
      DateTime(d.year, d.month, d.day, minutes ~/ 60, minutes % 60);

  for (var i = 0; i < times.length; i++) {
    final t = times[i];
    PlannedReminder plan(int k, DateTime when, PlannedRepeat repeat) =>
        PlannedReminder(
          id: reminderId(m.id, i, k),
          markId: m.id,
          when: when,
          repeat: repeat,
          title: text.title,
          body: text.body,
        );

    switch (m.repeat) {
      case RepeatRule.once:
        if (at(m.date, t).isAfter(now)) {
          out.add(plan(0, at(m.date, t), PlannedRepeat.none));
        }
      case RepeatRule.daily:
        final start = m.date.isAfter(today) ? m.date : today;
        var first = at(start, t);
        if (!first.isAfter(now)) {
          first = at(DateTime(start.year, start.month, start.day + 1), t);
        }
        out.add(plan(0, first, PlannedRepeat.daily));
      case RepeatRule.weekly:
        for (final d in m.nextOccurrences(today, 2)) {
          if (at(d, t).isAfter(now)) {
            out.add(plan(0, at(d, t), PlannedRepeat.weekly));
            break;
          }
        }
      case RepeatRule.monthly:
      case RepeatRule.quarterly:
      case RepeatRule.halfYearly:
      case RepeatRule.yearly:
        final window = upcomingWindow(m.repeat);
        var k = 0;
        for (final d in m.nextOccurrences(today, window + 1)) {
          if (k >= window) break;
          if (at(d, t).isAfter(now)) {
            out.add(plan(k, at(d, t), PlannedRepeat.none));
            k++;
          }
        }
    }
  }
  return out.length > maxTotal ? out.sublist(0, maxTotal) : out;
}
