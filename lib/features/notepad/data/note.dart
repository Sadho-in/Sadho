import '../../../l10n/app_localizations.dart';

/// One note in the notepad: an optional title and the text, with when it was
/// written and last changed. Saved on the phone only.
class Note {
  const Note({
    required this.id,
    this.title = '',
    this.text = '',
    required this.created,
    required this.edited,
  });

  final String id;
  final String title;
  final String text;
  final DateTime created;
  final DateTime edited;

  /// Nothing written: such a note is not kept.
  bool get isEmpty => title.trim().isEmpty && text.trim().isEmpty;

  /// What the list shows as its name: the title, else the first line of the
  /// text.
  String headingIn(AppLocalizations l) {
    if (title.trim().isNotEmpty) return title.trim();
    final first = text.trim().split('\n').first.trim();
    return first.isEmpty ? l.noteUntitled : first;
  }

  /// The text under the heading in the list (without a first line that is
  /// already the heading).
  String get snippet {
    final t = text.trim();
    if (title.trim().isNotEmpty) return t;
    final lines = t.split('\n');
    return lines.length < 2 ? '' : lines.skip(1).join('\n').trim();
  }

  /// Whether [query] is in the title or the text (any case).
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) || text.toLowerCase().contains(q);
  }

  Note copyWith({String? title, String? text, DateTime? edited}) => Note(
        id: id,
        title: title ?? this.title,
        text: text ?? this.text,
        created: created,
        edited: edited ?? this.edited,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'text': text,
        'created': created.millisecondsSinceEpoch,
        'edited': edited.millisecondsSinceEpoch,
      };

  /// Null for anything that is not a saved note.
  static Note? fromMap(Object? m) {
    if (m is! Map) return null;
    final id = m['id'], created = m['created'], edited = m['edited'];
    if (id is! String || id.isEmpty || created is! int) return null;
    final c = DateTime.fromMillisecondsSinceEpoch(created);
    return Note(
      id: id,
      title: m['title'] is String ? m['title'] as String : '',
      text: m['text'] is String ? m['text'] as String : '',
      created: c,
      edited: edited is int ? DateTime.fromMillisecondsSinceEpoch(edited) : c,
    );
  }
}
