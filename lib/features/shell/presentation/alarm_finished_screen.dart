import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../calendar/services/reminder_scheduler.dart';
import '../../sadhana/application/sadhana_session_provider.dart';
import '../../sadhana/application/selected_mantra_provider.dart';
import '../../sadhana/presentation/widgets/counter_section.dart'
    show ringLabels;
import '../../../l10n/l10n.dart';
import '../application/alarm_screen_provider.dart';
import 'app_shell.dart';

/// The ONLY thing shown over the lock screen: which alarm finished (for a
/// Sadhana session, its result), Stop, and Unlock to open the app.
class AlarmFinishedScreen extends ConsumerWidget {
  const AlarmFinishedScreen({super.key, required this.group});

  final String group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final alarm = ref.read(alarmScreenProvider.notifier);
    final isSadhana = group == sadhanaTimerGroup || group == malaGroup;
    final title = switch (group) {
      sadhanaTimerGroup || malaGroup => l.alarmScreenSadhanaTitle,
      sunAlarmGroup => l.alarmScreenSunTitle,
      _ => l.alarmScreenTimerTitle,
    };

    return Scaffold(
      key: const ValueKey('alarm-finished-screen'),
      backgroundColor: scheme.surface,
      // Centred in the screen as a rule; scrolls when a large text size
      // makes it taller than the screen.
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight - 48),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const Spacer(),
                    Icon(
                      isSadhana ? Icons.self_improvement : Icons.alarm,
                      size: 72,
                      color: scheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    if (isSadhana) ...[
                      const SizedBox(height: 12),
                      const _SadhanaResult(),
                    ],
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const ValueKey('alarm-stop'),
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.error,
                          foregroundColor: scheme.onError,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: alarm.stop,
                        icon: const Icon(Icons.notifications_off_outlined),
                        label: Text(l.stopAlert),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        key: const ValueKey('alarm-unlock'),
                        onPressed: () async {
                          if (await alarm.unlockAndContinue()) {
                            ref
                                .read(shellTabProvider.notifier)
                                .select(
                                  isSadhana ? ShellTab.sadhana : ShellTab.clock,
                                );
                          }
                        },
                        icon: const Icon(Icons.lock_open),
                        label: Text(l.alarmScreenUnlock),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.alarmScreenUnlockHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The mantra and how far the session got (e.g. "108 / of 108", or "0:00").
class _SadhanaResult extends ConsumerWidget {
  const _SadhanaResult();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sadhanaSessionProvider);
    final mantra = ref.watch(selectedMantraProvider);
    final labels = ringLabels(s, context.l10n);
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          mantra.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          labels.primary,
          key: const ValueKey('alarm-result'),
          style: theme.textTheme.displaySmall,
        ),
        Text(labels.secondary, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
