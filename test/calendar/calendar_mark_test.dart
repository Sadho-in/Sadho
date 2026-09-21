import 'package:advance_calendar/features/calendar/data/calendar_mark.dart';
import 'package:flutter_test/flutter_test.dart';

CalendarMark mark(
  DateTime date, {
  RepeatRule repeat = RepeatRule.once,
  ReminderMode mode = ReminderMode.none,
  List<int> times = const [],
  String id = 'm1',
}) =>
    CalendarMark(
      id: id,
      date: dateOnly(date),
      repeat: repeat,
      reminderMode: mode,
      reminderTimes: times,
    );

void main() {
  group('dates', () {
    test('dateKey is a stable yyyy-MM-dd', () {
      expect(dateKey(DateTime(2026, 9, 5, 23, 59)), '2026-09-05');
      expect(dateKey(DateTime(12, 1, 2)), '0012-01-02');
    });

    test('parseDateKey reads valid keys and rejects everything else', () {
      expect(parseDateKey('2026-09-21'), DateTime(2026, 9, 21));
      expect(parseDateKey('2028-02-29'), DateTime(2028, 2, 29));
      expect(parseDateKey('2026-02-29'), isNull, reason: 'not a leap year');
      expect(parseDateKey('2026-02-31'), isNull, reason: 'would roll over');
      expect(parseDateKey('2026-13-01'), isNull);
      expect(parseDateKey('26-9-21'), isNull);
      expect(parseDateKey('2026-09-21T10:00'), isNull);
      expect(parseDateKey(null), isNull);
      expect(parseDateKey(20260921), isNull);
    });

    test('dateOnly drops the time of day', () {
      expect(dateOnly(DateTime(2026, 9, 21, 18, 30, 5)), DateTime(2026, 9, 21));
    });

    test('daysInMonth knows leap years', () {
      expect(daysInMonth(2026, 2), 28);
      expect(daysInMonth(2028, 2), 29);
      expect(daysInMonth(2100, 2), 28, reason: 'century, not a leap year');
      expect(daysInMonth(2000, 2), 29);
      expect(daysInMonth(2026, 4), 30);
      expect(daysInMonth(2026, 12), 31);
    });
  });

  group('occursOn', () {
    test('Once: only on its own date', () {
      final m = mark(DateTime(2026, 9, 21));
      expect(m.occursOn(DateTime(2026, 9, 21)), isTrue);
      expect(m.occursOn(DateTime(2026, 9, 21, 15)), isTrue, reason: 'any time');
      expect(m.occursOn(DateTime(2026, 9, 20)), isFalse);
      expect(m.occursOn(DateTime(2026, 9, 22)), isFalse);
      expect(m.occursOn(DateTime(2027, 9, 21)), isFalse);
    });

    test('nothing occurs before the first date', () {
      for (final r in RepeatRule.values) {
        final m = mark(DateTime(2026, 9, 21), repeat: r);
        expect(m.occursOn(DateTime(2026, 9, 20)), isFalse, reason: r.name);
        expect(m.occursOn(DateTime(2020, 1, 1)), isFalse, reason: r.name);
        expect(m.occursOn(DateTime(2026, 9, 21)), isTrue, reason: r.name);
      }
    });

    test('Daily: every day from the start', () {
      final m = mark(DateTime(2026, 9, 21), repeat: RepeatRule.daily);
      for (var i = 0; i < 400; i += 37) {
        expect(m.occursOn(DateTime(2026, 9, 21 + i)), isTrue);
      }
    });

    test('Weekly: the same weekday, every 7 days', () {
      final m = mark(DateTime(2026, 9, 21), repeat: RepeatRule.weekly);
      expect(m.occursOn(DateTime(2026, 9, 28)), isTrue);
      expect(m.occursOn(DateTime(2026, 10, 5)), isTrue);
      expect(m.occursOn(DateTime(2026, 9, 22)), isFalse);
      expect(m.occursOn(DateTime(2026, 9, 27)), isFalse);
      expect(m.occursOn(DateTime(2027, 9, 20)), isTrue, reason: '52 weeks on');
    });

    test('Weekly stays on its weekday across daylight-saving changes', () {
      // Mondays through the spring and autumn clock changes.
      final start = mark(DateTime(2026, 1, 5), repeat: RepeatRule.weekly);
      for (var i = 0; i < 60; i++) {
        final d = DateTime(2026, 1, 5 + 7 * i);
        expect(d.weekday, DateTime.monday);
        expect(start.occursOn(d), isTrue, reason: 'week $i');
        expect(start.occursOn(DateTime(d.year, d.month, d.day + 1)), isFalse);
      }
    });

    test('Monthly: the same day each month, clamped to short months', () {
      final m = mark(DateTime(2026, 1, 31), repeat: RepeatRule.monthly);
      expect(m.occursOn(DateTime(2026, 2, 28)), isTrue, reason: '31st -> 28th');
      expect(m.occursOn(DateTime(2026, 2, 27)), isFalse);
      expect(m.occursOn(DateTime(2026, 3, 31)), isTrue);
      expect(m.occursOn(DateTime(2026, 4, 30)), isTrue, reason: '31st -> 30th');
      expect(m.occursOn(DateTime(2026, 4, 29)), isFalse);
      expect(m.occursOn(DateTime(2026, 5, 31)), isTrue);
      expect(m.occursOn(DateTime(2028, 2, 29)), isTrue, reason: 'leap February');
      expect(m.occursOn(DateTime(2028, 2, 28)), isFalse);
    });

    test('Monthly on the 15th', () {
      final m = mark(DateTime(2026, 9, 15), repeat: RepeatRule.monthly);
      expect(m.occursOn(DateTime(2026, 10, 15)), isTrue);
      expect(m.occursOn(DateTime(2026, 10, 14)), isFalse);
      expect(m.occursOn(DateTime(2027, 1, 15)), isTrue);
    });

    test('Quarterly: every 3 months', () {
      final m = mark(DateTime(2026, 1, 15), repeat: RepeatRule.quarterly);
      for (final d in [
        DateTime(2026, 4, 15),
        DateTime(2026, 7, 15),
        DateTime(2026, 10, 15),
        DateTime(2027, 1, 15),
      ]) {
        expect(m.occursOn(d), isTrue, reason: '$d');
      }
      expect(m.occursOn(DateTime(2026, 2, 15)), isFalse);
      expect(m.occursOn(DateTime(2026, 3, 15)), isFalse);
      expect(m.occursOn(DateTime(2026, 5, 15)), isFalse);
    });

    test('Quarterly from the 31st clamps in shorter target months', () {
      final m = mark(DateTime(2026, 1, 31), repeat: RepeatRule.quarterly);
      expect(m.occursOn(DateTime(2026, 4, 30)), isTrue);
      expect(m.occursOn(DateTime(2026, 7, 31)), isTrue);
      expect(m.occursOn(DateTime(2026, 10, 31)), isTrue);
    });

    test('Half-yearly: every 6 months', () {
      final m = mark(DateTime(2026, 3, 10), repeat: RepeatRule.halfYearly);
      expect(m.occursOn(DateTime(2026, 9, 10)), isTrue);
      expect(m.occursOn(DateTime(2027, 3, 10)), isTrue);
      expect(m.occursOn(DateTime(2026, 6, 10)), isFalse);
      expect(m.occursOn(DateTime(2026, 12, 10)), isFalse);
    });

    test('Yearly: same date every year; Feb 29 falls on Feb 28 in common years',
        () {
      final m = mark(DateTime(2026, 9, 21), repeat: RepeatRule.yearly);
      expect(m.occursOn(DateTime(2027, 9, 21)), isTrue);
      expect(m.occursOn(DateTime(2030, 9, 21)), isTrue);
      expect(m.occursOn(DateTime(2027, 9, 22)), isFalse);
      expect(m.occursOn(DateTime(2027, 3, 21)), isFalse);

      final leap = mark(DateTime(2028, 2, 29), repeat: RepeatRule.yearly);
      expect(leap.occursOn(DateTime(2029, 2, 28)), isTrue);
      expect(leap.occursOn(DateTime(2032, 2, 29)), isTrue);
      expect(leap.occursOn(DateTime(2032, 2, 28)), isFalse);
    });
  });

  group('nextOccurrences', () {
    List<String> keys(List<DateTime> l) => [for (final d in l) dateKey(d)];

    test('Once: its date if it is not past, else nothing', () {
      final m = mark(DateTime(2026, 9, 21));
      expect(keys(m.nextOccurrences(DateTime(2026, 9, 1), 5)), ['2026-09-21']);
      expect(keys(m.nextOccurrences(DateTime(2026, 9, 21), 5)), ['2026-09-21']);
      expect(m.nextOccurrences(DateTime(2026, 9, 22), 5), isEmpty);
      expect(m.nextOccurrences(DateTime(2026, 9, 1), 0), isEmpty);
    });

    test('Daily: consecutive days, starting at the first date if in the future',
        () {
      final m = mark(DateTime(2026, 9, 21), repeat: RepeatRule.daily);
      expect(keys(m.nextOccurrences(DateTime(2026, 9, 1), 3)),
          ['2026-09-21', '2026-09-22', '2026-09-23']);
      expect(keys(m.nextOccurrences(DateTime(2026, 9, 30), 2)),
          ['2026-09-30', '2026-10-01']);
      expect(keys(m.nextOccurrences(DateTime(2026, 12, 30), 3)),
          ['2026-12-30', '2026-12-31', '2027-01-01']);
    });

    test('Weekly: the same weekday', () {
      final m = mark(DateTime(2026, 9, 21), repeat: RepeatRule.weekly); // Monday
      expect(keys(m.nextOccurrences(DateTime(2026, 9, 22), 3)),
          ['2026-09-28', '2026-10-05', '2026-10-12']);
      expect(keys(m.nextOccurrences(DateTime(2026, 9, 28), 1)), ['2026-09-28']);
      expect(keys(m.nextOccurrences(DateTime(2026, 1, 1), 2)),
          ['2026-09-21', '2026-09-28']);
    });

    test('Monthly from the 31st', () {
      final m = mark(DateTime(2026, 1, 31), repeat: RepeatRule.monthly);
      expect(keys(m.nextOccurrences(DateTime(2026, 1, 1), 5)),
          ['2026-01-31', '2026-02-28', '2026-03-31', '2026-04-30', '2026-05-31']);
      expect(keys(m.nextOccurrences(DateTime(2026, 2, 1), 2)),
          ['2026-02-28', '2026-03-31']);
      expect(keys(m.nextOccurrences(DateTime(2026, 3, 1), 1)), ['2026-03-31']);
    });

    test('Quarterly, half-yearly, yearly', () {
      final q = mark(DateTime(2026, 11, 15), repeat: RepeatRule.quarterly);
      expect(keys(q.nextOccurrences(DateTime(2026, 11, 16), 3)),
          ['2027-02-15', '2027-05-15', '2027-08-15']);
      final h = mark(DateTime(2026, 3, 10), repeat: RepeatRule.halfYearly);
      expect(keys(h.nextOccurrences(DateTime(2026, 3, 11), 2)),
          ['2026-09-10', '2027-03-10']);
      final y = mark(DateTime(2026, 9, 21), repeat: RepeatRule.yearly);
      expect(keys(y.nextOccurrences(DateTime(2026, 9, 22), 2)),
          ['2027-09-21', '2028-09-21']);
      final leap = mark(DateTime(2028, 2, 29), repeat: RepeatRule.yearly);
      expect(keys(leap.nextOccurrences(DateTime(2028, 3, 1), 3)),
          ['2029-02-28', '2030-02-28', '2031-02-28']);
    });

    test('agrees with occursOn for every rule', () {
      for (final r in RepeatRule.values) {
        final m = mark(DateTime(2026, 1, 31), repeat: r);
        final next = m.nextOccurrences(DateTime(2026, 1, 1), 6);
        for (final d in next) {
          expect(m.occursOn(d), isTrue, reason: '${r.name} $d');
        }
        // ... and skips no date that occursOn says is one.
        final found = {for (final d in next) d};
        if (next.length > 1) {
          for (var t = next.first;
              !t.isAfter(next.last);
              t = DateTime(t.year, t.month, t.day + 1)) {
            expect(m.occursOn(t), found.contains(t),
                reason: '${r.name} on $t');
          }
        }
      }
    });

    test('a horizon stops an endless search', () {
      final m = mark(DateTime(2026, 1, 31), repeat: RepeatRule.yearly);
      final l = m.nextOccurrences(DateTime(2026, 1, 1), 100,
          horizon: const Duration(days: 800));
      expect(l.length, lessThan(5));
    });
  });

  group('reminders and titles', () {
    test('effective times follow the mode', () {
      expect(
          mark(DateTime(2026, 9, 21), times: [480, 600]).effectiveReminderTimes,
          isEmpty,
          reason: 'No time');
      expect(
          mark(DateTime(2026, 9, 21), mode: ReminderMode.once, times: [480, 600])
              .effectiveReminderTimes,
          [480],
          reason: 'One time uses just the first');
      expect(
          mark(DateTime(2026, 9, 21), mode: ReminderMode.several, times: [480, 600])
              .effectiveReminderTimes,
          [480, 600]);
      expect(mark(DateTime(2026, 9, 21), mode: ReminderMode.once).effectiveReminderTimes,
          [defaultReminderMinutes],
          reason: 'One time with none chosen falls back to 9:00');
      expect(mark(DateTime(2026, 9, 21), mode: ReminderMode.several).hasReminders,
          isFalse);
    });

    test('normalizeTimes sorts, dedupes and caps', () {
      expect(normalizeTimes([600, 480, 600, 1200]), [480, 600, 1200]);
      expect(normalizeTimes([for (var i = 0; i < 20; i++) i * 10]).length,
          maxReminderTimes);
    });

    test('title falls back to the type when there is no label', () {
      expect(mark(DateTime(2026, 9, 21)).title, 'Neutral day');
      expect(
          CalendarMark(
                  id: 'x',
                  date: DateTime(2026, 9, 21),
                  type: MarkType.cautious,
                  label: '  Ekadashi  ')
              .title,
          'Ekadashi');
      expect(CalendarMark(id: 'x', date: DateTime(2026, 9, 21), type: MarkType.good).title,
          'Good day');
    });

    test('all twelve emojis are offered', () {
      expect(markEmojis.length, 12);
      expect(markEmojis, containsAll(['🕉', '☬', '📿', '🪔', '🔔', '🌅', '⭐', '✦', '💰', '🤝', '🚫', '✅']));
    });
  });

  group('storage map', () {
    test('round-trips every field', () {
      final m = CalendarMark(
        id: 'abc',
        date: DateTime(2026, 9, 21),
        type: MarkType.cautious,
        emoji: '🪔',
        label: 'Amavasya',
        details: 'Fast until sunset.\nLight a lamp.',
        reminderMode: ReminderMode.several,
        reminderTimes: const [360, 1080],
        repeat: RepeatRule.monthly,
        homeMode: HomeMode.morning,
        homeMinutes: 450,
        createdAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      );
      final back = CalendarMark.fromMap(m.toMap())!;
      expect(back.id, 'abc');
      expect(back.date, DateTime(2026, 9, 21));
      expect(back.type, MarkType.cautious);
      expect(back.emoji, '🪔');
      expect(back.label, 'Amavasya');
      expect(back.details, 'Fast until sunset.\nLight a lamp.');
      expect(back.reminderMode, ReminderMode.several);
      expect(back.reminderTimes, [360, 1080]);
      expect(back.repeat, RepeatRule.monthly);
      expect(back.homeMode, HomeMode.morning);
      expect(back.homeMinutes, 450);
      expect(back.createdAt, m.createdAt);
    });

    test('a mark with no emoji keeps none', () {
      final back = CalendarMark.fromMap(
          CalendarMark(id: 'a', date: DateTime(2026, 1, 1)).toMap())!;
      expect(back.emoji, isNull);
    });

    test('a mark without a usable id or date is rejected, not invented', () {
      expect(CalendarMark.fromMap(null), isNull);
      expect(CalendarMark.fromMap('junk'), isNull);
      expect(CalendarMark.fromMap({'date': '2026-01-01'}), isNull);
      expect(CalendarMark.fromMap({'id': '', 'date': '2026-01-01'}), isNull);
      expect(CalendarMark.fromMap({'id': 'a'}), isNull);
      expect(CalendarMark.fromMap({'id': 'a', 'date': '2026-02-31'}), isNull);
    });

    test('bad fields fall back to defaults and never lose the mark', () {
      final m = CalendarMark.fromMap({
        'id': 'a',
        'date': '2026-09-21',
        'type': 'weird',
        'emoji': 5,
        'label': 3,
        'details': null,
        'reminderMode': 'nope',
        'reminderTimes': [600, 'x', -5, 2000, 480, 600, 1.5],
        'repeat': 'sometimes',
        'homeMode': 7,
        'homeMinutes': 99999,
        'createdAt': 'yesterday',
      })!;
      expect(m.type, MarkType.neutral);
      expect(m.emoji, isNull);
      expect(m.label, '');
      expect(m.details, '');
      expect(m.reminderMode, ReminderMode.none);
      expect(m.reminderTimes, [480, 600], reason: 'only valid, sorted, unique');
      expect(m.repeat, RepeatRule.once);
      expect(m.homeMode, HomeMode.none);
      expect(m.homeMinutes, defaultHomeMinutes);
      expect(m.createdAt, isNull);
    });

    test('copyWith changes only what it is given', () {
      final m = CalendarMark(
        id: 'a',
        date: DateTime(2026, 9, 21),
        emoji: '⭐',
        label: 'x',
        type: MarkType.good,
      );
      final c = m.copyWith(label: 'y', date: DateTime(2026, 10, 1, 13));
      expect(c.id, 'a');
      expect(c.label, 'y');
      expect(c.emoji, '⭐');
      expect(c.type, MarkType.good);
      expect(c.date, DateTime(2026, 10, 1), reason: 'date only');
      expect(m.copyWith(clearEmoji: true).emoji, isNull);
    });
  });
}
