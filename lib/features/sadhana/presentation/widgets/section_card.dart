import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/l10n.dart';
import '../../application/collapsed_cards_provider.dart';

/// A titled card used to group settings on the Sadhana tab.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// A [SectionCard] that opens and closes from its header (the chevron shows
/// which). It remembers its state across restarts. Closed, it shows only its
/// title and a one-line [summary] of what is inside ("Target · 108").
class CollapsibleSectionCard extends ConsumerWidget {
  const CollapsibleSectionCard({
    super.key,
    required this.id,
    required this.title,
    required this.summary,
    required this.child,
  });

  /// One of [SadhanaCard]'s ids.
  final String id;
  final String title;
  final String summary;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;
    final open = !ref.watch(collapsedCardsProvider).contains(id);
    void toggle() => ref.read(collapsedCardsProvider.notifier).toggle(id);
    final action = open ? l.collapseSection(title) : l.expandSection(title);

    final header = Row(
      children: [
        Expanded(
          // The title is never cut; the summary sits beside it, or under it
          // when there is no room, on one line.
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              if (!open)
                Text(
                  ' · $summary',
                  key: ValueKey('summary-$id'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        AnimatedRotation(
          turns: open ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: Icon(Icons.expand_more, color: scheme.onSurfaceVariant),
        ),
      ],
    );

    return Card(
      key: ValueKey('card-$id'),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: open,
            label: action,
            excludeSemantics: true,
            onTap: toggle,
            child: Tooltip(
              message: action,
              child: InkWell(
                key: ValueKey('toggle-$id'),
                onTap: toggle,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 12, open ? 0 : 12),
                    child: header,
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: child,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
