import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_constants.dart';
import '../../alarms/presentation/alarms_reliability_page.dart';
import '../../calendar/services/reminder_scheduler.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../l10n/l10n.dart';
import '../../calendar/presentation/calendar_screen.dart';
import '../../clock/presentation/clock_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../sadhana/application/mantra_library_provider.dart';
import '../../sadhana/application/sadhana_session_provider.dart';
import '../../sadhana/application/session_notice_provider.dart';
import '../../sadhana/presentation/sadhana_screen.dart';
import '../../sadhana/presentation/voice_training_screen.dart';
import '../../profile/application/profile_provider.dart';
import 'language_sheet.dart';

/// The bottom navigation, left to right. Home is first and opens by default.
///
/// [label] is the English name — used for logs/tests/debugging; the tab bar
/// itself shows [ShellTabL10n.localized].
enum ShellTab {
  home('Home', Icons.home_outlined, Icons.home),
  sadhana('Sadhana', Icons.self_improvement_outlined, Icons.self_improvement),
  calendar('Calendar', Icons.calendar_month_outlined, Icons.calendar_month),
  clock('Clock', Icons.schedule_outlined, Icons.schedule);

  const ShellTab(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

extension ShellTabL10n on ShellTab {
  String localized(AppLocalizations l) => switch (this) {
        ShellTab.home => l.navHome,
        ShellTab.sadhana => l.navSadhana,
        ShellTab.calendar => l.navCalendar,
        ShellTab.clock => l.navClock,
      };
}

/// Alert notifications the user taps (and the one that launched the app).
final _notificationOpenedProvider = StreamProvider<String>(
    (ref) => ref.watch(reminderSchedulerProvider).opened);

final shellTabProvider =
    NotifierProvider<ShellTabNotifier, ShellTab>(ShellTabNotifier.new);

class ShellTabNotifier extends Notifier<ShellTab> {
  @override
  ShellTab build() => ShellTab.home;
  void select(ShellTab tab) => state = tab;
}

/// Top bar (language, theme toggle, profile) + bottom navigation.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(shellTabProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profile = ref.watch(profileProvider);
    final l = context.l10n;

    // Tapping an alarm opens where it belongs: the finished Sadhana
    // session, or the Clock tab for the timer and the sun alarm.
    ref.listen<AsyncValue<String>>(_notificationOpenedProvider, (_, next) {
      final tab = switch (next.value) {
        sadhanaTimerGroup || malaGroup => ShellTab.sadhana,
        timerGroup || sunAlarmGroup => ShellTab.clock,
        _ => null,
      };
      if (tab != null) ref.read(shellTabProvider.notifier).select(tab);
    });

    // Leaving the Sadhana tab silences a completion alert that is still
    // ringing or repeating (its Stop control is no longer on screen).
    ref.listen<ShellTab>(shellTabProvider, (prev, next) {
      if (prev == ShellTab.sadhana && next != ShellTab.sadhana) {
        ref.read(sadhanaSessionProvider.notifier).stopAlert();
      }
    });

    // Session messages (permission denied, unsupported mode...). Listening
    // here, above every route, shows them once and over Focus mode too.
    ref.listen<SessionNotice?>(sessionNoticeProvider, (_, notice) {
      if (notice == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(notice.message),
          duration: const Duration(seconds: 7),
          action: notice.openSettings
              ? SnackBarAction(label: l.settingsAction, onPressed: openAppSettings)
              : notice.openAlarmsPage
              ? SnackBarAction(
                  label: notice.actionLabel ?? l.alarmExplainerCheck,
                  onPressed: () => openAlarmsReliability(context))
              : notice.onAction != null
              ? SnackBarAction(
                  label: notice.actionLabel ?? l.settingsAction,
                  onPressed: notice.onAction!)
              : (notice.trainMantraId == null
                  ? null
                  : SnackBarAction(
                      label: l.trainAction,
                      onPressed: () {
                        final id = notice.trainMantraId;
                        final library = ref.read(mantraLibraryProvider);
                        final mantra = library.where((m) => m.id == id);
                        if (mantra.isNotEmpty) {
                          openVoiceTraining(context, mantra.first);
                        }
                      },
                    )),
        ));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          IconButton(
            tooltip: l.tooltipLanguage,
            icon: const Icon(Icons.translate),
            onPressed: () => showLanguageSheet(context),
          ),
          IconButton(
            tooltip: isDark ? l.tooltipSwitchToLight : l.tooltipSwitchToDark,
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () =>
                ref.read(themeModeProvider.notifier).toggle(theme.brightness),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            // An IconButton: a 48 dp tap target, announced as a button.
            child: IconButton(
              tooltip: l.tooltipProfile,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
              ),
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
                child: profile.hasName
                    ? Text(profile.initial,
                        key: const ValueKey('avatar-initial'),
                        style: const TextStyle(fontWeight: FontWeight.w700))
                    : const Icon(Icons.person, size: 20),
              ),
            ),
          ),
        ],
      ),
      // IndexedStack keeps the Sadhana tab's local UI state alive.
      body: IndexedStack(
        index: tab.index,
        // In the same order as [ShellTab].
        children: const [
          HomeScreen(),
          SadhanaScreen(),
          CalendarScreen(),
          ClockScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.index,
        onDestinationSelected: (i) =>
            ref.read(shellTabProvider.notifier).select(ShellTab.values[i]),
        destinations: [
          for (final t in ShellTab.values)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.selectedIcon),
              label: t.localized(l),
            ),
        ],
      ),
    );
  }
}
