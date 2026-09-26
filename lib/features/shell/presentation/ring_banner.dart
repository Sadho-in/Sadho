import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../alarms/application/ring_controller.dart';
import '../../calendar/services/reminder_scheduler.dart';

/// At the top of every tab while an alarm rings or a finished Sadhana session
/// is not acknowledged: "Sadhana complete 🙏 — Stop". One tap stops it all.
class RingBanner extends ConsumerWidget {
  const RingBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(ringControllerProvider);
    if (!r.showStop) return const SizedBox.shrink();
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final title = switch (r.group) {
      timerGroup => l.alarmScreenTimerTitle,
      sunAlarmGroup => l.alarmScreenSunTitle,
      _ => l.alarmScreenSadhanaTitle,
    };
    return Material(
      key: const ValueKey('ring-banner'),
      color: scheme.errorContainer,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
          child: Row(
            children: [
              Icon(Icons.alarm_on, color: scheme.onErrorContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: scheme.onErrorContainer),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                key: const ValueKey('ring-banner-stop'),
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                ),
                onPressed: ref.read(ringControllerProvider.notifier).stop,
                icon: const Icon(Icons.notifications_off_outlined, size: 18),
                label: Text(l.stopAlert),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
