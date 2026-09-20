import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_provider.dart';
import '../../calendar/presentation/calendar_screen.dart';
import '../../clock/presentation/clock_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../sadhana/application/mantra_library_provider.dart';
import '../../sadhana/application/session_notice_provider.dart';
import '../../sadhana/presentation/sadhana_screen.dart';
import '../../sadhana/presentation/voice_training_screen.dart';
import '../language_provider.dart';

enum ShellTab {
  clock('Clock', Icons.schedule_outlined, Icons.schedule),
  calendar('Calendar', Icons.calendar_month_outlined, Icons.calendar_month),
  sadhana('Sadhana', Icons.self_improvement_outlined, Icons.self_improvement),
  home('Home', Icons.home_outlined, Icons.home);

  const ShellTab(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

final _tabProvider = NotifierProvider<_TabNotifier, ShellTab>(_TabNotifier.new);

class _TabNotifier extends Notifier<ShellTab> {
  @override
  ShellTab build() => ShellTab.sadhana;
  void select(ShellTab tab) => state = tab;
}

/// Top bar (language, theme toggle, profile) + bottom navigation.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(_tabProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              ? SnackBarAction(label: 'Settings', onPressed: openAppSettings)
              : (notice.trainMantraId == null
                  ? null
                  : SnackBarAction(
                      label: 'Train',
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
            tooltip: 'Language',
            icon: const Icon(Icons.translate),
            onPressed: () => _showLanguageSheet(context),
          ),
          IconButton(
            tooltip: isDark ? 'Switch to light theme' : 'Switch to dark theme',
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () =>
                ref.read(themeModeProvider.notifier).toggle(theme.brightness),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 12),
            child: Tooltip(
              message: 'Profile',
              child: InkResponse(
                radius: 22,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const _ProfilePage()),
                ),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  foregroundColor: theme.colorScheme.onSecondaryContainer,
                  child: const Icon(Icons.person, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
      // IndexedStack keeps the Sadhana tab's local UI state alive.
      body: IndexedStack(
        index: tab.index,
        children: const [
          ClockScreen(),
          CalendarScreen(),
          SadhanaScreen(),
          HomeScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.index,
        onDestinationSelected: (i) =>
            ref.read(_tabProvider.notifier).select(ShellTab.values[i]),
        destinations: [
          for (final t in ShellTab.values)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.selectedIcon),
              label: t.label,
            ),
        ],
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _LanguageSheet(),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const ProfileScreen(),
      );
}

class _LanguageSheet extends ConsumerWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(languageProvider);
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Language', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Your choice is saved. Translations arrive in a later phase.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: selected,
              onChanged: (code) {
                if (code != null) {
                  ref.read(languageProvider.notifier).set(code);
                }
              },
              child: Column(
                children: [
                  for (final l in appLanguages)
                    RadioListTile<String>(
                      value: l.code,
                      title: Text(l.nativeName),
                      subtitle: Text(l.name),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
