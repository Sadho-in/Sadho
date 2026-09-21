import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../data/calendar_mark.dart';
import 'calendar_marks_provider.dart';
import 'now_provider.dart';

/// Which "once in the morning" cards the user swiped away, and for which day.
/// Saved in Hive so a dismissed card stays dismissed until tomorrow.
class HomeDismissalsNotifier extends Notifier<Set<String>> {
  static const _key = 'calendar.homeDismissed';

  static String keyFor(String markId, DateTime day) => '$markId|${dateKey(day)}';

  @override
  Set<String> build() {
    final raw = AppStorage.settings.get(_key);
    final today = dateOnly(DateTime.now());
    // Old days can never matter again: drop them so the list stays small.
    return {
      if (raw is List)
        for (final v in raw)
          if (v is String && _keep(v, today)) v,
    };
  }

  static bool _keep(String key, DateTime today) {
    final at = key.lastIndexOf('|');
    final day = at < 0 ? null : parseDateKey(key.substring(at + 1));
    return day != null && !day.isBefore(today.subtract(const Duration(days: 1)));
  }

  bool isDismissed(String markId, DateTime day) =>
      state.contains(keyFor(markId, day));

  void dismiss(String markId, DateTime day) => _set({...state, keyFor(markId, day)});

  void restore(String markId, DateTime day) =>
      _set({...state}..remove(keyFor(markId, day)));

  void _set(Set<String> next) {
    state = next;
    AppStorage.settings.put(_key, next.toList());
  }
}

final homeDismissalsProvider =
    NotifierProvider<HomeDismissalsNotifier, Set<String>>(
  HomeDismissalsNotifier.new,
);

/// One card on the Home tab.
class HomeCard {
  const HomeCard({required this.mark, required this.day});

  final CalendarMark mark;

  /// The day the card is for (today).
  final DateTime day;

  /// "Keep all day" cards are pinned: they cannot be swiped away.
  bool get pinned => mark.homeMode == HomeMode.allDay;
}

/// The cards to show on Home right now.
///
/// - **Keep all day**: shown all day on every date the mark falls on; pinned.
/// - **Once in the morning**: appears at its time on those dates and stays
///   until swiped away for the day.
///
/// Pinned cards come first, then the rest by time.
final homeCardsProvider = Provider<List<HomeCard>>((ref) {
  final now = ref.watch(nowProvider);
  final marks = ref.watch(calendarMarksProvider);
  final dismissed = ref.watch(homeDismissalsProvider);
  final today = dateOnly(now);
  final minutes = now.hour * 60 + now.minute;

  final cards = <HomeCard>[];
  for (final m in marks) {
    if (m.homeMode == HomeMode.none || !m.occursOn(today)) continue;
    if (m.homeMode == HomeMode.morning) {
      if (minutes < m.homeMinutes) continue; // not yet its time
      if (dismissed.contains(HomeDismissalsNotifier.keyFor(m.id, today))) {
        continue;
      }
    }
    cards.add(HomeCard(mark: m, day: today));
  }
  cards.sort((a, b) {
    if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
    return a.mark.homeMinutes.compareTo(b.mark.homeMinutes);
  });
  return cards;
});
