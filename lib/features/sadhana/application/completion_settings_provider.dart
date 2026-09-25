import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../data/ringtone.dart';

/// How often the completion ringtone plays.
enum SoundRepeat {
  once,

  /// A few times ([soundRepeatTimes]), or until stopped.
  repeat,

  /// Over and over until Stop, Reset or leaving the screen.
  untilStopped,
}

/// How often the completion buzz comes.
enum VibrationRepeat {
  once,

  /// Every few seconds ([vibrationRepeatEvery]) until stopped.
  untilStopped,
}

/// Vibration and ringtone are deliberately independent: each has its own
/// on/off switch and its own options.
class CompletionSettings {
  const CompletionSettings({
    this.vibrationEnabled = true,
    this.vibrationLevel = 3,
    this.ringtoneEnabled = true,
    this.ringtone = Ringtone.templeBell,
    this.soundRepeat = SoundRepeat.once,
    this.vibrationRepeat = VibrationRepeat.once,
    this.keepScreenOn = true,
    this.quietDuringSession = false,
  });

  final bool vibrationEnabled;

  /// 1 (gentle) .. 5 (strongest).
  final int vibrationLevel;
  final bool ringtoneEnabled;
  final Ringtone ringtone;
  final SoundRepeat soundRepeat;
  final VibrationRepeat vibrationRepeat;

  /// Stops the screen from sleeping while a session is counting.
  final bool keepScreenOn;

  /// Silences other notifications while a session runs (Do Not Disturb,
  /// alarms only), Android. Off by default.
  final bool quietDuringSession;

  CompletionSettings copyWith({
    bool? vibrationEnabled,
    int? vibrationLevel,
    bool? ringtoneEnabled,
    Ringtone? ringtone,
    SoundRepeat? soundRepeat,
    VibrationRepeat? vibrationRepeat,
    bool? keepScreenOn,
    bool? quietDuringSession,
  }) =>
      CompletionSettings(
        vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
        vibrationLevel: vibrationLevel ?? this.vibrationLevel,
        ringtoneEnabled: ringtoneEnabled ?? this.ringtoneEnabled,
        ringtone: ringtone ?? this.ringtone,
        soundRepeat: soundRepeat ?? this.soundRepeat,
        vibrationRepeat: vibrationRepeat ?? this.vibrationRepeat,
        keepScreenOn: keepScreenOn ?? this.keepScreenOn,
        quietDuringSession: quietDuringSession ?? this.quietDuringSession,
      );
}

const _prefix = 'completion.';

class CompletionSettingsNotifier extends Notifier<CompletionSettings> {
  @override
  CompletionSettings build() {
    final box = AppStorage.settings;
    final ringtoneName = box.get('${_prefix}ringtone') as String?;
    T pick<T extends Enum>(List<T> values, String key, T fallback) {
      final name = box.get('$_prefix$key');
      return values.firstWhere((v) => v.name == name, orElse: () => fallback);
    }

    return CompletionSettings(
      vibrationEnabled: box.get('${_prefix}vibrationEnabled', defaultValue: true) as bool,
      vibrationLevel:
          ((box.get('${_prefix}vibrationLevel', defaultValue: 3) as int)).clamp(1, 5),
      ringtoneEnabled: box.get('${_prefix}ringtoneEnabled', defaultValue: true) as bool,
      ringtone: Ringtone.values.firstWhere(
        (r) => r.name == ringtoneName,
        orElse: () => Ringtone.templeBell,
      ),
      soundRepeat: pick(SoundRepeat.values, 'soundRepeat', SoundRepeat.once),
      vibrationRepeat:
          pick(VibrationRepeat.values, 'vibrationRepeat', VibrationRepeat.once),
      keepScreenOn:
          box.get('${_prefix}keepScreenOn', defaultValue: true) as bool,
      quietDuringSession:
          box.get('${_prefix}quietDuringSession', defaultValue: false) == true,
    );
  }

  void setVibrationEnabled(bool v) {
    state = state.copyWith(vibrationEnabled: v);
    AppStorage.settings.put('${_prefix}vibrationEnabled', v);
  }

  void setVibrationLevel(int level) {
    state = state.copyWith(vibrationLevel: level.clamp(1, 5));
    AppStorage.settings.put('${_prefix}vibrationLevel', state.vibrationLevel);
  }

  void setRingtoneEnabled(bool v) {
    state = state.copyWith(ringtoneEnabled: v);
    AppStorage.settings.put('${_prefix}ringtoneEnabled', v);
  }

  void setRingtone(Ringtone r) {
    state = state.copyWith(ringtone: r);
    AppStorage.settings.put('${_prefix}ringtone', r.name);
  }

  void setSoundRepeat(SoundRepeat r) {
    state = state.copyWith(soundRepeat: r);
    AppStorage.settings.put('${_prefix}soundRepeat', r.name);
  }

  void setVibrationRepeat(VibrationRepeat r) {
    state = state.copyWith(vibrationRepeat: r);
    AppStorage.settings.put('${_prefix}vibrationRepeat', r.name);
  }

  void setQuietDuringSession(bool v) {
    state = state.copyWith(quietDuringSession: v);
    AppStorage.settings.put('${_prefix}quietDuringSession', v);
  }

  void setKeepScreenOn(bool v) {
    state = state.copyWith(keepScreenOn: v);
    AppStorage.settings.put('${_prefix}keepScreenOn', v);
  }
}

final completionSettingsProvider =
    NotifierProvider<CompletionSettingsNotifier, CompletionSettings>(
  CompletionSettingsNotifier.new,
);
