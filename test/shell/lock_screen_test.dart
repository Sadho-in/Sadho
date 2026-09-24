import 'dart:io';

import 'package:advance_calendar/app.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/profile/presentation/profile_screen.dart';
import 'package:advance_calendar/features/sadhana/services/feedback_service.dart';
import 'package:advance_calendar/features/shell/application/alarm_screen_provider.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../profile/profile_support.dart';
import '../sadhana/test_support.dart';

/// The app shows over the lock screen ONLY when an alarm opens it while the
/// phone is locked, and then only a small "finished" screen. Leaving that
/// screen in any way switches it off first; the rest of the app needs the
/// phone unlocked.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('the manifest never lets the whole app show over the lock screen', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, isNot(contains('showWhenLocked')));
    expect(manifest, isNot(contains('turnScreenOn')));
  });

  late FakeLockScreen lock;

  Future<ProfileRig> open(WidgetTester tester, FakeLockScreen l) async {
    lock = l;
    final rig = profileRig(saved: {'onboarding.done': true}, lockScreen: l);
    phoneScreen(tester, height: 2400);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: rig.container, child: const SadhoApp()));
    await tester.pump();
    await tester.pump();
    return rig;
  }

  final finished = find.byKey(const ValueKey('alarm-finished-screen'));
  final appShell = find.byType(AppShell); // on screen only (skips offstage)

  String? alarm(ProfileRig rig) => rig.container.read(alarmScreenProvider);

  group('opened normally', () {
    testWidgets('never shows over the lock screen, locked or not',
        (tester) async {
      for (final locked in [false, true]) {
        final rig = await open(tester, FakeLockScreen(locked: locked));
        expect(lock.showing, isFalse);
        expect(lock.changes, isNot(contains(true)));
        expect(alarm(rig), isNull);
        expect(finished, findsNothing);
        expect(appShell, findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      }
    });
  });

  group('opened by an alarm', () {
    for (final group in [sadhanaTimerGroup, timerGroup, sunAlarmGroup]) {
      testWidgets('$group while locked: only the finished screen, over the '
          'lock screen', (tester) async {
        final rig = await open(tester, FakeLockScreen(locked: true, launch: group));
        expect(lock.showing, isTrue);
        expect(alarm(rig), group);
        expect(finished, findsOneWidget);
        expect(appShell, findsNothing, reason: 'the app itself is not shown');
        expect(find.byTooltip('Profile'), findsNothing);
        expect(find.byKey(const ValueKey('alarm-stop')), findsOneWidget);
        expect(find.byKey(const ValueKey('alarm-unlock')), findsOneWidget);
      });
    }

    testWidgets('while unlocked: opens normally, switched off', (tester) async {
      final rig = await open(
          tester, FakeLockScreen(locked: false, launch: sadhanaTimerGroup));
      expect(lock.showing, isFalse);
      expect(alarm(rig), isNull);
      expect(finished, findsNothing);
      expect(appShell, findsOneWidget);
    });

    testWidgets('a notification that is not an alarm never shows it',
        (tester) async {
      final rig = await open(tester, FakeLockScreen(locked: true, launch: 'daily-sadhana'));
      expect(lock.showing, isFalse);
      expect(alarm(rig), isNull);
    });

    testWidgets('an alarm arriving while the app runs (locked): the finished '
        'screen', (tester) async {
      final rig = await open(tester, FakeLockScreen(locked: true));
      expect(alarm(rig), isNull);
      lock.alarmOpens(timerGroup);
      await tester.pump();
      await tester.pump();
      expect(lock.showing, isTrue);
      expect(finished, findsOneWidget);
    });

    testWidgets('the Sadhana result is shown', (tester) async {
      await open(tester, FakeLockScreen(locked: true, launch: sadhanaTimerGroup));
      expect(find.text('Sadhana complete 🙏'), findsOneWidget);
      expect(find.byKey(const ValueKey('alarm-result')), findsOneWidget);
    });
  });

  group('leaving the finished screen switches it off first', () {
    testWidgets('Stop: silences the alarm, closes, the phone stays locked',
        (tester) async {
      final rig = await open(
          tester, FakeLockScreen(locked: true, launch: sadhanaTimerGroup));
      final fb = rig.container.read(feedbackServiceProvider) as FakeFeedback;
      await tester.tap(find.byKey(const ValueKey('alarm-stop')));
      await tester.pump();
      expect(fb.alertStops, 1);
      expect(rig.scheduler.dismissed, contains(sadhanaTimerGroup));
      expect(lock.showing, isFalse);
      expect(lock.unlockRequests, 0);
      expect(lock.locked, isTrue);
      expect(alarm(rig), isNull);
      expect(finished, findsNothing);
    });

    testWidgets('Unlock: asks the phone to unlock FIRST, then switches off and '
        'opens the right tab', (tester) async {
      final rig = await open(
          tester, FakeLockScreen(locked: true, launch: sadhanaTimerGroup));
      await tester.tap(find.byKey(const ValueKey('alarm-unlock')));
      await tester.pump();
      expect(lock.unlockRequests, 1);
      expect(lock.changes.last, isFalse);
      expect(lock.showing, isFalse);
      expect(appShell, findsOneWidget);
      expect(rig.container.read(shellTabProvider), ShellTab.sadhana);
    });

    testWidgets('Unlock for the Clock timer opens the Clock tab', (tester) async {
      final rig = await open(tester, FakeLockScreen(locked: true, launch: timerGroup));
      await tester.tap(find.byKey(const ValueKey('alarm-unlock')));
      await tester.pump();
      expect(rig.container.read(shellTabProvider), ShellTab.clock);
    });

    testWidgets('unlock cancelled: still switched off; the lock screen stays',
        (tester) async {
      final rig = await open(tester,
          FakeLockScreen(locked: true, launch: timerGroup, unlockSucceeds: false));
      await tester.tap(find.byKey(const ValueKey('alarm-unlock')));
      await tester.pump();
      expect(lock.unlockRequests, 1);
      expect(lock.showing, isFalse);
      expect(lock.locked, isTrue);
      expect(alarm(rig), isNull);
    });

    testWidgets('leaving the app (screen off, switching away)', (tester) async {
      final rig = await open(tester, FakeLockScreen(locked: true, launch: sunAlarmGroup));
      for (final s in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(s);
      }
      await tester.pump();
      expect(lock.showing, isFalse);
      expect(alarm(rig), isNull);
      for (final s in [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(s);
      }
      await tester.pump();
      expect(lock.showing, isFalse, reason: 'coming back is a normal opening');
      expect(finished, findsNothing);
    });

    testWidgets('the back button', (tester) async {
      final rig = await open(
          tester, FakeLockScreen(locked: true, launch: sadhanaTimerGroup));
      // Something was open in the app underneath: back must not touch it.
      rig.container.read(shellTabProvider.notifier).select(ShellTab.home);
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(lock.showing, isFalse);
      expect(alarm(rig), isNull);
      expect(find.byType(ProfilePage), findsNothing);
    });
  });

  test('only the three alarm groups can use the lock screen', () {
    expect(lockScreenAlarmGroups, {sadhanaTimerGroup, timerGroup, sunAlarmGroup});
    expect(lockScreenAlarmGroups, isNot(contains(dailyReminderGroup)));
  });

}
