import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/sadhana_session_provider.dart';
import '../../services/feedback_service.dart';
import '../../../../l10n/l10n.dart';

/// Shown only while the completion alert is still sounding or repeating
/// (on the Sadhana tab and in Focus mode alike): one press silences the
/// ringtone and the vibration.
class StopAlertButton extends ConsumerWidget {
  const StopAlertButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerting = ref.watch(feedbackServiceProvider).alerting;
    return ValueListenableBuilder<bool>(
      valueListenable: alerting,
      builder: (context, on, _) => on
          ? FilledButton.icon(
              key: const ValueKey('stop-alert'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: ref.read(sadhanaSessionProvider.notifier).stopAlert,
              icon: const Icon(Icons.notifications_off_outlined),
              label: Text(context.l10n.stopAlert),
            )
          : const SizedBox.shrink(),
    );
  }
}
