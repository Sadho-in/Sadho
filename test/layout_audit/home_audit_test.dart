import 'package:advance_calendar/features/calendar/application/calendar_marks_provider.dart';
import 'package:advance_calendar/features/calendar/data/calendar_mark.dart';
import 'package:advance_calendar/features/home/application/plans_provider.dart';
import 'package:advance_calendar/features/home/data/plan.dart';
import 'package:advance_calendar/features/home/data/tradition.dart';
import 'package:advance_calendar/features/onboarding/application/onboarding_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'audit_harness.dart';

/// P4.3-2a: onboarding and Home, in every language, text size and theme.
void main() {
  setUpAll(setUpLayoutAudit);

  Finder key(String k) => find.byKey(ValueKey(k));

  /// Two plans (one long title, one finished) and three calendar cards on
  /// Home, with long labels and details.
  Future<void> fillHome(ProfileRig rig) async {
    final plans = rig.container.read(plansProvider.notifier);
    plans.add(
        title: 'Sukhmani Sahib every morning before sunrise',
        kind: PlanKind.paath,
        days: 40);
    final short = plans.add(title: 'Jaap', kind: PlanKind.mantra, days: 1)!;
    plans.toggleToday(short.id);
    final marks = rig.container.read(calendarMarksProvider.notifier);
    final today = rig.clock.now;
    await marks.save(markOn(today,
        id: 'a',
        emoji: '🪔',
        label: 'Ekadashi fast and evening aarti at the temple',
        details: 'Break the fast after sunset tomorrow with fruit and milk.',
        home: HomeMode.allDay));
    await marks.save(markOn(today,
        id: 'b', type: MarkType.cautious, label: 'Travel', home: HomeMode.morning));
    await marks.save(markOn(today,
        id: 'c',
        type: MarkType.neutral,
        label: '',
        home: HomeMode.allDay,
        reminder: ReminderMode.several,
        times: const [7 * 60, 18 * 60 + 30]));
  }

  testWidgets('onboarding', (tester) async {
    await auditApp(tester, 'Onboarding', (rig) async {
      expect(rig.container.read(onboardingCompleteProvider), isFalse);
      expect(await reveal(tester, key('onboarding-continue')), findsOneWidget);
    }, saved: {'onboarding.done': false});
  });

  for (final t in Tradition.values) {
    testWidgets('Home, empty, ${t.name}', (tester) async {
      await auditApp(tester, 'Home (${t.name}, empty)', (rig) async {
        expect(await reveal(tester, key('home-empty')), findsOneWidget);
        expect(await reveal(tester, key('plans-empty')), findsOneWidget);
      }, saved: {'home.tradition': t.name});
    });
  }

  for (final t in Tradition.values) {
    testWidgets('Home with plans and cards, ${t.name}', (tester) async {
      await auditApp(tester, 'Home (${t.name}, full)', (rig) async {
        await fillHome(rig);
        await settle(tester);
        expect(await reveal(tester, key('home-card-a')), findsOneWidget);
      }, saved: {'home.tradition': t.name});
    });
  }

  testWidgets('Home: new plan sheet', (tester) async {
    await auditApp(tester, 'New plan sheet', (rig) async {
      await tester.tap(await reveal(tester, key('plan-add')));
      await settle(tester);
      expect(key('plan-save'), findsOneWidget);
    });
  });

  testWidgets('Home: delete plan dialog', (tester) async {
    await auditApp(tester, 'Delete plan dialog', (rig) async {
      final plan = rig.container.read(plansProvider.notifier).add(
          title: 'Sukhmani Sahib every morning before sunrise',
          kind: PlanKind.paath,
          days: 40)!;
      await settle(tester);
      await tester.tap(await reveal(tester, key('plan-menu-${plan.id}')));
      await settle(tester);
      await tester.tap(find.byType(PopupMenuItem<String>));
      await settle(tester);
      expect(key('plan-delete-confirm'), findsOneWidget);
    });
  });
}
