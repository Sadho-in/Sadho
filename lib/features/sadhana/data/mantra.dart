/// A mantra / paath the user can count.
class Mantra {
  const Mantra({
    required this.id,
    required this.title,
    required this.script,
    required this.transliteration,
    required this.tradition,
    required this.defaultCount,
    this.isCustom = false,
    this.isEdited = false,
    this.createdAt,
  });

  final String id;
  final String title;

  /// Text in its native script (Devanagari, Gurmukhi, ...).
  final String script;
  final String transliteration;

  /// Tradition / language tag, e.g. "Sanskrit · Hindu".
  final String tradition;
  final int defaultCount;
  final bool isCustom;

  /// A built-in mantra carrying the user's edits (see [MantraLibraryNotifier]).
  final bool isEdited;
  final DateTime? createdAt;

  Mantra copyWith({
    String? title,
    String? script,
    String? transliteration,
    String? tradition,
    int? defaultCount,
    bool? isEdited,
  }) =>
      Mantra(
        id: id,
        title: title ?? this.title,
        script: script ?? this.script,
        transliteration: transliteration ?? this.transliteration,
        tradition: tradition ?? this.tradition,
        defaultCount: defaultCount ?? this.defaultCount,
        isCustom: isCustom,
        isEdited: isEdited ?? this.isEdited,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'script': script,
        'transliteration': transliteration,
        'tradition': tradition,
        'defaultCount': defaultCount,
        'createdAt': createdAt?.millisecondsSinceEpoch,
      };

  factory Mantra.fromMap(Map<dynamic, dynamic> m) => Mantra(
        id: m['id'] as String,
        title: m['title'] as String,
        script: (m['script'] as String?) ?? '',
        transliteration: (m['transliteration'] as String?) ?? '',
        tradition: (m['tradition'] as String?) ?? '',
        defaultCount: (m['defaultCount'] as int?) ?? 108,
        isCustom: true,
        createdAt: m['createdAt'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int),
      );

  /// Case-insensitive match across every text field.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        script.toLowerCase().contains(q) ||
        transliteration.toLowerCase().contains(q) ||
        tradition.toLowerCase().contains(q);
  }
}
