import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/l10n.dart';
import '../../../../l10n/labels.dart';
import '../../../clock/application/location_provider.dart';
import '../../application/tradition_provider.dart';
import '../../data/tradition.dart';

/// "Today": a Hindu / Sikh / By place switch and the details for it.
///
/// Sunrise and sunset are real (worked out for the phone's place). Everything
/// else is an EXAMPLE value, tagged as such, until real panchang is wired in.
///
/// TODO(later-phase): real panchang (tithi, nakshatra, Rahu Kaal, Abhijit
/// muhurat), Hukamnama Ang, Nitnem, Gurpurab dates and local festivals.
class TodayCard extends ConsumerWidget {
  const TodayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;
    final tradition = ref.watch(effectiveTraditionProvider);
    final details = ref.watch(todayDetailsProvider);
    final where = ref.watch(locationProvider).summaryIn(l);
    final hasExample = details.any((d) => d.example);
    final hasLive = details.any((d) => !d.example);

    return Card(
      key: const ValueKey('today-card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.today, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<Tradition>(
                key: const ValueKey('tradition-switch'),
                showSelectedIcon: false,
                segments: [
                  for (final t in Tradition.values)
                    ButtonSegment(value: t, label: Text(t.localized(l))),
                ],
                selected: {tradition},
                onSelectionChanged: (v) =>
                    ref.read(traditionProvider.notifier).set(v.first),
              ),
            ),
            const SizedBox(height: 8),
            for (final d in details)
              Padding(
                key: ValueKey('detail-${d.key}'),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(d.icon, size: 22, color: scheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            children: [
                              Text(
                                todayDetailLabel(l, d.key, d.label),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              if (d.example)
                                Container(
                                  key: ValueKey('example-${d.key}'),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scheme.tertiaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    l.exampleTag,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: scheme.onTertiaryContainer,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            d.value,
                            key: ValueKey('value-${d.key}'),
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (hasExample || hasLive) const Divider(height: 20),
            if (hasExample)
              Text(
                l.exampleNote,
                key: const ValueKey('example-note'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            if (hasLive)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l.liveNote(where),
                  key: const ValueKey('live-note'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
