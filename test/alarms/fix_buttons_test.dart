import 'dart:io';

import 'package:advance_calendar/features/alarms/presentation/alarms_reliability_page.dart';
import 'package:advance_calendar/features/sadhana/application/completion_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile/profile_support.dart';
import '../sadhana/test_support.dart';

/// P5.1-3: every Fix button opens the right settings page (never nothing):
/// the specific page, then the app's notification settings, then its details
/// page; if none opens, written steps. Rows are re-checked on return.
void main() {
  setUp(resetStorage);

  late FakeAlarmHealth health;
  late FakeDnd dnd;

  Future<ProviderContainer> openPage(WidgetTester tester, FakeAlarmHealth h,
      {bool quiet = false}) async {
    health = h;
    dnd = FakeDnd(access: false);
    phoneScreen(tester, height: 1400);
    final c = ProviderContainer(
        overrides: testOverrides(alarmHealth: h, dnd: dnd));
    addTearDown(c.dispose);
    if (quiet) {
      c.read(completionSettingsProvider.notifier).setQuietDuringSession(true);
    }
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: AlarmsReliabilityPage()),
    ));
    await tester.pump();
    await tester.pump();
    return c;
  }

  String status(WidgetTester tester, String id) =>
      tester.widget<Text>(find.byKey(ValueKey('health-$id-status'))).data!;

  Future<void> fix(WidgetTester tester, String id) async {
    await tester.ensureVisible(find.byKey(ValueKey('health-$id-fix')));
    await tester.pump();
    await tester.tap(find.byKey(ValueKey('health-$id-fix')));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('each row\'s Fix calls its own fix, also when the row is OK',
      (tester) async {
    await openPage(tester, FakeAlarmHealth(), quiet: true);
    for (final id in ['notifications', 'exact', 'fullscreen', 'channel', 'battery']) {
      await fix(tester, id);
    }
    expect(health.fixes,
        ['notifications', 'exact', 'fullscreen', 'channel:null', 'battery']);
    await fix(tester, 'dnd');
    expect(dnd.settingsOpened, 1);
  });

  testWidgets('a turned-down alarm channel: the row says so; Fix opens it',
      (tester) async {
    await openPage(tester, FakeAlarmHealth(alarmChannel: false));
    expect(status(tester, 'channel'), 'Needs attention');
    await fix(tester, 'channel');
    expect(health.fixes, ['channel:sadhana_alarm_v2']);
  });

  testWidgets('nothing could be opened: written steps, not silence',
      (tester) async {
    await openPage(tester, FakeAlarmHealth(exactAlarms: false)..opens = false);
    await fix(tester, 'exact');
    expect(find.byKey(const ValueKey('health-manual-steps')), findsOneWidget);
    expect(find.textContaining('Settings › Apps › Sadho'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'OK'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('health-manual-steps')), findsNothing);
  });

  testWidgets('DND access page cannot open: written steps too', (tester) async {
    await openPage(tester, FakeAlarmHealth(), quiet: true);
    dnd.opens = false;
    await fix(tester, 'dnd');
    expect(find.byKey(const ValueKey('health-manual-steps')), findsOneWidget);
  });

  testWidgets('fixed in the settings: OK on return, without leaving the page',
      (tester) async {
    final h = FakeAlarmHealth(fullScreen: false);
    await openPage(tester, h);
    expect(status(tester, 'fullscreen'), 'Needs attention');
    h.fullScreen = true; // the user allowed it in the phone's settings
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();
    expect(status(tester, 'fullscreen'), 'OK');
  });

  test('native: every page, with the package, and the fallback chain', () {
    final kt = File('android/app/src/main/kotlin/in/sadho/app/MainActivity.kt')
        .readAsStringSync();
    for (final action in [
      'ACTION_APP_NOTIFICATION_SETTINGS',
      'ACTION_REQUEST_SCHEDULE_EXACT_ALARM',
      'ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT',
      'ACTION_CHANNEL_NOTIFICATION_SETTINGS',
      'ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS',
      'ACTION_APPLICATION_DETAILS_SETTINGS',
      'EXTRA_APP_PACKAGE',
      'EXTRA_CHANNEL_ID',
      'ActivityNotFoundException',
      'SecurityException',
    ]) {
      expect(kt, contains(action), reason: action);
    }
    expect(kt, contains('Uri.parse("package:\$packageName")'));
  });
}
