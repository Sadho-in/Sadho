import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:advance_calendar/core/constants/app_constants.dart';
import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/core/theme/app_theme.dart';
import 'package:advance_calendar/core/theme/palettes.dart';
import 'package:advance_calendar/core/theme/theme_provider.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/home/application/plans_provider.dart';
import 'package:advance_calendar/features/home/application/tradition_provider.dart';
import 'package:advance_calendar/features/home/data/tradition.dart';
import 'package:advance_calendar/features/home/data/plan.dart';
import 'package:advance_calendar/features/profile/application/account_service.dart';
import 'package:advance_calendar/features/profile/application/backup_service.dart';
import 'package:advance_calendar/features/profile/application/daily_reminder_provider.dart';
import 'package:advance_calendar/features/profile/application/profile_provider.dart';
import 'package:advance_calendar/features/profile/presentation/profile_screen.dart';
import 'package:advance_calendar/features/profile/presentation/widgets/password_sheet.dart';
import 'package:advance_calendar/features/shell/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'profile_support.dart';

void main() {
  Finder key(String k) => find.byKey(ValueKey(k));
  String text(WidgetTester t, String k) => t.widget<Text>(key(k)).data!;
  bool enabled(WidgetTester t, String k) {
    final w = t.widget(key(k));
    return (w as ButtonStyleButton).onPressed != null;
  }

  Future<void> scrollTo(WidgetTester t, String k) async {
    await t.ensureVisible(key(k));
    await t.pump();
  }

  group('the page', () {
    testWidgets('has every section, top to bottom, ending with the danger zone',
        (tester) async {
      await openProfile(tester);
      double y(Finder f) => tester.getTopLeft(f).dy;
      final order = [
        key('profile-completion'),
        find.text('Your details'),
        find.text('Theme'),
        key('profile-language'),
        find.text('Daily reminder'),
        find.text('Sadhana settings'),
        find.text('Backup & restore'),
        find.text('Account'),
        find.text('About'),
        key('danger-zone'),
      ];
      var last = -1.0;
      for (final f in order) {
        expect(f, findsOneWidget, reason: '$f');
        expect(y(f), greaterThan(last), reason: '$f is below the one before');
        last = y(f);
      }
      expect(find.text('Profile'), findsOneWidget, reason: 'the app bar title');
    });

    testWidgets('fits a small phone, and a dark theme, without overflow',
        (tester) async {
      for (final b in Brightness.values) {
        await openProfile(tester, width: 320, height: 6000, brightness: b);
        expect(tester.takeException(), isNull, reason: '$b');
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('scrolls on a short screen', (tester) async {
      await openProfile(tester, height: 640);
      await tester.scrollUntilVisible(key('danger-zone'), 300,
          scrollable: find.byType(Scrollable).first);
      expect(tester.takeException(), isNull);
      expect(key('delete-account'), findsOneWidget);
    });
  });

  group('name and email', () {
    testWidgets('start empty; Save is off until something changes', (tester) async {
      await openProfile(tester);
      expect(tester.widget<TextField>(key('profile-name')).controller!.text, '');
      expect(enabled(tester, 'profile-save'), isFalse);
    });

    testWidgets('typing a name and email, then Save, keeps them', (tester) async {
      final rig = await openProfile(tester);
      await tester.enterText(key('profile-name'), '  Asha Kaur ');
      await tester.enterText(key('profile-email'), 'asha@example.com');
      await tester.pump();
      expect(enabled(tester, 'profile-save'), isTrue);
      await tester.tap(key('profile-save'));
      await tester.pump();
      final p = rig.container.read(profileProvider);
      expect((p.name, p.email), ('Asha Kaur', 'asha@example.com'));
      expect(find.text('Profile saved'), findsOneWidget);
      expect(enabled(tester, 'profile-save'), isFalse, reason: 'nothing left to save');
      expect(AppStorage.settings.get('profile'), {'name': 'Asha Kaur', 'email': 'asha@example.com'});
    });

    testWidgets('they are filled in again on the next visit', (tester) async {
      final rig = profileRig(saved: {'profile': {'name': 'Asha', 'email': 'a@b.co'}});
      await openProfile(tester, rig: rig);
      expect(tester.widget<TextField>(key('profile-name')).controller!.text, 'Asha');
      expect(tester.widget<TextField>(key('profile-email')).controller!.text, 'a@b.co');
    });

    testWidgets('a bad email is called out and cannot be saved', (tester) async {
      final rig = await openProfile(tester);
      await tester.enterText(key('profile-email'), 'asha@');
      await tester.pump();
      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(enabled(tester, 'profile-save'), isFalse);
      await tester.enterText(key('profile-email'), 'asha@example.com');
      await tester.pump();
      expect(find.text('Enter a valid email address'), findsNothing);
      expect(enabled(tester, 'profile-save'), isTrue);
      expect(rig.container.read(profileProvider).email, '');
    });

    testWidgets('the email is optional', (tester) async {
      final rig = await openProfile(tester);
      await tester.enterText(key('profile-name'), 'Asha');
      await tester.pump();
      await tester.tap(key('profile-save'));
      await tester.pump();
      expect(rig.container.read(profileProvider).name, 'Asha');
    });

    testWidgets('a very long name is refused', (tester) async {
      await openProfile(tester);
      await tester.enterText(key('profile-name'), 'A' * 80);
      await tester.pump();
      expect(find.textContaining('under 60 characters'), findsOneWidget);
      expect(enabled(tester, 'profile-save'), isFalse);
    });

    testWidgets('changing it back to what is saved turns Save off again',
        (tester) async {
      final rig = profileRig(saved: {'profile': {'name': 'Asha', 'email': ''}});
      await openProfile(tester, rig: rig);
      await tester.enterText(key('profile-name'), 'Asha K');
      await tester.pump();
      expect(enabled(tester, 'profile-save'), isTrue);
      await tester.enterText(key('profile-name'), 'Asha');
      await tester.pump();
      expect(enabled(tester, 'profile-save'), isFalse);
    });
  });

  group('profile completion', () {
    testWidgets('0% with five steps and a reward note', (tester) async {
      await openProfile(tester);
      expect(text(tester, 'profile-percent'), '0%');
      expect(tester.widget<LinearProgressIndicator>(key('profile-progress')).value, 0);
      for (final s in ['name', 'email', 'tradition', 'reminder', 'plan']) {
        expect(key('step-$s'), findsOneWidget, reason: s);
      }
      expect(text(tester, 'profile-reward'), contains('100%'));
      expect(text(tester, 'profile-reward'), contains('free premium'));
    });

    testWidgets('grows as you fill things in', (tester) async {
      final rig = await openProfile(tester);
      await tester.enterText(key('profile-name'), 'Asha');
      await tester.pump();
      await tester.tap(key('profile-save'));
      await tester.pump();
      expect(text(tester, 'profile-percent'), '20%');
      expect(tester.widget<LinearProgressIndicator>(key('profile-progress')).value, 0.2);
      rig.container.read(plansProvider.notifier).add(title: 'A', kind: PlanKind.paath, days: 5);
      await tester.pump();
      expect(text(tester, 'profile-percent'), '40%');
    });

    testWidgets('at 100% it celebrates and mentions the free premium reward',
        (tester) async {
      final rig = await openProfile(tester);
      await tester.enterText(key('profile-name'), 'Asha');
      await tester.enterText(key('profile-email'), 'a@b.co');
      await tester.pump();
      await tester.tap(key('profile-save'));
      await tester.pump();
      await rig.container.read(dailyReminderProvider.notifier).setEnabled(true);
      rig.container.read(plansProvider.notifier).add(title: 'A', kind: PlanKind.paath, days: 5);
      await tester.pump();
      expect(text(tester, 'profile-percent'), '80%');
      expect(text(tester, 'profile-reward'), contains('100%'));
      rig.container.read(traditionProvider.notifier).set(Tradition.hindu);
      await tester.pump();
      expect(text(tester, 'profile-percent'), '100%');
      expect(text(tester, 'profile-reward'), contains('Profile complete'));
      expect(text(tester, 'profile-reward'), contains('free premium'));
    });
  });

  group('theme', () {
    testWidgets('five palettes and Light / Dark / System', (tester) async {
      await openProfile(tester);
      for (final p in sadhoPalettes) {
        expect(key('palette-${p.id}'), findsOneWidget, reason: p.id);
        expect(find.text(p.name), findsOneWidget, reason: p.name);
      }
      final sb = tester.widget<SegmentedButton<ThemeMode>>(key('theme-mode'));
      expect([for (final s in sb.segments) s.value],
          [ThemeMode.light, ThemeMode.dark, ThemeMode.system]);
    });

    testWidgets('Marigold is chosen to begin with, and System mode', (tester) async {
      await openProfile(tester);
      expect(text(tester, 'palette-blurb'), defaultPalette.blurb);
      expect(tester.widget<SegmentedButton<ThemeMode>>(key('theme-mode')).selected,
          {ThemeMode.system});
    });

    for (final p in sadhoPalettes.skip(1)) {
      testWidgets('choosing ${p.name} applies it and saves it', (tester) async {
        final rig = await openProfile(tester);
        await tester.tap(key('palette-${p.id}'));
        await tester.pump();
        expect(rig.container.read(paletteProvider).id, p.id);
        expect(AppStorage.settings.get('themePalette'), p.id);
        expect(text(tester, 'palette-blurb'), p.blurb);
      });
    }

    testWidgets('Light, Dark and System are remembered', (tester) async {
      final rig = await openProfile(tester);
      for (final (label, mode) in [
        ('Dark', ThemeMode.dark),
        ('Light', ThemeMode.light),
        ('System', ThemeMode.system),
      ]) {
        await tester.tap(find.descendant(of: key('theme-mode'), matching: find.text(label)));
        await tester.pump();
        expect(rig.container.read(themeModeProvider), mode);
        expect(AppStorage.settings.get('themeMode'), mode.name);
        expect(tester.widget<SegmentedButton<ThemeMode>>(key('theme-mode')).selected, {mode});
      }
    });

    testWidgets('a choice changes the colours of the WHOLE app, not just this page',
        (tester) async {
      final rig = profileRig();
      phoneScreen(tester, height: 6000);
      // A stand-in for SadhoApp: the MaterialApp is themed from the provider.
      await tester.pumpWidget(UncontrolledProviderScope(
        container: rig.container,
        child: Consumer(builder: (context, ref, _) {
          final palette = ref.watch(paletteProvider);
          return MaterialApp(
            theme: ThemeData(
                useMaterial3: true,
                colorScheme: AppTheme.colorScheme(palette, Brightness.light)),
            home: Builder(
              builder: (context) => Scaffold(
                body: Column(children: [
                  Container(
                    key: const ValueKey('probe'),
                    height: 10,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Expanded(child: ProfileScreen()),
                ]),
              ),
            ),
          );
        }),
      ));
      await tester.pump();
      Color probe() => tester.widget<Container>(key('probe')).color!;
      expect(probe(), sadhoPalettes[0].light.primary);
      await tester.tap(key('palette-tulsi'));
      await tester.pumpAndSettle(); // the theme change animates
      expect(probe(), sadhoPalettes[2].light.primary);
      await tester.tap(key('palette-lotus'));
      await tester.pumpAndSettle();
      expect(probe(), sadhoPalettes[4].light.primary);
    });

    testWidgets('a saved palette is selected when the page opens', (tester) async {
      final rig = profileRig(saved: {'themePalette': 'twilight'});
      await openProfile(tester, rig: rig);
      expect(text(tester, 'palette-blurb'), sadhoPalettes[3].blurb);
    });
  });

  group('language', () {
    testWidgets('shows the current language and opens the chooser', (tester) async {
      final rig = await openProfile(tester);
      expect(find.descendant(of: key('profile-language'), matching: find.textContaining('English')),
          findsOneWidget);
      await tester.tap(key('profile-language'));
      await tester.pumpAndSettle();
      for (final l in appLanguages) {
        expect(find.text(l.nativeName), findsWidgets, reason: l.name);
      }
      await tester.tap(find.text('हिन्दी'));
      await tester.pumpAndSettle();
      expect(rig.container.read(languageProvider), 'hi');
      expect(AppStorage.settings.get('language'), 'hi');
    });

    testWidgets('the tile then shows the new language', (tester) async {
      await openProfile(tester);
      await tester.tap(key('profile-language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ਪੰਜਾਬੀ'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(200, 20)); // dismiss the sheet
      await tester.pumpAndSettle();
      expect(find.descendant(of: key('profile-language'), matching: find.textContaining('ਪੰਜਾਬੀ')),
          findsOneWidget);
    });
  });

  group('daily reminder', () {
    testWidgets('off to begin with', (tester) async {
      await openProfile(tester);
      expect(tester.widget<SwitchListTile>(key('reminder-switch')).value, isFalse);
      expect(text(tester, 'reminder-status'), 'Off');
      expect(text(tester, 'reminder-time-text'), contains('6:00'));
    });

    testWidgets('switching on schedules a daily notification at that time',
        (tester) async {
      final rig = await openProfile(tester);
      await tester.tap(key('reminder-switch'));
      await tester.pump();
      await tester.pump();
      expect(rig.scheduler.permissionRequests, 1);
      final a = rig.scheduler.alerts[dailyReminderGroup]!.single;
      expect(a.repeatsDaily, isTrue);
      expect(a.when.hour, 6);
      expect(text(tester, 'reminder-status'), startsWith('Every day at'));
    });

    testWidgets('switching off cancels it', (tester) async {
      final rig = await openProfile(tester);
      await tester.tap(key('reminder-switch'));
      await tester.pump();
      await tester.tap(key('reminder-switch'));
      await tester.pump();
      await tester.pump();
      expect(rig.scheduler.alerts[dailyReminderGroup], isEmpty);
      expect(text(tester, 'reminder-status'), 'Off');
    });

    testWidgets('a refused permission says so', (tester) async {
      final rig = profileRig(scheduler: FakeScheduler(permission: false));
      await openProfile(tester, rig: rig);
      await tester.tap(key('reminder-switch'));
      await tester.pump();
      await tester.pump();
      expect(find.textContaining('Allow notifications'), findsOneWidget);
    });

    testWidgets('the time is chosen with the system time picker', (tester) async {
      final rig = await openProfile(tester);
      await tester.tap(key('reminder-time'));
      await tester.pumpAndSettle();
      expect(find.text('Daily sadhana reminder'), findsWidgets, reason: 'the picker opened');
      // Type the time instead of dragging the dial.
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();
      final fields = find.descendant(
          of: find.byType(Dialog), matching: find.byType(TextField));
      await tester.enterText(fields.at(0), '7');
      await tester.enterText(fields.at(1), '45');
      await tester.pump();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      final r = rig.container.read(dailyReminderProvider);
      expect((r.hour, r.minute), (7, 45));
      expect(text(tester, 'reminder-time-text'), contains('7:45'));
    });

    testWidgets('Cancel in the picker changes nothing', (tester) async {
      final rig = await openProfile(tester);
      await tester.tap(key('reminder-time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(rig.container.read(dailyReminderProvider).minutes, 360);
    });

    testWidgets('a saved reminder shows its time', (tester) async {
      final rig = profileRig(saved: {
        'profile.dailyReminder': const DailyReminder(enabled: true, minutes: 17 * 60 + 30).toMap()
      });
      await openProfile(tester, rig: rig);
      expect(tester.widget<SwitchListTile>(key('reminder-switch')).value, isTrue);
      expect(text(tester, 'reminder-status'), contains('5:30'));
    });
  });

  group('backup & restore', () {
    testWidgets('Export saves one file with everything, named by date', (tester) async {
      final rig = await openProfile(tester);
      rig.container.read(profileProvider.notifier).save(name: 'Asha', email: 'a@b.co');
      rig.container.read(plansProvider.notifier).add(title: 'Japji', kind: PlanKind.paath, days: 40);
      await AppStorage.calendarMarks.put('m1', {'id': 'm1', 'label': 'Ekadashi'});
      await scrollTo(tester, 'backup-export');
      await tester.tap(key('backup-export'));
      await tester.pump();
      await tester.pump();
      expect(rig.files.savedName, matches(RegExp(r'^sadho-backup-\d{4}-\d{2}-\d{2}\.json$')));
      expect(find.text('Backup saved'), findsOneWidget);
      final j = jsonDecode(utf8.decode(rig.files.savedBytes!)) as Map;
      expect(j['format'], 'sadho-backup');
      final boxes = j['boxes'] as Map;
      expect((boxes['settings'] as Map)['profile'], {'name': 'Asha', 'email': 'a@b.co'});
      expect((boxes['calendar_marks'] as Map)['m1'], isNotNull);
      expect(((boxes['settings'] as Map)['home.plans'] as List).length, 1);
    });

    testWidgets('backing out of the save dialog says so, and saves nothing',
        (tester) async {
      final files = FakeBackupFiles()..saveAccepted = false;
      await openProfile(tester, rig: profileRig(files: files));
      await scrollTo(tester, 'backup-export');
      await tester.tap(key('backup-export'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Backup cancelled'), findsOneWidget);
      expect(files.savedBytes, isNull);
    });

    Uint8List backupOf(Map<String, Map<String, Object?>> boxes, {int version = 1}) =>
        Uint8List.fromList(utf8.encode(jsonEncode({
          'format': 'sadho-backup',
          'version': version,
          'exportedAt': '2026-09-01T10:00:00.000',
          'boxes': boxes,
        })));

    testWidgets('Restore: choose a file, confirm, and the data is replaced',
        (tester) async {
      final files = FakeBackupFiles()
        ..toPick = backupOf({
          'settings': {'language': 'pa', 'profile': {'name': 'Restored', 'email': ''}},
          'calendar_marks': {'m9': {'id': 'm9'}},
        });
      final rig = profileRig(files: files, saved: {'language': 'en'});
      await AppStorage.calendarMarks.put('old', {'id': 'old'});
      await openProfile(tester, rig: rig);
      await scrollTo(tester, 'backup-restore');
      await tester.tap(key('backup-restore'));
      await tester.pumpAndSettle();

      expect(find.text('Restore this backup?'), findsOneWidget);
      expect(find.textContaining('3 saved items'), findsOneWidget);
      expect(find.textContaining('Sep 1, 2026'), findsOneWidget);
      // Nothing has changed yet.
      expect(AppStorage.settings.get('language'), 'en');

      await tester.tap(key('restore-confirm'));
      await tester.pumpAndSettle();
      expect(find.text('Backup restored'), findsOneWidget);
      await tester.tap(key('restore-done'));
      await tester.pumpAndSettle();
      expect(AppStorage.settings.get('language'), 'pa');
      expect((AppStorage.settings.get('profile') as Map)['name'], 'Restored');
      expect(AppStorage.calendarMarks.get('m9'), isNotNull);
      expect(AppStorage.calendarMarks.get('old'), isNull, reason: 'replaced, not merged');
    });

    testWidgets('Cancel at the confirmation restores nothing', (tester) async {
      final files = FakeBackupFiles()
        ..toPick = backupOf({'settings': {'language': 'pa'}});
      final rig = profileRig(files: files, saved: {'language': 'en'});
      await openProfile(tester, rig: rig);
      await scrollTo(tester, 'backup-restore');
      final before = snapshot();
      await tester.tap(key('backup-restore'));
      await tester.pumpAndSettle();
      await tester.tap(key('restore-cancel'));
      await tester.pumpAndSettle();
      expect(snapshot(), before);
      expect(find.text('Backup restored'), findsNothing);
    });

    testWidgets('backing out of the file chooser does nothing', (tester) async {
      final files = FakeBackupFiles();
      final rig = profileRig(files: files);
      await openProfile(tester, rig: rig);
      await scrollTo(tester, 'backup-restore');
      final before = snapshot();
      await tester.tap(key('backup-restore'));
      await tester.pumpAndSettle();
      expect(files.picks, 1);
      expect(find.text('Restore this backup?'), findsNothing);
      expect(snapshot(), before);
    });

    for (final (name, bytes, message) in <(String, Uint8List, String)>[
      ('a text file', Uint8List.fromList(utf8.encode('just some notes')), 'not a Sadho backup'),
      ('not text at all', Uint8List.fromList([0xff, 0xfe, 0xfd, 0x80]), 'not a Sadho backup'),
      ('another app\'s JSON', Uint8List.fromList(utf8.encode('{"hello": 1}')), 'not a Sadho backup'),
      ('a newer backup', backupOf({'settings': {'a': 1}}, version: 99), 'newer version'),
    ]) {
      testWidgets('$name is refused with a plain message and nothing changes',
          (tester) async {
        final files = FakeBackupFiles()..toPick = bytes;
        final rig = profileRig(files: files, saved: {'language': 'en'});
        await openProfile(tester, rig: rig);
        await scrollTo(tester, 'backup-restore');
        final before = snapshot();
        await tester.tap(key('backup-restore'));
        await tester.pumpAndSettle();
        expect(find.textContaining(message), findsOneWidget);
        expect(find.text('Restore this backup?'), findsNothing);
        expect(snapshot(), before);
      });
    }

    testWidgets('an oversize file is refused', (tester) async {
      final files = FakeBackupFiles()
        ..pickError = BackupException('That file is too big to be a Sadho backup.');
      await openProfile(tester, rig: profileRig(files: files));
      await scrollTo(tester, 'backup-restore');
      await tester.tap(key('backup-restore'));
      await tester.pumpAndSettle();
      expect(find.textContaining('too big'), findsOneWidget);
    });

    testWidgets('an unexpected error while reading is reported, not thrown',
        (tester) async {
      final files = FakeBackupFiles()..pickError = StateError('disk on fire');
      await openProfile(tester, rig: profileRig(files: files));
      await scrollTo(tester, 'backup-restore');
      await tester.tap(key('backup-restore'));
      await tester.pumpAndSettle();
      expect(find.text('Could not read that file.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('export then restore on a fresh phone brings everything back',
        (tester) async {
      final files = FakeBackupFiles();
      final rig = profileRig(files: files);
      rig.container.read(profileProvider.notifier).save(name: 'Asha', email: 'a@b.co');
      rig.container.read(plansProvider.notifier).add(title: 'Japji', kind: PlanKind.paath, days: 40);
      await AppStorage.voiceTemplates.put('c1', {'t': Uint8List.fromList([1, 2, 3])});
      await openProfile(tester, rig: rig);
      await scrollTo(tester, 'backup-export');
      await tester.tap(key('backup-export'));
      await tester.pump();
      await tester.pump();
      final before = snapshot();

      await AppStorage.clearAll(); // a new phone
      files.toPick = files.savedBytes;
      await tester.tap(key('backup-restore'));
      await tester.pumpAndSettle();
      await tester.tap(key('restore-confirm'));
      await tester.pumpAndSettle();
      await tester.tap(key('restore-done'));
      await tester.pumpAndSettle();
      expect(snapshot(), before);
    });

    testWidgets('cloud sync is shown as coming later, and is not a button',
        (tester) async {
      await openProfile(tester);
      expect(find.text('Cloud sync'), findsOneWidget);
      expect(find.text('Coming later'), findsOneWidget);
      expect(tester.widget<ListTile>(key('cloud-sync')).enabled, isFalse);
    });
  });

  group('change password', () {
    Future<void> open(WidgetTester tester) async {
      await tester.ensureVisible(key('change-password'));
      await tester.pump();
      await tester.tap(key('change-password'));
      await tester.pumpAndSettle();
    }

    testWidgets('empty entries are called out', (tester) async {
      await openProfile(tester);
      await open(tester);
      await tester.tap(key('pw-submit'));
      await tester.pump();
      expect(find.text('Enter your current password'), findsOneWidget);
      expect(find.textContaining('at least 8 characters'), findsOneWidget);
      expect(key('pw-current'), findsOneWidget, reason: 'the sheet stays open');
    });

    testWidgets('a short new password, the same password, and a mismatch',
        (tester) async {
      await openProfile(tester);
      await open(tester);
      await tester.enterText(key('pw-current'), 'oldpassword');
      await tester.enterText(key('pw-new'), 'short');
      await tester.enterText(key('pw-confirm'), 'short');
      await tester.tap(key('pw-submit'));
      await tester.pump();
      expect(find.textContaining('at least 8 characters'), findsOneWidget);

      await tester.enterText(key('pw-new'), 'oldpassword');
      await tester.pump();
      expect(find.textContaining('have not used'), findsOneWidget);

      await tester.enterText(key('pw-new'), 'newpassword1');
      await tester.enterText(key('pw-confirm'), 'newpassword2');
      await tester.pump();
      expect(find.text('The two passwords do not match'), findsOneWidget);
    });

    testWidgets('passwords are hidden unless you ask to see them', (tester) async {
      await openProfile(tester);
      await open(tester);
      bool obscured() => tester.widget<TextField>(key('pw-new')).obscureText;
      expect(obscured(), isTrue);
      await tester.tap(key('pw-show'));
      await tester.pump();
      expect(obscured(), isFalse);
    });

    testWidgets('valid entries close the sheet and say it is not live yet; '
        'nothing is stored', (tester) async {
      await openProfile(tester);
      await AppStorage.settings.put('language', 'en');
      final before = snapshot();
      await open(tester);
      await tester.enterText(key('pw-current'), 'oldpassword');
      await tester.enterText(key('pw-new'), 'newpassword1');
      await tester.enterText(key('pw-confirm'), 'newpassword1');
      await tester.tap(key('pw-submit'));
      await tester.pumpAndSettle();
      expect(key('pw-current'), findsNothing);
      expect(find.text('Password change will work once accounts are added.'), findsOneWidget);
      expect(snapshot(), before, reason: 'a password is never saved on the phone');
    });

    test('the rules', () {
      expect(validateNewPassword('12345678', 'x'), isNull);
      expect(validateNewPassword('1234567', 'x'), isNotNull);
      expect(validateNewPassword('samesame1', 'samesame1'), isNotNull);
      expect(validateConfirmPassword('a', 'a'), isNull);
      expect(validateConfirmPassword('a', 'b'), isNotNull);
      expect(validateCurrentPassword(''), isNotNull);
    });
  });

  group('sign out', () {
    testWidgets('with no account yet it says so, honestly, and keeps the data',
        (tester) async {
      final rig = await openProfile(tester);
      await AppStorage.settings.put('language', 'pa');
      await scrollTo(tester, 'sign-out');
      final before = snapshot();
      await tester.tap(key('sign-out'));
      await tester.pump();
      await tester.pump();
      expect(find.textContaining('not signed in yet'), findsOneWidget);
      expect(find.textContaining('Your data stays on this phone'), findsOneWidget);
      expect(snapshot(), before);
      expect(rig, isNotNull);
    });

    testWidgets('it goes through the account service', (tester) async {
      final sched = FakeScheduler();
      final spy = SpyAccountService(LocalAccountService(sched));
      final rig = profileRig(
          scheduler: sched, extra: [accountServiceProvider.overrideWithValue(spy)]);
      await openProfile(tester, rig: rig);
      await scrollTo(tester, 'sign-out');
      await tester.tap(key('sign-out'));
      await tester.pump();
      expect(spy.signOuts, 1);
      expect(spy.deletes, 0);
    });
  });

  group('the danger zone', () {
    testWidgets('is red, separate, and says what deleting does', (tester) async {
      await openProfile(tester);
      final scheme = Theme.of(tester.element(key('danger-zone'))).colorScheme;
      final box = tester.widget<Container>(key('danger-zone')).decoration! as BoxDecoration;
      expect((box.border! as Border).top.color, scheme.error);
      expect(find.text('Danger zone'), findsOneWidget);
      final btn = tester.widget<FilledButton>(key('delete-account'));
      expect(btn.style!.backgroundColor!.resolve({}), scheme.error);
      expect(find.text('Delete account'), findsOneWidget);
      // Below everything else, including About.
      expect(tester.getTopLeft(key('danger-zone')).dy,
          greaterThan(tester.getBottomLeft(find.text('Version')).dy));
    });

    Future<ProfileRig> withData(WidgetTester tester) async {
      final rig = profileRig(saved: {
        'language': 'pa',
        'profile': {'name': 'Asha', 'email': 'a@b.co'},
      });
      await AppStorage.calendarMarks.put('m1', {'id': 'm1'});
      await AppStorage.customMantras.put('c1', {'t': 1});
      rig.container.read(plansProvider.notifier).add(title: 'A', kind: PlanKind.paath, days: 5);
      await rig.container.read(dailyReminderProvider.notifier).setEnabled(true);
      await openProfile(tester, rig: rig);
      await scrollTo(tester, 'delete-account');
      return rig;
    }

    testWidgets('asks "Are you sure?" with Yes / No, before doing anything',
        (tester) async {
      await withData(tester);
      final before = snapshot();
      await tester.tap(key('delete-account'));
      await tester.pumpAndSettle();
      expect(find.text('Are you sure?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.textContaining('cannot be undone'), findsOneWidget);
      expect(snapshot(), before, reason: 'nothing is deleted while the question is open');
    });

    testWidgets('No keeps everything', (tester) async {
      final rig = await withData(tester);
      final before = snapshot();
      final cancelled = rig.scheduler.alertReplacements.length;
      await tester.tap(key('delete-account'));
      await tester.pumpAndSettle();
      await tester.tap(key('delete-no'));
      await tester.pumpAndSettle();
      expect(find.text('Are you sure?'), findsNothing);
      expect(snapshot(), before);
      expect(rig.scheduler.alertReplacements.length, cancelled);
      expect(rig.scheduler.rescheduledAll, isEmpty);
    });

    testWidgets('tapping outside the question also keeps everything',
        (tester) async {
      await withData(tester);
      final before = snapshot();
      await tester.tap(key('delete-account'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Are you sure?'), findsNothing);
      expect(snapshot(), before);
    });

    testWidgets('the back button also keeps everything', (tester) async {
      await withData(tester);
      final before = snapshot();
      await tester.tap(key('delete-account'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute(); // Android's back button
      await tester.pumpAndSettle();
      expect(find.text('Are you sure?'), findsNothing);
      expect(snapshot(), before);
    });

    testWidgets('Yes erases everything on the phone and stops every notification',
        (tester) async {
      final rig = await withData(tester);
      expect(snapshot().values.any((b) => b.isNotEmpty), isTrue);
      await tester.tap(key('delete-account'));
      await tester.pumpAndSettle();
      await tester.tap(key('delete-yes'));
      await tester.pumpAndSettle();
      for (final e in snapshot().entries) {
        expect(e.value, isEmpty, reason: e.key);
      }
      for (final g in alertGroups) {
        expect(rig.scheduler.alerts[g], isEmpty, reason: g);
      }
      expect(rig.scheduler.rescheduledAll, [isEmpty]);
    });

    testWidgets('after Yes, a fresh start has no profile or plans', (tester) async {
      final rig = await withData(tester);
      await tester.tap(key('delete-account'));
      await tester.pumpAndSettle();
      await tester.tap(key('delete-yes'));
      await tester.pumpAndSettle();
      final fresh = profileRig(scheduler: rig.scheduler);
      expect(fresh.container.read(profileProvider).name, '');
      expect(fresh.container.read(plansProvider), isEmpty);
      expect(fresh.container.read(profileCompletionProvider).percent, 0);
    });
  });

  group('about', () {
    testWidgets('Sadho, sadho.in and the version', (tester) async {
      await openProfile(tester);
      expect(text(tester, 'about-app'), 'Sadho');
      expect(text(tester, 'about-website'), 'sadho.in');
      expect(text(tester, 'about-version'), isNotEmpty);
    });

    test('the version shown is the one in pubspec.yaml', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final m = RegExp(r'^version:\s*([0-9.]+)', multiLine: true).firstMatch(pubspec)!;
      expect(AppConstants.version, m.group(1));
    });
  });
}
