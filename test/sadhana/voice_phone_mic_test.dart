import 'dart:typed_data';

import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/application/voice_training_provider.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/voice_panel.dart';
import 'package:advance_calendar/features/sadhana/services/pcm_input.dart';
import 'package:advance_calendar/features/sadhana/voice/mfcc.dart';
import 'package:advance_calendar/features/sadhana/voice/utterance_detector.dart';
import 'package:advance_calendar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:record/record.dart';

import 'synth.dart';
import 'test_support.dart';

/// P5.1-5: Voice on the phone's own microphone. The speech-tuned
/// VOICE_RECOGNITION source; trainings kept per microphone (phone / headset);
/// a live level bar; and an onset level that adapts to a quiet built-in mic.
void main() {
  setUp(resetStorage);

  group('recording', () {
    test('VOICE_RECOGNITION, still 16 kHz mono PCM16', () {
      expect(voiceRecordConfig.androidConfig.audioSource,
          AndroidAudioSource.voiceRecognition);
      expect(voiceRecordConfig.sampleRate, 16000);
      expect(voiceRecordConfig.numChannels, 1);
      expect(voiceRecordConfig.encoder, AudioEncoder.pcm16bits);
    });

    test('which microphone: a headset when one is connected', () {
      expect(voiceInputFrom([InputDeviceType.builtIn]), VoiceInput.phone);
      expect(voiceInputFrom([InputDeviceType.builtIn, InputDeviceType.wiredHeadset]),
          VoiceInput.headset);
      expect(voiceInputFrom([InputDeviceType.builtIn, InputDeviceType.bluetoothSco]),
          VoiceInput.headset);
      expect(voiceInputFrom(const []), VoiceInput.unknown);
    });
  });

  group('one training per microphone', () {
    List<MfccSequence> templates(int n) => [
          for (var k = 0; k < n; k++)
            MfccSequence.fromBytes(MfccSequence(2, mfccDims,
                    Float64List.fromList(List.filled(2 * mfccDims, k + 1.0)))
                .toBytes())!,
        ];

    ProviderContainer make(FakePcmInput pcm) {
      final c = ProviderContainer(overrides: testOverrides(pcm: pcm));
      addTearDown(c.dispose);
      return c;
    }

    test('each set is used with its own microphone', () async {
      final pcm = FakePcmInput();
      final c = make(pcm);
      final n = c.read(voiceTrainingProvider.notifier);
      await n.save('m', templates(3), input: VoiceInput.phone);
      await n.save('m', templates(5), input: VoiceInput.headset);
      n.setCurrentInput(VoiceInput.phone);
      expect(c.read(voiceTrainingProvider)['m']!.sampleCount, 3);
      pcm.input = VoiceInput.headset; // earphones plugged in
      await n.refreshInput();
      expect(c.read(voiceTrainingProvider)['m']!.sampleCount, 5);
      expect(n.setsFor('m').keys,
          containsAll([VoiceInput.phone, VoiceInput.headset]));
    });

    test('an older training (unknown input) is still used, without a warning',
        () async {
      seedTrainedVoice('m');
      final c = make(FakePcmInput());
      await c.read(voiceTrainingProvider.notifier).refreshInput();
      expect(c.read(mantraTrainedProvider('m')), isTrue);
      expect(c.read(voiceTrainingProvider)['m']!.input, VoiceInput.unknown);
      expect(c.read(trainedWithOtherInputProvider('m')), isNull);
    });

    test('trained only with earphones, phone mic now: used, and says so',
        () async {
      final c = make(FakePcmInput());
      final n = c.read(voiceTrainingProvider.notifier);
      await n.save('m', templates(3), input: VoiceInput.headset);
      await n.refreshInput(); // the fake reports the phone's mic
      expect(c.read(mantraTrainedProvider('m')), isTrue);
      expect(c.read(trainedWithOtherInputProvider('m')), VoiceInput.headset);
    });

    test('kept across a restart, and Clear removes every set', () async {
      final first = make(FakePcmInput());
      await first
          .read(voiceTrainingProvider.notifier)
          .save('m', templates(3), input: VoiceInput.phone);
      await first
          .read(voiceTrainingProvider.notifier)
          .save('m', templates(4), input: VoiceInput.headset);
      final again = make(FakePcmInput());
      final n = again.read(voiceTrainingProvider.notifier);
      expect(n.setsFor('m').length, 2);
      await n.clear('m');
      expect(again.read(voiceTrainingProvider)['m'], isNull);
      expect(AppStorage.voiceTemplates.values, isEmpty);
    });
  });

  group('a quiet built-in microphone', () {
    // A quiet room on a phone's own mic: about -75 dBFS; a soft chant about
    // -55 dBFS (under the old fixed -50 dB minimum).
    final quietRoom = silence(800, noise: 0.0003);
    Float64List softChant(int seed) =>
        synthMantra(mantraA, gain: 0.006, noise: 0.0003, seed: seed);

    int heard(GateConfig config, Float64List audio) {
      var n = 0;
      final det =
          UtteranceDetector(config: config, onUtterance: (_) => n++);
      feedInChunks(toPcm(audio), det.addSamples);
      return n;
    }

    final chanting = concat([
      quietRoom,
      softChant(1),
      silence(600, noise: 0.0003, seed: 4),
      softChant(2),
      silence(600, noise: 0.0003, seed: 5),
    ]);

    test('a soft chant is heard now (the minimum follows the noise floor)', () {
      expect(heard(const GateConfig(), chanting), 2);
    });

    test('with the old fixed minimum it was not', () {
      expect(heard(const GateConfig(quietMicFloorDb: -50), chanting), 0);
    });

    test('the noise cues still reject a hiss at the same level', () {
      final hiss = concat([
        quietRoom,
        synthNoise(700, level: 0.006, seed: 9),
        silence(600, noise: 0.0003, seed: 6),
      ]);
      expect(heard(const GateConfig(), hiss), 0);
    });

    test('digital silence never lowers the minimum below -68 dB', () {
      final gate = EnergyGate();
      for (var i = 0; i < 60; i++) {
        gate.step(-110);
      }
      expect(gate.calibrated, isTrue);
      expect(gate.minOnsetDb, -68);
    });

    test('the level bar reads a soft chant on a quiet mic', () {
      expect(levelFromDb(-70), 0);
      expect(levelFromDb(-55), greaterThan(0.2));
      expect(levelFromDb(-10), 1);
    });
  });

  group('the Voice panel', () {
    Future<ProviderContainer> pump(WidgetTester tester, FakeVoice voice,
        FakePcmInput pcm) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = ProviderContainer(
          overrides: testOverrides(voice: voice, pcm: pcm));
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
      await tester.pump();
      return c;
    }

    testWidgets('a live level bar while Voice listens', (tester) async {
      seedTrainedVoice();
      final voice = FakeVoice();
      final c = await pump(tester, voice, FakePcmInput());
      expect(find.byKey(const ValueKey('voice-level')), findsNothing);
      c.read(sadhanaSessionProvider.notifier)
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const ValueKey('voice-level')), findsOneWidget);
      voice.level.value = 0.6;
      await tester.pump();
      final bar = tester.widget<LinearProgressIndicator>(find.descendant(
          of: find.byKey(const ValueKey('voice-level')),
          matching: find.byType(LinearProgressIndicator)));
      expect(bar.value, 0.6);
    });

    testWidgets('trained with earphones, phone mic now: says so, with Train',
        (tester) async {
      final pcm = FakePcmInput();
      final c = ProviderContainer(overrides: testOverrides(pcm: pcm));
      await c.read(voiceTrainingProvider.notifier).save(
          'seed_om_namah_shivaya',
          [
            for (var k = 0; k < 3; k++)
              MfccSequence(40, mfccDims,
                  Float64List.fromList(List.filled(40 * mfccDims, k + 1.0))),
          ],
          input: VoiceInput.headset);
      c.dispose();
      await pump(tester, FakeVoice(), pcm);
      expect(find.byKey(const ValueKey('voice-other-input')), findsOneWidget);
      expect(find.text('Trained with earphones — train again with the phone mic'),
          findsOneWidget);
      expect(find.byKey(const ValueKey('voice-train-this-input')), findsOneWidget);
    });
  });
}
