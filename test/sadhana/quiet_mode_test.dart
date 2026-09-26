import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/alarms/presentation/alarms_reliability_page.dart';
import 'package:advance_calendar/features/sadhana/application/completion_settings_provider.dart';
import 'package:advance_calendar/features/sadhana/application/quiet_mode_provider.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/completion_settings_card.dart';
import 'package:advance_calendar/features/sadhana/services/dnd_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:advance_calendar/app.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';

import '../profile/profile_support.dart' show profileRig, phoneScreen;
import 'test_support.dart';

/// P5-6: quiet mode during sadhana. With the switch on and Do Not Disturb
/// access, a session sets alarms-only; every stop path, and the next app
/// start after a crash, puts the user's own setting back. Never touched when
/// the switch is off or access is missing.
void main() {
  late FakeDnd dnd;
  late FakeVolume volume;

  setUp(() {
    resetStorage();
    dnd = FakeDnd();
    volume = FakeVolume();
  });

  ProviderContainer make({bool quiet = true}) {
    final c = ProviderContainer(overrides: testOverrides(dnd: dnd, volume: volume));
    addTearDown(c.dispose);
    if (quiet) c.read(completionSettingsProvider.notifier).setQuietDuringSession(true);
    c.read(quietModeProvider); // alive, as in the app shell
    return c;
  }

  SadhanaSessionNotifier n(ProviderContainer c) =>
      c.read(sadhanaSessionProvider.notifier);

  /// A Mala session (keys counted in the app), running.
  Future<void> start(ProviderContainer c, {int target = 108}) async {
    n(c)
      ..setTargetCount(target)
      ..setMode(CountMode.mala)
      ..toggleRunning();
    await pumpEventQueue();
  }

  test('off by default', () {
    final c = make(quiet: false);
    expect(c.read(completionSettingsProvider).quietDuringSession, isFalse);
  });

  test('the switch persists', () {
    final c = make();
    expect(AppStorage.settings.get('completion.quietDuringSession'), isTrue);
    final again = ProviderContainer();
    addTearDown(again.dispose);
    expect(again.read(completionSettingsProvider).quietDuringSession, isTrue);
    c.read(completionSettingsProvider.notifier).setQuietDuringSession(false);
  });

  test('a session starting sets alarms only', () async {
    final c = make();
    await start(c);
    expect(dnd.filter, DndFilter.alarms);
    expect(c.read(quietModeProvider), isTrue);
    expect(AppStorage.settings.get(QuietModeNotifier.savedKey), DndFilter.all);
  });

  group('restored in every stop path', () {
    test('Pause', () async {
      final c = make();
      await start(c);
      n(c).toggleRunning();
      await pumpEventQueue();
      expect(dnd.filter, DndFilter.all);
      expect(c.read(quietModeProvider), isFalse);
      expect(AppStorage.settings.get(QuietModeNotifier.savedKey), isNull);
    });

    test('completion', () async {
      final c = make();
      await start(c, target: 2);
      volume
        ..press()
        ..press();
      await pumpEventQueue();
      expect(c.read(sadhanaSessionProvider).completed, isTrue);
      expect(dnd.filter, DndFilter.all);
    });

    test('Reset', () async {
      final c = make();
      await start(c);
      volume.press();
      n(c).reset();
      await pumpEventQueue();
      expect(dnd.filter, DndFilter.all);
    });

    test('leaving the Sadhana screen', () async {
      final c = make();
      await start(c);
      await c.read(quietModeProvider.notifier).leftSadhana();
      expect(dnd.filter, DndFilter.all);
    });

    test('switching quiet mode off mid-session', () async {
      final c = make();
      await start(c);
      c.read(completionSettingsProvider.notifier).setQuietDuringSession(false);
      await pumpEventQueue();
      expect(dnd.filter, DndFilter.all);
    });

    test('Priority only comes back as Priority only', () async {
      dnd.filter = DndFilter.priority;
      final c = make();
      await start(c);
      expect(dnd.filter, DndFilter.alarms);
      n(c).pause();
      await pumpEventQueue();
      expect(dnd.filter, DndFilter.priority);
    });
  });

  test('after a crash: restored at the next app start', () async {
    final first = ProviderContainer(overrides: testOverrides(dnd: dnd, volume: volume));
    first.read(completionSettingsProvider.notifier).setQuietDuringSession(true);
    first.read(quietModeProvider);
    await start(first);
    expect(dnd.filter, DndFilter.alarms);
    // Killed: nothing ran. (Its dispose below restores nothing either.)
    first.dispose();
    expect(dnd.filter, DndFilter.alarms);
    final second = make();
    await pumpEventQueue();
    expect(dnd.filter, DndFilter.all);
    expect(second.read(quietModeProvider), isFalse);
    expect(AppStorage.settings.get(QuietModeNotifier.savedKey), isNull);
  });

  group('left alone', () {
    test('when the switch is off', () async {
      final c = make(quiet: false);
      await start(c);
      n(c).pause();
      await pumpEventQueue();
      expect(dnd.sets, isEmpty);
    });

    test('without Do Not Disturb access', () async {
      dnd.access = false;
      final c = make();
      await start(c);
      n(c).pause();
      await pumpEventQueue();
      expect(dnd.sets, isEmpty);
      expect(AppStorage.settings.get(QuietModeNotifier.savedKey), isNull);
    });

    test('where there is no Do Not Disturb (not Android)', () async {
      dnd.supported = false;
      final c = make();
      await start(c);
      expect(dnd.sets, isEmpty);
    });

    test('when the user is already on alarms only or total silence', () async {
      for (final f in [DndFilter.alarms, DndFilter.none]) {
        dnd
          ..filter = f
          ..sets.clear();
        final c = make();
        await start(c);
        n(c).pause();
        await pumpEventQueue();
        expect(dnd.sets, isEmpty, reason: 'filter $f');
        expect(dnd.filter, f);
      }
    });

    test('when the user changed Do Not Disturb themselves meanwhile', () async {
      final c = make();
      await start(c);
      dnd.filter = DndFilter.none; // the user chose total silence
      n(c).pause();
      await pumpEventQueue();
      expect(dnd.filter, DndFilter.none);
      expect(AppStorage.settings.get(QuietModeNotifier.savedKey), isNull);
    });
  });

  group('on screen', () {
    Future<ProviderContainer> pumpCard(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = ProviderContainer(overrides: testOverrides(dnd: dnd, volume: volume));
      addTearDown(c.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: CompletionSettingsCard()),
          ),
        ),
      ));
      return c;
    }

    final toggle = find.byKey(const ValueKey('quiet-during-session'));

    testWidgets('the switch is in the Completion card, off', (tester) async {
      final c = await pumpCard(tester);
      expect(toggle, findsOneWidget);
      expect(find.text('Silence other notifications during a session'),
          findsOneWidget);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(c.read(completionSettingsProvider).quietDuringSession, isTrue);
      expect(find.byType(AlertDialog), findsNothing, reason: 'access is there');
    });

    testWidgets('not shown where there is no Do Not Disturb', (tester) async {
      dnd.supported = false;
      await pumpCard(tester);
      expect(toggle, findsNothing);
    });

    testWidgets('without access: explained once, then the settings page',
        (tester) async {
      dnd.access = false;
      final c = await pumpCard(tester);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(find.text('Allow Do Not Disturb access'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('quiet-open-settings')));
      await tester.pumpAndSettle();
      expect(dnd.settingsOpened, 1);
      // Off and on again: straight to the settings page, no second explanation.
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(dnd.settingsOpened, 2);
      expect(c.read(completionSettingsProvider).quietDuringSession, isTrue);
    });

    testWidgets('Alarms & reliability has a row for it only while it is on',
        (tester) async {
      dnd.access = false;
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = ProviderContainer(overrides: testOverrides(dnd: dnd, volume: volume));
      addTearDown(c.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: AlarmsReliabilityPage()),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('health-dnd')), findsNothing);
      c.read(completionSettingsProvider.notifier).setQuietDuringSession(true);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('health-dnd')), findsOneWidget);
      expect(find.text('Do Not Disturb access'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('health-dnd-fix')));
      await tester.pumpAndSettle();
      expect(dnd.settingsOpened, 1);
      dnd.access = true;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(
          tester.widget<Text>(find.byKey(const ValueKey('health-dnd-status'))).data,
          'OK');
    });
  });

  testWidgets('in the app: leaving the Sadhana tab restores it', (tester) async {
    final rig = profileRig(
        saved: {'onboarding.done': true, 'completion.quietDuringSession': true},
        extra: [dndDriverProvider.overrideWithValue(dnd)]);
    phoneScreen(tester, height: 2400);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: rig.container, child: const SadhoApp()));
    await tester.pump();
    rig.container.read(shellTabProvider.notifier).select(ShellTab.sadhana);
    await tester.pump();
    rig.container.read(sadhanaSessionProvider.notifier)
      ..setMode(CountMode.mala)
      ..toggleRunning();
    await tester.pump();
    await tester.pump();
    expect(dnd.filter, DndFilter.alarms);
    rig.container.read(shellTabProvider.notifier).select(ShellTab.home);
    await tester.pump();
    await tester.pump();
    expect(dnd.filter, DndFilter.all);
    rig.container.read(sadhanaSessionProvider.notifier).pause();
    await tester.pumpWidget(const SizedBox());
  });
}
