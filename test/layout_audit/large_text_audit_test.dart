import 'package:advance_calendar/features/calendar/application/calendar_marks_provider.dart';
import 'package:advance_calendar/features/calendar/data/calendar_mark.dart';
import 'package:advance_calendar/features/home/application/plans_provider.dart';
import 'package:advance_calendar/features/home/data/plan.dart';
import 'package:advance_calendar/features/profile/presentation/profile_screen.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'audit_harness.dart';

/// P4.3-9: the main screens stay usable at text scale 2.0, in every language
/// and both themes, on a small phone.
void main() {
  setUpAll(setUpLayoutAudit);

  final combos = auditCombos(scales: [2.0]);

  testWidgets('Home at 2.0', (tester) async {
    await auditApp(tester, 'Home @2.0', (rig) async {
      rig.container.read(plansProvider.notifier).add(
          title: 'Sukhmani Sahib every morning before sunrise',
          kind: PlanKind.paath,
          days: 40);
      await rig.container.read(calendarMarksProvider.notifier).save(markOn(
          rig.clock.now,
          id: 'a',
          emoji: '🪔',
          label: 'Ekadashi fast and evening aarti at temple',
          home: HomeMode.allDay));
      await selectTab(tester, rig, ShellTab.home);
    }, combos: combos);
  });

  testWidgets('Sadhana at 2.0', (tester) async {
    await auditApp(tester, 'Sadhana @2.0', (rig) async {
      await selectTab(tester, rig, ShellTab.sadhana);
    }, combos: combos);
  });

  testWidgets('Calendar at 2.0', (tester) async {
    await auditApp(tester, 'Calendar @2.0', (rig) async {
      await rig.container.read(calendarMarksProvider.notifier).save(
          markOn(rig.clock.now, id: 'a', emoji: '🔔', label: 'Ekadashi'));
      await selectTab(tester, rig, ShellTab.calendar);
    }, combos: combos);
  });

  testWidgets('Clock tool list at 2.0', (tester) async {
    await auditApp(tester, 'Clock @2.0', (rig) async {
      await selectTab(tester, rig, ShellTab.clock);
    }, combos: combos);
  });

  testWidgets('Profile at 2.0', (tester) async {
    await auditApp(tester, 'Profile @2.0', (rig) async {
      Navigator.of(appContext(tester)).push(
          MaterialPageRoute<void>(builder: (_) => const ProfilePage()));
      await settle(tester);
    }, combos: combos);
  });
}
