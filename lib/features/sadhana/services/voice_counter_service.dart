import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../voice/match_model.dart';
import '../voice/voice_engine.dart';
import 'pcm_input.dart';

export 'pcm_input.dart' show VoiceStartResult;

/// Voice counting (Beta): counts ONLY the user's trained mantra, on-device.
///
/// The microphone stream is cut into utterances at silence; each one is turned
/// into MFCC features and compared (DTW) with the templates recorded during
/// training. A match counts immediately; anything else is ignored. Nothing is
/// sent anywhere and no audio is kept.
///
/// TODO(later-phase): Picovoice Porcupine custom wake-word models (or another
/// keyword-spotting engine) would be more robust in noise and for very fast
/// chanting; cloud recognition is deliberately not used.
abstract class VoiceCounterService {
  bool get isSupported;

  /// Asks for microphone access (first use) and starts listening for the
  /// mantra described by [model].
  ///
  /// [onCandidate] fires for every detected utterance, matched or not (the
  /// caller counts only matches). [onStopped] is called with a user-facing
  /// message if listening gives up on its own (no audio, permission revoked).
  Future<VoiceStartResult> start({
    required MatchModel model,
    required double sensitivity,
    required void Function(VoiceCandidate candidate) onCandidate,
    required void Function(String message) onStopped,
  });

  /// Applies a new Strict ↔ Lenient value to a running session.
  void setSensitivity(double value);

  Future<void> stop();
}

class DeviceVoiceCounterService
    with WidgetsBindingObserver
    implements VoiceCounterService {
  DeviceVoiceCounterService(this._input);

  final PcmInput _input;

  VoiceEngine? _engine;
  void Function(String)? _onStopped;
  bool _wanted = false;
  bool _suspended = false;

  @override
  bool get isSupported => _input.isSupported;

  @override
  Future<VoiceStartResult> start({
    required MatchModel model,
    required double sensitivity,
    required void Function(VoiceCandidate candidate) onCandidate,
    required void Function(String message) onStopped,
  }) async {
    if (!isSupported) return VoiceStartResult.unsupported;
    await stop();

    final engine = VoiceEngine(
      model: model,
      sensitivity: sensitivity,
      onCandidate: onCandidate,
    );
    _engine = engine;
    _onStopped = onStopped;
    _wanted = true;
    _suspended = false;
    final result = await _open(engine);
    if (result != VoiceStartResult.started) {
      _wanted = false;
      _engine = null;
      return result;
    }
    WidgetsBinding.instance.addObserver(this);
    return result;
  }

  Future<VoiceStartResult> _open(VoiceEngine engine) => _input.start(
        onSamples: engine.addPcm,
        onError: _giveUp,
      );

  @override
  void setSensitivity(double value) => _engine?.sensitivity = value;

  @override
  Future<void> stop() async {
    _wanted = false;
    _suspended = false;
    _engine = null;
    WidgetsBinding.instance.removeObserver(this);
    await _input.stop();
  }

  void _giveUp(String message) {
    if (!_wanted) return;
    final callback = _onStopped;
    unawaited(stop());
    callback?.call(message);
  }

  // The OS does not let apps keep the microphone in the background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final engine = _engine;
    if (!_wanted || engine == null) return;
    if (state == AppLifecycleState.paused) {
      _suspended = true;
      unawaited(_input.stop());
    } else if (state == AppLifecycleState.resumed && _suspended) {
      _suspended = false;
      engine.reset(); // the room may have changed: re-measure the noise floor
      unawaited(_open(engine).then((r) {
        if (r != VoiceStartResult.started) {
          _giveUp('The microphone could not restart, so voice counting stopped.');
        }
      }));
    }
  }
}

final voiceCounterServiceProvider = Provider<VoiceCounterService>((ref) {
  final service = DeviceVoiceCounterService(ref.watch(pcmInputProvider));
  ref.onDispose(() => unawaited(service.stop()));
  return service;
});
