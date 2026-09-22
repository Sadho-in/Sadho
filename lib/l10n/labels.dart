import 'package:flutter/widgets.dart';

import '../core/storage/app_storage.dart';
import '../features/calendar/application/mark_style_provider.dart' show MarkStyle;
import '../features/calendar/data/calendar_mark.dart';
import '../features/sadhana/application/sadhana_session_provider.dart' show CountMode;
import '../features/sadhana/application/rhythm_pace.dart' show PaceUnit;
import '../features/sadhana/data/ringtone.dart';
import 'app_localizations.dart';

/// The words for the app's fixed choices (enums and a few small closed sets of
/// engine-origin messages), in the chosen language. The data/logic classes
/// keep an English `label` / plain string for tests, logs and pure-Dart code
/// that has no access to [AppLocalizations]; a test checks each stays equal
/// to the English text here, so the two can never quietly drift apart.

extension CountModeL10n on CountMode {
  String localized(AppLocalizations l) => switch (this) {
        CountMode.tap => l.modeTap,
        CountMode.rhythm => l.modeRhythm,
        CountMode.voice => l.modeVoice,
        CountMode.mala => l.modeMala,
      };
}

extension PaceUnitL10n on PaceUnit {
  String localized(AppLocalizations l) => switch (this) {
        PaceUnit.seconds => l.unitSeconds,
        PaceUnit.minutes => l.unitMinutes,
        PaceUnit.hours => l.unitHours,
      };
}

extension RingtoneL10n on Ringtone {
  String localized(AppLocalizations l) => switch (this) {
        Ringtone.templeBell => l.ringtoneTempleBell,
        Ringtone.singingBowl => l.ringtoneSingingBowl,
        Ringtone.softChime => l.ringtoneSoftChime,
        Ringtone.deepGong => l.ringtoneDeepGong,
      };
}

/// Messages that originate in pure-Dart engine code with no access to
/// [AppLocalizations] (the voice trainer, the microphone stream, the voice
/// counter's restart logic): each `_say()`/`onError()`/`onStopped()` there
/// still produces its fixed English text (so existing engine-level tests keep
/// matching it exactly); widgets translate it for display by looking it up
/// here. An unrecognised message (there should never be one) is shown as-is
/// rather than crashing.
String sadhanaEngineMessage(AppLocalizations l, String english) => switch (english) {
      'That was too short. Say the whole mantra.' => l.voiceTooShort,
      'That ran too long. Say the mantra once, then stop.' => l.voiceRanTooLong,
      'That sounded different from the others. Say it the same way again.' =>
        l.voiceSoundedDifferent,
      'Got it. Say it again.' => l.voiceGotIt,
      'Microphone permission was denied, so Voice counting cannot listen.' =>
        l.voiceDeniedShort,
      'Microphone access is blocked. Allow it in Settings to use Voice counting.' =>
        l.voiceBlockedShort,
      'Voice counting works on Android and iOS only' => l.msgVoiceUnsupported,
      'No microphone available on this device' => l.msgVoiceNoMic,
      'Microphone access was lost, so voice counting stopped.' => l.voiceAccessLost,
      'The microphone could not restart, so voice counting stopped.' =>
        l.voiceCouldNotRestart,
      _ => english,
    };

// ---- Calendar --------------------------------------------------------------

extension MarkTypeL10n on MarkType {
  String localized(AppLocalizations l) => switch (this) {
        MarkType.good => l.markTypeGood,
        MarkType.cautious => l.markTypeCautious,
        MarkType.neutral => l.markTypeNeutral,
      };
}

extension ReminderModeL10n on ReminderMode {
  String localized(AppLocalizations l) => switch (this) {
        ReminderMode.none => l.reminderModeNone,
        ReminderMode.once => l.reminderModeOnce,
        ReminderMode.several => l.reminderModeSeveral,
      };
}

extension RepeatRuleL10n on RepeatRule {
  String localized(AppLocalizations l) => switch (this) {
        RepeatRule.once => l.repeatRuleOnce,
        RepeatRule.daily => l.repeatRuleDaily,
        RepeatRule.weekly => l.repeatRuleWeekly,
        RepeatRule.monthly => l.repeatRuleMonthly,
        RepeatRule.quarterly => l.repeatRuleQuarterly,
        RepeatRule.halfYearly => l.repeatRuleHalfYearly,
        RepeatRule.yearly => l.repeatRuleYearly,
      };
}

extension HomeModeL10n on HomeMode {
  String localized(AppLocalizations l) => switch (this) {
        HomeMode.none => l.homeModeNone,
        HomeMode.morning => l.homeModeMorning,
        HomeMode.allDay => l.homeModeAllDay,
      };
}

extension MarkStyleL10n on MarkStyle {
  String localized(AppLocalizations l) => switch (this) {
        MarkStyle.dot => l.markStyleDot,
        MarkStyle.filled => l.markStyleFilled,
        MarkStyle.highlight => l.markStyleHighlight,
        MarkStyle.circle => l.markStyleCircle,
        MarkStyle.square => l.markStyleSquare,
      };
}

/// The spoken name of one of [markEmojis] (tooltip, screen reader).
String emojiName(AppLocalizations l, String emoji) => switch (emoji) {
      '🕉' => l.emojiOm,
      '☬' => l.emojiKhanda,
      '📿' => l.emojiMala,
      '🪔' => l.emojiDiya,
      '🔔' => l.emojiBell,
      '🌅' => l.emojiSunrise,
      '⭐' => l.emojiStar,
      '✦' => l.emojiSparkle,
      '💰' => l.emojiMoney,
      '🤝' => l.emojiHandshake,
      '🚫' => l.emojiAvoid,
      '✅' => l.emojiDone,
      _ => emoji,
    };

extension CalendarMarkL10n on CalendarMark {
  /// [title], but in the chosen language: the label if there is one,
  /// otherwise "Good day" / "Cautious day" / "Neutral day" for [type].
  String titleIn(AppLocalizations l) {
    final trimmed = label.trim();
    if (trimmed.isNotEmpty) return trimmed;
    return switch (type) {
      MarkType.good => l.markTitleGood,
      MarkType.cautious => l.markTitleCautious,
      MarkType.neutral => l.markTitleNeutral,
    };
  }
}

/// The app's texts read directly from Hive, for calendar/notification code
/// with neither a `ref` nor a BuildContext (a reminder planned for the OS
/// scheduler, ahead of any widget tree). Falls back to English the same way
/// `LanguageNotifier` falls back to English: nothing saved yet, or a saved
/// code with no matching language.
AppLocalizations currentL10n() {
  final code = AppStorage.settings.get('language') as String? ?? 'en';
  final locale = AppLocalizations.supportedLocales
      .firstWhere((l) => l.languageCode == code, orElse: () => const Locale('en'));
  return lookupAppLocalizations(locale);
}
