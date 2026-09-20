import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/presentation/focus_mode_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/mode_status.dart';
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

  Future<ProviderContainer> openFocus(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: testOverrides(voice: voice, volume: volume),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => openFocusMode(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(FocusModeScreen), findsOneWidget);
    return container;
  }

  int count(ProviderContainer c) => c.read(sadhanaSessionProvider).count;

  testWidgets('a tap anywhere increments the count', (tester) async {
    final c = await openFocus(tester);
    expect(count(c), 0);

    await tester.tapAt(const Offset(40, 300)); // empty area, top-left
    await tester.pump();
    expect(count(c), 1);

    await tester.tapAt(const Offset(700, 120)); // opposite corner
    await tester.pump();
    expect(count(c), 2);
  });

  testWidgets('taps count at every edge and corner of a phone screen',
      (tester) async {
    tester.view.physicalSize = const Size(411, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = await openFocus(tester);
    // The touch area must be the whole screen, not just as wide as the text.
    for (final p in const [
      Offset(3, 3),
      Offset(408, 3),
      Offset(3, 797),
      Offset(408, 797),
      Offset(405, 400),
      Offset(6, 400),
    ]) {
      final before = count(c);
      await tester.tapAt(p);
      await tester.pump();
      expect(count(c), before + 1, reason: 'tap at $p');
    }
  });

  testWidgets('a swipe does not count', (tester) async {
    final c = await openFocus(tester);
    await tester.dragFrom(const Offset(100, 300), const Offset(200, 0));
    await tester.pump();
    expect(count(c), 0);
  });

  testWidgets('three fingers held 4s exits; no counts are added',
      (tester) async {
    final c = await openFocus(tester);
    final g = [
      await tester.startGesture(const Offset(100, 200)),
      await tester.startGesture(const Offset(300, 200)),
      await tester.startGesture(const Offset(500, 200)),
    ];
    await tester.pump(); // first frame: the hold animation starts ticking

    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(FocusModeScreen), findsOneWidget);
    expect(find.text('Keep holding to exit…'), findsOneWidget,
        reason: 'progress indicator is visible while holding');

    await tester.pump(const Duration(milliseconds: 1900));
    expect(find.byType(FocusModeScreen), findsOneWidget,
        reason: 'still inside at 3.9s');

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.byType(FocusModeScreen), findsNothing);
    expect(count(c), 0);

    for (final gesture in g) {
      await gesture.up();
    }
  });

  testWidgets('releasing a finger early cancels the exit', (tester) async {
    final c = await openFocus(tester);
    final g = [
      await tester.startGesture(const Offset(100, 200)),
      await tester.startGesture(const Offset(300, 200)),
      await tester.startGesture(const Offset(500, 200)),
    ];
    await tester.pump(); // first frame: the hold animation starts ticking
    await tester.pump(const Duration(seconds: 3));
    await g.last.up(); // down to two fingers
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(FocusModeScreen), findsOneWidget);
    expect(find.text('Keep holding to exit…'), findsNothing);

    // Two fingers alone never exit, however long.
    await tester.pump(const Duration(seconds: 10));
    expect(find.byType(FocusModeScreen), findsOneWidget);

    await g[0].up();
    await g[1].up();
    await tester.pump();
    expect(count(c), 0, reason: 'multi-finger touches never count as a tap');
  });

  testWidgets('releasing before the first frame still cancels the hold',
      (tester) async {
    await openFocus(tester);
    final g = [
      await tester.startGesture(const Offset(100, 200)),
      await tester.startGesture(const Offset(300, 200)),
      await tester.startGesture(const Offset(500, 200)),
    ];
    await g.last.up(); // no frame has run yet
    await g[0].up();
    await g[1].up();
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));
    expect(find.byType(FocusModeScreen), findsOneWidget);
  });

  testWidgets('Hold to exit button exits after 4s and does not count',
      (tester) async {
    final c = await openFocus(tester);
    final g = await tester.startGesture(tester.getCenter(find.text('Hold to exit')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(FocusModeScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();
    expect(find.byType(FocusModeScreen), findsNothing);
    await g.up();
    expect(count(c), 0);
  });

  testWidgets('a quick tap on the exit button neither exits nor counts',
      (tester) async {
    final c = await openFocus(tester);
    await tester.tap(find.text('Hold to exit'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(FocusModeScreen), findsOneWidget);
    expect(count(c), 0);
  });

  testWidgets('system back does not leave focus mode', (tester) async {
    await openFocus(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(FocusModeScreen), findsOneWidget);
  });

  testWidgets('shows the readable rhythm pace', (tester) async {
    resetStorage();
    final c = await openFocus(tester);
    c.read(sadhanaSessionProvider.notifier)
      ..setMode(CountMode.rhythm)
      ..setRhythmSeconds(3600);
    await tester.pump();
    expect(find.text('Rhythm mode'), findsOneWidget);
    expect(find.text('Paused · every 1 hr'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('Tap mode: names the mode and says "Tap anywhere to count"',
      (tester) async {
    await openFocus(tester);
    expect(find.text('Tap mode'), findsOneWidget);
    expect(find.text('Tap anywhere to count'), findsOneWidget);
    expect(find.text('Tapping anywhere also adds one'), findsNothing);
  });

  testWidgets('other modes say that screen taps do not count', (tester) async {
    final c = await openFocus(tester);
    c.read(sadhanaSessionProvider.notifier).setMode(CountMode.rhythm);
    await tester.pump();
    expect(find.textContaining('Screen taps do not count in Rhythm mode'),
        findsOneWidget);
    expect(find.text('Tap anywhere to count'), findsNothing);
  });

  testWidgets('a screen tap counts ONLY in Tap mode', (tester) async {
    final c = await openFocus(tester);
    final n = c.read(sadhanaSessionProvider.notifier);
    for (final mode in [CountMode.voice, CountMode.rhythm, CountMode.mala]) {
      n.setMode(mode);
      await tester.pump();
      for (final p in const [Offset(40, 300), Offset(400, 300), Offset(700, 120)]) {
        await tester.tapAt(p);
        await tester.pump();
      }
      expect(count(c), 0, reason: 'taps in ${mode.name} mode must not count');
    }
    n.setMode(CountMode.tap);
    await tester.pump();
    await tester.tapAt(const Offset(400, 300));
    await tester.pump();
    expect(count(c), 1, reason: 'but in Tap mode they do');
  });

  testWidgets('taps stay inert while Rhythm runs; only its timer counts',
      (tester) async {
    final c = await openFocus(tester);
    c.read(sadhanaSessionProvider.notifier)
      ..setMode(CountMode.rhythm)
      ..setRhythmSeconds(1)
      ..setTargetCount(50);
    await tester.pump();
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.tapAt(const Offset(400, 300));
    await tester.tapAt(const Offset(60, 500));
    await tester.pump();
    expect(count(c), 0);
    await tester.pump(const Duration(milliseconds: 2500));
    expect(count(c), 2, reason: 'the timer counted, the taps did not');
    await tester.tap(find.text('Pause'));
    await tester.pump();
  });

  testWidgets('the + and - buttons work in every mode', (tester) async {
    final c = await openFocus(tester);
    final n = c.read(sadhanaSessionProvider.notifier);
    for (final mode in CountMode.values) {
      n.setMode(mode);
      await tester.pump();
      await tester.tap(find.byTooltip('Add one'));
      await tester.pump();
    }
    expect(count(c), 4, reason: 'one manual count in each of the four modes');
    await tester.tap(find.byTooltip('Remove one'));
    await tester.pump();
    expect(count(c), 3);
    expect(find.byType(FocusModeScreen), findsOneWidget);
  });

  testWidgets('pressing + or - is not also a screen tap', (tester) async {
    final c = await openFocus(tester);
    await tester.tap(find.byTooltip('Add one'));
    await tester.pump();
    expect(count(c), 1, reason: 'exactly one, even in Tap mode');
    await tester.tap(find.byTooltip('Remove one'));
    await tester.pump();
    expect(count(c), 0);
  });

  testWidgets('Separate: Focus shows the active mode\'s own count and status',
      (tester) async {
    final c = await openFocus(tester);
    final n = c.read(sadhanaSessionProvider.notifier)
      ..setCountScope(CountScope.separate)
      ..setTargetCount(108);
    await tester.pump();
    expect(find.text('Tap mode · own count'), findsOneWidget);

    await tester.tapAt(const Offset(40, 300));
    await tester.tapAt(const Offset(40, 300));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    n.setMode(CountMode.mala);
    await tester.pump();
    expect(find.text('Mala mode · own count'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget, reason: 'its own Start state');
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Press the volume keys to count'), findsOneWidget);
    volume.press();
    volume.press();
    volume.press();
    await tester.pump();
    expect(find.text('3'), findsOneWidget);

    n.setMode(CountMode.tap);
    await tester.pump();
    expect(find.text('2'), findsOneWidget, reason: 'Tap kept its count');
    expect(find.text('Start'), findsNothing, reason: 'Tap has no Start button');
  });

  testWidgets('the status line shrinks instead of overflowing when narrow',
      (tester) async {
    final container = ProviderContainer(
      overrides: testOverrides(voice: voice, volume: volume),
    );
    addTearDown(container.dispose);
    // Test text is wide (every glyph is a full-width square), so 150px is
    // narrower than any real phone gives this line.
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(
          body: Center(child: SizedBox(width: 150, child: ModeStatusLine())),
        ),
      ),
    ));
    final n = container.read(sadhanaSessionProvider.notifier)
      ..setCountScope(CountScope.separate);
    for (final mode in CountMode.values) {
      n.setMode(mode);
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '$mode overflowed');
    }
  });

  testWidgets('Separate: completing one mode ends only that mode',
      (tester) async {
    final c = await openFocus(tester);
    final n = c.read(sadhanaSessionProvider.notifier)
      ..setCountScope(CountScope.separate)
      ..setTargetCount(2);
    await tester.tapAt(const Offset(40, 300));
    await tester.tapAt(const Offset(40, 300));
    await tester.pump();
    expect(find.text('Target reached 🙏'), findsOneWidget);

    n.setMode(CountMode.rhythm);
    await tester.pump();
    expect(find.text('Target reached 🙏'), findsNothing);
    await tester.tapAt(const Offset(40, 300));
    await tester.pump();
    expect(count(c), 0, reason: 'a screen tap is inert in Rhythm mode');
    await tester.tap(find.byTooltip('Add one'));
    await tester.pump();
    expect(count(c), 1, reason: 'Rhythm still counts, from its own input');
  });

  testWidgets('voice: Start shows Listening…; only voice matches count, not taps',
      (tester) async {
    final c = await openFocus(tester);
    c.read(sadhanaSessionProvider.notifier).setMode(CountMode.voice);
    await tester.pump();

    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Listening…'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);

    voice.hear();
    await tester.pump();
    expect(count(c), 1);

    await tester.tapAt(const Offset(40, 300));
    await tester.pump();
    expect(count(c), 1, reason: 'a screen tap does not count in Voice mode');
    voice.hearOther();
    await tester.pump();
    expect(count(c), 1, reason: 'nor does a sound that is not the mantra');
    voice.hear();
    await tester.pump();
    expect(count(c), 2);
    expect(find.byType(FocusModeScreen), findsOneWidget,
        reason: 'starting the microphone must not leave Focus mode');
  });

  testWidgets('mala: volume presses count while Start is on', (tester) async {
    final c = await openFocus(tester);
    c.read(sadhanaSessionProvider.notifier).setMode(CountMode.mala);
    await tester.pump();

    volume.press();
    expect(count(c), 0, reason: 'not armed yet');

    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Press the volume keys to count'), findsOneWidget);
    volume.press();
    volume.press();
    volume.press();
    expect(count(c), 3);
  });
}
