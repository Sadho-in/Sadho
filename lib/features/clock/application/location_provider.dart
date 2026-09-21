import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../services/location_service.dart';

/// Where a [GeoPoint] came from.
enum LocationSource {
  /// From the phone, this session.
  device('Your location'),

  /// The last position the phone gave, kept in Hive.
  saved('Your last known location'),

  /// Nothing known: the default city.
  fallback('Amritsar (default)');

  const LocationSource(this.label);
  final String label;
}

/// A place on Earth used for sunrise and sunset.
class GeoPoint {
  const GeoPoint(this.lat, this.lon, this.source);

  final double lat;
  final double lon;
  final LocationSource source;

  String get label => source.label;
}

/// Used until (and unless) the phone gives a position: Amritsar, the app's
/// home city, so sunrise and sunset are always sensible.
const fallbackPoint = GeoPoint(31.6340, 74.8723, LocationSource.fallback);

class LocationState {
  const LocationState({
    required this.point,
    this.access = LocationAccess.unknown,
    this.busy = false,
    this.failed = false,
  });

  final GeoPoint point;
  final LocationAccess access;

  /// A lookup is in progress.
  final bool busy;

  /// Permission was fine but no position could be read.
  final bool failed;

  LocationState copyWith({
    GeoPoint? point,
    LocationAccess? access,
    bool? busy,
    bool? failed,
  }) =>
      LocationState(
        point: point ?? this.point,
        access: access ?? this.access,
        busy: busy ?? this.busy,
        failed: failed ?? this.failed,
      );

  /// One line for the UI: which place is being used and why.
  String get summary => switch (point.source) {
        LocationSource.device => 'Using your location',
        LocationSource.saved => 'Using your last known location',
        LocationSource.fallback => switch (access) {
            LocationAccess.deniedForever =>
              'Using Amritsar. Location is blocked in Settings.',
            LocationAccess.serviceOff =>
              'Using Amritsar. Turn on location for exact times.',
            LocationAccess.unsupported => 'Using Amritsar.',
            _ => 'Using Amritsar. Allow location for exact times.',
          },
      };
}

/// The place used for sun times. Starts from the last saved position (or the
/// default) at once, then quietly refreshes from the phone if it already has
/// permission. It never shows a permission prompt by itself; [refresh] with
/// `ask: true` does, when the user chooses "Use my location".
class LocationNotifier extends Notifier<LocationState> {
  static const _key = 'clock.location';

  @override
  LocationState build() {
    final initial = LocationState(point: _saved() ?? fallbackPoint);
    Future.microtask(() => refresh());
    return initial;
  }

  GeoPoint? _saved() {
    final v = AppStorage.settings.get(_key);
    if (v is! Map) return null;
    final lat = v['lat'], lon = v['lon'];
    if (lat is! num || lon is! num) return null;
    if (!lat.isFinite || !lon.isFinite) return null;
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) return null;
    return GeoPoint(lat.toDouble(), lon.toDouble(), LocationSource.saved);
  }

  /// Reads the phone's position. With [ask] it may show the permission prompt.
  Future<void> refresh({bool ask = false}) async {
    final service = ref.read(locationServiceProvider);
    if (!service.isSupported) {
      state = state.copyWith(access: LocationAccess.unsupported);
      return;
    }
    state = state.copyWith(busy: true, failed: false);
    var access = await service.access();
    if (!ref.mounted) return;
    if (ask && access == LocationAccess.denied) {
      access = await service.requestAccess();
      if (!ref.mounted) return;
    }
    if (access != LocationAccess.granted) {
      state = state.copyWith(access: access, busy: false);
      return;
    }
    final pos = await service.position();
    if (!ref.mounted) return;
    if (pos == null) {
      state = state.copyWith(access: access, busy: false, failed: true);
      return;
    }
    AppStorage.settings.put(_key, {'lat': pos.lat, 'lon': pos.lon});
    state = LocationState(
      point: GeoPoint(pos.lat, pos.lon, LocationSource.device),
      access: access,
    );
  }

  Future<void> openSettings() => ref.read(locationServiceProvider).openSettings();
}

final locationProvider =
    NotifierProvider<LocationNotifier, LocationState>(LocationNotifier.new);
