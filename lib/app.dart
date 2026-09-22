import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/clock/application/sun_alarm_provider.dart';
import 'features/onboarding/application/onboarding_provider.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/profile/application/daily_reminder_provider.dart';
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
    );
  }
}
