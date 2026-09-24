import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/alarm_health.dart';

/// The live status of the "Alarms & reliability" checks. Refreshed when the
/// page opens and whenever the user comes back from the phone's settings.
class AlarmHealthNotifier extends AsyncNotifier<AlarmHealthStatus> {
  @override
  Future<AlarmHealthStatus> build() => ref.read(alarmHealthProvider).check();

  Future<void> refresh() async {
    final next = await AsyncValue.guard(ref.read(alarmHealthProvider).check);
    if (ref.mounted) state = next;
  }
}

final alarmHealthStatusProvider =
    AsyncNotifierProvider<AlarmHealthNotifier, AlarmHealthStatus>(
        AlarmHealthNotifier.new);
