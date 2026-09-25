import 'package:advance_calendar/features/calendar/application/calendar_marks_provider.dart';
import 'package:advance_calendar/features/calendar/application/mark_style_provider.dart';
import 'package:advance_calendar/features/calendar/data/calendar_mark.dart';
import 'package:advance_calendar/features/calendar/presentation/widgets/mark_editor_sheet.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'audit_harness.dart';

/// P4.3-2c: the Calendar tab and everything it opens, in every language, text
/// size and theme.
void main() {
  setUpAll(setUpLayoutAudit);

  Finder key(String k) => find.byKey(ValueKey(k));

  /// Marks of every type, several on one date (the grid stacks them), a long
  /// label, and one repeating mark.
  Future<void> fillMonth(ProfileRig rig) async {
    final marks = rig.container.read(calendarMarksProvider.notifier);
    final today = rig.clock.now;
    await marks.save(markOn(today,
        id: 'a',
        emoji: '🪔',
        label: 'Ekadashi fast and evening aarti at temple',
        details: 'Break the fast after sunset tomorrow with fruit and milk.',
        home: HomeMode.allDay));
    await marks.save(markOn(today, id: 'b', type: MarkType.cautious));
    await marks.save(markOn(today, id: 'c', type: MarkType.neutral, emoji: '🔔'));
    await marks.save(markOn(today.add(const Duration(days: 2)),
        id: 'd',
        type: MarkType.cautious,
        label: 'Travel',
        repeat: RepeatRule.weekly,
        reminder: ReminderMode.several,
        times: const [7 * 60, 18 * 60 + 30]));
  }

  for (final style in MarkStyle.values) {
    testWidgets('Calendar grid, ${style.name} style', (tester) async {
      await auditApp(tester, 'Calendar (${style.name})', (rig) async {
        await fillMonth(rig);
        rig.container.read(markStyleProvider.notifier).set(style);
        await selectTab(tester, rig, ShellTab.calendar);
        expect(await reveal(tester, key('style-${style.name}')), findsOneWidget);
        expect(await reveal(tester, key('month-card-a')), findsOneWidget);
      });
    });
  }

  testWidgets('Calendar, no marks this month (legend, style picker, empty)',
      (tester) async {
    await auditApp(tester, 'Calendar (empty)', (rig) async {
      await selectTab(tester, rig, ShellTab.calendar);
      expect(await reveal(tester, key('legend-today')), findsOneWidget);
      expect(await reveal(tester, key('no-marks')), findsOneWidget);
    });
  });

  // The day editor with each reminder mode and each Home option (a Home
  // option per reminder mode, so every one is seen at least once).
  for (final (i, reminder) in ReminderMode.values.indexed) {
    final home = HomeMode.values[i % HomeMode.values.length];
    testWidgets('Day editor: reminder ${reminder.name}, home ${home.name}',
        (tester) async {
      await auditApp(tester, 'Day editor (${reminder.name}/${home.name})',
          (rig) async {
        await rig.container.read(calendarMarksProvider.notifier).save(markOn(
            rig.clock.now,
            id: 'a',
            emoji: '📿',
            label: 'Ekadashi fast and evening aarti at temple',
            details: 'Break the fast after sunset tomorrow.',
            repeat: RepeatRule.halfYearly,
            reminder: reminder,
            times: switch (reminder) {
              ReminderMode.none => const [],
              ReminderMode.once => const [6 * 60],
              ReminderMode.several => const [
                  5 * 60, 7 * 60 + 15, 12 * 60, 18 * 60 + 30, 21 * 60 + 45,
                ],
            },
            home: home));
        await rig.container
            .read(calendarMarksProvider.notifier)
            .save(markOn(rig.clock.now, id: 'b', type: MarkType.cautious));
        await selectTab(tester, rig, ShellTab.calendar);
        showMarkEditor(appContext(tester), date: rig.clock.now, markId: 'a');
        await settle(tester);
        expect(find.byType(MarkEditorSheet), findsOneWidget);
        expect(await reveal(tester, key('save-mark')), findsOneWidget);
      });
    });
  }

  testWidgets('Day editor: a new mark', (tester) async {
    await auditApp(tester, 'Day editor (new)', (rig) async {
      await selectTab(tester, rig, ShellTab.calendar);
      showMarkEditor(appContext(tester), date: rig.clock.now);
      await settle(tester);
      expect(find.byType(MarkEditorSheet), findsOneWidget);
    });
  });

  testWidgets('Delete-mark dialog (repeating mark)', (tester) async {
    await auditApp(tester, 'Delete mark dialog', (rig) async {
      await rig.container.read(calendarMarksProvider.notifier).save(markOn(
          rig.clock.now,
          id: 'a',
          label: 'Ekadashi fast and evening aarti at temple',
          repeat: RepeatRule.monthly));
      await selectTab(tester, rig, ShellTab.calendar);
      showMarkEditor(appContext(tester), date: rig.clock.now, markId: 'a');
      await settle(tester);
      await tester.tap(await reveal(tester, key('delete-mark')));
      await settle(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}
