import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/calendar/application/now_provider.dart';
import 'package:advance_calendar/features/home/application/plans_provider.dart';
import 'package:advance_calendar/features/home/data/plan.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile/profile_support.dart';

void main() {
  final d = DateTime(2026, 9, 22);
  String k(int daysAgo) {
    final t = DateTime(2026, 9, 22 - daysAgo);
    return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
  }

  group('the plan', () {
    Plan plan({int days = 10, Set<String> done = const {}}) => Plan(
        id: 'p', title: 'Japji', kind: PlanKind.paath, totalDays: days, startDate: d, doneDays: done);

    test('progress is days done out of the target', () {
      expect(plan().progress, 0);
      expect(plan(done: {k(0), k(1), k(2)}).progress, closeTo(0.3, 1e-9));
      expect(plan(done: {k(0), k(1), k(2)}).completed, 3);
      expect(plan(days: 3, done: {k(0), k(1), k(2)}).progress, 1);
    });

    test('active until every day is done, then complete', () {
      expect(plan(days: 2, done: {k(0)}).isActive, isTrue);
      final done = plan(days: 2, done: {k(0), k(1)});
      expect((done.isComplete, done.isActive), (true, false));
    });

    test('never shows more than 100% even with extra days recorded', () {
      final p = plan(days: 2, done: {k(0), k(1), k(2), k(3)});
      expect(p.completed, 2);
      expect(p.progress, 1);
    });

    test('doneOn looks at the calendar day', () {
      final p = plan(done: {k(0)});
      expect(p.doneOn(DateTime(2026, 9, 22, 23, 59)), isTrue);
      expect(p.doneOn(DateTime(2026, 9, 21)), isFalse);
    });

    test('round-trips through storage', () {
      final p = plan(done: {k(1), k(0)});
      final back = Plan.fromMap(p.toMap())!;
      expect((back.id, back.title, back.kind, back.totalDays), ('p', 'Japji', PlanKind.paath, 10));
      expect(back.doneDays, p.doneDays);
      expect(back.startDate, d);
    });

    test('damaged plans are skipped, not fatal', () {
      for (final junk in [
        null,
        'x',
        <String, dynamic>{},
        {'id': '', 'title': 'A', 'days': 5, 'start': '2026-09-22'},
        {'id': 'a', 'title': '  ', 'days': 5, 'start': '2026-09-22'},
        {'id': 'a', 'title': 'A', 'days': 0, 'start': '2026-09-22'},
        {'id': 'a', 'title': 'A', 'days': 9999, 'start': '2026-09-22'},
        {'id': 'a', 'title': 'A', 'days': 'ten', 'start': '2026-09-22'},
        {'id': 'a', 'title': 'A', 'days': 5, 'start': 'yesterday'},
        {'id': 'a', 'title': 'A', 'days': 5},
      ]) {
        expect(Plan.fromMap(junk), isNull, reason: '$junk');
      }
      // A plan with junk inside the list of days keeps only the good days.
      final p = Plan.fromMap({
        'id': 'a', 'title': 'A', 'days': 5, 'start': '2026-09-22', 'kind': 'weird',
        'done': ['2026-09-22', 5, 'nope'],
      })!;
      expect(p.doneDays, {'2026-09-22'});
      expect(p.kind, PlanKind.mantra, reason: 'an unknown kind becomes a mantra');
    });

    test('the suggestions are usable plans', () {
      expect(planSuggestions.length, greaterThanOrEqualTo(4));
      for (final s in planSuggestions) {
        expect(s.title, isNotEmpty);
        expect(s.days, inInclusiveRange(minPlanDays, maxPlanDays));
      }
      expect(planDayChoices, containsAll([7, 21, 40]));
    });
  });

  group('the daily streak', () {
    test('no days done: no streak', () => expect(currentStreak({}, d), 0));

    test('today only: 1', () => expect(currentStreak({k(0)}, d), 1));

    test('a run ending today counts every day of it', () {
      expect(currentStreak({k(0), k(1), k(2), k(3)}, d), 4);
    });

    test('still alive when today is not done yet (it ends yesterday)', () {
      expect(currentStreak({k(1), k(2), k(3)}, d), 3);
    });

    test('broken by a missed day', () {
      expect(currentStreak({k(0), k(1), k(3), k(4)}, d), 2);
      expect(currentStreak({k(2), k(3)}, d), 0, reason: 'a missed yesterday and today');
    });

    test('crosses months and years', () {
      final ny = DateTime(2027, 1, 2);
      expect(currentStreak({'2027-01-02', '2027-01-01', '2026-12-31', '2026-12-30'}, ny), 4);
    });

    test('an old long run does not count if it has been broken since', () {
      expect(currentStreak({for (var i = 5; i < 30; i++) k(i)}, d), 0);
    });

    test('the time of day does not matter', () {
      expect(currentStreak({k(0)}, DateTime(2026, 9, 22, 23, 59, 59)), 1);
    });
  });

  group('the plans list', () {
    late ProfileRig rig;
    setUp(() => rig = profileRig(now: DateTime(2026, 9, 22, 9, 0)));

    PlansNotifier n() => rig.container.read(plansProvider.notifier);
    List<Plan> plans() => rig.container.read(plansProvider);
    void newDay([int by = 1]) {
      final next = rig.clock.now.add(Duration(days: by));
      rig.clock.now = next;
      (rig.container.read(nowProvider.notifier) as FakeNow).set(next);
    }

    test('starts empty', () {
      expect(plans(), isEmpty);
      expect(rig.container.read(streakProvider), 0);
      expect(rig.container.read(activePlanCountProvider), 0);
    });

    test('adding a plan starts it today', () {
      final p = n().add(title: '  Hanuman Chalisa ', kind: PlanKind.paath, days: 40)!;
      expect(p.title, 'Hanuman Chalisa');
      expect(p.totalDays, 40);
      expect(p.startDate, DateTime(2026, 9, 22));
      expect(p.completed, 0);
      expect(plans(), [p]);
    });

    test('a plan needs a name and 1 to 365 days', () {
      expect(n().add(title: '', kind: PlanKind.mantra, days: 7), isNull);
      expect(n().add(title: '   ', kind: PlanKind.mantra, days: 7), isNull);
      expect(n().add(title: 'A', kind: PlanKind.mantra, days: 0), isNull);
      expect(n().add(title: 'A', kind: PlanKind.mantra, days: 366), isNull);
      expect(n().add(title: 'A', kind: PlanKind.mantra, days: -3), isNull);
      expect(plans(), isEmpty);
      expect(n().add(title: 'A', kind: PlanKind.mantra, days: 1), isNotNull);
      expect(n().add(title: 'B', kind: PlanKind.mantra, days: 365), isNotNull);
    });

    test('a very long name is cut to 60 characters', () {
      expect(n().add(title: 'x' * 100, kind: PlanKind.mantra, days: 3)!.title.length, 60);
    });

    test('several plans, each with its own id', () {
      final a = n().add(title: 'A', kind: PlanKind.mantra, days: 7)!;
      final b = n().add(title: 'A', kind: PlanKind.mantra, days: 7)!;
      expect(a.id, isNot(b.id), reason: 'the same name twice is fine');
      expect(plans().length, 2);
    });

    test('marking today done raises the count, and undoing takes it back', () {
      final p = n().add(title: 'Japji', kind: PlanKind.paath, days: 5)!;
      n().toggleToday(p.id);
      expect(plans().single.completed, 1);
      expect(plans().single.doneOn(DateTime(2026, 9, 22)), isTrue);
      n().toggleToday(p.id);
      expect(plans().single.completed, 0);
    });

    test('a day can only be counted once', () {
      final p = n().add(title: 'Japji', kind: PlanKind.paath, days: 5)!;
      n().toggleToday(p.id);
      n().toggleToday(p.id);
      n().toggleToday(p.id);
      expect(plans().single.completed, 1);
    });

    test('progress builds up day by day', () {
      final p = n().add(title: 'Japji', kind: PlanKind.paath, days: 4)!;
      for (var i = 1; i <= 4; i++) {
        n().toggleToday(p.id);
        expect(plans().single.completed, i);
        expect(plans().single.progress, i / 4);
        newDay();
      }
      expect(plans().single.isComplete, isTrue);
    });

    test('a finished plan takes no more days, but today can still be undone', () {
      final p = n().add(title: 'Japji', kind: PlanKind.paath, days: 2)!;
      n().toggleToday(p.id);
      newDay();
      n().toggleToday(p.id);
      expect(plans().single.isComplete, isTrue);
      newDay();
      n().toggleToday(p.id); // a third day: ignored
      expect(plans().single.completed, 2);
      expect(plans().single.doneDays.length, 2);
      newDay(-1);
      n().toggleToday(p.id); // undo the day it finished
      expect(plans().single.isComplete, isFalse);
    });

    test('marking one plan leaves the others alone', () {
      final a = n().add(title: 'A', kind: PlanKind.paath, days: 5)!;
      n().add(title: 'B', kind: PlanKind.mantra, days: 5);
      n().toggleToday(a.id);
      expect([for (final p in plans()) p.completed], [1, 0]);
    });

    test('ids stay unique even after deleting and adding at the same instant', () {
      final a = n().add(title: 'A', kind: PlanKind.paath, days: 5)!;
      final b = n().add(title: 'B', kind: PlanKind.paath, days: 5)!;
      n().remove(a.id);
      final c = n().add(title: 'C', kind: PlanKind.paath, days: 5)!;
      expect({b.id, c.id}.length, 2);
      n().toggleToday(c.id);
      expect([for (final p in plans()) p.completed], [0, 1], reason: 'only C is marked');
    });

    test('unknown ids do nothing', () {
      n().add(title: 'A', kind: PlanKind.paath, days: 5);
      n().toggleToday('nope');
      n().remove('nope');
      expect(plans().single.completed, 0);
    });

    test('deleting removes only that plan', () {
      final a = n().add(title: 'A', kind: PlanKind.paath, days: 5)!;
      final b = n().add(title: 'B', kind: PlanKind.mantra, days: 5)!;
      n().remove(a.id);
      expect(plans(), [b]);
    });

    test('active count and streak follow the plans', () {
      final a = n().add(title: 'A', kind: PlanKind.paath, days: 1)!;
      n().add(title: 'B', kind: PlanKind.mantra, days: 9);
      expect(rig.container.read(activePlanCountProvider), 2);
      n().toggleToday(a.id); // A is finished
      expect(rig.container.read(activePlanCountProvider), 1);
      expect(rig.container.read(streakProvider), 1);
    });

    test('the streak counts a day when ANY plan was done, across plans', () {
      final a = n().add(title: 'A', kind: PlanKind.paath, days: 30)!;
      final b = n().add(title: 'B', kind: PlanKind.mantra, days: 30)!;
      n().toggleToday(a.id);
      newDay();
      n().toggleToday(b.id);
      newDay();
      n().toggleToday(a.id);
      n().toggleToday(b.id);
      expect(rig.container.read(streakProvider), 3);
    });

    test('a missed day resets the streak; a fresh start begins at 1', () {
      final a = n().add(title: 'A', kind: PlanKind.paath, days: 30)!;
      n().toggleToday(a.id);
      newDay();
      n().toggleToday(a.id);
      expect(rig.container.read(streakProvider), 2);
      newDay(2); // a day in between is missed
      expect(rig.container.read(streakProvider), 0);
      n().toggleToday(a.id);
      expect(rig.container.read(streakProvider), 1);
    });

    test('a streak is still alive on the morning after, until that day ends', () {
      final a = n().add(title: 'A', kind: PlanKind.paath, days: 30)!;
      n().toggleToday(a.id);
      newDay();
      expect(rig.container.read(streakProvider), 1, reason: 'not done today yet');
    });

    test('everything is saved and comes back after a restart', () {
      final a = n().add(title: 'Japji', kind: PlanKind.paath, days: 40)!;
      n().add(title: 'Gayatri', kind: PlanKind.mantra, days: 21);
      n().toggleToday(a.id);
      final saved = AppStorage.settings.get('home.plans');
      final again = profileRig(now: DateTime(2026, 9, 22, 9), saved: {'home.plans': saved});
      final back = again.container.read(plansProvider);
      expect([for (final p in back) p.title], ['Japji', 'Gayatri']);
      expect(back.first.completed, 1);
      expect(again.container.read(streakProvider), 1);
    });

    test('damaged saved plans are skipped and the rest kept', () {
      final good = Plan(id: 'g', title: 'Good', kind: PlanKind.paath, totalDays: 5, startDate: d);
      final again = profileRig(saved: {
        'home.plans': [good.toMap(), 'junk', {'id': 'x'}, null],
      });
      expect(again.container.read(plansProvider).map((p) => p.title), ['Good']);
      final notAList = profileRig(saved: {'home.plans': 'nope'});
      expect(notAList.container.read(plansProvider), isEmpty);
    });
  });
}
