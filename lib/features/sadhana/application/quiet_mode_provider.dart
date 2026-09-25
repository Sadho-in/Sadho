import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../services/dnd_driver.dart';
import 'completion_settings_provider.dart';
import 'sadhana_session_provider.dart';

/// Quiet mode during sadhana (Android): with "Silence other notifications
/// during a session" on, starting a session sets the phone's Do Not Disturb to
/// alarms only (so Sadho's own alarm still rings), and pausing, finishing,
/// resetting or leaving the Sadhana screen puts the user's own setting back.
///
/// The user's setting is saved BEFORE it is changed, so if the app is killed
/// mid-session it is restored at the next start. Nothing is ever changed
/// without the user's Notification Policy access, and a Do Not Disturb the
/// user changed themselves meanwhile is left alone.
///
/// State: whether quiet mode is applied right now.
class QuietModeNotifier extends Notifier<bool> {
  /// Hive key: the user's own Do Not Disturb mode while quiet mode is on.
  static const savedKey = 'quiet.savedFilter';

  /// Hive key: the "allow Do Not Disturb access" explanation was shown.
  static const explainedKey = 'quiet.explained';

  late DndDriver _dnd;

  /// Changes run one after another (a quick Start/Pause must not interleave).
  Future<void> _queue = Future.value();

  @override
  bool build() {
    _dnd = ref.read(dndDriverProvider);
    // Left behind by a crash or a killed app: put it back now.
    if (AppStorage.settings.get(savedKey) is int) {
      Future.microtask(restore);
    }
    ref.listen<bool>(
        sadhanaSessionProvider.select((s) => s.running && !s.completed),
        (_, running) => running ? unawaited(apply()) : unawaited(restore()));
    ref.listen<bool>(
        completionSettingsProvider.select((c) => c.quietDuringSession), (_, on) {
      final s = ref.read(sadhanaSessionProvider);
      if (on && s.running && !s.completed) {
        unawaited(apply());
      } else if (!on) {
        unawaited(restore());
      }
    });
    return AppStorage.settings.get(savedKey) is int;
  }

  Future<void> _serial(Future<void> Function() op) =>
      _queue = _queue.then((_) => op()).catchError((Object _) {});

  /// A session started: alarms only, if the switch is on and allowed.
  Future<void> apply() => _serial(() async {
        if (!ref.mounted || !_dnd.isSupported) return;
        if (!ref.read(completionSettingsProvider).quietDuringSession) return;
        if (AppStorage.settings.get(savedKey) is int) return; // already on
        if (!await _dnd.hasAccess()) return;
        final before = await _dnd.currentFilter();
        // Unknown, or the user is already at least this quiet: leave it.
        if (before == null ||
            before == DndFilter.alarms ||
            before == DndFilter.none) {
          return;
        }
        AppStorage.settings.put(savedKey, before);
        if (await _dnd.setFilter(DndFilter.alarms)) {
          if (ref.mounted) state = true;
        } else {
          AppStorage.settings.delete(savedKey);
        }
      });

  /// Puts the user's own Do Not Disturb back (if quiet mode set it).
  Future<void> restore() => _serial(() async {
        final saved = AppStorage.settings.get(savedKey);
        if (saved is! int) {
          if (ref.mounted) state = false;
          return;
        }
        if (await _dnd.hasAccess() &&
            await _dnd.currentFilter() == DndFilter.alarms) {
          await _dnd.setFilter(saved);
        }
        AppStorage.settings.delete(savedKey);
        if (ref.mounted) state = false;
      });

  /// The Sadhana screen was left.
  Future<void> leftSadhana() => restore();
}

final quietModeProvider =
    NotifierProvider<QuietModeNotifier, bool>(QuietModeNotifier.new);
