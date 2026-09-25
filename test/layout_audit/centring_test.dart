import 'package:advance_calendar/core/theme/theme_provider.dart';
import 'package:advance_calendar/features/calendar/application/calendar_marks_provider.dart';
import 'package:advance_calendar/features/clock/data/clock_tool.dart';
import 'package:advance_calendar/features/clock/presentation/clock_screen.dart';
import 'package:advance_calendar/features/profile/presentation/profile_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/focus_mode_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/mantra_library_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/voice_training_screen.dart';
import 'package:advance_calendar/features/sadhana/application/selected_mantra_provider.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/shell/language_provider.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'audit_harness.dart';
import 'centring_check.dart';

/// P4.3-3: text that wraps where it is meant to be centred stays centred, in
/// Punjabi and Tamil (long words, both scripts), at both text sizes.
void main() {
  setUpAll(setUpLayoutAudit);

  final screens = <String, Future<void> Function(WidgetTester, ProfileRig)>{
    'Home': (t, rig) => selectTab(t, rig, ShellTab.home),
    'Sadhana': (t, rig) => selectTab(t, rig, ShellTab.sadhana),
    'Calendar (empty)': (t, rig) => selectTab(t, rig, ShellTab.calendar),
    'Calendar (marks)': (t, rig) async {
      await rig.container.read(calendarMarksProvider.notifier).save(
          markOn(rig.clock.now, id: 'a', label: 'Ekadashi', emoji: '🪔'));
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
        openClockTool(appContext(t), tool);
        await settle(t);
      },
  };

  screens['Voice training'] = (t, rig) async {
    openVoiceTraining(
        appContext(t), rig.container.read(selectedMantraProvider));
    await settle(t);
  };

  Future<void> check(WidgetTester tester, ProfileRig rig) async {
    final found = <String>{};
    for (final c in auditCombos(
        locales: ['pa', 'ta'], brightnesses: [Brightness.light])) {
      tester.platformDispatcher.textScaleFactorTestValue = c.scale;
      rig.container.read(languageProvider.notifier).set(c.locale);
      rig.container.read(themeModeProvider.notifier).set(ThemeMode.light);
      await settle(tester);
      for (final o in offCentreText(tester)) {
        found.add('$c: $o');
      }
    }
    expect(found, isEmpty, reason: found.join('\n'));
  }

  for (final align in [TextAlign.start, TextAlign.center]) {
    testWidgets('the check itself flags a wrapped ${align.name} text beside a '
        'centred icon only when it is not centred', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SizedBox(
          width: 120,
          child: Column(children: [
            const Icon(Icons.star),
            Text('a long line that has to wrap in a narrow column',
                textAlign: align),
          ]),
        ),
      ));
      expect(offCentreText(tester),
          align == TextAlign.center ? isEmpty : hasLength(1));
    });
  }

  testWidgets('Onboarding: wrapped text stays centred (pa, ta)', (tester) async {
    final rig = await openAuditApp(tester,
        height: 2400, saved: {'onboarding.done': false});
    await check(tester, rig);
  });

  testWidgets('Lock-screen alarm screen: wrapped text stays centred (pa, ta)',
      (tester) async {
    final rig = profileRig(
        saved: {'onboarding.done': true},
        lockScreen: FakeLockScreen(locked: true, launch: sadhanaTimerGroup));
    await openAuditApp(tester, rig: rig, height: 2400);
    expect(find.byKey(const ValueKey('alarm-finished-screen')), findsOneWidget);
    await check(tester, rig);
  });

  testWidgets('the Punjabi calendar: style names are centred under their '
      'previews', (tester) async {
    final rig = await openAuditApp(tester, height: 2400);
    rig.container.read(languageProvider.notifier).set('pa');
    await selectTab(tester, rig, ShellTab.calendar);
    final label = find.text('ਭਰਿਆ ਹੋਇਆ');
    expect(label, findsOneWidget);
    expect(tester.widget<Text>(label).textAlign, TextAlign.center);
    final tile = tester.getRect(find.byKey(const ValueKey('style-filled')));
    expect(tester.getRect(label).center.dx, closeTo(tile.center.dx, 1));
  });

  for (final lang in ['pa', 'ta']) {
    testWidgets('stopwatch hint ($lang): centred on every line, at 1.6',
        (tester) async {
      final rig = await openAuditApp(tester);
      rig.container.read(languageProvider.notifier).set(lang);
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      openClockTool(appContext(tester), ClockTool.stopwatch);
      await settle(tester);
      final hint = find.byKey(const ValueKey('sw-empty'));
      expect(tester.widget<Text>(hint).textAlign, TextAlign.center);
      expect(tester.getRect(hint).center.dx, closeTo(180, 1));
    });
  }

  for (final MapEntry(key: name, value: open) in screens.entries) {
    testWidgets('$name: wrapped text stays centred (pa, ta)', (tester) async {
      final rig = await openAuditApp(tester, height: 2400);
      await open(tester, rig);
      await check(tester, rig);
    });
  }
}
