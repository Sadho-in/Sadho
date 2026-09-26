import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Android's Do Not Disturb modes (NotificationManager.INTERRUPTION_FILTER_*).
abstract final class DndFilter {
  static const all = 1; // DND off
  static const priority = 2;
  static const none = 3;

  /// Alarms only: Sadho's own completion alarm still rings.
  static const alarms = 4;
}

/// The phone's Do Not Disturb. A seam, so tests run without a phone.
abstract class DndDriver {
  /// False where there is no such thing (iOS, web, desktop, tests).
  bool get isSupported;

  /// Whether the user has given Sadho Notification Policy access (needed to
  /// change Do Not Disturb at all).
  Future<bool> hasAccess();

  /// The current mode ([DndFilter]), or null if unknown.
  Future<int?> currentFilter();

  /// Sets the mode. False if it could not (no access).
  Future<bool> setFilter(int filter);

  /// Opens the phone's "Do Not Disturb access" settings page (or, failing
  /// that, the app's settings). False if nothing opened.
  Future<bool> openAccessSettings();
}

class NoopDndDriver implements DndDriver {
  const NoopDndDriver();

  @override
  bool get isSupported => false;

  @override
  Future<bool> hasAccess() async => false;

  @override
  Future<int?> currentFilter() async => null;

  @override
  Future<bool> setFilter(int filter) async => false;

  @override
  Future<bool> openAccessSettings() async => false;
}

/// Through MainActivity ("sadho/alarm": dndStatus, dndSetFilter,
/// openDndSettings).
class AndroidDndDriver implements DndDriver {
  const AndroidDndDriver();

  static const _channel = MethodChannel('sadho/alarm');

  static bool get platformSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  bool get isSupported => true;

  Future<Map<String, Object?>?> _status() async {
    try {
      return await _channel.invokeMapMethod<String, Object?>('dndStatus');
    } catch (e) {
      debugPrint('Do Not Disturb status unavailable: $e');
      return null;
    }
  }

  @override
  Future<bool> hasAccess() async => (await _status())?['access'] == true;

  @override
  Future<int?> currentFilter() async {
    final f = (await _status())?['filter'];
    return f is int && f > 0 ? f : null;
  }

  @override
  Future<bool> setFilter(int filter) async {
    try {
      return await _channel.invokeMethod<bool>('dndSetFilter', filter) ?? false;
    } catch (e) {
      debugPrint('Could not change Do Not Disturb: $e');
      return false;
    }
  }

  @override
  Future<bool> openAccessSettings() async {
    try {
      return await _channel.invokeMethod<bool>('openDndSettings') ?? false;
    } catch (e) {
      debugPrint('Could not open the Do Not Disturb settings: $e');
      return false;
    }
  }
}

/// `main()` overrides this with [AndroidDndDriver] on Android.
final dndDriverProvider = Provider<DndDriver>((ref) => const NoopDndDriver());
