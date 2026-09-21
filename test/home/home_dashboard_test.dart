import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/calendar/application/calendar_marks_provider.dart';
import 'package:advance_calendar/features/calendar/application/now_provider.dart';
import 'package:advance_calendar/features/calendar/data/calendar_mark.dart';
import 'package:advance_calendar/features/home/application/plans_provider.dart';
import 'package:advance_calendar/features/home/data/plan.dart';
import 'package:advance_calendar/features/home/data/tradition.dart';
import 'package:advance_calendar/features/home/presentation/home_screen.dart';
import 'package:advance_calendar/features/profile/application/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile/profile_support.dart';

void main() {
  Finder key(String k) => find.byKey(ValueKey(k));
  String text(WidgetTester t, String k) => t.widget<Text>(key(k)).data!;

  Future<ProfileRig> open(
    WidgetTester tester, {
    ProfileRig? rig,
    double width = 411,
    double height = 3000,
    Brightness brightness = Brightness.light,
  }) async {
    final r = rig ?? profileRig();
    await pumpProfile(tester, r, const HomeScreen(),
        width: width, height: height, brightness: brightness);
    return r;
  }

  void setNow(ProfileRig rig, DateTime t) {
    rig.clock.now = t;
    (rig.container.read(nowProvider.notifier) as FakeNow).set(t);
  }

  group('greeting and today line', () {
    testWidgets('a greeting for the time of day, and the date', (tester) async {
      await open(tester);
      expect(text(tester, 'home-greeting'), 'Good morning');
      expect(text(tester, 'home-date'), 'Monday, September 21, 2026');
    });

    testWidgets('uses your first name once you have set one', (tester) async {
      final rig = await open(tester);
      rig.container.read(profileProvider.notifier).save(name: 'Asha Kaur', email: '');
      await tester.pump();
      expect(text(tester, 'home-greeting'), 'Good morning, Asha');
    });

    testWidgets('changes with the time and rolls the date at midnight', (tester) async {
      final rig = await open(tester);
      setNow(rig, DateTime(2026, 9, 21, 14, 30));
      await tester.pump();
      expect(text(tester, 'home-greeting'), 'Good afternoon');
      setNow(rig, DateTime(2026, 9, 21, 19, 0));
      await tester.pump();
      expect(text(tester, 'home-greeting'), 'Good evening');
      setNow(rig, DateTime(2026, 9, 22, 0, 5));
      await tester.pump();
      expect(text(tester, 'home-greeting'), 'Good night');
      expect(text(tester, 'home-date'), 'Tuesday, September 22, 2026');
    });

    testWidgets('greeting first, then Today, then calendar cards, then plans',
        (tester) async {
      await open(tester);
      double y(String k) => tester.getTopLeft(key(k)).dy;
      expect(y('home-greeting'), lessThan(y('today-card')));
      expect(y('today-card'), lessThan(y('home-empty')));
      expect(y('home-empty'), lessThan(y('plan-add')));
    });

    testWidgets('"Today" appears once, as the card\'s title', (tester) async {
      await open(tester);
      expect(find.text('Today'), findsOneWidget);
    });
  });

  group('the tradition switch', () {
    Finder detail(String k) => key('detail-$k');

    testWidgets('Hindu, Sikh and By place, with Hindu showing first', (tester) async {
      await open(tester);
      final sb = tester.widget<SegmentedButton<Tradition>>(key('tradition-switch'));
      expect([for (final s in sb.segments) s.value], Tradition.values);
      expect(sb.selected, {Tradition.hindu});
      for (final l in ['Hindu', 'Sikh', 'By place']) {
        expect(find.descendant(of: key('tradition-switch'), matching: find.text(l)),
            findsOneWidget, reason: l);
      }
    });

    testWidgets('Hindu shows tithi, nakshatra, Rahu Kaal and Abhijit muhurat',
        (tester) async {
      await open(tester);
      for (final k in ['tithi', 'nakshatra', 'rahu', 'abhijit']) {
        expect(detail(k), findsOneWidget, reason: k);
      }
      expect(detail('hukamnama'), findsNothing);
      expect(detail('festival'), findsNothing);
      expect(text(tester, 'value-rahu'), ExampleValues.rahuKaal);
    });

    testWidgets('Sikh replaces them with Hukamnama, Nitnem, sunrise and Gurpurab',
        (tester) async {
      await open(tester);
      await tester.tap(find.descendant(of: key('tradition-switch'), matching: find.text('Sikh')));
      await tester.pump();
      for (final k in ['hukamnama', 'nitnem', 'sunrise', 'gurpurab']) {
        expect(detail(k), findsOneWidget, reason: k);
      }
      expect(detail('tithi'), findsNothing);
      expect(detail('sunset'), findsNothing);
      expect(text(tester, 'value-hukamnama'), ExampleValues.hukamnama);
    });

    testWidgets('By place shows sunrise, sunset, local festival, auspicious window',
        (tester) async {
      await open(tester);
      await tester.tap(find.descendant(of: key('tradition-switch'), matching: find.text('By place')));
      await tester.pump();
      for (final k in ['sunrise', 'sunset', 'festival', 'window']) {
        expect(detail(k), findsOneWidget, reason: k);
      }
      expect(detail('nitnem'), findsNothing);
    });

    testWidgets('the choice is saved and is still there after a restart',
        (tester) async {
      final rig = await open(tester);
      await tester.tap(find.descendant(of: key('tradition-switch'), matching: find.text('Sikh')));
      await tester.pump();
      expect(AppStorage.settings.get('home.tradition'), 'sikh');

      await tester.pumpWidget(const SizedBox());
      final again = profileRig(saved: {'home.tradition': 'sikh'});
      await open(tester, rig: again);
      expect(detail('hukamnama'), findsOneWidget);
      expect(rig, isNotNull);
    });

    testWidgets('example values are marked EXAMPLE; the real sunrise is not',
        (tester) async {
      await open(tester);
      expect(key('example-tithi'), findsOneWidget);
      expect(find.text('EXAMPLE'), findsNWidgets(4));
      expect(key('example-note'), findsOneWidget);
      await tester.tap(find.descendant(of: key('tradition-switch'), matching: find.text('By place')));
      await tester.pump();
      expect(key('example-sunrise'), findsNothing);
      expect(key('example-sunset'), findsNothing);
      expect(key('example-festival'), findsOneWidget);
      expect(find.text('EXAMPLE'), findsNWidgets(2));
      expect(key('live-note'), findsOneWidget);
      expect(text(tester, 'live-note'), contains('Using Amritsar'));
    });

    testWidgets('Hindu has no real values, so no "worked out for your place" note',
        (tester) async {
      await open(tester);
      expect(key('live-note'), findsNothing);
    });

    testWidgets('sunrise here is the real one for the day', (tester) async {
      await open(tester);
      await tester.tap(find.descendant(of: key('tradition-switch'), matching: find.text('By place')));
      await tester.pump();
      expect(text(tester, 'value-sunrise'), matches(RegExp(r'^\d{1,2}:\d{2}\s?[AP]M$')));
      expect(text(tester, 'value-sunset'), matches(RegExp(r'^\d{1,2}:\d{2}\s?[AP]M$')));
    });
  });

  group('calendar days flagged for home', () {
    testWidgets('appear as cards on the dashboard, and can be swiped away',
        (tester) async {
      final rig = profileRig();
      await rig.container.read(calendarMarksProvider.notifier).save(markOn(
          DateTime(2026, 9, 21),
          id: 'a', label: 'Sunrise prayer', emoji: '🪔',
          home: HomeMode.morning, homeMinutes: 6 * 60));
      await open(tester, rig: rig);
      expect(find.text('Sunrise prayer'), findsOneWidget);
      expect(key('home-empty'), findsNothing);
      await tester.fling(key('home-card-a'), const Offset(-600, 0), 2000);
      await tester.pumpAndSettle();
      expect(find.text('Sunrise prayer'), findsNothing);
      expect(key('home-empty'), findsOneWidget);
    });

    testWidgets('a pinned card cannot be swiped away', (tester) async {
      final rig = profileRig();
      await rig.container.read(calendarMarksProvider.notifier).save(markOn(
          DateTime(2026, 9, 21),
          id: 'p', label: 'Ekadashi fast', home: HomeMode.allDay));
      await open(tester, rig: rig);
      await tester.fling(key('home-card-p'), const Offset(-600, 0), 2000);
      await tester.pumpAndSettle();
      expect(find.text('Ekadashi fast'), findsOneWidget);
    });
  });

  group('plans', () {
    testWidgets('start with the streak, the active count and suggestions',
        (tester) async {
      await open(tester);
      expect(text(tester, 'stat-streak'), '0');
      expect(text(tester, 'stat-active'), '0');
      expect(find.text('day streak'), findsOneWidget);
      expect(find.text('active plans'), findsOneWidget);
      expect(key('plans-empty'), findsOneWidget);
      expect(key('plan-add'), findsOneWidget);
      for (var i = 0; i < planSuggestions.length; i++) {
        expect(key('start-$i'), findsOneWidget);
      }
    });

    testWidgets('a suggestion starts a plan at once', (tester) async {
      final rig = await open(tester);
      await tester.tap(key('start-0'));
      await tester.pump();
      final p = rig.container.read(plansProvider).single;
      expect((p.title, p.totalDays, p.kind), ('Hanuman Chalisa', 40, PlanKind.paath));
      expect(key('plans-empty'), findsNothing);
      expect(text(tester, 'plan-title-${p.id}'), 'Hanuman Chalisa');
      expect(text(tester, 'plan-progress-${p.id}'), '0 of 40 days');
      expect(text(tester, 'stat-active'), '1');
      expect(find.text('Paath · 40 days'), findsOneWidget);
    });

    testWidgets('a custom plan: name, kind and number of days', (tester) async {
      final rig = await open(tester);
      await tester.tap(key('plan-add'));
      await tester.pumpAndSettle();
      await tester.enterText(key('plan-title'), 'Mool Mantar');
      await tester.tap(find.descendant(of: key('plan-kind'), matching: find.text('Mantra')));
      await tester.pump();
      await tester.enterText(key('plan-days'), '30');
      await tester.pump();
      await tester.tap(key('plan-save'));
      await tester.pumpAndSettle();
      final p = rig.container.read(plansProvider).single;
      expect((p.title, p.kind, p.totalDays), ('Mool Mantar', PlanKind.mantra, 30));
      expect(key('plan-title'), findsNothing, reason: 'the sheet closed');
      expect(text(tester, 'plan-progress-${p.id}'), '0 of 30 days');
    });

    testWidgets('the form: day chips and suggestions fill it in', (tester) async {
      final rig = await open(tester);
      await tester.tap(key('plan-add'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(key('plan-days')).controller!.text, '21');
      await tester.tap(key('days-40'));
      await tester.pump();
      expect(tester.widget<TextField>(key('plan-days')).controller!.text, '40');
      expect(tester.widget<ChoiceChip>(key('days-40')).selected, isTrue);
      expect(tester.widget<ChoiceChip>(key('days-21')).selected, isFalse);
      await tester.tap(key('suggest-3')); // Gayatri Mantra, mantra, 21
      await tester.pump();
      expect(tester.widget<TextField>(key('plan-title')).controller!.text, 'Gayatri Mantra');
      expect(tester.widget<TextField>(key('plan-days')).controller!.text, '21');
      expect(tester.widget<SegmentedButton<PlanKind>>(key('plan-kind')).selected,
          {PlanKind.mantra});
      await tester.tap(key('plan-save'));
      await tester.pumpAndSettle();
      expect(rig.container.read(plansProvider).single.title, 'Gayatri Mantra');
    });

    testWidgets('the form refuses an empty name or a silly number of days',
        (tester) async {
      final rig = await open(tester);
      await tester.tap(key('plan-add'));
      await tester.pumpAndSettle();
      await tester.tap(key('plan-save'));
      await tester.pump();
      expect(find.text('Give the plan a name'), findsOneWidget);
      expect(rig.container.read(plansProvider), isEmpty);

      await tester.enterText(key('plan-title'), 'Japji');
      for (final bad in ['0', '400', '']) {
        await tester.enterText(key('plan-days'), bad);
        await tester.pump();
        await tester.tap(key('plan-save'));
        await tester.pump();
        expect(find.text('Choose 1 to 365 days'), findsOneWidget, reason: '"$bad"');
        expect(rig.container.read(plansProvider), isEmpty);
      }
      expect(key('plan-title'), findsOneWidget, reason: 'the sheet stays open');
    });

    testWidgets('Mark today done: the bar moves and the streak starts',
        (tester) async {
      final rig = await open(tester);
      rig.container.read(plansProvider.notifier).add(title: 'Japji', kind: PlanKind.paath, days: 4);
      await tester.pump();
      final id = rig.container.read(plansProvider).single.id;
      double bar() => tester.widget<LinearProgressIndicator>(key('plan-bar-$id')).value!;
      expect(bar(), 0);
      expect(find.text('Mark today done'), findsOneWidget);

      await tester.tap(key('plan-toggle-$id'));
      await tester.pump();
      expect(bar(), 0.25);
      expect(text(tester, 'plan-progress-$id'), '1 of 4 days');
      expect(find.text('Done today'), findsOneWidget);
      expect(text(tester, 'stat-streak'), '1');
    });

    testWidgets('Done today can be tapped again to take the tick back', (tester) async {
      final rig = await open(tester);
      rig.container.read(plansProvider.notifier).add(title: 'Japji', kind: PlanKind.paath, days: 4);
      await tester.pump();
      final id = rig.container.read(plansProvider).single.id;
      await tester.tap(key('plan-toggle-$id'));
      await tester.pump();
      await tester.tap(key('plan-toggle-$id'));
      await tester.pump();
      expect(text(tester, 'plan-progress-$id'), '0 of 4 days');
      expect(text(tester, 'stat-streak'), '0');
    });

    testWidgets('a new day offers the button again, and the streak grows',
        (tester) async {
      final rig = await open(tester);
      rig.container.read(plansProvider.notifier).add(title: 'Japji', kind: PlanKind.paath, days: 4);
      await tester.pump();
      final id = rig.container.read(plansProvider).single.id;
      await tester.tap(key('plan-toggle-$id'));
      await tester.pump();
      setNow(rig, DateTime(2026, 9, 22, 7, 0));
      await tester.pump();
      expect(find.text('Mark today done'), findsOneWidget);
      expect(text(tester, 'stat-streak'), '1', reason: 'yesterday still counts');
      await tester.tap(key('plan-toggle-$id'));
      await tester.pump();
      expect(text(tester, 'stat-streak'), '2');
      expect(text(tester, 'plan-progress-$id'), '2 of 4 days');
    });

    testWidgets('finishing a plan shows Completed and drops the active count',
        (tester) async {
      final rig = await open(tester);
      rig.container.read(plansProvider.notifier).add(title: 'Short', kind: PlanKind.mantra, days: 1);
      await tester.pump();
      final id = rig.container.read(plansProvider).single.id;
      expect(text(tester, 'stat-active'), '1');
      await tester.tap(key('plan-toggle-$id'));
      await tester.pump();
      expect(text(tester, 'plan-progress-$id'), 'Completed · 1 of 1 days');
      expect(text(tester, 'stat-active'), '0');
      // Tomorrow the finished plan cannot be ticked further.
      setNow(rig, DateTime(2026, 9, 22, 7, 0));
      await tester.pump();
      expect(tester.widget<FilledButton>(key('plan-toggle-$id')).onPressed, isNull);
    });

    testWidgets('several plans, and the active count', (tester) async {
      final rig = await open(tester);
      final n = rig.container.read(plansProvider.notifier);
      n.add(title: 'A', kind: PlanKind.paath, days: 5);
      n.add(title: 'B', kind: PlanKind.mantra, days: 5);
      n.add(title: 'C', kind: PlanKind.mantra, days: 5);
      await tester.pump();
      expect(text(tester, 'stat-active'), '3');
      expect(find.text('active plans'), findsOneWidget);
      expect(key('plans-empty'), findsNothing);
    });

    testWidgets('one active plan reads "active plan"', (tester) async {
      final rig = await open(tester);
      rig.container.read(plansProvider.notifier).add(title: 'A', kind: PlanKind.paath, days: 5);
      await tester.pump();
      expect(find.text('active plan'), findsOneWidget);
    });

    testWidgets('deleting asks first; Cancel keeps it, Delete removes it',
        (tester) async {
      final rig = await open(tester);
      rig.container.read(plansProvider.notifier).add(title: 'Japji', kind: PlanKind.paath, days: 5);
      await tester.pump();
      final id = rig.container.read(plansProvider).single.id;

      await tester.tap(key('plan-menu-$id'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete plan'));
      await tester.pumpAndSettle();
      expect(find.text('Delete plan?'), findsOneWidget);
      await tester.tap(key('plan-delete-cancel'));
      await tester.pumpAndSettle();
      expect(rig.container.read(plansProvider), hasLength(1));

      await tester.tap(key('plan-menu-$id'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete plan'));
      await tester.pumpAndSettle();
      await tester.tap(key('plan-delete-confirm'));
      await tester.pumpAndSettle();
      expect(rig.container.read(plansProvider), isEmpty);
      expect(key('plans-empty'), findsOneWidget);
    });

    testWidgets('plans and ticks are still there after the app restarts',
        (tester) async {
      final rig = await open(tester);
      rig.container.read(plansProvider.notifier).add(title: 'Japji', kind: PlanKind.paath, days: 40);
      await tester.pump();
      final id = rig.container.read(plansProvider).single.id;
      await tester.tap(key('plan-toggle-$id'));
      await tester.pump();

      await tester.pumpWidget(const SizedBox());
      final again = profileRig(saved: {'home.plans': AppStorage.settings.get('home.plans')});
      await open(tester, rig: again);
      expect(text(tester, 'plan-progress-$id'), '1 of 40 days');
      expect(text(tester, 'stat-streak'), '1');
    });
  });

  group('layout', () {
    for (final (name, w, h) in [('small', 320.0, 568.0), ('normal', 411.0, 915.0)]) {
      testWidgets('$name phone, with plans, no overflow, light and dark',
          (tester) async {
        for (final b in Brightness.values) {
          final rig = profileRig();
          final n = rig.container.read(plansProvider.notifier);
          n.add(title: 'A long paath name that goes on and on and on', kind: PlanKind.paath, days: 108);
          n.add(title: 'Mantra', kind: PlanKind.mantra, days: 7);
          await open(tester, rig: rig, width: w, height: h, brightness: b);
          await tester.tap(find.descendant(of: key('tradition-switch'), matching: find.text('Sikh')));
          await tester.pump();
          await tester.drag(find.byType(ListView), const Offset(0, -2000));
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '$name $b');
          await tester.pumpWidget(const SizedBox());
        }
      });
    }
  });
}
