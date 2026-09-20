import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../data/ringtone.dart';

/// Vibration and ringtone are deliberately independent: each has its own
/// on/off switch and its own options.
class CompletionSettings {
  const CompletionSettings({
    this.vibrationEnabled = true,
    this.vibrationLevel = 3,
    this.ringtoneEnabled = true,
    this.ringtone = Ringtone.templeBell,
  });

  final bool vibrationEnabled;

  /// 1 (gentle) .. 5 (strongest).
  final int vibrationLevel;
  final bool ringtoneEnabled;
  final Ringtone ringtone;

  CompletionSettings copyWith({
    bool? vibrationEnabled,
    int? vibrationLevel,
    bool? ringtoneEnabled,
    Ringtone? ringtone,
  }) =>
      CompletionSettings(
        vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
        vibrationLevel: vibrationLevel ?? this.vibrationLevel,
        ringtoneEnabled: ringtoneEnabled ?? this.ringtoneEnabled,
        ringtone: ringtone ?? this.ringtone,
      );
}

const _prefix = 'completion.';

class CompletionSettingsNotifier extends Notifier<CompletionSettings> {
  @override
  CompletionSettings build() {
    final box = AppStorage.settings;
    final ringtoneName = box.get('${_prefix}ringtone') as String?;
    return CompletionSettings(
      vibrationEnabled: box.get('${_prefix}vibrationEnabled', defaultValue: true) as bool,
      vibrationLevel:
          ((box.get('${_prefix}vibrationLevel', defaultValue: 3) as int)).clamp(1, 5),
      ringtoneEnabled: box.get('${_prefix}ringtoneEnabled', defaultValue: true) as bool,
      ringtone: Ringtone.values.firstWhere(
        (r) => r.name == ringtoneName,
        orElse: () => Ringtone.templeBell,
      ),
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
}

final completionSettingsProvider =
    NotifierProvider<CompletionSettingsNotifier, CompletionSettings>(
  CompletionSettingsNotifier.new,
);
