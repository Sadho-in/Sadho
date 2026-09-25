import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../../clock/application/clock_source.dart';
import '../data/note.dart';

/// Every note, newest first, saved in Hive (offline). Included in Backup and
/// erased by Delete account, like everything else the app stores.
class NotesNotifier extends Notifier<List<Note>> {
  int _seq = 0;

  @override
  List<Note> build() => _sorted([
        for (final v in AppStorage.notes.values) ?Note.fromMap(v),
      ]);

  DateTime get _now => ref.read(clockNowProvider)();

  /// A new, not yet saved note (it is saved by the first [save]).
  Note draft() {
    final now = _now;
    return Note(
      id: 'n_${now.microsecondsSinceEpoch}_${_seq++}',
      created: now,
      edited: now,
    );
  }

  Note? byId(String id) {
    for (final n in state) {
      if (n.id == id) return n;
    }
    return null;
  }

  /// Saves [title] and [text] into [note] (a draft or a saved note), marking
  /// it edited now. Called as the user types.
  Note save(Note note, {required String title, required String text}) {
    final next = note.copyWith(title: title, text: text, edited: _now);
    AppStorage.notes.put(next.id, next.toMap());
    state = _sorted([
      for (final n in state)
        if (n.id != next.id) n,
      next,
    ]);
    return next;
  }

  Future<void> delete(String id) async {
    state = [
      for (final n in state)
        if (n.id != id) n,
    ];
    await AppStorage.notes.delete(id);
  }

  /// Newest first (by when it was written).
  static List<Note> _sorted(List<Note> notes) =>
      notes..sort((a, b) => b.created.compareTo(a.created));
}

final notesProvider =
    NotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);
