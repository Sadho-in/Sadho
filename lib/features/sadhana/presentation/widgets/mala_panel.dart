import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/mala_settings_provider.dart';
import '../../services/mala_background_service.dart';
import '../../../../l10n/l10n.dart';

/// Shown in the Counting card while Mala is the active mode, on phones that
/// can count with the screen off (Android): the "Count with the screen off"
/// switch.
class MalaPanel extends ConsumerWidget {
  const MalaPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.read(malaBackgroundServiceProvider).isSupported) {
      return const SizedBox.shrink();
    }
    final on = ref.watch(malaScreenOffProvider);
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: SwitchListTile(
            key: const ValueKey('mala-screen-off'),
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.screen_lock_portrait_outlined),
            title: Text(l.malaScreenOffLabel),
            subtitle:
                Text(on ? l.malaScreenOffOnSubtitle : l.malaScreenOffOffSubtitle),
            value: on,
            onChanged: ref.read(malaScreenOffProvider.notifier).set,
          ),
        ),
      ),
    );
  }
}
