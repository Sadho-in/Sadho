import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/storage/app_storage.dart';
import '../../../l10n/labels.dart';
import '../../../l10n/locale_provider.dart';
import '../../calendar/application/now_provider.dart';
import '../../calendar/services/reminder_planner.dart' show reminderId;
import '../../calendar/services/reminder_scheduler.dart';
import '../data/sun_alarm.dart';
import 'location_provider.dart';

/// How many days of alarms are handed to the phone at once. The alarm time
/// changes every day (it follows the sun), so each day gets its own
/// notification, refreshed whenever the app opens or comes back to the front
/// and whenever the setting or location changes.
const sunAlarmDaysAhead = 30;

/// The sun-based alarm's settings, saved in Hive. Changing them, or opening the
/// app, recomputes the alarm times and re-schedules them with the phone's local
/// notifications.
class SunAlarmNotifier extends Notifier<SunAlarmSettings> {
  static const _key = 'clock.sunAlarm';
  _ResumeWatcher? _watcher;

  @override
  SunAlarmSettings build() {
    ref.listen(locationProvider.select((l) => l.point), (_, _) => reschedule());
    // Recompute when the app returns to the front (a new day may have begun).
    try {
      _watcher = _ResumeWatcher(reschedule);
      WidgetsBinding.instance.addObserver(_watcher!);
      ref.onDispose(() => WidgetsBinding.instance.removeObserver(_watcher!));
    } catch (_) {
      // No Flutter binding (plain unit tests): nothing to watch.
    }
    Future.microtask(reschedule);
    return SunAlarmSettings.fromMap(AppStorage.settings.get(_key));
  }

  /// Turns the alarm on or off. Turning it on asks for notification permission
  /// (the alarm cannot ring without it); the result is false if that was
  /// refused, and the alarm is then still switched on but will stay silent.
  Future<bool> setEnabled(bool on) async {
    var allowed = true;
    if (on) allowed = await ref.read(reminderSchedulerProvider).requestPermission();
    if (!ref.mounted) return allowed;
    _set(state.copyWith(enabled: on));
    return allowed;
  }

  void setEvent(SunEventKind event) => _set(state.copyWith(event: event));

  /// Minutes from the sun event: negative before, positive after.
  void setOffset(int minutes) => _set(state.copyWith(offsetMinutes: minutes));

  void _set(SunAlarmSettings next) {
    state = next;
    AppStorage.settings.put(_key, next.toMap());
    reschedule();
  }

  /// Recomputes the next days' alarm times and replaces what is scheduled.
  Future<void> reschedule() async {
    final scheduler = ref.read(reminderSchedulerProvider);
    try {
      if (!state.enabled) {
        await scheduler.replaceAlerts(sunAlarmGroup, const []);
        return;
      }
      final p = ref.read(locationProvider).point;
      final upcoming = upcomingSunAlarms(
        state,
        ref.read(nowProvider),
        p.lat,
        p.lon,
        days: sunAlarmDaysAhead,
      );
      final time = DateFormat.jm();
      final emoji = state.event == SunEventKind.sunrise ? '🌅' : '🌇';
      final l = ref.read(l10nProvider);
      final event = state.event.localized(l);
      await scheduler.replaceAlerts(sunAlarmGroup, [
        for (var i = 0; i < upcoming.length; i++)
          ScheduledAlert(
            id: reminderId(sunAlarmGroup, 0, i),
            when: upcoming[i].alarm,
            title: l.sunAlarmNotifTitle(emoji, event),
            body: l.sunAlarmNotifBody(event, time.format(upcoming[i].event),
                offsetLabelIn(l, state.offsetMinutes, state.event)),
          ),
      ]);
    } catch (e) {
      debugPrint('Could not schedule the sun alarm: $e');
    }
  }
}

class _ResumeWatcher with WidgetsBindingObserver {
  _ResumeWatcher(this.onResume);

  final void Function() onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResume();
  }
}

final sunAlarmProvider =
    NotifierProvider<SunAlarmNotifier, SunAlarmSettings>(SunAlarmNotifier.new);

/// The alarms still ahead, next first, for the current settings, place and
/// time (recomputed as any of them change).
final upcomingSunAlarmsProvider = Provider<List<SunAlarmTime>>((ref) {
  final s = ref.watch(sunAlarmProvider);
  final p = ref.watch(locationProvider).point;
  final now = ref.watch(nowProvider);
  return upcomingSunAlarms(s, now, p.lat, p.lon, days: 7);
});
