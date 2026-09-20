import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/sadhana_session_provider.dart';

/// "Count: Combined | Separate".
///
/// - **Combined**: Tap, Voice, Rhythm and Mala all add to ONE shared count
///   (the sum of the four) toward one target.
/// - **Separate**: each mode keeps its own count and its own progress toward
///   the target; Reset and completion apply only to the active mode.
///
/// [compact] is the one-line version under the mantra card on the Sadhana
/// screen; the full version (with an explanation) lives in Settings. Both read
/// and write the same persisted setting.
class CountScopeControl extends ConsumerWidget {
  const CountScopeControl({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(sadhanaSessionProvider.select((s) => s.scope));
    final notifier = ref.read(sadhanaSessionProvider.notifier);
    final theme = Theme.of(context);

    final segments = [
      ButtonSegment(
        value: CountScope.combined,
        icon: compact ? null : const Icon(Icons.merge_type),
        label: const Text('Combined'),
        tooltip: 'All four modes add to one shared count',
      ),
      ButtonSegment(
        value: CountScope.separate,
        icon: compact ? null : const Icon(Icons.call_split),
        label: const Text('Separate'),
        tooltip: 'Each mode keeps its own count',
      ),
    ];

    if (compact) {
      return Row(
        children: [
          Text('Count:', style: theme.textTheme.labelLarge),
          const SizedBox(width: 10),
          Expanded(
            child: SegmentedButton<CountScope>(
              segments: segments,
              selected: {scope},
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity(horizontal: -2, vertical: -3),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onSelectionChanged: (v) => notifier.setCountScope(v.first),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Count', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<CountScope>(
            segments: segments,
            selected: {scope},
            showSelectedIcon: false,
            onSelectionChanged: (v) => notifier.setCountScope(v.first),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          scope == CountScope.combined
              ? 'Tap, Voice, Rhythm and Mala all add to one shared count '
                  'toward one target.'
              : 'Each mode keeps its own count and its own progress toward '
                  'the target. Reset and completion apply only to the mode '
                  'you are in.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
