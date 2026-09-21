import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/world_cities.dart';
import '../widgets/tick_builder.dart';

/// Full-screen world clock: a fixed list of example cities for now.
class WorldClockPage extends StatelessWidget {
  const WorldClockPage({super.key});

  @override
  Widget build(BuildContext context) {
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('World clock')),
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
            Expanded(
              child: Column(
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
                    '${ct.dayLabel} · ${ct.relativeLabel}',
                    key: ValueKey('city-$name-note'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
    );
  }
}
