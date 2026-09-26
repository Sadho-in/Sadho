import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../../../l10n/locale_provider.dart';
import '../services/dnd_driver.dart';
import 'completion_settings_provider.dart';
import 'sadhana_session_provider.dart';
import 'session_notice_provider.dart';

/// Quiet mode during sadhana (Android): with "Silence other notifications
/// during a session" on, a session sets the phone's Do Not Disturb to alarms
/// only (so Sadho's own alarm still rings) with [quietPolicy] (no priority
/// senders or repeat callers, no pop-ups, status-bar icons or lights), and
/// pausing, finishing, resetting or leaving the Sadhana screen puts the user's
/// own mode AND policy back.
///
/// When a session counts: a running session (Start), and a Tap count target
/// from its first tap (it has no Start) until it completes, is Reset, or the
/// Sadhana screen is left.
///
/// The user's mode and policy are saved BEFORE they are changed, so if the app
/// is killed mid-session they are restored at the next start. Nothing is ever
/// changed without the user's Notification Policy access. After setting it,
/// Do Not Disturb is read back; if it did not apply, the user is told (never
/// silently nothing). A Do Not Disturb the user changed themselves meanwhile
/// is left alone.
///
/// P5.1 root cause of "messages still vibrate and pop up": quiet mode only
/// ever followed `running`, which a Tap count target never sets, and every
/// failure (no access, unknown mode, a phone that ignored the change) returned
/// silently. It also left the policy alone, so pop-ups of blocked messages
/// were still allowed by the user's own policy.
///
/// State: whether quiet mode is applied right now.
class QuietModeNotifier extends Notifier<bool> {
  /// Hive key: the user's own Do Not Disturb mode while quiet mode is on.
  static const savedKey = 'quiet.savedFilter';

  /// Hive key: the user's own Do Not Disturb policy while quiet mode is on.
  static const savedPolicyKey = 'quiet.savedPolicy';

  /// Hive key: the "allow Do Not Disturb access" explanation was shown.
  static const explainedKey = 'quiet.explained';

  late DndDriver _dnd;

  /// Changes run one after another (a quick Start/Pause must not interleave).
  Future<void> _queue = Future.value();

  /// A Tap count target is being counted (since its first tap).
  bool _tapSession = false;

  /// Whether a session wants quiet mode now.
  bool _wanted = false;

  @override
  bool build() {
    _dnd = ref.read(dndDriverProvider);
    // Left behind by a crash or a killed app: put it back now.
    if (AppStorage.settings.get(savedKey) is int) {
      Future.microtask(restore);
    }
    ref.listen<SadhanaState>(sadhanaSessionProvider, _onSession);
    ref.listen<bool>(
        completionSettingsProvider.select((c) => c.quietDuringSession), (_, on) {
      if (on && _wanted) {
        unawaited(apply());
      } else if (!on) {
        unawaited(restore());
      }
    });
    return AppStorage.settings.get(savedKey) is int;
  }

  void _onSession(SadhanaState? prev, SadhanaState s) {
    final tapCount = s.mode == CountMode.tap && !s.isTimeTarget;
    if (!tapCount || s.completed || s.count == 0) {
      _tapSession = false;
    } else if (prev != null && s.count > prev.count) {
      _tapSession = true; // the first tap (or any tap) of a Tap count target
    }
    final want = !s.completed && (s.running || _tapSession);
    if (want == _wanted) return;
    _wanted = want;
    unawaited(want ? apply() : restore());
  }

  Future<void> _serial(Future<void> Function() op) =>
      _queue = _queue.then((_) => op()).catchError((Object e) {
        debugPrint('quiet: failed: $e');
      });

  /// A session started: alarms only, if the switch is on and allowed.
  Future<void> apply() => _serial(() async {
        if (!ref.mounted || !_dnd.isSupported) return;
        if (!ref.read(completionSettingsProvider).quietDuringSession) return;
        if (AppStorage.settings.get(savedKey) is int) return; // already on
        final access = await _dnd.hasAccess();
        debugPrint('quiet: access=$access');
        if (!access) {
          _failed();
          return;
        }
        final before = await _dnd.currentFilter();
        final beforePolicy = await _dnd.currentPolicy();
        debugPrint('quiet: filter before=$before policy before=$beforePolicy');
        if (before == null) {
          _failed();
          return;
        }
        // The user is already at least this quiet: leave it.
        if (before == DndFilter.alarms || before == DndFilter.none) return;
        AppStorage.settings.put(savedKey, before);
        if (beforePolicy != null) {
          AppStorage.settings.put(savedPolicyKey, beforePolicy);
        }
        final policySet = beforePolicy != null && await _dnd.setPolicy(quietPolicy);
        final filterSet = await _dnd.setFilter(DndFilter.alarms);
        debugPrint('quiet: set filter=${DndFilter.alarms} ($filterSet) '
            'policy=$quietPolicy ($policySet)');
        final after = await _dnd.currentFilter();
        final afterPolicy = await _dnd.currentPolicy();
        debugPrint('quiet: read back filter=$after policy=$afterPolicy');
        if (filterSet && after == DndFilter.alarms) {
          if (ref.mounted) state = true;
          return;
        }
        // Did not apply: put everything back as it was, and say so.
        if (beforePolicy != null && policySet) await _dnd.setPolicy(beforePolicy);
        if (after != before) await _dnd.setFilter(before);
        AppStorage.settings
          ..delete(savedKey)
          ..delete(savedPolicyKey);
        _failed();
      });

  /// One clear notice, with a button to the access page.
  void _failed() {
    if (!ref.mounted) return;
    final l = ref.read(l10nProvider);
    ref.read(sessionNoticeProvider.notifier).show(
          l.quietModeFailed,
          actionLabel: l.allowAction,
          onAction: () => unawaited(_dnd.openAccessSettings()),
        );
  }

  /// Puts the user's own Do Not Disturb mode and policy back (if quiet mode
  /// set them).
  Future<void> restore() => _serial(() async {
        final saved = AppStorage.settings.get(savedKey);
        final savedPolicy = AppStorage.settings.get(savedPolicyKey);
        if (saved is! int) {
          AppStorage.settings.delete(savedPolicyKey);
          if (ref.mounted) state = false;
          return;
        }
        if (await _dnd.hasAccess()) {
          if (savedPolicy is Map &&
              mapEquals(await _dnd.currentPolicy(), quietPolicy)) {
            final ok = await _dnd.setPolicy(
                {for (final e in savedPolicy.entries) '${e.key}': e.value as int});
            debugPrint('quiet: policy restored ($ok)');
          }
          if (await _dnd.currentFilter() == DndFilter.alarms) {
            final ok = await _dnd.setFilter(saved);
            debugPrint('quiet: filter restored to $saved ($ok)');
          }
        }
        AppStorage.settings
          ..delete(savedKey)
          ..delete(savedPolicyKey);
        if (ref.mounted) state = false;
      });

  /// The Sadhana screen was left: a Tap count ends here, and quiet mode ends
  /// with the screen.
  Future<void> leftSadhana() {
    _tapSession = false;
    _wanted = false;
    return restore();
  }
}

final quietModeProvider =
    NotifierProvider<QuietModeNotifier, bool>(QuietModeNotifier.new);
