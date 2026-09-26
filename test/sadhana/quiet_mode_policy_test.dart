import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/sadhana/application/completion_settings_provider.dart';
import 'package:advance_calendar/features/sadhana/application/quiet_mode_provider.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/application/session_notice_provider.dart';
import 'package:advance_calendar/features/sadhana/presentation/sadhana_screen.dart';
import 'package:advance_calendar/features/sadhana/services/dnd_driver.dart';
import 'package:advance_calendar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

/// P5.1-4: quiet mode applies the filter AND the policy (no priority senders,
/// no pop-ups / status-bar icons / lights), reads them back, says so when it
/// did not apply, restores both exactly in every stop path, and covers a Tap
/// count target (from the first tap).
void main() {
  late FakeDnd dnd;
  late FakeVolume volume;

  setUp(() {
    resetStorage();
    dnd = FakeDnd();
    volume = FakeVolume();
  });

  ProviderContainer make() {
    final c = ProviderContainer(overrides: testOverrides(dnd: dnd, volume: volume));
    addTearDown(c.dispose);
    c.read(completionSettingsProvider.notifier).setQuietDuringSession(true);
    c.read(quietModeProvider);
    return c;
  }

  SadhanaSessionNotifier n(ProviderContainer c) =>
      c.read(sadhanaSessionProvider.notifier);

  Future<void> startMala(ProviderContainer c, {int target = 108}) async {
    n(c)
      ..setTargetCount(target)
      ..setMode(CountMode.mala)
      ..toggleRunning();
    await pumpEventQueue();
  }

  void expectRestored() {
    expect(dnd.filter, DndFilter.all);
    expect(dnd.policy, FakeDnd.userPolicy);
    expect(AppStorage.settings.get(QuietModeNotifier.savedKey), isNull);
    expect(AppStorage.settings.get(QuietModeNotifier.savedPolicyKey), isNull);
  }

  test('a session saves the user\'s filter AND policy, then sets both', () async {
    final c = make();
    await startMala(c);
    expect(dnd.filter, DndFilter.alarms);
    expect(dnd.policy, quietPolicy);
    expect(quietPolicy['categories'], DndPolicyBits.categoryAlarms,
        reason: 'no calls, messages, repeat callers or conversations');
    expect(quietPolicy['suppressed']! & DndPolicyBits.effectPeek, isNot(0));
    expect(quietPolicy['suppressed']! & DndPolicyBits.effectStatusBar, isNot(0));
    expect(quietPolicy['suppressed']! & DndPolicyBits.effectLights, isNot(0));
    expect(AppStorage.settings.get(QuietModeNotifier.savedKey), DndFilter.all);
    expect(AppStorage.settings.get(QuietModeNotifier.savedPolicyKey),
        FakeDnd.userPolicy);
    expect(c.read(quietModeProvider), isTrue);
  });

  group('both restored exactly', () {
    test('Pause', () async {
      final c = make();
      await startMala(c);
      n(c).toggleRunning();
      await pumpEventQueue();
      expectRestored();
    });

    test('completion', () async {
      final c = make();
      await startMala(c, target: 2);
      volume
        ..press()
        ..press();
      await pumpEventQueue();
      expectRestored();
    });

    test('Reset', () async {
      final c = make();
      await startMala(c);
      n(c).reset();
      await pumpEventQueue();
      expectRestored();
    });

    test('leaving the Sadhana screen', () async {
      final c = make();
      await startMala(c);
      await c.read(quietModeProvider.notifier).leftSadhana();
      expectRestored();
    });

    test('the switch turned off', () async {
      final c = make();
      await startMala(c);
      c.read(completionSettingsProvider.notifier).setQuietDuringSession(false);
      await pumpEventQueue();
      expectRestored();
    });

    test('after a crash, at the next start', () async {
      final first =
          ProviderContainer(overrides: testOverrides(dnd: dnd, volume: volume));
      first.read(completionSettingsProvider.notifier).setQuietDuringSession(true);
      first.read(quietModeProvider);
      await startMala(first);
      first.dispose();
      expect(dnd.policy, quietPolicy);
      make();
      await pumpEventQueue();
      expectRestored();
    });

    test('a policy the user changed meanwhile is left alone', () async {
      final c = make();
      await startMala(c);
      dnd.policy = {...FakeDnd.userPolicy, 'categories': 1};
      n(c).pause();
      await pumpEventQueue();
      expect(dnd.policy['categories'], 1);
      expect(dnd.filter, DndFilter.all);
    });
  });

  group('did not apply: one clear notice', () {
    String? notice(ProviderContainer c) =>
        c.read(sessionNoticeProvider)?.message;
    final failed = lookupAppLocalizations(const Locale('en')).quietModeFailed;

    test('the phone ignored the change (read back)', () async {
      dnd.applies = false;
      final c = make();
      await startMala(c);
      expect(notice(c), failed);
      expect(c.read(sessionNoticeProvider)!.onAction, isNotNull,
          reason: 'a button to the access page');
      expect(c.read(quietModeProvider), isFalse);
      expect(AppStorage.settings.get(QuietModeNotifier.savedKey), isNull);
      c.read(sessionNoticeProvider)!.onAction!();
      await pumpEventQueue();
      expect(dnd.settingsOpened, 1);
    });

    test('no Do Not Disturb access', () async {
      dnd.access = false;
      final c = make();
      await startMala(c);
      expect(notice(c), failed);
      expect(dnd.sets, isEmpty);
    });
  });

  group('Tap count target (no Start)', () {
    test('quiet from the first tap, off at completion', () async {
      final c = make();
      n(c).setTargetCount(3);
      await pumpEventQueue();
      expect(dnd.sets, isEmpty, reason: 'nothing counted yet');
      n(c).tap();
      await pumpEventQueue();
      expect(dnd.filter, DndFilter.alarms);
      expect(c.read(quietModeProvider), isTrue);
      n(c)
        ..tap()
        ..tap();
      await pumpEventQueue();
      expect(c.read(sadhanaSessionProvider).completed, isTrue);
      expectRestored();
    });

    test('Reset ends it', () async {
      final c = make();
      n(c)
        ..setTargetCount(10)
        ..tap();
      await pumpEventQueue();
      expect(dnd.filter, DndFilter.alarms);
      n(c).reset();
      await pumpEventQueue();
      expectRestored();
    });

    test('leaving the Sadhana screen ends it; the next tap starts it again',
        () async {
      final c = make();
      n(c)
        ..setTargetCount(10)
        ..tap();
      await pumpEventQueue();
      await c.read(quietModeProvider.notifier).leftSadhana();
      expectRestored();
      n(c).tap();
      await pumpEventQueue();
      expect(dnd.filter, DndFilter.alarms);
    });
  });

  group('the chip', () {
    Future<ProviderContainer> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = make();
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SadhanaScreen()),
        ),
      ));
      await tester.pump();
      return c;
    }

    final chip = find.byKey(const ValueKey('quiet-mode-chip'));

    testWidgets('shown only while quiet mode holds Do Not Disturb',
        (tester) async {
      final c = await pump(tester);
      expect(chip, findsNothing);
      n(c)
        ..setTargetCount(10)
        ..tap();
      await tester.pump();
      await tester.pump();
      expect(chip, findsOneWidget);
      expect(find.text('Quiet mode on'), findsOneWidget);
      n(c).reset();
      await tester.pump();
      await tester.pump();
      expect(chip, findsNothing);
    });

    testWidgets('not shown when it did not apply', (tester) async {
      dnd.applies = false;
      final c = await pump(tester);
      n(c)
        ..setTargetCount(10)
        ..tap();
      await tester.pump();
      await tester.pump();
      expect(chip, findsNothing);
    });
  });
}
