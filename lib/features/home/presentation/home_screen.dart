import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../calendar/application/now_provider.dart';
import '../../profile/application/profile_provider.dart';
import '../data/tradition.dart';
import 'widgets/home_cards_section.dart';
import 'widgets/plans_section.dart';
import 'widgets/today_card.dart';

/// Home tab (the dashboard): a greeting and today's date, the Today card
/// (Hindu / Sikh / By place), cards for calendar days flagged for Home, and
/// your paath & mantra plans.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = ref.watch(nowProvider);
    final name = ref.watch(profileProvider.select((p) => p.firstName));
    final greeting = greetingFor(now.hour);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(
              name.isEmpty ? greeting : '$greeting, $name',
              key: const ValueKey('home-greeting'),
              style: theme.textTheme.headlineSmall,
            ),
            Text(
              MaterialLocalizations.of(context).formatFullDate(now),
              key: const ValueKey('home-date'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            const TodayCard(),
            const SizedBox(height: 16),
            const HomeCardsSection(),
            const SizedBox(height: 16),
            const PlansSection(),
          ],
        ),
      ),
    );
  }
}
