import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/links.dart';
import '../../../../core/widgets/sadho_logo.dart';
import '../../../../l10n/l10n.dart';
import '../../../sadhana/presentation/widgets/section_card.dart';

/// Opens [url] in the browser; says so if it could not.
Future<void> openLink(BuildContext context, WidgetRef ref, Uri url) async {
  final ok = await ref.read(linkLauncherProvider).open(url);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.linkOpenFailed(url.toString()))));
  }
}

class AboutCard extends ConsumerWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    Widget link(IconData icon, String label, String key, VoidCallback onTap,
            {bool external = true}) =>
        ListTile(
          key: ValueKey(key),
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: muted),
          title: Text(label),
          trailing: Icon(external ? Icons.open_in_new : Icons.chevron_right,
              size: 20, color: muted),
          onTap: onTap,
        );
    return SectionCard(
      title: l.aboutTitle,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SadhoLogo(size: 64),
          ),
          row(Icons.self_improvement, l.appLabel, AppConstants.appName, 'about-app'),
          row(Icons.language, l.websiteLabel, AppConstants.website, 'about-website'),
          row(Icons.info_outline, l.versionLabel, AppConstants.version, 'about-version'),
          const Divider(height: 24),
          link(Icons.privacy_tip_outlined, l.legalPrivacyPolicy, 'about-privacy',
              () => openLink(context, ref, AppConstants.privacyUrl)),
          link(Icons.gavel_outlined, l.legalTermsOfUse, 'about-terms',
              () => openLink(context, ref, AppConstants.termsUrl)),
          link(Icons.support_agent_outlined, l.legalContact, 'about-contact',
              () => openLink(context, ref, AppConstants.contactUrl)),
          link(Icons.delete_sweep_outlined, l.legalDeleteData, 'about-delete-data',
              () => openLink(context, ref, AppConstants.deleteDataUrl)),
          link(
            Icons.description_outlined,
            l.legalLicenses,
            'about-licenses',
            () => showLicensePage(
              context: context,
              applicationName: AppConstants.appName,
              applicationVersion: AppConstants.version,
              applicationIcon: const Padding(
                padding: EdgeInsets.all(8),
                child: SadhoLogo(size: 48),
              ),
            ),
            external: false,
          ),
        ],
      ),
    );
  }
}
