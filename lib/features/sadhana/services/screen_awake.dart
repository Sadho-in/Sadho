import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../application/completion_settings_provider.dart';
import '../application/sadhana_session_provider.dart';

/// Stops the screen from sleeping. A seam, so tests run without a phone.
abstract class WakelockDriver {
  Future<void> enable();
  Future<void> disable();
}

class PluginWakelock implements WakelockDriver {
  @override
  Future<void> enable() => WakelockPlus.enable();

  @override
  Future<void> disable() => WakelockPlus.disable();
}

final wakelockDriverProvider =
    Provider<WakelockDriver>((ref) => PluginWakelock());

/// Keeps the screen on while at least one screen wants it (the Sadhana tab
/// and Focus mode can both be mounted at once), and off otherwise.
class ScreenAwake {
  ScreenAwake(this._driver);

  final WakelockDriver _driver;
  final _holders = <Object>{};
  bool _on = false;

  /// Whether the screen is being kept on.
  bool get isOn => _on;

  void set(Object holder, {required bool awake}) {
    awake ? _holders.add(holder) : _holders.remove(holder);
    final on = _holders.isNotEmpty;
    if (on == _on) return;
    _on = on;
    (on ? _driver.enable() : _driver.disable()).catchError((Object e) {
      debugPrint('Could not ${on ? 'keep' : 'stop keeping'} the screen on: $e');
    });
  }

  void releaseAll() {
    _holders.clear();
    set(this, awake: false);
  }
}

final screenAwakeProvider = Provider<ScreenAwake>((ref) {
  final awake = ScreenAwake(ref.read(wakelockDriverProvider));
  ref.onDispose(awake.releaseAll);
  return awake;
});

/// Keeps the screen on while [child] is on screen and the session is actively
/// running (not paused, not finished), if "Keep screen on while counting" is
/// on. Pressing the power button still locks the phone; a session with a
/// predictable end then rings like an alarm at the finish.
class KeepScreenOn extends ConsumerStatefulWidget {
  const KeepScreenOn({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<KeepScreenOn> createState() => _KeepScreenOnState();
}

class _KeepScreenOnState extends ConsumerState<KeepScreenOn> {
  /// Read up front: `ref` cannot be used in [dispose].
  late final ScreenAwake _awake;

  @override
  void initState() {
    super.initState();
    _awake = ref.read(screenAwakeProvider);
  }

  @override
  void dispose() {
    _awake.set(this, awake: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setting =
        ref.watch(completionSettingsProvider.select((c) => c.keepScreenOn));
    final active = ref.watch(
        sadhanaSessionProvider.select((s) => s.running && !s.completed));
    // False while this screen is hidden: another tab is selected, or another
    // page covers it.
    final visible = TickerMode.valuesOf(context).enabled;
    _awake.set(this, awake: setting && active && visible);
    return widget.child;
  }
}
