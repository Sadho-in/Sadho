import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/application/session_notice_provider.dart';
import 'package:advance_calendar/features/sadhana/services/voice_counter_service.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/counter_section.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/count_scope_control.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/mode_section.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/mode_status.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/progress_ring.dart';
import 'package:advance_calendar/features/profile/presentation/profile_screen.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

void main() {
  late FakeVoice voice;
  late FakeVolume volume;

  setUp(() {
    resetStorage();
    seedTrainedVoice(); // Voice only counts a trained mantra
    voice = FakeVoice();
    volume = FakeVolume();
  });

  Future<ProviderContainer> pump(
    WidgetTester tester,
    Widget child, {
    bool scrollable = true,
  }) async {
    final container = ProviderContainer(
      overrides: testOverrides(voice: voice, volume: volume),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: scrollable ? SingleChildScrollView(child: child) : child,
        ),
      ),
    ));
    return container;
  }

  SadhanaState read(ProviderContainer c) => c.read(sadhanaSessionProvider);

  /// The count shown in the ring (not the pace field, which can also say "2").
  Finder ring(String text) => find.descendant(
      of: find.byType(ProgressRing), matching: find.text(text));

  /// The counter card + setup card are taller than the default test screen.
  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('Rhythm pace control', () {
    testWidgets('is shown only when Rhythm is selected', (tester) async {
      final c = await pump(tester, const ModeSection());
      // Tap (the default): no pace control, no "every 2s" anywhere.
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Seconds'), findsNothing);
      expect(find.textContaining('every 2s'), findsNothing);
      expect(find.textContaining('Rhythm pace'), findsNothing,
          reason: 'the old "Rhythm pace: every 2s" shortcut is gone');

      await tester.tap(find.text('Rhythm'));
      await tester.pumpAndSettle();
      expect(read(c).mode, CountMode.rhythm);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Seconds'), findsOneWidget);
      expect(find.text('Minutes'), findsOneWidget);
      expect(find.text('Hours'), findsOneWidget);
      expect(find.text('Pace: count every 2s'), findsOneWidget);
    });

    testWidgets('typing a value + unit sets value × unit', (tester) async {
      final c = await pump(tester, const ModeSection());
      c.read(sadhanaSessionProvider.notifier).setMode(CountMode.rhythm);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5');
      await tester.pump();
      expect(read(c).rhythmSeconds, 5);

      await tester.tap(find.text('Minutes'));
      await tester.pumpAndSettle();
      expect(read(c).rhythmSeconds, 300);
      expect(find.text('Pace: count every 5 min'), findsOneWidget);

      await tester.tap(find.text('Hours'));
      await tester.enterText(find.byType(TextField), '1');
      await tester.pumpAndSettle();
      expect(read(c).rhythmSeconds, 3600);
      expect(find.text('Pace: count every 1 hr'), findsOneWidget);

      await tester.tap(find.text('Seconds'));
      await tester.enterText(find.byType(TextField), '0.2');
      await tester.pumpAndSettle();
      expect(read(c).rhythmSeconds, closeTo(0.2, 1e-9));
    });

    testWidgets('empty or invalid input is ignored, with an explanation',
        (tester) async {
      final c = await pump(tester, const ModeSection());
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.rhythm)
        ..setRhythmSeconds(10);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(read(c).rhythmSeconds, 10, reason: 'empty keeps last valid pace');
      expect(find.textContaining('Enter a pace'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '0.05');
      await tester.pump();
      expect(read(c).rhythmSeconds, 10);
      expect(find.textContaining('Too fast'), findsOneWidget);
      expect(find.textContaining('Still counting every 10s'), findsOneWidget);

      // 9 is fine in seconds but too slow once the unit becomes Hours.
      await tester.enterText(find.byType(TextField), '9');
      await tester.pump();
      expect(read(c).rhythmSeconds, 9);
      await tester.tap(find.text('Hours'));
      await tester.pump();
      expect(read(c).rhythmSeconds, 9, reason: 'invalid combination ignored');
      expect(find.textContaining('Too slow'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '2');
      await tester.pump();
      expect(read(c).rhythmSeconds, 7200, reason: 'valid again');
      n.setRhythmSeconds(2);
    });

    testWidgets('a saved pace is restored into the editor in the best unit',
        (tester) async {
      final c = await pump(tester, const ModeSection());
      c.read(sadhanaSessionProvider.notifier)
        ..setRhythmSeconds(7200)
        ..setMode(CountMode.rhythm);
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '2');
      expect(find.text('Pace: count every 2 hr'), findsOneWidget);
    });

    testWidgets('never shows under Voice, Mala or Tap, and comes back for '
        'Rhythm', (tester) async {
      final c = await pump(
        tester,
        const Column(children: [CounterSection(), ModeSection()]),
      );
      final n = c.read(sadhanaSessionProvider.notifier);
      for (final mode in [CountMode.tap, CountMode.voice, CountMode.mala]) {
        n.setMode(mode);
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsNothing, reason: mode.name);
        expect(find.textContaining('every 2s'), findsNothing,
            reason: 'no pace text in ${mode.name} mode');
        expect(find.textContaining('Pace:'), findsNothing);
        expect(find.text('Seconds'), findsNothing);
      }
      n.setMode(CountMode.rhythm);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Pace: count every 2s'), findsOneWidget);
      n.setMode(CountMode.voice);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing,
          reason: 'and gone again as soon as another mode is chosen');
    });

    testWidgets('a pace edit while Rhythm is chosen is kept for later',
        (tester) async {
      final c = await pump(tester, const ModeSection());
      await tester.tap(find.text('Rhythm'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '3');
      await tester.pump();
      expect(read(c).rhythmSeconds, 3);
      await tester.tap(find.text('Tap'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rhythm'));
      await tester.pumpAndSettle();
      expect(find.text('Pace: count every 3s'), findsOneWidget);
    });
  });

  group('mode status line', () {
    testWidgets('Tap names itself and says how to count', (tester) async {
      await pump(tester, const CounterSection());
      expect(find.text('Tap mode'), findsOneWidget);
      expect(find.text('Tap anywhere to count'), findsOneWidget);
    });

    testWidgets('Rhythm shows the readable pace and paused/running',
        (tester) async {
      final c = await pump(tester, const CounterSection());
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.rhythm)
        ..setRhythmSeconds(300);
      await tester.pump();
      expect(find.text('Rhythm mode'), findsOneWidget);
      expect(find.text('Paused · every 5 min'), findsOneWidget);
      n.toggleRunning();
      await tester.pump();
      expect(find.text('Counting every 5 min'), findsOneWidget);
      n.setRhythmSeconds(2);
      await tester.pump();
      expect(find.text('Counting every 2s'), findsOneWidget);
      n.setRhythmSeconds(3600);
      await tester.pump();
      expect(find.text('Counting every 1 hr'), findsOneWidget);
      n.toggleRunning();
    });

    testWidgets('Voice shows a live "Listening…" indicator', (tester) async {
      final c = await pump(tester, const CounterSection());
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice);
      await tester.pump();
      expect(find.text('Voice mode'), findsOneWidget);
      expect(find.text('Paused · press Start to listen'), findsOneWidget);
      expect(find.text('Listening…'), findsNothing);

      n.toggleRunning();
      await tester.pump(); // start() resolves
      await tester.pump();
      expect(find.text('Listening…'), findsOneWidget);
      expect(find.text('Voice mode'), findsOneWidget);

      voice.hear();
      await tester.pump();
      expect(find.text('1'), findsWidgets, reason: 'ring shows the count');

      n.toggleRunning();
      await tester.pump();
      expect(find.text('Listening…'), findsNothing);
    });

    testWidgets('Voice says the microphone is being started while it waits',
        (tester) async {
      final pending = PendingVoice();
      voice = pending;
      final c = await pump(tester, const CounterSection());
      c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning(); // the permission dialog is still up
      await tester.pump();
      expect(find.textContaining('allow access if asked'), findsOneWidget);
      expect(find.text('Listening…'), findsNothing);

      pending.answer(VoiceStartResult.started);
      await tester.pump();
      await tester.pump();
      expect(find.text('Listening…'), findsOneWidget);
      c.read(sadhanaSessionProvider.notifier).toggleRunning();
    });

    testWidgets('Mala tells you to press the volume keys once active',
        (tester) async {
      final c = await pump(tester, const CounterSection());
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.mala);
      await tester.pump();
      expect(find.text('Mala mode'), findsOneWidget);
      expect(find.text('Press the volume keys to count'), findsNothing,
          reason: 'not armed until Start');
      n.toggleRunning();
      await tester.pump();
      await tester.pump();
      expect(find.text('Press the volume keys to count'), findsOneWidget);
      n.toggleRunning();
    });

    testWidgets('Separate scope says the count is the mode\'s own',
        (tester) async {
      // The two-line status (Focus mode's) also says the count is its own.
      final c = await pump(tester, const ModeStatusLine());
      expect(find.text('Tap mode'), findsOneWidget);
      c.read(sadhanaSessionProvider.notifier).setCountScope(CountScope.separate);
      await tester.pump();
      expect(find.text('Tap mode · own count'), findsOneWidget);
    });
  });

  group('Count: Combined | Separate', () {
    testWidgets('is a compact one-line control, defaulting to Combined',
        (tester) async {
      final c = await pump(tester, const CountScopeControl(compact: true));
      expect(find.text('Count:'), findsOneWidget);
      expect(find.text('Combined'), findsOneWidget);
      expect(find.text('Separate'), findsOneWidget);
      expect(read(c).scope, CountScope.combined);
      final size = tester.getSize(find.byType(CountScopeControl));
      expect(size.height, lessThan(44), reason: 'small, not a card');
    });

    testWidgets('toggling switches the scope and persists to Hive',
        (tester) async {
      final c = await pump(tester, const CountScopeControl(compact: true));
      await tester.tap(find.text('Separate'));
      await tester.pumpAndSettle();
      expect(read(c).scope, CountScope.separate);
      expect(AppStorage.settings.get('sadhana.session')['countScope'],
          'separate');

      await tester.tap(find.text('Combined'));
      await tester.pumpAndSettle();
      expect(read(c).scope, CountScope.combined);
      expect(AppStorage.settings.get('sadhana.session')['countScope'],
          'combined');
    });

    testWidgets('a saved Separate choice is restored on relaunch',
        (tester) async {
      var c = await pump(tester, const CountScopeControl(compact: true));
      await tester.tap(find.text('Separate'));
      await tester.pumpAndSettle();
      c.dispose();

      await tester.pumpWidget(const SizedBox());
      c = await pump(tester, const CountScopeControl(compact: true));
      expect(read(c).scope, CountScope.separate);
      final selected = tester
          .widget<SegmentedButton<CountScope>>(
              find.byType(SegmentedButton<CountScope>))
          .selected;
      expect(selected, {CountScope.separate});
    });

    testWidgets('the full version in Settings explains it and stays in sync',
        (tester) async {
      final c = await pump(tester, const ProfileScreen(), scrollable: false);
      expect(find.text('Sadhana settings'), findsOneWidget);
      expect(find.text('Count'), findsOneWidget);
      expect(find.textContaining('one shared count'), findsOneWidget);
      await tester.tap(find.text('Separate'));
      await tester.pumpAndSettle();
      expect(read(c).scope, CountScope.separate);
      expect(find.textContaining('its own progress'), findsOneWidget);
    });

    testWidgets('COMBINED through the real controls: every mode adds to one '
        'shared count', (tester) async {
      useTallScreen(tester);
      final c = await pump(
        tester,
        const Column(children: [
          CountScopeControl(compact: true),
          CounterSection(),
          ModeSection(),
        ]),
      );
      await tester.tap(find.byTooltip('Add one'));
      await tester.tap(find.byTooltip('Add one'));
      await tester.pump();
      expect(ring('2'), findsOneWidget);

      await tester.tap(find.text('Rhythm'));
      await tester.pumpAndSettle();
      expect(ring('2'), findsOneWidget, reason: 'same shared count');
      await tester.tap(find.byTooltip('Add one'));
      await tester.pump();
      expect(ring('3'), findsOneWidget);

      await tester.tap(find.text('Mala'));
      await tester.pumpAndSettle();
      expect(ring('3'), findsOneWidget);
      await tester.tap(find.byTooltip('Add one'));
      await tester.pump();
      expect(ring('4'), findsOneWidget);
      expect(find.text('of 108'), findsOneWidget, reason: 'one target');
      expect(read(c).count, 4);
    });

    testWidgets('SEPARATE through the real controls: each mode has its own '
        'count and Reset only clears the active one', (tester) async {
      useTallScreen(tester);
      final c = await pump(
        tester,
        const Column(children: [
          CountScopeControl(compact: true),
          CounterSection(),
          ModeSection(),
        ]),
      );
      await tester.tap(find.text('Separate'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byTooltip('Add one'));
      }
      await tester.pump();
      expect(ring('3'), findsOneWidget);
      expect(find.text('of 108'), findsOneWidget);

      await tester.tap(find.text('Rhythm'));
      await tester.pumpAndSettle();
      expect(ring('0'), findsOneWidget, reason: 'Rhythm starts at 0');
      await tester.tap(find.byTooltip('Add one'));
      await tester.pump();
      expect(ring('1'), findsOneWidget);

      await tester.tap(find.text('Tap'));
      await tester.pumpAndSettle();
      expect(ring('3'), findsOneWidget, reason: 'Tap kept its own count');

      // Reset applies to Tap only, and says so.
      await tester.tap(find.byTooltip('Reset'));
      await tester.pumpAndSettle();
      expect(find.text('Reset Tap count?'), findsOneWidget);
      expect(find.textContaining('other modes keep their counts'),
          findsOneWidget);
      await tester.tap(find.text('Reset').last);
      await tester.pumpAndSettle();
      expect(ring('3'), findsNothing);
      expect(read(c).progressOf(CountMode.tap).count, 0);
      await tester.tap(find.text('Rhythm'));
      await tester.pumpAndSettle();
      expect(ring('1'), findsOneWidget, reason: 'Rhythm was not reset');
    });

    testWidgets('flipping the toggle loses nothing and shows sum vs own',
        (tester) async {
      useTallScreen(tester);
      final c = await pump(
        tester,
        const Column(children: [
          CountScopeControl(compact: true),
          CounterSection(),
          ModeSection(),
        ]),
      );
      await tester.tap(find.byTooltip('Add one'));
      await tester.tap(find.byTooltip('Add one'));
      await tester.tap(find.text('Rhythm'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Add one'));
      await tester.pump();
      expect(ring('3'), findsOneWidget, reason: 'Combined: 2 + 1');

      await tester.tap(find.text('Separate'));
      await tester.pumpAndSettle();
      expect(ring('1'), findsOneWidget, reason: 'Separate: Rhythm\'s own');
      await tester.tap(find.text('Combined'));
      await tester.pumpAndSettle();
      expect(ring('3'), findsOneWidget, reason: 'and back, nothing lost');
      await tester.tap(find.text('Separate'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tap'));
      await tester.pumpAndSettle();
      expect(ring('2'), findsOneWidget, reason: 'Tap still owns its 2');
      expect(read(c).progressOf(CountMode.rhythm).count, 1);
    });

    testWidgets('completion in one mode shows only for that mode',
        (tester) async {
      useTallScreen(tester);
      final c = await pump(
        tester,
        const Column(children: [
          CountScopeControl(compact: true),
          CounterSection(),
          ModeSection(),
        ]),
      );
      c.read(sadhanaSessionProvider.notifier)
        ..setCountScope(CountScope.separate)
        ..setTargetCount(2)
        ..increment()
        ..increment();
      await tester.pump();
      expect(find.textContaining('Target reached in Tap'), findsOneWidget);

      await tester.tap(find.text('Rhythm'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Target reached'), findsNothing);
      expect(find.text('of 2'), findsOneWidget);
    });

    testWidgets('Combined reset dialog is unchanged', (tester) async {
      final c = await pump(tester, const CounterSection());
      c.read(sadhanaSessionProvider.notifier).increment();
      await tester.pump();
      await tester.tap(find.byTooltip('Reset'));
      await tester.pumpAndSettle();
      expect(find.text('Reset this session?'), findsOneWidget);
      expect(find.text('Your count of 1 will return to zero.'), findsOneWidget);
    });
  });

  group('the ring tap counts only in Tap mode', () {
    testWidgets('a tap on the ring counts in Tap mode, not in the others',
        (tester) async {
      final c = await pump(tester, const CounterSection());
      await tester.tap(find.byType(ProgressRing));
      await tester.pump();
      expect(read(c).count, 1);
      for (final mode in [CountMode.voice, CountMode.rhythm, CountMode.mala]) {
        c.read(sadhanaSessionProvider.notifier).setMode(mode);
        await tester.pump();
        await tester.tap(find.byType(ProgressRing));
        await tester.pump();
        expect(read(c).count, 1, reason: 'a ring tap in ${mode.name} mode');
      }
    });

    testWidgets('the + button adds one in every mode', (tester) async {
      final c = await pump(tester, const CounterSection());
      for (final mode in CountMode.values) {
        c.read(sadhanaSessionProvider.notifier).setMode(mode);
        await tester.pump();
        await tester.tap(find.byTooltip('Add one'));
        await tester.pump();
      }
      expect(read(c).count, 4);
    });
  });

  group('modes this device cannot run', () {
    testWidgets('the setup card says so up front', (tester) async {
      voice = FakeVoice(supported: false);
      volume = FakeVolume(supported: false);
      await pump(tester, const ModeSection());
      expect(find.text('Voice counting works on Android and iOS only'),
          findsOneWidget);
      expect(find.text('Volume-key counting needs a physical device'),
          findsOneWidget);
    });

    testWidgets('and stays quiet when both work', (tester) async {
      await pump(tester, const ModeSection());
      expect(find.textContaining('physical device'), findsNothing);
      expect(find.textContaining('Android and iOS only'), findsNothing);
    });

    testWidgets('only the unusable mode is called out', (tester) async {
      volume = FakeVolume(supported: false);
      await pump(tester, const ModeSection());
      expect(find.textContaining('physical device'), findsOneWidget);
      expect(find.textContaining('Android and iOS only'), findsNothing);
    });
  });

  group('mode chips', () {
    testWidgets('Voice and Mala are real modes now, not "coming soon"',
        (tester) async {
      final c = await pump(tester, const ModeSection());
      await tester.tap(find.text('Voice'));
      await tester.pumpAndSettle();
      expect(read(c).mode, CountMode.voice);
      expect(find.textContaining('chant your trained mantra'), findsOneWidget);

      await tester.tap(find.text('Mala'));
      await tester.pumpAndSettle();
      expect(read(c).mode, CountMode.mala);
      expect(find.textContaining('volume button'), findsOneWidget);
      expect(find.textContaining('coming soon'), findsNothing);
    });

    testWidgets('unsupported platforms stay on Tap and raise a notice',
        (tester) async {
      voice = FakeVoice(supported: false);
      volume = FakeVolume(supported: false);
      final c = await pump(tester, const ModeSection());
      await tester.tap(find.text('Voice'));
      await tester.pump();
      expect(read(c).mode, CountMode.tap);
      expect(c.read(sessionNoticeProvider)!.message,
          contains('Android and iOS only'));
      await tester.tap(find.text('Mala'));
      await tester.pump();
      expect(read(c).mode, CountMode.tap);
      expect(c.read(sessionNoticeProvider)!.message,
          contains('Volume-key counting needs a physical device'));
    });

    testWidgets('a device with no microphone says so and stays usable',
        (tester) async {
      voice.result = VoiceStartResult.unavailable;
      final c = await pump(tester, const CounterSection());
      c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await tester.pump();
      await tester.pump();
      expect(read(c).mode, CountMode.tap);
      expect(c.read(sessionNoticeProvider)!.message,
          contains('No microphone available on this device'));
      expect(find.text('Tap anywhere to count'), findsOneWidget);
    });
  });

  testWidgets('the app shell shows session notices as a snackbar',
      (tester) async {
    final container = ProviderContainer(
      overrides: testOverrides(voice: voice, volume: volume),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AppShell()),
    ));
    await tester.pump();

    voice.result = VoiceStartResult.permanentlyDenied;
    container.read(sadhanaSessionProvider.notifier)
      ..setMode(CountMode.voice)
      ..toggleRunning();
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('Microphone access is blocked'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget,
        reason: 'offers to open system settings');
    expect(container.read(sadhanaSessionProvider).mode, CountMode.tap);
  });
}
