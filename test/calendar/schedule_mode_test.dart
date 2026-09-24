import 'dart:io';

import 'package:advance_calendar/features/calendar/services/local_notifications_scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

/// Real alarms are set as alarm clocks (the most reliable under Doze and
/// battery savers); reminders stay exact-but-ordinary; without exact-alarm
/// permission everything falls back to a flexible time.
void main() {
  test('real alarms ring as an alarm clock', () {
    expect(scheduleModeFor(alarm: true, exact: true), AndroidScheduleMode.alarmClock);
  });

  test('calendar and gentle reminders stay exact while idle', () {
    expect(scheduleModeFor(alarm: false, exact: true),
        AndroidScheduleMode.exactAllowWhileIdle);
  });

  test('without exact alarms both fall back to a flexible time', () {
    for (final alarm in [true, false]) {
      expect(scheduleModeFor(alarm: alarm, exact: false),
          AndroidScheduleMode.inexactAllowWhileIdle);
    }
  });

  test('manifest: USE_EXACT_ALARM, and SCHEDULE_EXACT_ALARM only up to '
      'Android 12', () {
    final m = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(m, contains('android.permission.USE_EXACT_ALARM'));
    expect(
        RegExp(r'SCHEDULE_EXACT_ALARM"\s*android:maxSdkVersion="32"').hasMatch(m),
        isTrue);
    expect(m, isNot(contains('REQUEST_IGNORE_BATTERY_OPTIMIZATIONS')),
        reason: 'Google Play restricts it; the app only links to settings');
  });
}
