import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volume_button_listener/volume_button_listener.dart';

/// Hardware volume-button counting for Mala mode.
///
/// This is the in-app listener: it counts only while the app is on screen.
/// On Android, Mala normally counts through the background service instead
/// (mala_background_service.dart), which works with the screen off; this is
/// its fallback, and the counter where there is no such service.
///
/// TODO(later-phase): true Bluetooth smart-mala (BLE) support.
abstract class VolumeButtonService {
  /// False where volume keys cannot be captured (web, desktop, iOS).
  bool get isSupported;

  /// Starts capturing volume Up/Down presses, calling [onPress] for each.
  /// Returns false if capture could not be started.
  Future<bool> start(VoidCallback onPress);

  /// Stops capturing and gives the volume keys back to the system.
  Future<void> stop();
}

/// Android only: the plugin consumes the key event in the activity window, so
/// the system volume does not change and its volume panel does not appear.
///
/// iOS is excluded on purpose: it can only observe volume *changes* (the
/// panel cannot be hidden and presses at min/max volume are invisible), which
/// is not reliable enough for eyes-closed counting.
class DeviceVolumeButtonService implements VolumeButtonService {
  VoidCallback? _onPress;

  @override
  bool get isSupported =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      VolumeButtonListener.supportsVolumeButtonListener;

  @override
  Future<bool> start(VoidCallback onPress) async {
    if (!isSupported) return false;
    try {
      await stop();
      final listener = VolumeButtonListener.instance;
      listener.showVolumeUI = false; // suppress the system volume panel
      listener.suppressRepeatedPressEvents = true; // holding a key = one count
      _onPress = onPress;
      await listener.addButtonPressedListener(_handle);
      return true;
    } catch (e) {
      debugPrint('Volume-button capture failed: $e');
      _onPress = null;
      return false;
    }
  }

  void _handle(VolumeButtonDirection direction) => _onPress?.call();

  @override
  Future<void> stop() async {
    if (!isSupported) return;
    _onPress = null;
    try {
      final listener = VolumeButtonListener.instance;
      await listener.removeButtonPressedListener(_handle);
      listener.showVolumeUI = true; // normal volume behaviour again
    } catch (e) {
      debugPrint('Volume-button release failed: $e');
    }
  }
}

final volumeButtonServiceProvider = Provider<VolumeButtonService>((ref) {
  final service = DeviceVolumeButtonService();
  ref.onDispose(service.stop);
  return service;
});
