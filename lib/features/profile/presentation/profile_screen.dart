import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../sadhana/presentation/widgets/count_scope_control.dart';
import '../../sadhana/presentation/widgets/section_card.dart';
import 'widgets/about_card.dart';
import 'widgets/account_card.dart';
import 'widgets/backup_card.dart';
import 'widgets/completion_card.dart';
import 'widgets/danger_zone.dart';
import 'widgets/details_card.dart';
import 'widgets/language_card.dart';
import 'widgets/reminder_card.dart';
import 'widgets/theme_card.dart';

/// The Profile page (opened from the avatar in the top bar).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.profileTitle)),
        body: const ProfileScreen(),
      );
}

/// Everything about you and the app: details, look, language, reminder,
/// backup, account and the danger zone.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 16);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const CompletionCard(),
            gap,
            const DetailsCard(),
            gap,
            const ThemeCard(),
            gap,
            const LanguageCard(),
            gap,
            const ReminderCard(),
            gap,
            SectionCard(
              title: context.l10n.sadhanaSettingsTitle,
              child: const CountScopeControl(),
            ),
            gap,
            const BackupCard(),
            gap,
            const AccountCard(),
            gap,
            const AboutCard(),
            const SizedBox(height: 28),
            const DangerZone(),
          ],
        ),
      ),
    );
  }
}
