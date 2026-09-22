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
