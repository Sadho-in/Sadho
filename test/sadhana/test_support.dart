import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/calendar/application/now_provider.dart';
import 'package:advance_calendar/features/sadhana/application/voice_training_provider.dart';
import 'package:advance_calendar/features/sadhana/data/ringtone.dart';
import 'package:advance_calendar/features/sadhana/services/feedback_service.dart';
import 'package:advance_calendar/features/sadhana/services/pcm_input.dart';
import 'package:advance_calendar/features/sadhana/services/voice_counter_service.dart';
import 'package:advance_calendar/features/sadhana/services/volume_button_service.dart';
import 'package:advance_calendar/features/sadhana/voice/match_model.dart';
import 'package:advance_calendar/features/sadhana/voice/mfcc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../calendar/calendar_support.dart' show FakeNow;

class FakeFeedback implements FeedbackService {
  int milestones = 0;
  int completions = 0;

  @override
  Future<void> milestone() async => milestones++;

  @override
  Future<void> complete() async => completions++;

  @override
  Future<void> previewRingtone(Ringtone ringtone) async {}

  @override
  Future<void> previewVibration({required bool strong}) async {}
}

/// Fresh in-memory storage; call from setUp.
void resetStorage() => AppStorage.useMemoryForTests();

/// Scriptable stand-in for the Voice matcher (mic + templates + DTW).
class FakeVoice implements VoiceCounterService {
  FakeVoice({this.supported = true, this.result = VoiceStartResult.started});

  final bool supported;
  VoiceStartResult result;
  int starts = 0;
  int stops = 0;
  bool listening = false;
  MatchModel? lastModel;
  double? lastSensitivity;
  void Function(VoiceCandidate)? _onCandidate;
  void Function(String)? _onStopped;

  @override
  bool get isSupported => supported;

  @override
  Future<VoiceStartResult> start({
    required MatchModel model,
    required double sensitivity,
    required void Function(VoiceCandidate candidate) onCandidate,
    required void Function(String message) onStopped,
  }) async {
    starts++;
    lastModel = model;
    lastSensitivity = sensitivity;
    if (result != VoiceStartResult.started) return result;
    listening = true;
    _onCandidate = onCandidate;
    _onStopped = onStopped;
    return result;
  }

  @override
  void setSensitivity(double value) => lastSensitivity = value;

  @override
  Future<void> stop() async {
    stops++;
    listening = false;
  }

  /// The user chants their trained mantra once (a match).
  void hear() => _onCandidate?.call(
      const VoiceCandidate(matched: true, distance: 1.0, threshold: 2.0));

  /// Some other sound is heard (no match).
  void hearOther() => _onCandidate?.call(
      const VoiceCandidate(matched: false, distance: 4.0, threshold: 2.0));

  /// The engine gives up on its own.
  void engineGivesUp(String message) => _onStopped?.call(message);
}

/// A microphone whose start() (e.g. the permission dialog) is still pending
/// until [answer] is called.
class PendingVoice extends FakeVoice {
  final _gate = Completer<VoiceStartResult>();

  @override
  Future<VoiceStartResult> start({
    required MatchModel model,
    required double sensitivity,
    required void Function(VoiceCandidate candidate) onCandidate,
    required void Function(String message) onStopped,
  }) async {
    starts++;
    final r = await _gate.future;
    if (r == VoiceStartResult.started) {
      listening = true;
      _onCandidate = onCandidate;
      _onStopped = onStopped;
    }
    return r;
  }

  void answer(VoiceStartResult r) => _gate.complete(r);
}

/// Scriptable microphone: tests push PCM into it as if the mic delivered it.
class FakePcmInput implements PcmInput {
  FakePcmInput({this.supported = true, this.result = VoiceStartResult.started});

  final bool supported;
  VoiceStartResult result;
  int starts = 0;
  int stops = 0;
  bool streaming = false;
  void Function(Int16List)? _onSamples;
  void Function(String)? _onError;

  @override
  bool get isSupported => supported;

  @override
  Future<VoiceStartResult> start({
    required void Function(Int16List samples) onSamples,
    required void Function(String message) onError,
  }) async {
    starts++;
    if (result != VoiceStartResult.started) return result;
    streaming = true;
    _onSamples = onSamples;
    _onError = onError;
    return result;
  }

  @override
  Future<void> stop() async {
    stops++;
    streaming = false;
  }

  /// Audio arriving from the microphone (dropped when not streaming).
  void push(Int16List pcm) {
    if (streaming) _onSamples?.call(pcm);
  }

  /// The microphone dies on its own.
  void fail(String message) => _onError?.call(message);
}

/// Stores a trained voice (3 made-up templates) for [mantraId], as if the user
/// had finished training. Works before or after a container is created.
void seedTrainedVoice([String mantraId = 'seed_om_namah_shivaya', int samples = 3]) {
  final templates = [
    for (var k = 0; k < samples; k++)
      MfccSequence(
        40,
        mfccDims,
        Float64List.fromList([
          for (var i = 0; i < 40 * mfccDims; i++) math.sin(i * 0.1 + k * 0.05),
        ]),
      ),
  ];
  final training = VoiceTraining(
      mantraId: mantraId, templates: templates, trainedAt: DateTime(2026, 9, 1));
  AppStorage.voiceTemplates
      .put(mantraId, {'mantraId': mantraId, ...training.toMap()});
}

/// Scriptable stand-in for volume-key capture.
class FakeVolume implements VolumeButtonService {
  FakeVolume({this.supported = true, this.startOk = true});

  final bool supported;
  final bool startOk;
  int starts = 0;
  int stops = 0;
  bool capturing = false;
  VoidCallback? _onPress;

  @override
  bool get isSupported => supported;

  @override
  Future<bool> start(VoidCallback onPress) async {
    starts++;
    if (!startOk) return false;
    capturing = true;
    _onPress = onPress;
    return true;
  }

  @override
  Future<void> stop() async {
    stops++;
    capturing = false;
  }

  /// A hardware volume key press (only delivered while capturing).
  void press() {
    if (capturing) _onPress?.call();
  }
}

/// Provider overrides that replace every plugin-backed service.
List<Override> testOverrides({
  FakeFeedback? feedback,
  FakeVoice? voice,
  FakeVolume? volume,
  FakePcmInput? pcm,
}) =>
    [
      pcmInputProvider.overrideWithValue(pcm ?? FakePcmInput()),
      // The real clock ticks on a timer, which widget tests must not leave
      // running (and a fixed date keeps them independent of today's).
      nowProvider.overrideWith(() => FakeNow(DateTime(2026, 9, 21, 8, 0))),
      feedbackServiceProvider.overrideWithValue(feedback ?? FakeFeedback()),
      voiceCounterServiceProvider.overrideWithValue(voice ?? FakeVoice()),
      volumeButtonServiceProvider.overrideWithValue(volume ?? FakeVolume()),
    ];
