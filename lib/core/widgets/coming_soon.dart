import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

/// Shared placeholder body for tabs that are not built yet.
class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            context.l10n.comingSoon,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
