import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/sadhana/application/mantra_library_provider.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/application/voice_training_provider.dart';
import 'package:advance_calendar/features/sadhana/presentation/voice_calibration_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/voice_training_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/mode_section.dart';
import 'package:advance_calendar/features/sadhana/voice/calibration.dart';
import 'package:advance_calendar/features/sadhana/voice/mfcc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'synth.dart';
import 'test_support.dart';

/// P5-5: the calibration step on screen: after training, from the Voice
/// panel, hearing the 11 repetitions, and saving.
void main() {
  late FakePcmInput mic;

  setUp(() {
    resetStorage();
    mic = FakePcmInput();
  });

  void seedRealTraining(String mantraId) {
    final ex = MfccExtractor();
    AppStorage.voiceTemplates.put(mantraId, {
      'mantraId': mantraId,
      ...VoiceTraining(
        mantraId: mantraId,
        templates: [
          for (var k = 1; k <= 4; k++)
            ex.extract(loudnessNormalized(concat([
              silence(100),
              synthMantra(mantraA, seed: k, tempo: 0.94 + k * 0.03),
              silence(100),
            ]))),
        ],
        trainedAt: DateTime(2026, 9, 1),
      ).toMap(),
    });
  }

  Future<ProviderContainer> pump(WidgetTester tester, Widget Function(ProviderContainer) home) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = ProviderContainer(overrides: testOverrides(pcm: mic));
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(home: Scaffold(body: home(c))),
    ));
    return c;
  }

  Widget opener(ProviderContainer c, String id) => Builder(
        builder: (context) => TextButton(
          onPressed: () => openVoiceCalibration(context,
              c.read(mantraLibraryProvider).firstWhere((m) => m.id == id)),
          child: const Text('open'),
        ),
      );

  void chant(int seed) => feedInChunks(
      toPcm(concat([synthMantra(mantraA, seed: seed), silence(700, seed: seed)])),
      mic.push);

  testWidgets('hears 11 repetitions, shows each, then saves the threshold',
      (tester) async {
    seedRealTraining('seed_waheguru');
    final c = await pump(tester, (c) => opener(c, 'seed_waheguru'));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Calibrate voice'), findsOneWidget);
    expect(find.textContaining('Chant your mantra 11 times'), findsWidgets);
    expect(find.textContaining('Nothing is recorded or kept'), findsOneWidget);
    expect(mic.starts, 0, reason: 'nothing listens until asked');

    await tester.tap(find.byKey(const ValueKey('calibration-start')));
    await tester.pump();
    expect(find.text('Stay quiet for a moment…'), findsOneWidget);
    feedInChunks(toPcm(silence(calibrationQuietMs + 100)), mic.push);
    await tester.pump();
    expect(find.text('Heard 0 of 11'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      chant(100 + i);
    }
    await tester.pump();
    expect(find.text('Heard 3 of 11'), findsOneWidget);
    for (var i = 3; i < 11; i++) {
      chant(100 + i);
    }
    await tester.pump();
    expect(find.text('Calibrated'), findsOneWidget);
    expect(find.textContaining('All 11 repetitions will count'), findsOneWidget);
    expect(mic.streaming, isFalse);

    await tester.tap(find.byKey(const ValueKey('calibration-save')));
    await tester.pumpAndSettle();
    expect(find.byType(VoiceCalibrationScreen), findsNothing);
    expect(find.textContaining('Calibration saved for'), findsOneWidget);
    final t = c.read(voiceTrainingProvider)['seed_waheguru']!;
    expect(t.calibratedThreshold, isNotNull);
    expect(t.toModel().thresholdFor(0.5), closeTo(t.calibratedThreshold!, 1e-9));
  });

  testWidgets('Later leaves without changing anything', (tester) async {
    seedRealTraining('seed_waheguru');
    final c = await pump(tester, (c) => opener(c, 'seed_waheguru'));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
    expect(find.byType(VoiceCalibrationScreen), findsNothing);
    expect(c.read(voiceTrainingProvider)['seed_waheguru']!.calibratedThreshold, isNull);
  });

  testWidgets('opening it pauses a listening session (one microphone)',
      (tester) async {
    seedRealTraining('seed_om_namah_shivaya');
    final c = await pump(tester, (c) => opener(c, 'seed_om_namah_shivaya'));
    c.read(sadhanaSessionProvider.notifier)
      ..setMode(CountMode.voice)
      ..toggleRunning();
    await tester.pump();
    expect(c.read(sadhanaSessionProvider).running, isTrue);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(c.read(sadhanaSessionProvider).running, isFalse);
  });

  testWidgets('the Voice panel offers Calibrate, then Re-calibrate',
      (tester) async {
    seedRealTraining('seed_om_namah_shivaya');
    final c = await pump(tester, (_) => const SingleChildScrollView(child: ModeSection()));
    c.read(sadhanaSessionProvider.notifier).setMode(CountMode.voice);
    await tester.pump();
    expect(find.text('Calibrate'), findsOneWidget);
    await c
        .read(voiceTrainingProvider.notifier)
        .setCalibration('seed_om_namah_shivaya', 1.5);
    await tester.pump();
    expect(find.text('Re-calibrate'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('voice-calibrate')));
    await tester.pumpAndSettle();
    expect(find.byType(VoiceCalibrationScreen), findsOneWidget);
  });

  testWidgets('saving a training goes straight on to the calibration step',
      (tester) async {
    await pump(
        tester,
        (c) => Builder(
              builder: (context) => TextButton(
                onPressed: () => openVoiceTraining(
                    context,
                    c
                        .read(mantraLibraryProvider)
                        .firstWhere((m) => m.id == 'seed_waheguru')),
                child: const Text('train'),
              ),
            ));
    await tester.tap(find.text('train'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start recording'));
    await tester.pump();
    feedInChunks(toPcm(silence(600)), mic.push);
    for (var i = 1; i <= 3; i++) {
      feedInChunks(
          toPcm(concat([synthMantra(mantraA, seed: i), silence(900, seed: 9)])),
          mic.push);
      await tester.pump();
    }
    await tester.tap(find.text('Save 3 recordings'));
    await tester.pumpAndSettle();
    expect(find.byType(VoiceTrainingScreen), findsNothing);
    expect(find.byType(VoiceCalibrationScreen), findsOneWidget);
    expect(find.textContaining('Chant your mantra 11 times'), findsWidgets);
  });
}
