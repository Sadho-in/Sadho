import 'dart:io';

import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/clock/application/sun_alarm_provider.dart';
import 'package:advance_calendar/features/profile/application/daily_reminder_provider.dart';
import 'package:advance_calendar/features/clock/application/timer_provider.dart';
import 'package:advance_calendar/features/clock/data/clock_tool.dart';
import 'package:advance_calendar/features/clock/presentation/clock_screen.dart';
import 'package:advance_calendar/features/shell/language_provider.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:advance_calendar/l10n/app_localizations.dart';
import 'package:advance_calendar/l10n/date_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../layout_audit/audit_harness.dart';

/// P4.3-5: every date and time is written in the app's language.
void main() {
  setUpAll(() async {
    await setUpLayoutAudit();
    initAppDateFormatting();
  });

  const locales = ['en', 'hi', 'pa', 'mr', 'bn', 'gu', 'ta', 'te', 'kn'];

  test('no DateFormat outside lib/l10n/date_formats.dart (every date goes '
      'through AppDates or MaterialLocalizations, in the app language)', () {
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart') ||
          f.path.endsWith('date_formats.dart') ||
          f.path.contains('app_localizations')) {
        continue;
      }
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains(RegExp(r'\bDateFormat\b'))) offenders.add('${f.path}:${i + 1}');
      }
    }
    expect(offenders, isEmpty);
  });

  test('AppDates follows its locale; mr and bn use their own digits', () {
    final d = DateTime(2026, 9, 21, 17, 5, 9);
    expect(AppDates(const Locale('en')).fullDate(d), 'Monday, 21 September 2026');
    expect(AppDates(const Locale('pa')).fullDate(d), 'ਸੋਮਵਾਰ, 21 ਸਤੰਬਰ 2026');
    expect(AppDates(const Locale('mr')).fullDate(d), contains('२०२६'));
    expect(AppDates(const Locale('bn')).fullDate(d), contains('২০২৬'));
    for (final l in ['hi', 'pa', 'gu', 'ta', 'te', 'kn']) {
      expect(AppDates(Locale(l)).fullDate(d), contains('2026'), reason: l);
    }
  });

  for (final code in locales) {
    testWidgets('$code: the big clock date matches intl for $code '
        '${code == 'en' ? '' : 'and is not English'}', (tester) async {
      final rig = await openAuditApp(tester, height: 1200);
      rig.container.read(languageProvider.notifier).set(code);
      await settle(tester);
      openClockTool(appContext(tester), ClockTool.clock);
      await settle(tester);
      final now = rig.clock.now;
      final shown = tester
          .widget<Text>(find.byKey(const ValueKey('clock-date')))
          .data!;
      expect(shown, DateFormat('EEEE, d MMMM y', code).format(now));
      if (code != 'en') {
        expect(shown, isNot(DateFormat('EEEE, d MMMM y', 'en').format(now)));
        expect(shown, isNot(contains('September')));
        expect(shown, isNot(contains('Monday')));
      }
    });

    testWidgets('$code: the calendar month title matches intl for $code '
        '${code == 'en' ? '' : 'and is not English'}', (tester) async {
      final rig = await openAuditApp(tester, height: 1200);
      rig.container.read(languageProvider.notifier).set(code);
      await selectTab(tester, rig, ShellTab.calendar);
      final title = DateFormat.yMMMM(code).format(rig.clock.now);
      expect(find.text(title), findsOneWidget);
      if (code != 'en') {
        expect(title, isNot(contains('September')));
        // The weekday names under it too.
        expect(find.text(DateFormat.E(code).format(rig.clock.now)),
            findsWidgets);
        expect(find.text('Mon'), findsNothing);
      }
    });
  }

  testWidgets('Home date, sunset time, world clock and the sun alarm are in '
      'Punjabi', (tester) async {
    final rig = await openAuditApp(tester, height: 2400);
    rig.container.read(languageProvider.notifier).set('pa');
    await settle(tester);
    final pa = AppDates(const Locale('pa'));
    // Home: the full date (MaterialLocalizations, in pa).
    expect(find.textContaining('ਸਤੰਬਰ'), findsWidgets);
    expect(find.textContaining('September'), findsNothing);

    openClockTool(appContext(tester), ClockTool.worldClock);
    await settle(tester);
    // Punjabi AM / PM, not English.
    final london = tester
        .widget<Text>(find.byKey(const ValueKey('city-London-time')))
        .data!;
    expect(london, matches(RegExp('ਪੂ.ਦੁ.|ਬਾ.ਦੁ.')));
    expect(london, isNot(matches(RegExp('AM|PM'))));
    Navigator.of(appContext(tester)).pop();
    await settle(tester);

    openClockTool(appContext(tester), ClockTool.sunAlarm);
    await settle(tester);
    final detail = tester
        .widget<Text>(find.byKey(const ValueKey('sun-alarm-detail')))
        .data!;
    expect(detail, isNot(contains('Sunrise')));
    expect(detail, isNot(matches(RegExp('AM|PM'))));
    expect(pa.tag, 'pa');
  });

  test('sun alarm notifications are re-worded (and re-timed) when the '
      'language changes', () async {
    final rig = profileRig(location: FakeLocationService());
    final c = rig.container;
    // Listened to, as the app does (SadhoApp watches it).
    c.listen(sunAlarmProvider, (_, _) {});
    await c.read(sunAlarmProvider.notifier).setEnabled(true);
    await Future<void>.delayed(Duration.zero);
    final en = rig.scheduler.alerts[sunAlarmGroup]!.first;
    c.read(languageProvider.notifier).set('mr');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final mr = rig.scheduler.alerts[sunAlarmGroup]!.first;
    final l = lookupAppLocalizations(const Locale('mr'));
    expect(mr.title, isNot(en.title));
    expect(mr.title, contains(l.sunEventSunrise));
    // Marathi writes the time with its own digits.
    expect(mr.body, matches(RegExp('[०-९]')));
  });

  test('a running timer re-words its notification in the new language',
      () async {
    final rig = profileRig();
    final c = rig.container;
    // Listened to, as the app does (the Clock tab's status line).
    c.listen(timerProvider, (_, _) {});
    c.read(timerProvider.notifier).start();
    await Future<void>.delayed(Duration.zero);
    c.read(languageProvider.notifier).set('ta');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final ta = lookupAppLocalizations(const Locale('ta'));
    expect(rig.scheduler.alerts[timerGroup]!.single.title,
        ta.timerFinishedTitle(ta.presetAarti));
  });

  test('the daily reminder is re-worded when the language changes', () async {
    final rig = profileRig();
    final c = rig.container;
    c.listen(dailyReminderProvider, (_, _) {}); // as SadhoApp does
    await c.read(dailyReminderProvider.notifier).setEnabled(true);
    await Future<void>.delayed(Duration.zero);
    final en = rig.scheduler.alerts[dailyReminderGroup]!.single;
    c.read(languageProvider.notifier).set('gu');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final gu = rig.scheduler.alerts[dailyReminderGroup]!.single;
    final l = lookupAppLocalizations(const Locale('gu'));
    expect(gu.body, l.sadhanaTimeNotifBody);
    expect(gu.body, isNot(en.body));
  });
}
