import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../../calendar/application/now_provider.dart';
import '../../clock/application/location_provider.dart';
import '../../clock/data/sun_alarm.dart';
import '../data/tradition.dart';

/// The tradition picked on Home, or null until one is picked (Profile counts
/// picking one towards its completion). Saved in Hive.
class TraditionNotifier extends Notifier<Tradition?> {
  static const _key = 'home.tradition';

  @override
  Tradition? build() => Tradition.byName(AppStorage.settings.get(_key));

  void set(Tradition t) {
    state = t;
    AppStorage.settings.put(_key, t.name);
  }
}

final traditionProvider = NotifierProvider<TraditionNotifier, Tradition?>(
  TraditionNotifier.new,
);

/// What Home shows: the picked tradition, Hindu until one is picked.
final effectiveTraditionProvider = Provider<Tradition>(
  (ref) => ref.watch(traditionProvider) ?? Tradition.hindu,
);

/// The "Today" lines for the chosen tradition. Sunrise and sunset are real, for
/// the phone's place (Amritsar if unknown); the rest are EXAMPLE values.
final todayDetailsProvider = Provider<List<TodayDetail>>((ref) {
  final tradition = ref.watch(effectiveTraditionProvider);
  final now = ref.watch(nowProvider);
  final p = ref.watch(locationProvider.select((l) => l.point));
  final day = DateTime(now.year, now.month, now.day);
  return todayDetails(
    tradition,
    sunrise: sunEventOn(SunEventKind.sunrise, day, p.lat, p.lon),
    sunset: sunEventOn(SunEventKind.sunset, day, p.lat, p.lon),
  );
});
