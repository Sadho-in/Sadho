import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../application/completion_settings_provider.dart';
import '../data/ringtone.dart';

/// Haptic + audio feedback for Sadhana sessions.
///
/// Vibration and ringtone are gated by *separate* settings; either can be on
/// without the other.
abstract class FeedbackService {
  /// Every 108 counts. Vibration only.
  Future<void> milestone();

  /// Target reached. Stronger buzz (if enabled) and ringtone (if enabled).
  Future<void> complete();

  /// Settings-screen previews; these ignore the on/off switches.
  Future<void> previewVibration({required bool strong});
  Future<void> previewRingtone(Ringtone ringtone);
}

class DeviceFeedbackService implements FeedbackService {
  DeviceFeedbackService(this._settings);

  final CompletionSettings Function() _settings;
  final AudioPlayer _player = AudioPlayer();
  bool? _hasVibrator;
  bool? _hasAmplitude;

  /// Android amplitude (1..255) for each of the five levels.
  static const _amplitudes = [40, 90, 150, 210, 255];

  static int amplitudeFor(int level) => _amplitudes[level.clamp(1, 5) - 1];

  @override
  Future<void> milestone() async {
    final s = _settings();
    if (s.vibrationEnabled) await _buzz(s.vibrationLevel, strong: false);
  }

  @override
  Future<void> complete() async {
    final s = _settings();
    // Independent switches: neither call depends on the other.
    if (s.vibrationEnabled) await _buzz(s.vibrationLevel, strong: true);
    if (s.ringtoneEnabled) await _play(s.ringtone);
  }

  @override
  Future<void> previewVibration({required bool strong}) =>
      _buzz(_settings().vibrationLevel, strong: strong);

  @override
  Future<void> previewRingtone(Ringtone ringtone) => _play(ringtone);

  Future<void> _buzz(int level, {required bool strong}) async {
    try {
      _hasVibrator ??= await Vibration.hasVibrator();
      if (_hasVibrator != true) return;
      _hasAmplitude ??= await Vibration.hasAmplitudeControl();

      final amp = amplitudeFor(level);
      // The target buzz is one level stronger and a double pulse, so it is
      // always distinguishable from the 108-count milestone.
      final strongAmp = amplitudeFor(level + 1);

      if (_hasAmplitude == true) {
        if (strong) {
          await Vibration.vibrate(
            pattern: [0, 350, 120, 600],
            intensities: [0, strongAmp, 0, strongAmp],
          );
        } else {
          await Vibration.vibrate(duration: 180, amplitude: amp);
        }
      } else {
        // No amplitude control: intensity is approximated by duration.
        final ms = 60 + level * 40;
        if (strong) {
          await Vibration.vibrate(pattern: [0, ms * 2, 120, ms * 3]);
        } else {
          await Vibration.vibrate(duration: ms);
        }
      }
    } catch (e) {
      debugPrint('Vibration unavailable: $e');
    }
  }

  Future<void> _play(Ringtone ringtone) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(ringtone.asset));
    } catch (e) {
      debugPrint('Ringtone playback failed: $e');
    }
  }
}

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  final service = DeviceFeedbackService(
    () => ref.read(completionSettingsProvider),
  );
  return service;
});
