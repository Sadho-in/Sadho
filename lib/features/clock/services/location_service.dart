import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Where location stands on this phone.
enum LocationAccess {
  /// Not asked yet / not known.
  unknown,
  granted,
  denied,

  /// Refused for good: only system Settings can change it.
  deniedForever,

  /// The phone's location switch is off.
  serviceOff,

  /// Web / desktop.
  unsupported,
}

/// The phone's location (approximate is enough for sunrise/sunset). A seam so
/// tests never touch the real plugin.
abstract class LocationService {
  bool get isSupported;

  /// Current permission state, without asking.
  Future<LocationAccess> access();

  /// Asks the user (only shows a prompt if it can still be asked).
  Future<LocationAccess> requestAccess();

  /// A recent position, or null if none could be had.
  Future<({double lat, double lon})?> position();

  /// Opens the system Settings for this app (for "denied forever").
  Future<void> openSettings();
}

class GeolocatorLocationService implements LocationService {
  @override
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  LocationAccess _map(LocationPermission p) => switch (p) {
        LocationPermission.always ||
        LocationPermission.whileInUse =>
          LocationAccess.granted,
        LocationPermission.denied => LocationAccess.denied,
        LocationPermission.deniedForever => LocationAccess.deniedForever,
        LocationPermission.unableToDetermine => LocationAccess.unknown,
      };

  @override
  Future<LocationAccess> access() async {
    if (!isSupported) return LocationAccess.unsupported;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return LocationAccess.serviceOff;
      }
      return _map(await Geolocator.checkPermission());
    } catch (e) {
      debugPrint('Location check failed: $e');
      return LocationAccess.unknown;
    }
  }

  @override
  Future<LocationAccess> requestAccess() async {
    if (!isSupported) return LocationAccess.unsupported;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return LocationAccess.serviceOff;
      }
      return _map(await Geolocator.requestPermission());
    } catch (e) {
      debugPrint('Location request failed: $e');
      return LocationAccess.unknown;
    }
  }

  @override
  Future<({double lat, double lon})?> position() async {
    try {
      // A cached fix is instant and plenty accurate for the sun.
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return (lat: last.latitude, lon: last.longitude);
      final now = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return (lat: now.latitude, lon: now.longitude);
    } catch (e) {
      debugPrint('Could not get a position: $e');
      return null;
    }
  }

  @override
  Future<void> openSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint('Could not open settings: $e');
    }
  }
}

final locationServiceProvider =
    Provider<LocationService>((ref) => GeolocatorLocationService());
