import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/rhythm_pace.dart';
import '../../application/sadhana_session_provider.dart';
import '../../../../l10n/l10n.dart';
import '../../../../l10n/labels.dart';

/// Number field + Seconds/Minutes/Hours selector. Interval = value × unit.
///
/// Invalid or empty input is ignored: the session keeps its last valid pace
/// and the field explains what is wrong.
class RhythmPaceEditor extends ConsumerStatefulWidget {
  const RhythmPaceEditor({super.key});

  @override
  ConsumerState<RhythmPaceEditor> createState() => _RhythmPaceEditorState();
}

class _RhythmPaceEditorState extends ConsumerState<RhythmPaceEditor> {
  late PaceUnit _unit;
  late final TextEditingController _value;

  @override
  void initState() {
    super.initState();
    final seconds = ref.read(sadhanaSessionProvider).rhythmSeconds;
    _unit = bestPaceUnit(seconds);
    _value = TextEditingController(text: paceValueText(seconds, _unit));
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  void _push() {
    final result = checkPace(_value.text, _unit, context.l10n);
    if (result.seconds != null) {
      ref.read(sadhanaSessionProvider.notifier).setRhythmSeconds(result.seconds!);
    }
    setState(() {}); // refresh the helper / error text
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = ref.watch(sadhanaSessionProvider.select((s) => s.rhythmSeconds));
    final l = context.l10n;
    final error = checkPace(_value.text, _unit, l).error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: TextField(
                controller: _value,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  LengthLimitingTextInputFormatter(8),
                ],
                decoration: InputDecoration(labelText: l.paceFieldLabel),
                onChanged: (_) => _push(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SegmentedButton<PaceUnit>(
                segments: [
                  for (final u in PaceUnit.values)
                    ButtonSegment(
                      value: u,
                      label: Text(u.localized(l), style: const TextStyle(fontSize: 12)),
                    ),
                ],
                selected: {_unit},
                showSelectedIcon: false,
                onSelectionChanged: (v) {
                  _unit = v.first;
                  _push();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          error == null
              ? l.paceHelpOk(formatPaceEvery(current), paceRangeText)
              : l.paceHelpError(error, formatPaceEvery(current)),
          style: theme.textTheme.bodySmall?.copyWith(
            color: error == null
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.error,
          ),
        ),
      ],
    );
  }
}
