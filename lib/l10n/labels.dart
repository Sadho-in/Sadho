import 'package:flutter/widgets.dart';

import '../core/storage/app_storage.dart';
import '../core/theme/palettes.dart' show SadhoPalette;
import '../features/calendar/application/mark_style_provider.dart' show MarkStyle;
import '../features/calendar/data/calendar_mark.dart';
import '../features/clock/application/location_provider.dart'
    show LocationSource, LocationState;
import '../features/clock/data/clock_tool.dart';
import '../features/clock/data/sun_alarm.dart' show SunEventKind;
import '../features/clock/data/world_cities.dart' show CityTime;
import '../features/clock/services/location_service.dart' show LocationAccess;
import '../features/home/data/plan.dart' show PlanKind;
import '../features/home/data/tradition.dart' show Tradition;
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

// ---- Clock ------------------------------------------------------------------

extension ClockToolL10n on ClockTool {
  String localizedTitle(AppLocalizations l) => switch (this) {
        ClockTool.clock => l.navClock,
        ClockTool.sunAlarm => l.clockToolSunAlarmTitle,
        ClockTool.worldClock => l.clockToolWorldClockTitle,
        ClockTool.timer => l.clockToolTimerTitle,
        ClockTool.stopwatch => l.clockToolStopwatchTitle,
        ClockTool.notepad => l.clockToolNotepadTitle,
      };

  String localizedSubtitle(AppLocalizations l) => switch (this) {
        ClockTool.clock => l.clockToolClockSubtitle,
        ClockTool.sunAlarm => l.clockToolSunAlarmSubtitle,
        ClockTool.worldClock => l.clockToolWorldClockSubtitle,
        ClockTool.timer => l.clockToolTimerSubtitle,
        ClockTool.stopwatch => l.clockToolStopwatchSubtitle,
        ClockTool.notepad => l.clockToolNotepadSubtitle,
      };
}

extension SunEventKindL10n on SunEventKind {
  String localized(AppLocalizations l) => switch (this) {
        SunEventKind.sunrise => l.sunEventSunrise,
        SunEventKind.sunset => l.sunEventSunset,
      };
}

/// [offsetLabel], but in the chosen language: "1 hr before", "45 min before",
/// "At sunrise", "15 min after"...
String offsetLabelIn(AppLocalizations l, int minutes, SunEventKind kind) {
  if (minutes == 0) return l.offsetAtEvent(kind.localized(l).toLowerCase());
  final abs = minutes.abs();
  final h = abs ~/ 60, m = abs % 60;
  final amount = h == 0
      ? l.offsetMinutesOnly(m)
      : (m == 0 ? l.offsetHoursOnly(h) : l.offsetHoursMinutes(h, m));
  return minutes < 0 ? l.offsetBefore(amount) : l.offsetAfter(amount);
}

extension LocationSourceL10n on LocationSource {
  String localized(AppLocalizations l) => switch (this) {
        LocationSource.device => l.locationSourceDevice,
        LocationSource.saved => l.locationSourceSaved,
        LocationSource.fallback => l.locationSourceFallback,
      };
}

extension LocationStateL10n on LocationState {
  /// [LocationState.summary], but in the chosen language.
  String summaryIn(AppLocalizations l) => switch (point.source) {
        LocationSource.device => l.locSummaryDevice,
        LocationSource.saved => l.locSummarySaved,
        LocationSource.fallback => switch (access) {
            LocationAccess.deniedForever => l.locSummaryBlocked,
            LocationAccess.serviceOff => l.locSummaryServiceOff,
            LocationAccess.unsupported => l.locSummaryUnsupported,
            _ => l.locSummaryDefault,
          },
      };
}

/// The localized name of a [TimerPreset]/vrat-to-sunset id ('aarti',
/// 'chalisa', 'path', 'havan', 'vrat_sunset'), or [fallback] (the stored
/// English label) for anything else.
String presetLabelFor(AppLocalizations l, String presetId, String fallback) =>
    switch (presetId) {
      'aarti' => l.presetAarti,
      'chalisa' => l.presetChalisa,
      'path' => l.presetPath,
      'havan' => l.presetHavan,
      'vrat_sunset' => l.vratToSunset,
      'custom' => l.customTimerName,
      _ => fallback,
    };

/// A length as its non-zero parts: 1020 -> "17 min", 3630 -> "1 h 30 s",
/// 86400 -> "24 h".
String formatShortDuration(AppLocalizations l, int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  return [
    if (h > 0) l.durationHours(h),
    if (m > 0) l.durationMinutes(m),
    if (s > 0 || seconds == 0) l.durationSeconds(s),
  ].join(' ');
}

extension CityTimeL10n on CityTime {
  /// [CityTime.dayLabel], but in the chosen language.
  String dayLabelIn(AppLocalizations l) => switch (dayOffset) {
        0 => l.today,
        1 => l.tomorrow,
        -1 => l.yesterday,
        _ => dayOffset > 0 ? l.cityInDays(dayOffset) : l.cityDaysAgo(-dayOffset),
      };

  /// [CityTime.relativeLabel], but in the chosen language.
  String relativeLabelIn(AppLocalizations l) => relativeToViewerIn(l, aheadBy);
}

/// [relativeToViewer], but in the chosen language: "Same time as you",
/// "5 h 30 m ahead of you", "4 h behind you"...
String relativeToViewerIn(AppLocalizations l, Duration d) {
  if (d == Duration.zero) return l.citySameTime;
  final abs = d.abs();
  final h = abs.inHours, m = abs.inMinutes % 60;
  final amount = h == 0
      ? l.cityAmountMinutes(m)
      : (m == 0 ? l.cityAmountHours(h) : l.cityAmountHoursMinutes(h, m));
  return d.isNegative ? l.cityBehindYou(amount) : l.cityAheadOfYou(amount);
}

// ---- Home -------------------------------------------------------------------

extension TraditionL10n on Tradition {
  String localized(AppLocalizations l) => switch (this) {
        Tradition.hindu => l.traditionHindu,
        Tradition.sikh => l.traditionSikh,
        Tradition.place => l.traditionPlace,
      };
}

extension PlanKindL10n on PlanKind {
  String localized(AppLocalizations l) => switch (this) {
        PlanKind.paath => l.planKindPaath,
        PlanKind.mantra => l.planKindMantra,
      };
}

/// The localized label for a [TodayDetail] by its [key] ('sunrise', 'tithi',
/// 'hukamnama'...), or [fallback] (the stored English label) for anything
/// unrecognised.
String todayDetailLabel(AppLocalizations l, String key, String fallback) =>
    switch (key) {
      'sunrise' => l.sunEventSunrise,
      'sunset' => l.sunEventSunset,
      'tithi' => l.todayLabelTithi,
      'nakshatra' => l.todayLabelNakshatra,
      'rahu' => l.todayLabelRahu,
      'abhijit' => l.todayLabelAbhijit,
      'hukamnama' => l.todayLabelHukamnama,
      'nitnem' => l.todayLabelNitnem,
      'gurpurab' => l.todayLabelGurpurab,
      'festival' => l.todayLabelFestival,
      'window' => l.todayLabelWindow,
      _ => fallback,
    };

/// [greetingFor], but in the chosen language.
String greetingForIn(AppLocalizations l, int hour) {
  if (hour >= 5 && hour < 12) return l.greetingMorning;
  if (hour >= 12 && hour < 17) return l.greetingAfternoon;
  if (hour >= 17 && hour < 21) return l.greetingEvening;
  return l.greetingNight;
}

// ---- Profile ------------------------------------------------------------------

/// A colour palette's name and blurb, in the chosen language, by [SadhoPalette.id]
/// (falling back to the stored English text for anything unrecognised).
extension SadhoPaletteL10n on SadhoPalette {
  String localizedName(AppLocalizations l) => switch (id) {
        'marigold' => l.paletteMarigoldName,
        'sandalwood' => l.paletteSandalwoodName,
        'tulsi' => l.paletteTulsiName,
        'twilight' => l.paletteTwilightName,
        'lotus' => l.paletteLotusName,
        'highContrast' => l.paletteHighContrastName,
        _ => name,
      };

  String localizedBlurb(AppLocalizations l) => switch (id) {
        'marigold' => l.paletteMarigoldBlurb,
        'sandalwood' => l.paletteSandalwoodBlurb,
        'tulsi' => l.paletteTulsiBlurb,
        'twilight' => l.paletteTwilightBlurb,
        'lotus' => l.paletteLotusBlurb,
        'highContrast' => l.paletteHighContrastBlurb,
        _ => blurb,
      };
}
