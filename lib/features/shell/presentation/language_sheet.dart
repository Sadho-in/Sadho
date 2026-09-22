import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
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
    final loc = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.languageSheetTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              loc.languageSheetSubtitle,
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
                  for (final lang in appLanguages)
                    RadioListTile<String>(
                      value: lang.code,
                      title: Text(lang.nativeName),
                      subtitle: Text(lang.name),
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
