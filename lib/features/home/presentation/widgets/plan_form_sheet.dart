import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/plans_provider.dart';
import '../../data/plan.dart';

/// Start a plan: a paath or a mantra, for N days.
class PlanFormSheet extends ConsumerStatefulWidget {
  const PlanFormSheet({super.key});

  @override
  ConsumerState<PlanFormSheet> createState() => _PlanFormSheetState();
}

class _PlanFormSheetState extends ConsumerState<PlanFormSheet> {
  final _title = TextEditingController();
  final _days = TextEditingController(text: '21');
  PlanKind _kind = PlanKind.paath;
  bool _tried = false;

  @override
  void dispose() {
    _title.dispose();
    _days.dispose();
    super.dispose();
  }

  int? get _n => int.tryParse(_days.text.trim());

  String? get _titleError =>
      _title.text.trim().isEmpty ? 'Give the plan a name' : null;

  String? get _daysError {
    final n = _n;
    return n == null || n < minPlanDays || n > maxPlanDays
        ? 'Choose $minPlanDays to $maxPlanDays days'
        : null;
  }

  void _save() {
    setState(() => _tried = true);
    if (_titleError != null || _daysError != null) return;
    ref
        .read(plansProvider.notifier)
        .add(title: _title.text, kind: _kind, days: _n!);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New plan', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Pick a paath or mantra and how many days you will keep it up.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < planSuggestions.length; i++)
                  ActionChip(
                    key: ValueKey('suggest-$i'),
                    label: Text(planSuggestions[i].title),
                    onPressed: () => setState(() {
                      final s = planSuggestions[i];
                      _title.text = s.title;
                      _kind = s.kind;
                      _days.text = '${s.days}';
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              key: const ValueKey('plan-title'),
              controller: _title,
              textCapitalization: TextCapitalization.words,
              maxLength: 60,
              decoration: InputDecoration(
                labelText: 'Paath or mantra',
                errorText: _tried ? _titleError : null,
                counterText: '',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<PlanKind>(
                key: const ValueKey('plan-kind'),
                showSelectedIcon: false,
                segments: [
                  for (final k in PlanKind.values)
                    ButtonSegment(value: k, label: Text(k.label)),
                ],
                selected: {_kind},
                onSelectionChanged: (v) => setState(() => _kind = v.first),
              ),
            ),
            const SizedBox(height: 14),
            Text('For how many days?', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final n in planDayChoices)
                  ChoiceChip(
                    key: ValueKey('days-$n'),
                    label: Text('$n'),
                    selected: _n == n,
                    onSelected: (_) => setState(() => _days.text = '$n'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 160,
              child: TextField(
                key: const ValueKey('plan-days'),
                controller: _days,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Days',
                  errorText: _tried || _days.text.isNotEmpty
                      ? _daysError
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const ValueKey('plan-save'),
                onPressed: _save,
                child: const Text('Start plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
