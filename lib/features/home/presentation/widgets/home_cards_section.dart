import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/l10n.dart';
import '../../../../l10n/labels.dart';
import '../../../calendar/application/home_cards_provider.dart';
import '../../../calendar/application/now_provider.dart';
import '../../../calendar/presentation/widgets/mark_card.dart';
import '../../../calendar/presentation/widgets/mark_editor_sheet.dart';

/// Today's cards, from calendar days flagged for the home screen (the
/// Calendar's home cards, unchanged).
///
/// - **Once in the morning** cards appear at their time and can be swiped away
///   for the day (Undo is offered).
/// - **Keep all day** cards are pinned: they stay all day and cannot be swiped.
class HomeCardsSection extends ConsumerWidget {
  const HomeCardsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;
    final now = ref.watch(nowProvider);
    final cards = ref.watch(homeCardsProvider);
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (cards.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    size: 40,
                    color: scheme.primary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l.homeEmptyTitle,
                    key: const ValueKey('home-empty'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.homeEmptyBody,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        for (final c in cards)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: c.pinned
                // Pinned: no Dismissible, so it cannot be swiped away.
                ? MarkCard(
                    key: ValueKey('home-card-${c.mark.id}'),
                    mark: c.mark,
                    pinned: true,
                    hint: l.pinnedAllDay,
                    onTap: () =>
                        showMarkEditor(context, date: today, markId: c.mark.id),
                  )
                : Dismissible(
                    key: ValueKey('home-swipe-${c.mark.id}'),
                    direction: DismissDirection.horizontal,
                    background: const _SwipeBackground(
                      alignment: Alignment.centerLeft,
                    ),
                    secondaryBackground: const _SwipeBackground(
                      alignment: Alignment.centerRight,
                    ),
                    onDismissed: (_) {
                      ref
                          .read(homeDismissalsProvider.notifier)
                          .dismiss(c.mark.id, today);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(l.doneForToday(c.mark.titleIn(l))),
                            action: SnackBarAction(
                              label: l.undoAction,
                              onPressed: () => ref
                                  .read(homeDismissalsProvider.notifier)
                                  .restore(c.mark.id, today),
                            ),
                          ),
                        );
                    },
                    child: MarkCard(
                      key: ValueKey('home-card-${c.mark.id}'),
                      mark: c.mark,
                      hint: l.swipeToDismiss,
                      onTap: () => showMarkEditor(
                        context,
                        date: today,
                        markId: c.mark.id,
                      ),
                    ),
                  ),
          ),
      ],
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, color: scheme.onSecondaryContainer),
          const SizedBox(width: 8),
          Text(
            context.l10n.doneForTodayLabel,
            style: TextStyle(color: scheme.onSecondaryContainer),
          ),
        ],
      ),
    );
  }
}
