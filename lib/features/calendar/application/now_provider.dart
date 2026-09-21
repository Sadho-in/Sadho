import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current time, refreshed while the app is open so things that depend on
/// the clock (a morning card appearing at its time, "today" rolling over at
/// midnight) update by themselves. Tests override it with a fixed time.
class NowNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final timer = Timer.periodic(const Duration(seconds: 20), (_) {
      final n = DateTime.now();
      // Only publish a change when the minute turns over.
      if (n.minute != state.minute ||
          n.hour != state.hour ||
          n.day != state.day) {
        state = n;
      }
    });
    ref.onDispose(timer.cancel);
    return DateTime.now();
  }
}

final nowProvider = NotifierProvider<NowNotifier, DateTime>(NowNotifier.new);
