import 'dart:typed_data';

import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/sadhana/application/mantra_library_provider.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/application/voice_training_provider.dart';
import 'package:advance_calendar/features/sadhana/presentation/focus_mode_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/mantra_library_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/sadhana_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/voice_training_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/counter_section.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/mode_section.dart';
import 'package:advance_calendar/features/sadhana/services/pcm_input.dart';
import 'package:advance_calendar/features/sadhana/voice/mfcc.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'synth.dart';
import 'test_support.dart';

void main() {
  late FakeVoice voice;
  late FakeVolume volume;
  late FakePcmInput mic;

  setUp(() {
    resetStorage();
    voice = FakeVoice();
    volume = FakeVolume();
    mic = FakePcmInput();
  });

  /// How many recordings a fresh load of the store would find for Waheguru.
  int makeReloaded(ProviderContainer c) {
    final fresh = ProviderContainer(overrides: testOverrides(pcm: mic));
    addTearDown(fresh.dispose);
    return fresh.read(voiceTrainingProvider)['seed_waheguru']!.sampleCount;
  }

  /// A saved training made of REAL (synthetic) mantra recordings, so new
  /// recordings of the same mantra are consistent with it.
  void seedRealTraining(String mantraId, [int n = 3]) {
    final ex = MfccExtractor();
    final templates = [
      for (var k = 1; k <= n; k++)
        ex.extract(concat([
          silence(100),
          synthMantra(mantraA, seed: k, tempo: 0.94 + k * 0.03),
          silence(100),
        ])),
    ];
    AppStorage.voiceTemplates.put(mantraId, {
      'mantraId': mantraId,
      ...VoiceTraining(
              mantraId: mantraId,
              templates: templates,
              trainedAt: DateTime(2026, 9, 1))
          .toMap(),
    });
  }

  void tallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<ProviderContainer> pump(WidgetTester tester, Widget child,
      {bool scroll = true}) async {
    tallScreen(tester);
    final c = ProviderContainer(
        overrides: testOverrides(voice: voice, volume: volume, pcm: mic));
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        home: Scaffold(body: scroll ? SingleChildScrollView(child: child) : child),
      ),
    ));
    return c;
  }

  SadhanaState read(ProviderContainer c) => c.read(sadhanaSessionProvider);

  group('Beta labelling', () {
    testWidgets('the Voice chip is labelled Beta', (tester) async {
      seedTrainedVoice();
      await pump(tester, const ModeSection());
      expect(find.text('BETA'), findsOneWidget);
      expect(find.text('Voice'), findsOneWidget, reason: 'label unchanged');
    });

    testWidgets('the Voice panel, status line and training screen say Beta',
        (tester) async {
      seedTrainedVoice();
      final c = await pump(
          tester, const Column(children: [CounterSection(), ModeSection()]));
      c.read(sadhanaSessionProvider.notifier).setMode(CountMode.voice);
      await tester.pumpAndSettle();
      // chip + panel title + status line
      expect(find.text('BETA'), findsNWidgets(3));
      expect(find.textContaining('Beta: works on-device and offline'),
          findsOneWidget);
    });

    testWidgets('other modes carry no Beta label on their status', (tester) async {
      seedTrainedVoice();
      final c = await pump(tester, const CounterSection());
      expect(find.text('BETA'), findsNothing);
      c.read(sadhanaSessionProvider.notifier).setMode(CountMode.rhythm);
      await tester.pump();
      expect(find.text('BETA'), findsNothing);
    });
  });

  group('choosing Voice', () {
    testWidgets('for an untrained mantra asks to train first', (tester) async {
      final c = await pump(tester, const ModeSection());
      await tester.tap(find.text('Voice'));
      await tester.pumpAndSettle();
      expect(read(c).mode, CountMode.voice);
      expect(find.text('Train your voice first'), findsOneWidget);
      expect(find.textContaining('3 to 7 times'), findsWidgets);

      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();
      expect(find.text('Train your voice first'), findsNothing);
      expect(find.byType(VoiceTrainingScreen), findsNothing);
      expect(read(c).mode, CountMode.voice, reason: 'stays selected');
    });

    testWidgets('"Train now" opens the training screen for that mantra',
        (tester) async {
      await pump(tester, const ModeSection());
      await tester.tap(find.text('Voice'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Train now'));
      await tester.pumpAndSettle();
      expect(find.byType(VoiceTrainingScreen), findsOneWidget);
      expect(find.text('Om Namah Shivaya'), findsOneWidget);
    });

    testWidgets('for a trained mantra there is no prompt', (tester) async {
      seedTrainedVoice();
      final c = await pump(tester, const ModeSection());
      await tester.tap(find.text('Voice'));
      await tester.pumpAndSettle();
      expect(find.text('Train your voice first'), findsNothing);
      expect(read(c).mode, CountMode.voice);
    });

    testWidgets('an unsupported device gets the honest message, not a prompt',
        (tester) async {
      voice = FakeVoice(supported: false);
      final c = await pump(tester, const ModeSection());
      await tester.tap(find.text('Voice'));
      await tester.pumpAndSettle();
      expect(find.text('Train your voice first'), findsNothing);
      expect(read(c).mode, CountMode.tap);
    });
  });

  group('Voice panel', () {
    testWidgets('untrained: says so and offers Train voice only',
        (tester) async {
      final c = await pump(tester, const ModeSection());
      c.read(sadhanaSessionProvider.notifier).setMode(CountMode.voice);
      await tester.pumpAndSettle();
      expect(find.text('Train your own mantra'), findsOneWidget);
      expect(find.text('Voice not trained'), findsOneWidget);
      expect(find.text('Train voice'), findsOneWidget);
      expect(find.text('Re-train'), findsNothing);
      expect(find.text('Clear training'), findsNothing);
    });

    testWidgets('trained: Re-train and Clear training, and Clear asks first',
        (tester) async {
      seedTrainedVoice();
      final c = await pump(tester, const ModeSection());
      c.read(sadhanaSessionProvider.notifier).setMode(CountMode.voice);
      await tester.pumpAndSettle();
      expect(find.text('Voice trained'), findsOneWidget);
      expect(find.text('Re-train'), findsOneWidget);
      expect(find.textContaining('from your 3 recordings'), findsOneWidget);

      await tester.tap(find.text('Clear training'));
      await tester.pumpAndSettle();
      expect(find.text('Clear voice training?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(c.read(mantraTrainedProvider('seed_om_namah_shivaya')), isTrue);

      await tester.tap(find.text('Clear training'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Clear training'));
      await tester.pumpAndSettle();
      expect(c.read(mantraTrainedProvider('seed_om_namah_shivaya')), isFalse);
      expect(find.text('Voice not trained'), findsOneWidget);
      expect(AppStorage.voiceTemplates.values, isEmpty);
    });

    testWidgets('only shown while Voice is the active mode', (tester) async {
      await pump(tester, const ModeSection());
      expect(find.text('Train your own mantra'), findsNothing);
      expect(find.text('Sensitivity'), findsNothing);
    });

    testWidgets('Sensitivity: Strict ↔ Lenient, default one step toward Strict, '
        'persisted',
        (tester) async {
      seedTrainedVoice();
      final c = await pump(tester, const ModeSection());
      c.read(sadhanaSessionProvider.notifier).setMode(CountMode.voice);
      await tester.pumpAndSettle();
      expect(find.text('Sensitivity'), findsOneWidget);
      expect(find.text('Strict'), findsOneWidget);
      expect(find.text('Lenient'), findsOneWidget);
      final slider = find.byType(Slider);
      // P5.1: one step (a quarter) from the middle toward Strict.
      expect(tester.widget<Slider>(slider).value, 0.25,
          reason: 'one step toward Strict');

      // Drag to the Strict end.
      await tester.drag(slider, const Offset(-2000, 0));
      await tester.pump();
      expect(c.read(voiceSensitivityProvider), lessThan(0.05));
      expect(AppStorage.settings.get('voice.sensitivity'), lessThan(0.05));
      await tester.drag(slider, const Offset(4000, 0));
      await tester.pump();
      expect(c.read(voiceSensitivityProvider), greaterThan(0.95));
    });

    testWidgets('opening training pauses a listening session', (tester) async {
      seedTrainedVoice();
      final c = await pump(tester, const ModeSection());
      final n = c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await tester.pumpAndSettle();
      expect(voice.listening, isTrue);
      await tester.tap(find.text('Re-train'));
      await tester.pumpAndSettle();
      expect(read(c).running, isFalse);
      expect(voice.listening, isFalse,
          reason: 'the microphone is free for the training screen');
      n.pause();
    });
  });

  group('Trained / not trained shown', () {
    testWidgets('on the Sadhana screen', (tester) async {
      final c = await pump(tester, const SadhanaScreen(), scroll: false);
      expect(find.text('Voice not trained'), findsOneWidget);
      seedTrainedVoice();
      c.invalidate(voiceTrainingProvider);
      await tester.pump();
      expect(find.text('Voice trained'), findsOneWidget);
    });

    testWidgets('in the library, per mantra, with a Train button',
        (tester) async {
      seedTrainedVoice('seed_waheguru');
      await pump(tester, const MantraLibraryScreen(), scroll: false);
      expect(find.text('Voice trained'), findsOneWidget);
      expect(find.text('Voice not trained'), findsNWidgets(3));
      expect(find.byTooltip('Re-train voice'), findsOneWidget);
      expect(find.byTooltip('Train voice'), findsNWidgets(3));
      final waheguru = find.widgetWithText(Card, 'Waheguru').first;
      expect(
          find.descendant(of: waheguru, matching: find.text('Voice trained')),
          findsOneWidget);
    });

    testWidgets('the library button opens training for that mantra',
        (tester) async {
      await pump(tester, const MantraLibraryScreen(), scroll: false);
      final gayatri = find.widgetWithText(Card, 'Gayatri Mantra').first;
      await tester.tap(
          find.descendant(of: gayatri, matching: find.byTooltip('Train voice')));
      await tester.pumpAndSettle();
      expect(find.byType(VoiceTrainingScreen), findsOneWidget);
      expect(find.text('Gayatri Mantra'), findsOneWidget);
    });
  });

  group('live status while listening', () {
    testWidgets('untrained Voice says to train first', (tester) async {
      final c = await pump(tester, const CounterSection());
      c.read(sadhanaSessionProvider.notifier).setMode(CountMode.voice);
      await tester.pump();
      expect(find.text('Voice mode'), findsOneWidget);
      expect(find.textContaining('Not trained yet'), findsOneWidget);
    });

    testWidgets('Start on an untrained mantra does not open the microphone',
        (tester) async {
      final c = await pump(tester, const CounterSection());
      c.read(sadhanaSessionProvider.notifier).setMode(CountMode.voice);
      await tester.pump();
      await tester.tap(find.text('Start'));
      await tester.pump();
      expect(voice.starts, 0);
      expect(read(c).running, isFalse);
    });

    testWidgets('shows a live "Counted" / "Ignored" result for each utterance',
        (tester) async {
      seedTrainedVoice();
      final c = await pump(tester, const CounterSection());
      c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await tester.pump();
      await tester.pump();
      expect(find.text('Listening…'), findsOneWidget);
      expect(find.textContaining('Counted'), findsNothing);

      voice.hear();
      await tester.pump();
      expect(find.text('Counted · 75% match'), findsOneWidget);
      expect(read(c).count, 1);

      voice.hearOther();
      await tester.pump();
      expect(find.text('Ignored · 0% match (not your mantra)'), findsOneWidget);
      expect(read(c).count, 1, reason: 'not counted');

      await tester.pump(const Duration(seconds: 1));
      c.read(sadhanaSessionProvider.notifier).pause();
      await tester.pump();
      expect(find.textContaining('Counted'), findsNothing,
          reason: 'cleared when listening stops');
    });

    testWidgets('the icon bumps when something is heard', (tester) async {
      seedTrainedVoice();
      final c = await pump(tester, const CounterSection());
      c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await tester.pump();
      await tester.pump();
      final icon = find.byIcon(Icons.mic);
      expect(icon, findsOneWidget);
      double scaleOf() => tester
          .widget<Transform>(find
              .ancestor(of: icon, matching: find.byType(Transform))
              .first)
          .transform
          .getMaxScaleOnAxis();
      expect(scaleOf(), closeTo(1.0, 0.01));
      voice.hear();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(scaleOf(), greaterThan(1.05), reason: 'a visible pulse');
      await tester.pump(const Duration(milliseconds: 500));
      expect(scaleOf(), closeTo(1.0, 0.01), reason: 'and it settles');
      c.read(sadhanaSessionProvider.notifier).pause();
    });
  });

  group('manual +/- correction', () {
    testWidgets('the Undo button takes one off and is off at zero',
        (tester) async {
      final c = await pump(tester, const CounterSection());
      expect(tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.remove)).onPressed,
          isNull);
      await tester.tap(find.byTooltip('Add one'));
      await tester.tap(find.byTooltip('Add one'));
      await tester.pump();
      expect(read(c).count, 2);
      await tester.tap(find.byTooltip('Remove one'));
      await tester.pump();
      expect(read(c).count, 1);
    });

    testWidgets('works in Voice mode too (undo a miscount)', (tester) async {
      seedTrainedVoice();
      final c = await pump(tester, const CounterSection());
      c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await tester.pump();
      await tester.pump();
      voice.hear();
      voice.hear();
      await tester.pump();
      await tester.tap(find.byTooltip('Remove one'));
      await tester.pump();
      expect(read(c).count, 1);
      c.read(sadhanaSessionProvider.notifier).pause();
    });
  });

  group('Focus mode with Voice', () {
    Future<ProviderContainer> focus(WidgetTester tester) async {
      tallScreen(tester);
      final c = ProviderContainer(
          overrides: testOverrides(voice: voice, volume: volume, pcm: mic));
      addTearDown(c.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                  onPressed: () => openFocusMode(context),
                  child: const Text('open')),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return c;
    }

    testWidgets('shows the mode, Beta, Listening…, live result and counts',
        (tester) async {
      seedTrainedVoice();
      final c = await focus(tester);
      c.read(sadhanaSessionProvider.notifier).setMode(CountMode.voice);
      await tester.pump();
      expect(find.text('Voice mode'), findsOneWidget);
      expect(find.text('BETA'), findsOneWidget);
      await tester.tap(find.text('Start'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Listening…'), findsOneWidget);

      voice.hear();
      voice.hear();
      voice.hear();
      await tester.pump();
      expect(read(c).count, 3);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Counted · 75% match'), findsOneWidget);
      voice.hearOther();
      await tester.pump();
      expect(read(c).count, 3);
      expect(find.textContaining('Ignored'), findsOneWidget);
    });

    testWidgets('the - button corrects the count and is not itself a tap',
        (tester) async {
      seedTrainedVoice();
      final c = await focus(tester);
      c.read(sadhanaSessionProvider.notifier)
        ..increment()
        ..increment()
        ..increment();
      await tester.pump();
      expect(tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.remove)).onPressed,
          isNotNull);
      await tester.tap(find.byTooltip('Remove one'));
      await tester.pump();
      expect(read(c).count, 2, reason: 'one removed, and the press added none');
    });

    testWidgets('screen taps do NOT count while Voice listens; + does',
        (tester) async {
      seedTrainedVoice();
      final c = await focus(tester);
      c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await tester.pump();
      await tester.pump();
      await tester.tapAt(const Offset(60, 900));
      await tester.tapAt(const Offset(400, 600));
      await tester.pump();
      expect(read(c).count, 0, reason: 'only a voice match counts');
      expect(find.textContaining('Screen taps do not count in Voice mode'),
          findsOneWidget);
      // Tap mode is the way to count by tapping.
      voice.hear();
      await tester.pump();
      expect(read(c).count, 1);
      await tester.tap(find.byTooltip('Add one'));
      await tester.pump();
      expect(read(c).count, 2, reason: 'the manual + still corrects');
    });

    testWidgets('Start on an untrained mantra explains and does not listen',
        (tester) async {
      final c = await focus(tester);
      c.read(sadhanaSessionProvider.notifier).setMode(CountMode.voice);
      await tester.pump();
      expect(find.textContaining('Not trained yet'), findsOneWidget);
      await tester.tap(find.text('Start'));
      await tester.pump();
      expect(voice.starts, 0);
      expect(find.byType(FocusModeScreen), findsOneWidget,
          reason: 'never kicks the user out of Focus mode');
    });
  });

  group('the "Train" prompt from a session notice', () {
    testWidgets('a snackbar offers Train and opens that mantra\'s training',
        (tester) async {
      tallScreen(tester);
      final c = ProviderContainer(
          overrides: testOverrides(voice: voice, volume: volume, pcm: mic));
      addTearDown(c.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: AppShell()),
      ));
      await tester.pump();

      c.read(sadhanaSessionProvider.notifier)
        ..selectMantra('seed_waheguru', 108)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('Train your voice for this mantra first'),
          findsOneWidget);
      await tester.tap(find.text('Train'));
      await tester.pumpAndSettle();
      expect(find.byType(VoiceTrainingScreen), findsOneWidget);
      expect(find.text('Waheguru'), findsWidgets);
    });
  });

  group('VoiceTrainingScreen', () {
    Future<ProviderContainer> open(WidgetTester tester,
        {String? seedFor, int seedCount = 3}) async {
      if (seedFor != null) seedRealTraining(seedFor, seedCount);
      tallScreen(tester);
      final c = ProviderContainer(
          overrides: testOverrides(voice: voice, volume: volume, pcm: mic));
      addTearDown(c.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => openVoiceTraining(
                    context,
                    c
                        .read(mantraLibraryProvider)
                        .firstWhere((m) => m.id == 'seed_waheguru')),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return c;
    }

    void say(WidgetTester tester, Float64List chant) {
      feedInChunks(toPcm(concat([chant, silence(900, seed: 9)])), mic.push);
    }

    testWidgets('intro: instructions, Beta, privacy note', (tester) async {
      await open(tester);
      expect(find.text('Train voice'), findsOneWidget, reason: 'app bar');
      expect(find.text('BETA'), findsOneWidget);
      expect(find.text('Train your own mantra'), findsOneWidget);
      expect(find.textContaining('3 to 7 times'), findsOneWidget);
      expect(find.textContaining('5 is a good number'), findsOneWidget);
      expect(find.text('Start recording'), findsOneWidget);
      expect(find.textContaining('never the audio'), findsOneWidget);
      expect(find.textContaining('noisy room'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget, reason: 'sensitivity here too');
      expect(mic.starts, 0, reason: 'nothing listens until asked');
    });

    testWidgets('records up to 7 times, then saves to Hive', (tester) async {
      final c = await open(tester);
      await tester.tap(find.text('Start recording'));
      await tester.pump();
      expect(find.text('Stay quiet for a moment…'), findsOneWidget);

      feedInChunks(toPcm(silence(600)), mic.push);
      await tester.pump();
      expect(find.text('Say your mantra…'), findsOneWidget);
      expect(find.text('Recording 1 of up to 7'), findsOneWidget);
      expect(find.text('Record 3 more to save'), findsOneWidget);

      for (var i = 1; i <= 7; i++) {
        expect(find.text('Recording $i of up to 7'), findsOneWidget);
        say(tester, synthMantra(mantraA, seed: i, tempo: 1 + (i % 3) * 0.04));
        await tester.pump();
        if (i == 2) expect(find.text('Record 1 more to save'), findsOneWidget);
        if (i == 3) expect(find.text('Save 3 recordings'), findsOneWidget);
        if (i == 5) {
          expect(find.text('Save 5 recordings'), findsOneWidget);
          expect(find.text('Say your mantra…'), findsOneWidget,
              reason: '5 does not end it: it goes on to 7');
        }
      }
      expect(find.text('All 7 recordings captured'), findsOneWidget);
      expect(find.text('Save 7 recordings'), findsOneWidget);
      expect(mic.streaming, isFalse);

      await tester.tap(find.text('Save 7 recordings'));
      await tester.pumpAndSettle();
      expect(find.byType(VoiceTrainingScreen), findsNothing, reason: 'closed');
      expect(find.textContaining('Voice trained for “Waheguru” (7 recordings)'),
          findsOneWidget);
      final saved = c.read(voiceTrainingProvider)['seed_waheguru']!;
      expect(saved.sampleCount, 7);
      expect(saved.isUsable, isTrue);
      // Kept per microphone since P5.1 (the fake phone reports its own mic).
      expect(
          AppStorage.voiceTemplates
              .get(voiceTrainingKey('seed_waheguru', VoiceInput.phone)),
          isNotNull);
    });

    for (final n in [3, 4, 5, 6]) {
      testWidgets('can save after just $n recordings', (tester) async {
        final c = await open(tester);
        await tester.tap(find.text('Start recording'));
        await tester.pump();
        feedInChunks(toPcm(silence(600)), mic.push);
        for (var i = 1; i <= n; i++) {
          say(tester, synthMantra(mantraA, seed: i));
          await tester.pump();
        }
        await tester.tap(find.text('Save $n recordings'));
        await tester.pumpAndSettle();
        expect(c.read(voiceTrainingProvider)['seed_waheguru']!.sampleCount, n);
        expect(mic.streaming, isFalse, reason: 'microphone released on save');
      });
    }

    testWidgets('Undo last drops the previous recording', (tester) async {
      await open(tester);
      await tester.tap(find.text('Start recording'));
      await tester.pump();
      feedInChunks(toPcm(silence(600)), mic.push);
      say(tester, synthMantra(mantraA, seed: 1));
      say(tester, synthMantra(mantraA, seed: 2));
      await tester.pump();
      expect(find.text('Recording 3 of up to 7'), findsOneWidget);
      await tester.tap(find.text('Undo last'));
      await tester.pump();
      expect(find.text('Recording 2 of up to 7'), findsOneWidget);
    });

    testWidgets('a too-short sound is refused with a hint', (tester) async {
      await open(tester);
      await tester.tap(find.text('Start recording'));
      await tester.pump();
      feedInChunks(toPcm(silence(600)), mic.push);
      say(tester, tone(500, ms: 90, amp: 0.4));
      await tester.pump();
      expect(find.textContaining('too short'), findsOneWidget);
      expect(find.text('Recording 1 of up to 7'), findsOneWidget);
    });

    testWidgets('Stop keeps what was recorded: Continue, Save or Start over',
        (tester) async {
      final c = await open(tester);
      await tester.tap(find.text('Start recording'));
      await tester.pump();
      feedInChunks(toPcm(silence(600)), mic.push);
      for (var i = 1; i <= 3; i++) {
        say(tester, synthMantra(mantraA, seed: i));
        await tester.pump();
      }
      await tester.tap(find.text('Stop'));
      await tester.pump();
      expect(mic.streaming, isFalse);
      expect(find.text('Paused'), findsOneWidget);
      expect(find.text('Save 3 recordings'), findsOneWidget);
      expect(find.text('Continue recording'), findsOneWidget);
      expect(find.text('Start over'), findsOneWidget);

      await tester.tap(find.text('Continue recording'));
      await tester.pump();
      feedInChunks(toPcm(silence(600)), mic.push);
      await tester.pump();
      expect(find.text('Recording 4 of up to 7'), findsOneWidget,
          reason: 'the 3 already made are kept');
      await tester.tap(find.text('Stop'));
      await tester.pump();
      await tester.tap(find.text('Save 3 recordings'));
      await tester.pumpAndSettle();
      expect(c.read(voiceTrainingProvider)['seed_waheguru']!.sampleCount, 3);
    });

    testWidgets('leaving the screen releases the microphone', (tester) async {
      await open(tester);
      await tester.tap(find.text('Start recording'));
      await tester.pump();
      expect(mic.streaming, isTrue);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(mic.streaming, isFalse);
    });

    testWidgets('a trained mantra offers Add more samples, Re-train and Clear',
        (tester) async {
      final c = await open(tester, seedFor: 'seed_waheguru');
      expect(find.text('Trained · 3 recordings'), findsOneWidget);
      expect(find.text('Voice trained'), findsOneWidget);
      expect(find.text('Add more samples'), findsOneWidget);
      expect(find.text('Re-train'), findsOneWidget);
      expect(find.text('Clear training'), findsOneWidget);
      expect(find.text('Start recording'), findsNothing);
      expect(find.textContaining('Add up to 4 more'), findsOneWidget);

      await tester.tap(find.text('Clear training'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Clear training'));
      await tester.pumpAndSettle();
      expect(c.read(mantraTrainedProvider('seed_waheguru')), isFalse);
      expect(find.text('Voice not trained'), findsOneWidget);
      expect(find.text('Start recording'), findsOneWidget);
    });

    testWidgets('Add more samples APPENDS to the existing recordings',
        (tester) async {
      final c = await open(tester, seedFor: 'seed_waheguru');
      final before = c.read(voiceTrainingProvider)['seed_waheguru']!;
      final originalBytes = [for (final t in before.templates) t.toBytes()];

      await tester.tap(find.text('Add more samples'));
      await tester.pump();
      expect(find.text('Stay quiet for a moment…'), findsOneWidget);
      expect(find.textContaining('Adding to your 3 saved recordings'),
          findsOneWidget);
      feedInChunks(toPcm(silence(600)), mic.push);
      await tester.pump();
      expect(find.text('Recording 4 of up to 7'), findsOneWidget,
          reason: 'continues after the 3 already saved');
      expect(find.text('Record a sample to save'), findsOneWidget);

      say(tester, synthMantra(mantraA, seed: 11));
      await tester.pump();
      say(tester, synthMantra(mantraA, seed: 12, tempo: 1.05));
      await tester.pump();
      expect(find.text('Recording 6 of up to 7'), findsOneWidget);
      expect(find.text('Save 5 recordings'), findsOneWidget);

      await tester.tap(find.text('Save 5 recordings'));
      await tester.pumpAndSettle();
      final after = c.read(voiceTrainingProvider)['seed_waheguru']!;
      expect(after.sampleCount, 5, reason: '3 kept + 2 new, not replaced');
      for (var i = 0; i < 3; i++) {
        expect(after.templates[i].toBytes(), originalBytes[i],
            reason: 'the original recording $i is untouched');
      }
      expect(find.textContaining('Added 2 recordings to “Waheguru” (5 in total)'),
          findsOneWidget);
      expect(makeReloaded(c), 5, reason: 'and it is what Hive holds');
    });

    testWidgets('adding is capped at 7 in total', (tester) async {
      await open(tester, seedFor: 'seed_waheguru');
      await tester.tap(find.text('Add more samples'));
      await tester.pump();
      feedInChunks(toPcm(silence(600)), mic.push);
      for (var i = 1; i <= 4; i++) {
        say(tester, synthMantra(mantraA, seed: 20 + i));
        await tester.pump();
      }
      expect(find.text('All 7 recordings captured'), findsOneWidget);
      expect(find.text('Save 7 recordings'), findsOneWidget);
      expect(mic.streaming, isFalse);
    });

    testWidgets('at the maximum there is nothing to add, only Re-train',
        (tester) async {
      seedRealTraining('seed_waheguru', 7);
      await open(tester);
      expect(find.text('Trained · 7 recordings'), findsOneWidget);
      final add = find.widgetWithText(FilledButton, 'Add more samples');
      expect(tester.widget<FilledButton>(add).onPressed, isNull,
          reason: 'disabled');
      expect(find.textContaining('maximum of 7'), findsOneWidget);
      expect(find.text('Re-train'), findsOneWidget);
    });

    testWidgets('undo while adding never removes the saved recordings',
        (tester) async {
      final c = await open(tester, seedFor: 'seed_waheguru');
      await tester.tap(find.text('Add more samples'));
      await tester.pump();
      feedInChunks(toPcm(silence(600)), mic.push);
      say(tester, synthMantra(mantraA, seed: 11));
      await tester.pump();
      expect(find.text('Undo last'), findsOneWidget);
      await tester.tap(find.text('Undo last'));
      await tester.pump();
      expect(find.text('Undo last'), findsNothing, reason: 'only new ones');
      expect(find.text('Recording 4 of up to 7'), findsOneWidget);
      expect(c.read(voiceTrainingProvider)['seed_waheguru']!.sampleCount, 3);
    });

    testWidgets('Re-train REPLACES all the old recordings', (tester) async {
      final c = await open(tester, seedFor: 'seed_waheguru');
      final before = c.read(voiceTrainingProvider)['seed_waheguru']!.trainedAt;
      await tester.tap(find.text('Re-train'));
      await tester.pump();
      expect(find.textContaining('Adding to your'), findsNothing);
      feedInChunks(toPcm(silence(600)), mic.push);
      await tester.pump();
      expect(find.text('Recording 1 of up to 7'), findsOneWidget,
          reason: 'starts from zero');
      for (var i = 1; i <= 4; i++) {
        say(tester, synthMantra(mantraB, seed: i));
        await tester.pump();
      }
      await tester.tap(find.text('Save 4 recordings'));
      await tester.pumpAndSettle();
      final after = c.read(voiceTrainingProvider)['seed_waheguru']!;
      expect(after.sampleCount, 4, reason: 'the 3 old ones are gone');
      expect(after.trainedAt.isAfter(before), isTrue);
      expect(find.textContaining('Voice trained for “Waheguru” (4 recordings)'),
          findsOneWidget);
    });

    testWidgets('opening with addMore starts recording straight away',
        (tester) async {
      seedTrainedVoice('seed_waheguru');
      tallScreen(tester);
      final c = ProviderContainer(
          overrides: testOverrides(voice: voice, volume: volume, pcm: mic));
      addTearDown(c.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          home: VoiceTrainingScreen(
            mantra: c
                .read(mantraLibraryProvider)
                .firstWhere((m) => m.id == 'seed_waheguru'),
            addMore: true,
          ),
        ),
      ));
      await tester.pump();
      await tester.pump();
      expect(mic.starts, 1);
      expect(find.text('Stay quiet for a moment…'), findsOneWidget);
      expect(find.textContaining('Adding to your 3 saved recordings'),
          findsOneWidget);
    });

    testWidgets('permission denied: says why and offers Try again',
        (tester) async {
      mic.result = VoiceStartResult.denied;
      await open(tester);
      await tester.tap(find.text('Start recording'));
      await tester.pump();
      expect(find.text('Cannot use the microphone'), findsOneWidget);
      expect(find.textContaining('permission was denied'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Open Settings'), findsNothing);

      mic.result = VoiceStartResult.started;
      await tester.tap(find.text('Try again'));
      await tester.pump();
      expect(find.text('Stay quiet for a moment…'), findsOneWidget);
    });

    testWidgets('blocked permission points to Settings', (tester) async {
      mic.result = VoiceStartResult.permanentlyDenied;
      await open(tester);
      await tester.tap(find.text('Start recording'));
      await tester.pump();
      expect(find.textContaining('blocked'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);
    });

    testWidgets('no microphone: the honest message', (tester) async {
      mic.result = VoiceStartResult.unavailable;
      await open(tester);
      await tester.tap(find.text('Start recording'));
      await tester.pump();
      expect(find.text('No microphone available on this device'),
          findsOneWidget);
    });
  });
}
