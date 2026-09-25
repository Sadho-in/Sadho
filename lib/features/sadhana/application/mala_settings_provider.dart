import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';

/// "Count with the screen off" (Mala, Android): Mala counts through the
/// background service, so the volume keys count with the phone locked. On by
/// default; off means the in-app listener only (the screen must stay on).
class MalaScreenOffNotifier extends Notifier<bool> {
  static const key = 'mala.screenOff';

  @override
  bool build() => AppStorage.settings.get(key, defaultValue: true) != false;

  void set(bool on) {
    state = on;
    AppStorage.settings.put(key, on);
  }
}

final malaScreenOffProvider =
    NotifierProvider<MalaScreenOffNotifier, bool>(MalaScreenOffNotifier.new);
