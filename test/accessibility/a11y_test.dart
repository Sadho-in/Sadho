import 'dart:convert';
import 'dart:io';

import 'package:advance_calendar/features/calendar/application/calendar_marks_provider.dart';
import 'package:advance_calendar/features/calendar/data/calendar_mark.dart';
import 'package:advance_calendar/features/clock/data/clock_tool.dart';
import 'package:advance_calendar/features/clock/presentation/clock_screen.dart';
import 'package:advance_calendar/features/home/application/plans_provider.dart';
import 'package:advance_calendar/features/home/data/plan.dart';
import 'package:advance_calendar/features/notepad/application/notes_provider.dart';
import 'package:advance_calendar/features/profile/presentation/profile_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/focus_mode_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/mantra_library_screen.dart';
import 'package:advance_calendar/features/shell/language_provider.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../layout_audit/audit_harness.dart';
import 'a11y_support.dart';

/// P4.3-9: every tap target is at least 48×48 dp and says what it does.
void main() {
  setUpAll(setUpLayoutAudit);

  final screens = <String, Future<void> Function(WidgetTester, ProfileRig)>{
    'Home': (t, rig) async {
      final plans = rig.container.read(plansProvider.notifier);
      plans.add(title: 'Sukhmani Sahib', kind: PlanKind.paath, days: 40);
      await rig.container.read(calendarMarksProvider.notifier).save(markOn(
          rig.clock.now,
          id: 'a',
          label: 'Ekadashi',
          home: HomeMode.allDay));
      await selectTab(t, rig, ShellTab.home);
    },
    'Sadhana': (t, rig) => selectTab(t, rig, ShellTab.sadhana),
    'Calendar': (t, rig) async {
      await rig.container
          .read(calendarMarksProvider.notifier)
          .save(markOn(rig.clock.now, id: 'a', label: 'Ekadashi'));
      await selectTab(t, rig, ShellTab.calendar);
    },
    'Clock': (t, rig) => selectTab(t, rig, ShellTab.clock),
    'Profile': (t, rig) async {
      Navigator.of(appContext(t)).push(
          MaterialPageRoute<void>(builder: (_) => const ProfilePage()));
      await settle(t);
    },
    'Focus mode': (t, rig) async {
      await selectTab(t, rig, ShellTab.sadhana);
      openFocusMode(appContext(t));
      await settle(t);
    },
    'Mantra library': (t, rig) async {
      Navigator.of(appContext(t)).push(MaterialPageRoute<void>(
          builder: (_) => const MantraLibraryScreen()));
      await settle(t);
    },
    for (final tool in ClockTool.values)
      'Clock: ${tool.name}': (t, rig) async {
        if (tool == ClockTool.notepad) {
          final n = rig.container.read(notesProvider.notifier);
          n.save(n.draft(), title: 'Samagri list', text: 'ghee');
        }
        openClockTool(appContext(t), tool);
        await settle(t);
      },
  };

  for (final MapEntry(key: name, value: open) in screens.entries) {
    testWidgets('$name: tap targets are 48×48 and labelled', (tester) async {
      final handle = tester.ensureSemantics();
      final rig = await openAuditApp(tester, height: 3000);
      await open(tester, rig);
      expect(tapTargetProblems(tester), isEmpty);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
  }

  // The app's English strings, and each language's own.
  Set<String> arbValues(String code) {
    final m = jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
        as Map<String, dynamic>;
    return {
      for (final e in m.entries)
        if (!e.key.startsWith('@') && e.value is String) e.value as String,
    };
  }

  final english = arbValues('en');

  for (final code in auditLocales.where((c) => c != 'en')) {
    testWidgets('$code: every button says what it does in $code (no English '
        'labels or tooltips)', (tester) async {
      final handle = tester.ensureSemantics();
      final own = arbValues(code);
      final found = <String>{};
      for (final MapEntry(key: name, value: open) in screens.entries) {
        final rig = await openAuditApp(tester, height: 3000);
        rig.container.read(languageProvider.notifier).set(code);
        await settle(tester);
        await open(tester, rig);
        for (final label in tapTargetLabels(tester)) {
          // Split "Reset\nReset" style merged labels.
          for (final part in label.split('\n')) {
            if (english.contains(part) &&
                !own.contains(part) &&
                part.contains(RegExp('[A-Za-z]{3}'))) {
              found.add('$name: "$part"');
            }
          }
        }
        expect(tapTargetProblems(tester), isEmpty, reason: '$code $name');
        await tester.pumpWidget(const SizedBox());
      }
      // Flutter's own Back / Close tooltips are translated too.
      final rig = await openAuditApp(tester);
      rig.container.read(languageProvider.notifier).set(code);
      await settle(tester);
      final m = MaterialLocalizations.of(appContext(tester));
      expect(m.backButtonTooltip, isNot('Back'));
      expect(m.closeButtonTooltip, isNot('Close'));
      expect(found, isEmpty, reason: found.join('\n'));
      handle.dispose();
    });
  }
}
