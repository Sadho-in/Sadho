import 'dart:math' as math;

import 'package:advance_calendar/features/sadhana/presentation/widgets/voice_panel.dart';
import 'package:advance_calendar/features/sadhana/application/voice_training_provider.dart';
import 'package:advance_calendar/features/sadhana/voice/calibration.dart';
import 'package:advance_calendar/features/sadhana/voice/match_model.dart';
import 'package:advance_calendar/features/sadhana/voice/mfcc.dart';
import 'package:advance_calendar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'synth.dart';
import 'test_support.dart';

/// P5.1-6: Voice counts the mantra, not other words. The calibration's
/// second step ("Now say something else 5 times") puts the threshold between
/// the mantra and the other words, closer to the mantra; the default slider
/// is one step stricter; an uncalibrated mantra is prompted to calibrate.
void main() {
  final extractor = MfccExtractor();
  MfccSequence mfccOf(List<Syllable> s, {int seed = 1, double tempo = 1}) =>
      extractor.extract(loudnessNormalized(concat([
        silence(100),
        synthMantra(s, seed: seed, tempo: tempo),
        silence(100),
      ])));

  MatchModel trained([double? threshold]) => MatchModel([
        for (var k = 1; k <= 4; k++) mfccOf(mantraA, seed: k, tempo: 0.94 + k * 0.03),
      ], calibratedThreshold: threshold);

  group('the threshold with other words', () {
    test('sits between the two groups, closer to the mantra', () {
      final same = [0.8, 1.1, 0.9, 1.3, 1.0];
      final others = [2.2, 2.9, 3.4, double.infinity, 2.5];
      final t = calibrateThreshold(same: same, different: [4.5], others: others)!;
      expect(t, greaterThanOrEqualTo(1.3));
      expect(t, lessThan(2.2));
      expect(t - 1.3, lessThan(2.2 - t), reason: 'closer to the mantra side');
    });

    test('other words closer than the room\'s noise raise the rejection', () {
      final same = [0.8, 1.1, 1.3];
      final noiseOnly = calibrateThreshold(same: same, different: [4.0])!;
      final withOthers =
          calibrateThreshold(same: same, different: [4.0], others: [2.0, 2.4])!;
      expect(withOthers, lessThan(noiseOnly));
    });

    test('on synthetic speech: the mantra counts, other "words" do not', () async {
      final mic = FakePcmInput();
      final c = VoiceCalibrator(input: mic, model: trained());
      await c.start();
      feedInChunks(toPcm(silence(calibrationQuietMs + 100)), mic.push);
      for (var i = 0; i < calibrationReps; i++) {
        feedInChunks(
            toPcm(concat([
              synthMantra(mantraA, seed: 100 + i, tempo: 0.95 + 0.01 * i),
              silence(600, seed: 200 + i),
            ])),
            mic.push);
      }
      expect(c.phase, CalibrationPhase.others);
      for (var i = 0; i < calibrationOtherReps; i++) {
        feedInChunks(
            toPcm(concat([
              synthMantra(i.isEven ? mantraB : mantraC, seed: 300 + i),
              silence(600, seed: 400 + i),
            ])),
            mic.push);
      }
      expect(c.phase, CalibrationPhase.done);
      final t = c.threshold!;
      final sameMax = c.heard.map((h) => h.distance).reduce(math.max);
      final otherMin = c.others.where((d) => d.isFinite).fold(double.infinity, math.min);
      expect(t, greaterThanOrEqualTo(sameMax));
      expect(t, lessThan(otherMin));
      expect(c.mantraCounted, calibrationReps);
      expect(c.othersCounted, 0);

      // The calibrated model, at the default slider: the mantra counts, a
      // different "word" of similar length does not.
      final model = trained(t);
      expect(model.evaluate(mfccOf(mantraA, seed: 77), defaultVoiceSensitivity).matched,
          isTrue);
      expect(model.evaluate(mfccOf(mantraB, seed: 78), defaultVoiceSensitivity).matched,
          isFalse);
      c.dispose();
    });

    test('the step can be skipped: then the mantra and the room decide', () async {
      final mic = FakePcmInput();
      final c = VoiceCalibrator(input: mic, model: trained(), reps: 2);
      await c.start();
      feedInChunks(toPcm(silence(calibrationQuietMs + 100)), mic.push);
      for (var i = 0; i < 2; i++) {
        feedInChunks(
            toPcm(concat([synthMantra(mantraA, seed: 10 + i), silence(600)])),
            mic.push);
      }
      expect(c.phase, CalibrationPhase.others);
      c.skipOthers();
      expect(c.phase, CalibrationPhase.done);
      expect(c.skippedOthers, isTrue);
      expect(c.threshold, isNotNull);
      expect(mic.streaming, isFalse);
      c.dispose();
    });
  });

  test('the default slider is one step toward Strict', () {
    expect(defaultVoiceSensitivity, 0.25);
    final m = trained();
    expect(m.thresholdFor(defaultVoiceSensitivity), lessThan(m.thresholdFor(0.5)));
    // Calibrated: the default is exactly the calibrated threshold.
    expect(trained(1.6).thresholdFor(defaultVoiceSensitivity), closeTo(1.6, 1e-9));
  });

  group('the Voice panel', () {
    Future<ProviderContainer> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = ProviderContainer(overrides: testOverrides());
      addTearDown(c.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SingleChildScrollView(child: VoicePanel())),
        ),
      ));
      await tester.pump();
      return c;
    }

    final prompt = find.byKey(const ValueKey('voice-calibrate-prompt'));

    testWidgets('trained, not calibrated: "Calibrate for better accuracy"',
        (tester) async {
      resetStorage();
      seedTrainedVoice();
      final c = await pump(tester);
      expect(prompt, findsOneWidget);
      expect(find.text('Calibrate for better accuracy'), findsOneWidget);
      expect(find.byKey(const ValueKey('voice-calibrate')), findsOneWidget);
      await c
          .read(voiceTrainingProvider.notifier)
          .setCalibration('seed_om_namah_shivaya', 1.5);
      await tester.pump();
      expect(prompt, findsNothing);
    });

    testWidgets('not trained: no calibration prompt; the honest note is there',
        (tester) async {
      resetStorage();
      await pump(tester);
      expect(prompt, findsNothing);
      expect(
          find.text('Voice learns how YOUR chant of this mantra sounds. '
              'It can\'t check pronunciation against the written text.'),
          findsOneWidget);
    });
  });
}
