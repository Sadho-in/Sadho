import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../alarms/application/ring_controller.dart';
import '../../../../l10n/l10n.dart';

/// Shown while anything rings (the in-app alert or the phone's alarm) and
/// while a finished session is not yet acknowledged, on the Sadhana tab (as
/// its main button) and in Focus mode alike: one press silences the ringtone,
/// the vibration and the notification everywhere.
class StopAlertButton extends ConsumerWidget {
  const StopAlertButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final show = ref.watch(ringControllerProvider.select((r) => r.showStop));
    if (!show) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        key: const ValueKey('stop-alert'),
        style: FilledButton.styleFrom(
          backgroundColor: scheme.error,
          foregroundColor: scheme.onError,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: ref.read(ringControllerProvider.notifier).stop,
        icon: const Icon(Icons.notifications_off_outlined),
        label: Text(context.l10n.stopAlert),
      ),
      ),
    );
  }
}
