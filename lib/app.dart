import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/clock/application/sun_alarm_provider.dart';
import 'features/shell/presentation/app_shell.dart';

class SadhoApp extends ConsumerWidget {
  const SadhoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep the sun alarm's daily schedule fresh from the moment the app opens
    // (not only when the Clock tab is visited).
    ref.watch(sunAlarmProvider);
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      home: const AppShell(),
    );
  }
}
