import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/l10n.dart';
import '../../../../l10n/labels.dart';
import '../../../calendar/application/now_provider.dart';
import '../../application/plans_provider.dart';
import '../../data/plan.dart';
import 'plan_form_sheet.dart';

/// Paath & mantra plans: a streak, the number of active plans, and a card per
/// plan with a progress bar and "Mark today done".
///
/// TODO(later-phase): count a plan's day automatically from Sadhana sessions.
class PlansSection extends ConsumerWidget {
  const PlansSection({super.key});

  Future<void> _add(BuildContext context) => showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const PlanFormSheet(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;
    final plans = ref.watch(plansProvider);
    final streak = ref.watch(streakProvider);
    final active = ref.watch(activePlanCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l.plansTitle,
                style: theme.textTheme.titleLarge,
              ),
            ),
            TextButton.icon(
              key: const ValueKey('plan-add'),
              onPressed: () => _add(context),
              icon: const Icon(Icons.add),
              label: Text(l.addPlan),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _Stat(
                valueKey: 'stat-streak',
                icon: Icons.local_fire_department,
                value: '$streak',
                label: l.dayStreak,
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Stat(
                valueKey: 'stat-active',
                icon: Icons.flag_outlined,
                value: '$active',
                label: l.activePlanCount(active),
                color: scheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (plans.isEmpty)
          _Suggestions(
            onAdd: (s) {
              ref
                  .read(plansProvider.notifier)
                  .add(title: s.title, kind: s.kind, days: s.days);
            },
          )
        else
          for (final p in plans)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PlanCard(plan: p),
            ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.valueKey,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final String valueKey;
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    key: ValueKey(valueKey),
                    style: theme.textTheme.headlineSmall,
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onAdd});
  final void Function(PlanSuggestion) onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.noPlansYet,
              key: const ValueKey('plans-empty'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l.plansEmptyBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < planSuggestions.length; i++)
                  ActionChip(
                    key: ValueKey('start-$i'),
                    avatar: Icon(
                      planSuggestions[i].kind == PlanKind.paath
                          ? Icons.menu_book_outlined
                          : Icons.self_improvement,
                      size: 18,
                    ),
                    label: Text(l.titledDaysTag(
                        planSuggestions[i].title, planSuggestions[i].days)),
                    onPressed: () => onAdd(planSuggestions[i]),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  const _PlanCard({required this.plan});
  final Plan plan;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deletePlanQuestion),
        content: Text(l.deletePlanBody(plan.title)),
        actions: [
          TextButton(
            key: const ValueKey('plan-delete-cancel'),
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            key: const ValueKey('plan-delete-confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.actionDelete),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(plansProvider.notifier).remove(plan.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;
    // Today's mark is what the button toggles.
    final doneToday = plan.doneOn(ref.watch(nowProvider));
    final finished = plan.isComplete;

    return Card(
      key: ValueKey('plan-${plan.id}'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.title,
                    key: ValueKey('plan-title-${plan.id}'),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                PopupMenuButton<String>(
                  key: ValueKey('plan-menu-${plan.id}'),
                  tooltip: l.planOptionsTooltip,
                  onSelected: (v) {
                    if (v == 'delete') _confirmDelete(context, ref);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                        value: 'delete', child: Text(l.deletePlanMenuItem)),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  plan.kind == PlanKind.paath
                      ? Icons.menu_book_outlined
                      : Icons.self_improvement,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l.titledDaysTag(plan.kind.localized(l), plan.totalDays),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  key: ValueKey('plan-bar-${plan.id}'),
                  value: plan.progress,
                  minHeight: 8,
                  backgroundColor: scheme.surfaceContainerHigh,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 6,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    finished
                        ? l.completedOfDays(plan.completed, plan.totalDays)
                        : l.ofDays(plan.completed, plan.totalDays),
                    key: ValueKey('plan-progress-${plan.id}'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: finished ? scheme.primary : null,
                      fontWeight: finished ? FontWeight.w700 : null,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: doneToday
                      ? OutlinedButton.icon(
                          key: ValueKey('plan-toggle-${plan.id}'),
                          onPressed: () => ref
                              .read(plansProvider.notifier)
                              .toggleToday(plan.id),
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: Text(l.doneTodayButton),
                        )
                      : FilledButton(
                          key: ValueKey('plan-toggle-${plan.id}'),
                          onPressed: finished
                              ? null
                              : () => ref
                                    .read(plansProvider.notifier)
                                    .toggleToday(plan.id),
                          child: Text(l.markTodayDone),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
