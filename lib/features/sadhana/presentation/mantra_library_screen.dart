import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/mantra_library_provider.dart';
import '../application/selected_mantra_provider.dart';
import '../application/voice_training_provider.dart';
import '../data/mantra.dart';
import 'widgets/mantra_form_sheet.dart';
import 'voice_training_screen.dart';
import 'widgets/script_text.dart';
import 'widgets/voice_widgets.dart';
import '../../../l10n/l10n.dart';

/// Searchable mantra / paath library. Pops with the chosen [Mantra].
class MantraLibraryScreen extends ConsumerStatefulWidget {
  const MantraLibraryScreen({super.key});

  @override
  ConsumerState<MantraLibraryScreen> createState() =>
      _MantraLibraryScreenState();
}

class _MantraLibraryScreenState extends ConsumerState<MantraLibraryScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final library = ref.watch(mantraLibraryProvider);
    final selected = ref.watch(selectedMantraProvider);
    final results = library.where((m) => m.matches(_query)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.mantraLibraryTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: Text(context.l10n.addMantra),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            // A text field rather than a SearchBar: its whole 56 dp box is
            // the tap target, and screen readers hear what it is for.
            child: TextField(
              key: const ValueKey('library-search'),
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: context.l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                fillColor: theme.colorScheme.surfaceContainerLow,
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: context.l10n.actionClear,
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        context.l10n.noMantrasMatch(_query),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _MantraTile(
                      mantra: results[i],
                      selected: results[i].id == selected.id,
                      onTap: () => Navigator.of(context).pop(results[i]),
                      onEdit: () => _edit(results[i]),
                      onDelete: results[i].isCustom
                          ? () => _confirmDelete(results[i])
                          : null,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _add() => _openForm(null);

  Future<void> _edit(Mantra m) => _openForm(m);

  Future<void> _openForm(Mantra? editing) async {
    final result = await showModalBottomSheet<MantraFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => MantraFormSheet(editing: editing),
    );
    if (result == null || !mounted) return;
    final title = result.mantra.title;
    // Replace, don't queue: back-to-back changes must each be confirmed now.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(switch (result.action) {
            MantraFormAction.added => context.l10n.mantraAdded(title),
            MantraFormAction.saved => context.l10n.mantraSaved(title),
            MantraFormAction.restored => context.l10n.mantraRestored(title),
          }),
        ),
      );
  }

  Future<void> _confirmDelete(Mantra m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteMantraTitle),
        content: Text(context.l10n.deleteMantraBody(m.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.actionDelete),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(mantraLibraryProvider.notifier).remove(m.id);
  }
}

class _MantraTile extends ConsumerWidget {
  const _MantraTile({
    required this.mantra,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    this.onDelete,
  });

  final Mantra mantra;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  /// Only custom mantras can be deleted; built-ins can only be edited/reset.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final trained = ref.watch(mantraTrainedProvider(mantra.id));
    return Card(
      color: selected ? scheme.primaryContainer.withValues(alpha: 0.5) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mantra.title, style: theme.textTheme.titleLarge),
                    if (mantra.script.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ScriptText(
                        mantra.script,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                      ),
                    ],
                    if (mantra.transliteration.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        mantra.transliteration,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _Tag(
                          mantra.tradition,
                          scheme.secondaryContainer,
                          scheme.onSecondaryContainer,
                        ),
                        _Tag(
                          context.l10n.mantraCountTag(mantra.defaultCount),
                          scheme.surfaceContainerHigh,
                          scheme.onSurface,
                        ),
                        if (mantra.isEdited)
                          _Tag(
                            context.l10n.editedTag,
                            scheme.tertiaryContainer,
                            scheme.onTertiaryContainer,
                          ),
                        VoiceTrainedTag(mantra.id),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (selected)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.check_circle, color: scheme.primary),
                    ),
                  IconButton(
                    tooltip: context.l10n.actionEdit,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    tooltip: trained
                        ? context.l10n.retrainVoiceTooltip
                        : context.l10n.trainVoice,
                    icon: Icon(trained ? Icons.mic : Icons.mic_none),
                    onPressed: () => openVoiceTraining(context, mantra),
                  ),
                  if (onDelete != null)
                    IconButton(
                      tooltip: context.l10n.actionDelete,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, this.background, this.foreground);
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: foreground),
      ),
    );
  }
}
