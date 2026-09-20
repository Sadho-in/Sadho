import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../data/mantra.dart';
import '../data/seed_mantras.dart';
import 'voice_training_provider.dart';

/// Largest default count the form accepts.
const maxMantraCount = 9999999;

/// Seeded mantras (with any of the user's edits applied) followed by the
/// user's custom ones (oldest first).
///
/// Built-in mantras live in code, so an edit is stored as an override in Hive
/// rather than changing them: only the fields that differ from the built-in
/// text are saved, and removing the override restores the default.
class MantraLibraryNotifier extends Notifier<List<Mantra>> {
  @override
  List<Mantra> build() => _load();

  List<Mantra> _load() {
    final custom = AppStorage.customMantras.values
        .map((v) => Mantra.fromMap(v as Map))
        .toList()
      ..sort((a, b) => (a.createdAt ?? DateTime(0))
          .compareTo(b.createdAt ?? DateTime(0)));
    return [
      for (final seed in seedMantras)
        _withOverride(seed, AppStorage.mantraOverrides.get(seed.id)),
      ...custom,
    ];
  }

  /// [seed] with the saved [raw] override applied. Anything malformed in the
  /// override is ignored field by field, so bad data can never hide a mantra.
  static Mantra _withOverride(Mantra seed, Object? raw) {
    if (raw is! Map) return seed;
    String? text(String key) => raw[key] is String ? raw[key] as String : null;
    final title = text('title')?.trim();
    final count = raw['defaultCount'];
    final edited = seed.copyWith(
      title: title == null || title.isEmpty ? null : title,
      script: text('script'),
      transliteration: text('transliteration'),
      tradition: text('tradition'),
      defaultCount:
          count is int && count >= 1 && count <= maxMantraCount ? count : null,
    );
    return edited.title != seed.title ||
            edited.script != seed.script ||
            edited.transliteration != seed.transliteration ||
            edited.tradition != seed.tradition ||
            edited.defaultCount != seed.defaultCount
        ? edited.copyWith(isEdited: true)
        : seed;
  }

  Future<Mantra> add({
    required String title,
    required String script,
    required String transliteration,
    required String tradition,
    required int defaultCount,
  }) async {
    final now = DateTime.now();
    final mantra = Mantra(
      id: 'custom_${now.microsecondsSinceEpoch}',
      title: title.trim(),
      script: script.trim(),
      transliteration: transliteration.trim(),
      tradition: tradition.trim(),
      defaultCount: defaultCount,
      isCustom: true,
      createdAt: now,
    );
    await AppStorage.customMantras.put(mantra.id, mantra.toMap());
    state = _load();
    return mantra;
  }

  /// Saves new text for [id], a custom or a built-in mantra, and returns it.
  /// A built-in edited back to its default text stops counting as edited.
  Future<Mantra> update(
    String id, {
    required String title,
    required String script,
    required String transliteration,
    required String tradition,
    required int defaultCount,
  }) async {
    final current = state.firstWhere(
      (m) => m.id == id,
      orElse: () => throw ArgumentError.value(id, 'id', 'No such mantra'),
    );
    final edited = current.copyWith(
      title: title.trim(),
      script: script.trim(),
      transliteration: transliteration.trim(),
      tradition: tradition.trim(),
      defaultCount: defaultCount,
    );

    if (current.isCustom) {
      await AppStorage.customMantras.put(id, edited.toMap());
    } else {
      final seed = seedMantras.firstWhere((m) => m.id == id);
      final diff = <String, Object>{
        if (edited.title != seed.title) 'title': edited.title,
        if (edited.script != seed.script) 'script': edited.script,
        if (edited.transliteration != seed.transliteration)
          'transliteration': edited.transliteration,
        if (edited.tradition != seed.tradition) 'tradition': edited.tradition,
        if (edited.defaultCount != seed.defaultCount)
          'defaultCount': edited.defaultCount,
      };
      if (diff.isEmpty) {
        await AppStorage.mantraOverrides.delete(id);
      } else {
        await AppStorage.mantraOverrides.put(id, diff);
      }
    }
    state = _load();
    return state.firstWhere((m) => m.id == id);
  }

  /// Drops the user's edits to a built-in mantra. Returns the default text.
  Future<Mantra> resetToDefault(String id) async {
    await AppStorage.mantraOverrides.delete(id);
    state = _load();
    return state.firstWhere(
      (m) => m.id == id,
      orElse: () => throw ArgumentError.value(id, 'id', 'No such mantra'),
    );
  }

  Future<void> remove(String id) async {
    await AppStorage.customMantras.delete(id);
    // Its trained voice goes with it (nothing else could ever use it).
    await ref.read(voiceTrainingProvider.notifier).clear(id);
    state = _load();
  }
}

final mantraLibraryProvider =
    NotifierProvider<MantraLibraryNotifier, List<Mantra>>(
  MantraLibraryNotifier.new,
);
