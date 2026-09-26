// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get navHome => 'ਹੋਮ';

  @override
  String get navSadhana => 'ਸਾਧਨਾ';

  @override
  String get navCalendar => 'ਕੈਲੰਡਰ';

  @override
  String get navClock => 'ਘੜੀ';

  @override
  String get tooltipLanguage => 'ਭਾਸ਼ਾ';

  @override
  String get tooltipProfile => 'ਪ੍ਰੋਫਾਈਲ';

  @override
  String get tooltipSwitchToLight => 'ਲਾਈਟ ਥੀਮ \'ਤੇ ਜਾਓ';

  @override
  String get tooltipSwitchToDark => 'ਡਾਰਕ ਥੀਮ \'ਤੇ ਜਾਓ';

  @override
  String get languageSheetTitle => 'ਭਾਸ਼ਾ';

  @override
  String get languageSheetSubtitle =>
      'ਤੁਹਾਡੀ ਚੋਣ ਸੰਭਾਲੀ ਜਾਂਦੀ ਹੈ ਅਤੇ ਤੁਰੰਤ ਲਾਗੂ ਹੁੰਦੀ ਹੈ।';

  @override
  String get actionCancel => 'ਰੱਦ ਕਰੋ';

  @override
  String get actionDelete => 'ਮਿਟਾਓ';

  @override
  String get actionSave => 'ਸੰਭਾਲੋ';

  @override
  String get actionReset => 'ਰੀਸੈੱਟ ਕਰੋ';

  @override
  String get actionEdit => 'ਸੋਧੋ';

  @override
  String get actionOk => 'ਠੀਕ ਹੈ';

  @override
  String get unitSeconds => 'ਸਕਿੰਟ';

  @override
  String get unitMinutes => 'ਮਿੰਟ';

  @override
  String get unitHours => 'ਘੰਟੇ';

  @override
  String get paceErrorEmpty => 'ਰਫ਼ਤਾਰ ਦਰਜ ਕਰੋ।';

  @override
  String get paceErrorNotNumber => 'ਇਹ ਇੱਕ ਨੰਬਰ ਨਹੀਂ ਹੈ।';

  @override
  String paceErrorTooFast(String min) {
    return 'ਬਹੁਤ ਤੇਜ਼। ਘੱਟੋ-ਘੱਟ $min ਹੈ।';
  }

  @override
  String paceErrorTooSlow(String max) {
    return 'ਬਹੁਤ ਹੌਲੀ। ਵੱਧ ਤੋਂ ਵੱਧ $max ਹੈ।';
  }

  @override
  String get modeTap => 'ਟੈਪ';

  @override
  String get modeRhythm => 'ਰਿਦਮ';

  @override
  String get modeVoice => 'ਆਵਾਜ਼';

  @override
  String get modeMala => 'ਮਾਲਾ';

  @override
  String get ringtoneTempleBell => 'ਮੰਦਿਰ ਦੀ ਘੰਟੀ';

  @override
  String get ringtoneSingingBowl => 'ਸਿੰਗਿੰਗ ਬਾਊਲ';

  @override
  String get ringtoneSoftChime => 'ਹਲਕੀ ਘੰਟੀ';

  @override
  String get ringtoneDeepGong => 'ਡੂੰਘਾ ਗੌਂਗ';

  @override
  String get msgVoiceUnsupported =>
      'ਆਵਾਜ਼ ਗਿਣਤੀ ਸਿਰਫ਼ Android ਅਤੇ iOS \'ਤੇ ਕੰਮ ਕਰਦੀ ਹੈ';

  @override
  String get msgVoiceNoMic => 'ਇਸ ਡਿਵਾਈਸ \'ਤੇ ਕੋਈ ਮਾਈਕ੍ਰੋਫ਼ੋਨ ਉਪਲਬਧ ਨਹੀਂ ਹੈ';

  @override
  String get msgMalaUnsupported =>
      'ਵਾਲੀਅਮ-ਕੀ ਗਿਣਤੀ ਲਈ ਇੱਕ ਅਸਲੀ ਡਿਵਾਈਸ ਚਾਹੀਦੀ ਹੈ';

  @override
  String trainFirstPrompt(int min, int max) {
    return 'ਪਹਿਲਾਂ ਇਸ ਮੰਤਰ ਲਈ ਆਪਣੀ ਆਵਾਜ਼ ਨੂੰ ਸਿਖਲਾਈ ਦਿਓ: ਇਸਨੂੰ $min ਤੋਂ $max ਵਾਰ ਰਿਕਾਰਡ ਕਰੋ।';
  }

  @override
  String get fallbackVoiceDenied =>
      'ਮਾਈਕ੍ਰੋਫ਼ੋਨ ਇਜਾਜ਼ਤ ਅਸਵੀਕਾਰ ਕੀਤੀ ਗਈ, ਇਸ ਲਈ ਆਵਾਜ਼ ਗਿਣਤੀ ਸੁਣ ਨਹੀਂ ਸਕਦੀ। ਟੈਪ ਮੋਡ ਵਰਤ ਰਹੇ ਹਾਂ।';

  @override
  String get fallbackVoiceBlocked =>
      'ਮਾਈਕ੍ਰੋਫ਼ੋਨ ਐਕਸੈਸ ਬਲੌਕ ਹੈ। ਆਵਾਜ਼ ਗਿਣਤੀ ਵਰਤਣ ਲਈ ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਇਜਾਜ਼ਤ ਦਿਓ। ਟੈਪ ਮੋਡ ਵਰਤ ਰਹੇ ਹਾਂ।';

  @override
  String get fallbackVoiceUnsupported =>
      'ਆਵਾਜ਼ ਗਿਣਤੀ ਸਿਰਫ਼ Android ਅਤੇ iOS \'ਤੇ ਕੰਮ ਕਰਦੀ ਹੈ। ਟੈਪ ਮੋਡ ਵਰਤ ਰਹੇ ਹਾਂ।';

  @override
  String get fallbackVoiceNoMic =>
      'ਇਸ ਡਿਵਾਈਸ \'ਤੇ ਕੋਈ ਮਾਈਕ੍ਰੋਫ਼ੋਨ ਉਪਲਬਧ ਨਹੀਂ ਹੈ। ਟੈਪ ਮੋਡ ਵਰਤ ਰਹੇ ਹਾਂ।';

  @override
  String get fallbackMalaUnsupported =>
      'ਵਾਲੀਅਮ-ਕੀ ਗਿਣਤੀ ਲਈ ਇੱਕ ਅਸਲੀ ਡਿਵਾਈਸ ਚਾਹੀਦੀ ਹੈ। ਟੈਪ ਮੋਡ ਵਰਤ ਰਹੇ ਹਾਂ।';

  @override
  String get sadhanaRingTitle => '🔔 ਸਾਧਨਾ ਦਾ ਸਮਾਂ ਪੂਰਾ ਹੋਇਆ';

  @override
  String get sadhanaRingBody => 'ਤੁਹਾਡੇ ਸੈਸ਼ਨ ਦਾ ਸਮਾਂ ਪੂਰਾ ਹੋ ਗਿਆ ਹੈ 🙏';

  @override
  String get voiceTooShort => 'ਇਹ ਬਹੁਤ ਛੋਟਾ ਸੀ। ਪੂਰਾ ਮੰਤਰ ਬੋਲੋ।';

  @override
  String get voiceRanTooLong =>
      'ਇਹ ਬਹੁਤ ਲੰਬਾ ਚੱਲਿਆ। ਮੰਤਰ ਇੱਕ ਵਾਰ ਬੋਲੋ, ਫਿਰ ਰੁਕੋ।';

  @override
  String get voiceSoundedDifferent =>
      'ਇਹ ਦੂਜਿਆਂ ਨਾਲੋਂ ਵੱਖਰਾ ਸੁਣਾਈ ਦਿੱਤਾ। ਇਸਨੂੰ ਉਸੇ ਤਰ੍ਹਾਂ ਦੁਬਾਰਾ ਬੋਲੋ।';

  @override
  String get voiceGotIt => 'ਸਮਝ ਗਏ। ਦੁਬਾਰਾ ਬੋਲੋ।';

  @override
  String get voiceDeniedShort =>
      'ਮਾਈਕ੍ਰੋਫ਼ੋਨ ਇਜਾਜ਼ਤ ਅਸਵੀਕਾਰ ਕੀਤੀ ਗਈ, ਇਸ ਲਈ ਆਵਾਜ਼ ਗਿਣਤੀ ਸੁਣ ਨਹੀਂ ਸਕਦੀ।';

  @override
  String get voiceBlockedShort =>
      'ਮਾਈਕ੍ਰੋਫ਼ੋਨ ਐਕਸੈਸ ਬਲੌਕ ਹੈ। ਆਵਾਜ਼ ਗਿਣਤੀ ਵਰਤਣ ਲਈ ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਇਜਾਜ਼ਤ ਦਿਓ।';

  @override
  String get voiceAccessLost =>
      'ਮਾਈਕ੍ਰੋਫ਼ੋਨ ਐਕਸੈਸ ਖਤਮ ਹੋ ਗਈ, ਇਸ ਲਈ ਆਵਾਜ਼ ਗਿਣਤੀ ਰੁਕ ਗਈ।';

  @override
  String get voiceCouldNotRestart =>
      'ਮਾਈਕ੍ਰੋਫ਼ੋਨ ਮੁੜ ਸ਼ੁਰੂ ਨਹੀਂ ਹੋ ਸਕਿਆ, ਇਸ ਲਈ ਆਵਾਜ਼ ਗਿਣਤੀ ਰੁਕ ਗਈ।';

  @override
  String get mantraLibraryTitle => 'ਮੰਤਰ ਲਾਇਬ੍ਰੇਰੀ';

  @override
  String get addMantra => 'ਮੰਤਰ ਜੋੜੋ';

  @override
  String get searchHint => 'ਸਿਰਲੇਖ, ਲਿਪੀ ਜਾਂ ਪਰੰਪਰਾ ਖੋਜੋ';

  @override
  String noMantrasMatch(String query) {
    return '“$query” ਨਾਲ ਕੋਈ ਮੰਤਰ ਮੇਲ ਨਹੀਂ ਖਾਂਦਾ।\nਆਪਣਾ ਬਣਾਉਣ ਲਈ “ਮੰਤਰ ਜੋੜੋ” ਟੈਪ ਕਰੋ।';
  }

  @override
  String mantraAdded(String title) {
    return '“$title” ਜੋੜਿਆ ਗਿਆ';
  }

  @override
  String mantraSaved(String title) {
    return '“$title” ਸੰਭਾਲਿਆ ਗਿਆ';
  }

  @override
  String mantraRestored(String title) {
    return '“$title” ਨੂੰ ਇਸਦੇ ਡਿਫਾਲਟ \'ਤੇ ਬਹਾਲ ਕੀਤਾ ਗਿਆ';
  }

  @override
  String get deleteMantraTitle => 'ਮੰਤਰ ਮਿਟਾਓ?';

  @override
  String deleteMantraBody(String title) {
    return '“$title” ਤੁਹਾਡੀ ਲਾਇਬ੍ਰੇਰੀ ਵਿੱਚੋਂ ਹਟਾ ਦਿੱਤਾ ਜਾਵੇਗਾ।';
  }

  @override
  String get retrainVoiceTooltip => 'ਆਵਾਜ਼ ਮੁੜ ਸਿਖਲਾਈ ਦਿਓ';

  @override
  String get trainVoice => 'ਆਵਾਜ਼ ਸਿਖਲਾਈ ਦਿਓ';

  @override
  String mantraCountTag(int count) {
    return '$count ਗਿਣਤੀ';
  }

  @override
  String get editedTag => 'ਸੋਧਿਆ';

  @override
  String get editMantra => 'ਮੰਤਰ ਸੋਧੋ';

  @override
  String get addAMantra => 'ਇੱਕ ਮੰਤਰ ਜੋੜੋ';

  @override
  String get titleLabel => 'ਸਿਰਲੇਖ *';

  @override
  String get titleRequired => 'ਇੱਕ ਸਿਰਲੇਖ ਦਰਜ ਕਰੋ';

  @override
  String get scriptTextLabel => 'ਲਿਪੀ ਟੈਕਸਟ';

  @override
  String get transliterationLabel => 'ਲਿਪੀਅੰਤਰਨ';

  @override
  String get traditionLabel => 'ਪਰੰਪਰਾ / ਭਾਸ਼ਾ';

  @override
  String get traditionHint => 'ਉਦਾ. ਸੰਸਕ੍ਰਿਤ · ਹਿੰਦੂ';

  @override
  String get defaultCountLabel => 'ਡਿਫਾਲਟ ਗਿਣਤੀ *';

  @override
  String get enterNumberOneOrMore => '1 ਜਾਂ ਇਸ ਤੋਂ ਵੱਧ ਨੰਬਰ ਦਰਜ ਕਰੋ';

  @override
  String get tooLarge => 'ਇਹ ਬਹੁਤ ਵੱਡਾ ਹੈ';

  @override
  String get saveChanges => 'ਬਦਲਾਅ ਸੰਭਾਲੋ';

  @override
  String get saveToLibrary => 'ਲਾਇਬ੍ਰੇਰੀ ਵਿੱਚ ਸੰਭਾਲੋ';

  @override
  String get resetToDefaultButton => 'ਡਿਫਾਲਟ \'ਤੇ ਰੀਸੈੱਟ ਕਰੋ';

  @override
  String get resetToDefaultTitle => 'ਡਿਫਾਲਟ \'ਤੇ ਰੀਸੈੱਟ ਕਰਨਾ ਹੈ?';

  @override
  String resetToDefaultBody(String title) {
    return '“$title” ਵਿੱਚ ਤੁਹਾਡੇ ਬਦਲਾਅ ਹਟਾ ਦਿੱਤੇ ਜਾਣਗੇ ਅਤੇ ਮੂਲ ਟੈਕਸਟ ਬਹਾਲ ਕੀਤਾ ਜਾਵੇਗਾ।';
  }

  @override
  String switchToMantra(String title) {
    return '$title \'ਤੇ ਸਵਿੱਚ ਕਰਨਾ ਹੈ?';
  }

  @override
  String get switchMantraBody => 'ਤੁਹਾਡੀ ਮੌਜੂਦਾ ਗਿਣਤੀ ਰੀਸੈੱਟ ਹੋ ਜਾਵੇਗੀ।';

  @override
  String get keepCurrent => 'ਮੌਜੂਦਾ ਰੱਖੋ';

  @override
  String get switchAction => 'ਸਵਿੱਚ ਕਰੋ';

  @override
  String get smallerMantraText => 'ਛੋਟਾ ਮੰਤਰ ਟੈਕਸਟ';

  @override
  String get largerMantraText => 'ਵੱਡਾ ਮੰਤਰ ਟੈਕਸਟ';

  @override
  String get libraryButton => 'ਲਾਇਬ੍ਰੇਰੀ';

  @override
  String get trainYourOwnMantra => 'ਆਪਣਾ ਮੰਤਰ ਸਿਖਲਾਈ ਦਿਓ';

  @override
  String voiceCountingFrom(String title, int count) {
    return 'ਤੁਹਾਡੀਆਂ $count ਰਿਕਾਰਡਿੰਗਾਂ ਤੋਂ “$title” ਗਿਣਿਆ ਜਾ ਰਿਹਾ ਹੈ। ਹੋਰ ਆਵਾਜ਼ਾਂ ਅਤੇ ਸ਼ਬਦ ਨਜ਼ਰਅੰਦਾਜ਼ ਕੀਤੇ ਜਾਂਦੇ ਹਨ।';
  }

  @override
  String voiceCountsOnlyTrained(String title, int min, int max) {
    return 'ਆਵਾਜ਼ ਸਿਰਫ਼ ਤੁਹਾਡੇ ਦੁਆਰਾ ਸਿਖਲਾਈ ਪ੍ਰਾਪਤ ਮੰਤਰ ਨੂੰ ਗਿਣਦੀ ਹੈ। ਸ਼ੁਰੂ ਕਰਨ ਲਈ “$title” ਨੂੰ $min ਤੋਂ $max ਵਾਰ ਰਿਕਾਰਡ ਕਰੋ।';
  }

  @override
  String get addMoreSamples => 'ਹੋਰ ਨਮੂਨੇ ਜੋੜੋ';

  @override
  String get retrain => 'ਮੁੜ ਸਿਖਲਾਈ ਦਿਓ';

  @override
  String get clearTraining => 'ਸਿਖਲਾਈ ਸਾਫ਼ ਕਰੋ';

  @override
  String get voiceBetaNote =>
      'ਬੀਟਾ: ਇਹ ਡਿਵਾਈਸ \'ਤੇ ਅਤੇ ਆਫਲਾਈਨ ਕੰਮ ਕਰਦਾ ਹੈ। ਵਧੇਰੇ ਰਿਕਾਰਡਿੰਗਾਂ ਨਾਲ ਸ਼ੁੱਧਤਾ ਵਧਦੀ ਹੈ ਅਤੇ ਸ਼ੋਰ ਵਾਲੇ ਕਮਰੇ ਵਿੱਚ ਘਟਦੀ ਹੈ। ਦੁਹਰਾਓ ਦੇ ਵਿਚਕਾਰ ਥੋੜ੍ਹਾ ਰੁਕੋ। ਸਿਰਫ਼ ਤੁਹਾਡੀ ਆਵਾਜ਼ ਇੱਥੇ ਗਿਣੀ ਜਾਂਦੀ ਹੈ; + ਅਤੇ − ਬਟਨ ਗਿਣਤੀ ਠੀਕ ਕਰਦੇ ਹਨ।';

  @override
  String get trainVoiceFirstTitle => 'ਪਹਿਲਾਂ ਆਪਣੀ ਆਵਾਜ਼ ਸਿਖਲਾਈ ਦਿਓ';

  @override
  String trainVoiceFirstBody(String title, int min, int max) {
    return 'ਆਵਾਜ਼ ਸਿਰਫ਼ ਤੁਹਾਡੇ ਸਿਖਲਾਈ ਪ੍ਰਾਪਤ ਮੰਤਰ ਨੂੰ ਗਿਣਦੀ ਹੈ। “$title” ਨੂੰ $min ਤੋਂ $max ਵਾਰ (ਲਗਭਗ ਇੱਕ ਮਿੰਟ) ਰਿਕਾਰਡ ਕਰੋ। ਇਹ ਇਸ ਡਿਵਾਈਸ \'ਤੇ ਰਹਿੰਦਾ ਹੈ ਅਤੇ ਆਫਲਾਈਨ ਕੰਮ ਕਰਦਾ ਹੈ।';
  }

  @override
  String get later => 'ਬਾਅਦ ਵਿੱਚ';

  @override
  String get trainNow => 'ਹੁਣੇ ਸਿਖਲਾਈ ਦਿਓ';

  @override
  String get betaLabel => 'ਬੀਟਾ';

  @override
  String get voiceTrained => 'ਆਵਾਜ਼ ਸਿਖਲਾਈ ਪ੍ਰਾਪਤ';

  @override
  String get voiceNotTrained => 'ਆਵਾਜ਼ ਸਿਖਲਾਈ ਪ੍ਰਾਪਤ ਨਹੀਂ';

  @override
  String get sensitivityLabel => 'ਸੰਵੇਦਨਸ਼ੀਲਤਾ';

  @override
  String get sensitivityStrict => 'ਸਖ਼ਤ';

  @override
  String get sensitivityLenient => 'ਢਿੱਲਾ';

  @override
  String get sensitivityMedium => 'ਦਰਮਿਆਨਾ';

  @override
  String get clearVoiceTrainingTitle => 'ਆਵਾਜ਼ ਸਿਖਲਾਈ ਸਾਫ਼ ਕਰਨੀ ਹੈ?';

  @override
  String clearVoiceTrainingBody(String title) {
    return 'ਜਦੋਂ ਤੱਕ ਤੁਸੀਂ ਇਸਨੂੰ ਦੁਬਾਰਾ ਸਿਖਲਾਈ ਨਹੀਂ ਦਿੰਦੇ, ਆਵਾਜ਼ “$title” ਗਿਣਨਾ ਬੰਦ ਕਰ ਦੇਵੇਗੀ।';
  }

  @override
  String get completionTitle => 'ਸੰਪੂਰਨਤਾ';

  @override
  String get vibrationLabel => 'ਕੰਬਣੀ';

  @override
  String vibrationSubtitle(int n) {
    return 'ਹਰ $n ਗਿਣਤੀ \'ਤੇ ਇੱਕ ਬਜ਼, ਅਤੇ ਟੀਚੇ \'ਤੇ ਇੱਕ ਮਜ਼ਬੂਤ।';
  }

  @override
  String intensityLevel(int level) {
    return 'ਤੀਬਰਤਾ: ਪੱਧਰ $level ਵਿੱਚੋਂ 5';
  }

  @override
  String get testMilestone => 'ਟੈਸਟ ਮੀਲਪੱਥਰ';

  @override
  String get testTarget => 'ਟੈਸਟ ਟੀਚਾ';

  @override
  String get ringtoneLabel => 'ਰਿੰਗਟੋਨ';

  @override
  String get ringtoneSubtitle => 'ਟੀਚੇ ਤੱਕ ਪਹੁੰਚਣ \'ਤੇ ਇੱਕ ਆਵਾਜ਼ ਵੱਜਦੀ ਹੈ।';

  @override
  String get playSound => 'ਆਵਾਜ਼ ਚਲਾਓ';

  @override
  String get combined => 'ਸੰਯੁਕਤ';

  @override
  String get combinedTooltip => 'ਸਾਰੇ ਚਾਰ ਮੋਡ ਇੱਕ ਸਾਂਝੀ ਗਿਣਤੀ ਵਿੱਚ ਜੁੜਦੇ ਹਨ';

  @override
  String get separate => 'ਵੱਖਰਾ';

  @override
  String get separateTooltip => 'ਹਰੇਕ ਮੋਡ ਆਪਣੀ ਖੁਦ ਦੀ ਗਿਣਤੀ ਰੱਖਦਾ ਹੈ';

  @override
  String get countModeSemantic => 'ਗਿਣਤੀ ਮੋਡ';

  @override
  String get combinedExplain =>
      'ਟੈਪ, ਆਵਾਜ਼, ਰਿਦਮ ਅਤੇ ਮਾਲਾ ਸਾਰੇ ਇੱਕ ਟੀਚੇ ਵੱਲ ਇੱਕ ਸਾਂਝੀ ਗਿਣਤੀ ਵਿੱਚ ਜੁੜਦੇ ਹਨ।';

  @override
  String get separateExplain =>
      'ਹਰੇਕ ਮੋਡ ਆਪਣੀ ਗਿਣਤੀ ਅਤੇ ਟੀਚੇ ਵੱਲ ਆਪਣੀ ਤਰੱਕੀ ਰੱਖਦਾ ਹੈ। ਰੀਸੈੱਟ ਅਤੇ ਸੰਪੂਰਨਤਾ ਸਿਰਫ਼ ਉਸ ਮੋਡ \'ਤੇ ਲਾਗੂ ਹੁੰਦੀ ਹੈ ਜਿਸ ਵਿੱਚ ਤੁਸੀਂ ਹੋ।';

  @override
  String countedLabel(int count) {
    return '$count ਗਿਣਿਆ ਗਿਆ';
  }

  @override
  String ofTarget(int count) {
    return '$count ਵਿੱਚੋਂ';
  }

  @override
  String get removeOneTooltip => 'ਇੱਕ ਹਟਾਓ';

  @override
  String get undoLabel => 'ਵਾਪਸ ਲਵੋ';

  @override
  String get countLabel => 'ਗਿਣਤੀ';

  @override
  String get addOneTooltip => 'ਇੱਕ ਜੋੜੋ';

  @override
  String get focusLabel => 'ਫੋਕਸ';

  @override
  String get focusModeTooltip => 'ਫੋਕਸ ਮੋਡ';

  @override
  String get pause => 'ਰੋਕੋ';

  @override
  String get resume => 'ਮੁੜ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get start => 'ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String targetReachedSeparate(String mode) {
    return '$mode ਵਿੱਚ ਟੀਚਾ ਪੂਰਾ ਹੋਇਆ 🙏  ਇਸ ਮੋਡ ਨੂੰ ਰੀਸੈੱਟ ਕਰੋ, ਮੋਡ ਬਦਲੋ, ਜਾਂ ਟੀਚਾ ਵਧਾਓ।';
  }

  @override
  String get targetReachedCombined =>
      'ਟੀਚਾ ਪੂਰਾ ਹੋਇਆ 🙏  ਰੀਸੈੱਟ ਕਰੋ, ਜਾਂ ਟੀਚਾ ਵਧਾਓ।';

  @override
  String resetModeCountTitle(String mode) {
    return '$mode ਗਿਣਤੀ ਰੀਸੈੱਟ ਕਰਨੀ ਹੈ?';
  }

  @override
  String get resetSessionTitle => 'ਇਸ ਸੈਸ਼ਨ ਨੂੰ ਰੀਸੈੱਟ ਕਰਨਾ ਹੈ?';

  @override
  String resetModeCountBody(String mode, int count) {
    return 'ਤੁਹਾਡੀ $mode ਗਿਣਤੀ $count ਜ਼ੀਰੋ \'ਤੇ ਵਾਪਸ ਆ ਜਾਵੇਗੀ। ਹੋਰ ਮੋਡ ਆਪਣੀ ਗਿਣਤੀ ਰੱਖਦੇ ਹਨ।';
  }

  @override
  String resetSessionBody(int count) {
    return 'ਤੁਹਾਡੀ $count ਗਿਣਤੀ ਜ਼ੀਰੋ \'ਤੇ ਵਾਪਸ ਆ ਜਾਵੇਗੀ।';
  }

  @override
  String get modeHelpTap =>
      'ਰਿੰਗ \'ਤੇ ਟੈਪ ਕਰੋ, ਜਾਂ ਫੋਕਸ ਮੋਡ ਵਿੱਚ ਕਿਤੇ ਵੀ। ਸਿਰਫ਼ ਟੈਪ ਮੋਡ ਸਕ੍ਰੀਨ ਟੈਪ ਗਿਣਦਾ ਹੈ।';

  @override
  String get modeHelpRhythm =>
      'Start ਦਬਾਓ ਅਤੇ ਗਿਣਤੀ ਹੇਠਾਂ ਦਿੱਤੀ ਰਫ਼ਤਾਰ \'ਤੇ ਆਪਣੇ ਆਪ ਵਧਦੀ ਹੈ।';

  @override
  String get modeHelpVoice =>
      'Start ਦਬਾਓ, ਫਿਰ ਆਪਣਾ ਸਿਖਲਾਈ ਪ੍ਰਾਪਤ ਮੰਤਰ ਜਪੋ। ਹਰ ਵਾਰ ਪਛਾਣੇ ਜਾਣ \'ਤੇ ਇਹ ਤੁਰੰਤ ਇੱਕ ਗਿਣਤੀ ਜੋੜਦਾ ਹੈ; ਹੋਰ ਆਵਾਜ਼ਾਂ ਨਜ਼ਰਅੰਦਾਜ਼ ਕੀਤੀਆਂ ਜਾਂਦੀਆਂ ਹਨ। ਮਾਈਕ੍ਰੋਫ਼ੋਨ ਚਾਹੀਦਾ ਹੈ; ਸ਼ਾਂਤ ਕਮਰੇ ਵਿੱਚ ਸਭ ਤੋਂ ਵਧੀਆ ਕੰਮ ਕਰਦਾ ਹੈ।';

  @override
  String get modeHelpMala =>
      'Start ਦਬਾਓ, ਫਿਰ ਗਿਣਨ ਲਈ ਕੋਈ ਵੀ ਵਾਲੀਅਮ ਬਟਨ ਦਬਾਓ। ਅੱਖਾਂ ਬੰਦ ਹੋਣ ਜਾਂ ਫੋਨ ਜੇਬ ਵਿੱਚ ਹੋਣ \'ਤੇ ਸੁਵਿਧਾਜਨਕ। ਸਕ੍ਰੀਨ ਚਾਲੂ ਰਹਿਣੀ ਚਾਹੀਦੀ ਹੈ।';

  @override
  String get countingModeLabel => 'ਗਿਣਤੀ ਮੋਡ';

  @override
  String pacePrefix(String pace) {
    return 'ਰਫ਼ਤਾਰ: ਗਿਣਤੀ $pace';
  }

  @override
  String modeSemanticLabel(String mode) {
    return '$mode ਮੋਡ';
  }

  @override
  String get tapAnywhereToCount => 'ਗਿਣਨ ਲਈ ਕਿਤੇ ਵੀ ਟੈਪ ਕਰੋ';

  @override
  String countingPace(String pace) {
    return 'ਗਿਣਤੀ $pace';
  }

  @override
  String pausedPace(String pace) {
    return 'ਰੁਕਿਆ ਹੋਇਆ · $pace';
  }

  @override
  String get listening => 'ਸੁਣ ਰਿਹਾ ਹੈ…';

  @override
  String get startingMicrophone =>
      'ਮਾਈਕ੍ਰੋਫ਼ੋਨ ਸ਼ੁਰੂ ਹੋ ਰਿਹਾ ਹੈ… ਪੁੱਛੇ ਜਾਣ \'ਤੇ ਐਕਸੈਸ ਦਿਓ';

  @override
  String get notTrainedYet =>
      'ਹਾਲੇ ਸਿਖਲਾਈ ਪ੍ਰਾਪਤ ਨਹੀਂ · ਆਵਾਜ਼ ਵਰਤਣ ਲਈ ਮੰਤਰ ਸਿਖਲਾਈ ਦਿਓ';

  @override
  String get pausedPressStartListen => 'ਰੁਕਿਆ ਹੋਇਆ · ਸੁਣਨ ਲਈ Start ਦਬਾਓ';

  @override
  String get pressVolumeKeys => 'ਗਿਣਨ ਲਈ ਵਾਲੀਅਮ ਕੁੰਜੀਆਂ ਦਬਾਓ';

  @override
  String get capturingVolumeKeys => 'ਵਾਲੀਅਮ ਕੁੰਜੀਆਂ ਕੈਪਚਰ ਕਰ ਰਿਹਾ ਹੈ…';

  @override
  String get pausedPressStartVolume =>
      'ਰੁਕਿਆ ਹੋਇਆ · ਵਾਲੀਅਮ ਕੁੰਜੀਆਂ ਵਰਤਣ ਲਈ Start ਦਬਾਓ';

  @override
  String modeTitleLine(String mode, String own) {
    String _temp0 = intl.Intl.selectLogic(own, {
      'yes': ' · ਆਪਣੀ ਗਿਣਤੀ',
      'other': '',
    });
    return '$mode ਮੋਡ$_temp0';
  }

  @override
  String voiceCountedMatch(int percent) {
    return 'ਗਿਣਿਆ ਗਿਆ · $percent% ਮੇਲ';
  }

  @override
  String voiceIgnoredMatch(int percent) {
    return 'ਨਜ਼ਰਅੰਦਾਜ਼ ਕੀਤਾ ਗਿਆ · $percent% ਮੇਲ (ਤੁਹਾਡਾ ਮੰਤਰ ਨਹੀਂ)';
  }

  @override
  String get paceFieldLabel => 'ਰਫ਼ਤਾਰ';

  @override
  String paceHelpOk(String pace, String range) {
    return '$pace ਗਿਣਦਾ ਹੈ। (ਇਜਾਜ਼ਤ: $range)';
  }

  @override
  String paceHelpError(String error, String pace) {
    return '$error ਹਾਲੇ ਵੀ $pace ਗਿਣ ਰਿਹਾ ਹੈ।';
  }

  @override
  String get sankalpLabel => 'ਸੰਕਲਪ';

  @override
  String get sankalpHint => 'ਇਸ ਅਭਿਆਸ ਲਈ ਆਪਣਾ ਇਰਾਦਾ ਦੱਸੋ…';

  @override
  String get targetSectionTitle => 'ਟੀਚਾ';

  @override
  String get byCount => 'ਗਿਣਤੀ ਅਨੁਸਾਰ';

  @override
  String get byTime => 'ਸਮੇਂ ਅਨੁਸਾਰ';

  @override
  String customWithValue(String value) {
    return 'ਕਸਟਮ · $value';
  }

  @override
  String get custom => 'ਕਸਟਮ';

  @override
  String get enterNumberRange => '1 ਤੋਂ 9,999,999 ਤੱਕ ਦਾ ਨੰਬਰ ਦਰਜ ਕਰੋ';

  @override
  String get customCountTitle => 'ਕਸਟਮ ਗਿਣਤੀ';

  @override
  String get targetCountLabel => 'ਟੀਚਾ ਗਿਣਤੀ';

  @override
  String get setAction => 'ਸੈੱਟ ਕਰੋ';

  @override
  String get durationLabel => 'ਮਿਆਦ';

  @override
  String get enterDuration => '1 ਜਾਂ ਵੱਧ ਦੀ ਮਿਆਦ ਦਰਜ ਕਰੋ।';

  @override
  String get maxDurationCapped =>
      'ਵੱਧ ਤੋਂ ਵੱਧ 99 ਘੰ 59 ਮਿੰ 59 ਸੈ ਹੈ — ਇਸਨੂੰ ਸੀਮਤ ਕੀਤਾ ਜਾਵੇਗਾ।';

  @override
  String sessionLasts(String duration) {
    return 'ਸੈਸ਼ਨ $duration ਤੱਕ ਚੱਲਦਾ ਹੈ।';
  }

  @override
  String get targetReachedFocus => 'ਟੀਚਾ ਪੂਰਾ ਹੋਇਆ 🙏';

  @override
  String screenTapsDoNotCount(String mode) {
    return '$mode ਮੋਡ ਵਿੱਚ ਸਕ੍ਰੀਨ ਟੈਪ ਨਹੀਂ ਗਿਣੇ ਜਾਂਦੇ। ਠੀਕ ਕਰਨ ਲਈ + ਜਾਂ − ਵਰਤੋ।';
  }

  @override
  String holdFingersToExit(int fingers, int seconds) {
    return 'ਬਾਹਰ ਜਾਣ ਲਈ $fingers ਉਂਗਲਾਂ $seconds ਸਕਿੰਟ ਲਈ ਦਬਾਈ ਰੱਖੋ';
  }

  @override
  String get holdToExitFocusMode => 'ਫੋਕਸ ਮੋਡ ਤੋਂ ਬਾਹਰ ਜਾਣ ਲਈ ਦਬਾਈ ਰੱਖੋ';

  @override
  String get holdToExit => 'ਬਾਹਰ ਜਾਣ ਲਈ ਦਬਾਈ ਰੱਖੋ';

  @override
  String get keepHoldingToExit => 'ਬਾਹਰ ਜਾਣ ਲਈ ਦਬਾਈ ਰੱਖੋ…';

  @override
  String addedRecordingsTo(int added, String title, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'ਰਿਕਾਰਡਿੰਗਾਂ',
      one: 'ਰਿਕਾਰਡਿੰਗ',
    );
    return '“$title” ਵਿੱਚ $added $_temp0 ਜੋੜੀਆਂ ਗਈਆਂ (ਕੁੱਲ $total)';
  }

  @override
  String voiceTrainedFor(String title, int count) {
    return '“$title” ਲਈ ਆਵਾਜ਼ ਸਿਖਲਾਈ ਪ੍ਰਾਪਤ ($count ਰਿਕਾਰਡਿੰਗਾਂ)';
  }

  @override
  String trainedRecordingsCount(int count) {
    return 'ਸਿਖਲਾਈ ਪ੍ਰਾਪਤ · $count ਰਿਕਾਰਡਿੰਗਾਂ';
  }

  @override
  String get tooFewRecordings =>
      'ਗਿਣਨ ਲਈ ਬਹੁਤ ਘੱਟ ਰਿਕਾਰਡਿੰਗਾਂ। ਹੋਰ ਜੋੜੋ, ਜਾਂ ਮੁੜ ਸਿਖਲਾਈ ਦਿਓ।';

  @override
  String canCountAddMore(int room) {
    return 'ਆਵਾਜ਼ ਇਸ ਮੰਤਰ ਨੂੰ ਗਿਣ ਸਕਦੀ ਹੈ। ਸ਼ੁੱਧਤਾ ਸੁਧਾਰਨ ਲਈ ਸ਼ੁਰੂ ਕੀਤੇ ਬਿਨਾਂ $room ਹੋਰ ਰਿਕਾਰਡਿੰਗਾਂ ਜੋੜੋ।';
  }

  @override
  String canCountAtMax(int max) {
    return 'ਆਵਾਜ਼ ਇਸ ਮੰਤਰ ਨੂੰ ਗਿਣ ਸਕਦੀ ਹੈ। ਤੁਹਾਡੇ ਕੋਲ ਵੱਧ ਤੋਂ ਵੱਧ $max ਰਿਕਾਰਡਿੰਗਾਂ ਹਨ; ਉਹਨਾਂ ਨੂੰ ਬਦਲਣ ਲਈ ਮੁੜ ਸਿਖਲਾਈ ਦਿਓ।';
  }

  @override
  String get pausedHeadline => 'ਰੁਕਿਆ ਹੋਇਆ';

  @override
  String pausedSub(int recorded) {
    return '$recorded ਰਿਕਾਰਡ ਕੀਤੀਆਂ। ਜਾਰੀ ਰੱਖੋ, ਜਾਂ ਜੋ ਹੈ ਉਸਨੂੰ ਸੰਭਾਲੋ।';
  }

  @override
  String recordInstructions(int min, int max, int recommended) {
    return 'ਇਸਨੂੰ ਆਪਣੀ ਆਮ ਜਾਪ ਰਫ਼ਤਾਰ \'ਤੇ $min ਤੋਂ $max ਵਾਰ ਰਿਕਾਰਡ ਕਰੋ ($recommended ਇੱਕ ਚੰਗੀ ਗਿਣਤੀ ਹੈ)। ਫਿਰ ਆਵਾਜ਼ ਸਿਰਫ਼ ਤੁਹਾਡਾ ਮੰਤਰ ਗਿਣੇਗੀ।';
  }

  @override
  String get openingMicrophone => 'ਮਾਈਕ੍ਰੋਫ਼ੋਨ ਖੋਲ੍ਹਿਆ ਜਾ ਰਿਹਾ ਹੈ…';

  @override
  String get stayQuiet => 'ਇੱਕ ਪਲ ਲਈ ਸ਼ਾਂਤ ਰਹੋ…';

  @override
  String get listeningToRoom =>
      'ਬੈਕਗਰਾਊਂਡ ਸ਼ੋਰ ਨਾ ਗਿਣਿਆ ਜਾਵੇ ਇਸ ਲਈ ਕਮਰੇ ਨੂੰ ਸੁਣਿਆ ਜਾ ਰਿਹਾ ਹੈ।';

  @override
  String get sayYourMantra => 'ਆਪਣਾ ਮੰਤਰ ਬੋਲੋ…';

  @override
  String recordingXofY(int current, int max) {
    return '$current ਦੀ ਰਿਕਾਰਡਿੰਗ ਹੋ ਰਹੀ ਹੈ, ਵੱਧ ਤੋਂ ਵੱਧ $max ਵਿੱਚੋਂ';
  }

  @override
  String allRecordingsCaptured(int count) {
    return 'ਸਾਰੀਆਂ $count ਰਿਕਾਰਡਿੰਗਾਂ ਕੈਪਚਰ ਹੋ ਗਈਆਂ';
  }

  @override
  String get saveToStartCounting =>
      'ਆਵਾਜ਼ ਨਾਲ ਗਿਣਤੀ ਸ਼ੁਰੂ ਕਰਨ ਲਈ ਇਹਨਾਂ ਨੂੰ ਸੰਭਾਲੋ।';

  @override
  String get cannotUseMicrophone => 'ਮਾਈਕ੍ਰੋਫ਼ੋਨ ਵਰਤਿਆ ਨਹੀਂ ਜਾ ਸਕਦਾ';

  @override
  String get canSaveNowHint =>
      'ਤੁਸੀਂ ਹੁਣੇ ਸੰਭਾਲ ਸਕਦੇ ਹੋ, ਜਾਂ ਹੋਰ ਸ਼ੁੱਧਤਾ ਲਈ ਜਾਰੀ ਰੱਖ ਸਕਦੇ ਹੋ।';

  @override
  String minAreEnough(int min) {
    return 'ਸ਼ੁਰੂ ਕਰਨ ਲਈ $min ਕਾਫ਼ੀ ਹਨ।';
  }

  @override
  String addingToSaved(int count) {
    return 'ਤੁਹਾਡੀਆਂ $count ਸੰਭਾਲੀਆਂ ਰਿਕਾਰਡਿੰਗਾਂ ਵਿੱਚ ਜੋੜਿਆ ਜਾ ਰਿਹਾ ਹੈ।';
  }

  @override
  String get tryAgain => 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get startRecording => 'ਰਿਕਾਰਡਿੰਗ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get openSettingsAction => 'ਸੈਟਿੰਗਾਂ ਖੋਲ੍ਹੋ';

  @override
  String saveNRecordings(int count) {
    return '$count ਰਿਕਾਰਡਿੰਗਾਂ ਸੰਭਾਲੋ';
  }

  @override
  String recordMoreToSave(int n) {
    return 'ਸੰਭਾਲਣ ਲਈ $n ਹੋਰ ਰਿਕਾਰਡ ਕਰੋ';
  }

  @override
  String get recordSampleToSave => 'ਸੰਭਾਲਣ ਲਈ ਇੱਕ ਨਮੂਨਾ ਰਿਕਾਰਡ ਕਰੋ';

  @override
  String get undoLast => 'ਆਖਰੀ ਵਾਪਸ ਲਵੋ';

  @override
  String get stop => 'ਰੋਕੋ';

  @override
  String get continueRecording => 'ਰਿਕਾਰਡਿੰਗ ਜਾਰੀ ਰੱਖੋ';

  @override
  String get startOver => 'ਮੁੜ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String recordedOfMax(int recorded, int max) {
    return '$recorded ਰਿਕਾਰਡ ਕੀਤੀਆਂ, ਵੱਧ ਤੋਂ ਵੱਧ $max ਵਿੱਚੋਂ';
  }

  @override
  String voiceBetaNoteTraining(int max) {
    return 'ਬੀਟਾ। ਸਭ ਕੁਝ ਇਸ ਡਿਵਾਈਸ \'ਤੇ, ਆਫਲਾਈਨ ਹੁੰਦਾ ਹੈ: ਸਿਰਫ਼ ਆਵਾਜ਼ ਦਾ ਵਰਣਨ ਕਰਨ ਵਾਲੇ ਨੰਬਰ ਸੰਭਾਲੇ ਜਾਂਦੇ ਹਨ, ਕਦੇ ਆਡੀਓ ਨਹੀਂ। ਵਧੇਰੇ ਰਿਕਾਰਡਿੰਗਾਂ ਗਿਣਤੀ ਨੂੰ ਵਧੇਰੇ ਸਹੀ ਬਣਾਉਂਦੀਆਂ ਹਨ (ਵੱਧ ਤੋਂ ਵੱਧ $max ਤੱਕ); ਸ਼ੋਰ ਵਾਲਾ ਕਮਰਾ ਇਸਨੂੰ ਘੱਟ ਸਹੀ ਬਣਾਉਂਦਾ ਹੈ। ਮੰਤਰ ਇੱਕ ਵਾਰ ਬੋਲੋ, ਫਿਰ ਅਗਲੀ ਵਾਰ ਤੋਂ ਪਹਿਲਾਂ ਥੋੜ੍ਹਾ ਰੁਕੋ।';
  }

  @override
  String get actionClear => 'ਸਾਫ਼ ਕਰੋ';

  @override
  String get today => 'ਅੱਜ';

  @override
  String get previousMonth => 'ਪਿਛਲਾ ਮਹੀਨਾ';

  @override
  String get nextMonth => 'ਅਗਲਾ ਮਹੀਨਾ';

  @override
  String get markTypeGood => 'ਚੰਗਾ';

  @override
  String get markTypeCautious => 'ਸਾਵਧਾਨ';

  @override
  String get markTypeNeutral => 'ਨਿਰਪੱਖ';

  @override
  String get reminderModeNone => 'ਕੋਈ ਸਮਾਂ ਨਹੀਂ';

  @override
  String get reminderModeOnce => 'ਇੱਕ ਵਾਰ';

  @override
  String get reminderModeSeveral => 'ਕਈ ਵਾਰ';

  @override
  String get repeatRuleOnce => 'ਇੱਕ ਵਾਰ';

  @override
  String get repeatRuleDaily => 'ਰੋਜ਼ਾਨਾ';

  @override
  String get repeatRuleWeekly => 'ਹਫ਼ਤਾਵਾਰੀ';

  @override
  String get repeatRuleMonthly => 'ਮਹੀਨਾਵਾਰ';

  @override
  String get repeatRuleQuarterly => 'ਤਿਮਾਹੀ';

  @override
  String get repeatRuleHalfYearly => 'ਅਰਧ-ਸਾਲਾਨਾ';

  @override
  String get repeatRuleYearly => 'ਸਾਲਾਨਾ';

  @override
  String get homeModeNone => 'ਨਾ ਦਿਖਾਓ';

  @override
  String get homeModeMorning => 'ਸਵੇਰੇ ਇੱਕ ਵਾਰ';

  @override
  String get homeModeAllDay => 'ਪੂਰਾ ਦਿਨ ਰੱਖੋ';

  @override
  String get markStyleDot => 'ਬਿੰਦੂ';

  @override
  String get markStyleFilled => 'ਭਰਿਆ ਹੋਇਆ';

  @override
  String get markStyleHighlight => 'ਹਾਈਲਾਈਟ';

  @override
  String get markStyleCircle => 'ਚੱਕਰ';

  @override
  String get markStyleSquare => 'ਵਰਗ';

  @override
  String get emojiOm => 'ॐ';

  @override
  String get emojiKhanda => 'ਖੰਡਾ';

  @override
  String get emojiMala => 'ਮਾਲਾ';

  @override
  String get emojiDiya => 'ਦੀਵਾ';

  @override
  String get emojiBell => 'ਘੰਟੀ';

  @override
  String get emojiSunrise => 'ਸੂਰਜ ਚੜ੍ਹਨਾ';

  @override
  String get emojiStar => 'ਤਾਰਾ';

  @override
  String get emojiSparkle => 'ਚਮਕ';

  @override
  String get emojiMoney => 'ਪੈਸਾ';

  @override
  String get emojiHandshake => 'ਹੱਥ ਮਿਲਾਉਣਾ';

  @override
  String get emojiAvoid => 'ਬਚੋ';

  @override
  String get emojiDone => 'ਮੁਕੰਮਲ';

  @override
  String get markTitleGood => 'ਚੰਗਾ ਦਿਨ';

  @override
  String get markTitleCautious => 'ਸਾਵਧਾਨ ਦਿਨ';

  @override
  String get markTitleNeutral => 'ਨਿਰਪੱਖ ਦਿਨ';

  @override
  String get reminderBodyGood => 'ਇੱਕ ਚੰਗਾ ਦਿਨ।';

  @override
  String get reminderBodyCautious => 'ਅੱਜ ਸਾਵਧਾਨ ਰਹੋ।';

  @override
  String get reminderBodyNeutral => 'ਤੁਹਾਡੇ ਕੈਲੰਡਰ ਵਿੱਚ ਚਿੰਨ੍ਹਿਤ।';

  @override
  String get channelCalendarRemindersName => 'ਕੈਲੰਡਰ ਰੀਮਾਈਂਡਰ';

  @override
  String get channelCalendarRemindersDesc =>
      'ਤੁਹਾਡੇ ਦੁਆਰਾ Sadho ਵਿੱਚ ਚਿੰਨ੍ਹਿਤ ਤਾਰੀਖਾਂ ਲਈ ਰੀਮਾਈਂਡਰ';

  @override
  String get channelAlarmsName => 'ਅਲਾਰਮ ਅਤੇ ਟਾਈਮਰ';

  @override
  String get channelAlarmsDesc => 'ਸੂਰਜ-ਅਧਾਰਿਤ ਅਲਾਰਮ ਅਤੇ ਪੂਰੇ ਹੋਏ ਟਾਈਮਰ';

  @override
  String get repeatSummaryOnce => 'ਇੱਕ ਵਾਰ';

  @override
  String get repeatSummaryDaily => 'ਹਰ ਰੋਜ਼';

  @override
  String get repeatSummaryWeekly => 'ਹਰ ਹਫ਼ਤੇ';

  @override
  String get repeatSummaryMonthly => 'ਹਰ ਮਹੀਨੇ';

  @override
  String get repeatSummaryQuarterly => 'ਹਰ 3 ਮਹੀਨੇ';

  @override
  String get repeatSummaryHalfYearly => 'ਹਰ 6 ਮਹੀਨੇ';

  @override
  String get repeatSummaryYearly => 'ਹਰ ਸਾਲ';

  @override
  String reminderSummaryAt(String times) {
    return '$times \'ਤੇ ਯਾਦ ਦਿਵਾਓ';
  }

  @override
  String homeSummaryFrom(String time) {
    return 'ਹੋਮ \'ਤੇ $time ਤੋਂ';
  }

  @override
  String get homeSummaryAllDay => 'ਹੋਮ \'ਤੇ ਪੂਰਾ ਦਿਨ';

  @override
  String marksInMonth(String month) {
    return '$month ਵਿੱਚ ਨਿਸ਼ਾਨ';
  }

  @override
  String noMarksInMonth(String month) {
    return '$month ਵਿੱਚ ਕੁਝ ਵੀ ਚਿੰਨ੍ਹਿਤ ਨਹੀਂ। ਨਿਸ਼ਾਨ ਜੋੜਨ ਲਈ ਇੱਕ ਤਾਰੀਖ ਟੈਪ ਕਰੋ।';
  }

  @override
  String get markStyleSectionTitle => 'ਨਿਸ਼ਾਨ ਸ਼ੈਲੀ';

  @override
  String get markStyleSectionHint =>
      'ਚਿੰਨ੍ਹਿਤ ਤਾਰੀਖਾਂ ਕਿਵੇਂ ਦਿਖਦੀਆਂ ਹਨ। ਹਰ ਨਿਸ਼ਾਨ \'ਤੇ ਲਾਗੂ ਹੁੰਦਾ ਹੈ।';

  @override
  String markStyleSemantic(String style) {
    return '$style ਨਿਸ਼ਾਨ ਸ਼ੈਲੀ';
  }

  @override
  String get dayCellToday => ', ਅੱਜ';

  @override
  String get dayCellAnd => 'ਅਤੇ';

  @override
  String dayCellMarkedSuffix(int count, String kinds) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ', $kinds ਚਿੰਨ੍ਹਿਤ, $count ਨਿਸ਼ਾਨ',
      one: ', $kinds ਚਿੰਨ੍ਹਿਤ, 1 ਨਿਸ਼ਾਨ',
    );
    return '$_temp0';
  }

  @override
  String get markEditorNoTimeWarning =>
      'ਘੱਟੋ-ਘੱਟ ਇੱਕ ਸਮਾਂ ਜੋੜੋ, ਜਾਂ \"ਕੋਈ ਸਮਾਂ ਨਹੀਂ\" ਚੁਣੋ।';

  @override
  String get notificationsOffWarning =>
      'Sadho ਲਈ ਸੂਚਨਾਵਾਂ ਬੰਦ ਹਨ, ਇਸ ਲਈ ਇਹ ਰੀਮਾਈਂਡਰ ਨਹੀਂ ਵੱਜੇਗਾ। ਇਹਨਾਂ ਨੂੰ ਆਪਣੇ ਫ਼ੋਨ ਦੀਆਂ ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਚਾਲੂ ਕਰੋ।';

  @override
  String get deleteMarkFallbackTitle => 'ਇਹ ਨਿਸ਼ਾਨ';

  @override
  String get deleteMarkQuestion => 'ਇਹ ਨਿਸ਼ਾਨ ਮਿਟਾਉਣਾ ਹੈ?';

  @override
  String deleteMarkRepeatsBody(String title) {
    return '$title ਅਤੇ ਇਸਦੀਆਂ ਸਾਰੀਆਂ ਦੁਹਰਾਈਆਂ ਮਿਟਾਉਣੀਆਂ ਹਨ? ਇਸਦੇ ਰੀਮਾਈਂਡਰ ਵੀ ਹਟਾ ਦਿੱਤੇ ਜਾਣਗੇ।';
  }

  @override
  String deleteMarkBody(String title) {
    return '$title ਮਿਟਾਉਣਾ ਹੈ? ਇਸਦੇ ਰੀਮਾਈਂਡਰ ਵੀ ਹਟਾ ਦਿੱਤੇ ਜਾਣਗੇ।';
  }

  @override
  String get newMark => 'ਨਵਾਂ ਨਿਸ਼ਾਨ';

  @override
  String get editMark => 'ਨਿਸ਼ਾਨ ਸੋਧੋ';

  @override
  String repeatFromNotice(String repeatSummary, String date) {
    return '$repeatSummary, $date ਤੋਂ। ਬਦਲਾਅ ਹਰ ਦੁਹਰਾਈ \'ਤੇ ਲਾਗੂ ਹੁੰਦੇ ਹਨ।';
  }

  @override
  String get markTypeSectionTitle => 'ਨਿਸ਼ਾਨ ਕਿਸਮ';

  @override
  String get iconSectionTitle => 'ਆਈਕਨ';

  @override
  String get iconNone => 'ਕੋਈ ਨਹੀਂ';

  @override
  String get labelFieldLabel => 'ਲੇਬਲ';

  @override
  String get detailsFieldLabel => 'ਵੇਰਵੇ / ਨੋਟਸ';

  @override
  String get remindMeAtSectionTitle => 'ਮੈਨੂੰ ਯਾਦ ਦਿਵਾਓ';

  @override
  String removeTimeTooltip(String time) {
    return '$time ਹਟਾਓ';
  }

  @override
  String get addTime => 'ਸਮਾਂ ਜੋੜੋ';

  @override
  String get repeatSectionTitle => 'ਦੁਹਰਾਓ';

  @override
  String get onHomeScreenSectionTitle => 'ਤੁਹਾਡੀ ਹੋਮ ਸਕ੍ਰੀਨ \'ਤੇ';

  @override
  String showFromTime(String time) {
    return '$time ਤੋਂ ਦਿਖਾਓ';
  }

  @override
  String get homeModeNoneExplain => 'ਨਿਸ਼ਾਨ ਸਿਰਫ਼ ਕੈਲੰਡਰ \'ਤੇ ਰਹਿੰਦਾ ਹੈ।';

  @override
  String get homeModeMorningExplain =>
      'ਉਸ ਸਮੇਂ ਹੋਮ \'ਤੇ ਇੱਕ ਕਾਰਡ ਦਿਖਾਈ ਦਿੰਦਾ ਹੈ। ਪੂਰਾ ਹੋਣ \'ਤੇ ਇਸਨੂੰ ਸਵਾਈਪ ਕਰੋ: ਇਹ ਅਗਲੀ ਦੁਹਰਾਈ \'ਤੇ ਵਾਪਸ ਆਉਂਦਾ ਹੈ।';

  @override
  String get homeModeAllDayExplain =>
      'ਇੱਕ ਕਾਰਡ ਹੋਮ \'ਤੇ ਪੂਰਾ ਦਿਨ ਪਿੰਨ ਰਹਿੰਦਾ ਹੈ (ਇਸਨੂੰ ਸਵਾਈਪ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਦਾ)।';

  @override
  String get tomorrow => 'ਕੱਲ੍ਹ';

  @override
  String get yesterday => 'ਬੀਤਿਆ ਕੱਲ੍ਹ';

  @override
  String get startAgain => 'ਮੁੜ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get settingsAction => 'ਸੈਟਿੰਗਾਂ';

  @override
  String get clockToolClockSubtitle => 'ਇੱਕ ਵੱਡਾ, ਲਾਈਵ ਸਮਾਂ ਅਤੇ ਤਾਰੀਖ';

  @override
  String get clockToolSunAlarmTitle => 'ਸੂਰਜ-ਅਧਾਰਿਤ ਅਲਾਰਮ';

  @override
  String get clockToolSunAlarmSubtitle =>
      'ਸੂਰਜ ਚੜ੍ਹਨ ਜਾਂ ਡੁੱਬਣ \'ਤੇ, ਆਫਸੈੱਟ ਨਾਲ ਜਾਗੋ';

  @override
  String get clockToolWorldClockTitle => 'ਵਿਸ਼ਵ ਘੜੀ';

  @override
  String get clockToolWorldClockSubtitle => 'ਅੰਮ੍ਰਿਤਸਰ, ਹਰਿਦੁਆਰ, ਲੰਡਨ ਅਤੇ ਹੋਰ';

  @override
  String get clockToolTimerTitle => 'ਸਾਧਨਾ ਅਤੇ ਵਰਤ ਟਾਈਮਰ';

  @override
  String get clockToolTimerSubtitle =>
      'ਆਰਤੀ, ਚਾਲੀਸਾ, ਪਾਠ, ਹਵਨ, ਜਾਂ ਸੂਰਜ ਡੁੱਬਣ ਤੱਕ';

  @override
  String get clockToolStopwatchTitle => 'ਪਾਠ ਸਟੌਪਵਾਚ';

  @override
  String get clockToolStopwatchSubtitle => 'ਸ਼ੁਰੂ ਕਰੋ, ਰੋਕੋ ਅਤੇ ਲੈਪ ਕਰੋ';

  @override
  String get sunEventSunrise => 'ਸੂਰਜ ਚੜ੍ਹਨਾ';

  @override
  String get sunEventSunset => 'ਸੂਰਜ ਡੁੱਬਣਾ';

  @override
  String offsetAtEvent(String event) {
    return '$event \'ਤੇ';
  }

  @override
  String offsetMinutesOnly(int m) {
    return '$m ਮਿੰਟ';
  }

  @override
  String offsetHoursOnly(int h) {
    return '$h ਘੰ';
  }

  @override
  String offsetHoursMinutes(int h, int m) {
    return '$h ਘੰ $m ਮਿੰਟ';
  }

  @override
  String offsetBefore(String amount) {
    return '$amount ਪਹਿਲਾਂ';
  }

  @override
  String offsetAfter(String amount) {
    return '$amount ਬਾਅਦ';
  }

  @override
  String get locationSourceDevice => 'ਤੁਹਾਡਾ ਟਿਕਾਣਾ';

  @override
  String get locationSourceSaved => 'ਤੁਹਾਡਾ ਆਖਰੀ ਜਾਣਿਆ ਟਿਕਾਣਾ';

  @override
  String get locationSourceFallback => 'ਅੰਮ੍ਰਿਤਸਰ (ਡਿਫਾਲਟ)';

  @override
  String get locSummaryDevice => 'ਤੁਹਾਡਾ ਟਿਕਾਣਾ ਵਰਤਿਆ ਜਾ ਰਿਹਾ ਹੈ';

  @override
  String get locSummarySaved => 'ਤੁਹਾਡਾ ਆਖਰੀ ਜਾਣਿਆ ਟਿਕਾਣਾ ਵਰਤਿਆ ਜਾ ਰਿਹਾ ਹੈ';

  @override
  String get locSummaryBlocked =>
      'ਅੰਮ੍ਰਿਤਸਰ ਵਰਤਿਆ ਜਾ ਰਿਹਾ ਹੈ। ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਟਿਕਾਣਾ ਬਲੌਕ ਹੈ।';

  @override
  String get locSummaryServiceOff =>
      'ਅੰਮ੍ਰਿਤਸਰ ਵਰਤਿਆ ਜਾ ਰਿਹਾ ਹੈ। ਸਟੀਕ ਸਮੇਂ ਲਈ ਟਿਕਾਣਾ ਚਾਲੂ ਕਰੋ।';

  @override
  String get locSummaryUnsupported => 'ਅੰਮ੍ਰਿਤਸਰ ਵਰਤਿਆ ਜਾ ਰਿਹਾ ਹੈ।';

  @override
  String get locSummaryDefault =>
      'ਅੰਮ੍ਰਿਤਸਰ ਵਰਤਿਆ ਜਾ ਰਿਹਾ ਹੈ। ਸਟੀਕ ਸਮੇਂ ਲਈ ਟਿਕਾਣੇ ਦੀ ਇਜਾਜ਼ਤ ਦਿਓ।';

  @override
  String get presetAarti => 'ਆਰਤੀ';

  @override
  String get presetChalisa => 'ਚਾਲੀਸਾ';

  @override
  String get presetPath => 'ਪਾਠ';

  @override
  String get presetHavan => 'ਹਵਨ';

  @override
  String get vratToSunset => 'ਵਰਤ → ਸੂਰਜ ਡੁੱਬਣਾ';

  @override
  String presetChipLabel(String label, int minutes) {
    return '$label · $minutes ਮਿੰਟ';
  }

  @override
  String get clockNoSunsetHere => 'ਇੱਥੇ ਹੁਣੇ ਗਿਣਨ ਲਈ ਕੋਈ ਸੂਰਜ ਡੁੱਬਣਾ ਨਹੀਂ ਹੈ।';

  @override
  String get clockSunsetPassedTomorrow =>
      'ਅੱਜ ਦਾ ਸੂਰਜ ਡੁੱਬਣਾ ਲੰਘ ਗਿਆ ਹੈ: ਕੱਲ੍ਹ ਲਈ ਗਿਣਿਆ ਜਾ ਰਿਹਾ ਹੈ।';

  @override
  String timerFinishedTitle(String label) {
    return '🔔 $label ਪੂਰਾ ਹੋਇਆ';
  }

  @override
  String get sunsetArrived => 'ਸੂਰਜ ਡੁੱਬ ਗਿਆ 🙏';

  @override
  String timerTimeUp(String label) {
    return 'ਤੁਹਾਡਾ $label ਸਮਾਂ ਪੂਰਾ ਹੋ ਗਿਆ ਹੈ 🙏';
  }

  @override
  String sunAlarmNotifTitle(String emoji, String event) {
    return '$emoji $event ਅਲਾਰਮ';
  }

  @override
  String sunAlarmNotifBody(String event, String time, String offset) {
    return '$event $time \'ਤੇ ਹੈ · $offset';
  }

  @override
  String get statusOn => 'ਚਾਲੂ';

  @override
  String get finished => 'ਪੂਰਾ ਹੋਇਆ';

  @override
  String get left => 'ਬਾਕੀ';

  @override
  String get paused => 'ਰੁਕਿਆ';

  @override
  String get runningStatus => 'ਚੱਲ ਰਿਹਾ ਹੈ';

  @override
  String get stoppedStatus => 'ਰੁਕ ਗਿਆ';

  @override
  String get lap => 'ਲੈਪ';

  @override
  String get lapTime => 'ਲੈਪ ਸਮਾਂ';

  @override
  String get total => 'ਕੁੱਲ';

  @override
  String get fastest => 'ਸਭ ਤੋਂ ਤੇਜ਼';

  @override
  String get slowest => 'ਸਭ ਤੋਂ ਹੌਲੀ';

  @override
  String get tapLapToMark => 'ਲੈਪ ਚਿੰਨ੍ਹਿਤ ਕਰਨ ਲਈ Lap ਟੈਪ ਕਰੋ।';

  @override
  String get startThenTapLap => 'Start ਕਰੋ, ਫਿਰ ਹਰ ਗੇੜ \'ਤੇ Lap ਟੈਪ ਕਰੋ।';

  @override
  String get allowNotificationsForAlarm =>
      'ਅਲਾਰਮ ਵੱਜਣ ਲਈ ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਸੂਚਨਾਵਾਂ ਚਾਲੂ ਕਰੋ।';

  @override
  String get alarmRingsAt => 'ਅਲਾਰਮ ਵੱਜੇਗਾ';

  @override
  String get alarmWouldRingAt => 'ਅਲਾਰਮ ਵੱਜਦਾ';

  @override
  String noEventToFollow(String event) {
    return 'ਇੱਥੇ ਹੁਣੇ ਪਾਲਣਾ ਕਰਨ ਲਈ ਕੋਈ $event ਨਹੀਂ ਹੈ।';
  }

  @override
  String get alarmOnLabel => 'ਅਲਾਰਮ ਚਾਲੂ';

  @override
  String get recalculatedDaily =>
      'ਸੂਰਜ ਦੇ ਚੱਲਣ ਨਾਲ ਹਰ ਰੋਜ਼ ਮੁੜ ਗਣਨਾ ਕੀਤੀ ਜਾਂਦੀ ਹੈ';

  @override
  String todayHereSunriseSunset(String rise, String set) {
    return 'ਇੱਥੇ ਅੱਜ: ਸੂਰਜ ਚੜ੍ਹਨਾ $rise · ਸੂਰਜ ਡੁੱਬਣਾ $set';
  }

  @override
  String get whenLabel => 'ਕਦੋਂ';

  @override
  String get minutesLabel => 'ਮਿੰਟ';

  @override
  String get upTo1440 => '1440 ਤੱਕ';

  @override
  String get before => 'ਪਹਿਲਾਂ';

  @override
  String get after => 'ਬਾਅਦ ਵਿੱਚ';

  @override
  String get useMyLocation => 'ਮੇਰਾ ਟਿਕਾਣਾ ਵਰਤੋ';

  @override
  String get couldNotReadPosition => ' · ਤੁਹਾਡੀ ਸਥਿਤੀ ਨਹੀਂ ਪੜ੍ਹ ਸਕਿਆ';

  @override
  String get timesUp => 'ਸਮਾਂ ਪੂਰਾ ਹੋਇਆ 🙏';

  @override
  String sunsetAtTime(String time) {
    return 'ਸੂਰਜ ਡੁੱਬਣਾ $time \'ਤੇ';
  }

  @override
  String cityInDays(int days) {
    return '$days ਦਿਨਾਂ ਵਿੱਚ';
  }

  @override
  String cityDaysAgo(int days) {
    return '$days ਦਿਨ ਪਹਿਲਾਂ';
  }

  @override
  String get citySameTime => 'ਤੁਹਾਡੇ ਵਾਂਗ ਹੀ ਸਮਾਂ';

  @override
  String cityAmountMinutes(int m) {
    return '$m ਮਿੰ';
  }

  @override
  String cityAmountHours(int h) {
    return '$h ਘੰ';
  }

  @override
  String cityAmountHoursMinutes(int h, int m) {
    return '$h ਘੰ $m ਮਿੰ';
  }

  @override
  String cityAheadOfYou(String amount) {
    return 'ਤੁਹਾਡੇ ਤੋਂ $amount ਅੱਗੇ';
  }

  @override
  String cityBehindYou(String amount) {
    return 'ਤੁਹਾਡੇ ਤੋਂ $amount ਪਿੱਛੇ';
  }

  @override
  String get traditionHindu => 'ਹਿੰਦੂ';

  @override
  String get traditionSikh => 'ਸਿੱਖ';

  @override
  String get traditionPlace => 'ਟਿਕਾਣੇ ਅਨੁਸਾਰ';

  @override
  String get todayLabelTithi => 'ਤਿਥੀ';

  @override
  String get todayLabelNakshatra => 'ਨਛੱਤਰ';

  @override
  String get todayLabelRahu => 'ਰਾਹੂ ਕਾਲ';

  @override
  String get todayLabelAbhijit => 'ਅਭਿਜੀਤ ਮੁਹੂਰਤ';

  @override
  String get todayLabelHukamnama => 'ਹੁਕਮਨਾਮਾ';

  @override
  String get todayLabelNitnem => 'ਨਿਤਨੇਮ ਬਾਕੀ';

  @override
  String get todayLabelGurpurab => 'ਅਗਲਾ ਗੁਰਪੁਰਬ';

  @override
  String get todayLabelFestival => 'ਸਥਾਨਕ ਤਿਉਹਾਰ';

  @override
  String get todayLabelWindow => 'ਸ਼ੁਭ ਸਮਾਂ';

  @override
  String get exampleTag => 'ਉਦਾਹਰਣ';

  @override
  String get exampleNote =>
      'ਉਦਾਹਰਣ ਚਿੰਨ੍ਹਿਤ ਮੁੱਲ ਪਲੇਸਹੋਲਡਰ ਹਨ: ਅਸਲ ਪੰਚਾਂਗ ਡਾਟਾ ਬਾਅਦ ਦੇ ਪੜਾਅ ਵਿੱਚ ਆਵੇਗਾ।';

  @override
  String liveNote(String where) {
    return 'ਸੂਰਜ ਚੜ੍ਹਨਾ ਅਤੇ ਡੁੱਬਣਾ ਤੁਹਾਡੇ ਟਿਕਾਣੇ ਲਈ ਕੱਢੇ ਗਏ ਹਨ। $where.';
  }

  @override
  String get greetingMorning => 'ਸ਼ੁਭ ਸਵੇਰ';

  @override
  String get greetingAfternoon => 'ਸ਼ੁਭ ਦੁਪਹਿਰ';

  @override
  String get greetingEvening => 'ਸ਼ੁਭ ਸ਼ਾਮ';

  @override
  String get greetingNight => 'ਸ਼ੁਭ ਰਾਤ';

  @override
  String get homeEmptyTitle => 'ਅੱਜ ਤੁਹਾਡੀ ਹੋਮ ਸਕ੍ਰੀਨ \'ਤੇ ਕੁਝ ਨਹੀਂ ਹੈ';

  @override
  String get homeEmptyBody =>
      'ਕੈਲੰਡਰ ਵਿੱਚ ਇੱਕ ਤਾਰੀਖ ਚਿੰਨ੍ਹਿਤ ਕਰੋ ਅਤੇ ਇਸਨੂੰ ਇੱਥੇ ਦੇਖਣ ਲਈ \"ਤੁਹਾਡੀ ਹੋਮ ਸਕ੍ਰੀਨ \'ਤੇ\" ਚੁਣੋ।';

  @override
  String get pinnedAllDay => 'ਪੂਰਾ ਦਿਨ ਪਿੰਨ ਕੀਤਾ';

  @override
  String get swipeToDismiss => 'ਅੱਜ ਲਈ ਹਟਾਉਣ ਵਾਸਤੇ ਸਵਾਈਪ ਕਰੋ';

  @override
  String doneForToday(String title) {
    return 'ਅੱਜ ਲਈ ਪੂਰਾ ਹੋਇਆ: $title';
  }

  @override
  String get undoAction => 'ਵਾਪਸ ਲਵੋ';

  @override
  String get doneForTodayLabel => 'ਅੱਜ ਲਈ ਪੂਰਾ ਹੋਇਆ';

  @override
  String get plansTitle => 'ਪਾਠ ਅਤੇ ਮੰਤਰ ਯੋਜਨਾਵਾਂ';

  @override
  String get addPlan => 'ਯੋਜਨਾ ਜੋੜੋ';

  @override
  String get dayStreak => 'ਦਿਨ ਦੀ ਲਗਾਤਾਰ ਲੜੀ';

  @override
  String activePlanCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ਸਰਗਰਮ ਯੋਜਨਾਵਾਂ',
      one: 'ਸਰਗਰਮ ਯੋਜਨਾ',
    );
    return '$_temp0';
  }

  @override
  String get noPlansYet => 'ਹਾਲੇ ਕੋਈ ਯੋਜਨਾ ਨਹੀਂ';

  @override
  String get plansEmptyBody =>
      'ਇੱਕ ਪਾਠ ਜਾਂ ਮੰਤਰ ਲਈ ਕਈ ਦਿਨਾਂ ਤੱਕ ਵਚਨਬੱਧ ਰਹੋ ਅਤੇ ਹਰ ਦਿਨ ਚਿੰਨ੍ਹਿਤ ਕਰੋ। ਇਹਨਾਂ ਵਿੱਚੋਂ ਕਿਸੇ ਇੱਕ ਨਾਲ ਸ਼ੁਰੂ ਕਰੋ, ਜਾਂ ਆਪਣਾ ਬਣਾਓ।';

  @override
  String get planOptionsTooltip => 'ਯੋਜਨਾ ਵਿਕਲਪ';

  @override
  String get deletePlanMenuItem => 'ਯੋਜਨਾ ਮਿਟਾਓ';

  @override
  String get deletePlanQuestion => 'ਯੋਜਨਾ ਮਿਟਾਉਣੀ ਹੈ?';

  @override
  String deletePlanBody(String title) {
    return '$title ਅਤੇ ਇਸਦੀ ਤਰੱਕੀ ਹਟਾ ਦਿੱਤੀ ਜਾਵੇਗੀ।';
  }

  @override
  String titledDaysTag(String title, int days) {
    return '$title · $days ਦਿਨ';
  }

  @override
  String completedOfDays(int completed, int total) {
    return 'ਪੂਰਾ · $total ਵਿੱਚੋਂ $completed ਦਿਨ';
  }

  @override
  String ofDays(int completed, int total) {
    return '$total ਵਿੱਚੋਂ $completed ਦਿਨ';
  }

  @override
  String get doneTodayButton => 'ਅੱਜ ਪੂਰਾ ਹੋਇਆ';

  @override
  String get markTodayDone => 'ਅੱਜ ਪੂਰਾ ਹੋਇਆ ਚਿੰਨ੍ਹਿਤ ਕਰੋ';

  @override
  String get newPlanTitle => 'ਨਵੀਂ ਯੋਜਨਾ';

  @override
  String get newPlanSubtitle =>
      'ਇੱਕ ਪਾਠ ਜਾਂ ਮੰਤਰ ਚੁਣੋ ਅਤੇ ਤੁਸੀਂ ਇਸਨੂੰ ਕਿੰਨੇ ਦਿਨ ਜਾਰੀ ਰੱਖੋਗੇ।';

  @override
  String get paathOrMantraLabel => 'ਪਾਠ ਜਾਂ ਮੰਤਰ';

  @override
  String get giveThePlanAName => 'ਯੋਜਨਾ ਨੂੰ ਇੱਕ ਨਾਮ ਦਿਓ';

  @override
  String chooseDaysRange(int min, int max) {
    return '$min ਤੋਂ $max ਦਿਨ ਚੁਣੋ';
  }

  @override
  String get forHowManyDays => 'ਕਿੰਨੇ ਦਿਨਾਂ ਲਈ?';

  @override
  String get daysFieldLabel => 'ਦਿਨ';

  @override
  String get startPlanButton => 'ਯੋਜਨਾ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get planKindPaath => 'ਪਾਠ';

  @override
  String get planKindMantra => 'ਮੰਤਰ';

  @override
  String get profileTitle => 'ਪ੍ਰੋਫਾਈਲ';

  @override
  String get sadhanaSettingsTitle => 'ਸਾਧਨਾ ਸੈਟਿੰਗਾਂ';

  @override
  String get validEmailError => 'ਇੱਕ ਵੈਧ ਈਮੇਲ ਪਤਾ ਦਰਜ ਕਰੋ';

  @override
  String nameTooLong(int max) {
    return 'ਇਸਨੂੰ $max ਅੱਖਰਾਂ ਤੋਂ ਘੱਟ ਰੱਖੋ';
  }

  @override
  String get enterCurrentPassword => 'ਆਪਣਾ ਮੌਜੂਦਾ ਪਾਸਵਰਡ ਦਰਜ ਕਰੋ';

  @override
  String passwordTooShort(int min) {
    return 'ਘੱਟੋ-ਘੱਟ $min ਅੱਖਰ ਵਰਤੋ';
  }

  @override
  String get passwordAlreadyUsed =>
      'ਅਜਿਹਾ ਪਾਸਵਰਡ ਚੁਣੋ ਜੋ ਤੁਸੀਂ ਪਹਿਲਾਂ ਨਹੀਂ ਵਰਤਿਆ';

  @override
  String get passwordsDontMatch => 'ਦੋਵੇਂ ਪਾਸਵਰਡ ਮੇਲ ਨਹੀਂ ਖਾਂਦੇ';

  @override
  String get changePasswordTitle => 'ਪਾਸਵਰਡ ਬਦਲੋ';

  @override
  String get accountsLaterNote =>
      'ਖਾਤੇ ਬਾਅਦ ਦੇ ਪੜਾਅ ਵਿੱਚ ਆਉਣਗੇ; ਉਦੋਂ ਤੱਕ ਇਹ ਸਿਰਫ਼ ਤੁਹਾਡੀਆਂ ਐਂਟਰੀਆਂ ਦੀ ਜਾਂਚ ਕਰਦਾ ਹੈ ਅਤੇ ਕੁਝ ਨਹੀਂ ਬਦਲਦਾ।';

  @override
  String get currentPasswordLabel => 'ਮੌਜੂਦਾ ਪਾਸਵਰਡ';

  @override
  String get newPasswordLabel => 'ਨਵਾਂ ਪਾਸਵਰਡ';

  @override
  String get confirmNewPasswordLabel => 'ਨਵੇਂ ਪਾਸਵਰਡ ਦੀ ਪੁਸ਼ਟੀ ਕਰੋ';

  @override
  String get showPasswords => 'ਪਾਸਵਰਡ ਦਿਖਾਓ';

  @override
  String get updatePasswordButton => 'ਪਾਸਵਰਡ ਅੱਪਡੇਟ ਕਰੋ';

  @override
  String get stepAddName => 'ਆਪਣਾ ਨਾਮ ਜੋੜੋ';

  @override
  String get stepAddEmail => 'ਆਪਣੀ ਈਮੇਲ ਜੋੜੋ';

  @override
  String get stepPickTradition => 'ਹੋਮ \'ਤੇ ਆਪਣੀ ਪਰੰਪਰਾ ਚੁਣੋ';

  @override
  String get stepTurnOnReminder => 'ਰੋਜ਼ਾਨਾ ਰੀਮਾਈਂਡਰ ਚਾਲੂ ਕਰੋ';

  @override
  String get stepStartPlan => 'ਇੱਕ ਪਾਠ ਜਾਂ ਮੰਤਰ ਯੋਜਨਾ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get profileCompletionTitle => 'ਪ੍ਰੋਫਾਈਲ ਸੰਪੂਰਨਤਾ';

  @override
  String get profileCompleteReward =>
      'ਪ੍ਰੋਫਾਈਲ ਪੂਰੀ! ਪ੍ਰੀਮੀਅਮ ਲਾਂਚ ਹੋਣ \'ਤੇ ਤੁਹਾਡਾ ਮੁਫ਼ਤ ਪ੍ਰੀਮੀਅਮ ਇਨਾਮ ਉਡੀਕ ਕਰੇਗਾ।';

  @override
  String get reachRewardNote =>
      'ਲਾਂਚ ਹੋਣ \'ਤੇ ਮੁਫ਼ਤ ਪ੍ਰੀਮੀਅਮ ਪਾਉਣ ਲਈ 100% ਤੱਕ ਪਹੁੰਚੋ।';

  @override
  String get aboutTitle => 'ਬਾਰੇ';

  @override
  String get appLabel => 'ਐਪ';

  @override
  String get websiteLabel => 'ਵੈੱਬਸਾਈਟ';

  @override
  String get versionLabel => 'ਵਰਜਨ';

  @override
  String get passwordWillWorkLater =>
      'ਖਾਤੇ ਜੁੜਨ ਤੋਂ ਬਾਅਦ ਪਾਸਵਰਡ ਬਦਲਣਾ ਕੰਮ ਕਰੇਗਾ।';

  @override
  String get signedOut => 'ਸਾਈਨ ਆਊਟ ਹੋ ਗਿਆ';

  @override
  String get notSignedInYet =>
      'ਤੁਸੀਂ ਹਾਲੇ ਸਾਈਨ ਇਨ ਨਹੀਂ ਹੋ: ਖਾਤੇ ਬਾਅਦ ਦੇ ਪੜਾਅ ਵਿੱਚ ਆਉਣਗੇ। ਤੁਹਾਡਾ ਡਾਟਾ ਇਸ ਫ਼ੋਨ \'ਤੇ ਰਹਿੰਦਾ ਹੈ।';

  @override
  String get accountTitle => 'ਖਾਤਾ';

  @override
  String get signOutButton => 'ਸਾਈਨ ਆਊਟ ਕਰੋ';

  @override
  String get backupSaved => 'ਬੈਕਅੱਪ ਸੰਭਾਲਿਆ ਗਿਆ';

  @override
  String get backupCancelled => 'ਬੈਕਅੱਪ ਰੱਦ ਕੀਤਾ ਗਿਆ';

  @override
  String get couldNotSaveBackup =>
      'ਬੈਕਅੱਪ ਸੰਭਾਲ ਨਹੀਂ ਸਕਿਆ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get backupNotSadho => 'ਉਹ ਫਾਈਲ Sadho ਬੈਕਅੱਪ ਨਹੀਂ ਹੈ।';

  @override
  String get couldNotReadFile => 'ਉਹ ਫਾਈਲ ਪੜ੍ਹ ਨਹੀਂ ਸਕਿਆ।';

  @override
  String get backupDamaged => 'ਬੈਕਅੱਪ ਫਾਈਲ ਖਰਾਬ ਹੈ।';

  @override
  String get backupTooNew =>
      'ਇਹ ਬੈਕਅੱਪ Sadho ਦੇ ਨਵੇਂ ਵਰਜਨ ਦੁਆਰਾ ਬਣਾਇਆ ਗਿਆ ਸੀ। ਪਹਿਲਾਂ ਐਪ ਅੱਪਡੇਟ ਕਰੋ।';

  @override
  String get backupNoData => 'ਉਸ ਬੈਕਅੱਪ ਵਿੱਚ ਕੋਈ Sadho ਡਾਟਾ ਨਹੀਂ ਹੈ।';

  @override
  String get backupTooBig => 'ਉਹ ਫਾਈਲ Sadho ਬੈਕਅੱਪ ਹੋਣ ਲਈ ਬਹੁਤ ਵੱਡੀ ਹੈ।';

  @override
  String madeOnSuffix(String date) {
    return ' $date ਨੂੰ ਬਣਾਇਆ ਗਿਆ';
  }

  @override
  String restoreBackupBody(String made, int count) {
    return 'ਇੱਕ ਬੈਕਅੱਪ$made ਜਿਸ ਵਿੱਚ $count ਸੰਭਾਲੀਆਂ ਚੀਜ਼ਾਂ ਹਨ। ਇਹ ਇਸ ਫ਼ੋਨ \'ਤੇ ਮੌਜੂਦ ਚੀਜ਼ਾਂ ਦੀ ਥਾਂ ਲਵੇਗਾ: ਨਿਸ਼ਾਨ, ਯੋਜਨਾਵਾਂ, ਮੰਤਰ, ਆਵਾਜ਼ ਸਿਖਲਾਈ ਅਤੇ ਸੈਟਿੰਗਾਂ।';
  }

  @override
  String get restoreThisBackup => 'ਇਹ ਬੈਕਅੱਪ ਬਹਾਲ ਕਰਨਾ ਹੈ?';

  @override
  String get backupRestoredTitle => 'ਬੈਕਅੱਪ ਬਹਾਲ ਕੀਤਾ ਗਿਆ';

  @override
  String get backupRestoredBody =>
      'Sadho ਤੁਹਾਡੇ ਬਹਾਲ ਕੀਤੇ ਡਾਟੇ ਨਾਲ ਮੁੜ ਲੋਡ ਹੋਵੇਗਾ।';

  @override
  String get backupRestoreTitle => 'ਬੈਕਅੱਪ ਅਤੇ ਬਹਾਲੀ';

  @override
  String get backupExplain =>
      'ਆਪਣੇ ਨਿਸ਼ਾਨ, ਯੋਜਨਾਵਾਂ, ਮੰਤਰ, ਆਵਾਜ਼ ਸਿਖਲਾਈ ਅਤੇ ਸੈਟਿੰਗਾਂ ਨੂੰ ਆਪਣੀ ਪਸੰਦ ਦੀ ਫਾਈਲ ਵਿੱਚ ਸੰਭਾਲੋ (Drive, Files, ਆਪਣੇ ਆਪ ਨੂੰ ਈਮੇਲ ਕਰੋ)। ਇਸਨੂੰ ਇਸ ਜਾਂ ਕਿਸੇ ਹੋਰ ਫ਼ੋਨ \'ਤੇ ਬਹਾਲ ਕਰੋ।';

  @override
  String get exportButton => 'ਐਕਸਪੋਰਟ';

  @override
  String get restoreButton => 'ਬਹਾਲ ਕਰੋ';

  @override
  String get cloudSyncTitle => 'ਕਲਾਊਡ ਸਿੰਕ';

  @override
  String get comingLater => 'ਬਾਅਦ ਵਿੱਚ ਆਵੇਗਾ';

  @override
  String get saveBackupDialogTitle => 'ਆਪਣਾ Sadho ਬੈਕਅੱਪ ਸੰਭਾਲੋ';

  @override
  String get chooseBackupDialogTitle => 'ਇੱਕ Sadho ਬੈਕਅੱਪ ਚੁਣੋ';

  @override
  String get areYouSure => 'ਕੀ ਤੁਸੀਂ ਯਕੀਨੀ ਹੋ?';

  @override
  String get deleteAccountWarning =>
      'ਇਹ ਤੁਹਾਡਾ ਖਾਤਾ ਅਤੇ ਇਸ ਫ਼ੋਨ \'ਤੇ ਸੰਭਾਲਿਆ ਸਭ ਕੁਝ ਹਟਾਉਂਦਾ ਹੈ: ਤੁਹਾਡੀ ਪ੍ਰੋਫਾਈਲ, ਨਿਸ਼ਾਨ, ਯੋਜਨਾਵਾਂ, ਮੰਤਰ, ਆਵਾਜ਼ ਸਿਖਲਾਈ ਅਤੇ ਸੈਟਿੰਗਾਂ। ਇਸਨੂੰ ਵਾਪਸ ਨਹੀਂ ਲਿਆ ਜਾ ਸਕਦਾ।';

  @override
  String get yesAction => 'ਹਾਂ';

  @override
  String get noAction => 'ਨਹੀਂ';

  @override
  String get dangerZoneTitle => 'ਖ਼ਤਰਾ ਖੇਤਰ';

  @override
  String get deleteAccountExplain =>
      'ਆਪਣਾ ਖਾਤਾ ਮਿਟਾਉਣ ਨਾਲ ਤੁਹਾਡੀ ਪ੍ਰੋਫਾਈਲ ਅਤੇ ਇਸ ਫ਼ੋਨ \'ਤੇ ਸੰਭਾਲਿਆ ਸਭ ਕੁਝ ਮਿਟ ਜਾਂਦਾ ਹੈ। ਜੇ ਤੁਸੀਂ ਇਸਨੂੰ ਵਾਪਸ ਚਾਹੁੰਦੇ ਹੋ ਤਾਂ ਪਹਿਲਾਂ ਬੈਕਅੱਪ ਐਕਸਪੋਰਟ ਕਰੋ।';

  @override
  String get deleteAccountButton => 'ਖਾਤਾ ਮਿਟਾਓ';

  @override
  String get profileSaved => 'ਪ੍ਰੋਫਾਈਲ ਸੰਭਾਲੀ ਗਈ';

  @override
  String get yourDetailsTitle => 'ਤੁਹਾਡੇ ਵੇਰਵੇ';

  @override
  String get nameLabel => 'ਨਾਮ';

  @override
  String get emailLabel => 'ਈਮੇਲ';

  @override
  String get dailyReminderTitle => 'ਰੋਜ਼ਾਨਾ ਰੀਮਾਈਂਡਰ';

  @override
  String get dailySadhanaReminder => 'ਰੋਜ਼ਾਨਾ ਸਾਧਨਾ ਰੀਮਾਈਂਡਰ';

  @override
  String get reminderOff => 'ਬੰਦ';

  @override
  String everyDayAt(String time) {
    return 'ਹਰ ਰੋਜ਼ $time ਵਜੇ';
  }

  @override
  String get allowNotificationsForReminder =>
      'ਰੀਮਾਈਂਡਰ ਵੱਜਣ ਲਈ ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਸੂਚਨਾਵਾਂ ਚਾਲੂ ਕਰੋ।';

  @override
  String get timeLabel => 'ਸਮਾਂ';

  @override
  String get themeTitle => 'ਥੀਮ';

  @override
  String get lightMode => 'ਲਾਈਟ';

  @override
  String get darkMode => 'ਡਾਰਕ';

  @override
  String get systemMode => 'ਸਿਸਟਮ';

  @override
  String get coloursTitle => 'ਰੰਗ';

  @override
  String paletteSemantic(String name) {
    return '$name ਰੰਗ';
  }

  @override
  String get paletteMarigoldName => 'ਗੇਂਦਾ';

  @override
  String get paletteMarigoldBlurb => 'ਨਿੱਘਾ ਕੇਸਰੀ ਅਤੇ ਡੂੰਘਾ ਨੀਲਾ';

  @override
  String get paletteSandalwoodName => 'ਚੰਦਨ';

  @override
  String get paletteSandalwoodBlurb => 'ਨਰਮ ਚੰਦਨ ਭੂਰਾ ਅਤੇ ਮਿੱਟੀ';

  @override
  String get paletteTulsiName => 'ਤੁਲਸੀ ਹਰਾ';

  @override
  String get paletteTulsiBlurb => 'ਸ਼ਾਂਤ ਪਵਿੱਤਰ-ਤੁਲਸੀ ਹਰਾ';

  @override
  String get paletteTwilightName => 'ਸੰਧਿਆ ਨੀਲਾ';

  @override
  String get paletteTwilightBlurb => 'ਦੀਵਾ-ਚਮਕ ਸੁਨਹਿਰੀ ਨਾਲ ਸੰਧਿਆ ਨੀਲਾ';

  @override
  String get paletteLotusName => 'ਕਮਲ ਗੁਲਾਬੀ';

  @override
  String get paletteLotusBlurb => 'ਕੋਮਲ ਕਮਲ ਗੁਲਾਬੀ ਅਤੇ ਪੱਤਾ ਹਰਾ';

  @override
  String get sadhanaTimeNotifTitle => '🪔 ਤੁਹਾਡੀ ਸਾਧਨਾ ਦਾ ਸਮਾਂ';

  @override
  String get sadhanaTimeNotifBody =>
      'ਆਪਣੇ ਪਾਠ ਜਾਂ ਮੰਤਰ ਲਈ ਕੁਝ ਸ਼ਾਂਤ ਮਿੰਟ ਕੱਢੋ 🙏';

  @override
  String get comingSoon => 'ਜਲਦੀ ਆ ਰਿਹਾ ਹੈ';

  @override
  String get trainAction => 'ਸਿਖਲਾਈ ਦਿਓ';

  @override
  String get onboardingTitle => 'Sadho ਵਿੱਚ ਤੁਹਾਡਾ ਸਵਾਗਤ ਹੈ';

  @override
  String get onboardingSubtitle =>
      'ਸ਼ੁਰੂ ਕਰਨ ਲਈ ਆਪਣੀ ਭਾਸ਼ਾ ਅਤੇ ਪਰੰਪਰਾ ਚੁਣੋ। ਤੁਸੀਂ ਦੋਵਾਂ ਨੂੰ ਬਾਅਦ ਵਿੱਚ ਪ੍ਰੋਫਾਈਲ ਵਿੱਚ ਬਦਲ ਸਕਦੇ ਹੋ।';

  @override
  String get traditionHeading => 'ਪਰੰਪਰਾ';

  @override
  String get continueAction => 'ਜਾਰੀ ਰੱਖੋ';

  @override
  String get stopAlert => 'ਰੋਕੋ';

  @override
  String get repeatLabel => 'ਦੁਹਰਾਓ';

  @override
  String get repeatOnce => 'ਇੱਕ ਵਾਰ';

  @override
  String soundRepeatTimes(int times) {
    return '$times ਵਾਰ';
  }

  @override
  String get repeatUntilStopped => 'ਰੋਕਣ ਤੱਕ';

  @override
  String vibrationRepeatUntilStopped(int seconds) {
    return 'ਹਰ $seconds ਸਕਿੰਟ, ਰੋਕਣ ਤੱਕ';
  }

  @override
  String get keepScreenOnLabel => 'ਗਿਣਤੀ ਦੌਰਾਨ ਸਕ੍ਰੀਨ ਚਾਲੂ ਰੱਖੋ';

  @override
  String get keepScreenOnSubtitle =>
      'ਸੈਸ਼ਨ ਚੱਲਦੇ ਸਮੇਂ ਸਕ੍ਰੀਨ ਬੰਦ ਨਹੀਂ ਹੁੰਦੀ। ਪਾਵਰ ਬਟਨ ਨਾਲ ਫ਼ੋਨ ਫਿਰ ਵੀ ਲੌਕ ਹੁੰਦਾ ਹੈ; ਤਦ ਸਮੇਂ ਜਾਂ ਲੈਅ ਵਾਲਾ ਸੈਸ਼ਨ ਪੂਰਾ ਹੋਣ \'ਤੇ ਅਲਾਰਮ ਵਾਂਗ ਵੱਜਦਾ ਹੈ।';

  @override
  String get alarmMayBeLate =>
      'ਅਲਾਰਮ ਥੋੜ੍ਹਾ ਦੇਰ ਨਾਲ ਵੱਜ ਸਕਦਾ ਹੈ (ਸਹੀ ਅਲਾਰਮ ਬੰਦ ਹਨ)।';

  @override
  String get exactAlarmNotice =>
      'ਸਕ੍ਰੀਨ ਬੰਦ ਹੋਣ \'ਤੇ ਵੀ ਠੀਕ ਸਮੇਂ ਵੱਜਣ ਲਈ, Sadho ਨੂੰ ਸਹੀ ਅਲਾਰਮ ਦੀ ਇਜਾਜ਼ਤ ਦਿਓ।';

  @override
  String get fullScreenNotice =>
      'ਪੂਰਾ ਸੈਸ਼ਨ ਲੌਕ ਸਕ੍ਰੀਨ \'ਤੇ ਦਿਖਾਉਣ ਲਈ, ਫੁੱਲ-ਸਕ੍ਰੀਨ ਸੂਚਨਾਵਾਂ ਦੀ ਇਜਾਜ਼ਤ ਦਿਓ।';

  @override
  String get allowAction => 'ਇਜਾਜ਼ਤ ਦਿਓ';

  @override
  String channelSadhanaAlarmName(String sound) {
    return 'ਸਾਧਨਾ ਅਲਾਰਮ · $sound';
  }

  @override
  String get channelSadhanaAlarmSilentName => 'ਸਾਧਨਾ ਅਲਾਰਮ · ਚੁੱਪ';

  @override
  String get channelNoVibration => 'ਕੰਪਨ ਨਹੀਂ';

  @override
  String get channelSadhanaAlarmDesc =>
      'ਸਮੇਂ ਜਾਂ ਲੈਅ ਵਾਲਾ ਸੈਸ਼ਨ ਪੂਰਾ ਹੋਣ \'ਤੇ ਵੱਜਦਾ ਹੈ';

  @override
  String get alarmScreenSadhanaTitle => 'ਸਾਧਨਾ ਪੂਰੀ 🙏';

  @override
  String get alarmScreenTimerTitle => 'ਟਾਈਮਰ ਪੂਰਾ ਹੋਇਆ';

  @override
  String get alarmScreenSunTitle => 'ਸੂਰਜ ਅਲਾਰਮ';

  @override
  String get alarmScreenUnlock => 'Sadho ਖੋਲ੍ਹਣ ਲਈ ਅਨਲੌਕ ਕਰੋ';

  @override
  String get alarmScreenUnlockHint =>
      'ਐਪ ਦੇ ਬਾਕੀ ਹਿੱਸੇ ਲਈ ਫ਼ੋਨ ਅਨਲੌਕ ਹੋਣਾ ਚਾਹੀਦਾ ਹੈ।';

  @override
  String get alarmsReliabilityTitle => 'ਅਲਾਰਮ ਅਤੇ ਭਰੋਸੇਯੋਗਤਾ';

  @override
  String get alarmsReliabilityIntro =>
      'ਸਕ੍ਰੀਨ ਬੰਦ ਹੋਣ \'ਤੇ ਵੀ ਅਲਾਰਮ ਸਮੇਂ ਸਿਰ ਵੱਜਣ ਲਈ ਫ਼ੋਨ ਨੂੰ ਇਹ ਇਜਾਜ਼ਤਾਂ ਦੇਣੀਆਂ ਪੈਣਗੀਆਂ। ਠੀਕ ਕਰੋ ਸਹੀ ਸੈਟਿੰਗ ਪੰਨਾ ਖੋਲ੍ਹਦਾ ਹੈ।';

  @override
  String get alarmsReliabilityAllOk => 'ਅਲਾਰਮ ਸਮੇਂ ਸਿਰ ਵੱਜਣ ਲਈ ਸਭ ਤਿਆਰ ਹੈ';

  @override
  String get alarmsReliabilityAttention => 'ਕੁਝ ਧਿਆਨ ਮੰਗਦਾ ਹੈ';

  @override
  String get healthOk => 'ਠੀਕ ਹੈ';

  @override
  String get healthNeedsAttention => 'ਧਿਆਨ ਦਿਓ';

  @override
  String get healthFix => 'ਠੀਕ ਕਰੋ';

  @override
  String get healthNotificationsTitle => 'ਸੂਚਨਾਵਾਂ ਦੀ ਇਜਾਜ਼ਤ';

  @override
  String get healthNotificationsBody =>
      'ਅਲਾਰਮ ਅਤੇ ਰੀਮਾਈਂਡਰ ਸੂਚਨਾ ਵਜੋਂ ਆਉਂਦੇ ਹਨ।';

  @override
  String get healthExactTitle => 'ਸਹੀ ਅਲਾਰਮ ਦੀ ਇਜਾਜ਼ਤ';

  @override
  String get healthExactBody => 'ਠੀਕ ਉਸੇ ਸਕਿੰਟ ਵੱਜਦਾ ਹੈ, ਦੇਰ ਨਾਲ ਨਹੀਂ।';

  @override
  String get healthFullScreenTitle => 'ਲੌਕ ਸਕ੍ਰੀਨ \'ਤੇ ਅਲਾਰਮ ਦਿਖਾਓ';

  @override
  String get healthFullScreenBody =>
      'ਫ਼ੋਨ ਲੌਕ ਹੋਣ \'ਤੇ ਵੀ ਪੂਰਾ ਹੋਇਆ ਅਲਾਰਮ ਦਿਖਦਾ ਹੈ।';

  @override
  String get healthBatteryTitle => 'ਬੈਟਰੀ: ਐਪ ਪਾਬੰਦ ਨਹੀਂ';

  @override
  String get healthBatteryBody =>
      'ਬੈਟਰੀ ਵਿੱਚ ਬਿਨਾਂ ਪਾਬੰਦੀ ਚੁਣੋ (ਜਾਂ ਘੱਟੋ-ਘੱਟ ਪਾਬੰਦ ਨਹੀਂ), ਤਾਂ ਜੋ ਫ਼ੋਨ ਅਲਾਰਮ ਨਾ ਰੋਕੇ।';

  @override
  String get healthBatterySamsungHint =>
      'Samsung: ਸੈਟਿੰਗਾਂ › ਬੈਟਰੀ › ਬੈਕਗ੍ਰਾਊਂਡ ਵਰਤੋਂ ਸੀਮਾਵਾਂ ਵਿੱਚ, Sadho ਨੂੰ “ਸਲੀਪਿੰਗ ਐਪਸ” ਅਤੇ “ਡੀਪ ਸਲੀਪਿੰਗ ਐਪਸ” ਤੋਂ ਹਟਾਓ, ਅਤੇ ਬੈਟਰੀ ਵਰਤੋਂ “ਬਿਨਾਂ ਪਾਬੰਦੀ” ਕਰੋ।';

  @override
  String get alarmExplainerOk =>
      'ਇਹ ਸੈਸ਼ਨ ਪੂਰਾ ਹੋਣ \'ਤੇ ਅਲਾਰਮ ਵਾਂਗ ਵੱਜੇਗਾ, ਸਕ੍ਰੀਨ ਜਾਂ ਐਪ ਬੰਦ ਹੋਵੇ ਤਾਂ ਵੀ।';

  @override
  String get alarmExplainerAttention =>
      'ਇਹ ਸੈਸ਼ਨ ਪੂਰਾ ਹੋਣ \'ਤੇ ਅਲਾਰਮ ਵਾਂਗ ਵੱਜੇਗਾ, ਪਰ ਸਮੇਂ ਸਿਰ ਵੱਜਣ ਲਈ ਫ਼ੋਨ ਦੀ ਇੱਕ ਸੈਟਿੰਗ ਬਦਲਣੀ ਪਵੇਗੀ।';

  @override
  String get alarmExplainerCheck => 'ਜਾਂਚੋ';

  @override
  String get customTimerName => 'ਕਸਟਮ ਟਾਈਮਰ';

  @override
  String customChipLabel(String duration) {
    return 'ਕਸਟਮ · $duration';
  }

  @override
  String get customTimerTitle => 'ਆਪਣਾ ਸਮਾਂ';

  @override
  String get customTimerRange => '1 ਸਕਿੰਟ ਤੋਂ 24 ਘੰਟੇ ਤੱਕ ਚੁਣੋ।';

  @override
  String durationHours(int hours) {
    return '$hours ਘੰਟੇ';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes ਮਿੰਟ';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds ਸਕਿੰਟ';
  }

  @override
  String collapseSection(String section) {
    return '$section ਲੁਕਾਓ';
  }

  @override
  String expandSection(String section) {
    return '$section ਦਿਖਾਓ';
  }

  @override
  String get summaryVibrationOn => 'ਕੰਬਣੀ ਚਾਲੂ';

  @override
  String get summaryVibrationOff => 'ਕੰਬਣੀ ਬੰਦ';

  @override
  String get summarySoundOff => 'ਆਵਾਜ਼ ਬੰਦ';

  @override
  String get summaryNotSet => 'ਤੈਅ ਨਹੀਂ';

  @override
  String get clockToolNotepadTitle => 'ਨੋਟਪੈਡ';

  @override
  String get clockToolNotepadSubtitle => 'ਨੋਟ, ਇਸੇ ਫ਼ੋਨ \'ਤੇ ਸੰਭਾਲੇ';

  @override
  String get notesSearchHint => 'ਨੋਟ ਖੋਜੋ';

  @override
  String get notesEmpty => 'ਹਾਲੇ ਕੋਈ ਨੋਟ ਨਹੀਂ। ਲਿਖਣ ਲਈ + ਦਬਾਓ।';

  @override
  String notesNoMatch(String query) {
    return '“$query” ਨਾਲ ਕੋਈ ਨੋਟ ਮੇਲ ਨਹੀਂ ਖਾਂਦਾ।';
  }

  @override
  String get noteNew => 'ਨਵਾਂ ਨੋਟ';

  @override
  String get noteEdit => 'ਨੋਟ';

  @override
  String get noteTitleHint => 'ਸਿਰਲੇਖ (ਵਿਕਲਪਿਕ)';

  @override
  String get noteTextHint => 'ਇੱਥੇ ਲਿਖੋ…';

  @override
  String get noteUntitled => 'ਖਾਲੀ ਨੋਟ';

  @override
  String noteCreatedAt(String when) {
    return 'ਬਣਾਇਆ $when';
  }

  @override
  String noteEditedAt(String when) {
    return 'ਬਦਲਿਆ $when';
  }

  @override
  String get noteSavedAsYouType => 'ਲਿਖਦੇ ਸਮੇਂ ਸੰਭਾਲਿਆ ਜਾਂਦਾ ਹੈ';

  @override
  String get noteDelete => 'ਨੋਟ ਮਿਟਾਓ';

  @override
  String get noteDeleteQuestion => 'ਕੀ ਇਹ ਨੋਟ ਮਿਟਾਉਣਾ ਹੈ?';

  @override
  String noteDeleteBody(String title) {
    return '“$title” ਇਸ ਫ਼ੋਨ ਤੋਂ ਹਟਾ ਦਿੱਤਾ ਜਾਵੇਗਾ। ਇਹ ਵਾਪਸ ਨਹੀਂ ਹੋ ਸਕਦਾ।';
  }

  @override
  String get paletteHighContrastName => 'ਉੱਚ ਕੰਟ੍ਰਾਸਟ';

  @override
  String get paletteHighContrastBlurb => 'ਸਭ ਤੋਂ ਵੱਧ ਫ਼ਰਕ, ਸੌਖਾ ਪੜ੍ਹਨ ਲਈ';

  @override
  String get malaNotificationChannel => 'ਮਾਲਾ ਕਾਊਂਟਰ';

  @override
  String malaNotificationTitle(String count, String target) {
    return 'ਮਾਲਾ · $count / $target';
  }

  @override
  String malaNotificationTitleCount(String count) {
    return 'ਮਾਲਾ · $count';
  }

  @override
  String get malaNotificationRunning =>
      'ਗਿਣਨ ਲਈ ਵਾਲੀਅਮ ਕੁੰਜੀ ਦਬਾਓ, ਸਕ੍ਰੀਨ ਬੰਦ ਹੋਣ \'ਤੇ ਵੀ।';

  @override
  String get malaNotificationDone => 'ਟੀਚਾ ਪੂਰਾ 🙏';

  @override
  String get malaRingTitle => '🔔 ਮਾਲਾ ਪੂਰੀ';

  @override
  String malaRingBody(int target) {
    return 'ਤੁਸੀਂ $target ਦਾ ਟੀਚਾ ਪੂਰਾ ਕੀਤਾ 🙏';
  }

  @override
  String get malaScreenOffUnavailable =>
      'ਇਸ ਫ਼ੋਨ \'ਤੇ ਸਕ੍ਰੀਨ ਬੰਦ ਹੋਣ \'ਤੇ ਗਿਣਤੀ ਸ਼ੁਰੂ ਨਹੀਂ ਹੋ ਸਕੀ। ਵਾਲੀਅਮ ਕੁੰਜੀਆਂ ਸਿਰਫ਼ ਉਦੋਂ ਗਿਣਨਗੀਆਂ ਜਦੋਂ Sadho ਖੁੱਲ੍ਹਾ ਹੋਵੇ।';

  @override
  String get pressVolumeKeysScreenOff =>
      'ਵਾਲੀਅਮ ਕੁੰਜੀਆਂ ਗਿਣਦੀਆਂ ਹਨ, ਸਕ੍ਰੀਨ ਬੰਦ ਹੋਣ \'ਤੇ ਵੀ';

  @override
  String get malaScreenOffLabel => 'ਸਕ੍ਰੀਨ ਬੰਦ ਹੋਣ \'ਤੇ ਵੀ ਗਿਣੋ';

  @override
  String get malaScreenOffOnSubtitle =>
      'ਫ਼ੋਨ ਲਾਕ ਕਰੋ ਅਤੇ ਵਾਲੀਅਮ ਕੁੰਜੀ ਦਬਾਉਂਦੇ ਰਹੋ। ਇੱਕ ਸੂਚਨਾ ਗਿਣਤੀ ਦਿਖਾਉਂਦੀ ਹੈ ਅਤੇ ਟੀਚੇ \'ਤੇ ਵੱਜਦੀ ਹੈ।';

  @override
  String get malaScreenOffOffSubtitle =>
      'ਬੰਦ: ਵਾਲੀਅਮ ਕੁੰਜੀਆਂ ਸਿਰਫ਼ ਉਦੋਂ ਗਿਣਦੀਆਂ ਹਨ ਜਦੋਂ Sadho ਖੁੱਲ੍ਹਾ ਹੋਵੇ ਅਤੇ ਸਕ੍ਰੀਨ ਚਾਲੂ ਹੋਵੇ।';

  @override
  String get modeHelpMalaScreenOff =>
      'Start ਦਬਾਓ, ਫਿਰ ਗਿਣਨ ਲਈ ਕੋਈ ਵੀ ਵਾਲੀਅਮ ਕੁੰਜੀ ਦਬਾਓ, ਫ਼ੋਨ ਲਾਕ ਅਤੇ ਸਕ੍ਰੀਨ ਬੰਦ ਹੋਣ \'ਤੇ ਵੀ। ਅੱਖਾਂ ਬੰਦ ਕਰਕੇ ਜਾਂ ਫ਼ੋਨ ਜੇਬ ਵਿੱਚ ਰੱਖ ਕੇ ਸੌਖਾ।';

  @override
  String get malaScreenOffExplainer =>
      'ਫ਼ੋਨ ਲਾਕ ਕਰੋ, ਗਿਣਨ ਲਈ ਵਾਲੀਅਮ ਕੁੰਜੀ ਦਬਾਓ। ਬੈਟਰੀ \'ਅਪ੍ਰਤਿਬੰਧਿਤ\' ਕਰੋ।';

  @override
  String get calibrateTitle => 'ਅਵਾਜ਼ ਕੈਲੀਬ੍ਰੇਟ ਕਰੋ';

  @override
  String calibrateIntro(int count) {
    return 'ਆਪਣਾ ਮੰਤਰ $count ਵਾਰ ਜਪੋ, ਜਿਵੇਂ ਤੁਸੀਂ ਆਮ ਤੌਰ \'ਤੇ ਕਰਦੇ ਹੋ, ਹਰ ਵਾਰ ਤੋਂ ਬਾਅਦ ਥੋੜ੍ਹਾ ਰੁਕ ਕੇ। ਫਿਰ Sadho ਤੈਅ ਕਰਦਾ ਹੈ ਕਿ ਅਵਾਜ਼ ਕਿੰਨੀ ਸਖ਼ਤ ਹੋਵੇ, ਤਾਂ ਜੋ ਸਾਰੇ ਗਿਣੇ ਜਾਣ ਅਤੇ ਕਮਰੇ ਦਾ ਰੌਲਾ ਨਹੀਂ। ਕੁਝ ਵੀ ਰਿਕਾਰਡ ਜਾਂ ਰੱਖਿਆ ਨਹੀਂ ਜਾਂਦਾ।';
  }

  @override
  String calibrateChantNow(int count) {
    return 'ਹੁਣ ਆਪਣਾ ਮੰਤਰ $count ਵਾਰ ਜਪੋ';
  }

  @override
  String calibrateHeard(int heard, int count) {
    return '$count ਵਿੱਚੋਂ $heard ਸੁਣੇ';
  }

  @override
  String calibrateSkipped(int count) {
    return '$count ਅਵਾਜ਼ਾਂ ਛੱਡੀਆਂ ਜੋ ਇੱਕ ਜਾਪ ਨਹੀਂ ਸਨ';
  }

  @override
  String get calibrateDone => 'ਕੈਲੀਬ੍ਰੇਟ ਹੋ ਗਿਆ';

  @override
  String calibrateDoneBody(int count) {
    return 'ਸਾਰੇ $count ਜਾਪ ਗਿਣੇ ਜਾਣਗੇ; ਕਮਰੇ ਦਾ ਰੌਲਾ ਨਹੀਂ।';
  }

  @override
  String get calibrateStart => 'ਕੈਲੀਬ੍ਰੇਸ਼ਨ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get calibrateSave => 'ਕੈਲੀਬ੍ਰੇਸ਼ਨ ਸੰਭਾਲੋ';

  @override
  String calibrationSaved(String mantra) {
    return '“$mantra” ਲਈ ਕੈਲੀਬ੍ਰੇਸ਼ਨ ਸੰਭਾਲੀ ਗਈ';
  }

  @override
  String get calibrateVoice => 'ਕੈਲੀਬ੍ਰੇਟ ਕਰੋ';

  @override
  String get recalibrateVoice => 'ਮੁੜ ਕੈਲੀਬ੍ਰੇਟ ਕਰੋ';

  @override
  String get quietModeLabel => 'ਸੈਸ਼ਨ ਦੌਰਾਨ ਹੋਰ ਸੂਚਨਾਵਾਂ ਚੁੱਪ ਕਰੋ';

  @override
  String get quietModeSubtitle =>
      'ਸੈਸ਼ਨ ਚੱਲਦੇ ਸਮੇਂ \'ਪਰੇਸ਼ਾਨ ਨਾ ਕਰੋ\' (ਸਿਰਫ਼ ਅਲਾਰਮ) ਚਾਲੂ ਕਰਦਾ ਹੈ, ਤਾਂ ਜੋ Sadho ਦਾ ਅਲਾਰਮ ਫਿਰ ਵੀ ਵੱਜੇ। ਬਾਅਦ ਵਿੱਚ ਤੁਹਾਡੀ ਆਪਣੀ ਸੈਟਿੰਗ ਵਾਪਸ ਆ ਜਾਂਦੀ ਹੈ।';

  @override
  String get quietModeAccessTitle => '\'ਪਰੇਸ਼ਾਨ ਨਾ ਕਰੋ\' ਪਹੁੰਚ ਦਿਓ';

  @override
  String get quietModeAccessBody =>
      'ਸਾਧਨਾ ਦੌਰਾਨ ਹੋਰ ਸੂਚਨਾਵਾਂ ਚੁੱਪ ਕਰਨ ਲਈ Sadho ਨੂੰ \'ਪਰੇਸ਼ਾਨ ਨਾ ਕਰੋ\' ਪਹੁੰਚ ਚਾਹੀਦੀ ਹੈ। ਅਗਲੀ ਸਕ੍ਰੀਨ \'ਤੇ Sadho ਲੱਭੋ ਅਤੇ ਇਜਾਜ਼ਤ ਦਿਓ। Sadho ਸਿਰਫ਼ ਸੈਸ਼ਨ ਚੱਲਦੇ ਸਮੇਂ \'ਸਿਰਫ਼ ਅਲਾਰਮ\' ਮੋਡ ਚਾਲੂ ਕਰਦਾ ਹੈ ਅਤੇ ਬਾਅਦ ਵਿੱਚ ਤੁਹਾਡੀ ਸੈਟਿੰਗ ਵਾਪਸ ਕਰ ਦਿੰਦਾ ਹੈ।';

  @override
  String get healthDndTitle => '\'ਪਰੇਸ਼ਾਨ ਨਾ ਕਰੋ\' ਪਹੁੰਚ';

  @override
  String get healthDndBody =>
      'ਸੈਸ਼ਨ ਦੌਰਾਨ ਹੋਰ ਸੂਚਨਾਵਾਂ ਚੁੱਪ ਕਰਨ ਲਈ ਲੋੜੀਂਦਾ। ਇਸ ਤੋਂ ਬਿਨਾਂ Sadho \'ਪਰੇਸ਼ਾਨ ਨਾ ਕਰੋ\' ਨੂੰ ਨਹੀਂ ਛੇੜਦਾ।';

  @override
  String get legalPrivacyPolicy => 'ਪਰਦੇਦਾਰੀ ਨੀਤੀ';

  @override
  String get legalTermsOfUse => 'ਵਰਤੋਂ ਦੀਆਂ ਸ਼ਰਤਾਂ';

  @override
  String get legalContact => 'ਸੰਪਰਕ ਅਤੇ ਸ਼ਿਕਾਇਤ';

  @override
  String get legalDeleteData => 'ਆਪਣਾ ਡਾਟਾ ਮਿਟਾਓ';

  @override
  String get legalLicenses => 'ਓਪਨ-ਸੋਰਸ ਲਾਇਸੈਂਸ';

  @override
  String linkOpenFailed(String url) {
    return '$url ਨਹੀਂ ਖੁੱਲ੍ਹ ਸਕਿਆ';
  }

  @override
  String onboardingLegalNotice(String terms, String privacy) {
    return 'ਤੁਹਾਡੀ ਸਾਧਨਾ, ਕੈਲੰਡਰ, ਅਵਾਜ਼ ਸਿਖਲਾਈ ਅਤੇ ਟਿਕਾਣਾ ਇਸੇ ਫ਼ੋਨ \'ਤੇ ਰਹਿੰਦੇ ਹਨ। ਜਾਰੀ ਰੱਖ ਕੇ ਤੁਸੀਂ $terms ਨਾਲ ਸਹਿਮਤ ਹੁੰਦੇ ਹੋ ਅਤੇ ਤੁਸੀਂ $privacy ਪੜ੍ਹ ਲਈ ਹੈ।';
  }

  @override
  String get channelSadhanaAlarmV2Name => 'ਸਾਧਨਾ ਅਲਾਰਮ';

  @override
  String get healthChannelTitle => 'ਅਲਾਰਮ ਸੂਚਨਾਵਾਂ: \'ਅਲਰਟ\' \'ਤੇ ਰੱਖੋ';

  @override
  String get healthChannelBody =>
      '“ਸਾਧਨਾ ਅਲਾਰਮ” ਅਤੇ “ਅਲਾਰਮ ਅਤੇ ਟਾਈਮਰ” ਸੂਚਨਾਵਾਂ ਸਕ੍ਰੀਨ \'ਤੇ ਆਉਣੀਆਂ ਚਾਹੀਦੀਆਂ ਹਨ, ਨਹੀਂ ਤਾਂ ਅਲਾਰਮ ਸਕ੍ਰੀਨ ਲੌਕ ਸਕ੍ਰੀਨ \'ਤੇ ਨਹੀਂ ਦਿਸ ਸਕਦੀ।';

  @override
  String get healthFixManualTitle => 'ਸੈਟਿੰਗਾਂ ਆਪ ਖੋਲ੍ਹੋ';

  @override
  String get healthFixManualBody =>
      'ਫ਼ੋਨ ਨੇ ਇਹ ਪੰਨਾ ਨਹੀਂ ਖੋਲ੍ਹਿਆ। Samsung ਫ਼ੋਨ \'ਤੇ:\n1. ਸੈਟਿੰਗਾਂ › ਐਪਾਂ › Sadho ਖੋਲ੍ਹੋ।\n2. ਸੂਚਨਾਵਾਂ: ਇਜਾਜ਼ਤ ਦਿਓ, ਅਤੇ “ਸਾਧਨਾ ਅਲਾਰਮ” ਤੇ “ਅਲਾਰਮ ਅਤੇ ਟਾਈਮਰ” ਨੂੰ \'ਅਲਰਟ\' \'ਤੇ ਰੱਖੋ।\n3. ਅਲਾਰਮ ਅਤੇ ਰੀਮਾਈਂਡਰ: ਇਜਾਜ਼ਤ ਦਿਓ।\n4. ਬੈਟਰੀ: ਬਿਨਾਂ ਪਾਬੰਦੀ।\n5. ਪੂਰੀ-ਸਕ੍ਰੀਨ ਸੂਚਨਾਵਾਂ: ਸੈਟਿੰਗਾਂ › ਐਪਾਂ › ⋮ › ਖ਼ਾਸ ਪਹੁੰਚ › Sadho ਨੂੰ ਇਜਾਜ਼ਤ ਦਿਓ।\n6. \'ਪਰੇਸ਼ਾਨ ਨਾ ਕਰੋ\' ਪਹੁੰਚ: ਸੈਟਿੰਗਾਂ › ਸੂਚਨਾਵਾਂ › ਪਰੇਸ਼ਾਨ ਨਾ ਕਰੋ › ਐਪ ਪਹੁੰਚ (ਸਿਰਫ਼ ਸ਼ਾਂਤ ਮੋਡ ਲਈ)।';
}
