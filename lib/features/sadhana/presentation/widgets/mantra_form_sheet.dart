import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/mantra_library_provider.dart';
import '../../data/mantra.dart';
import '../../../../l10n/l10n.dart';

enum MantraFormAction { added, saved, restored }

/// What the form hands back when it closes with a change.
class MantraFormResult {
  const MantraFormResult(this.action, this.mantra);
  final MantraFormAction action;
  final Mantra mantra;
}

/// One form for adding a custom mantra and for editing any mantra (custom or
/// built-in); saved locally with Hive. Pass [editing] to pre-fill it. Pops a
/// [MantraFormResult] on success.
///
/// Built-in mantras are saved as an override; once one has been edited the
/// form also offers "Reset to default".
class MantraFormSheet extends ConsumerStatefulWidget {
  const MantraFormSheet({super.key, this.editing});

  final Mantra? editing;

  @override
  ConsumerState<MantraFormSheet> createState() => _MantraFormSheetState();
}

class _MantraFormSheetState extends ConsumerState<MantraFormSheet> {
  static const _traditions = [
    'Sanskrit · Hindu',
    'Gurmukhi · Sikh',
    'Gurbani · Sikh',
    'Buddhist',
    'Jain',
    'Other',
  ];

  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.editing?.title);
  late final _script = TextEditingController(text: widget.editing?.script);
  late final _translit =
      TextEditingController(text: widget.editing?.transliteration);
  late final _tradition = TextEditingController(text: widget.editing?.tradition);
  late final _count = TextEditingController(
      text: '${widget.editing?.defaultCount ?? 108}');
  bool _saving = false;

  bool get _isEdit => widget.editing != null;

  @override
  void dispose() {
    for (final c in [_title, _script, _translit, _tradition, _count]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final library = ref.read(mantraLibraryProvider.notifier);
    final title = _title.text;
    final script = _script.text;
    final translit = _translit.text;
    final tradition = _tradition.text;
    final count = int.parse(_count.text.trim());
    final result = _isEdit
        ? MantraFormResult(
            MantraFormAction.saved,
            await library.update(
              widget.editing!.id,
              title: title,
              script: script,
              transliteration: translit,
              tradition: tradition,
              defaultCount: count,
            ),
          )
        : MantraFormResult(
            MantraFormAction.added,
            await library.add(
              title: title,
              script: script,
              transliteration: translit,
              tradition: tradition,
              defaultCount: count,
            ),
          );
    if (mounted) Navigator.of(context).pop(result);
  }

  Future<void> _reset() async {
    final m = widget.editing!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.resetToDefaultTitle),
        content: Text(context.l10n.resetToDefaultBody(m.title)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.l10n.actionCancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(context.l10n.actionReset)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _saving = true);
    final restored =
        await ref.read(mantraLibraryProvider.notifier).resetToDefault(m.id);
    if (mounted) {
      Navigator.of(context)
          .pop(MantraFormResult(MantraFormAction.restored, restored));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      // Lift the sheet above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isEdit ? context.l10n.editMantra : context.l10n.addAMantra,
                    style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _title,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: context.l10n.titleLabel),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? context.l10n.titleRequired
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _script,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: context.l10n.scriptTextLabel,
                    // The example script stays in its own language on purpose:
                    // it shows what belongs in this field, not a translation.
                    hintText: 'e.g. ॐ नमः शिवाय or ਵਾਹਿਗੁਰੂ',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _translit,
                  minLines: 1,
                  maxLines: 3,
                  decoration:
                      InputDecoration(labelText: context.l10n.transliterationLabel),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tradition,
                  decoration: InputDecoration(
                    labelText: context.l10n.traditionLabel,
                    // Not translated: this names a specific tradition, like the
                    // suggestion chips below (mantra content, not UI chrome).
                    hintText: context.l10n.traditionHint,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final t in _traditions)
                      ActionChip(
                        label: Text(t),
                        onPressed: () => setState(() => _tradition.text = t),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _count,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: context.l10n.defaultCountLabel),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null || n < 1) return context.l10n.enterNumberOneOrMore;
                    if (n > maxMantraCount) return context.l10n.tooLarge;
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_isEdit ? context.l10n.saveChanges : context.l10n.saveToLibrary),
                  ),
                ),
                if (widget.editing?.isEdited ?? false)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: _saving ? null : _reset,
                      icon: const Icon(Icons.restore, size: 18),
                      label: Text(context.l10n.resetToDefaultButton),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
