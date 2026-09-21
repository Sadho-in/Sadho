import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/app_restart.dart';
import 'core/storage/app_storage.dart';
import 'features/calendar/services/local_notifications_scheduler.dart';
import 'features/calendar/services/reminder_scheduler.dart';

// TODO(phase-2): initialise Supabase (auth + sync) here.
// TODO(later-phase): Android/iOS home-screen widgets, OCR.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.init();

  // Calendar reminders are local notifications. If they cannot be set up (an
  // unsupported platform, a plugin failure) the calendar still works, just
  // without reminders.
  ReminderScheduler scheduler = NoopReminderScheduler();
  if (LocalNotificationsScheduler.platformSupported) {
    try {
      final real = LocalNotificationsScheduler();
      await real.init();
      scheduler = real;
    } catch (e) {
      debugPrint('Reminders are unavailable: $e');
    }
  }

  runApp(AppRestart(
    builder: (_) => ProviderScope(
      overrides: [reminderSchedulerProvider.overrideWithValue(scheduler)],
      child: const SadhoApp(),
    ),
  ));
}
