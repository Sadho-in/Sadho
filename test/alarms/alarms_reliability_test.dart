import 'package:advance_calendar/app.dart';
import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/alarms/presentation/alarms_reliability_page.dart';
import 'package:advance_calendar/features/alarms/services/alarm_health.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/application/session_notice_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../profile/profile_support.dart';
import '../sadhana/test_support.dart';

/// "Alarms & reliability": one row per thing the phone must allow, each with
/// a live status and a Fix button that opens the right settings page; and the
/// one-time explainer the first time a session will ring like an alarm.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(resetStorage);

  late FakeAlarmHealth health;

  Future<ProviderContainer> openPage(WidgetTester tester, FakeAlarmHealth h) async {
    health = h;
    phoneScreen(tester, height: 900);
    final c = ProviderContainer(overrides: testOverrides(alarmHealth: h));
    addTearDown(c.dispose);
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

  const rows = ['notifications', 'exact', 'fullscreen', 'battery'];

  group('the page', () {
    testWidgets('all fine: four rows, all OK', (tester) async {
      await openPage(tester, FakeAlarmHealth());
      for (final id in rows) {
        await tester.ensureVisible(find.byKey(ValueKey('health-$id')));
        expect(status(tester, id), 'OK', reason: id);
      }
    });

    for (final id in rows) {
      testWidgets('$id refused: Needs attention; Fix opens its settings page',
          (tester) async {
        await openPage(
            tester,
            FakeAlarmHealth(
              notifications: id != 'notifications',
              exactAlarms: id != 'exact',
              fullScreen: id != 'fullscreen',
              battery: id != 'battery',
            ));
        await tester.ensureVisible(find.byKey(ValueKey('health-$id')));
        expect(status(tester, id), 'Needs attention');
        for (final other in rows.where((r) => r != id)) {
          expect(status(tester, other), 'OK');
        }
        await tester.ensureVisible(find.byKey(ValueKey('health-$id-fix')));
        await tester.pump();
        await tester.tap(find.byKey(ValueKey('health-$id-fix')));
        await tester.pump();
        expect(health.fixes, [id]);
      });
    }

    testWidgets('statuses refresh on coming back from the settings',
        (tester) async {
      await openPage(tester, FakeAlarmHealth(exactAlarms: false));
      expect(status(tester, 'exact'), 'Needs attention');
      health.exactAlarms = true; // allowed in the settings
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump();
      expect(status(tester, 'exact'), 'OK');
    });

    testWidgets('a Fix answered in place (a dialog) refreshes too',
        (tester) async {
      await openPage(tester, FakeAlarmHealth(notifications: false));
      final before = health.checks;
      health.notifications = true;
      await tester.tap(find.byKey(const ValueKey('health-notifications-fix')));
      await tester.pump();
      await tester.pump();
      expect(health.checks, greaterThan(before));
      expect(status(tester, 'notifications'), 'OK');
    });

    testWidgets('Samsung: the battery row says how to leave "Sleeping apps"',
        (tester) async {
      await openPage(tester, FakeAlarmHealth(samsung: true, battery: false));
      expect(find.textContaining('Sleeping apps'), findsOneWidget);
    });

    testWidgets('not Samsung: no Samsung hint', (tester) async {
      await openPage(tester, FakeAlarmHealth());
      expect(find.textContaining('Sleeping apps'), findsNothing);
    });

    testWidgets('iPhone: only the notifications row', (tester) async {
      await openPage(tester, FakeAlarmHealth(android: false));
      expect(find.byKey(const ValueKey('health-notifications')), findsOneWidget);
      for (final id in ['exact', 'fullscreen', 'battery']) {
        expect(find.byKey(ValueKey('health-$id')), findsNothing);
      }
    });
  });

  group('the Profile entry', () {
    Future<void> card(WidgetTester tester, FakeAlarmHealth h) async {
      final c = ProviderContainer(overrides: testOverrides(alarmHealth: h));
      addTearDown(c.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: Scaffold(body: AlarmsReliabilityCard())),
      ));
      await tester.pump();
      await tester.pump();
    }

    testWidgets('shows the overall status and opens the page', (tester) async {
      await card(tester, FakeAlarmHealth(battery: false));
      expect(find.text('Something needs attention'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('alarms-reliability-entry')));
      await tester.pumpAndSettle();
      expect(find.byType(AlarmsReliabilityPage), findsOneWidget);
    });

    testWidgets('all fine', (tester) async {
      await card(tester, FakeAlarmHealth());
      expect(find.text('Everything is set for alarms to ring on time'), findsOneWidget);
    });

    testWidgets('is on the Profile page', (tester) async {
      await openProfile(tester);
      await tester.pump();
      expect(find.byKey(const ValueKey('alarms-reliability-entry')), findsOneWidget);
    });
  });

  group('battery status from the phone', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('sadho/alarm');

    Future<AlarmHealthStatus> checkWith(Map<String, Object?> battery) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'batteryStatus') return battery;
        if (call.method == 'canUseFullScreenIntent') return true;
        return null;
      });
      addTearDown(() => TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null));
      return DeviceAlarmHealth(_AndroidScheduler()).check();
    }

    test('"Restricted" needs attention on every phone', () async {
      final s = await checkWith({'restricted': true, 'unrestricted': false, 'samsung': false});
      expect(s.battery, isFalse);
    });

    test('"Optimized" is fine on most phones', () async {
      final s = await checkWith({'restricted': false, 'unrestricted': false, 'samsung': false});
      expect(s.battery, isTrue);
    });

    test('...but not on Samsung, which wants "Unrestricted"', () async {
      final s = await checkWith({'restricted': false, 'unrestricted': false, 'samsung': true});
      expect(s.battery, isFalse);
      expect(s.samsung, isTrue);
      final ok = await checkWith({'restricted': false, 'unrestricted': true, 'samsung': true});
      expect(ok.battery, isTrue);
    });
  });

  group('the one-time explainer', () {
    final attention = FakeAlarmHealth(battery: false);

    ProviderContainer session(FakeAlarmHealth h, {FakeScheduler? scheduler}) {
      final c = ProviderContainer(overrides: [
        ...testOverrides(alarmHealth: h),
        reminderSchedulerProvider.overrideWithValue(scheduler ?? FakeScheduler()),
      ]);
      addTearDown(c.dispose);
      return c;
    }

    Future<void> startTime(ProviderContainer c) async {
      c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.rhythm)
        ..setTargetType(TargetType.time)
        ..setTargetSeconds(600)
        ..toggleRunning();
      await pumpEventQueue();
    }

    test('first TIME session, all fine: a short note, no button', () async {
      final c = session(FakeAlarmHealth());
      await startTime(c);
      final n = c.read(sessionNoticeProvider)!;
      expect(n.message, contains('ring like an alarm'));
      expect(n.openAlarmsPage, isFalse);
      c.read(sadhanaSessionProvider.notifier).pause();
    });

    test('something needs attention: a button to Alarms & reliability', () async {
      final c = session(attention);
      await startTime(c);
      final n = c.read(sessionNoticeProvider)!;
      expect(n.openAlarmsPage, isTrue);
      expect(n.actionLabel, 'Check');
      c.read(sadhanaSessionProvider.notifier).pause();
    });

    test('first Rhythm COUNT session also explains', () async {
      final c = session(FakeAlarmHealth());
      c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.rhythm)
        ..setRhythmSeconds(60)
        ..toggleRunning();
      await pumpEventQueue();
      expect(c.read(sessionNoticeProvider), isNotNull);
      c.read(sadhanaSessionProvider.notifier).pause();
    });

    test('a Tap COUNT session never does (no alarm)', () async {
      final c = session(FakeAlarmHealth());
      c.read(sadhanaSessionProvider.notifier).tap();
      await pumpEventQueue();
      expect(c.read(sessionNoticeProvider), isNull);
      expect(AppStorage.settings.get(SadhanaSessionNotifier.alarmExplainedKey), isNull);
    });

    test('only once, ever', () async {
      final c = session(FakeAlarmHealth());
      await startTime(c);
      final first = c.read(sessionNoticeProvider);
      c.read(sadhanaSessionProvider.notifier).pause();
      c.dispose();
      final again = session(FakeAlarmHealth());
      await startTime(again);
      expect(again.read(sessionNoticeProvider), isNot(same(first)));
      expect(again.read(sessionNoticeProvider), isNull);
      again.read(sadhanaSessionProvider.notifier).pause();
    });

    test('notifications refused: still explained, with the button', () async {
      final c = session(FakeAlarmHealth(notifications: false),
          scheduler: FakeScheduler(permission: false));
      await startTime(c);
      await pumpEventQueue();
      expect(c.read(sessionNoticeProvider)!.openAlarmsPage, isTrue);
      c.read(sadhanaSessionProvider.notifier).pause();
    });

    testWidgets('the button opens the page', (tester) async {
      final rig = profileRig(saved: {'onboarding.done': true});
      phoneScreen(tester, height: 2400);
      await tester.pumpWidget(UncontrolledProviderScope(
          container: rig.container, child: const SadhoApp()));
      await tester.pump();
      rig.container.read(sessionNoticeProvider.notifier).show('x',
          actionLabel: 'Check', openAlarmsPage: true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      expect(find.byType(AlarmsReliabilityPage), findsOneWidget);
    });
  });
}

/// A supported scheduler on an Android phone with exact alarms allowed.
class _AndroidScheduler extends FakeScheduler {}
