import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/app_restart.dart';
import 'core/licenses.dart';
import 'core/storage/app_storage.dart';
import 'features/alarms/services/alarm_ring.dart';
import 'features/calendar/services/local_notifications_scheduler.dart';
import 'features/calendar/services/reminder_scheduler.dart';
import 'features/sadhana/services/dnd_driver.dart';
import 'features/sadhana/services/mala_background_service.dart';
import 'l10n/date_formats.dart';

// TODO(phase-2): initialise Supabase (auth + sync) here.
// TODO(later-phase): Android/iOS home-screen widgets, OCR.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.init();
  // The bundled fonts' licences, for the open-source licences page.
  registerFontLicenses();
  // Month and weekday names for all nine app languages.
  initAppDateFormatting();

  // Calendar reminders are local notifications. If they cannot be set up (an
  // unsupported platform, a plugin failure) the calendar still works, just
  // without reminders.
  // The one native alarm ring (Android): every alarm-style finish.
  final AlarmRing ring = AndroidAlarmRing.platformSupported
      ? AndroidAlarmRing()
      : const NoopAlarmRing();

  ReminderScheduler scheduler = NoopReminderScheduler();
  if (LocalNotificationsScheduler.platformSupported) {
    try {
      final real = LocalNotificationsScheduler(ring: ring);
      await real.init();
      scheduler = real;
    } catch (e) {
      debugPrint('Reminders are unavailable: $e');
    }
  }

  // Mala with the screen off: a native foreground service, Android only.
  final MalaBackgroundService mala = AndroidMalaBackgroundService.platformSupported
      ? AndroidMalaBackgroundService()
      : const UnsupportedMalaBackgroundService();

  runApp(AppRestart(
    builder: (_) => ProviderScope(
      overrides: [
        reminderSchedulerProvider.overrideWithValue(scheduler),
        malaBackgroundServiceProvider.overrideWithValue(mala),
        alarmRingProvider.overrideWithValue(ring),
        // Quiet mode during sadhana (Do Not Disturb), Android only.
        if (AndroidDndDriver.platformSupported)
          dndDriverProvider.overrideWithValue(const AndroidDndDriver()),
      ],
      child: const SadhoApp(),
    ),
  ));
}
