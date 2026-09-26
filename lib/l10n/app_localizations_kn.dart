// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get navHome => 'ಮುಖಪುಟ';

  @override
  String get navSadhana => 'ಸಾಧನೆ';

  @override
  String get navCalendar => 'ಕ್ಯಾಲೆಂಡರ್';

  @override
  String get navClock => 'ಗಡಿಯಾರ';

  @override
  String get tooltipLanguage => 'ಭಾಷೆ';

  @override
  String get tooltipProfile => 'ಪ್ರೊಫೈಲ್';

  @override
  String get tooltipSwitchToLight => 'ಲೈಟ್ ಥೀಮ್‌ಗೆ ಬದಲಿಸಿ';

  @override
  String get tooltipSwitchToDark => 'ಡಾರ್ಕ್ ಥೀಮ್‌ಗೆ ಬದಲಿಸಿ';

  @override
  String get languageSheetTitle => 'ಭಾಷೆ';

  @override
  String get languageSheetSubtitle =>
      'ನಿಮ್ಮ ಆಯ್ಕೆ ಉಳಿಸಲ್ಪಟ್ಟು ತಕ್ಷಣ ಅನ್ವಯವಾಗುತ್ತದೆ.';

  @override
  String get actionCancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get actionDelete => 'ಅಳಿಸಿ';

  @override
  String get actionSave => 'ಉಳಿಸಿ';

  @override
  String get actionReset => 'ಮರುಹೊಂದಿಸಿ';

  @override
  String get actionEdit => 'ಸಂಪಾದಿಸಿ';

  @override
  String get actionOk => 'ಸರಿ';

  @override
  String get unitSeconds => 'ಸೆಕೆಂಡುಗಳು';

  @override
  String get unitMinutes => 'ನಿಮಿಷಗಳು';

  @override
  String get unitHours => 'ಗಂಟೆಗಳು';

  @override
  String get paceErrorEmpty => 'ವೇಗವನ್ನು ನಮೂದಿಸಿ.';

  @override
  String get paceErrorNotNumber => 'ಇದು ಸಂಖ್ಯೆಯಲ್ಲ.';

  @override
  String paceErrorTooFast(String min) {
    return 'ತುಂಬಾ ವೇಗ. ಕನಿಷ್ಠ $min.';
  }

  @override
  String paceErrorTooSlow(String max) {
    return 'ತುಂಬಾ ನಿಧಾನ. ಗರಿಷ್ಠ $max.';
  }

  @override
  String get modeTap => 'ಟ್ಯಾಪ್';

  @override
  String get modeRhythm => 'ಲಯ';

  @override
  String get modeVoice => 'ಧ್ವನಿ';

  @override
  String get modeMala => 'ಮಾಲೆ';

  @override
  String get ringtoneTempleBell => 'ದೇವಸ್ಥಾನದ ಗಂಟೆ';

  @override
  String get ringtoneSingingBowl => 'ಗಾಯನ ಬೌಲ್';

  @override
  String get ringtoneSoftChime => 'ಮೃದು ಚೈಮ್';

  @override
  String get ringtoneDeepGong => 'ಆಳವಾದ ಗಾಂಗ್';

  @override
  String get msgVoiceUnsupported =>
      'ಧ್ವನಿ ಎಣಿಕೆ Android ಮತ್ತು iOS ನಲ್ಲಿ ಮಾತ್ರ ಕಾರ್ಯನಿರ್ವಹಿಸುತ್ತದೆ';

  @override
  String get msgVoiceNoMic => 'ಈ ಸಾಧನದಲ್ಲಿ ಮೈಕ್ರೊಫೋನ್ ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get msgMalaUnsupported => 'ವಾಲ್ಯೂಮ್-ಕೀ ಎಣಿಕೆಗೆ ನೈಜ ಸಾಧನ ಬೇಕು';

  @override
  String trainFirstPrompt(int min, int max) {
    return 'ಮೊದಲು ಈ ಮಂತ್ರಕ್ಕಾಗಿ ನಿಮ್ಮ ಧ್ವನಿಯನ್ನು ತರಬೇತಿಗೊಳಿಸಿ: ಇದನ್ನು $min ರಿಂದ $max ಬಾರಿ ರೆಕಾರ್ಡ್ ಮಾಡಿ.';
  }

  @override
  String get fallbackVoiceDenied =>
      'ಮೈಕ್ರೊಫೋನ್ ಅನುಮತಿ ನಿರಾಕರಿಸಲಾಗಿದೆ, ಆದ್ದರಿಂದ ಧ್ವನಿ ಎಣಿಕೆ ಕೇಳಲಾಗುವುದಿಲ್ಲ. ಟ್ಯಾಪ್ ಮೋಡ್ ಬಳಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get fallbackVoiceBlocked =>
      'ಮೈಕ್ರೊಫೋನ್ ಪ್ರವೇಶ ನಿರ್ಬಂಧಿಸಲಾಗಿದೆ. ಧ್ವನಿ ಎಣಿಕೆ ಬಳಸಲು ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಅನುಮತಿಸಿ. ಟ್ಯಾಪ್ ಮೋಡ್ ಬಳಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get fallbackVoiceUnsupported =>
      'ಧ್ವನಿ ಎಣಿಕೆ Android ಮತ್ತು iOS ನಲ್ಲಿ ಮಾತ್ರ ಕಾರ್ಯನಿರ್ವಹಿಸುತ್ತದೆ. ಟ್ಯಾಪ್ ಮೋಡ್ ಬಳಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get fallbackVoiceNoMic =>
      'ಈ ಸಾಧನದಲ್ಲಿ ಮೈಕ್ರೊಫೋನ್ ಲಭ್ಯವಿಲ್ಲ. ಟ್ಯಾಪ್ ಮೋಡ್ ಬಳಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get fallbackMalaUnsupported =>
      'ವಾಲ್ಯೂಮ್-ಕೀ ಎಣಿಕೆಗೆ ನೈಜ ಸಾಧನ ಬೇಕು. ಟ್ಯಾಪ್ ಮೋಡ್ ಬಳಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get sadhanaRingTitle => '🔔 ಸಾಧನೆಯ ಸಮಯ ಮುಗಿಯಿತು';

  @override
  String get sadhanaRingBody => 'ನಿಮ್ಮ ಅಧಿವೇಶನದ ಸಮಯ ಮುಗಿದಿದೆ 🙏';

  @override
  String get voiceTooShort => 'ಇದು ತುಂಬಾ ಚಿಕ್ಕದಾಗಿತ್ತು. ಪೂರ್ಣ ಮಂತ್ರವನ್ನು ಹೇಳಿ.';

  @override
  String get voiceRanTooLong =>
      'ಇದು ಬಹಳ ಸಮಯ ನಡೆಯಿತು. ಮಂತ್ರವನ್ನು ಒಮ್ಮೆ ಹೇಳಿ, ನಂತರ ನಿಲ್ಲಿಸಿ.';

  @override
  String get voiceSoundedDifferent =>
      'ಇದು ಇತರರಿಗಿಂತ ವಿಭಿನ್ನವಾಗಿ ಕೇಳಿಸಿತು. ಅದೇ ರೀತಿ ಮತ್ತೆ ಹೇಳಿ.';

  @override
  String get voiceGotIt => 'ಅರ್ಥವಾಯಿತು. ಮತ್ತೆ ಹೇಳಿ.';

  @override
  String get voiceDeniedShort =>
      'ಮೈಕ್ರೊಫೋನ್ ಅನುಮತಿ ನಿರಾಕರಿಸಲಾಗಿದೆ, ಆದ್ದರಿಂದ ಧ್ವನಿ ಎಣಿಕೆ ಕೇಳಲಾಗುವುದಿಲ್ಲ.';

  @override
  String get voiceBlockedShort =>
      'ಮೈಕ್ರೊಫೋನ್ ಪ್ರವೇಶ ನಿರ್ಬಂಧಿಸಲಾಗಿದೆ. ಧ್ವನಿ ಎಣಿಕೆ ಬಳಸಲು ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಅನುಮತಿಸಿ.';

  @override
  String get voiceAccessLost =>
      'ಮೈಕ್ರೊಫೋನ್ ಪ್ರವೇಶ ಕಳೆದುಹೋಯಿತು, ಆದ್ದರಿಂದ ಧ್ವನಿ ಎಣಿಕೆ ನಿಂತಿತು.';

  @override
  String get voiceCouldNotRestart =>
      'ಮೈಕ್ರೊಫೋನ್ ಮತ್ತೆ ಪ್ರಾರಂಭಿಸಲಾಗಲಿಲ್ಲ, ಆದ್ದರಿಂದ ಧ್ವನಿ ಎಣಿಕೆ ನಿಂತಿತು.';

  @override
  String get mantraLibraryTitle => 'ಮಂತ್ರ ಗ್ರಂಥಾಲಯ';

  @override
  String get addMantra => 'ಮಂತ್ರ ಸೇರಿಸಿ';

  @override
  String get searchHint => 'ಶೀರ್ಷಿಕೆ, ಲಿಪಿ ಅಥವಾ ಸಂಪ್ರದಾಯ ಹುಡುಕಿ';

  @override
  String noMantrasMatch(String query) {
    return '“$query” ಗೆ ಯಾವುದೇ ಮಂತ್ರ ಹೊಂದಿಕೆಯಾಗುತ್ತಿಲ್ಲ.\nನಿಮ್ಮದೇ ಆದದನ್ನು ರಚಿಸಲು “ಮಂತ್ರ ಸೇರಿಸಿ” ಟ್ಯಾಪ್ ಮಾಡಿ.';
  }

  @override
  String mantraAdded(String title) {
    return '“$title” ಸೇರಿಸಲಾಗಿದೆ';
  }

  @override
  String mantraSaved(String title) {
    return '“$title” ಉಳಿಸಲಾಗಿದೆ';
  }

  @override
  String mantraRestored(String title) {
    return '“$title” ಅನ್ನು ಅದರ ಡೀಫಾಲ್ಟ್‌ಗೆ ಮರುಸ್ಥಾಪಿಸಲಾಗಿದೆ';
  }

  @override
  String get deleteMantraTitle => 'ಮಂತ್ರವನ್ನು ಅಳಿಸುವುದೇ?';

  @override
  String deleteMantraBody(String title) {
    return '“$title” ಅನ್ನು ನಿಮ್ಮ ಗ್ರಂಥಾಲಯದಿಂದ ತೆಗೆದುಹಾಕಲಾಗುವುದು.';
  }

  @override
  String get retrainVoiceTooltip => 'ಧ್ವನಿಯನ್ನು ಮರು ತರಬೇತಿಗೊಳಿಸಿ';

  @override
  String get trainVoice => 'ಧ್ವನಿ ತರಬೇತಿಗೊಳಿಸಿ';

  @override
  String mantraCountTag(int count) {
    return '$count ಎಣಿಕೆ';
  }

  @override
  String get editedTag => 'ಸಂಪಾದಿಸಲಾಗಿದೆ';

  @override
  String get editMantra => 'ಮಂತ್ರ ಸಂಪಾದಿಸಿ';

  @override
  String get addAMantra => 'ಒಂದು ಮಂತ್ರ ಸೇರಿಸಿ';

  @override
  String get titleLabel => 'ಶೀರ್ಷಿಕೆ *';

  @override
  String get titleRequired => 'ಶೀರ್ಷಿಕೆ ನಮೂದಿಸಿ';

  @override
  String get scriptTextLabel => 'ಲಿಪಿ ಪಠ್ಯ';

  @override
  String get transliterationLabel => 'ಲಿಪ್ಯಂತರ';

  @override
  String get traditionLabel => 'ಸಂಪ್ರದಾಯ / ಭಾಷೆ';

  @override
  String get traditionHint => 'ಉದಾ. ಸಂಸ್ಕೃತ · ಹಿಂದೂ';

  @override
  String get defaultCountLabel => 'ಡೀಫಾಲ್ಟ್ ಎಣಿಕೆ *';

  @override
  String get enterNumberOneOrMore => '1 ಅಥವಾ ಹೆಚ್ಚಿನ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ';

  @override
  String get tooLarge => 'ಇದು ತುಂಬಾ ದೊಡ್ಡದಾಗಿದೆ';

  @override
  String get saveChanges => 'ಬದಲಾವಣೆಗಳನ್ನು ಉಳಿಸಿ';

  @override
  String get saveToLibrary => 'ಗ್ರಂಥಾಲಯದಲ್ಲಿ ಉಳಿಸಿ';

  @override
  String get resetToDefaultButton => 'ಡೀಫಾಲ್ಟ್‌ಗೆ ಮರುಹೊಂದಿಸಿ';

  @override
  String get resetToDefaultTitle => 'ಡೀಫಾಲ್ಟ್‌ಗೆ ಮರುಹೊಂದಿಸುವುದೇ?';

  @override
  String resetToDefaultBody(String title) {
    return '“$title” ಗೆ ನಿಮ್ಮ ಬದಲಾವಣೆಗಳನ್ನು ತಿರಸ್ಕರಿಸಿ ಮೂಲ ಪಠ್ಯವನ್ನು ಮರುಸ್ಥಾಪಿಸಲಾಗುವುದು.';
  }

  @override
  String switchToMantra(String title) {
    return '$title ಗೆ ಬದಲಾಯಿಸುವುದೇ?';
  }

  @override
  String get switchMantraBody => 'ನಿಮ್ಮ ಪ್ರಸ್ತುತ ಎಣಿಕೆ ಮರುಹೊಂದಿಸಲಾಗುವುದು.';

  @override
  String get keepCurrent => 'ಪ್ರಸ್ತುತವನ್ನು ಇರಿಸಿ';

  @override
  String get switchAction => 'ಬದಲಿಸಿ';

  @override
  String get smallerMantraText => 'ಚಿಕ್ಕ ಮಂತ್ರ ಪಠ್ಯ';

  @override
  String get largerMantraText => 'ದೊಡ್ಡ ಮಂತ್ರ ಪಠ್ಯ';

  @override
  String get libraryButton => 'ಗ್ರಂಥಾಲಯ';

  @override
  String get trainYourOwnMantra => 'ನಿಮ್ಮ ಸ್ವಂತ ಮಂತ್ರವನ್ನು ತರಬೇತಿಗೊಳಿಸಿ';

  @override
  String voiceCountingFrom(String title, int count) {
    return 'ನಿಮ್ಮ $count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳಿಂದ “$title” ಎಣಿಸಲಾಗುತ್ತಿದೆ. ಇತರ ಶಬ್ದಗಳು ಮತ್ತು ಪದಗಳನ್ನು ನಿರ್ಲಕ್ಷಿಸಲಾಗುತ್ತದೆ.';
  }

  @override
  String voiceCountsOnlyTrained(String title, int min, int max) {
    return 'ನೀವು ತರಬೇತಿಗೊಳಿಸಿದ ಮಂತ್ರವನ್ನು ಮಾತ್ರ ಧ್ವನಿ ಎಣಿಸುತ್ತದೆ. ಪ್ರಾರಂಭಿಸಲು “$title” ಅನ್ನು $min ರಿಂದ $max ಬಾರಿ ರೆಕಾರ್ಡ್ ಮಾಡಿ.';
  }

  @override
  String get addMoreSamples => 'ಇನ್ನಷ್ಟು ಮಾದರಿಗಳನ್ನು ಸೇರಿಸಿ';

  @override
  String get retrain => 'ಮತ್ತೆ ತರಬೇತಿಗೊಳಿಸಿ';

  @override
  String get clearTraining => 'ತರಬೇತಿ ಅಳಿಸಿ';

  @override
  String get voiceBetaNote =>
      'ಬೀಟಾ: ಇದು ಸಾಧನದಲ್ಲಿಯೇ, ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿ ಕಾರ್ಯನಿರ್ವಹಿಸುತ್ತದೆ. ಹೆಚ್ಚಿನ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ನಿಖರತೆಯನ್ನು ಹೆಚ್ಚಿಸುತ್ತವೆ, ಗದ್ದಲದ ಕೋಣೆಯಲ್ಲಿ ಕಡಿಮೆಯಾಗುತ್ತದೆ. ಪುನರಾವರ್ತನೆಗಳ ನಡುವೆ ಸ್ವಲ್ಪ ನಿಲ್ಲಿಸಿ. ಇಲ್ಲಿ ನಿಮ್ಮ ಧ್ವನಿ ಮಾತ್ರ ಎಣಿಸಲ್ಪಡುತ್ತದೆ; + ಮತ್ತು − ಬಟನ್‌ಗಳು ಎಣಿಕೆಯನ್ನು ಸರಿಪಡಿಸುತ್ತವೆ.';

  @override
  String get trainVoiceFirstTitle => 'ಮೊದಲು ನಿಮ್ಮ ಧ್ವನಿಯನ್ನು ತರಬೇತಿಗೊಳಿಸಿ';

  @override
  String trainVoiceFirstBody(String title, int min, int max) {
    return 'ನೀವು ತರಬೇತಿಗೊಳಿಸಿದ ಮಂತ್ರವನ್ನು ಮಾತ್ರ ಧ್ವನಿ ಎಣಿಸುತ್ತದೆ. “$title” ಅನ್ನು $min ರಿಂದ $max ಬಾರಿ (ಸುಮಾರು ಒಂದು ನಿಮಿಷ) ರೆಕಾರ್ಡ್ ಮಾಡಿ. ಇದು ಈ ಸಾಧನದಲ್ಲಿಯೇ ಉಳಿದು ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿ ಕಾರ್ಯನಿರ್ವಹಿಸುತ್ತದೆ.';
  }

  @override
  String get later => 'ನಂತರ';

  @override
  String get trainNow => 'ಈಗ ತರಬೇತಿಗೊಳಿಸಿ';

  @override
  String get betaLabel => 'ಬೀಟಾ';

  @override
  String get voiceTrained => 'ಧ್ವನಿ ತರಬೇತಿಗೊಂಡಿದೆ';

  @override
  String get voiceNotTrained => 'ಧ್ವನಿ ತರಬೇತಿಗೊಂಡಿಲ್ಲ';

  @override
  String get sensitivityLabel => 'ಸಂವೇದನಾಶೀಲತೆ';

  @override
  String get sensitivityStrict => 'ಕಠಿಣ';

  @override
  String get sensitivityLenient => 'ಸಡಿಲ';

  @override
  String get sensitivityMedium => 'ಮಧ್ಯಮ';

  @override
  String get clearVoiceTrainingTitle => 'ಧ್ವನಿ ತರಬೇತಿ ಅಳಿಸುವುದೇ?';

  @override
  String clearVoiceTrainingBody(String title) {
    return 'ನೀವು ಮತ್ತೆ ತರಬೇತಿಗೊಳಿಸುವವರೆಗೆ ಧ್ವನಿ “$title” ಅನ್ನು ಎಣಿಸುವುದನ್ನು ನಿಲ್ಲಿಸುತ್ತದೆ.';
  }

  @override
  String get completionTitle => 'ಪೂರ್ಣಗೊಳಿಕೆ';

  @override
  String get vibrationLabel => 'ಕಂಪನ';

  @override
  String vibrationSubtitle(int n) {
    return 'ಪ್ರತಿ $n ಎಣಿಕೆಗೆ ಒಂದು ಕಂಪನ, ಗುರಿಯಲ್ಲಿ ಬಲವಾದದ್ದು.';
  }

  @override
  String intensityLevel(int level) {
    return 'ತೀವ್ರತೆ: ಹಂತ $level ರಲ್ಲಿ 5';
  }

  @override
  String get testMilestone => 'ಟೆಸ್ಟ್ ಮೈಲಿಗಲ್ಲು';

  @override
  String get testTarget => 'ಟೆಸ್ಟ್ ಗುರಿ';

  @override
  String get ringtoneLabel => 'ರಿಂಗ್‌ಟೋನ್';

  @override
  String get ringtoneSubtitle => 'ಗುರಿ ತಲುಪಿದಾಗ ಒಂದು ಶಬ್ದ ಮೊಳಗುತ್ತದೆ.';

  @override
  String get playSound => 'ಶಬ್ದ ಪ್ಲೇ ಮಾಡಿ';

  @override
  String get combined => 'ಸಂಯೋಜಿತ';

  @override
  String get combinedTooltip =>
      'ಎಲ್ಲಾ ನಾಲ್ಕು ಮೋಡ್‌ಗಳು ಒಂದು ಹಂಚಿಕೆಯ ಎಣಿಕೆಗೆ ಸೇರುತ್ತವೆ';

  @override
  String get separate => 'ಪ್ರತ್ಯೇಕ';

  @override
  String get separateTooltip => 'ಪ್ರತಿ ಮೋಡ್ ತನ್ನದೇ ಆದ ಎಣಿಕೆ ಇಟ್ಟುಕೊಳ್ಳುತ್ತದೆ';

  @override
  String get countModeSemantic => 'ಎಣಿಕೆ ಮೋಡ್';

  @override
  String get combinedExplain =>
      'ಟ್ಯಾಪ್, ಧ್ವನಿ, ಲಯ ಮತ್ತು ಮಾಲೆ ಎಲ್ಲವೂ ಒಂದು ಗುರಿಯತ್ತ ಒಂದು ಹಂಚಿಕೆಯ ಎಣಿಕೆಗೆ ಸೇರುತ್ತವೆ.';

  @override
  String get separateExplain =>
      'ಪ್ರತಿ ಮೋಡ್ ತನ್ನದೇ ಆದ ಎಣಿಕೆ ಮತ್ತು ಗುರಿಯತ್ತ ಪ್ರಗತಿಯನ್ನು ಇಟ್ಟುಕೊಳ್ಳುತ್ತದೆ. ಮರುಹೊಂದಿಕೆ ಮತ್ತು ಪೂರ್ಣಗೊಳಿಕೆ ನೀವು ಇರುವ ಮೋಡ್‌ಗೆ ಮಾತ್ರ ಅನ್ವಯಿಸುತ್ತದೆ.';

  @override
  String countedLabel(int count) {
    return '$count ಎಣಿಸಲಾಗಿದೆ';
  }

  @override
  String ofTarget(int count) {
    return '$count ರಲ್ಲಿ';
  }

  @override
  String get removeOneTooltip => 'ಒಂದನ್ನು ತೆಗೆದುಹಾಕಿ';

  @override
  String get undoLabel => 'ರದ್ದುಗೊಳಿಸಿ';

  @override
  String get countLabel => 'ಎಣಿಕೆ';

  @override
  String get addOneTooltip => 'ಒಂದನ್ನು ಸೇರಿಸಿ';

  @override
  String get focusLabel => 'ಫೋಕಸ್';

  @override
  String get focusModeTooltip => 'ಫೋಕಸ್ ಮೋಡ್';

  @override
  String get pause => 'ವಿರಾಮ';

  @override
  String get resume => 'ಪುನರಾರಂಭಿಸಿ';

  @override
  String get start => 'ಪ್ರಾರಂಭಿಸಿ';

  @override
  String targetReachedSeparate(String mode) {
    return '$mode ನಲ್ಲಿ ಗುರಿ ತಲುಪಲಾಗಿದೆ 🙏  ಈ ಮೋಡ್ ಅನ್ನು ಮರುಹೊಂದಿಸಿ, ಮೋಡ್ ಬದಲಿಸಿ, ಅಥವಾ ಗುರಿಯನ್ನು ಹೆಚ್ಚಿಸಿ.';
  }

  @override
  String get targetReachedCombined =>
      'ಗುರಿ ತಲುಪಲಾಗಿದೆ 🙏  ಮರುಹೊಂದಿಸಿ, ಅಥವಾ ಗುರಿಯನ್ನು ಹೆಚ್ಚಿಸಿ.';

  @override
  String resetModeCountTitle(String mode) {
    return '$mode ಎಣಿಕೆಯನ್ನು ಮರುಹೊಂದಿಸುವುದೇ?';
  }

  @override
  String get resetSessionTitle => 'ಈ ಅಧಿವೇಶನವನ್ನು ಮರುಹೊಂದಿಸುವುದೇ?';

  @override
  String resetModeCountBody(String mode, int count) {
    return 'ನಿಮ್ಮ $mode ಎಣಿಕೆ $count ಶೂನ್ಯಕ್ಕೆ ಹಿಂತಿರುಗುತ್ತದೆ. ಇತರ ಮೋಡ್‌ಗಳು ತಮ್ಮ ಎಣಿಕೆಗಳನ್ನು ಉಳಿಸಿಕೊಳ್ಳುತ್ತವೆ.';
  }

  @override
  String resetSessionBody(int count) {
    return 'ನಿಮ್ಮ $count ಎಣಿಕೆ ಶೂನ್ಯಕ್ಕೆ ಹಿಂತಿರುಗುತ್ತದೆ.';
  }

  @override
  String get modeHelpTap =>
      'ವರ್ತುಲವನ್ನು ಟ್ಯಾಪ್ ಮಾಡಿ, ಅಥವಾ ಫೋಕಸ್ ಮೋಡ್‌ನಲ್ಲಿ ಎಲ್ಲಿಯಾದರೂ. ಟ್ಯಾಪ್ ಮೋಡ್ ಮಾತ್ರ ಪರದೆಯ ಟ್ಯಾಪ್‌ಗಳನ್ನು ಎಣಿಸುತ್ತದೆ.';

  @override
  String get modeHelpRhythm =>
      'Start ಒತ್ತಿ, ಕೆಳಗಿನ ವೇಗದಲ್ಲಿ ಎಣಿಕೆ ತಾನಾಗಿಯೇ ಹೆಚ್ಚಾಗುತ್ತದೆ.';

  @override
  String get modeHelpVoice =>
      'Start ಒತ್ತಿ, ನಂತರ ನಿಮ್ಮ ತರಬೇತಿ ಪಡೆದ ಮಂತ್ರವನ್ನು ಜಪಿಸಿ. ಪ್ರತಿ ಬಾರಿ ಗುರುತಿಸಿದಾಗ ಅದು ತಕ್ಷಣ ಒಂದು ಎಣಿಕೆ ಸೇರಿಸುತ್ತದೆ; ಇತರ ಶಬ್ದಗಳನ್ನು ನಿರ್ಲಕ್ಷಿಸಲಾಗುತ್ತದೆ. ಮೈಕ್ರೊಫೋನ್ ಬೇಕು; ಶಾಂತ ಕೋಣೆಯಲ್ಲಿ ಉತ್ತಮವಾಗಿ ಕಾರ್ಯನಿರ್ವಹಿಸುತ್ತದೆ.';

  @override
  String get modeHelpMala =>
      'Start ಒತ್ತಿ, ನಂತರ ಎಣಿಸಲು ಯಾವುದೇ ವಾಲ್ಯೂಮ್ ಬಟನ್ ಒತ್ತಿ. ಕಣ್ಣುಗಳನ್ನು ಮುಚ್ಚಿದಾಗ ಅಥವಾ ಫೋನ್ ಜೇಬಿನಲ್ಲಿದ್ದಾಗ ಅನುಕೂಲಕರ. ಪರದೆ ಆನ್ ಆಗಿರಬೇಕು.';

  @override
  String get countingModeLabel => 'ಎಣಿಕೆ ಮೋಡ್';

  @override
  String pacePrefix(String pace) {
    return 'ವೇಗ: ಎಣಿಕೆ $pace';
  }

  @override
  String modeSemanticLabel(String mode) {
    return '$mode ಮೋಡ್';
  }

  @override
  String get tapAnywhereToCount => 'ಎಣಿಸಲು ಎಲ್ಲಿಯಾದರೂ ಟ್ಯಾಪ್ ಮಾಡಿ';

  @override
  String countingPace(String pace) {
    return 'ಎಣಿಕೆ $pace';
  }

  @override
  String pausedPace(String pace) {
    return 'ವಿರಾಮಗೊಂಡಿದೆ · $pace';
  }

  @override
  String get listening => 'ಕೇಳುತ್ತಿದೆ…';

  @override
  String get startingMicrophone =>
      'ಮೈಕ್ರೊಫೋನ್ ಪ್ರಾರಂಭವಾಗುತ್ತಿದೆ… ಕೇಳಿದರೆ ಪ್ರವೇಶ ನೀಡಿ';

  @override
  String get notTrainedYet =>
      'ಇನ್ನೂ ತರಬೇತಿಗೊಂಡಿಲ್ಲ · ಧ್ವನಿ ಬಳಸಲು ಮಂತ್ರವನ್ನು ತರಬೇತಿಗೊಳಿಸಿ';

  @override
  String get pausedPressStartListen => 'ವಿರಾಮಗೊಂಡಿದೆ · ಕೇಳಲು Start ಒತ್ತಿ';

  @override
  String get pressVolumeKeys => 'ಎಣಿಸಲು ವಾಲ್ಯೂಮ್ ಕೀಗಳನ್ನು ಒತ್ತಿ';

  @override
  String get capturingVolumeKeys => 'ವಾಲ್ಯೂಮ್ ಕೀಗಳನ್ನು ಸೆರೆಹಿಡಿಯುತ್ತಿದೆ…';

  @override
  String get pausedPressStartVolume =>
      'ವಿರಾಮಗೊಂಡಿದೆ · ವಾಲ್ಯೂಮ್ ಕೀಗಳನ್ನು ಬಳಸಲು Start ಒತ್ತಿ';

  @override
  String modeTitleLine(String mode, String own) {
    String _temp0 = intl.Intl.selectLogic(own, {
      'yes': ' · ಸ್ವಂತ ಎಣಿಕೆ',
      'other': '',
    });
    return '$mode ಮೋಡ್$_temp0';
  }

  @override
  String voiceCountedMatch(int percent) {
    return 'ಎಣಿಸಲಾಗಿದೆ · $percent% ಹೊಂದಾಣಿಕೆ';
  }

  @override
  String voiceIgnoredMatch(int percent) {
    return 'ನಿರ್ಲಕ್ಷಿಸಲಾಗಿದೆ · $percent% ಹೊಂದಾಣಿಕೆ (ನಿಮ್ಮ ಮಂತ್ರವಲ್ಲ)';
  }

  @override
  String get paceFieldLabel => 'ವೇಗ';

  @override
  String paceHelpOk(String pace, String range) {
    return '$pace ಎಣಿಸುತ್ತದೆ. (ಅನುಮತಿಸಲಾಗಿದೆ: $range)';
  }

  @override
  String paceHelpError(String error, String pace) {
    return '$error ಇನ್ನೂ $pace ಎಣಿಸುತ್ತಿದೆ.';
  }

  @override
  String get sankalpLabel => 'ಸಂಕಲ್ಪ';

  @override
  String get sankalpHint => 'ಈ ಅಭ್ಯಾಸಕ್ಕಾಗಿ ನಿಮ್ಮ ಸಂಕಲ್ಪವನ್ನು ಹೇಳಿ…';

  @override
  String get targetSectionTitle => 'ಗುರಿ';

  @override
  String get byCount => 'ಎಣಿಕೆಯ ಪ್ರಕಾರ';

  @override
  String get byTime => 'ಸಮಯದ ಪ್ರಕಾರ';

  @override
  String customWithValue(String value) {
    return 'ಕಸ್ಟಮ್ · $value';
  }

  @override
  String get custom => 'ಕಸ್ಟಮ್';

  @override
  String get enterNumberRange => '1 ರಿಂದ 9,999,999 ವರೆಗಿನ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ';

  @override
  String get customCountTitle => 'ಕಸ್ಟಮ್ ಎಣಿಕೆ';

  @override
  String get targetCountLabel => 'ಗುರಿ ಎಣಿಕೆ';

  @override
  String get setAction => 'ಸೆಟ್ ಮಾಡಿ';

  @override
  String get durationLabel => 'ಅವಧಿ';

  @override
  String get enterDuration => '1 ಅಥವಾ ಹೆಚ್ಚಿನ ಅವಧಿಯನ್ನು ನಮೂದಿಸಿ.';

  @override
  String get maxDurationCapped =>
      'ಗರಿಷ್ಠ 99 ಗಂ 59 ನಿ 59 ಸೆ — ಇದನ್ನು ಮಿತಿಗೊಳಿಸಲಾಗುವುದು.';

  @override
  String sessionLasts(String duration) {
    return 'ಅಧಿವೇಶನ $duration ವರೆಗೆ ಇರುತ್ತದೆ.';
  }

  @override
  String get targetReachedFocus => 'ಗುರಿ ತಲುಪಲಾಗಿದೆ 🙏';

  @override
  String screenTapsDoNotCount(String mode) {
    return '$mode ಮೋಡ್‌ನಲ್ಲಿ ಪರದೆಯ ಟ್ಯಾಪ್‌ಗಳನ್ನು ಎಣಿಸಲಾಗುವುದಿಲ್ಲ. ಸರಿಪಡಿಸಲು + ಅಥವಾ − ಬಳಸಿ.';
  }

  @override
  String holdFingersToExit(int fingers, int seconds) {
    return 'ನಿರ್ಗಮಿಸಲು $fingers ಬೆರಳುಗಳನ್ನು $seconds ಸೆಕೆಂಡುಗಳ ಕಾಲ ಒತ್ತಿ ಹಿಡಿಯಿರಿ';
  }

  @override
  String get holdToExitFocusMode => 'ಫೋಕಸ್ ಮೋಡ್‌ನಿಂದ ನಿರ್ಗಮಿಸಲು ಒತ್ತಿ ಹಿಡಿಯಿರಿ';

  @override
  String get holdToExit => 'ನಿರ್ಗಮಿಸಲು ಒತ್ತಿ ಹಿಡಿಯಿರಿ';

  @override
  String get keepHoldingToExit => 'ನಿರ್ಗಮಿಸಲು ಒತ್ತಿ ಹಿಡಿಯುತ್ತಿರಿ…';

  @override
  String addedRecordingsTo(int added, String title, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು',
      one: 'ರೆಕಾರ್ಡಿಂಗ್',
    );
    return '“$title” ಗೆ $added $_temp0 ಸೇರಿಸಲಾಗಿದೆ (ಒಟ್ಟು $total)';
  }

  @override
  String voiceTrainedFor(String title, int count) {
    return '“$title” ಗಾಗಿ ಧ್ವನಿ ತರಬೇತಿಗೊಂಡಿದೆ ($count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು)';
  }

  @override
  String trainedRecordingsCount(int count) {
    return 'ತರಬೇತಿಗೊಂಡಿದೆ · $count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು';
  }

  @override
  String get tooFewRecordings =>
      'ಎಣಿಸಲು ಬಹಳ ಕಡಿಮೆ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳಿವೆ. ಇನ್ನಷ್ಟು ಸೇರಿಸಿ, ಅಥವಾ ಮತ್ತೆ ತರಬೇತಿಗೊಳಿಸಿ.';

  @override
  String canCountAddMore(int room) {
    return 'ಈ ಮಂತ್ರವನ್ನು ಧ್ವನಿ ಎಣಿಸಬಲ್ಲದು. ಮತ್ತೆ ಪ್ರಾರಂಭಿಸದೆ ನಿಖರತೆಯನ್ನು ಸುಧಾರಿಸಲು $room ಇನ್ನಷ್ಟು ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಸೇರಿಸಿ.';
  }

  @override
  String canCountAtMax(int max) {
    return 'ಈ ಮಂತ್ರವನ್ನು ಧ್ವನಿ ಎಣಿಸಬಲ್ಲದು. ನಿಮ್ಮಲ್ಲಿ ಗರಿಷ್ಠ $max ರೆಕಾರ್ಡಿಂಗ್‌ಗಳಿವೆ; ಅವುಗಳನ್ನು ಬದಲಾಯಿಸಲು ಮತ್ತೆ ತರಬೇತಿಗೊಳಿಸಿ.';
  }

  @override
  String get pausedHeadline => 'ವಿರಾಮಗೊಂಡಿದೆ';

  @override
  String pausedSub(int recorded) {
    return '$recorded ರೆಕಾರ್ಡ್ ಮಾಡಲಾಗಿದೆ. ಮುಂದುವರಿಸಿ, ಅಥವಾ ಇರುವುದನ್ನು ಉಳಿಸಿ.';
  }

  @override
  String recordInstructions(int min, int max, int recommended) {
    return 'ನಿಮ್ಮ ಸಾಮಾನ್ಯ ಜಪ ವೇಗದಲ್ಲಿ ಇದನ್ನು $min ರಿಂದ $max ಬಾರಿ ರೆಕಾರ್ಡ್ ಮಾಡಿ ($recommended ಉತ್ತಮ ಸಂಖ್ಯೆ). ನಂತರ ಧ್ವನಿ ನಿಮ್ಮ ಮಂತ್ರವನ್ನು ಮಾತ್ರ ಎಣಿಸುತ್ತದೆ.';
  }

  @override
  String get openingMicrophone => 'ಮೈಕ್ರೊಫೋನ್ ತೆರೆಯಲಾಗುತ್ತಿದೆ…';

  @override
  String get stayQuiet => 'ಒಂದು ಕ್ಷಣ ಮೌನವಾಗಿರಿ…';

  @override
  String get listeningToRoom =>
      'ಹಿನ್ನೆಲೆ ಶಬ್ದ ಎಣಿಸದಂತೆ ಕೋಣೆಯನ್ನು ಕೇಳಲಾಗುತ್ತಿದೆ.';

  @override
  String get sayYourMantra => 'ನಿಮ್ಮ ಮಂತ್ರವನ್ನು ಹೇಳಿ…';

  @override
  String recordingXofY(int current, int max) {
    return '$current ರೆಕಾರ್ಡ್ ಆಗುತ್ತಿದೆ, ಗರಿಷ್ಠ $max ರಲ್ಲಿ';
  }

  @override
  String allRecordingsCaptured(int count) {
    return 'ಎಲ್ಲಾ $count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಸೆರೆಹಿಡಿಯಲಾಗಿದೆ';
  }

  @override
  String get saveToStartCounting =>
      'ಧ್ವನಿಯಿಂದ ಎಣಿಕೆ ಪ್ರಾರಂಭಿಸಲು ಇವುಗಳನ್ನು ಉಳಿಸಿ.';

  @override
  String get cannotUseMicrophone => 'ಮೈಕ್ರೊಫೋನ್ ಬಳಸಲಾಗುವುದಿಲ್ಲ';

  @override
  String get canSaveNowHint =>
      'ನೀವು ಈಗ ಉಳಿಸಬಹುದು, ಅಥವಾ ಹೆಚ್ಚಿನ ನಿಖರತೆಗಾಗಿ ಮುಂದುವರಿಸಬಹುದು.';

  @override
  String minAreEnough(int min) {
    return 'ಪ್ರಾರಂಭಿಸಲು $min ಸಾಕು.';
  }

  @override
  String addingToSaved(int count) {
    return 'ನಿಮ್ಮ $count ಉಳಿಸಿದ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳಿಗೆ ಸೇರಿಸಲಾಗುತ್ತಿದೆ.';
  }

  @override
  String get tryAgain => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get startRecording => 'ರೆಕಾರ್ಡಿಂಗ್ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get openSettingsAction => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ';

  @override
  String saveNRecordings(int count) {
    return '$count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಉಳಿಸಿ';
  }

  @override
  String recordMoreToSave(int n) {
    return 'ಉಳಿಸಲು $n ಇನ್ನಷ್ಟು ರೆಕಾರ್ಡ್ ಮಾಡಿ';
  }

  @override
  String get recordSampleToSave => 'ಉಳಿಸಲು ಒಂದು ಮಾದರಿಯನ್ನು ರೆಕಾರ್ಡ್ ಮಾಡಿ';

  @override
  String get undoLast => 'ಕೊನೆಯದನ್ನು ರದ್ದುಗೊಳಿಸಿ';

  @override
  String get stop => 'ನಿಲ್ಲಿಸಿ';

  @override
  String get continueRecording => 'ರೆಕಾರ್ಡಿಂಗ್ ಮುಂದುವರಿಸಿ';

  @override
  String get startOver => 'ಮತ್ತೆ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String recordedOfMax(int recorded, int max) {
    return '$recorded ರೆಕಾರ್ಡ್ ಮಾಡಲಾಗಿದೆ, ಗರಿಷ್ಠ $max ರಲ್ಲಿ';
  }

  @override
  String voiceBetaNoteTraining(int max) {
    return 'ಬೀಟಾ. ಎಲ್ಲವೂ ಈ ಸಾಧನದಲ್ಲಿಯೇ, ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿ ನಡೆಯುತ್ತದೆ: ಶಬ್ದವನ್ನು ವಿವರಿಸುವ ಸಂಖ್ಯೆಗಳು ಮಾತ್ರ ಉಳಿಸಲ್ಪಡುತ್ತವೆ, ಆಡಿಯೋ ಎಂದಿಗೂ ಅಲ್ಲ. ಹೆಚ್ಚಿನ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ಎಣಿಕೆಯನ್ನು ಹೆಚ್ಚು ನಿಖರಗೊಳಿಸುತ್ತವೆ (ಗರಿಷ್ಠ $max ವರೆಗೆ); ಗದ್ದಲದ ಕೋಣೆ ಅದನ್ನು ಕಡಿಮೆ ನಿಖರಗೊಳಿಸುತ್ತದೆ. ಮಂತ್ರವನ್ನು ಒಮ್ಮೆ ಹೇಳಿ, ಮುಂದಿನದಕ್ಕೂ ಮೊದಲು ಸ್ವಲ್ಪ ನಿಲ್ಲಿಸಿ.';
  }

  @override
  String get actionClear => 'ತೆರವುಗೊಳಿಸಿ';

  @override
  String get today => 'ಇಂದು';

  @override
  String get previousMonth => 'ಹಿಂದಿನ ತಿಂಗಳು';

  @override
  String get nextMonth => 'ಮುಂದಿನ ತಿಂಗಳು';

  @override
  String get markTypeGood => 'ಒಳ್ಳೆಯದು';

  @override
  String get markTypeCautious => 'ಎಚ್ಚರಿಕೆ';

  @override
  String get markTypeNeutral => 'ತಟಸ್ಥ';

  @override
  String get reminderModeNone => 'ಸಮಯವಿಲ್ಲ';

  @override
  String get reminderModeOnce => 'ಒಂದು ಬಾರಿ';

  @override
  String get reminderModeSeveral => 'ಹಲವಾರು ಬಾರಿ';

  @override
  String get repeatRuleOnce => 'ಒಂದು ಬಾರಿ';

  @override
  String get repeatRuleDaily => 'ಪ್ರತಿದಿನ';

  @override
  String get repeatRuleWeekly => 'ವಾರಕ್ಕೊಮ್ಮೆ';

  @override
  String get repeatRuleMonthly => 'ಮಾಸಿಕ';

  @override
  String get repeatRuleQuarterly => 'ತ್ರೈಮಾಸಿಕ';

  @override
  String get repeatRuleHalfYearly => 'ಅರ್ಧ-ವಾರ್ಷಿಕ';

  @override
  String get repeatRuleYearly => 'ವಾರ್ಷಿಕ';

  @override
  String get homeModeNone => 'ತೋರಿಸಬೇಡಿ';

  @override
  String get homeModeMorning => 'ಬೆಳಿಗ್ಗೆ ಒಮ್ಮೆ';

  @override
  String get homeModeAllDay => 'ಇಡೀ ದಿನ ಇರಿಸಿ';

  @override
  String get markStyleDot => 'ಚುಕ್ಕೆ';

  @override
  String get markStyleFilled => 'ತುಂಬಿದ';

  @override
  String get markStyleHighlight => 'ಹೈಲೈಟ್';

  @override
  String get markStyleCircle => 'ವೃತ್ತ';

  @override
  String get markStyleSquare => 'ಚೌಕ';

  @override
  String get emojiOm => 'ॐ';

  @override
  String get emojiKhanda => 'ಖಂಡಾ';

  @override
  String get emojiMala => 'ಮಾಲೆ';

  @override
  String get emojiDiya => 'ದೀಪ';

  @override
  String get emojiBell => 'ಗಂಟೆ';

  @override
  String get emojiSunrise => 'ಸೂರ್ಯೋದಯ';

  @override
  String get emojiStar => 'ನಕ್ಷತ್ರ';

  @override
  String get emojiSparkle => 'ಹೊಳಪು';

  @override
  String get emojiMoney => 'ಹಣ';

  @override
  String get emojiHandshake => 'ಹಸ್ತಲಾಘವ';

  @override
  String get emojiAvoid => 'ತಪ್ಪಿಸಿ';

  @override
  String get emojiDone => 'ಮುಗಿದಿದೆ';

  @override
  String get markTitleGood => 'ಒಳ್ಳೆಯ ದಿನ';

  @override
  String get markTitleCautious => 'ಎಚ್ಚರಿಕೆಯ ದಿನ';

  @override
  String get markTitleNeutral => 'ತಟಸ್ಥ ದಿನ';

  @override
  String get reminderBodyGood => 'ಒಂದು ಒಳ್ಳೆಯ ದಿನ.';

  @override
  String get reminderBodyCautious => 'ಇಂದು ಎಚ್ಚರಿಕೆಯಿಂದಿರಿ.';

  @override
  String get reminderBodyNeutral => 'ನಿಮ್ಮ ಕ್ಯಾಲೆಂಡರ್‌ನಲ್ಲಿ ಗುರುತಿಸಲಾಗಿದೆ.';

  @override
  String get channelCalendarRemindersName => 'ಕ್ಯಾಲೆಂಡರ್ ಜ್ಞಾಪನೆಗಳು';

  @override
  String get channelCalendarRemindersDesc =>
      'ನೀವು Sadho ನಲ್ಲಿ ಗುರುತಿಸಿದ ದಿನಾಂಕಗಳಿಗಾಗಿ ಜ್ಞಾಪನೆಗಳು';

  @override
  String get channelAlarmsName => 'ಅಲಾರಂ ಮತ್ತು ಟೈಮರ್';

  @override
  String get channelAlarmsDesc => 'ಸೂರ್ಯ ಆಧಾರಿತ ಅಲಾರಂ ಮತ್ತು ಮುಗಿದ ಟೈಮರ್‌ಗಳು';

  @override
  String get repeatSummaryOnce => 'ಒಂದು ಬಾರಿ';

  @override
  String get repeatSummaryDaily => 'ಪ್ರತಿದಿನ';

  @override
  String get repeatSummaryWeekly => 'ಪ್ರತಿ ವಾರ';

  @override
  String get repeatSummaryMonthly => 'ಪ್ರತಿ ತಿಂಗಳು';

  @override
  String get repeatSummaryQuarterly => 'ಪ್ರತಿ 3 ತಿಂಗಳಿಗೆ';

  @override
  String get repeatSummaryHalfYearly => 'ಪ್ರತಿ 6 ತಿಂಗಳಿಗೆ';

  @override
  String get repeatSummaryYearly => 'ಪ್ರತಿ ವರ್ಷ';

  @override
  String reminderSummaryAt(String times) {
    return '$times ಕ್ಕೆ ನೆನಪಿಸಿ';
  }

  @override
  String homeSummaryFrom(String time) {
    return 'ಹೋಮ್‌ನಲ್ಲಿ $time ರಿಂದ';
  }

  @override
  String get homeSummaryAllDay => 'ಹೋಮ್‌ನಲ್ಲಿ ಇಡೀ ದಿನ';

  @override
  String marksInMonth(String month) {
    return '$month ನಲ್ಲಿ ಗುರುತುಗಳು';
  }

  @override
  String noMarksInMonth(String month) {
    return '$month ನಲ್ಲಿ ಏನೂ ಗುರುತಿಸಲಾಗಿಲ್ಲ. ಗುರುತು ಸೇರಿಸಲು ದಿನಾಂಕವನ್ನು ಟ್ಯಾಪ್ ಮಾಡಿ.';
  }

  @override
  String get markStyleSectionTitle => 'ಗುರುತು ಶೈಲಿ';

  @override
  String get markStyleSectionHint =>
      'ಗುರುತಿಸಿದ ದಿನಾಂಕಗಳು ಹೇಗೆ ಕಾಣುತ್ತವೆ. ಪ್ರತಿ ಗುರುತಿಗೆ ಅನ್ವಯಿಸುತ್ತದೆ.';

  @override
  String markStyleSemantic(String style) {
    return '$style ಗುರುತು ಶೈಲಿ';
  }

  @override
  String get dayCellToday => ', ಇಂದು';

  @override
  String get dayCellAnd => 'ಮತ್ತು';

  @override
  String dayCellMarkedSuffix(int count, String kinds) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ', $kinds ಗುರುತಿಸಲಾಗಿದೆ, $count ಗುರುತುಗಳು',
      one: ', $kinds ಗುರುತಿಸಲಾಗಿದೆ, 1 ಗುರುತು',
    );
    return '$_temp0';
  }

  @override
  String get markEditorNoTimeWarning =>
      'ಕನಿಷ್ಠ ಒಂದು ಸಮಯವನ್ನು ಸೇರಿಸಿ, ಅಥವಾ \"ಸಮಯವಿಲ್ಲ\" ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get notificationsOffWarning =>
      'Sadho ಗಾಗಿ ಅಧಿಸೂಚನೆಗಳು ಆಫ್ ಆಗಿವೆ, ಆದ್ದರಿಂದ ಈ ಜ್ಞಾಪನೆ ಮೊಳಗುವುದಿಲ್ಲ. ಅವುಗಳನ್ನು ನಿಮ್ಮ ಫೋನ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಆನ್ ಮಾಡಿ.';

  @override
  String get deleteMarkFallbackTitle => 'ಈ ಗುರುತು';

  @override
  String get deleteMarkQuestion => 'ಈ ಗುರುತನ್ನು ಅಳಿಸುವುದೇ?';

  @override
  String deleteMarkRepeatsBody(String title) {
    return '$title ಮತ್ತು ಅದರ ಎಲ್ಲಾ ಪುನರಾವರ್ತನೆಗಳನ್ನು ಅಳಿಸುವುದೇ? ಅದರ ಜ್ಞಾಪನೆಗಳನ್ನು ಸಹ ತೆಗೆದುಹಾಕಲಾಗುವುದು.';
  }

  @override
  String deleteMarkBody(String title) {
    return '$title ಅಳಿಸುವುದೇ? ಅದರ ಜ್ಞಾಪನೆಗಳನ್ನು ಸಹ ತೆಗೆದುಹಾಕಲಾಗುವುದು.';
  }

  @override
  String get newMark => 'ಹೊಸ ಗುರುತು';

  @override
  String get editMark => 'ಗುರುತು ಸಂಪಾದಿಸಿ';

  @override
  String repeatFromNotice(String repeatSummary, String date) {
    return '$repeatSummary, $date ರಿಂದ. ಬದಲಾವಣೆಗಳು ಪ್ರತಿ ಪುನರಾವರ್ತನೆಗೆ ಅನ್ವಯಿಸುತ್ತವೆ.';
  }

  @override
  String get markTypeSectionTitle => 'ಗುರುತು ಪ್ರಕಾರ';

  @override
  String get iconSectionTitle => 'ಐಕಾನ್';

  @override
  String get iconNone => 'ಯಾವುದೂ ಇಲ್ಲ';

  @override
  String get labelFieldLabel => 'ಲೇಬಲ್';

  @override
  String get detailsFieldLabel => 'ವಿವರಗಳು / ಟಿಪ್ಪಣಿಗಳು';

  @override
  String get remindMeAtSectionTitle => 'ನನಗೆ ನೆನಪಿಸಿ';

  @override
  String removeTimeTooltip(String time) {
    return '$time ಅನ್ನು ತೆಗೆದುಹಾಕಿ';
  }

  @override
  String get addTime => 'ಸಮಯ ಸೇರಿಸಿ';

  @override
  String get repeatSectionTitle => 'ಪುನರಾವರ್ತನೆ';

  @override
  String get onHomeScreenSectionTitle => 'ನಿಮ್ಮ ಹೋಮ್ ಸ್ಕ್ರೀನ್‌ನಲ್ಲಿ';

  @override
  String showFromTime(String time) {
    return '$time ರಿಂದ ತೋರಿಸಿ';
  }

  @override
  String get homeModeNoneExplain => 'ಗುರುತು ಕ್ಯಾಲೆಂಡರ್‌ನಲ್ಲಿ ಮಾತ್ರ ಇರುತ್ತದೆ.';

  @override
  String get homeModeMorningExplain =>
      'ಆ ಸಮಯದಲ್ಲಿ ಹೋಮ್‌ನಲ್ಲಿ ಒಂದು ಕಾರ್ಡ್ ಕಾಣಿಸಿಕೊಳ್ಳುತ್ತದೆ. ಮುಗಿದ ನಂತರ ಅದನ್ನು ಸ್ವೈಪ್ ಮಾಡಿ: ಮುಂದಿನ ಪುನರಾವರ್ತನೆಯಲ್ಲಿ ಅದು ಮತ್ತೆ ಬರುತ್ತದೆ.';

  @override
  String get homeModeAllDayExplain =>
      'ಒಂದು ಕಾರ್ಡ್ ಹೋಮ್‌ನಲ್ಲಿ ಇಡೀ ದಿನ ಪಿನ್ ಆಗಿರುತ್ತದೆ (ಇದನ್ನು ಸ್ವೈಪ್ ಮಾಡಲಾಗುವುದಿಲ್ಲ).';

  @override
  String get tomorrow => 'ನಾಳೆ';

  @override
  String get yesterday => 'ನಿನ್ನೆ';

  @override
  String get startAgain => 'ಮತ್ತೆ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get settingsAction => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get clockToolClockSubtitle => 'ದೊಡ್ಡ, ಲೈವ್ ಸಮಯ ಮತ್ತು ದಿನಾಂಕ';

  @override
  String get clockToolSunAlarmTitle => 'ಸೂರ್ಯ ಆಧಾರಿತ ಅಲಾರಂ';

  @override
  String get clockToolSunAlarmSubtitle =>
      'ಸೂರ್ಯೋದಯ ಅಥವಾ ಸೂರ್ಯಾಸ್ತದಲ್ಲಿ, ಆಫ್‌ಸೆಟ್‌ನೊಂದಿಗೆ ಎಚ್ಚರಗೊಳ್ಳಿ';

  @override
  String get clockToolWorldClockTitle => 'ವಿಶ್ವ ಗಡಿಯಾರ';

  @override
  String get clockToolWorldClockSubtitle =>
      'ಅಮೃತಸರ, ಹರಿದ್ವಾರ, ಲಂಡನ್ ಮತ್ತು ಇನ್ನಷ್ಟು';

  @override
  String get clockToolTimerTitle => 'ಸಾಧನೆ ಮತ್ತು ವ್ರತ ಟೈಮರ್';

  @override
  String get clockToolTimerSubtitle =>
      'ಆರತಿ, ಚಾಲೀಸಾ, ಪಾಠ, ಹವನ, ಅಥವಾ ಸೂರ್ಯಾಸ್ತದವರೆಗೆ';

  @override
  String get clockToolStopwatchTitle => 'ಪಾಠ ಸ್ಟಾಪ್‌ವಾಚ್';

  @override
  String get clockToolStopwatchSubtitle =>
      'ಪ್ರಾರಂಭಿಸಿ, ನಿಲ್ಲಿಸಿ ಮತ್ತು ಲ್ಯಾಪ್ ಮಾಡಿ';

  @override
  String get sunEventSunrise => 'ಸೂರ್ಯೋದಯ';

  @override
  String get sunEventSunset => 'ಸೂರ್ಯಾಸ್ತ';

  @override
  String offsetAtEvent(String event) {
    return '$event ನಲ್ಲಿ';
  }

  @override
  String offsetMinutesOnly(int m) {
    return '$m ನಿಮಿಷಗಳು';
  }

  @override
  String offsetHoursOnly(int h) {
    return '$h ಗಂ';
  }

  @override
  String offsetHoursMinutes(int h, int m) {
    return '$h ಗಂ $m ನಿಮಿಷಗಳು';
  }

  @override
  String offsetBefore(String amount) {
    return '$amount ಮೊದಲು';
  }

  @override
  String offsetAfter(String amount) {
    return '$amount ನಂತರ';
  }

  @override
  String get locationSourceDevice => 'ನಿಮ್ಮ ಸ್ಥಳ';

  @override
  String get locationSourceSaved => 'ನಿಮ್ಮ ಕೊನೆಯ ತಿಳಿದಿರುವ ಸ್ಥಳ';

  @override
  String get locationSourceFallback => 'ಅಮೃತಸರ (ಡೀಫಾಲ್ಟ್)';

  @override
  String get locSummaryDevice => 'ನಿಮ್ಮ ಸ್ಥಳವನ್ನು ಬಳಸಲಾಗುತ್ತಿದೆ';

  @override
  String get locSummarySaved => 'ನಿಮ್ಮ ಕೊನೆಯ ತಿಳಿದಿರುವ ಸ್ಥಳವನ್ನು ಬಳಸಲಾಗುತ್ತಿದೆ';

  @override
  String get locSummaryBlocked =>
      'ಅಮೃತಸರ ಬಳಸಲಾಗುತ್ತಿದೆ. ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಸ್ಥಳ ನಿರ್ಬಂಧಿಸಲಾಗಿದೆ.';

  @override
  String get locSummaryServiceOff =>
      'ಅಮೃತಸರ ಬಳಸಲಾಗುತ್ತಿದೆ. ನಿಖರ ಸಮಯಗಳಿಗಾಗಿ ಸ್ಥಳವನ್ನು ಆನ್ ಮಾಡಿ.';

  @override
  String get locSummaryUnsupported => 'ಅಮೃತಸರ ಬಳಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get locSummaryDefault =>
      'ಅಮೃತಸರ ಬಳಸಲಾಗುತ್ತಿದೆ. ನಿಖರ ಸಮಯಗಳಿಗಾಗಿ ಸ್ಥಳವನ್ನು ಅನುಮತಿಸಿ.';

  @override
  String get presetAarti => 'ಆರತಿ';

  @override
  String get presetChalisa => 'ಚಾಲೀಸಾ';

  @override
  String get presetPath => 'ಪಾಠ';

  @override
  String get presetHavan => 'ಹವನ';

  @override
  String get vratToSunset => 'ವ್ರತ → ಸೂರ್ಯಾಸ್ತ';

  @override
  String presetChipLabel(String label, int minutes) {
    return '$label · $minutes ನಿಮಿಷಗಳು';
  }

  @override
  String get clockNoSunsetHere => 'ಇಲ್ಲಿ ಈಗ ಎಣಿಸಲು ಸೂರ್ಯಾಸ್ತವಿಲ್ಲ.';

  @override
  String get clockSunsetPassedTomorrow =>
      'ಇಂದಿನ ಸೂರ್ಯಾಸ್ತ ಕಳೆದಿದೆ: ನಾಳೆಗಾಗಿ ಎಣಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String timerFinishedTitle(String label) {
    return '🔔 $label ಮುಗಿದಿದೆ';
  }

  @override
  String get sunsetArrived => 'ಸೂರ್ಯಾಸ್ತ ಬಂದಿದೆ 🙏';

  @override
  String timerTimeUp(String label) {
    return 'ನಿಮ್ಮ $label ಸಮಯ ಮುಗಿದಿದೆ 🙏';
  }

  @override
  String sunAlarmNotifTitle(String emoji, String event) {
    return '$emoji $event ಅಲಾರಂ';
  }

  @override
  String sunAlarmNotifBody(String event, String time, String offset) {
    return '$event $time ಕ್ಕೆ ಇದೆ · $offset';
  }

  @override
  String get statusOn => 'ಆನ್';

  @override
  String get finished => 'ಮುಗಿದಿದೆ';

  @override
  String get left => 'ಬಾಕಿ';

  @override
  String get paused => 'ವಿರಾಮ';

  @override
  String get runningStatus => 'ಚಾಲನೆಯಲ್ಲಿದೆ';

  @override
  String get stoppedStatus => 'ನಿಂತಿದೆ';

  @override
  String get lap => 'ಲ್ಯಾಪ್';

  @override
  String get lapTime => 'ಲ್ಯಾಪ್ ಸಮಯ';

  @override
  String get total => 'ಒಟ್ಟು';

  @override
  String get fastest => 'ವೇಗವಾದ';

  @override
  String get slowest => 'ನಿಧಾನವಾದ';

  @override
  String get tapLapToMark => 'ಲ್ಯಾಪ್ ಗುರುತಿಸಲು Lap ಟ್ಯಾಪ್ ಮಾಡಿ.';

  @override
  String get startThenTapLap =>
      'Start ಮಾಡಿ, ನಂತರ ಪ್ರತಿ ಸುತ್ತಿನಲ್ಲಿ Lap ಟ್ಯಾಪ್ ಮಾಡಿ.';

  @override
  String get allowNotificationsForAlarm =>
      'ಅಲಾರಂ ಮೊಳಗಲು ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಅಧಿಸೂಚನೆಗಳನ್ನು ಆನ್ ಮಾಡಿ.';

  @override
  String get alarmRingsAt => 'ಅಲಾರಂ ಮೊಳಗುತ್ತದೆ';

  @override
  String get alarmWouldRingAt => 'ಅಲಾರಂ ಮೊಳಗುತ್ತಿತ್ತು';

  @override
  String noEventToFollow(String event) {
    return 'ಇಲ್ಲಿ ಈಗ ಅನುಸರಿಸಲು $event ಇಲ್ಲ.';
  }

  @override
  String get alarmOnLabel => 'ಅಲಾರಂ ಆನ್';

  @override
  String get recalculatedDaily =>
      'ಸೂರ್ಯ ಚಲಿಸುತ್ತಿದ್ದಂತೆ ಪ್ರತಿದಿನ ಮರುಲೆಕ್ಕಾಚಾರ ಮಾಡಲಾಗುತ್ತದೆ';

  @override
  String todayHereSunriseSunset(String rise, String set) {
    return 'ಇಲ್ಲಿ ಇಂದು: ಸೂರ್ಯೋದಯ $rise · ಸೂರ್ಯಾಸ್ತ $set';
  }

  @override
  String get whenLabel => 'ಯಾವಾಗ';

  @override
  String get minutesLabel => 'ನಿಮಿಷಗಳು';

  @override
  String get upTo1440 => '1440 ರವರೆಗೆ';

  @override
  String get before => 'ಮೊದಲು';

  @override
  String get after => 'ನಂತರ';

  @override
  String get useMyLocation => 'ನನ್ನ ಸ್ಥಳವನ್ನು ಬಳಸಿ';

  @override
  String get couldNotReadPosition => ' · ನಿಮ್ಮ ಸ್ಥಾನವನ್ನು ಓದಲಾಗಲಿಲ್ಲ';

  @override
  String get timesUp => 'ಸಮಯ ಮುಗಿದಿದೆ 🙏';

  @override
  String sunsetAtTime(String time) {
    return 'ಸೂರ್ಯಾಸ್ತ $time ಕ್ಕೆ';
  }

  @override
  String cityInDays(int days) {
    return '$days ದಿನಗಳಲ್ಲಿ';
  }

  @override
  String cityDaysAgo(int days) {
    return '$days ದಿನಗಳ ಹಿಂದೆ';
  }

  @override
  String get citySameTime => 'ನಿಮ್ಮಂತೆಯೇ ಅದೇ ಸಮಯ';

  @override
  String cityAmountMinutes(int m) {
    return '$m ನಿ';
  }

  @override
  String cityAmountHours(int h) {
    return '$h ಗಂ';
  }

  @override
  String cityAmountHoursMinutes(int h, int m) {
    return '$h ಗಂ $m ನಿ';
  }

  @override
  String cityAheadOfYou(String amount) {
    return 'ನಿಮಗಿಂತ $amount ಮುಂದೆ';
  }

  @override
  String cityBehindYou(String amount) {
    return 'ನಿಮಗಿಂತ $amount ಹಿಂದೆ';
  }

  @override
  String get traditionHindu => 'ಹಿಂದೂ';

  @override
  String get traditionSikh => 'ಸಿಖ್';

  @override
  String get traditionPlace => 'ಸ್ಥಳದ ಪ್ರಕಾರ';

  @override
  String get todayLabelTithi => 'ತಿಥಿ';

  @override
  String get todayLabelNakshatra => 'ನಕ್ಷತ್ರ';

  @override
  String get todayLabelRahu => 'ರಾಹು ಕಾಲ';

  @override
  String get todayLabelAbhijit => 'ಅಭಿಜಿತ್ ಮುಹೂರ್ತ';

  @override
  String get todayLabelHukamnama => 'ಹುಕಂನಾಮಾ';

  @override
  String get todayLabelNitnem => 'ನಿತ್ನೇಮ್ ಬಾಕಿ';

  @override
  String get todayLabelGurpurab => 'ಮುಂದಿನ ಗುರುಪರ್ವ';

  @override
  String get todayLabelFestival => 'ಸ್ಥಳೀಯ ಹಬ್ಬ';

  @override
  String get todayLabelWindow => 'ಶುಭ ಸಮಯ';

  @override
  String get exampleTag => 'ಉದಾಹರಣೆ';

  @override
  String get exampleNote =>
      'ಉದಾಹರಣೆ ಎಂದು ಗುರುತಿಸಿದ ಮೌಲ್ಯಗಳು ಪ್ಲೇಸ್‌ಹೋಲ್ಡರ್‌ಗಳು: ನಿಜವಾದ ಪಂಚಾಂಗ ಡೇಟಾ ನಂತರದ ಹಂತದಲ್ಲಿ ಬರುತ್ತದೆ.';

  @override
  String liveNote(String where) {
    return 'ಸೂರ್ಯೋದಯ ಮತ್ತು ಸೂರ್ಯಾಸ್ತವನ್ನು ನಿಮ್ಮ ಸ್ಥಳಕ್ಕಾಗಿ ಲೆಕ್ಕಹಾಕಲಾಗಿದೆ. $where.';
  }

  @override
  String get greetingMorning => 'ಶುಭೋದಯ';

  @override
  String get greetingAfternoon => 'ಶುಭ ಮಧ್ಯಾಹ್ನ';

  @override
  String get greetingEvening => 'ಶುಭ ಸಂಜೆ';

  @override
  String get greetingNight => 'ಶುಭ ರಾತ್ರಿ';

  @override
  String get homeEmptyTitle => 'ಇಂದು ನಿಮ್ಮ ಹೋಮ್ ಸ್ಕ್ರೀನ್‌ನಲ್ಲಿ ಏನೂ ಇಲ್ಲ';

  @override
  String get homeEmptyBody =>
      'ಕ್ಯಾಲೆಂಡರ್‌ನಲ್ಲಿ ಒಂದು ದಿನಾಂಕವನ್ನು ಗುರುತಿಸಿ ಮತ್ತು ಇದನ್ನು ಇಲ್ಲಿ ನೋಡಲು \"ನಿಮ್ಮ ಹೋಮ್ ಸ್ಕ್ರೀನ್‌ನಲ್ಲಿ\" ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get pinnedAllDay => 'ಇಡೀ ದಿನ ಪಿನ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String get swipeToDismiss => 'ಇಂದಿಗೆ ತೆಗೆದುಹಾಕಲು ಸ್ವೈಪ್ ಮಾಡಿ';

  @override
  String doneForToday(String title) {
    return 'ಇಂದಿಗೆ ಮುಗಿದಿದೆ: $title';
  }

  @override
  String get undoAction => 'ರದ್ದುಗೊಳಿಸಿ';

  @override
  String get doneForTodayLabel => 'ಇಂದಿಗೆ ಮುಗಿದಿದೆ';

  @override
  String get plansTitle => 'ಪಾಠ ಮತ್ತು ಮಂತ್ರ ಯೋಜನೆಗಳು';

  @override
  String get addPlan => 'ಯೋಜನೆ ಸೇರಿಸಿ';

  @override
  String get dayStreak => 'ದಿನದ ಸರಣಿ';

  @override
  String activePlanCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ಸಕ್ರಿಯ ಯೋಜನೆಗಳು',
      one: 'ಸಕ್ರಿಯ ಯೋಜನೆ',
    );
    return '$_temp0';
  }

  @override
  String get noPlansYet => 'ಇನ್ನೂ ಯಾವುದೇ ಯೋಜನೆಗಳಿಲ್ಲ';

  @override
  String get plansEmptyBody =>
      'ಒಂದು ಪಾಠ ಅಥವಾ ಮಂತ್ರಕ್ಕಾಗಿ ಹಲವು ದಿನಗಳವರೆಗೆ ಬದ್ಧರಾಗಿ ಪ್ರತಿ ದಿನ ಗುರುತಿಸಿ. ಇವುಗಳಲ್ಲಿ ಒಂದರಿಂದ ಪ್ರಾರಂಭಿಸಿ, ಅಥವಾ ನಿಮ್ಮದೇ ಆದದನ್ನು ಸೇರಿಸಿ.';

  @override
  String get planOptionsTooltip => 'ಯೋಜನೆಯ ಆಯ್ಕೆಗಳು';

  @override
  String get deletePlanMenuItem => 'ಯೋಜನೆ ಅಳಿಸಿ';

  @override
  String get deletePlanQuestion => 'ಯೋಜನೆ ಅಳಿಸುವುದೇ?';

  @override
  String deletePlanBody(String title) {
    return '$title ಮತ್ತು ಅದರ ಪ್ರಗತಿಯನ್ನು ತೆಗೆದುಹಾಕಲಾಗುವುದು.';
  }

  @override
  String titledDaysTag(String title, int days) {
    return '$title · $days ದಿನಗಳು';
  }

  @override
  String completedOfDays(int completed, int total) {
    return 'ಪೂರ್ಣಗೊಂಡಿದೆ · $total ರಲ್ಲಿ $completed ದಿನಗಳು';
  }

  @override
  String ofDays(int completed, int total) {
    return '$total ರಲ್ಲಿ $completed ದಿನಗಳು';
  }

  @override
  String get doneTodayButton => 'ಇಂದು ಮುಗಿದಿದೆ';

  @override
  String get markTodayDone => 'ಇಂದು ಮುಗಿದಿದೆ ಎಂದು ಗುರುತಿಸಿ';

  @override
  String get newPlanTitle => 'ಹೊಸ ಯೋಜನೆ';

  @override
  String get newPlanSubtitle =>
      'ಒಂದು ಪಾಠ ಅಥವಾ ಮಂತ್ರವನ್ನು ಆಯ್ಕೆಮಾಡಿ ಮತ್ತು ನೀವು ಅದನ್ನು ಎಷ್ಟು ದಿನ ಮುಂದುವರಿಸುತ್ತೀರಿ ಎಂಬುದನ್ನು ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get paathOrMantraLabel => 'ಪಾಠ ಅಥವಾ ಮಂತ್ರ';

  @override
  String get giveThePlanAName => 'ಯೋಜನೆಗೆ ಒಂದು ಹೆಸರು ನೀಡಿ';

  @override
  String chooseDaysRange(int min, int max) {
    return '$min ರಿಂದ $max ದಿನಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ';
  }

  @override
  String get forHowManyDays => 'ಎಷ್ಟು ದಿನಗಳಿಗೆ?';

  @override
  String get daysFieldLabel => 'ದಿನಗಳು';

  @override
  String get startPlanButton => 'ಯೋಜನೆ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get planKindPaath => 'ಪಾಠ';

  @override
  String get planKindMantra => 'ಮಂತ್ರ';

  @override
  String get profileTitle => 'ಪ್ರೊಫೈಲ್';

  @override
  String get sadhanaSettingsTitle => 'ಸಾಧನೆ ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get validEmailError => 'ಮಾನ್ಯ ಇಮೇಲ್ ವಿಳಾಸ ನಮೂದಿಸಿ';

  @override
  String nameTooLong(int max) {
    return 'ಇದನ್ನು $max ಅಕ್ಷರಗಳಿಗಿಂತ ಕಡಿಮೆ ಇಡಿ';
  }

  @override
  String get enterCurrentPassword => 'ನಿಮ್ಮ ಪ್ರಸ್ತುತ ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ';

  @override
  String passwordTooShort(int min) {
    return 'ಕನಿಷ್ಠ $min ಅಕ್ಷರಗಳನ್ನು ಬಳಸಿ';
  }

  @override
  String get passwordAlreadyUsed => 'ನೀವು ಈ ಹಿಂದೆ ಬಳಸದ ಪಾಸ್‌ವರ್ಡ್ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get passwordsDontMatch => 'ಎರಡು ಪಾಸ್‌ವರ್ಡ್‌ಗಳು ಹೊಂದಿಕೆಯಾಗುತ್ತಿಲ್ಲ';

  @override
  String get changePasswordTitle => 'ಪಾಸ್‌ವರ್ಡ್ ಬದಲಾಯಿಸಿ';

  @override
  String get accountsLaterNote =>
      'ಖಾತೆಗಳು ನಂತರದ ಹಂತದಲ್ಲಿ ಬರುತ್ತವೆ; ಅಲ್ಲಿಯವರೆಗೆ ಇದು ನಿಮ್ಮ ನಮೂದುಗಳನ್ನು ಮಾತ್ರ ಪರಿಶೀಲಿಸುತ್ತದೆ, ಏನನ್ನೂ ಬದಲಾಯಿಸುವುದಿಲ್ಲ.';

  @override
  String get currentPasswordLabel => 'ಪ್ರಸ್ತುತ ಪಾಸ್‌ವರ್ಡ್';

  @override
  String get newPasswordLabel => 'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್';

  @override
  String get confirmNewPasswordLabel => 'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ದೃಢೀಕರಿಸಿ';

  @override
  String get showPasswords => 'ಪಾಸ್‌ವರ್ಡ್‌ಗಳನ್ನು ತೋರಿಸಿ';

  @override
  String get updatePasswordButton => 'ಪಾಸ್‌ವರ್ಡ್ ಅಪ್‌ಡೇಟ್ ಮಾಡಿ';

  @override
  String get stepAddName => 'ನಿಮ್ಮ ಹೆಸರು ಸೇರಿಸಿ';

  @override
  String get stepAddEmail => 'ನಿಮ್ಮ ಇಮೇಲ್ ಸೇರಿಸಿ';

  @override
  String get stepPickTradition => 'ಹೋಮ್‌ನಲ್ಲಿ ನಿಮ್ಮ ಸಂಪ್ರದಾಯವನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get stepTurnOnReminder => 'ದೈನಂದಿನ ಜ್ಞಾಪನೆ ಆನ್ ಮಾಡಿ';

  @override
  String get stepStartPlan => 'ಒಂದು ಪಾಠ ಅಥವಾ ಮಂತ್ರ ಯೋಜನೆ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get profileCompletionTitle => 'ಪ್ರೊಫೈಲ್ ಪೂರ್ಣಗೊಳಿಕೆ';

  @override
  String get profileCompleteReward =>
      'ಪ್ರೊಫೈಲ್ ಪೂರ್ಣಗೊಂಡಿದೆ! ಪ್ರೀಮಿಯಂ ಬಿಡುಗಡೆಯಾದಾಗ ನಿಮ್ಮ ಉಚಿತ ಪ್ರೀಮಿಯಂ ಬಹುಮಾನ ಕಾಯುತ್ತಿರುತ್ತದೆ.';

  @override
  String get reachRewardNote => 'ಬಿಡುಗಡೆಯಾದಾಗ ಉಚಿತ ಪ್ರೀಮಿಯಂ ಪಡೆಯಲು 100% ತಲುಪಿ.';

  @override
  String get aboutTitle => 'ಬಗ್ಗೆ';

  @override
  String get appLabel => 'ಆ್ಯಪ್';

  @override
  String get websiteLabel => 'ವೆಬ್‌ಸೈಟ್';

  @override
  String get versionLabel => 'ಆವೃತ್ತಿ';

  @override
  String get passwordWillWorkLater =>
      'ಖಾತೆಗಳನ್ನು ಸೇರಿಸಿದ ನಂತರ ಪಾಸ್‌ವರ್ಡ್ ಬದಲಾವಣೆ ಕಾರ್ಯನಿರ್ವಹಿಸುತ್ತದೆ.';

  @override
  String get signedOut => 'ಸೈನ್ ಔಟ್ ಆಗಿದೆ';

  @override
  String get notSignedInYet =>
      'ನೀವು ಇನ್ನೂ ಸೈನ್ ಇನ್ ಆಗಿಲ್ಲ: ಖಾತೆಗಳು ನಂತರದ ಹಂತದಲ್ಲಿ ಬರುತ್ತವೆ. ನಿಮ್ಮ ಡೇಟಾ ಈ ಫೋನ್‌ನಲ್ಲಿಯೇ ಇರುತ್ತದೆ.';

  @override
  String get accountTitle => 'ಖಾತೆ';

  @override
  String get signOutButton => 'ಸೈನ್ ಔಟ್ ಮಾಡಿ';

  @override
  String get backupSaved => 'ಬ್ಯಾಕಪ್ ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get backupCancelled => 'ಬ್ಯಾಕಪ್ ರದ್ದುಗೊಳಿಸಲಾಗಿದೆ';

  @override
  String get couldNotSaveBackup => 'ಬ್ಯಾಕಪ್ ಉಳಿಸಲಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get backupNotSadho => 'ಆ ಫೈಲ್ Sadho ಬ್ಯಾಕಪ್ ಅಲ್ಲ.';

  @override
  String get couldNotReadFile => 'ಆ ಫೈಲ್ ಓದಲಾಗಲಿಲ್ಲ.';

  @override
  String get backupDamaged => 'ಬ್ಯಾಕಪ್ ಫೈಲ್ ಹಾಳಾಗಿದೆ.';

  @override
  String get backupTooNew =>
      'ಈ ಬ್ಯಾಕಪ್ ಅನ್ನು Sadho ಯ ಹೊಸ ಆವೃತ್ತಿಯಿಂದ ರಚಿಸಲಾಗಿದೆ. ಮೊದಲು ಆ್ಯಪ್ ಅಪ್‌ಡೇಟ್ ಮಾಡಿ.';

  @override
  String get backupNoData => 'ಆ ಬ್ಯಾಕಪ್‌ನಲ್ಲಿ Sadho ಡೇಟಾ ಇಲ್ಲ.';

  @override
  String get backupTooBig => 'ಆ ಫೈಲ್ Sadho ಬ್ಯಾಕಪ್ ಆಗಿರಲು ತುಂಬಾ ದೊಡ್ಡದಾಗಿದೆ.';

  @override
  String madeOnSuffix(String date) {
    return ' $date ರಂದು ರಚಿಸಲಾಗಿದೆ';
  }

  @override
  String restoreBackupBody(String made, int count) {
    return 'ಒಂದು ಬ್ಯಾಕಪ್$made ಇದರಲ್ಲಿ $count ಉಳಿಸಿದ ವಸ್ತುಗಳಿವೆ. ಇದು ಈ ಫೋನ್‌ನಲ್ಲಿರುವುದನ್ನು ಬದಲಾಯಿಸುತ್ತದೆ: ಗುರುತುಗಳು, ಯೋಜನೆಗಳು, ಮಂತ್ರಗಳು, ಧ್ವನಿ ತರಬೇತಿ ಮತ್ತು ಸೆಟ್ಟಿಂಗ್‌ಗಳು.';
  }

  @override
  String get restoreThisBackup => 'ಈ ಬ್ಯಾಕಪ್ ಅನ್ನು ಮರುಸ್ಥಾಪಿಸುವುದೇ?';

  @override
  String get backupRestoredTitle => 'ಬ್ಯಾಕಪ್ ಮರುಸ್ಥಾಪಿಸಲಾಗಿದೆ';

  @override
  String get backupRestoredBody =>
      'ನಿಮ್ಮ ಮರುಸ್ಥಾಪಿಸಿದ ಡೇಟಾದೊಂದಿಗೆ Sadho ಮತ್ತೆ ಲೋಡ್ ಆಗುತ್ತದೆ.';

  @override
  String get backupRestoreTitle => 'ಬ್ಯಾಕಪ್ ಮತ್ತು ಮರುಸ್ಥಾಪನೆ';

  @override
  String get backupExplain =>
      'ನಿಮ್ಮ ಗುರುತುಗಳು, ಯೋಜನೆಗಳು, ಮಂತ್ರಗಳು, ಧ್ವನಿ ತರಬೇತಿ ಮತ್ತು ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ನೀವು ಆಯ್ಕೆಮಾಡುವ ಫೈಲ್‌ಗೆ ಉಳಿಸಿ (Drive, Files, ನಿಮಗೇ ಇಮೇಲ್ ಮಾಡಿ). ಇದನ್ನು ಈ ಅಥವಾ ಇನ್ನೊಂದು ಫೋನ್‌ನಲ್ಲಿ ಮರುಸ್ಥಾಪಿಸಿ.';

  @override
  String get exportButton => 'ರಫ್ತು';

  @override
  String get restoreButton => 'ಮರುಸ್ಥಾಪಿಸಿ';

  @override
  String get cloudSyncTitle => 'ಕ್ಲೌಡ್ ಸಿಂಕ್';

  @override
  String get comingLater => 'ನಂತರ ಬರುತ್ತದೆ';

  @override
  String get saveBackupDialogTitle => 'ನಿಮ್ಮ Sadho ಬ್ಯಾಕಪ್ ಉಳಿಸಿ';

  @override
  String get chooseBackupDialogTitle => 'ಒಂದು Sadho ಬ್ಯಾಕಪ್ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get areYouSure => 'ನೀವು ಖಚಿತವಾಗಿದ್ದೀರಾ?';

  @override
  String get deleteAccountWarning =>
      'ಇದು ನಿಮ್ಮ ಖಾತೆ ಮತ್ತು ಈ ಫೋನ್‌ನಲ್ಲಿ ಉಳಿಸಿದ ಎಲ್ಲವನ್ನೂ ಅಳಿಸುತ್ತದೆ: ನಿಮ್ಮ ಪ್ರೊಫೈಲ್, ಗುರುತುಗಳು, ಯೋಜನೆಗಳು, ಮಂತ್ರಗಳು, ಧ್ವನಿ ತರಬೇತಿ ಮತ್ತು ಸೆಟ್ಟಿಂಗ್‌ಗಳು. ಇದನ್ನು ರದ್ದುಗೊಳಿಸಲಾಗುವುದಿಲ್ಲ.';

  @override
  String get yesAction => 'ಹೌದು';

  @override
  String get noAction => 'ಇಲ್ಲ';

  @override
  String get dangerZoneTitle => 'ಅಪಾಯ ವಲಯ';

  @override
  String get deleteAccountExplain =>
      'ನಿಮ್ಮ ಖಾತೆಯನ್ನು ಅಳಿಸುವುದರಿಂದ ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಮತ್ತು ಈ ಫೋನ್‌ನಲ್ಲಿ ಉಳಿಸಿದ ಎಲ್ಲವೂ ಅಳಿಸಿಹೋಗುತ್ತದೆ. ನಿಮಗೆ ಅದು ಮತ್ತೆ ಬೇಕಾದರೆ ಮೊದಲು ಬ್ಯಾಕಪ್ ರಫ್ತು ಮಾಡಿ.';

  @override
  String get deleteAccountButton => 'ಖಾತೆ ಅಳಿಸಿ';

  @override
  String get profileSaved => 'ಪ್ರೊಫೈಲ್ ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get yourDetailsTitle => 'ನಿಮ್ಮ ವಿವರಗಳು';

  @override
  String get nameLabel => 'ಹೆಸರು';

  @override
  String get emailLabel => 'ಇಮೇಲ್';

  @override
  String get dailyReminderTitle => 'ದೈನಂದಿನ ಜ್ಞಾಪನೆ';

  @override
  String get dailySadhanaReminder => 'ದೈನಂದಿನ ಸಾಧನೆ ಜ್ಞಾಪನೆ';

  @override
  String get reminderOff => 'ಆಫ್';

  @override
  String everyDayAt(String time) {
    return 'ಪ್ರತಿದಿನ $time ಕ್ಕೆ';
  }

  @override
  String get allowNotificationsForReminder =>
      'ಜ್ಞಾಪನೆ ಮೊಳಗಲು ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಅಧಿಸೂಚನೆಗಳನ್ನು ಆನ್ ಮಾಡಿ.';

  @override
  String get timeLabel => 'ಸಮಯ';

  @override
  String get themeTitle => 'ಥೀಮ್';

  @override
  String get lightMode => 'ಲೈಟ್';

  @override
  String get darkMode => 'ಡಾರ್ಕ್';

  @override
  String get systemMode => 'ಸಿಸ್ಟಮ್';

  @override
  String get coloursTitle => 'ಬಣ್ಣಗಳು';

  @override
  String paletteSemantic(String name) {
    return '$name ಬಣ್ಣಗಳು';
  }

  @override
  String get paletteMarigoldName => 'ಚೆಂಡು ಹೂ';

  @override
  String get paletteMarigoldBlurb => 'ಬೆಚ್ಚಗಿನ ಕೇಸರಿ ಮತ್ತು ಆಳವಾದ ಇಂಡಿಗೋ';

  @override
  String get paletteSandalwoodName => 'ಶ್ರೀಗಂಧ';

  @override
  String get paletteSandalwoodBlurb => 'ಮೃದುವಾದ ಶ್ರೀಗಂಧ ಕಂದು ಮತ್ತು ಮಣ್ಣಿನ ಬಣ್ಣ';

  @override
  String get paletteTulsiName => 'ತುಳಸಿ ಹಸಿರು';

  @override
  String get paletteTulsiBlurb => 'ಶಾಂತ ಪವಿತ್ರ-ತುಳಸಿ ಹಸಿರು';

  @override
  String get paletteTwilightName => 'ಸಂಧ್ಯಾ ಇಂಡಿಗೋ';

  @override
  String get paletteTwilightBlurb => 'ದೀಪ-ಹೊಳಪಿನ ಚಿನ್ನದೊಂದಿಗೆ ಸಂಧ್ಯಾ ಇಂಡಿಗೋ';

  @override
  String get paletteLotusName => 'ಕಮಲ ಗುಲಾಬಿ';

  @override
  String get paletteLotusBlurb => 'ಮೃದುವಾದ ಕಮಲ ಗುಲಾಬಿ ಮತ್ತು ಎಲೆ ಹಸಿರು';

  @override
  String get sadhanaTimeNotifTitle => '🪔 ನಿಮ್ಮ ಸಾಧನೆಯ ಸಮಯ';

  @override
  String get sadhanaTimeNotifBody =>
      'ನಿಮ್ಮ ಪಾಠ ಅಥವಾ ಮಂತ್ರಕ್ಕಾಗಿ ಕೆಲವು ಶಾಂತ ನಿಮಿಷಗಳನ್ನು ತೆಗೆದುಕೊಳ್ಳಿ 🙏';

  @override
  String get comingSoon => 'ಶೀಘ್ರದಲ್ಲೇ ಬರುತ್ತಿದೆ';

  @override
  String get trainAction => 'ತರಬೇತಿಗೊಳಿಸಿ';

  @override
  String get onboardingTitle => 'Sadho ಗೆ ಸ್ವಾಗತ';

  @override
  String get onboardingSubtitle =>
      'ಪ್ರಾರಂಭಿಸಲು ನಿಮ್ಮ ಭಾಷೆ ಮತ್ತು ಸಂಪ್ರದಾಯವನ್ನು ಆಯ್ಕೆಮಾಡಿ. ನೀವು ಎರಡನ್ನೂ ನಂತರ ಪ್ರೊಫೈಲ್‌ನಲ್ಲಿ ಬದಲಾಯಿಸಬಹುದು.';

  @override
  String get traditionHeading => 'ಸಂಪ್ರದಾಯ';

  @override
  String get continueAction => 'ಮುಂದುವರಿಸಿ';

  @override
  String get stopAlert => 'ನಿಲ್ಲಿಸಿ';

  @override
  String get repeatLabel => 'ಪುನರಾವರ್ತನೆ';

  @override
  String get repeatOnce => 'ಒಮ್ಮೆ';

  @override
  String soundRepeatTimes(int times) {
    return '$times ಬಾರಿ';
  }

  @override
  String get repeatUntilStopped => 'ನಿಲ್ಲಿಸುವವರೆಗೆ';

  @override
  String vibrationRepeatUntilStopped(int seconds) {
    return 'ಪ್ರತಿ $seconds ಸೆಕೆಂಡಿಗೆ, ನಿಲ್ಲಿಸುವವರೆಗೆ';
  }

  @override
  String get keepScreenOnLabel => 'ಎಣಿಸುವಾಗ ಪರದೆಯನ್ನು ಆನ್ ಇರಿಸಿ';

  @override
  String get keepScreenOnSubtitle =>
      'ಸೆಷನ್ ನಡೆಯುವಾಗ ಪರದೆ ನಿದ್ರಿಸುವುದಿಲ್ಲ. ಪವರ್ ಬಟನ್ ಈಗಲೂ ಫೋನ್ ಲಾಕ್ ಮಾಡುತ್ತದೆ; ಆಗ ಸಮಯ ಅಥವಾ ಲಯದ ಸೆಷನ್ ಮುಗಿದಾಗ ಅಲಾರಂನಂತೆ ಮೊಳಗುತ್ತದೆ.';

  @override
  String get alarmMayBeLate =>
      'ಅಲಾರಂ ಸ್ವಲ್ಪ ತಡವಾಗಿ ಮೊಳಗಬಹುದು (ನಿಖರ ಅಲಾರಂಗಳು ಆಫ್ ಆಗಿವೆ).';

  @override
  String get exactAlarmNotice =>
      'ಪರದೆ ಆಫ್ ಆಗಿದ್ದರೂ ಸರಿಯಾದ ಸಮಯಕ್ಕೆ ಮೊಳಗಲು, Sadho ಗೆ ನಿಖರ ಅಲಾರಂಗಳನ್ನು ಅನುಮತಿಸಿ.';

  @override
  String get fullScreenNotice =>
      'ಮುಗಿದ ಸೆಷನ್ ಅನ್ನು ಲಾಕ್ ಪರದೆಯ ಮೇಲೆ ತೋರಿಸಲು, ಪೂರ್ಣ-ಪರದೆ ಎಚ್ಚರಿಕೆಗಳನ್ನು ಅನುಮತಿಸಿ.';

  @override
  String get allowAction => 'ಅನುಮತಿಸಿ';

  @override
  String channelSadhanaAlarmName(String sound) {
    return 'ಸಾಧನಾ ಅಲಾರಂ · $sound';
  }

  @override
  String get channelSadhanaAlarmSilentName => 'ಸಾಧನಾ ಅಲಾರಂ · ಮೌನ';

  @override
  String get channelNoVibration => 'ಕಂಪನ ಇಲ್ಲ';

  @override
  String get channelSadhanaAlarmDesc => 'ಸಮಯ ಅಥವಾ ಲಯದ ಸೆಷನ್ ಮುಗಿದಾಗ ಮೊಳಗುತ್ತದೆ';

  @override
  String get alarmScreenSadhanaTitle => 'ಸಾಧನೆ ಪೂರ್ಣ 🙏';

  @override
  String get alarmScreenTimerTitle => 'ಟೈಮರ್ ಮುಗಿಯಿತು';

  @override
  String get alarmScreenSunTitle => 'ಸೂರ್ಯ ಅಲಾರಂ';

  @override
  String get alarmScreenUnlock => 'Sadho ತೆರೆಯಲು ಅನ್‌ಲಾಕ್ ಮಾಡಿ';

  @override
  String get alarmScreenUnlockHint =>
      'ಆ್ಯಪ್‌ನ ಉಳಿದ ಭಾಗಕ್ಕೆ ಫೋನ್ ಅನ್‌ಲಾಕ್ ಆಗಿರಬೇಕು.';

  @override
  String get alarmsReliabilityTitle => 'ಅಲಾರಂಗಳು & ವಿಶ್ವಾಸಾರ್ಹತೆ';

  @override
  String get alarmsReliabilityIntro =>
      'ಪರದೆ ಆಫ್ ಆಗಿದ್ದರೂ ಅಲಾರಂಗಳು ಸಮಯಕ್ಕೆ ಮೊಳಗಲು, ಫೋನ್ ಇವುಗಳನ್ನು ಅನುಮತಿಸಬೇಕು. ಸರಿಪಡಿಸಿ ಸರಿಯಾದ ಸೆಟ್ಟಿಂಗ್‌ಗಳ ಪುಟ ತೆರೆಯುತ್ತದೆ.';

  @override
  String get alarmsReliabilityAllOk => 'ಅಲಾರಂಗಳು ಸಮಯಕ್ಕೆ ಮೊಳಗಲು ಎಲ್ಲವೂ ಸಿದ್ಧ';

  @override
  String get alarmsReliabilityAttention => 'ಏನೋ ಗಮನ ಬೇಕಾಗಿದೆ';

  @override
  String get healthOk => 'ಸರಿ';

  @override
  String get healthNeedsAttention => 'ಗಮನ ಬೇಕು';

  @override
  String get healthFix => 'ಸರಿಪಡಿಸಿ';

  @override
  String get healthNotificationsTitle => 'ಅಧಿಸೂಚನೆಗಳಿಗೆ ಅನುಮತಿ';

  @override
  String get healthNotificationsBody =>
      'ಅಲಾರಂಗಳು ಮತ್ತು ಜ್ಞಾಪನೆಗಳು ಅಧಿಸೂಚನೆಗಳಾಗಿ ಬರುತ್ತವೆ.';

  @override
  String get healthExactTitle => 'ನಿಖರ ಅಲಾರಂಗಳಿಗೆ ಅನುಮತಿ';

  @override
  String get healthExactBody => 'ಅದೇ ಸೆಕೆಂಡಿನಲ್ಲಿ ಮೊಳಗುತ್ತದೆ, ತಡವಾಗಿ ಅಲ್ಲ.';

  @override
  String get healthFullScreenTitle => 'ಲಾಕ್ ಪರದೆಯ ಮೇಲೆ ಅಲಾರಂಗಳನ್ನು ತೋರಿಸಿ';

  @override
  String get healthFullScreenBody =>
      'ಫೋನ್ ಲಾಕ್ ಆಗಿದ್ದರೂ ಮುಗಿದ ಅಲಾರಂ ಕಾಣಿಸುತ್ತದೆ.';

  @override
  String get healthBatteryTitle => 'ಬ್ಯಾಟರಿ: ಆ್ಯಪ್ ನಿರ್ಬಂಧಿತವಲ್ಲ';

  @override
  String get healthBatteryBody =>
      'ಬ್ಯಾಟರಿಯಲ್ಲಿ ಅನಿರ್ಬಂಧಿತ ಆಯ್ಕೆಮಾಡಿ (ಕನಿಷ್ಠ ನಿರ್ಬಂಧಿತವಲ್ಲ), ಆಗ ಫೋನ್ ಅಲಾರಂಗಳನ್ನು ತಡೆಯುವುದಿಲ್ಲ.';

  @override
  String get healthBatterySamsungHint =>
      'Samsung: ಸೆಟ್ಟಿಂಗ್‌ಗಳು › ಬ್ಯಾಟರಿ › ಹಿನ್ನೆಲೆ ಬಳಕೆ ಮಿತಿಗಳಲ್ಲಿ, Sadho ಅನ್ನು “ಸ್ಲೀಪಿಂಗ್ ಆ್ಯಪ್‌ಗಳು” ಮತ್ತು “ಡೀಪ್ ಸ್ಲೀಪಿಂಗ್ ಆ್ಯಪ್‌ಗಳು” ನಿಂದ ತೆಗೆದುಹಾಕಿ, ಬ್ಯಾಟರಿ ಬಳಕೆಯನ್ನು “ಅನಿರ್ಬಂಧಿತ” ಮಾಡಿ.';

  @override
  String get alarmExplainerOk =>
      'ಈ ಸೆಷನ್ ಮುಗಿದಾಗ ಅಲಾರಂನಂತೆ ಮೊಳಗುತ್ತದೆ, ಪರದೆ ಅಥವಾ ಆ್ಯಪ್ ಮುಚ್ಚಿದ್ದರೂ.';

  @override
  String get alarmExplainerAttention =>
      'ಈ ಸೆಷನ್ ಮುಗಿದಾಗ ಅಲಾರಂನಂತೆ ಮೊಳಗುತ್ತದೆ, ಆದರೆ ಸಮಯಕ್ಕೆ ಮೊಳಗಲು ಫೋನ್‌ನ ಒಂದು ಸೆಟ್ಟಿಂಗ್ ಬದಲಿಸಬೇಕು.';

  @override
  String get alarmExplainerCheck => 'ಪರಿಶೀಲಿಸಿ';

  @override
  String get customTimerName => 'ಕಸ್ಟಮ್ ಟೈಮರ್';

  @override
  String customChipLabel(String duration) {
    return 'ಕಸ್ಟಮ್ · $duration';
  }

  @override
  String get customTimerTitle => 'ನಿಮ್ಮ ಅವಧಿ';

  @override
  String get customTimerRange => '1 ಸೆಕೆಂಡಿನಿಂದ 24 ಗಂಟೆಗಳವರೆಗೆ ಆರಿಸಿ.';

  @override
  String durationHours(int hours) {
    return '$hours ಗಂ';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes ನಿ';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds ಸೆ';
  }

  @override
  String collapseSection(String section) {
    return '$section ಮರೆಮಾಡಿ';
  }

  @override
  String expandSection(String section) {
    return '$section ತೋರಿಸಿ';
  }

  @override
  String get summaryVibrationOn => 'ಕಂಪನ ಆನ್';

  @override
  String get summaryVibrationOff => 'ಕಂಪನ ಆಫ್';

  @override
  String get summarySoundOff => 'ಧ್ವನಿ ಆಫ್';

  @override
  String get summaryNotSet => 'ನಿಗದಿಸಿಲ್ಲ';

  @override
  String get clockToolNotepadTitle => 'ನೋಟ್‌ಪ್ಯಾಡ್';

  @override
  String get clockToolNotepadSubtitle => 'ಟಿಪ್ಪಣಿಗಳು, ಈ ಫೋನ್‌ನಲ್ಲೇ';

  @override
  String get notesSearchHint => 'ಟಿಪ್ಪಣಿಗಳನ್ನು ಹುಡುಕಿ';

  @override
  String get notesEmpty => 'ಇನ್ನೂ ಟಿಪ್ಪಣಿಗಳಿಲ್ಲ. ಬರೆಯಲು + ಒತ್ತಿ.';

  @override
  String notesNoMatch(String query) {
    return '“$query” ಗೆ ಹೊಂದುವ ಟಿಪ್ಪಣಿ ಇಲ್ಲ.';
  }

  @override
  String get noteNew => 'ಹೊಸ ಟಿಪ್ಪಣಿ';

  @override
  String get noteEdit => 'ಟಿಪ್ಪಣಿ';

  @override
  String get noteTitleHint => 'ಶೀರ್ಷಿಕೆ (ಐಚ್ಛಿಕ)';

  @override
  String get noteTextHint => 'ಇಲ್ಲಿ ಬರೆಯಿರಿ…';

  @override
  String get noteUntitled => 'ಖಾಲಿ ಟಿಪ್ಪಣಿ';

  @override
  String noteCreatedAt(String when) {
    return 'ರಚಿಸಿದ್ದು $when';
  }

  @override
  String noteEditedAt(String when) {
    return 'ಬದಲಿಸಿದ್ದು $when';
  }

  @override
  String get noteSavedAsYouType => 'ಬರೆಯುತ್ತಿದ್ದಂತೆ ಉಳಿಸಲಾಗುತ್ತದೆ';

  @override
  String get noteDelete => 'ಟಿಪ್ಪಣಿ ಅಳಿಸಿ';

  @override
  String get noteDeleteQuestion => 'ಈ ಟಿಪ್ಪಣಿಯನ್ನು ಅಳಿಸಬೇಕೆ?';

  @override
  String noteDeleteBody(String title) {
    return '“$title” ಈ ಫೋನ್‌ನಿಂದ ತೆಗೆದುಹಾಕಲಾಗುತ್ತದೆ. ಇದನ್ನು ಮರಳಿ ಪಡೆಯಲಾಗದು.';
  }

  @override
  String get paletteHighContrastName => 'ಹೆಚ್ಚಿನ ಕಾಂಟ್ರಾಸ್ಟ್';

  @override
  String get paletteHighContrastBlurb => 'ಅತಿ ಹೆಚ್ಚಿನ ವ್ಯತ್ಯಾಸ, ಸುಲಭ ಓದಿಗಾಗಿ';

  @override
  String get malaNotificationChannel => 'ಮಾಲೆ ಕೌಂಟರ್';

  @override
  String malaNotificationTitle(String count, String target) {
    return 'ಮಾಲೆ · $count / $target';
  }

  @override
  String malaNotificationTitleCount(String count) {
    return 'ಮಾಲೆ · $count';
  }

  @override
  String get malaNotificationRunning =>
      'ಎಣಿಸಲು ವಾಲ್ಯೂಮ್ ಕೀ ಒತ್ತಿ, ಪರದೆ ಆಫ್ ಆಗಿದ್ದರೂ.';

  @override
  String get malaNotificationDone => 'ಗುರಿ ಪೂರ್ಣ 🙏';

  @override
  String get malaRingTitle => '🔔 ಮಾಲೆ ಪೂರ್ಣ';

  @override
  String malaRingBody(int target) {
    return 'ನೀವು $target ಗುರಿಯನ್ನು ತಲುಪಿದಿರಿ 🙏';
  }

  @override
  String get malaScreenOffUnavailable =>
      'ಈ ಫೋನ್‌ನಲ್ಲಿ ಪರದೆ ಆಫ್ ಆಗಿರುವಾಗ ಎಣಿಕೆ ಪ್ರಾರಂಭವಾಗಲಿಲ್ಲ. Sadho ತೆರೆದಿರುವಾಗ ಮಾತ್ರ ವಾಲ್ಯೂಮ್ ಕೀಗಳು ಎಣಿಸುತ್ತವೆ.';

  @override
  String get pressVolumeKeysScreenOff =>
      'ಪರದೆ ಆಫ್ ಆಗಿದ್ದರೂ ವಾಲ್ಯೂಮ್ ಕೀಗಳು ಎಣಿಸುತ್ತವೆ';

  @override
  String get malaScreenOffLabel => 'ಪರದೆ ಆಫ್ ಆಗಿದ್ದರೂ ಎಣಿಸಿ';

  @override
  String get malaScreenOffOnSubtitle =>
      'ಫೋನ್ ಲಾಕ್ ಮಾಡಿ ವಾಲ್ಯೂಮ್ ಕೀ ಒತ್ತುತ್ತಿರಿ. ಒಂದು ಅಧಿಸೂಚನೆ ಎಣಿಕೆಯನ್ನು ತೋರಿಸಿ ಗುರಿಯಲ್ಲಿ ರಿಂಗ್ ಆಗುತ್ತದೆ.';

  @override
  String get malaScreenOffOffSubtitle =>
      'ಆಫ್: Sadho ತೆರೆದಿದ್ದು ಪರದೆ ಆನ್ ಆಗಿರುವಾಗ ಮಾತ್ರ ವಾಲ್ಯೂಮ್ ಕೀಗಳು ಎಣಿಸುತ್ತವೆ.';

  @override
  String get modeHelpMalaScreenOff =>
      'Start ಒತ್ತಿ, ನಂತರ ಎಣಿಸಲು ಯಾವುದೇ ವಾಲ್ಯೂಮ್ ಕೀ ಒತ್ತಿ, ಫೋನ್ ಲಾಕ್ ಆಗಿ ಪರದೆ ಆಫ್ ಆಗಿದ್ದರೂ. ಕಣ್ಣು ಮುಚ್ಚಿ ಅಥವಾ ಫೋನ್ ಜೇಬಿನಲ್ಲಿದ್ದಾಗ ಅನುಕೂಲಕರ.';

  @override
  String get malaScreenOffExplainer =>
      'ಫೋನ್ ಲಾಕ್ ಮಾಡಿ, ಎಣಿಸಲು ವಾಲ್ಯೂಮ್ ಕೀ ಒತ್ತಿ. ಬ್ಯಾಟರಿ \'ಅನಿರ್ಬಂಧಿತ\' ಮಾಡಿ.';

  @override
  String get calibrateTitle => 'ಧ್ವನಿ ಮಾಪನ ಮಾಡಿ';

  @override
  String calibrateIntro(int count) {
    return 'ನಿಮ್ಮ ಮಂತ್ರವನ್ನು ಎಂದಿನಂತೆ $count ಬಾರಿ ಜಪಿಸಿ, ಪ್ರತಿಯೊಂದರ ನಂತರ ಸ್ವಲ್ಪ ನಿಲ್ಲಿಸಿ. ನಂತರ Sadho ಧ್ವನಿ ಎಷ್ಟು ಕಟ್ಟುನಿಟ್ಟಾಗಿರಬೇಕು ಎಂದು ಹೊಂದಿಸುತ್ತದೆ, ಎಲ್ಲವೂ ಎಣಿಕೆಯಾಗುವಂತೆ, ಕೋಣೆಯ ಶಬ್ದ ಅಲ್ಲ. ಏನನ್ನೂ ರೆಕಾರ್ಡ್ ಮಾಡುವುದಿಲ್ಲ ಅಥವಾ ಇಡುವುದಿಲ್ಲ.';
  }

  @override
  String calibrateChantNow(int count) {
    return 'ಈಗ ನಿಮ್ಮ ಮಂತ್ರವನ್ನು $count ಬಾರಿ ಜಪಿಸಿ';
  }

  @override
  String calibrateHeard(int heard, int count) {
    return '$count ರಲ್ಲಿ $heard ಕೇಳಿಸಿತು';
  }

  @override
  String calibrateSkipped(int count) {
    return 'ಒಂದು ಜಪವಲ್ಲದ $count ಶಬ್ದಗಳನ್ನು ಬಿಡಲಾಗಿದೆ';
  }

  @override
  String get calibrateDone => 'ಮಾಪನ ಆಯಿತು';

  @override
  String calibrateDoneBody(int count) {
    return 'ಎಲ್ಲಾ $count ಜಪಗಳು ಎಣಿಕೆಯಾಗುತ್ತವೆ; ಕೋಣೆಯ ಶಬ್ದ ಅಲ್ಲ.';
  }

  @override
  String get calibrateStart => 'ಮಾಪನ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get calibrateSave => 'ಮಾಪನ ಉಳಿಸಿ';

  @override
  String calibrationSaved(String mantra) {
    return '“$mantra” ಗಾಗಿ ಮಾಪನ ಉಳಿಸಲಾಗಿದೆ';
  }

  @override
  String get calibrateVoice => 'ಮಾಪನ ಮಾಡಿ';

  @override
  String get recalibrateVoice => 'ಮತ್ತೆ ಮಾಪನ ಮಾಡಿ';

  @override
  String get quietModeLabel => 'ಅವಧಿಯಲ್ಲಿ ಇತರ ಅಧಿಸೂಚನೆಗಳನ್ನು ನಿಶ್ಯಬ್ದಗೊಳಿಸಿ';

  @override
  String get quietModeSubtitle =>
      'ಅವಧಿ ನಡೆಯುವಾಗ \'ಅಡಚಣೆ ಮಾಡಬೇಡಿ\' (ಅಲಾರಾಂ ಮಾತ್ರ) ಆನ್ ಮಾಡುತ್ತದೆ, ಆದ್ದರಿಂದ Sadho ಅಲಾರಾಂ ರಿಂಗ್ ಆಗುತ್ತದೆ. ನಂತರ ನಿಮ್ಮ ಸ್ವಂತ ಸೆಟ್ಟಿಂಗ್ ಮರಳುತ್ತದೆ.';

  @override
  String get quietModeAccessTitle => '\'ಅಡಚಣೆ ಮಾಡಬೇಡಿ\' ಪ್ರವೇಶ ಅನುಮತಿಸಿ';

  @override
  String get quietModeAccessBody =>
      'ಸಾಧನೆಯ ವೇಳೆ ಇತರ ಅಧಿಸೂಚನೆಗಳನ್ನು ನಿಶ್ಯಬ್ದಗೊಳಿಸಲು Sadho ಗೆ \'ಅಡಚಣೆ ಮಾಡಬೇಡಿ\' ಪ್ರವೇಶ ಬೇಕು. ಮುಂದಿನ ಪರದೆಯಲ್ಲಿ Sadho ಹುಡುಕಿ ಅನುಮತಿಸಿ. ಅವಧಿ ನಡೆಯುವಾಗ ಮಾತ್ರ Sadho \'ಅಲಾರಾಂ ಮಾತ್ರ\' ಮೋಡ್ ಆನ್ ಮಾಡಿ, ನಂತರ ನಿಮ್ಮ ಸೆಟ್ಟಿಂಗ್ ಮರಳಿಸುತ್ತದೆ.';

  @override
  String get healthDndTitle => '\'ಅಡಚಣೆ ಮಾಡಬೇಡಿ\' ಪ್ರವೇಶ';

  @override
  String get healthDndBody =>
      'ಅವಧಿಯಲ್ಲಿ ಇತರ ಅಧಿಸೂಚನೆಗಳನ್ನು ನಿಶ್ಯಬ್ದಗೊಳಿಸಲು ಅಗತ್ಯ. ಇದಿಲ್ಲದೆ Sadho \'ಅಡಚಣೆ ಮಾಡಬೇಡಿ\' ಅನ್ನು ಮುಟ್ಟುವುದಿಲ್ಲ.';

  @override
  String get legalPrivacyPolicy => 'ಗೌಪ್ಯತಾ ನೀತಿ';

  @override
  String get legalTermsOfUse => 'ಬಳಕೆಯ ನಿಯಮಗಳು';

  @override
  String get legalContact => 'ಸಂಪರ್ಕ ಮತ್ತು ದೂರು';

  @override
  String get legalDeleteData => 'ನಿಮ್ಮ ಡೇಟಾ ಅಳಿಸಿ';

  @override
  String get legalLicenses => 'ಓಪನ್-ಸೋರ್ಸ್ ಪರವಾನಗಿಗಳು';

  @override
  String linkOpenFailed(String url) {
    return '$url ತೆರೆಯಲಾಗಲಿಲ್ಲ';
  }

  @override
  String onboardingLegalNotice(String terms, String privacy) {
    return 'ನಿಮ್ಮ ಸಾಧನೆ, ಕ್ಯಾಲೆಂಡರ್, ಧ್ವನಿ ತರಬೇತಿ ಮತ್ತು ಸ್ಥಳ ಈ ಫೋನ್‌ನಲ್ಲೇ ಇರುತ್ತವೆ. ಮುಂದುವರಿಯುವ ಮೂಲಕ ನೀವು $terms ಒಪ್ಪುತ್ತೀರಿ ಮತ್ತು $privacy ಓದಿದ್ದೀರಿ.';
  }

  @override
  String get channelSadhanaAlarmV2Name => 'ಸಾಧನಾ ಅಲಾರಂ';

  @override
  String get healthChannelTitle => 'ಅಲಾರಾಂ ಅಧಿಸೂಚನೆಗಳು: \'ಅಲರ್ಟ್\' ನಲ್ಲಿ ಇಡಿ';

  @override
  String get healthChannelBody =>
      '“ಸಾಧನಾ ಅಲಾರಾಂ” ಮತ್ತು “ಅಲಾರಾಂ ಮತ್ತು ಟೈಮರ್” ಅಧಿಸೂಚನೆಗಳು ಪರದೆಯ ಮೇಲೆ ಬರಬೇಕು, ಇಲ್ಲದಿದ್ದರೆ ಲಾಕ್ ಪರದೆಯ ಮೇಲೆ ಅಲಾರಾಂ ಪರದೆ ಕಾಣಿಸದು.';

  @override
  String get healthFixManualTitle => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ನೀವೇ ತೆರೆಯಿರಿ';

  @override
  String get healthFixManualBody =>
      'ಫೋನ್ ಈ ಪುಟವನ್ನು ತೆರೆಯಲಿಲ್ಲ. Samsung ಫೋನ್‌ನಲ್ಲಿ:\n1. ಸೆಟ್ಟಿಂಗ್‌ಗಳು › ಆ್ಯಪ್‌ಗಳು › Sadho ತೆರೆಯಿರಿ.\n2. ಅಧಿಸೂಚನೆಗಳು: ಅನುಮತಿಸಿ, ಮತ್ತು “ಸಾಧನಾ ಅಲಾರಾಂ”, “ಅಲಾರಾಂ ಮತ್ತು ಟೈಮರ್” ಅನ್ನು \'ಅಲರ್ಟ್\' ನಲ್ಲಿ ಇಡಿ.\n3. ಅಲಾರಾಂಗಳು ಮತ್ತು ಜ್ಞಾಪನೆಗಳು: ಅನುಮತಿಸಿ.\n4. ಬ್ಯಾಟರಿ: ನಿರ್ಬಂಧರಹಿತ.\n5. ಪೂರ್ಣ-ಪರದೆ ಅಧಿಸೂಚನೆಗಳು: ಸೆಟ್ಟಿಂಗ್‌ಗಳು › ಆ್ಯಪ್‌ಗಳು › ⋮ › ವಿಶೇಷ ಪ್ರವೇಶ › Sadho ಗೆ ಅನುಮತಿಸಿ.\n6. \'ಅಡಚಣೆ ಮಾಡಬೇಡಿ\' ಪ್ರವೇಶ: ಸೆಟ್ಟಿಂಗ್‌ಗಳು › ಅಧಿಸೂಚನೆಗಳು › ಅಡಚಣೆ ಮಾಡಬೇಡಿ › ಆ್ಯಪ್ ಪ್ರವೇಶ (ಶಾಂತ ಮೋಡ್‌ಗೆ ಮಾತ್ರ).';

  @override
  String get quietModeFailed => 'ಶಾಂತ ಮೋಡ್ \'ಅಡಚಣೆ ಮಾಡಬೇಡಿ\' ಆನ್ ಮಾಡಲಾಗಲಿಲ್ಲ';

  @override
  String get quietModeChip => 'ಶಾಂತ ಮೋಡ್ ಆನ್';

  @override
  String get voiceInputLevel => 'ಮೈಕ್ರೊಫೋನ್ ಮಟ್ಟ';

  @override
  String get voiceTrainedWithHeadset =>
      'ಇಯರ್‌ಫೋನ್‌ನಿಂದ ತರಬೇತಿ — ಫೋನ್ ಮೈಕ್‌ನಿಂದ ಮತ್ತೆ ತರಬೇತಿ ನೀಡಿ';

  @override
  String get voiceTrainedWithPhone =>
      'ಫೋನ್ ಮೈಕ್‌ನಿಂದ ತರಬೇತಿ — ಈ ಇಯರ್‌ಫೋನ್‌ನಿಂದ ಮತ್ತೆ ತರಬೇತಿ ನೀಡಿ';
}
