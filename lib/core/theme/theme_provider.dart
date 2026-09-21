import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/app_storage.dart';
import 'palettes.dart';

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

const _paletteKey = 'themePalette';

/// The colour palette chosen in Profile, persisted in Hive. Defaults to
/// Marigold, and an unknown saved id also falls back to Marigold.
class PaletteNotifier extends Notifier<SadhoPalette> {
  @override
  SadhoPalette build() => paletteById(AppStorage.settings.get(_paletteKey));

  void set(SadhoPalette palette) {
    state = palette;
    AppStorage.settings.put(_paletteKey, palette.id);
  }
}

final paletteProvider =
    NotifierProvider<PaletteNotifier, SadhoPalette>(PaletteNotifier.new);
