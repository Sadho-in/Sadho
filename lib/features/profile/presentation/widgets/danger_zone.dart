import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_restart.dart';
import '../../../../l10n/l10n.dart';
import '../../application/account_service.dart';

/// A clearly separate, red section: delete the account (and everything on this
/// phone), only after "Are you sure? Yes / No".
class DangerZone extends ConsumerWidget {
  const DangerZone({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final scheme = Theme.of(context).colorScheme;
    final l = context.l10n;
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const ValueKey('delete-dialog'),
        icon: Icon(Icons.warning_amber_rounded, color: scheme.error, size: 32),
        title: Text(l.areYouSure),
        content: Text(l.deleteAccountWarning),
        actions: [
          TextButton(
            key: const ValueKey('delete-no'),
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.noAction),
          ),
          TextButton(
            key: const ValueKey('delete-yes'),
            style: TextButton.styleFrom(foregroundColor: scheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.yesAction),
          ),
        ],
      ),
    );
    if (yes != true) return; // "No", or tapped outside: nothing happens
    await ref.read(accountServiceProvider).deleteAccount();
    if (context.mounted) AppRestart.of(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;
    return Container(
      key: const ValueKey('danger-zone'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.error, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: scheme.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l.dangerZoneTitle,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(color: scheme.error)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.deleteAccountExplain,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const ValueKey('delete-account'),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => _delete(context, ref),
              icon: const Icon(Icons.delete_forever_outlined),
              label: Text(l.deleteAccountButton),
            ),
          ),
        ],
      ),
    );
  }
}
