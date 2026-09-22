import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/sadhana_session_provider.dart';
import '../format.dart';
import 'section_card.dart';
import '../../../../l10n/l10n.dart';

const _presets = [27, 108, 1008];

enum _TimeUnit {
  seconds(1),
  minutes(60),
  hours(3600);

  const _TimeUnit(this.inSeconds);
  final int inSeconds;

  String localized(AppLocalizations l) => switch (this) {
        _TimeUnit.seconds => l.unitSeconds,
        _TimeUnit.minutes => l.unitMinutes,
        _TimeUnit.hours => l.unitHours,
      };
}

/// Target by COUNT (27 / 108 / 1008 / custom) or by TIME (s / min / h).
class TargetSection extends ConsumerWidget {
  const TargetSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sadhanaSessionProvider);
    final notifier = ref.read(sadhanaSessionProvider.notifier);

    final l = context.l10n;
    return SectionCard(
      title: l.targetSectionTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<TargetType>(
              segments: [
                ButtonSegment(
                  value: TargetType.count,
                  icon: const Icon(Icons.tag),
                  label: Text(l.byCount),
                ),
                ButtonSegment(
                  value: TargetType.time,
                  icon: const Icon(Icons.timer_outlined),
                  label: Text(l.byTime),
                ),
              ],
              selected: {s.targetType},
              showSelectedIcon: false,
              onSelectionChanged: (v) => notifier.setTargetType(v.first),
            ),
          ),
          const SizedBox(height: 16),
          if (s.isTimeTarget)
            _TimeTargetEditor(
              initialSeconds: s.targetSeconds,
              onChanged: notifier.setTargetSeconds,
            )
          else
            _CountTargetEditor(
              current: s.targetCount,
              onChanged: notifier.setTargetCount,
            ),
        ],
      ),
    );
  }
}

class _CountTargetEditor extends StatelessWidget {
  const _CountTargetEditor({required this.current, required this.onChanged});

  final int current;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final isCustom = !_presets.contains(current);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final p in _presets)
          ChoiceChip(
            label: Text('$p'),
            selected: current == p,
            onSelected: (_) => onChanged(p),
          ),
        ChoiceChip(
          avatar: const Icon(Icons.edit_outlined, size: 18),
          label: Text(isCustom
              ? context.l10n.customWithValue('$current')
              : context.l10n.custom),
          selected: isCustom,
          onSelected: (_) async {
            final v = await _askCount(context, current);
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }

  Future<int?> _askCount(BuildContext context, int initial) {
    final controller = TextEditingController(text: '$initial');
    return showDialog<int>(
      context: context,
      builder: (ctx) {
        String? error;
        return StatefulBuilder(
          builder: (ctx, setState) {
            void submit() {
              final n = int.tryParse(controller.text.trim());
              if (n == null || n < 1 || n > 9999999) {
                setState(() => error = context.l10n.enterNumberRange);
                return;
              }
              Navigator.pop(ctx, n);
            }

            return AlertDialog(
              title: Text(context.l10n.customCountTitle),
              content: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: context.l10n.targetCountLabel,
                  errorText: error,
                ),
                onSubmitted: (_) => submit(),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(context.l10n.actionCancel)),
                FilledButton(onPressed: submit, child: Text(context.l10n.setAction)),
              ],
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }
}

class _TimeTargetEditor extends StatefulWidget {
  const _TimeTargetEditor({
    required this.initialSeconds,
    required this.onChanged,
  });

  final int initialSeconds;
  final ValueChanged<int> onChanged;

  @override
  State<_TimeTargetEditor> createState() => _TimeTargetEditorState();
}

class _TimeTargetEditorState extends State<_TimeTargetEditor> {
  late _TimeUnit _unit;
  late final TextEditingController _value;

  @override
  void initState() {
    super.initState();
    // Show the saved target in the largest unit that divides it evenly.
    final s = widget.initialSeconds;
    _unit = s % 3600 == 0
        ? _TimeUnit.hours
        : s % 60 == 0
            ? _TimeUnit.minutes
            : _TimeUnit.seconds;
    _value = TextEditingController(text: '${s ~/ _unit.inSeconds}');
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  int? get _seconds {
    final n = int.tryParse(_value.text.trim());
    if (n == null || n < 1) return null;
    return n * _unit.inSeconds;
  }

  void _push() {
    final s = _seconds;
    if (s != null) widget.onChanged(s);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seconds = _seconds;
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
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                decoration: InputDecoration(labelText: context.l10n.durationLabel),
                onChanged: (_) {
                  setState(() {});
                  _push();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SegmentedButton<_TimeUnit>(
                segments: [
                  for (final u in _TimeUnit.values)
                    ButtonSegment(
                      value: u,
                      label: Text(u.localized(context.l10n), style: const TextStyle(fontSize: 12)),
                    ),
                ],
                selected: {_unit},
                showSelectedIcon: false,
                onSelectionChanged: (v) {
                  setState(() => _unit = v.first);
                  _push();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          seconds == null
              ? context.l10n.enterDuration
              : seconds > 359999
                  ? context.l10n.maxDurationCapped
                  : context.l10n.sessionLasts(formatDurationWords(seconds)),
          style: theme.textTheme.bodySmall?.copyWith(
            color: seconds == null
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
