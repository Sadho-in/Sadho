import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

enum VoiceStartResult {
  started,

  /// Microphone permission refused (can be asked again).
  denied,

  /// Microphone permission refused for good; only system Settings can undo it.
  permanentlyDenied,

  /// Web / desktop, or any platform without microphone capture support.
  unsupported,

  /// Supported platform, but no microphone (e.g. an emulator) or it failed.
  unavailable,
}

/// Which microphone Voice hears through. Trainings are kept per input: a
/// headset mic and the phone's own mic sound very different.
enum VoiceInput {
  /// The phone's built-in microphone.
  phone,

  /// A wired, USB or Bluetooth headset / earphones.
  headset,

  /// Not known (trainings made before P5.1, or the phone would not say).
  unknown,
}

/// The input Android records from, given the connected input devices: a
/// headset whenever one is connected (Android routes the default source to
/// it), otherwise the phone's own microphone.
VoiceInput voiceInputFrom(Iterable<InputDeviceType> types) {
  const headsets = {
    InputDeviceType.wiredHeadset,
    InputDeviceType.usb,
    InputDeviceType.bluetoothSco,
    InputDeviceType.bluetoothLe,
  };
  if (types.any(headsets.contains)) return VoiceInput.headset;
  if (types.contains(InputDeviceType.builtIn)) return VoiceInput.phone;
  return VoiceInput.unknown;
}

/// The recording settings Voice uses (training, calibration and counting).
///
/// Android audio source: VOICE_RECOGNITION. Until P5.1 it was the default
/// source (MediaRecorder.AudioSource.DEFAULT, which is MIC): on many phones,
/// Samsung among them, the built-in mic then gets the call-style processing
/// (heavy noise suppression and automatic gain) that squashes a soft, steady
/// chant into near silence, while a headset mic bypasses it; that is why Voice
/// counted with wired earphones and barely with the phone's own mic.
/// VOICE_RECOGNITION is tuned for speech recognisers: flat gain, no noise
/// suppression, so the chant's level and spectrum reach the matcher intact.
/// Still 16 kHz mono PCM16 (the matcher's format).
const voiceRecordConfig = RecordConfig(
  encoder: AudioEncoder.pcm16bits,
  sampleRate: 16000,
  numChannels: 1,
  androidConfig: AndroidRecordConfig(
    audioSource: AndroidAudioSource.voiceRecognition,
  ),
);

/// A live microphone as 16 kHz mono PCM16 chunks. Voice counting and Voice
/// training both read from this, so tests can swap in scripted audio.
abstract class PcmInput {
  bool get isSupported;

  /// Asks for microphone access (first use) and starts streaming.
  /// [onSamples] gets each chunk of audio; [onError] is called with a
  /// user-facing message if capture dies on its own (nothing was ever heard,
  /// permission revoked mid-session).
  Future<VoiceStartResult> start({
    required void Function(Int16List samples) onSamples,
    required void Function(String message) onError,
  });

  Future<void> stop();

  /// The microphone that would be recorded from now.
  Future<VoiceInput> currentInput();
}

/// `record`-backed microphone (Android and iOS). Nothing here touches the
/// network: audio goes from the microphone to the on-device matcher only.
class DeviceRecordInput implements PcmInput {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _sub;
  Timer? _watchdog;

  /// A trailing odd byte from the previous chunk (samples are 2 bytes).
  int? _carry;

  @override
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<VoiceStartResult> start({
    required void Function(Int16List samples) onSamples,
    required void Function(String message) onError,
  }) async {
    if (!isSupported) return VoiceStartResult.unsupported;
    await stop();

    if (defaultTargetPlatform == TargetPlatform.android) {
      var status = await Permission.microphone.status;
      if (!status.isGranted) status = await Permission.microphone.request();
      if (status.isPermanentlyDenied) return VoiceStartResult.permanentlyDenied;
      if (!status.isGranted) return VoiceStartResult.denied;
    } else {
      // iOS asks once; after a refusal only Settings can change it.
      if (!await _recorder.hasPermission()) {
        return VoiceStartResult.permanentlyDenied;
      }
    }

    final Stream<Uint8List> stream;
    try {
      stream = await _recorder.startStream(voiceRecordConfig);
    } catch (e) {
      debugPrint('Microphone start failed: $e');
      return VoiceStartResult.unavailable;
    }

    var gotAudio = false;
    _carry = null;
    _sub = stream.listen(
      (bytes) {
        gotAudio = true;
        final samples = _toSamples(bytes);
        if (samples.isNotEmpty) onSamples(samples);
      },
      onError: (Object e) {
        debugPrint('Microphone stream error: $e');
        onError('Microphone access was lost, so voice counting stopped.');
      },
    );
    // A device without a working microphone can start "successfully" yet never
    // deliver audio. Say so instead of listening to nothing.
    _watchdog = Timer(const Duration(seconds: 3), () {
      if (!gotAudio) {
        unawaited(stop());
        onError('No microphone available on this device');
      }
    });
    return VoiceStartResult.started;
  }

  Int16List _toSamples(Uint8List bytes) {
    var data = bytes;
    if (_carry != null) {
      data = Uint8List(bytes.length + 1)
        ..[0] = _carry!
        ..setRange(1, bytes.length + 1, bytes);
      _carry = null;
    }
    if (data.length.isOdd) {
      _carry = data[data.length - 1];
      data = Uint8List.sublistView(data, 0, data.length - 1);
    }
    final view = ByteData.sublistView(data);
    final out = Int16List(data.length ~/ 2);
    for (var i = 0; i < out.length; i++) {
      out[i] = view.getInt16(i * 2, Endian.little);
    }
    return out;
  }

  @override
  Future<void> stop() async {
    _watchdog?.cancel();
    _watchdog = null;
    final sub = _sub;
    _sub = null;
    await sub?.cancel();
    try {
      if (await _recorder.isRecording()) await _recorder.stop();
    } catch (e) {
      debugPrint('Microphone stop failed: $e');
    }
  }

  @override
  Future<VoiceInput> currentInput() async {
    if (!isSupported) return VoiceInput.unknown;
    try {
      final devices = await _recorder.listInputDevices();
      return voiceInputFrom(devices.map((d) => d.type));
    } catch (e) {
      debugPrint('Could not list the microphones: $e');
      return VoiceInput.unknown;
    }
  }

  Future<void> dispose() async {
    await stop();
    await _recorder.dispose();
  }
}

final pcmInputProvider = Provider<PcmInput>((ref) {
  final input = DeviceRecordInput();
  ref.onDispose(() => unawaited(input.dispose()));
  return input;
});
