import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';

/// How a marked date is drawn on the month grid. One choice for every mark.
enum MarkStyle {
  dot('Dot'),
  filled('Filled'),
  highlight('Highlight'),
  circle('Circle'),
  square('Square');

  const MarkStyle(this.label);
  final String label;
}

/// The chosen [MarkStyle], saved in Hive and restored on relaunch.
class MarkStyleNotifier extends Notifier<MarkStyle> {
  static const _key = 'calendar.markStyle';

  @override
  MarkStyle build() {
    final saved = AppStorage.settings.get(_key);
    return MarkStyle.values.firstWhere(
      (s) => s.name == saved,
      orElse: () => MarkStyle.dot,
    );
  }

  void set(MarkStyle style) {
    state = style;
    AppStorage.settings.put(_key, style.name);
  }
}

final markStyleProvider =
    NotifierProvider<MarkStyleNotifier, MarkStyle>(MarkStyleNotifier.new);
