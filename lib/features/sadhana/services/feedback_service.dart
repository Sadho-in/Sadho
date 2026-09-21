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

  /// A tap that counted for nothing because the target is already reached:
  /// a very short tick (if vibration is on), on EVERY such tap, so the phone
  /// answers you instead of feeling dead. No sound.
  Future<void> acknowledge();

  /// Settings-screen previews; these ignore the on/off switches.
  Future<void> previewVibration({required bool strong});
  Future<void> previewRingtone(Ringtone ringtone);
}

/// The phone's vibrator. A seam so the intensity logic can be tested without
/// a phone (the real plugin only works on a device).
abstract class HapticsDriver {
  Future<bool> hasVibrator();

  /// Whether the strength (not just the length) of a buzz can be set. Many
  /// phones, including some Samsung models, cannot.
  Future<bool> hasAmplitudeControl();

  /// Either a single buzz ([duration], with [amplitude] 1..255 if supported) or
  /// a [pattern] of off/on lengths (with per-step [intensities] if supported).
  Future<void> vibrate({
    int duration = 0,
    int amplitude = -1,
    List<int> pattern = const [],
    List<int> intensities = const [],
  });
}

class PluginHaptics implements HapticsDriver {
  @override
  Future<bool> hasVibrator() => Vibration.hasVibrator();

  @override
  Future<bool> hasAmplitudeControl() => Vibration.hasAmplitudeControl();

  @override
  Future<void> vibrate({
    int duration = 0,
    int amplitude = -1,
    List<int> pattern = const [],
    List<int> intensities = const [],
  }) =>
      pattern.isNotEmpty
          ? Vibration.vibrate(pattern: pattern, intensities: intensities)
          : Vibration.vibrate(duration: duration, amplitude: amplitude);
}

/// Plays a bundled sound asset. A seam, like [HapticsDriver].
abstract class SoundDriver {
  Future<void> play(String asset);
  Future<void> stop();
}

/// Plays completion sounds on the ALARM stream.
///
/// `audioplayers` defaults to the media stream, so a phone whose media volume
/// is turned down (very common) would play the sound silently. A completion
/// bell is an alert, like an alarm or timer: it plays at the alarm volume, and
/// is not silenced by a muted media volume. The vibration already uses the
/// alarm usage, so the two behave the same way.
class PluginSound implements SoundDriver {
  PluginSound() : _player = AudioPlayer();

  final AudioPlayer _player;
  bool _configured = false;

  /// Alarm usage, "sonification" content (short alerts), ducking rather than
  /// taking over other audio.
  static final completionContext = AudioContext(
    android: AudioContextAndroid(
      usageType: AndroidUsageType.alarm,
      contentType: AndroidContentType.sonification,
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
  );

  @override
  Future<void> play(String asset) async {
    if (!_configured) {
      await _player.setAudioContext(completionContext);
      _configured = true;
    }
    await _player.play(AssetSource(asset));
  }

  @override
  Future<void> stop() => _player.stop();
}

final hapticsDriverProvider = Provider<HapticsDriver>((ref) => PluginHaptics());
final soundDriverProvider = Provider<SoundDriver>((ref) => PluginSound());

class DeviceFeedbackService implements FeedbackService {
  DeviceFeedbackService(
    this._settings, {
    HapticsDriver? haptics,
    SoundDriver? sound,
  })  : _haptics = haptics ?? PluginHaptics(),
        _sound = sound ?? PluginSound();

  final CompletionSettings Function() _settings;
  final HapticsDriver _haptics;
  final SoundDriver _sound;
  bool? _hasVibrator;
  bool? _hasAmplitude;

  /// Android amplitude (1..255) for each of the five levels.
  static const _amplitudes = [40, 90, 150, 210, 255];

  static int amplitudeFor(int level) => _amplitudes[level.clamp(1, 5) - 1];

  /// On a phone that cannot vary strength, the intensity levels become the
  /// LENGTH of a buzz: level 1 is 200 ms, level 5 is 520 ms. (These used to
  /// be 100-260 ms, too short to notice reliably.)
  static int pulseMs(int level) => 120 + level.clamp(1, 5) * 80;

  /// The acknowledgement tick after the target is reached: short (50 ms at
  /// level 1 up to 90 ms at level 5) so it reads as a tick, not a buzz, and
  /// clearly different from a milestone or the completion buzz.
  static int ackMs(int level) => 40 + level.clamp(1, 5) * 10;

  /// The completion buzz on such a phone: three long pulses with short gaps,
  /// so it is unmistakably longer and stronger than a milestone buzz.
  static List<int> completionPattern(int level) {
    final p = pulseMs(level);
    return [0, (p * 2).clamp(0, 900), 150, (p * 2).clamp(0, 900), 150, (p * 3).clamp(0, 1200)];
  }

  @override
  Future<void> milestone() async {
    final s = _settings();
    if (s.vibrationEnabled) await _buzz(s.vibrationLevel, strong: false);
  }

  @override
  Future<void> complete() async {
    final s = _settings();
    // Independent switches: neither call depends on the other (and a failing
    // vibrator never stops the sound).
    if (s.vibrationEnabled) await _buzz(s.vibrationLevel, strong: true);
    if (s.ringtoneEnabled) await _play(s.ringtone);
  }

  @override
  Future<void> acknowledge() async {
    final s = _settings();
    if (!s.vibrationEnabled) return;
    try {
      _hasVibrator ??= await _haptics.hasVibrator();
      if (_hasVibrator != true) return;
      _hasAmplitude ??= await _haptics.hasAmplitudeControl();
      final ms = ackMs(s.vibrationLevel);
      if (_hasAmplitude == true) {
        await _haptics.vibrate(
            duration: ms, amplitude: amplitudeFor(s.vibrationLevel));
      } else {
        await _haptics.vibrate(duration: ms);
      }
    } catch (e) {
      debugPrint('Vibration unavailable: $e');
    }
  }

  @override
  Future<void> previewVibration({required bool strong}) =>
      _buzz(_settings().vibrationLevel, strong: strong);

  @override
  Future<void> previewRingtone(Ringtone ringtone) => _play(ringtone);

  Future<void> _buzz(int level, {required bool strong}) async {
    try {
      _hasVibrator ??= await _haptics.hasVibrator();
      if (_hasVibrator != true) {
        debugPrint('No vibrator on this device: skipping the buzz.');
        return;
      }
      _hasAmplitude ??= await _haptics.hasAmplitudeControl();

      if (_hasAmplitude == true) {
        final amp = amplitudeFor(level);
        // The target buzz is one level stronger and a double pulse, so it is
        // always distinguishable from the 108-count milestone.
        final strongAmp = amplitudeFor(level + 1);
        if (strong) {
          await _haptics.vibrate(
            pattern: [0, 350, 120, 600],
            intensities: [0, strongAmp, 0, strongAmp],
          );
        } else {
          await _haptics.vibrate(duration: 180, amplitude: amp);
        }
      } else if (strong) {
        await _haptics.vibrate(pattern: completionPattern(level));
      } else {
        await _haptics.vibrate(duration: pulseMs(level));
      }
    } catch (e) {
      debugPrint('Vibration unavailable: $e');
    }
  }

  Future<void> _play(Ringtone ringtone) async {
    try {
      await _sound.stop();
      await _sound.play(ringtone.asset);
    } catch (e) {
      debugPrint('Ringtone playback failed: $e');
    }
  }
}

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return DeviceFeedbackService(
    () => ref.read(completionSettingsProvider),
    haptics: ref.read(hapticsDriverProvider),
    sound: ref.read(soundDriverProvider),
  );
});
