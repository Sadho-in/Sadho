import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/calendar/application/now_provider.dart';
import 'package:advance_calendar/features/clock/application/clock_source.dart';
import 'package:advance_calendar/features/clock/services/location_service.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/sadhana/services/feedback_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart' show addTearDown;

import '../calendar/calendar_support.dart';
import '../sadhana/test_support.dart' show FakeFeedback, FakeHaptics, FakeSound;

export '../calendar/calendar_support.dart';
export '../sadhana/test_support.dart' show FakeFeedback, FakeHaptics, FakeSound;

/// A clock the test moves by hand (the Clock tab reads time through
/// `clockNowProvider`, since `pump` does not move `DateTime.now`).
class FakeClock {
  FakeClock(this.now);
  DateTime now;

  DateTime call() => now;
  void advance(Duration d) => now = now.add(d);
}

/// Scriptable stand-in for the phone's location.
class FakeLocationService implements LocationService {
  FakeLocationService({
    this.supported = true,
    this.state = LocationAccess.granted,
    this.lat = 51.5074,
    this.lon = -0.1278,
    this.hasFix = true,
  });

  bool supported;

  /// What the permission looks like now.
  LocationAccess state;

  /// What asking the user results in (only from [LocationAccess.denied]).
  LocationAccess afterAsk = LocationAccess.granted;
  double lat;
  double lon;
  bool hasFix;
  int accessChecks = 0;
  int asks = 0;
  int settingsOpened = 0;

  @override
  bool get isSupported => supported;

  @override
  Future<LocationAccess> access() async {
    accessChecks++;
    return state;
  }

  @override
  Future<LocationAccess> requestAccess() async {
    asks++;
    state = afterAsk;
    return state;
  }

  @override
  Future<({double lat, double lon})?> position() async =>
      hasFix ? (lat: lat, lon: lon) : null;

  @override
  Future<void> openSettings() async => settingsOpened++;
}

/// A day in the middle of the week, at breakfast time.
DateTime clockTestNow() => DateTime(2026, 9, 21, 8, 0);

/// Everything the Clock tab talks to, replaced.
///
/// Location defaults to "no permission, not asked": the app then uses Amritsar,
/// exactly what a first launch does.
List<Override> clockOverrides({
  FakeClock? clock,
  FakeScheduler? scheduler,
  FakeLocationService? location,
  FakeFeedback? feedback,
  FakeHaptics? haptics,
  FakeSound? sound,
}) {
  final c = clock ?? FakeClock(clockTestNow());
  return [
    clockNowProvider.overrideWithValue(c.call),
    nowProvider.overrideWith(() => FakeNow(c.now)),
    reminderSchedulerProvider.overrideWithValue(scheduler ?? FakeScheduler()),
    locationServiceProvider.overrideWithValue(
      location ?? FakeLocationService(state: LocationAccess.denied),
    ),
    if (haptics != null || sound != null) ...[
      hapticsDriverProvider.overrideWithValue(haptics ?? FakeHaptics()),
      soundDriverProvider.overrideWithValue(sound ?? FakeSound()),
    ] else
      feedbackServiceProvider.overrideWithValue(feedback ?? FakeFeedback()),
  ];
}

/// A container for provider tests (fresh in-memory storage, holding [saved]).
///
/// [resetStorage] false reuses whatever is already in [AppStorage] instead of
/// replacing it with a fresh empty store — for a container that simulates
/// reopening the app on the same (fake) phone, as a relaunch really would.
ProviderContainer clockContainer({
  FakeClock? clock,
  FakeScheduler? scheduler,
  FakeLocationService? location,
  FakeFeedback? feedback,
  FakeHaptics? haptics,
  FakeSound? sound,
  Map<String, Object?> saved = const {},
  List<Override> extra = const [],
  bool resetStorage = true,
}) {
  if (resetStorage) AppStorage.useMemoryForTests();
  // Whatever an earlier run of the app would have left in the settings box.
  saved.forEach(AppStorage.settings.put);
  final c = ProviderContainer(
    overrides: [
      ...clockOverrides(
        clock: clock,
        scheduler: scheduler,
        location: location,
        feedback: feedback,
        haptics: haptics,
        sound: sound,
      ),
      ...extra,
    ],
  );
  addTearDown(c.dispose);
  return c;
}
