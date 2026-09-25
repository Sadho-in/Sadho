import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/l10n.dart';
import '../../../../l10n/labels.dart';
import '../../data/world_cities.dart';
import '../widgets/tick_builder.dart';

/// Full-screen world clock: a fixed list of example cities for now.
class WorldClockPage extends StatelessWidget {
  const WorldClockPage({super.key});

  @override
  Widget build(BuildContext context) {
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.clockToolWorldClockTitle)),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: TickBuilder(
              builder: (context, now) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: worldCities.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _CityCard(
                  cityTimeAt(worldCities[i], now),
                  use24: use24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CityCard extends StatelessWidget {
  const _CityCard(this.ct, {required this.use24});

  final CityTime ct;
  final bool use24;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;
    final time = (use24 ? DateFormat('HH:mm') : DateFormat.jm()).format(ct.time);
    final name = ct.city.name;
    return Card(
      key: ValueKey('city-$name'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              ct.isDaytime ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
              color: ct.isDaytime ? scheme.primary : scheme.secondary,
            ),
            const SizedBox(width: 14),
            // The time sits on the right, or under the city when a long
            // name or a large text size leaves no room beside it.
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: theme.textTheme.titleLarge),
                      Text(
                        ct.city.region,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${ct.dayLabelIn(l)} · ${ct.relativeLabelIn(l)}',
                        key: ValueKey('city-$name-note'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    time,
                    key: ValueKey('city-$name-time'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
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
