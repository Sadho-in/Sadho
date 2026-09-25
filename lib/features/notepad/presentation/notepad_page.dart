import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/date_formats.dart';
import '../../../l10n/l10n.dart';
import '../application/notes_provider.dart';
import '../data/note.dart';
import 'note_editor_page.dart';

/// Asks before deleting [note]; true if it was deleted.
Future<bool> confirmDeleteNote(
    BuildContext context, WidgetRef ref, Note note) async {
  final l = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      key: const ValueKey('note-delete-dialog'),
      title: Text(l.noteDeleteQuestion),
      content: Text(l.noteDeleteBody(note.headingIn(l))),
      actions: [
        TextButton(
          key: const ValueKey('note-delete-no'),
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l.actionCancel),
        ),
        FilledButton(
          key: const ValueKey('note-delete-yes'),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l.actionDelete),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  await ref.read(notesProvider.notifier).delete(note.id);
  return true;
}

/// Full-screen notepad (a Clock tool): the notes, newest first, with a
/// search; + writes a new one.
class NotepadPage extends ConsumerStatefulWidget {
  const NotepadPage({super.key});

  @override
  ConsumerState<NotepadPage> createState() => _NotepadPageState();
}

class _NotepadPageState extends ConsumerState<NotepadPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(String? id) => Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => NoteEditorPage(noteId: id)));

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final all = ref.watch(notesProvider);
    final query = _search.text;
    final shown = [
      for (final n in all)
        if (n.matches(query)) n,
    ];
    final dates = AppDates.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.clockToolNotepadTitle)),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('note-add'),
        tooltip: l.noteNew,
        onPressed: () => _open(null),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                if (all.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      key: const ValueKey('notes-search'),
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: l.notesSearchHint,
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                        suffixIcon: query.isEmpty
                            ? null
                            : IconButton(
                                key: const ValueKey('notes-search-clear'),
                                tooltip: MaterialLocalizations.of(context)
                                    .deleteButtonTooltip,
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    setState(() => _search.clear()),
                              ),
                      ),
                    ),
                  ),
                if (shown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Text(
                      all.isEmpty ? l.notesEmpty : l.notesNoMatch(query.trim()),
                      key: const ValueKey('notes-empty'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                for (final n in shown)
                  Card(
                    key: ValueKey('note-${n.id}'),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _open(n.id),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n.headingIn(l),
                                      style: theme.textTheme.titleMedium),
                                  if (n.snippet.isNotEmpty)
                                    Text(
                                      n.snippet,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l.noteEditedAt(dates.dateTime(n.edited)),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              key: ValueKey('note-delete-${n.id}'),
                              tooltip: l.noteDelete,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => confirmDeleteNote(context, ref, n),
                            ),
                          ],
                        ),
                      ),
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
