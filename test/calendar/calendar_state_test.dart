import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/calendar/application/calendar_marks_provider.dart';
import 'package:advance_calendar/features/calendar/application/home_cards_provider.dart';
import 'package:advance_calendar/features/calendar/application/mark_style_provider.dart';
import 'package:advance_calendar/features/calendar/application/now_provider.dart';
import 'package:advance_calendar/features/calendar/data/calendar_mark.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'calendar_support.dart';

void main() {
  late FakeScheduler scheduler;

  setUp(() {
    AppStorage.useMemoryForTests();
    scheduler = FakeScheduler();
  });

  ProviderContainer make({DateTime? now}) {
    final c = ProviderContainer(
        overrides: calendarOverrides(scheduler: scheduler, now: now));
    addTearDown(c.dispose);
    return c;
  }

  CalendarMarksNotifier marks(ProviderContainer c) =>
      c.read(calendarMarksProvider.notifier);

  CalendarMark newMark(
    ProviderContainer c,
    DateTime date, {
    MarkType type = MarkType.good,
    String label = 'Puja',
    RepeatRule repeat = RepeatRule.once,
    HomeMode home = HomeMode.none,
    int homeMinutes = 7 * 60,
    ReminderMode reminder = ReminderMode.none,
    List<int> times = const [],
  }) =>
      CalendarMark(
        id: marks(c).newId(),
        date: date,
        type: type,
        label: label,
        repeat: repeat,
        homeMode: home,
        homeMinutes: homeMinutes,
        reminderMode: reminder,
        reminderTimes: times,
      );

  group('marks store (Hive)', () {
    test('starts empty', () {
      expect(make().read(calendarMarksProvider), isEmpty);
    });

    test('save persists to Hive and survives a relaunch', () async {
      final c = make();
      final saved = await marks(c).save(newMark(c, DateTime(2026, 9, 25),
          label: 'Ekadashi', type: MarkType.cautious));
      expect(c.read(calendarMarksProvider).single.label, 'Ekadashi');
      expect(AppStorage.calendarMarks.get(saved.id), isNotNull);

      final again = make();
      final m = again.read(calendarMarksProvider).single;
      expect(m.id, saved.id);
      expect(m.label, 'Ekadashi');
      expect(m.type, MarkType.cautious);
      expect(m.date, DateTime(2026, 9, 25));
    });

    test('editing replaces the mark, keeps its id and creation time', () async {
      final c = make();
      final first = await marks(c).save(newMark(c, DateTime(2026, 9, 25)));
      expect(first.createdAt, isNotNull);
      final edited = await marks(c).save(first.copyWith(label: 'Renamed'));
      expect(c.read(calendarMarksProvider).length, 1);
      expect(edited.id, first.id);
      expect(edited.label, 'Renamed');
      expect(edited.createdAt, first.createdAt);
      expect(make().read(calendarMarksProvider).single.label, 'Renamed');
    });

    test('the list is ordered by date, then by when it was made', () async {
      final c = make();
      await marks(c).save(newMark(c, DateTime(2026, 10, 3), label: 'later'));
      await marks(c).save(newMark(c, DateTime(2026, 9, 1), label: 'first'));
      await marks(c).save(newMark(c, DateTime(2026, 10, 3), label: 'later 2'));
      expect([for (final m in c.read(calendarMarksProvider)) m.label],
          ['first', 'later', 'later 2']);
    });

    test('delete removes it from state and Hive and cancels its reminders',
        () async {
      final c = make();
      final a = await marks(c).save(newMark(c, DateTime(2026, 9, 25), label: 'a'));
      final b = await marks(c).save(newMark(c, DateTime(2026, 9, 26), label: 'b'));
      await marks(c).delete(a.id);
      expect(c.read(calendarMarksProvider).single.id, b.id);
      expect(AppStorage.calendarMarks.get(a.id), isNull);
      expect(scheduler.cancelled, [a.id]);
      expect(make().read(calendarMarksProvider).single.id, b.id);
    });

    test('a damaged record is skipped, the rest still load', () async {
      final c = make();
      await marks(c).save(newMark(c, DateTime(2026, 9, 25), label: 'good one'));
      AppStorage.calendarMarks.put('bad', {'id': 'bad', 'date': 'nonsense'});
      AppStorage.calendarMarks.put('worse', 'garbage');
      expect([for (final m in make().read(calendarMarksProvider)) m.label],
          ['good one']);
    });

    test('byId', () async {
      final c = make();
      final a = await marks(c).save(newMark(c, DateTime(2026, 9, 25)));
      expect(marks(c).byId(a.id)?.id, a.id);
      expect(marks(c).byId('nope'), isNull);
    });

    test('new ids do not repeat', () {
      final c = make();
      final ids = {for (var i = 0; i < 200; i++) marks(c).newId()};
      expect(ids.length, greaterThan(190));
    });
  });

  group('marksOn: a date, with repeats, most severe first', () {
    test('includes the marks that start on it and repeats of earlier ones',
        () async {
      final c = make();
      await marks(c).save(newMark(c, DateTime(2026, 9, 21), label: 'once'));
      await marks(c).save(
          newMark(c, DateTime(2026, 9, 7), label: 'weekly', repeat: RepeatRule.weekly));
      await marks(c).save(
          newMark(c, DateTime(2026, 8, 21), label: 'monthly', repeat: RepeatRule.monthly));
      await marks(c).save(newMark(c, DateTime(2026, 9, 22), label: 'other day'));
      expect(
          {for (final m in marks(c).marksOn(DateTime(2026, 9, 21))) m.label},
          {'once', 'weekly', 'monthly'});
      expect(marks(c).marksOn(DateTime(2026, 9, 23)), isEmpty);
    });

    test('cautious first, then good, then neutral', () async {
      final c = make();
      final d = DateTime(2026, 9, 21);
      await marks(c).save(newMark(c, d, label: 'n', type: MarkType.neutral));
      await marks(c).save(newMark(c, d, label: 'g', type: MarkType.good));
      await marks(c).save(newMark(c, d, label: 'c', type: MarkType.cautious));
      expect([for (final m in marks(c).marksOn(d)) m.label], ['c', 'g', 'n']);
    });
  });

  group('reminders follow the marks', () {
    test('saving schedules the mark; starting the app refreshes everything',
        () async {
      final c = make();
      c.read(calendarMarksProvider);
      await pumpEventQueue();
      expect(scheduler.rescheduledAll.length, 1, reason: 'once, on start');
      final saved = await marks(c).save(newMark(c, DateTime(2026, 9, 25),
          reminder: ReminderMode.once, times: const [540]));
      expect(scheduler.scheduled.single.id, saved.id);
      expect(scheduler.scheduled.single.effectiveReminderTimes, [540]);
    });

    test('a saved mark is handed to the scheduler on the next start', () async {
      final c = make();
      await marks(c).save(newMark(c, DateTime(2026, 9, 25), label: 'kept'));
      final again = make();
      again.read(calendarMarksProvider);
      await pumpEventQueue();
      expect([for (final m in scheduler.rescheduledAll.last) m.label], ['kept']);
    });

    test('a scheduler that fails never loses the mark', () async {
      scheduler.throwOnSchedule = true;
      final c = make();
      final saved = await marks(c).save(newMark(c, DateTime(2026, 9, 25),
          reminder: ReminderMode.once, times: const [540]));
      expect(c.read(calendarMarksProvider).single.id, saved.id);
      expect(AppStorage.calendarMarks.get(saved.id), isNotNull);
    });
  });

  group('mark display style (persisted)', () {
    test('defaults to Dot, all five exist', () {
      expect(make().read(markStyleProvider), MarkStyle.dot);
      expect([for (final s in MarkStyle.values) s.label],
          ['Dot', 'Filled', 'Highlight', 'Circle', 'Square']);
    });

    test('the choice is saved and restored', () {
      final c = make();
      c.read(markStyleProvider.notifier).set(MarkStyle.highlight);
      expect(AppStorage.settings.get('calendar.markStyle'), 'highlight');
      expect(make().read(markStyleProvider), MarkStyle.highlight);
    });

    test('an unknown saved value falls back to Dot', () {
      AppStorage.settings.put('calendar.markStyle', 'sparkles');
      expect(make().read(markStyleProvider), MarkStyle.dot);
    });
  });

  group('Home cards', () {
    // Monday 21 Sep 2026.
    DateTime at(int h, [int m = 0]) => DateTime(2026, 9, 21, h, m);

    Future<ProviderContainer> withMarks(
        DateTime now, List<CalendarMark Function(ProviderContainer)> build) async {
      final c = make(now: now);
      for (final b in build) {
        await marks(c).save(b(c));
      }
      return c;
    }

    List<String> labels(ProviderContainer c) =>
        [for (final h in c.read(homeCardsProvider)) h.mark.label];

    test('"Don\'t show" never appears', () async {
      final c = await withMarks(at(12), [
        (c) => newMark(c, DateTime(2026, 9, 21), label: 'hidden'),
      ]);
      expect(labels(c), isEmpty);
    });

    test('a mark on another date does not appear today', () async {
      final c = await withMarks(at(12), [
        (c) => newMark(c, DateTime(2026, 9, 22), label: 'tomorrow', home: HomeMode.allDay),
        (c) => newMark(c, DateTime(2026, 9, 20), label: 'yesterday', home: HomeMode.allDay),
      ]);
      expect(labels(c), isEmpty);
    });

    test('Keep all day: shown all day, pinned', () async {
      final c = await withMarks(at(0, 1), [
        (c) => newMark(c, DateTime(2026, 9, 21), label: 'pinned', home: HomeMode.allDay),
      ]);
      expect(labels(c), ['pinned']);
      expect(c.read(homeCardsProvider).single.pinned, isTrue);
      (c.read(nowProvider.notifier) as FakeNow).set(DateTime(2026, 9, 21, 23, 59));
      expect(labels(c), ['pinned']);
    });

    test('Once in the morning: appears at its time, not before', () async {
      final c = await withMarks(at(6, 29), [
        (c) => newMark(c, DateTime(2026, 9, 21),
            label: 'morning', home: HomeMode.morning, homeMinutes: 6 * 60 + 30),
      ]);
      expect(labels(c), isEmpty, reason: '6:29 is before 6:30');
      final now = c.read(nowProvider.notifier) as FakeNow;
      now.set(at(6, 30));
      expect(labels(c), ['morning'], reason: 'exactly its time');
      now.set(at(15));
      expect(labels(c), ['morning'], reason: 'and it stays until swiped');
      expect(c.read(homeCardsProvider).single.pinned, isFalse);
    });

    test('swiping a morning card dismisses it for the day only', () async {
      final c = await withMarks(at(9), [
        (c) => newMark(c, DateTime(2026, 9, 21),
            label: 'daily', home: HomeMode.morning, repeat: RepeatRule.daily),
      ]);
      expect(labels(c), ['daily']);
      c.read(homeDismissalsProvider.notifier).dismiss(
          c.read(homeCardsProvider).single.mark.id, DateTime(2026, 9, 21));
      expect(labels(c), isEmpty);

      final now = c.read(nowProvider.notifier) as FakeNow;
      now.set(DateTime(2026, 9, 21, 23, 0));
      expect(labels(c), isEmpty, reason: 'still gone later the same day');
      now.set(DateTime(2026, 9, 22, 9, 0));
      expect(labels(c), ['daily'], reason: 'back tomorrow');
    });

    test('undo brings a dismissed card back', () async {
      final c = await withMarks(at(9), [
        (c) => newMark(c, DateTime(2026, 9, 21), label: 'm', home: HomeMode.morning),
      ]);
      final id = c.read(homeCardsProvider).single.mark.id;
      final d = c.read(homeDismissalsProvider.notifier);
      d.dismiss(id, DateTime(2026, 9, 21));
      expect(labels(c), isEmpty);
      d.restore(id, DateTime(2026, 9, 21));
      expect(labels(c), ['m']);
    });

    test('a dismissal is saved and survives a relaunch', () async {
      final c = await withMarks(at(9), [
        (c) => newMark(c, DateTime(2026, 9, 21), label: 'm', home: HomeMode.morning),
      ]);
      final id = c.read(homeCardsProvider).single.mark.id;
      c.read(homeDismissalsProvider.notifier).dismiss(id, DateTime(2026, 9, 21));
      final again = make(now: at(9));
      expect(again.read(homeCardsProvider), isEmpty);
    });

    test('dismissing one mark does not hide another', () async {
      final c = await withMarks(at(9), [
        (c) => newMark(c, DateTime(2026, 9, 21), label: 'a', home: HomeMode.morning),
        (c) => newMark(c, DateTime(2026, 9, 21), label: 'b', home: HomeMode.morning),
      ]);
      final first = c.read(homeCardsProvider).first.mark;
      c.read(homeDismissalsProvider.notifier).dismiss(first.id, DateTime(2026, 9, 21));
      expect(labels(c).length, 1);
      expect(labels(c).single, isNot(first.label));
    });

    test('pinned cards cannot be dismissed away by the provider either', () async {
      final c = await withMarks(at(9), [
        (c) => newMark(c, DateTime(2026, 9, 21), label: 'pin', home: HomeMode.allDay),
      ]);
      final id = c.read(homeCardsProvider).single.mark.id;
      c.read(homeDismissalsProvider.notifier).dismiss(id, DateTime(2026, 9, 21));
      expect(labels(c), ['pin'], reason: 'a stray dismissal cannot hide a pinned card');
    });

    test('repeats show on the right days', () async {
      final c = await withMarks(at(9), [
        (c) => newMark(c, DateTime(2026, 9, 7),
            label: 'weekly', home: HomeMode.allDay, repeat: RepeatRule.weekly),
      ]);
      expect(labels(c), ['weekly'], reason: 'Monday 21 is two weeks on');
      final now = c.read(nowProvider.notifier) as FakeNow;
      now.set(DateTime(2026, 9, 22, 9));
      expect(labels(c), isEmpty, reason: 'Tuesday');
      now.set(DateTime(2026, 9, 28, 9));
      expect(labels(c), ['weekly']);
    });

    test('pinned first, then by morning time', () async {
      final c = await withMarks(at(12), [
        (c) => newMark(c, DateTime(2026, 9, 21), label: 'late', home: HomeMode.morning, homeMinutes: 9 * 60),
        (c) => newMark(c, DateTime(2026, 9, 21), label: 'early', home: HomeMode.morning, homeMinutes: 6 * 60),
        (c) => newMark(c, DateTime(2026, 9, 21), label: 'pin', home: HomeMode.allDay),
      ]);
      expect(labels(c), ['pin', 'early', 'late']);
    });

    test('editing a mark to "Don\'t show" removes its card', () async {
      final c = await withMarks(at(12), [
        (c) => newMark(c, DateTime(2026, 9, 21), label: 'm', home: HomeMode.allDay),
      ]);
      final m = c.read(homeCardsProvider).single.mark;
      await marks(c).save(m.copyWith(homeMode: HomeMode.none));
      expect(labels(c), isEmpty);
    });

    test('old dismissals are dropped on load', () {
      AppStorage.settings.put('calendar.homeDismissed',
          ['a|2026-01-01', 'b|2026-09-21', 'c|not-a-date', 42, 'd|2099-01-01']);
      final c = make(now: at(9));
      final kept = c.read(homeDismissalsProvider);
      expect(kept.contains('a|2026-01-01'), isFalse);
      expect(kept.contains('c|not-a-date'), isFalse);
      expect(kept.contains('d|2099-01-01'), isTrue);
    });
  });
}
