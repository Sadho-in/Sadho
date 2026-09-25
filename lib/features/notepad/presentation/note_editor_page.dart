import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/date_formats.dart';
import '../../../l10n/l10n.dart';
import '../application/notes_provider.dart';
import '../data/note.dart';
import 'notepad_page.dart';

/// Writes or edits one note. There is no Save button: every change is saved
/// as it is typed. A note left empty is not kept.
class NoteEditorPage extends ConsumerStatefulWidget {
  const NoteEditorPage({super.key, this.noteId});

  /// The note to edit; null writes a new one.
  final String? noteId;

  @override
  ConsumerState<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage> {
  late Note _note;

  /// Whether [_note] is in storage yet (a new note is saved on first input).
  late bool _saved;
  late final TextEditingController _title;
  late final TextEditingController _text;

  @override
  void initState() {
    super.initState();
    final notes = ref.read(notesProvider.notifier);
    final existing = widget.noteId == null ? null : notes.byId(widget.noteId!);
    _note = existing ?? notes.draft();
    _saved = existing != null;
    _title = TextEditingController(text: _note.title);
    _text = TextEditingController(text: _note.text);
  }

  @override
  void dispose() {
    _title.dispose();
    _text.dispose();
    super.dispose();
  }

  void _changed() {
    final next = ref
        .read(notesProvider.notifier)
        .save(_note, title: _title.text, text: _text.text);
    setState(() {
      _note = next;
      _saved = true;
    });
  }

  /// On the way out: an empty note is not kept.
  void _leaving() {
    if (_saved && _note.isEmpty) {
      ref.read(notesProvider.notifier).delete(_note.id);
    }
  }

  Future<void> _delete() async {
    if (!_saved) {
      Navigator.of(context).pop();
      return;
    }
    final navigator = Navigator.of(context);
    if (await confirmDeleteNote(context, ref, _note)) {
      _saved = false;
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dates = AppDates.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _leaving();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.noteId == null ? l.noteNew : l.noteEdit),
          actions: [
            IconButton(
              key: const ValueKey('note-delete'),
              tooltip: l.noteDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          ],
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  TextField(
                    key: const ValueKey('note-title'),
                    controller: _title,
                    textCapitalization: TextCapitalization.sentences,
                    style: theme.textTheme.titleLarge,
                    decoration: InputDecoration(
                      hintText: l.noteTitleHint,
                      border: InputBorder.none,
                    ),
                    onChanged: (_) => _changed(),
                  ),
                  TextField(
                    key: const ValueKey('note-text'),
                    controller: _text,
                    autofocus: widget.noteId == null,
                    minLines: 8,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: l.noteTextHint,
                      border: InputBorder.none,
                    ),
                    onChanged: (_) => _changed(),
                  ),
                  const Divider(height: 24),
                  Text(
                    [
                      l.noteCreatedAt(dates.dateTime(_note.created)),
                      if (_saved && _note.edited != _note.created)
                        l.noteEditedAt(dates.dateTime(_note.edited)),
                      l.noteSavedAsYouType,
                    ].join(' · '),
                    key: const ValueKey('note-times'),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
