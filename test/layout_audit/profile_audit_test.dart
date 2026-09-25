import 'dart:convert';
import 'dart:typed_data';

import 'package:advance_calendar/features/alarms/presentation/alarms_reliability_page.dart';
import 'package:advance_calendar/features/alarms/services/alarm_health.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/profile/application/backup_service.dart';
import 'package:advance_calendar/features/profile/presentation/profile_screen.dart';
import 'package:advance_calendar/features/sadhana/application/session_notice_provider.dart';
import 'package:advance_calendar/features/shell/language_provider.dart';
import 'package:advance_calendar/features/shell/presentation/language_sheet.dart';
import 'package:advance_calendar/core/theme/theme_provider.dart';
import 'package:advance_calendar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../sadhana/test_support.dart' show FakeAlarmHealth;
import 'audit_harness.dart';

/// P4.3-2e: Profile and everything under it, the lock-screen alarm screen,
/// the backup / restore / delete dialogs and the snackbars with an action, in
/// every language, text size and theme.
void main() {
  setUpAll(setUpLayoutAudit);

  Finder key(String k) => find.byKey(ValueKey(k));

  Future<void> openProfilePage(WidgetTester tester) async {
    Navigator.of(appContext(tester)).push(
        MaterialPageRoute<void>(builder: (_) => const ProfilePage()));
    await settle(tester);
  }

  testWidgets('Profile page (every card)', (tester) async {
    await auditApp(tester, 'Profile', (rig) async {
      await openProfilePage(tester);
      expect(await reveal(tester, key('delete-account')), findsOneWidget);
    });
  });

  testWidgets('Profile: change-password sheet', (tester) async {
    await auditApp(tester, 'Password sheet', (rig) async {
      await openProfilePage(tester);
      await tester.tap(await reveal(tester, key('change-password')));
      await settle(tester);
      expect(find.byType(BottomSheet), findsOneWidget);
    });
  });

  testWidgets('Language sheet', (tester) async {
    await auditApp(tester, 'Language sheet', (rig) async {
      showLanguageSheet(appContext(tester));
      await settle(tester);
      expect(key('language-sheet-pa'), findsOneWidget);
    });
  });

  for (final (name, broken) in [('all fine', false), ('everything to fix, Samsung', true)]) {
    testWidgets('Alarms & reliability ($name)', (tester) async {
      await auditApp(tester, 'Alarms & reliability ($name)', (rig) async {
        final health = rig.container.read(alarmHealthProvider) as FakeAlarmHealth;
        if (broken) {
          health
            ..notifications = false
            ..exactAlarms = false
            ..fullScreen = false
            ..battery = false
            ..samsung = true;
        }
        openAlarmsReliability(appContext(tester));
        await settle(tester);
        expect(await reveal(tester, key('health-battery')), findsOneWidget);
        if (broken) {
          expect(await reveal(tester, key('health-battery-fix')), findsOneWidget);
        }
      });
    });
  }

  for (final group in [sadhanaTimerGroup, timerGroup, sunAlarmGroup]) {
    testWidgets('Lock-screen alarm screen ($group)', (tester) async {
      await auditApp(tester, 'Alarm finished screen ($group)', (rig) async {
        expect(key('alarm-finished-screen'), findsOneWidget);
      }, lockScreen: FakeLockScreen(locked: true, launch: group));
    });
  }

  testWidgets('Restore: confirm dialog', (tester) async {
    await auditApp(tester, 'Restore confirm dialog', (rig) async {
      rig.files.toPick =
          Uint8List.fromList(utf8.encode(exportBackup(now: rig.clock.now)));
      await openProfilePage(tester);
      await tester.tap(await reveal(tester, key('backup-restore')));
      await settle(tester);
      expect(key('restore-confirm'), findsOneWidget);
    });
  });

  testWidgets('Restore: done dialog', (tester) async {
    await auditApp(tester, 'Restore done dialog', (rig) async {
      rig.files.toPick =
          Uint8List.fromList(utf8.encode(exportBackup(now: rig.clock.now)));
      await openProfilePage(tester);
      await tester.tap(await reveal(tester, key('backup-restore')));
      await settle(tester);
      await tester.tap(key('restore-confirm'));
      await settle(tester);
      expect(key('restore-done'), findsOneWidget);
    });
  });

  testWidgets('Delete-account dialog', (tester) async {
    await auditApp(tester, 'Delete account dialog', (rig) async {
      await openProfilePage(tester);
      await tester.tap(await reveal(tester, key('delete-account')));
      await settle(tester);
      expect(key('delete-dialog'), findsOneWidget);
    });
  });

  // A snackbar lives a few seconds, so each combination shows it afresh (in
  // that language), with the longest action labels the app uses.
  for (final (name, show) in <(String, void Function(ProfileRig, AppLocalizations))>[
    ('Open settings', (rig, l) => rig.container
        .read(sessionNoticeProvider.notifier)
        .show(l.alarmExplainerCheck, openSettings: true)),
    ('Alarms page', (rig, l) => rig.container
        .read(sessionNoticeProvider.notifier)
        .show(l.alarmExplainerCheck, openAlarmsPage: true)),
    ('Allow', (rig, l) => rig.container
        .read(sessionNoticeProvider.notifier)
        .show(l.alarmExplainerCheck, actionLabel: l.allowAction, onAction: () {})),
    ('Train', (rig, l) => rig.container
        .read(sessionNoticeProvider.notifier)
        .show(l.trainFirstPrompt(3, 7), trainMantraId: 'waheguru')),
  ]) {
    testWidgets('Snackbar with an action: $name', (tester) async {
      final rig = await openAuditApp(tester);
      final failures = await collectLayoutFailures(tester, auditCombos(),
          (c) async {
        rig.container.read(languageProvider.notifier).set(c.locale);
        rig.container.read(themeModeProvider.notifier).set(
            c.brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light);
        await settle(tester);
        show(rig, lookupAppLocalizations(Locale(c.locale)));
        await settle(tester);
        expect(find.byType(SnackBarAction), findsOneWidget, reason: '$c');
      }, scroll: false);
      expectNoLayoutFailures(failures, 'Snackbar ($name)');
    });
  }
}
