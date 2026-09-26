import 'dart:io';

import 'package:advance_calendar/app.dart';
import 'package:advance_calendar/features/alarms/services/alarm_ring.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/shell/application/alarm_screen_provider.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile/profile_support.dart';
import '../sadhana/test_support.dart';

/// P5.1-2: the lock-screen alarm screen shows every time. While the phone's
/// ring is going, a moment in the background (the screen turning on, the
/// keyguard) no longer closes it; it closes when the ring stops, on Stop, or
/// once the phone is unlocked. Still ONLY the finished screen is shown.
void main() {
  late FakeLockScreen lock;
  late FakeAlarmRing ring;

  Future<ProfileRig> open(WidgetTester tester, {required bool ringing}) async {
    lock = FakeLockScreen(locked: true, launch: sadhanaTimerGroup);
    ring = FakeAlarmRing();
    if (ringing) ring.ring(sadhanaTimerGroup);
    final rig = profileRig(
        saved: {'onboarding.done': true},
        lockScreen: lock,
        extra: [alarmRingProvider.overrideWithValue(ring)]);
    phoneScreen(tester, height: 2400);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: rig.container, child: const SadhoApp()));
    await tester.pump();
    await tester.pump();
    return rig;
  }

  void away(WidgetTester tester) {
    for (final s in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
  }

  void back(WidgetTester tester) {
    for (final s in [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
  }

  final finished = find.byKey(const ValueKey('alarm-finished-screen'));
  String? alarm(ProfileRig rig) => rig.container.read(alarmScreenProvider);

  testWidgets('ringing: a pause while the screen turns on keeps the screen',
      (tester) async {
    final rig = await open(tester, ringing: true);
    away(tester);
    await tester.pump();
    expect(alarm(rig), sadhanaTimerGroup);
    expect(lock.showing, isTrue);
    back(tester);
    await tester.pump();
    await tester.pump();
    expect(finished, findsOneWidget);
    expect(find.byType(AppShell), findsNothing,
        reason: 'still only the finished screen over the lock screen');
  });

  testWidgets('the ring stopping while away closes it', (tester) async {
    final rig = await open(tester, ringing: true);
    away(tester);
    await tester.pump();
    await ring.stop(); // e.g. Stop in the notification
    await tester.pump();
    expect(lock.showing, isFalse);
    expect(alarm(rig), isNull);
  });

  testWidgets('not ringing: leaving closes it at once (as before)',
      (tester) async {
    final rig = await open(tester, ringing: false);
    away(tester);
    await tester.pump();
    expect(lock.showing, isFalse);
    expect(alarm(rig), isNull);
  });

  testWidgets('unlocked from the keyguard meanwhile: the app opens normally',
      (tester) async {
    final rig = await open(tester, ringing: true);
    away(tester);
    await tester.pump();
    lock.locked = false;
    ring.unlock();
    back(tester);
    await tester.pump();
    await tester.pump();
    expect(alarm(rig), isNull);
    expect(lock.showing, isFalse);
    expect(find.byType(AppShell), findsOneWidget);
  });

  group('native (read as text)', () {
    test('the ring service starts the alarm screen itself when allowed', () {
      final ringer = File('android/app/src/main/kotlin/in/sadho/app/AlarmRinger.kt')
          .readAsStringSync();
      expect(ringer, contains('canUseFullScreenIntent()'));
      expect(ringer, contains('startActivity(alarmScreenIntent('));
      expect(ringer, contains('isKeyguardLocked'));
    });

    test('Fix for full-screen alarms opens its own settings page', () {
      final activity =
          File('android/app/src/main/kotlin/in/sadho/app/MainActivity.kt')
              .readAsStringSync();
      expect(activity, contains('ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT'));
      final health = File('lib/features/alarms/services/alarm_health.dart')
          .readAsStringSync();
      expect(health, contains("openSettings('fullscreen')"));
    });
  });
}
