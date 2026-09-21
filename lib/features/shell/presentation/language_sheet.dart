import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../language_provider.dart';

/// The language chooser (a bottom sheet), from the top bar and from Profile.
void showLanguageSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => const LanguageSheet(),
  );
}

class LanguageSheet extends ConsumerWidget {
  const LanguageSheet({super.key});

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
