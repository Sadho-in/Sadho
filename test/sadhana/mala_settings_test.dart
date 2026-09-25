import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/sadhana/application/mala_settings_provider.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/application/session_notice_provider.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/mode_section.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/mode_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

/// P5-4: the "Count with the screen off" switch (Android only), the one-time
/// explainer, and what the Mala panel says.
void main() {
  late FakeVolume volume;
  late FakeMalaService mala;

  setUp(() {
    resetStorage();
    volume = FakeVolume();
    mala = FakeMalaService();
  });

  ProviderContainer make() {
    final c = ProviderContainer(
        overrides: testOverrides(volume: volume, mala: mala));
    addTearDown(c.dispose);
    return c;
  }

  group('the setting', () {
    test('is on by default and persists', () {
      final c = make();
      expect(c.read(malaScreenOffProvider), isTrue);
      c.read(malaScreenOffProvider.notifier).set(false);
      expect(AppStorage.settings.get(MalaScreenOffNotifier.key), isFalse);
      final again = make();
      expect(again.read(malaScreenOffProvider), isFalse);
    });

    test('off: Mala uses the in-app listener only, with no notice', () async {
      final c = make();
      c.read(malaScreenOffProvider.notifier).set(false);
      c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.mala)
        ..toggleRunning();
      await pumpEventQueue();
      expect(mala.starts, 0);
      expect(volume.starts, 1);
      expect(c.read(sadhanaSessionProvider).malaScreenOff, isFalse);
      expect(c.read(sessionNoticeProvider), isNull);
    });

    test('switched while Mala runs: the input changes over at once', () async {
      final c = make();
      c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.mala)
        ..toggleRunning();
      await pumpEventQueue();
      expect(mala.running, isTrue);
      c.read(malaScreenOffProvider.notifier).set(false);
      await pumpEventQueue();
      expect(mala.running, isFalse);
      expect(volume.capturing, isTrue);
      expect(c.read(sadhanaSessionProvider).running, isTrue);
      c.read(malaScreenOffProvider.notifier).set(true);
      await pumpEventQueue();
      expect(volume.capturing, isFalse);
      expect(mala.running, isTrue);
    });
  });

  test('the explainer comes once, with a button to Alarms & reliability',
      () async {
    final c = make();
    final n = c.read(sadhanaSessionProvider.notifier)
      ..setMode(CountMode.mala)
      ..toggleRunning();
    await pumpEventQueue();
    final notice = c.read(sessionNoticeProvider)!;
    expect(notice.message, contains('Lock the phone'));
    expect(notice.message, contains('Unrestricted'));
    expect(notice.openAlarmsPage, isTrue);
    expect(notice.actionLabel, 'Check');
    n
      ..toggleRunning()
      ..toggleRunning();
    await pumpEventQueue();
    expect(identical(c.read(sessionNoticeProvider), notice), isTrue);
  });

  group('the Mala panel', () {
    Future<ProviderContainer> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = make();
      c.read(sadhanaSessionProvider.notifier).setMode(CountMode.mala);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(children: [ModeSection(), ModeStatusLine()]),
            ),
          ),
        ),
      ));
      return c;
    }

    testWidgets('has the switch; turning it off persists', (tester) async {
      final c = await pump(tester);
      final toggle = find.byKey(const ValueKey('mala-screen-off'));
      expect(toggle, findsOneWidget);
      expect(find.text('Count with the screen off'), findsOneWidget);
      expect(find.textContaining('even with the phone locked'), findsOneWidget);
      await tester.tap(toggle);
      await tester.pump();
      expect(c.read(malaScreenOffProvider), isFalse);
      expect(find.textContaining('The screen must stay on'), findsOneWidget);
    });

    testWidgets('while counting, the status says it works with the screen off',
        (tester) async {
      final c = await pump(tester);
      c.read(sadhanaSessionProvider.notifier).toggleRunning();
      await tester.pump();
      await tester.pump();
      expect(find.text('Volume keys count, even with the screen off'),
          findsOneWidget);
      c.read(sadhanaSessionProvider.notifier).pause();
    });

    testWidgets('not shown where there is no service (iOS, other platforms)',
        (tester) async {
      mala.supported = false;
      await pump(tester);
      expect(find.byKey(const ValueKey('mala-screen-off')), findsNothing);
      expect(find.textContaining('The screen must stay on'), findsOneWidget);
    });
  });
}
