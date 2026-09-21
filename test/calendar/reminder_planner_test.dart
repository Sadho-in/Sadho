import 'package:advance_calendar/features/calendar/data/calendar_mark.dart';
import 'package:advance_calendar/features/calendar/services/reminder_planner.dart';
import 'package:flutter_test/flutter_test.dart';

CalendarMark mark(
  DateTime date, {
  RepeatRule repeat = RepeatRule.once,
  ReminderMode mode = ReminderMode.once,
  List<int> times = const [9 * 60],
  String id = 'm1',
  String label = 'Puja',
  String details = '',
  String? emoji,
  MarkType type = MarkType.good,
}) =>
    CalendarMark(
      id: id,
      date: dateOnly(date),
      repeat: repeat,
      reminderMode: mode,
      reminderTimes: times,
      label: label,
      details: details,
      emoji: emoji,
      type: type,
    );

String hm(DateTime d) => '${d.hour}:${d.minute.toString().padLeft(2, '0')}';
List<String> whens(List<PlannedReminder> l) => [for (final p in l) dateKey(p.when)];

void main() {
  // Monday 21 Sep 2026, 08:00.
  final now = DateTime(2026, 9, 21, 8, 0);

  group('nothing to plan', () {
    test('No time', () {
      expect(planReminders(mark(DateTime(2026, 9, 22), mode: ReminderMode.none), now),
          isEmpty);
    });

    test('Several times with none added', () {
      expect(
          planReminders(
              mark(DateTime(2026, 9, 22), mode: ReminderMode.several, times: []), now),
          isEmpty);
    });

    test('a one-off in the past', () {
      expect(planReminders(mark(DateTime(2026, 9, 20)), now), isEmpty);
      expect(planReminders(mark(DateTime(2026, 9, 21), times: [7 * 60]), now), isEmpty,
          reason: 'today, but 7:00 has passed');
      expect(planReminders(mark(DateTime(2026, 9, 21), times: [8 * 60]), now), isEmpty,
          reason: 'exactly now is not in the future');
    });
  });

  group('Once', () {
    test('one notification on its date and time', () {
      final p = planReminders(mark(DateTime(2026, 9, 25), times: [6 * 60 + 30]), now);
      expect(p.length, 1);
      expect(p.single.when, DateTime(2026, 9, 25, 6, 30));
      expect(p.single.repeat, PlannedRepeat.none);
    });

    test('later today still counts', () {
      final p = planReminders(mark(DateTime(2026, 9, 21), times: [9 * 60]), now);
      expect(p.single.when, DateTime(2026, 9, 21, 9, 0));
    });

    test('One time uses just the first time even if several are stored', () {
      final p = planReminders(
          mark(DateTime(2026, 9, 25), times: [7 * 60, 18 * 60]), now);
      expect(p.length, 1);
      expect(p.single.when.hour, 7);
    });

    test('Several times: one notification per time, each with its own id', () {
      final p = planReminders(
          mark(DateTime(2026, 9, 25),
              mode: ReminderMode.several, times: [6 * 60, 12 * 60, 18 * 60]),
          now);
      expect([for (final r in p) hm(r.when)], ['6:00', '12:00', '18:00']);
      expect({for (final r in p) r.id}.length, 3);
    });

    test('Several times: past times today are skipped, later ones kept', () {
      final p = planReminders(
          mark(DateTime(2026, 9, 21),
              mode: ReminderMode.several, times: [6 * 60, 12 * 60, 18 * 60]),
          now);
      expect([for (final r in p) hm(r.when)], ['12:00', '18:00']);
    });
  });

  group('Daily: ONE repeating notification', () {
    test('starts today if the time is still ahead', () {
      final p = planReminders(
          mark(DateTime(2026, 9, 1), repeat: RepeatRule.daily, times: [9 * 60]), now);
      expect(p.length, 1, reason: 'the alarm system does the repeating');
      expect(p.single.when, DateTime(2026, 9, 21, 9, 0));
      expect(p.single.repeat, PlannedRepeat.daily);
    });

    test('starts tomorrow if today\'s time has passed', () {
      final p = planReminders(
          mark(DateTime(2026, 9, 1), repeat: RepeatRule.daily, times: [7 * 60]), now);
      expect(p.single.when, DateTime(2026, 9, 22, 7, 0));
    });

    test('never rings before the first date', () {
      final p = planReminders(
          mark(DateTime(2026, 10, 5), repeat: RepeatRule.daily, times: [7 * 60]), now);
      expect(p.single.when, DateTime(2026, 10, 5, 7, 0));
    });

    test('one repeating notification per time of day', () {
      final p = planReminders(
          mark(DateTime(2026, 9, 1),
              repeat: RepeatRule.daily,
              mode: ReminderMode.several,
              times: [6 * 60, 20 * 60]),
          now);
      expect(p.length, 2);
      expect(p.every((r) => r.repeat == PlannedRepeat.daily), isTrue);
      expect([for (final r in p) r.when], [
        DateTime(2026, 9, 22, 6, 0),
        DateTime(2026, 9, 21, 20, 0),
      ], reason: '6:00 has passed today, so tomorrow; 20:00 is still ahead');
    });
  });

  group('Weekly: ONE repeating notification', () {
    test('starts on the next matching weekday', () {
      // Mark started on Monday 7 Sep; now is Monday 21 Sep 08:00.
      final p = planReminders(
          mark(DateTime(2026, 9, 7), repeat: RepeatRule.weekly, times: [9 * 60]), now);
      expect(p.length, 1);
      expect(p.single.when, DateTime(2026, 9, 21, 9, 0), reason: 'today, 9:00 ahead');
      expect(p.single.repeat, PlannedRepeat.weekly);
    });

    test('a time that has passed today waits for next week', () {
      final p = planReminders(
          mark(DateTime(2026, 9, 7), repeat: RepeatRule.weekly, times: [7 * 60]), now);
      expect(p.single.when, DateTime(2026, 9, 28, 7, 0));
    });

    test('a different weekday', () {
      // Started on a Friday (4 Sep): next Friday is 25 Sep.
      final p = planReminders(
          mark(DateTime(2026, 9, 4), repeat: RepeatRule.weekly, times: [9 * 60]), now);
      expect(p.single.when, DateTime(2026, 9, 25, 9, 0));
      expect(p.single.when.weekday, DateTime.friday);
    });

    test('not before the first date', () {
      final p = planReminders(
          mark(DateTime(2026, 11, 2), repeat: RepeatRule.weekly, times: [9 * 60]), now);
      expect(p.single.when, DateTime(2026, 11, 2, 9, 0));
    });
  });

  group('Monthly, quarterly, half-yearly, yearly: a rolling window', () {
    test('Monthly plans the next 12 dates as separate notifications', () {
      final p = planReminders(
          mark(DateTime(2026, 1, 15), repeat: RepeatRule.monthly, times: [9 * 60]), now);
      expect(p.length, 12);
      expect(p.every((r) => r.repeat == PlannedRepeat.none), isTrue);
      expect(p.first.when, DateTime(2026, 10, 15, 9, 0));
      expect(p.last.when, DateTime(2027, 9, 15, 9, 0));
    });

    test('Monthly from the 31st clamps to shorter months', () {
      final p = planReminders(
          mark(DateTime(2026, 1, 31), repeat: RepeatRule.monthly, times: [9 * 60]),
          DateTime(2026, 1, 1));
      expect(whens(p).take(5).toList(),
          ['2026-01-31', '2026-02-28', '2026-03-31', '2026-04-30', '2026-05-31']);
    });

    test('a date already gone today is not planned', () {
      final p = planReminders(
          mark(DateTime(2026, 8, 21), repeat: RepeatRule.monthly, times: [7 * 60]), now);
      expect(p.first.when, DateTime(2026, 10, 21, 7, 0),
          reason: '21 Sep 7:00 already passed at 8:00');
    });

    test('window sizes: quarterly 8, half-yearly 6, yearly 5', () {
      DateTime start = DateTime(2026, 1, 15);
      final base = DateTime(2026, 1, 1);
      expect(planReminders(mark(start, repeat: RepeatRule.quarterly), base).length, 8);
      expect(planReminders(mark(start, repeat: RepeatRule.halfYearly), base).length, 6);
      expect(planReminders(mark(start, repeat: RepeatRule.yearly), base).length, 5);
      expect(upcomingWindow(RepeatRule.monthly), 12);
    });

    test('several times multiply the window per time', () {
      final p = planReminders(
          mark(DateTime(2026, 1, 15),
              repeat: RepeatRule.monthly,
              mode: ReminderMode.several,
              times: [6 * 60, 18 * 60]),
          DateTime(2026, 1, 1));
      expect(p.length, 24);
      expect({for (final r in p) r.id}.length, 24, reason: 'all ids differ');
    });

    test('everything is strictly in the future and never before the start', () {
      for (final r in [RepeatRule.monthly, RepeatRule.quarterly, RepeatRule.halfYearly, RepeatRule.yearly]) {
        final m = mark(DateTime(2027, 3, 10), repeat: r, times: [9 * 60]);
        for (final p in planReminders(m, now)) {
          expect(p.when.isAfter(now), isTrue, reason: r.name);
          expect(dateOnly(p.when).isBefore(m.date), isFalse, reason: r.name);
        }
      }
    });

    test('the total is capped per mark', () {
      final p = planReminders(
          mark(DateTime(2026, 1, 15),
              repeat: RepeatRule.monthly,
              mode: ReminderMode.several,
              times: [for (var i = 0; i < 8; i++) (6 + i) * 60]),
          DateTime(2026, 1, 1));
      expect(p.length, 60, reason: '8 times x 12 dates = 96, capped at 60');
    });
  });

  group('ids', () {
    test('are stable, 31-bit, and differ by mark, time and occurrence', () {
      expect(reminderId('a', 0, 0), reminderId('a', 0, 0));
      final ids = {
        for (final m in ['a', 'b', 'c'])
          for (var t = 0; t < 8; t++)
            for (var k = 0; k < 12; k++) reminderId(m, t, k),
      };
      expect(ids.length, 3 * 8 * 12, reason: 'no collisions in a realistic set');
      for (final id in ids) {
        expect(id, inInclusiveRange(0, 0x7fffffff));
      }
    });

    test('planning twice gives the same ids (so re-scheduling replaces)', () {
      final m = mark(DateTime(2026, 9, 25));
      expect(planReminders(m, now).single.id, planReminders(m, now).single.id);
    });
  });

  group('notification text', () {
    test('title is the emoji and the label', () {
      final p = planReminders(mark(DateTime(2026, 9, 25), label: 'Ekadashi', emoji: '🪔'), now);
      expect(p.single.title, '🪔 Ekadashi');
    });

    test('no emoji: just the label; no label: the type', () {
      expect(reminderText(mark(DateTime(2026, 9, 25), label: 'Puja')).title, 'Puja');
      expect(reminderText(mark(DateTime(2026, 9, 25), label: '', type: MarkType.cautious)).title,
          'Cautious day');
    });

    test('body is the details on one line, shortened when long', () {
      final b = reminderText(mark(DateTime(2026, 9, 25),
              details: 'Fast until\n  sunset.\n\nLight a lamp.'))
          .body;
      expect(b, 'Fast until sunset. Light a lamp.');
      final long = reminderText(mark(DateTime(2026, 9, 25), details: 'word ' * 100)).body;
      expect(long.length, lessThanOrEqualTo(140));
      expect(long.endsWith('…'), isTrue);
    });

    test('with no details the body says what kind of day it is', () {
      expect(reminderText(mark(DateTime(2026, 9, 25), type: MarkType.good)).body, 'A good day.');
      expect(reminderText(mark(DateTime(2026, 9, 25), type: MarkType.cautious)).body,
          'Be careful today.');
      expect(reminderText(mark(DateTime(2026, 9, 25), type: MarkType.neutral)).body,
          'Marked in your calendar.');
    });
  });
}
