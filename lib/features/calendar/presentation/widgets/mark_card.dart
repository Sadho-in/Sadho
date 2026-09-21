import 'package:flutter/material.dart';

import '../../data/calendar_mark.dart';
import 'mark_format.dart';
import 'mark_palette.dart';

/// A mark as a card: its emoji, label, notes and a few small tags. Shared by
/// the Calendar's month list and the Home tab, so a mark looks the same
/// everywhere. The stripe and the avatar use the mark's colour with its darker
/// outline.
class MarkCard extends StatelessWidget {
  const MarkCard({
    super.key,
    required this.mark,
    this.dateLabel,
    this.onTap,
    this.pinned = false,
    this.hint,
  });

  final CalendarMark mark;

  /// Shown as a tag, e.g. "Mon, 21 Sep 2026".
  final String? dateLabel;
  final VoidCallback? onTap;

  /// A pinned (all day) card shows a pin and cannot be swiped away.
  final bool pinned;

  /// A small line at the bottom, e.g. "Swipe to dismiss for today".
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final b = theme.brightness;
    final base = MarkPalette.base(mark.type, b);
    final outline = MarkPalette.outline(mark.type, b);

    final tags = <String>[
      mark.type.label,
      ?dateLabel,
      if (mark.repeat != RepeatRule.once) repeatSummary(mark.repeat),
      ?reminderSummary(context, mark),
      ?homeSummary(context, mark),
    ];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                key: const ValueKey('mark-stripe'),
                width: 6,
                color: base,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        key: const ValueKey('mark-avatar'),
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: base.withValues(alpha: 0.22),
                          border: Border.all(color: outline, width: 2),
                        ),
                        child: mark.emoji != null
                            ? Text(mark.emoji!, style: const TextStyle(fontSize: 22))
                            : Icon(MarkPalette.icon(mark.type),
                                color: outline, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    mark.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                if (pinned)
                                  Icon(Icons.push_pin,
                                      key: const ValueKey('mark-pin'),
                                      size: 18,
                                      color: scheme.onSurfaceVariant),
                              ],
                            ),
                            if (mark.details.trim().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                mark.details.trim(),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                for (final t in tags) _Tag(t, first: t == tags.first, color: outline),
                              ],
                            ),
                            if (hint != null) ...[
                              const SizedBox(height: 6),
                              Text(hint!,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, {required this.first, required this.color});

  final String text;

  /// The first tag is the mark's kind, drawn in its colour.
  final bool first;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: first ? color.withValues(alpha: 0.14) : scheme.surfaceContainerHigh,
        border: first ? Border.all(color: color) : null,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: first ? color : scheme.onSurfaceVariant,
              fontWeight: first ? FontWeight.w700 : FontWeight.w500,
            ),
      ),
    );
  }
}
