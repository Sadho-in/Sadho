import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/clock/application/location_provider.dart';
import 'package:advance_calendar/features/clock/services/location_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'clock_support.dart';

void main() {
  test('with nothing known the place is Amritsar', () async {
    final c = clockContainer(
      location: FakeLocationService(state: LocationAccess.denied),
    );
    final l = c.read(locationProvider);
    expect(l.point.source, LocationSource.fallback);
    expect((l.point.lat, l.point.lon), (fallbackPoint.lat, fallbackPoint.lon));
    expect(l.point.label, 'Amritsar (default)');
    await pumpEventQueue();
    expect(c.read(locationProvider).point.source, LocationSource.fallback);
    expect(c.read(locationProvider).access, LocationAccess.denied);
  });

  test('it never shows the permission prompt on its own', () async {
    final svc = FakeLocationService(state: LocationAccess.denied);
    final c = clockContainer(location: svc);
    c.read(locationProvider);
    await pumpEventQueue();
    expect(svc.asks, 0);
    expect(c.read(locationProvider).summary, contains('Allow location'));
  });

  test(
    'if the phone already allows it, the position is used and saved',
    () async {
      final svc = FakeLocationService(lat: 51.5, lon: -0.12);
      final c = clockContainer(location: svc);
      c.read(locationProvider);
      await pumpEventQueue();
      final l = c.read(locationProvider);
      expect(l.point.source, LocationSource.device);
      expect((l.point.lat, l.point.lon), (51.5, -0.12));
      expect(l.summary, 'Using your location');
      expect(AppStorage.settings.get('clock.location'), {
        'lat': 51.5,
        'lon': -0.12,
      });
    },
  );

  test('a saved position is used at once, before the phone answers', () async {
    final c = clockContainer(
      location: FakeLocationService(state: LocationAccess.denied),
      saved: {
        'clock.location': {'lat': 40.7, 'lon': -74.0},
      },
    );
    final l = c.read(locationProvider);
    expect(l.point.source, LocationSource.saved);
    expect((l.point.lat, l.point.lon), (40.7, -74.0));
    expect(l.summary, 'Using your last known location');
    await pumpEventQueue(); // the phone says no: the saved place stays
    expect(c.read(locationProvider).point.source, LocationSource.saved);
  });

  test('"Use my location" asks, then reads the position', () async {
    final svc = FakeLocationService(
      state: LocationAccess.denied,
      lat: 12.9,
      lon: 77.6,
    );
    final c = clockContainer(location: svc);
    await c.read(locationProvider.notifier).refresh(ask: true);
    expect(svc.asks, 1);
    expect(c.read(locationProvider).point.source, LocationSource.device);
    expect(c.read(locationProvider).point.lat, 12.9);
  });

  test('refusing the prompt keeps Amritsar and says how to fix it', () async {
    final svc = FakeLocationService(state: LocationAccess.denied)
      ..afterAsk = LocationAccess.deniedForever;
    final c = clockContainer(location: svc);
    await c.read(locationProvider.notifier).refresh(ask: true);
    final l = c.read(locationProvider);
    expect(l.point.source, LocationSource.fallback);
    expect(l.access, LocationAccess.deniedForever);
    expect(l.summary, contains('blocked in Settings'));
    // Blocked for good: asking again does not prompt.
    await c.read(locationProvider.notifier).refresh(ask: true);
    expect(svc.asks, 1);
  });

  test('location switched off is explained', () async {
    final c = clockContainer(
      location: FakeLocationService(state: LocationAccess.serviceOff),
    );
    await c.read(locationProvider.notifier).refresh(ask: true);
    expect(c.read(locationProvider).summary, contains('Turn on location'));
  });

  test(
    'a permitted phone that gives no position keeps the fallback and flags it',
    () async {
      final c = clockContainer(location: FakeLocationService(hasFix: false));
      await c.read(locationProvider.notifier).refresh();
      final l = c.read(locationProvider);
      expect(l.failed, isTrue);
      expect(l.point.source, LocationSource.fallback);
      expect(l.busy, isFalse);
    },
  );

  test('an unsupported platform (web, desktop) just uses Amritsar', () async {
    final svc = FakeLocationService(supported: false);
    final c = clockContainer(location: svc);
    await c.read(locationProvider.notifier).refresh(ask: true);
    expect(c.read(locationProvider).point.source, LocationSource.fallback);
    expect(svc.asks, 0);
  });

  test('a corrupt saved position is ignored', () {
    for (final bad in [
      {'lat': 999, 'lon': 10},
      {'lat': 'x', 'lon': 10},
      {'lat': 10},
      'junk',
    ]) {
      final c = clockContainer(
        location: FakeLocationService(state: LocationAccess.denied),
        saved: {'clock.location': bad},
      );
      expect(
        c.read(locationProvider).point.source,
        LocationSource.fallback,
        reason: '$bad',
      );
    }
  });
}
