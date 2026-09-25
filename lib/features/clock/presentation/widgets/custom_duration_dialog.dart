import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/l10n.dart';
import '../../data/timer_presets.dart';

/// Asks for a timer length in hours, minutes and seconds (1 s to 24 h).
/// Returns the length in seconds, or null if cancelled.
Future<int?> showCustomDurationDialog(BuildContext context,
        {required int initialSeconds}) =>
    showDialog<int>(
      context: context,
      builder: (_) => CustomDurationDialog(initialSeconds: initialSeconds),
    );

class CustomDurationDialog extends StatefulWidget {
  const CustomDurationDialog({super.key, required this.initialSeconds});

  final int initialSeconds;

  @override
  State<CustomDurationDialog> createState() => _CustomDurationDialogState();
}

class _CustomDurationDialogState extends State<CustomDurationDialog> {
  late final _h = TextEditingController(text: '${widget.initialSeconds ~/ 3600}');
  late final _m =
      TextEditingController(text: '${(widget.initialSeconds % 3600) ~/ 60}');
  late final _s = TextEditingController(text: '${widget.initialSeconds % 60}');

  @override
  void dispose() {
    _h.dispose();
    _m.dispose();
    _s.dispose();
    super.dispose();
  }

  /// The length entered, or null when a field is out of range or the total is
  /// not 1 s to 24 h.
  int? get _seconds {
    int part(TextEditingController c) => int.tryParse(c.text) ?? 0;
    final h = part(_h), m = part(_m), s = part(_s);
    if (m > 59 || s > 59) return null;
    final total = h * 3600 + m * 60 + s;
    return isValidCustomSeconds(total) ? total : null;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final value = _seconds;

    Widget field(String key, String unit, TextEditingController c) => Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The unit above the box (not a floating label, which is one
              // line and would cut a long word short).
              Text(unit,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              TextField(
                key: ValueKey(key),
                controller: c,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  semanticCounterText: unit,
                ),
                style: theme.textTheme.headlineSmall,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        );

    return AlertDialog(
      title: Text(l.customTimerTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                field('custom-h', l.unitHours, _h),
                const SizedBox(width: 8),
                field('custom-m', l.unitMinutes, _m),
                const SizedBox(width: 8),
                field('custom-s', l.unitSeconds, _s),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l.customTimerRange,
              key: const ValueKey('custom-range'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: value == null
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.actionCancel),
        ),
        FilledButton(
          key: const ValueKey('custom-ok'),
          onPressed: value == null ? null : () => Navigator.pop(context, value),
          child: Text(l.actionOk),
        ),
      ],
    );
  }
}
