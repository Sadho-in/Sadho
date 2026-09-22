import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/l10n.dart';
import '../../application/profile_provider.dart';

/// "60% complete", with what is missing and a note about the premium reward.
class CompletionCard extends ConsumerWidget {
  const CompletionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;
    final c = ref.watch(profileCompletionProvider);

    return Card(
      key: const ValueKey('profile-completion'),
      color: c.complete ? scheme.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l.profileCompletionTitle,
                      style: theme.textTheme.titleLarge),
                ),
                Text(
                  '${c.percent}%',
                  key: const ValueKey('profile-percent'),
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: scheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                key: const ValueKey('profile-progress'),
                value: c.percent / 100,
                minHeight: 10,
                backgroundColor: scheme.surfaceContainerHigh,
              ),
            ),
            const SizedBox(height: 12),
            for (final s in c.steps)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  key: ValueKey('step-${s.id}'),
                  children: [
                    Icon(
                      s.done ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 20,
                      color: s.done ? scheme.primary : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: s.done ? scheme.onSurfaceVariant : null,
                          decoration: s.done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.workspace_premium_outlined,
                    size: 20, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    c.complete ? l.profileCompleteReward : l.reachRewardNote,
                    key: const ValueKey('profile-reward'),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
