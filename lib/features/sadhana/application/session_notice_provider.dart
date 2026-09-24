import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A short message the session wants the user to see (e.g. "Microphone
/// permission denied, switched to Tap"). Shown once as a snackbar by the app
/// shell, so it appears over Focus mode too.
class SessionNotice {
  const SessionNotice(this.message,
      {this.openSettings = false,
      this.trainMantraId,
      this.actionLabel,
      this.onAction});

  final String message;

  /// Offer an "Open settings" action (for permanently denied permissions).
  final bool openSettings;

  /// Offer a "Train" action that opens Voice training for this mantra.
  final String? trainMantraId;

  /// Any other action (e.g. "Allow" for an alarm permission).
  final String? actionLabel;
  final void Function()? onAction;
}

class SessionNoticeNotifier extends Notifier<SessionNotice?> {
  @override
  SessionNotice? build() => null;

  void show(String message,
          {bool openSettings = false,
          String? trainMantraId,
          String? actionLabel,
          void Function()? onAction}) =>
      state = SessionNotice(message,
          openSettings: openSettings,
          trainMantraId: trainMantraId,
          actionLabel: actionLabel,
          onAction: onAction);
}

final sessionNoticeProvider =
    NotifierProvider<SessionNoticeNotifier, SessionNotice?>(
  SessionNoticeNotifier.new,
);
