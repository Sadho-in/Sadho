import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shell/language_provider.dart';
import '../../../shell/presentation/language_sheet.dart';

/// The app language. It is saved; real translations come with the i18n phase.
///
/// TODO(later-phase): wire the language into flutter_localizations.
class LanguageCard extends ConsumerWidget {
  const LanguageCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(languageProvider);
    final lang = appLanguages.firstWhere((l) => l.code == code,
        orElse: () => appLanguages.first);
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        key: const ValueKey('profile-language'),
        leading: const Icon(Icons.translate),
        title: const Text('Language'),
        subtitle: Text('${lang.nativeName} · translations arrive in a later phase',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showLanguageSheet(context),
      ),
    );
  }
}
