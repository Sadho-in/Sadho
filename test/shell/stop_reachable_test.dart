import 'dart:io';

import 'package:advance_calendar/app.dart';
import 'package:advance_calendar/features/alarms/application/ring_controller.dart';
import 'package:advance_calendar/features/alarms/services/alarm_ring.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/sadhana/presentation/focus_mode_screen.dart';
import 'package:advance_calendar/features/sadhana/services/feedback_service.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile/profile_support.dart';
import '../sadhana/test_support.dart';

/// P5.1-7: Stop is always reachable. While an alarm rings, or a finished
/// session is not acknowledged, a Stop is on screen: a banner on every tab,
/// the Sadhana screen's main button, Focus mode. It survives the app being
/// recreated (the ring's state is read back from the phone). One tap stops
/// sound, vibration and notification everywhere.
void main() {
  late FakeAlarmRing ring;
  late FakeFeedback feedback;

  Future<ProfileRig> open(WidgetTester tester) async {
    feedback = FakeFeedback();
    final rig = profileRig(saved: {
      'onboarding.done': true
    }, extra: [
      alarmRingProvider.overrideWithValue(ring),
    ]);
    // The rig's own feedback fake: the one the controller stops.
    feedback = rig.container.read(feedbackServiceProvider) as FakeFeedback;
    phoneScreen(tester, height: 2400);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: rig.container, child: const SadhoApp()));
    await tester.pump();
    await tester.pump();
    return rig;
  }

  final banner = find.byKey(const ValueKey('ring-banner'));
  final bannerStop = find.byKey(const ValueKey('ring-banner-stop'));
  final mainStop = find.byKey(const ValueKey('stop-alert'));

  ShellTab tab(ProfileRig rig) => rig.container.read(shellTabProvider);

  testWidgets(
      'after a recreate (unlocked with the PIN, ring silenced, not acknowledged): '
      'the app opens on Sadhana with Stop visible', (tester) async {
    ring = FakeAlarmRing()
      ..state = const RingState(unacknowledged: true, group: sadhanaTimerGroup);
    final rig = await open(tester);
    expect(tab(rig), ShellTab.sadhana);
    expect(banner, findsOneWidget);
    expect(find.text('Sadhana complete 🙏'), findsOneWidget);
    expect(mainStop, findsOneWidget, reason: 'the Sadhana screen\'s main button');
  });

  testWidgets('while ringing: the banner on every tab', (tester) async {
    ring = FakeAlarmRing()..ring(malaGroup);
    final rig = await open(tester);
    for (final t in ShellTab.values) {
      rig.container.read(shellTabProvider.notifier).select(t);
      await tester.pump();
      expect(banner, findsOneWidget, reason: t.label);
    }
  });

  testWidgets('it rings while the app is open: the banner appears at once',
      (tester) async {
    ring = FakeAlarmRing();
    final rig = await open(tester);
    expect(banner, findsNothing);
    ring.ring(sadhanaTimerGroup);
    await tester.pump();
    expect(banner, findsOneWidget);
    expect(tab(rig), ShellTab.sadhana);
  });

  testWidgets('Focus mode shows Stop while ringing', (tester) async {
    ring = FakeAlarmRing()..ring(sadhanaTimerGroup);
    final rig = await open(tester);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: rig.container,
        child: const MaterialApp(home: FocusModeScreen())));
    await tester.pump();
    await tester.pump();
    expect(mainStop, findsOneWidget);
  });

  testWidgets('one Stop silences everything and acknowledges', (tester) async {
    ring = FakeAlarmRing()..ring(sadhanaTimerGroup);
    final rig = await open(tester);
    await tester.tap(bannerStop);
    await tester.pump();
    await tester.pump();
    expect(ring.stops, 1, reason: 'the phone: sound, vibration, notification');
    expect(feedback.alertStops, greaterThanOrEqualTo(1), reason: 'the app');
    expect(ring.state.ringing, isFalse);
    expect(ring.state.unacknowledged, isFalse);
    expect(banner, findsNothing);
    expect(mainStop, findsNothing);
    expect(rig.container.read(ringControllerProvider).showStop, isFalse);
  });

  testWidgets('the Sadhana screen\'s Stop does the same', (tester) async {
    ring = FakeAlarmRing()..ring(sadhanaTimerGroup);
    await open(tester);
    await tester.ensureVisible(mainStop);
    await tester.tap(mainStop);
    await tester.pump();
    await tester.pump();
    expect(ring.stops, 1);
    expect(banner, findsNothing);
  });

  testWidgets('a Clock timer: banner while ringing, gone once silenced',
      (tester) async {
    ring = FakeAlarmRing()..ring(timerGroup);
    await open(tester);
    expect(find.text('Timer finished'), findsOneWidget);
    ring.unlock();
    await tester.pump();
    expect(banner, findsNothing,
        reason: 'only a Sadhana finish waits to be acknowledged');
  });

  group('native (read as text)', () {
    test('a recreated activity does not replay the alarm intent', () {
      final kt = File('android/app/src/main/kotlin/in/sadho/app/MainActivity.kt')
          .readAsStringSync();
      expect(kt, contains('if (savedInstanceState == null) takeAlarmIntent(intent)'));
    });

    test('every handleable configuration change is handled (no recreate)', () {
      final manifest =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      final changes = RegExp(r'android:configChanges="([^"]+)"')
          .firstMatch(manifest)!
          .group(1)!
          .split('|');
      expect(
          changes,
          containsAll([
            'orientation', 'keyboardHidden', 'keyboard', 'screenSize',
            'smallestScreenSize', 'locale', 'layoutDirection', 'fontScale',
            'screenLayout', 'density', 'uiMode', 'navigation', 'touchscreen',
            'colorMode', 'mcc', 'mnc', 'fontWeightAdjustment',
            'grammaticalGender',
          ]));
      expect(manifest, isNot(contains('showWhenLocked')));
    });
  });
}
