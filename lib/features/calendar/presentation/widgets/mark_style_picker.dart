import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/l10n.dart';
import '../../../../l10n/labels.dart';
import '../../application/mark_style_provider.dart';
import '../../data/calendar_mark.dart';
import 'mark_glyph.dart';
import 'mark_palette.dart';

/// Picks how marked dates are drawn (Dot, Filled, Highlight, Circle, Square).
/// One choice for every mark; each option previews itself in a mark colour
/// with its darker outline.
class MarkStylePicker extends ConsumerWidget {
  const MarkStylePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(markStyleProvider);
    final theme = Theme.of(context);
    final l = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.markStyleSectionTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              l.markStyleSectionHint,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final s in MarkStyle.values)
                  _StyleTile(
                    style: s,
                    selected: s == selected,
                    onTap: () => ref.read(markStyleProvider.notifier).set(s),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleTile extends StatelessWidget {
  const _StyleTile({
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final MarkStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;
    return Semantics(
      button: true,
      selected: selected,
      label: l.markStyleSemantic(style.localized(l)),
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        key: ValueKey('style-${style.name}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 58,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected ? scheme.primaryContainer : null,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: MarkGlyph(
                  style: style,
                  types: const [MarkType.good],
                  child: Text('15',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: style == MarkStyle.filled
                            ? MarkPalette.onColor(MarkPalette.base(
                                MarkType.good, theme.brightness))
                            : scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                style.localized(l),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What the colours mean, and the today marker.
class MarkLegend extends StatelessWidget {
  const MarkLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final b = theme.brightness;
    final l = context.l10n;
    Widget item(Widget swatch, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            swatch,
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.labelMedium),
          ],
        );
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        for (final t in MarkType.values)
          item(
            Container(
              key: ValueKey('legend-${t.name}'),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MarkPalette.base(t, b),
                border: Border.all(color: MarkPalette.outline(t, b), width: 1.5),
              ),
            ),
            t.localized(l),
          ),
        item(
          Container(
            key: const ValueKey('legend-today'),
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: scheme.secondary, shape: BoxShape.circle),
          ),
          l.today,
        ),
      ],
    );
  }
}
