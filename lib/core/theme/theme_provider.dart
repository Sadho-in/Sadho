import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/app_storage.dart';

const _key = 'themeMode';

/// Runtime light/dark switch, persisted in Hive. Defaults to the system mode.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final saved = AppStorage.settings.get(_key) as String?;
    return ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  void set(ThemeMode mode) {
    state = mode;
    AppStorage.settings.put(_key, mode.name);
  }

  /// Flips between light and dark based on what is currently on screen.
  void toggle(Brightness current) =>
      set(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
