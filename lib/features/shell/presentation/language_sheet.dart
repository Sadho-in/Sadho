import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../language_provider.dart';

/// The language chooser (a bottom sheet), from the top bar and from Profile.
void showLanguageSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    // Without this, the sheet is capped at half the screen height and its
    // body (a plain Column, not scrollable on its own) has no way to reach
    // the languages that don't fit — isScrollControlled lets the sheet grow,
    // and LanguageSheet's own SingleChildScrollView handles the rest.
    isScrollControlled: true,
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
      // isScrollControlled (set where this sheet is shown) lets the sheet
      // grow past half the screen; this scroll view is what lets its content
      // — up to nine languages, more with a large system font — actually
      // reach past that on a short screen instead of just getting clipped.
      child: SingleChildScrollView(
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
                      key: ValueKey('language-sheet-${lang.code}'),
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
