import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';

/// The Sadhana cards that open and close from their header.
abstract final class SadhanaCard {
  static const target = 'target';
  static const completion = 'completion';
  static const sankalp = 'sankalp';
  static const all = {target, completion, sankalp};
}

/// Which of those cards are closed (every card is open by default). Saved in
/// Hive, so a card stays as the user left it after a restart.
class CollapsedCardsNotifier extends Notifier<Set<String>> {
  static const _key = 'sadhana.collapsedCards';

  @override
  Set<String> build() {
    final saved = AppStorage.settings.get(_key);
    return {
      if (saved is List)
        for (final id in saved)
          if (id is String && SadhanaCard.all.contains(id)) id,
    };
  }

  bool isOpen(String id) => !state.contains(id);

  void toggle(String id) {
    final next = {...state};
    if (!next.remove(id)) next.add(id);
    state = next;
    AppStorage.settings.put(_key, next.toList()..sort());
  }
}

final collapsedCardsProvider =
    NotifierProvider<CollapsedCardsNotifier, Set<String>>(
        CollapsedCardsNotifier.new);
