import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../sadhana/presentation/widgets/section_card.dart';

class AboutCard extends StatelessWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      title: 'About',
      child: Column(
        children: [
          row(Icons.self_improvement, 'App', AppConstants.appName, 'about-app'),
          row(Icons.language, 'Website', AppConstants.website, 'about-website'),
          row(Icons.info_outline, 'Version', AppConstants.version, 'about-version'),
        ],
      ),
    );
  }
}
