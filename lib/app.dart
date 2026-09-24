import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/clock/application/sun_alarm_provider.dart';
import 'features/onboarding/application/onboarding_provider.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/profile/application/daily_reminder_provider.dart';
import 'features/shell/application/alarm_screen_provider.dart';
import 'features/shell/presentation/alarm_finished_screen.dart';
import 'features/shell/presentation/app_shell.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_provider.dart';

class SadhoApp extends ConsumerWidget {
  const SadhoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep the sun alarm's daily schedule fresh from the moment the app opens
    // (not only when the Clock tab is visited). The daily reminder likewise.
    ref.watch(sunAlarmProvider);
    ref.watch(dailyReminderProvider);
    final palette = ref.watch(paletteProvider);
    final locale = ref.watch(localeProvider);
    final onboarded = ref.watch(onboardingCompleteProvider);
    // Set only while an alarm has opened the app over the lock screen.
    final alarm = ref.watch(alarmScreenProvider);
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(palette, Brightness.light, locale.languageCode),
      darkTheme: AppTheme.build(palette, Brightness.dark, locale.languageCode),
      themeMode: ref.watch(themeModeProvider),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: onboarded ? const AppShell() : const OnboardingScreen(),
      // Over the lock screen, the app itself is not shown at all (not painted,
      // not touchable, not read by screen readers): only the finished screen.
      // The same structure either way, so the app keeps its state.
      builder: (context, child) => Stack(
        children: [
          Offstage(
            offstage: alarm != null,
            child: ExcludeSemantics(
              excluding: alarm != null,
              child: TickerMode(enabled: alarm == null, child: child!),
            ),
          ),
          if (alarm != null) AlarmFinishedScreen(group: alarm),
        ],
      ),
    );
  }
}
