import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../l10n/l10n.dart';
import '../../../sadhana/presentation/widgets/section_card.dart';

class AboutCard extends StatelessWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final muted = theme.colorScheme.onSurfaceVariant;
    Widget row(IconData icon, String label, String value, String key) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 20, color: muted),
              const SizedBox(width: 12),
              Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(value,
                    key: ValueKey(key),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge),
              ),
            ],
          ),
        );
    return SectionCard(
      title: l.aboutTitle,
      child: Column(
        children: [
          row(Icons.self_improvement, l.appLabel, AppConstants.appName, 'about-app'),
          row(Icons.language, l.websiteLabel, AppConstants.website, 'about-website'),
          row(Icons.info_outline, l.versionLabel, AppConstants.version, 'about-version'),
        ],
      ),
    );
  }
}
