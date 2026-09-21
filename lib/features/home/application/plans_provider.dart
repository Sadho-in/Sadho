import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../../calendar/application/now_provider.dart';
import '../../calendar/data/calendar_mark.dart' show dateKey, dateOnly;
import '../data/plan.dart';

/// The paath and mantra plans, saved in Hive.
class PlansNotifier extends Notifier<List<Plan>> {
  static const _key = 'home.plans';

  @override
  List<Plan> build() {
    final raw = AppStorage.settings.get(_key);
    return [
      if (raw is List)
        for (final m in raw) ?Plan.fromMap(m),
    ];
  }

  DateTime get _today => dateOnly(ref.read(nowProvider));

  /// Starts a plan today. Returns null (and adds nothing) if the title is empty
  /// or the days are outside 1–365.
  Plan? add({
    required String title,
    required PlanKind kind,
    required int days,
  }) {
    final t = title.trim();
    if (t.isEmpty || days < minPlanDays || days > maxPlanDays) return null;
    final now = ref.read(nowProvider);
    var n = 0;
    String idFor(int i) => 'plan-${now.microsecondsSinceEpoch}-$i';
    while (state.any((p) => p.id == idFor(n))) {
      n++;
    }
    final plan = Plan(
      id: idFor(n),
      title: t.length > 60 ? t.substring(0, 60) : t,
      kind: kind,
      totalDays: days,
      startDate: _today,
    );
    _set([...state, plan]);
    return plan;
  }

  /// Marks today done for the plan, or takes the mark back if it was already
  /// done today. A finished plan cannot be marked further.
  void toggleToday(String id) {
    final today = dateKey(_today);
    _set([
      for (final p in state)
        if (p.id != id)
          p
        else if (p.doneDays.contains(today))
          p.copyWith(doneDays: {...p.doneDays}..remove(today))
        else if (p.isComplete)
          p
        else
          p.copyWith(doneDays: {...p.doneDays, today}),
    ]);
  }

  void remove(String id) => _set([
    for (final p in state)
      if (p.id != id) p,
  ]);

  void _set(List<Plan> next) {
    state = next;
    AppStorage.settings.put(_key, [for (final p in next) p.toMap()]);
  }
}

final plansProvider = NotifierProvider<PlansNotifier, List<Plan>>(
  PlansNotifier.new,
);

/// Plans still to finish.
final activePlanCountProvider = Provider<int>(
  (ref) => ref.watch(plansProvider).where((p) => p.isActive).length,
);

/// Days in a row with at least one plan done.
final streakProvider = Provider<int>((ref) {
  final plans = ref.watch(plansProvider);
  final now = ref.watch(nowProvider);
  return currentStreak({for (final p in plans) ...p.doneDays}, now);
});
