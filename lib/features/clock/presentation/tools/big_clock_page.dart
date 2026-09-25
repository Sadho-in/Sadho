import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/l10n.dart';
import '../widgets/tick_builder.dart';

/// Full-screen clock: a large live time with the date beneath it.
class BigClockPage extends StatelessWidget {
  const BigClockPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final digits = theme.textTheme.displayLarge!.copyWith(
      fontSize: 160,
      fontWeight: FontWeight.w300,
      height: 1,
      color: scheme.onSurface,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.navClock)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TickBuilder(
              builder: (context, now) {
                final hm = (use24 ? DateFormat('HH:mm') : DateFormat('h:mm')).format(now);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Narrow (a phone upright): hours and minutes fill the
                    // width, seconds and AM/PM sit beneath. Wide: one line.
                    LayoutBuilder(builder: (context, box) {
                      final narrow = box.maxWidth < 600;
                      final hmText = Text(hm, key: const ValueKey('clock-time'), style: digits);
                      final secText = Text(
                        ':${DateFormat('ss').format(now)}',
                        key: const ValueKey('clock-seconds'),
                        style: digits.copyWith(
                          fontSize: narrow ? 64 : 72,
                          color: scheme.primary,
                        ),
                      );
                      final period = use24
                          ? null
                          : Text(
                              DateFormat('a').format(now),
                              key: const ValueKey('clock-period'),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            );
                      if (narrow) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(fit: BoxFit.scaleDown, child: hmText),
                            // AM/PM goes under the seconds when a large
                            // text size leaves no room beside them.
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.end,
                              spacing: 12,
                              children: [secText, ?period],
                            ),
                          ],
                        );
                      }
                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            hmText,
                            secText,
                            if (period != null) ...[
                              const SizedBox(width: 12),
                              period,
                            ],
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    Text(
                      DateFormat('EEEE, d MMMM y').format(now),
                      key: const ValueKey('clock-date'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      now.timeZoneName,
                      key: const ValueKey('clock-zone'),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
