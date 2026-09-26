// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get navHome => 'முகப்பு';

  @override
  String get navSadhana => 'சாதனை';

  @override
  String get navCalendar => 'காலண்டர்';

  @override
  String get navClock => 'கடிகாரம்';

  @override
  String get tooltipLanguage => 'மொழி';

  @override
  String get tooltipProfile => 'சுயவிவரம்';

  @override
  String get tooltipSwitchToLight => 'வெளிர் தீமிற்கு மாறு';

  @override
  String get tooltipSwitchToDark => 'இருள் தீமிற்கு மாறு';

  @override
  String get languageSheetTitle => 'மொழி';

  @override
  String get languageSheetSubtitle =>
      'உங்கள் தேர்வு சேமிக்கப்பட்டு உடனடியாகப் பயன்படுத்தப்படும்.';

  @override
  String get actionCancel => 'ரத்துசெய்';

  @override
  String get actionDelete => 'நீக்கு';

  @override
  String get actionSave => 'சேமி';

  @override
  String get actionReset => 'மீட்டமை';

  @override
  String get actionEdit => 'திருத்து';

  @override
  String get actionOk => 'சரி';

  @override
  String get unitSeconds => 'விநாடிகள்';

  @override
  String get unitMinutes => 'நிமிடங்கள்';

  @override
  String get unitHours => 'மணிநேரம்';

  @override
  String get paceErrorEmpty => 'வேகத்தை உள்ளிடவும்.';

  @override
  String get paceErrorNotNumber => 'இது ஒரு எண் அல்ல.';

  @override
  String paceErrorTooFast(String min) {
    return 'மிக வேகமாக உள்ளது. குறைந்தபட்சம் $min.';
  }

  @override
  String paceErrorTooSlow(String max) {
    return 'மிக மெதுவாக உள்ளது. அதிகபட்சம் $max.';
  }

  @override
  String get modeTap => 'தட்டு';

  @override
  String get modeRhythm => 'தாளம்';

  @override
  String get modeVoice => 'குரல்';

  @override
  String get modeMala => 'மாலை';

  @override
  String get ringtoneTempleBell => 'கோவில் மணி';

  @override
  String get ringtoneSingingBowl => 'பாடும் கிண்ணம்';

  @override
  String get ringtoneSoftChime => 'மென்மையான ஒலி';

  @override
  String get ringtoneDeepGong => 'ஆழமான காங்';

  @override
  String get msgVoiceUnsupported =>
      'குரல் எண்ணிக்கை Android மற்றும் iOS-இல் மட்டுமே செயல்படும்';

  @override
  String get msgVoiceNoMic => 'இந்தச் சாதனத்தில் மைக்ரோஃபோன் இல்லை';

  @override
  String get msgMalaUnsupported =>
      'ஒலியளவு-விசை எண்ணிக்கைக்கு உண்மையான சாதனம் தேவை';

  @override
  String trainFirstPrompt(int min, int max) {
    return 'முதலில் இந்த மந்திரத்திற்கு உங்கள் குரலைப் பயிற்சி செய்யுங்கள்: இதை $min முதல் $max முறை பதிவு செய்யுங்கள்.';
  }

  @override
  String get fallbackVoiceDenied =>
      'மைக்ரோஃபோன் அனுமதி மறுக்கப்பட்டது, எனவே குரல் எண்ணிக்கை கேட்க முடியவில்லை. தட்டு பயன்முறையைப் பயன்படுத்துகிறது.';

  @override
  String get fallbackVoiceBlocked =>
      'மைக்ரோஃபோன் அணுகல் தடுக்கப்பட்டுள்ளது. குரல் எண்ணிக்கையைப் பயன்படுத்த அமைப்புகளில் அனுமதிக்கவும். தட்டு பயன்முறையைப் பயன்படுத்துகிறது.';

  @override
  String get fallbackVoiceUnsupported =>
      'குரல் எண்ணிக்கை Android மற்றும் iOS-இல் மட்டுமே செயல்படும். தட்டு பயன்முறையைப் பயன்படுத்துகிறது.';

  @override
  String get fallbackVoiceNoMic =>
      'இந்தச் சாதனத்தில் மைக்ரோஃபோன் இல்லை. தட்டு பயன்முறையைப் பயன்படுத்துகிறது.';

  @override
  String get fallbackMalaUnsupported =>
      'ஒலியளவு-விசை எண்ணிக்கைக்கு உண்மையான சாதனம் தேவை. தட்டு பயன்முறையைப் பயன்படுத்துகிறது.';

  @override
  String get sadhanaRingTitle => '🔔 சாதனை நேரம் முடிந்தது';

  @override
  String get sadhanaRingBody => 'உங்கள் அமர்வு நேரம் முடிந்தது 🙏';

  @override
  String get voiceTooShort =>
      'இது மிகக் குறுகியதாக இருந்தது. முழு மந்திரத்தையும் சொல்லுங்கள்.';

  @override
  String get voiceRanTooLong =>
      'இது நீண்ட நேரம் ஓடியது. மந்திரத்தை ஒருமுறை சொல்லி நிறுத்துங்கள்.';

  @override
  String get voiceSoundedDifferent =>
      'இது மற்றவைகளிலிருந்து வேறுபட்டதாக ஒலித்தது. அதே முறையில் மீண்டும் சொல்லுங்கள்.';

  @override
  String get voiceGotIt => 'புரிந்தது. மீண்டும் சொல்லுங்கள்.';

  @override
  String get voiceDeniedShort =>
      'மைக்ரோஃபோன் அனுமதி மறுக்கப்பட்டது, எனவே குரல் எண்ணிக்கை கேட்க முடியவில்லை.';

  @override
  String get voiceBlockedShort =>
      'மைக்ரோஃபோன் அணுகல் தடுக்கப்பட்டுள்ளது. குரல் எண்ணிக்கையைப் பயன்படுத்த அமைப்புகளில் அனுமதிக்கவும்.';

  @override
  String get voiceAccessLost =>
      'மைக்ரோஃபோன் அணுகல் இழக்கப்பட்டது, எனவே குரல் எண்ணிக்கை நிறுத்தப்பட்டது.';

  @override
  String get voiceCouldNotRestart =>
      'மைக்ரோஃபோனை மீண்டும் தொடங்க முடியவில்லை, எனவே குரல் எண்ணிக்கை நிறுத்தப்பட்டது.';

  @override
  String get mantraLibraryTitle => 'மந்திர நூலகம்';

  @override
  String get addMantra => 'மந்திரம் சேர்';

  @override
  String get searchHint => 'தலைப்பு, எழுத்து அல்லது பாரம்பரியத்தைத் தேடு';

  @override
  String noMantrasMatch(String query) {
    return '“$query” உடன் எந்த மந்திரமும் பொருந்தவில்லை.\nஉங்கள் சொந்தத்தை உருவாக்க “மந்திரம் சேர்” என்பதைத் தட்டவும்.';
  }

  @override
  String mantraAdded(String title) {
    return '“$title” சேர்க்கப்பட்டது';
  }

  @override
  String mantraSaved(String title) {
    return '“$title” சேமிக்கப்பட்டது';
  }

  @override
  String mantraRestored(String title) {
    return '“$title” அதன் இயல்புநிலைக்கு மீட்டமைக்கப்பட்டது';
  }

  @override
  String get deleteMantraTitle => 'மந்திரத்தை நீக்கவா?';

  @override
  String deleteMantraBody(String title) {
    return '“$title” உங்கள் நூலகத்திலிருந்து அகற்றப்படும்.';
  }

  @override
  String get retrainVoiceTooltip => 'குரலை மீண்டும் பயிற்சி செய்';

  @override
  String get trainVoice => 'குரலைப் பயிற்சி செய்';

  @override
  String mantraCountTag(int count) {
    return '$count எண்ணிக்கை';
  }

  @override
  String get editedTag => 'திருத்தப்பட்டது';

  @override
  String get editMantra => 'மந்திரத்தைத் திருத்து';

  @override
  String get addAMantra => 'ஒரு மந்திரத்தைச் சேர்';

  @override
  String get titleLabel => 'தலைப்பு *';

  @override
  String get titleRequired => 'தலைப்பை உள்ளிடவும்';

  @override
  String get scriptTextLabel => 'எழுத்து உரை';

  @override
  String get transliterationLabel => 'ஒலிபெயர்ப்பு';

  @override
  String get traditionLabel => 'பாரம்பரியம் / மொழி';

  @override
  String get traditionHint => 'எ.கா. சமஸ்கிருதம் · இந்து';

  @override
  String get defaultCountLabel => 'இயல்புநிலை எண்ணிக்கை *';

  @override
  String get enterNumberOneOrMore =>
      '1 அல்லது அதற்கு மேற்பட்ட எண்ணை உள்ளிடவும்';

  @override
  String get tooLarge => 'இது மிகப் பெரியது';

  @override
  String get saveChanges => 'மாற்றங்களைச் சேமி';

  @override
  String get saveToLibrary => 'நூலகத்தில் சேமி';

  @override
  String get resetToDefaultButton => 'இயல்புநிலைக்கு மீட்டமை';

  @override
  String get resetToDefaultTitle => 'இயல்புநிலைக்கு மீட்டமைக்கவா?';

  @override
  String resetToDefaultBody(String title) {
    return '“$title”க்கான உங்கள் மாற்றங்கள் நிராகரிக்கப்பட்டு, உள்ளமை உரை மீட்டமைக்கப்படும்.';
  }

  @override
  String switchToMantra(String title) {
    return '$title-க்கு மாறவா?';
  }

  @override
  String get switchMantraBody => 'உங்கள் தற்போதைய எண்ணிக்கை மீட்டமைக்கப்படும்.';

  @override
  String get keepCurrent => 'தற்போதையதை வை';

  @override
  String get switchAction => 'மாறு';

  @override
  String get smallerMantraText => 'சிறிய மந்திர உரை';

  @override
  String get largerMantraText => 'பெரிய மந்திர உரை';

  @override
  String get libraryButton => 'நூலகம்';

  @override
  String get trainYourOwnMantra => 'உங்கள் சொந்த மந்திரத்தைப் பயிற்சி செய்';

  @override
  String voiceCountingFrom(String title, int count) {
    return 'உங்கள் $count பதிவுகளிலிருந்து “$title” எண்ணப்படுகிறது. மற்ற ஒலிகளும் சொற்களும் புறக்கணிக்கப்படும்.';
  }

  @override
  String voiceCountsOnlyTrained(String title, int min, int max) {
    return 'நீங்கள் பயிற்சி செய்த மந்திரத்தை மட்டுமே குரல் எண்ணும். தொடங்க “$title”-ஐ $min முதல் $max முறை பதிவு செய்யுங்கள்.';
  }

  @override
  String get addMoreSamples => 'மேலும் மாதிரிகளைச் சேர்';

  @override
  String get retrain => 'மீண்டும் பயிற்சி செய்';

  @override
  String get clearTraining => 'பயிற்சியை அழி';

  @override
  String get voiceBetaNote =>
      'பீட்டா: இது சாதனத்திலேயே, ஆஃப்லைனில் இயங்குகிறது. அதிக பதிவுகள் துல்லியத்தை மேம்படுத்தும், சத்தமான அறையில் குறையும். மறுபடியும் சொல்வதற்கு முன் சிறிது நிறுத்துங்கள். இங்கே உங்கள் குரல் மட்டுமே எண்ணப்படும்; + மற்றும் − பொத்தான்கள் எண்ணிக்கையைச் சரிசெய்யும்.';

  @override
  String get trainVoiceFirstTitle =>
      'முதலில் உங்கள் குரலைப் பயிற்சி செய்யுங்கள்';

  @override
  String trainVoiceFirstBody(String title, int min, int max) {
    return 'நீங்கள் பயிற்சி செய்த மந்திரத்தை மட்டுமே குரல் எண்ணும். “$title”-ஐ $min முதல் $max முறை (சுமார் ஒரு நிமிடம்) பதிவு செய்யுங்கள். இது இந்தச் சாதனத்திலேயே இருந்து ஆஃப்லைனில் செயல்படும்.';
  }

  @override
  String get later => 'பின்னர்';

  @override
  String get trainNow => 'இப்போது பயிற்சி செய்';

  @override
  String get betaLabel => 'பீட்டா';

  @override
  String get voiceTrained => 'குரல் பயிற்சி பெற்றது';

  @override
  String get voiceNotTrained => 'குரல் பயிற்சி பெறவில்லை';

  @override
  String get sensitivityLabel => 'உணர்திறன்';

  @override
  String get sensitivityStrict => 'கண்டிப்பான';

  @override
  String get sensitivityLenient => 'தளர்வான';

  @override
  String get sensitivityMedium => 'நடுத்தரம்';

  @override
  String get clearVoiceTrainingTitle => 'குரல் பயிற்சியை அழிக்கவா?';

  @override
  String clearVoiceTrainingBody(String title) {
    return 'நீங்கள் மீண்டும் பயிற்சி செய்யும் வரை குரல் “$title”-ஐ எண்ணுவதை நிறுத்தும்.';
  }

  @override
  String get completionTitle => 'நிறைவு';

  @override
  String get vibrationLabel => 'அதிர்வு';

  @override
  String vibrationSubtitle(int n) {
    return 'ஒவ்வொரு $n எண்ணிக்கையிலும் ஒரு அதிர்வு, இலக்கில் வலுவான ஒன்று.';
  }

  @override
  String intensityLevel(int level) {
    return 'தீவிரம்: நிலை $level இல் 5';
  }

  @override
  String get testMilestone => 'சோதனை மைல்கல்';

  @override
  String get testTarget => 'சோதனை இலக்கு';

  @override
  String get ringtoneLabel => 'ரிங்டோன்';

  @override
  String get ringtoneSubtitle => 'இலக்கை அடையும்போது ஒரு ஒலி இயங்கும்.';

  @override
  String get playSound => 'ஒலியை இயக்கு';

  @override
  String get combined => 'இணைந்த';

  @override
  String get combinedTooltip =>
      'நான்கு பயன்முறைகளும் ஒரு பகிரப்பட்ட எண்ணிக்கையில் சேர்க்கப்படும்';

  @override
  String get separate => 'தனித்தனி';

  @override
  String get separateTooltip =>
      'ஒவ்வொரு பயன்முறையும் அதன் சொந்த எண்ணிக்கையை வைத்திருக்கும்';

  @override
  String get countModeSemantic => 'எண்ணிக்கை பயன்முறை';

  @override
  String get combinedExplain =>
      'தட்டு, குரல், தாளம் மற்றும் மாலை அனைத்தும் ஒரு இலக்கை நோக்கி ஒரு பகிரப்பட்ட எண்ணிக்கையில் சேரும்.';

  @override
  String get separateExplain =>
      'ஒவ்வொரு பயன்முறையும் அதன் சொந்த எண்ணிக்கையையும் இலக்கை நோக்கிய முன்னேற்றத்தையும் வைத்திருக்கும். மீட்டமைப்பும் நிறைவும் நீங்கள் இருக்கும் பயன்முறைக்கு மட்டுமே பொருந்தும்.';

  @override
  String countedLabel(int count) {
    return '$count எண்ணப்பட்டது';
  }

  @override
  String ofTarget(int count) {
    return '$count இல்';
  }

  @override
  String get removeOneTooltip => 'ஒன்றை நீக்கு';

  @override
  String get undoLabel => 'செயல்தவிர்';

  @override
  String get countLabel => 'எண்ணிக்கை';

  @override
  String get addOneTooltip => 'ஒன்றைச் சேர்';

  @override
  String get focusLabel => 'கவனம்';

  @override
  String get focusModeTooltip => 'கவன பயன்முறை';

  @override
  String get pause => 'இடைநிறுத்து';

  @override
  String get resume => 'மீண்டும் தொடங்கு';

  @override
  String get start => 'தொடங்கு';

  @override
  String targetReachedSeparate(String mode) {
    return '$mode இல் இலக்கு எட்டப்பட்டது 🙏  இந்த பயன்முறையை மீட்டமைக்கவும், பயன்முறையை மாற்றவும் அல்லது இலக்கை உயர்த்தவும்.';
  }

  @override
  String get targetReachedCombined =>
      'இலக்கு எட்டப்பட்டது 🙏  மீட்டமைக்கவும் அல்லது இலக்கை உயர்த்தவும்.';

  @override
  String resetModeCountTitle(String mode) {
    return '$mode எண்ணிக்கையை மீட்டமைக்கவா?';
  }

  @override
  String get resetSessionTitle => 'இந்த அமர்வை மீட்டமைக்கவா?';

  @override
  String resetModeCountBody(String mode, int count) {
    return 'உங்கள் $mode எண்ணிக்கை $count பூஜ்ஜியத்திற்குத் திரும்பும். மற்ற பயன்முறைகள் தங்கள் எண்ணிக்கையை வைத்திருக்கும்.';
  }

  @override
  String resetSessionBody(int count) {
    return 'உங்கள் $count எண்ணிக்கை பூஜ்ஜியத்திற்குத் திரும்பும்.';
  }

  @override
  String get modeHelpTap =>
      'வளையத்தைத் தட்டவும் அல்லது கவன பயன்முறையில் எங்கும். தட்டு பயன்முறை மட்டுமே திரைத் தட்டல்களை எண்ணும்.';

  @override
  String get modeHelpRhythm =>
      'Start-ஐ அழுத்தவும், எண்ணிக்கை கீழே உள்ள வேகத்தில் தானாக அதிகரிக்கும்.';

  @override
  String get modeHelpVoice =>
      'Start-ஐ அழுத்தி, உங்கள் பயிற்சி பெற்ற மந்திரத்தை ஜபிக்கவும். ஒவ்வொரு முறை அடையாளம் காணப்படும்போதும் உடனடியாக ஒரு எண்ணிக்கை சேர்க்கப்படும்; மற்ற ஒலிகள் புறக்கணிக்கப்படும். மைக்ரோஃபோன் தேவை; அமைதியான அறையில் சிறப்பாக செயல்படும்.';

  @override
  String get modeHelpMala =>
      'Start-ஐ அழுத்தி, எண்ண எந்த ஒலியளவு பொத்தானையும் அழுத்தவும். கண்களை மூடியிருக்கும்போது அல்லது தொலைபேசி பாக்கெட்டில் இருக்கும்போது வசதியானது. திரை இயங்கிக் கொண்டே இருக்க வேண்டும்.';

  @override
  String get countingModeLabel => 'எண்ணிக்கை பயன்முறை';

  @override
  String pacePrefix(String pace) {
    return 'வேகம்: எண்ணிக்கை $pace';
  }

  @override
  String modeSemanticLabel(String mode) {
    return '$mode பயன்முறை';
  }

  @override
  String get tapAnywhereToCount => 'எண்ண எங்கும் தட்டவும்';

  @override
  String countingPace(String pace) {
    return 'எண்ணிக்கை $pace';
  }

  @override
  String pausedPace(String pace) {
    return 'இடைநிறுத்தப்பட்டது · $pace';
  }

  @override
  String get listening => 'கேட்கிறது…';

  @override
  String get startingMicrophone =>
      'மைக்ரோஃபோன் தொடங்குகிறது… கேட்கப்பட்டால் அணுகலை வழங்கவும்';

  @override
  String get notTrainedYet =>
      'இன்னும் பயிற்சி பெறவில்லை · குரலைப் பயன்படுத்த மந்திரத்தைப் பயிற்சி செய்யுங்கள்';

  @override
  String get pausedPressStartListen =>
      'இடைநிறுத்தப்பட்டது · கேட்க Start-ஐ அழுத்தவும்';

  @override
  String get pressVolumeKeys => 'எண்ண ஒலியளவு விசைகளை அழுத்தவும்';

  @override
  String get capturingVolumeKeys => 'ஒலியளவு விசைகளைப் பிடிக்கிறது…';

  @override
  String get pausedPressStartVolume =>
      'இடைநிறுத்தப்பட்டது · ஒலியளவு விசைகளைப் பயன்படுத்த Start-ஐ அழுத்தவும்';

  @override
  String modeTitleLine(String mode, String own) {
    String _temp0 = intl.Intl.selectLogic(own, {
      'yes': ' · சொந்த எண்ணிக்கை',
      'other': '',
    });
    return '$mode பயன்முறை$_temp0';
  }

  @override
  String voiceCountedMatch(int percent) {
    return 'எண்ணப்பட்டது · $percent% பொருத்தம்';
  }

  @override
  String voiceIgnoredMatch(int percent) {
    return 'புறக்கணிக்கப்பட்டது · $percent% பொருத்தம் (உங்கள் மந்திரம் அல்ல)';
  }

  @override
  String get paceFieldLabel => 'வேகம்';

  @override
  String paceHelpOk(String pace, String range) {
    return '$pace எண்ணுகிறது. (அனுமதிக்கப்பட்டது: $range)';
  }

  @override
  String paceHelpError(String error, String pace) {
    return '$error இன்னும் $pace எண்ணுகிறது.';
  }

  @override
  String get sankalpLabel => 'சங்கல்பம்';

  @override
  String get sankalpHint => 'இந்தப் பயிற்சிக்கான உங்கள் நோக்கத்தைக் கூறுங்கள்…';

  @override
  String get targetSectionTitle => 'இலக்கு';

  @override
  String get byCount => 'எண்ணிக்கை வாரியாக';

  @override
  String get byTime => 'நேரம் வாரியாக';

  @override
  String customWithValue(String value) {
    return 'தனிப்பயன் · $value';
  }

  @override
  String get custom => 'தனிப்பயன்';

  @override
  String get enterNumberRange => '1 முதல் 9,999,999 வரை ஒரு எண்ணை உள்ளிடவும்';

  @override
  String get customCountTitle => 'தனிப்பயன் எண்ணிக்கை';

  @override
  String get targetCountLabel => 'இலக்கு எண்ணிக்கை';

  @override
  String get setAction => 'அமை';

  @override
  String get durationLabel => 'கால அளவு';

  @override
  String get enterDuration => '1 அல்லது அதற்கு மேற்பட்ட கால அளவை உள்ளிடவும்.';

  @override
  String get maxDurationCapped =>
      'அதிகபட்சம் 99 மணி 59 நிமி 59 வி — இது வரம்பிடப்படும்.';

  @override
  String sessionLasts(String duration) {
    return 'அமர்வு $duration நீடிக்கும்.';
  }

  @override
  String get targetReachedFocus => 'இலக்கு எட்டப்பட்டது 🙏';

  @override
  String screenTapsDoNotCount(String mode) {
    return '$mode பயன்முறையில் திரைத் தட்டல்கள் எண்ணப்படாது. சரிசெய்ய + அல்லது − ஐப் பயன்படுத்தவும்.';
  }

  @override
  String holdFingersToExit(int fingers, int seconds) {
    return 'வெளியேற $fingers விரல்களை $seconds விநாடிகள் அழுத்திப் பிடிக்கவும்';
  }

  @override
  String get holdToExitFocusMode =>
      'கவன பயன்முறையிலிருந்து வெளியேற அழுத்திப் பிடிக்கவும்';

  @override
  String get holdToExit => 'வெளியேற அழுத்திப் பிடிக்கவும்';

  @override
  String get keepHoldingToExit => 'வெளியேற தொடர்ந்து அழுத்தவும்…';

  @override
  String addedRecordingsTo(int added, String title, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'பதிவுகள்',
      one: 'பதிவு',
    );
    return '“$title”-இல் $added $_temp0 சேர்க்கப்பட்டன (மொத்தம் $total)';
  }

  @override
  String voiceTrainedFor(String title, int count) {
    return '“$title”-க்காக குரல் பயிற்சி பெற்றது ($count பதிவுகள்)';
  }

  @override
  String trainedRecordingsCount(int count) {
    return 'பயிற்சி பெற்றது · $count பதிவுகள்';
  }

  @override
  String get tooFewRecordings =>
      'எண்ண போதுமான பதிவுகள் இல்லை. மேலும் சேர்க்கவும் அல்லது மீண்டும் பயிற்சி செய்யவும்.';

  @override
  String canCountAddMore(int room) {
    return 'இந்த மந்திரத்தை குரல் எண்ண முடியும். மீண்டும் தொடங்காமல் துல்லியத்தை மேம்படுத்த $room பதிவுகளை மேலும் சேர்க்கலாம்.';
  }

  @override
  String canCountAtMax(int max) {
    return 'இந்த மந்திரத்தை குரல் எண்ண முடியும். உங்களிடம் அதிகபட்சமான $max பதிவுகள் உள்ளன; அவற்றை மாற்ற மீண்டும் பயிற்சி செய்யுங்கள்.';
  }

  @override
  String get pausedHeadline => 'இடைநிறுத்தப்பட்டது';

  @override
  String pausedSub(int recorded) {
    return '$recorded பதிவு செய்யப்பட்டன. தொடரவும் அல்லது இருப்பதைச் சேமிக்கவும்.';
  }

  @override
  String recordInstructions(int min, int max, int recommended) {
    return 'உங்கள் இயல்பான ஜப வேகத்தில் $min முதல் $max முறை பதிவு செய்யுங்கள் ($recommended ஒரு நல்ல எண்ணிக்கை). பின்னர் குரல் உங்கள் மந்திரத்தை மட்டுமே எண்ணும்.';
  }

  @override
  String get openingMicrophone => 'மைக்ரோஃபோன் திறக்கப்படுகிறது…';

  @override
  String get stayQuiet => 'ஒரு கணம் அமைதியாக இருங்கள்…';

  @override
  String get listeningToRoom =>
      'பின்னணி சத்தம் எண்ணப்படாமல் இருக்க அறையைக் கேட்கிறது.';

  @override
  String get sayYourMantra => 'உங்கள் மந்திரத்தைச் சொல்லுங்கள்…';

  @override
  String recordingXofY(int current, int max) {
    return '$current பதிவு செய்யப்படுகிறது, அதிகபட்சம் $max இல்';
  }

  @override
  String allRecordingsCaptured(int count) {
    return 'அனைத்து $count பதிவுகளும் பிடிக்கப்பட்டன';
  }

  @override
  String get saveToStartCounting =>
      'குரலால் எண்ணத் தொடங்க இவற்றைச் சேமிக்கவும்.';

  @override
  String get cannotUseMicrophone => 'மைக்ரோஃபோனைப் பயன்படுத்த முடியவில்லை';

  @override
  String get canSaveNowHint =>
      'நீங்கள் இப்போது சேமிக்கலாம் அல்லது மேலும் துல்லியத்திற்காக தொடரலாம்.';

  @override
  String minAreEnough(int min) {
    return 'தொடங்க $min போதுமானவை.';
  }

  @override
  String addingToSaved(int count) {
    return 'உங்கள் $count சேமிக்கப்பட்ட பதிவுகளில் சேர்க்கப்படுகிறது.';
  }

  @override
  String get tryAgain => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get startRecording => 'பதிவைத் தொடங்கு';

  @override
  String get openSettingsAction => 'அமைப்புகளைத் திற';

  @override
  String saveNRecordings(int count) {
    return '$count பதிவுகளைச் சேமி';
  }

  @override
  String recordMoreToSave(int n) {
    return 'சேமிக்க $n மேலும் பதிவு செய்யுங்கள்';
  }

  @override
  String get recordSampleToSave => 'சேமிக்க ஒரு மாதிரியைப் பதிவு செய்யுங்கள்';

  @override
  String get undoLast => 'கடைசியை செயல்தவிர்';

  @override
  String get stop => 'நிறுத்து';

  @override
  String get continueRecording => 'பதிவைத் தொடரவும்';

  @override
  String get startOver => 'மீண்டும் தொடங்கு';

  @override
  String recordedOfMax(int recorded, int max) {
    return '$recorded பதிவு செய்யப்பட்டன, அதிகபட்சம் $max இல்';
  }

  @override
  String voiceBetaNoteTraining(int max) {
    return 'பீட்டா. அனைத்தும் இந்தச் சாதனத்திலேயே, ஆஃப்லைனில் நடக்கும்: ஒலியை விவரிக்கும் எண்கள் மட்டுமே சேமிக்கப்படும், ஆடியோ ஒருபோதும் இல்லை. அதிக பதிவுகள் எண்ணிக்கையை மேலும் துல்லியமாக்கும் (அதிகபட்சம் $max வரை); சத்தமான அறை அதைக் குறைவான துல்லியமாக்கும். மந்திரத்தை ஒருமுறை சொல்லி, அடுத்ததற்கு முன் சிறிது நிறுத்துங்கள்.';
  }

  @override
  String get actionClear => 'அழி';

  @override
  String get today => 'இன்று';

  @override
  String get previousMonth => 'முந்தைய மாதம்';

  @override
  String get nextMonth => 'அடுத்த மாதம்';

  @override
  String get markTypeGood => 'நல்லது';

  @override
  String get markTypeCautious => 'எச்சரிக்கை';

  @override
  String get markTypeNeutral => 'நடுநிலை';

  @override
  String get reminderModeNone => 'நேரம் இல்லை';

  @override
  String get reminderModeOnce => 'ஒரு முறை';

  @override
  String get reminderModeSeveral => 'பல முறை';

  @override
  String get repeatRuleOnce => 'ஒரு முறை';

  @override
  String get repeatRuleDaily => 'தினமும்';

  @override
  String get repeatRuleWeekly => 'வாராந்திரம்';

  @override
  String get repeatRuleMonthly => 'மாதந்தோறும்';

  @override
  String get repeatRuleQuarterly => 'காலாண்டு';

  @override
  String get repeatRuleHalfYearly => 'அரையாண்டு';

  @override
  String get repeatRuleYearly => 'ஆண்டுதோறும்';

  @override
  String get homeModeNone => 'காட்ட வேண்டாம்';

  @override
  String get homeModeMorning => 'காலையில் ஒரு முறை';

  @override
  String get homeModeAllDay => 'நாள் முழுவதும் வை';

  @override
  String get markStyleDot => 'புள்ளி';

  @override
  String get markStyleFilled => 'நிரப்பப்பட்டது';

  @override
  String get markStyleHighlight => 'சிறப்பம்சம்';

  @override
  String get markStyleCircle => 'வட்டம்';

  @override
  String get markStyleSquare => 'சதுரம்';

  @override
  String get emojiOm => 'ॐ';

  @override
  String get emojiKhanda => 'கண்டா';

  @override
  String get emojiMala => 'மாலை';

  @override
  String get emojiDiya => 'தீபம்';

  @override
  String get emojiBell => 'மணி';

  @override
  String get emojiSunrise => 'சூரிய உதயம்';

  @override
  String get emojiStar => 'நட்சத்திரம்';

  @override
  String get emojiSparkle => 'ஒளிர்வு';

  @override
  String get emojiMoney => 'பணம்';

  @override
  String get emojiHandshake => 'கைகுலுக்கல்';

  @override
  String get emojiAvoid => 'தவிர்';

  @override
  String get emojiDone => 'முடிந்தது';

  @override
  String get markTitleGood => 'நல்ல நாள்';

  @override
  String get markTitleCautious => 'எச்சரிக்கை நாள்';

  @override
  String get markTitleNeutral => 'நடுநிலை நாள்';

  @override
  String get reminderBodyGood => 'ஒரு நல்ல நாள்.';

  @override
  String get reminderBodyCautious => 'இன்று எச்சரிக்கையாக இருங்கள்.';

  @override
  String get reminderBodyNeutral => 'உங்கள் காலண்டரில் குறிக்கப்பட்டது.';

  @override
  String get channelCalendarRemindersName => 'காலண்டர் நினைவூட்டல்கள்';

  @override
  String get channelCalendarRemindersDesc =>
      'நீங்கள் Sadho இல் குறித்த தேதிகளுக்கான நினைவூட்டல்கள்';

  @override
  String get channelAlarmsName => 'அலாரம் மற்றும் டைமர்';

  @override
  String get channelAlarmsDesc =>
      'சூரிய அடிப்படையிலான அலாரம் மற்றும் முடிந்த டைமர்கள்';

  @override
  String get repeatSummaryOnce => 'ஒரு முறை';

  @override
  String get repeatSummaryDaily => 'தினமும்';

  @override
  String get repeatSummaryWeekly => 'ஒவ்வொரு வாரமும்';

  @override
  String get repeatSummaryMonthly => 'ஒவ்வொரு மாதமும்';

  @override
  String get repeatSummaryQuarterly => 'ஒவ்வொரு 3 மாதமும்';

  @override
  String get repeatSummaryHalfYearly => 'ஒவ்வொரு 6 மாதமும்';

  @override
  String get repeatSummaryYearly => 'ஒவ்வொரு ஆண்டும்';

  @override
  String reminderSummaryAt(String times) {
    return '$times இல் நினைவூட்டு';
  }

  @override
  String homeSummaryFrom(String time) {
    return 'முகப்பில் $time முதல்';
  }

  @override
  String get homeSummaryAllDay => 'முகப்பில் நாள் முழுவதும்';

  @override
  String marksInMonth(String month) {
    return '$month இல் குறிகள்';
  }

  @override
  String noMarksInMonth(String month) {
    return '$month இல் எதுவும் குறிக்கப்படவில்லை. குறியைச் சேர்க்க ஒரு தேதியைத் தட்டவும்.';
  }

  @override
  String get markStyleSectionTitle => 'குறி பாணி';

  @override
  String get markStyleSectionHint =>
      'குறிக்கப்பட்ட தேதிகள் எப்படி தோன்றும். ஒவ்வொரு குறிக்கும் பொருந்தும்.';

  @override
  String markStyleSemantic(String style) {
    return '$style குறி பாணி';
  }

  @override
  String get dayCellToday => ', இன்று';

  @override
  String get dayCellAnd => 'மற்றும்';

  @override
  String dayCellMarkedSuffix(int count, String kinds) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ', $kinds குறிக்கப்பட்டது, $count குறிகள்',
      one: ', $kinds குறிக்கப்பட்டது, 1 குறி',
    );
    return '$_temp0';
  }

  @override
  String get markEditorNoTimeWarning =>
      'குறைந்தது ஒரு நேரத்தைச் சேர்க்கவும் அல்லது \"நேரம் இல்லை\" என்பதைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get notificationsOffWarning =>
      'Sadho-க்கான அறிவிப்புகள் அணைக்கப்பட்டுள்ளன, எனவே இந்த நினைவூட்டல் ஒலிக்காது. உங்கள் தொலைபேசி அமைப்புகளில் அவற்றை இயக்கவும்.';

  @override
  String get deleteMarkFallbackTitle => 'இந்தக் குறி';

  @override
  String get deleteMarkQuestion => 'இந்தக் குறியை நீக்கவா?';

  @override
  String deleteMarkRepeatsBody(String title) {
    return '$title மற்றும் அதன் அனைத்து மறுநிகழ்வுகளையும் நீக்கவா? அதன் நினைவூட்டல்களும் அகற்றப்படும்.';
  }

  @override
  String deleteMarkBody(String title) {
    return '$title-ஐ நீக்கவா? அதன் நினைவூட்டல்களும் அகற்றப்படும்.';
  }

  @override
  String get newMark => 'புதிய குறி';

  @override
  String get editMark => 'குறியைத் திருத்து';

  @override
  String repeatFromNotice(String repeatSummary, String date) {
    return '$repeatSummary, $date முதல். மாற்றங்கள் ஒவ்வொரு மறுநிகழ்விற்கும் பொருந்தும்.';
  }

  @override
  String get markTypeSectionTitle => 'குறி வகை';

  @override
  String get iconSectionTitle => 'சின்னம்';

  @override
  String get iconNone => 'எதுவுமில்லை';

  @override
  String get labelFieldLabel => 'லேபிள்';

  @override
  String get detailsFieldLabel => 'விவரங்கள் / குறிப்புகள்';

  @override
  String get remindMeAtSectionTitle => 'எனக்கு நினைவூட்டு';

  @override
  String removeTimeTooltip(String time) {
    return '$time-ஐ அகற்று';
  }

  @override
  String get addTime => 'நேரத்தைச் சேர்';

  @override
  String get repeatSectionTitle => 'மறுநிகழ்வு';

  @override
  String get onHomeScreenSectionTitle => 'உங்கள் முகப்புத் திரையில்';

  @override
  String showFromTime(String time) {
    return '$time முதல் காட்டு';
  }

  @override
  String get homeModeNoneExplain => 'குறி காலண்டரில் மட்டுமே இருக்கும்.';

  @override
  String get homeModeMorningExplain =>
      'அந்த நேரத்தில் முகப்பில் ஒரு அட்டை தோன்றும். முடிந்ததும் அதை ஸ்வைப் செய்யவும்: அடுத்த மறுநிகழ்வில் அது மீண்டும் வரும்.';

  @override
  String get homeModeAllDayExplain =>
      'ஒரு அட்டை முகப்பில் நாள் முழுவதும் பின் செய்யப்பட்டிருக்கும் (இதை ஸ்வைப் செய்ய முடியாது).';

  @override
  String get tomorrow => 'நாளை';

  @override
  String get yesterday => 'நேற்று';

  @override
  String get startAgain => 'மீண்டும் தொடங்கு';

  @override
  String get settingsAction => 'அமைப்புகள்';

  @override
  String get clockToolClockSubtitle => 'பெரிய, நேரடி நேரம் மற்றும் தேதி';

  @override
  String get clockToolSunAlarmTitle => 'சூரிய அடிப்படையிலான அலாரம்';

  @override
  String get clockToolSunAlarmSubtitle =>
      'சூரிய உதயம் அல்லது அஸ்தமனத்தில், ஒரு ஆஃப்செட்டுடன் எழுங்கள்';

  @override
  String get clockToolWorldClockTitle => 'உலகக் கடிகாரம்';

  @override
  String get clockToolWorldClockSubtitle =>
      'அமிர்தசரஸ், அரித்வார், லண்டன் மற்றும் பல';

  @override
  String get clockToolTimerTitle => 'சாதனை & விரத நேரங்காட்டி';

  @override
  String get clockToolTimerSubtitle =>
      'ஆரத்தி, சாலிசா, பாத், ஹவன், அல்லது சூரிய அஸ்தமனம் வரை';

  @override
  String get clockToolStopwatchTitle => 'பாத் ஸ்டாப்வாட்ச்';

  @override
  String get clockToolStopwatchSubtitle =>
      'தொடங்கு, நிறுத்து மற்றும் லாப் செய்';

  @override
  String get sunEventSunrise => 'சூரிய உதயம்';

  @override
  String get sunEventSunset => 'சூரிய அஸ்தமனம்';

  @override
  String offsetAtEvent(String event) {
    return '$event இல்';
  }

  @override
  String offsetMinutesOnly(int m) {
    return '$m நிமிடங்கள்';
  }

  @override
  String offsetHoursOnly(int h) {
    return '$h மணி';
  }

  @override
  String offsetHoursMinutes(int h, int m) {
    return '$h மணி $m நிமிடங்கள்';
  }

  @override
  String offsetBefore(String amount) {
    return '$amount முன்பு';
  }

  @override
  String offsetAfter(String amount) {
    return '$amount பிறகு';
  }

  @override
  String get locationSourceDevice => 'உங்கள் இருப்பிடம்';

  @override
  String get locationSourceSaved => 'உங்கள் கடைசியாக அறியப்பட்ட இருப்பிடம்';

  @override
  String get locationSourceFallback => 'அமிர்தசரஸ் (இயல்புநிலை)';

  @override
  String get locSummaryDevice => 'உங்கள் இருப்பிடத்தைப் பயன்படுத்துகிறது';

  @override
  String get locSummarySaved =>
      'உங்கள் கடைசியாக அறியப்பட்ட இருப்பிடத்தைப் பயன்படுத்துகிறது';

  @override
  String get locSummaryBlocked =>
      'அமிர்தசரஸ் பயன்படுத்தப்படுகிறது. அமைப்புகளில் இருப்பிடம் தடுக்கப்பட்டுள்ளது.';

  @override
  String get locSummaryServiceOff =>
      'அமிர்தசரஸ் பயன்படுத்தப்படுகிறது. துல்லியமான நேரத்திற்கு இருப்பிடத்தை இயக்கவும்.';

  @override
  String get locSummaryUnsupported => 'அமிர்தசரஸ் பயன்படுத்தப்படுகிறது.';

  @override
  String get locSummaryDefault =>
      'அமிர்தசரஸ் பயன்படுத்தப்படுகிறது. துல்லியமான நேரத்திற்கு இருப்பிடத்தை அனுமதிக்கவும்.';

  @override
  String get presetAarti => 'ஆரத்தி';

  @override
  String get presetChalisa => 'சாலிசா';

  @override
  String get presetPath => 'பாத்';

  @override
  String get presetHavan => 'ஹவன்';

  @override
  String get vratToSunset => 'விரதம் → சூரிய அஸ்தமனம்';

  @override
  String presetChipLabel(String label, int minutes) {
    return '$label · $minutes நிமிடங்கள்';
  }

  @override
  String get clockNoSunsetHere => 'இங்கே இப்போது எண்ண சூரிய அஸ்தமனம் இல்லை.';

  @override
  String get clockSunsetPassedTomorrow =>
      'இன்றைய சூரிய அஸ்தமனம் கடந்துவிட்டது: நாளைக்கு எண்ணப்படுகிறது.';

  @override
  String timerFinishedTitle(String label) {
    return '🔔 $label முடிந்தது';
  }

  @override
  String get sunsetArrived => 'சூரிய அஸ்தமனம் வந்துவிட்டது 🙏';

  @override
  String timerTimeUp(String label) {
    return 'உங்கள் $label நேரம் முடிந்தது 🙏';
  }

  @override
  String sunAlarmNotifTitle(String emoji, String event) {
    return '$emoji $event அலாரம்';
  }

  @override
  String sunAlarmNotifBody(String event, String time, String offset) {
    return '$event $time இல் உள்ளது · $offset';
  }

  @override
  String get statusOn => 'இயக்கத்தில்';

  @override
  String get finished => 'முடிந்தது';

  @override
  String get left => 'மீதம்';

  @override
  String get paused => 'இடைநிறுத்தப்பட்டது';

  @override
  String get runningStatus => 'இயங்குகிறது';

  @override
  String get stoppedStatus => 'நிறுத்தப்பட்டது';

  @override
  String get lap => 'லாப்';

  @override
  String get lapTime => 'லாப் நேரம்';

  @override
  String get total => 'மொத்தம்';

  @override
  String get fastest => 'வேகமானது';

  @override
  String get slowest => 'மெதுவானது';

  @override
  String get tapLapToMark => 'லாப்பைக் குறிக்க Lap-ஐ தட்டவும்.';

  @override
  String get startThenTapLap =>
      'Start செய்து, ஒவ்வொரு சுற்றிலும் Lap-ஐ தட்டவும்.';

  @override
  String get allowNotificationsForAlarm =>
      'அலாரம் ஒலிக்க அமைப்புகளில் அறிவிப்புகளை இயக்கவும்.';

  @override
  String get alarmRingsAt => 'அலாரம் ஒலிக்கும்';

  @override
  String get alarmWouldRingAt => 'அலாரம் ஒலித்திருக்கும்';

  @override
  String noEventToFollow(String event) {
    return 'இங்கே இப்போது பின்பற்ற $event இல்லை.';
  }

  @override
  String get alarmOnLabel => 'அலாரம் இயக்கத்தில்';

  @override
  String get recalculatedDaily =>
      'சூரியன் நகரும்போது தினமும் மீண்டும் கணக்கிடப்படும்';

  @override
  String todayHereSunriseSunset(String rise, String set) {
    return 'இங்கே இன்று: சூரிய உதயம் $rise · சூரிய அஸ்தமனம் $set';
  }

  @override
  String get whenLabel => 'எப்போது';

  @override
  String get minutesLabel => 'நிமிடங்கள்';

  @override
  String get upTo1440 => '1440 வரை';

  @override
  String get before => 'முன்பு';

  @override
  String get after => 'பிறகு';

  @override
  String get useMyLocation => 'எனது இருப்பிடத்தைப் பயன்படுத்து';

  @override
  String get couldNotReadPosition => ' · உங்கள் நிலையைப் படிக்க முடியவில்லை';

  @override
  String get timesUp => 'நேரம் முடிந்தது 🙏';

  @override
  String sunsetAtTime(String time) {
    return 'சூரிய அஸ்தமனம் $time இல்';
  }

  @override
  String cityInDays(int days) {
    return '$days நாட்களில்';
  }

  @override
  String cityDaysAgo(int days) {
    return '$days நாட்களுக்கு முன்பு';
  }

  @override
  String get citySameTime => 'உங்களைப் போன்ற அதே நேரம்';

  @override
  String cityAmountMinutes(int m) {
    return '$m நிமி';
  }

  @override
  String cityAmountHours(int h) {
    return '$h ம';
  }

  @override
  String cityAmountHoursMinutes(int h, int m) {
    return '$h ம $m நிமி';
  }

  @override
  String cityAheadOfYou(String amount) {
    return 'உங்களை விட $amount முன்னால்';
  }

  @override
  String cityBehindYou(String amount) {
    return 'உங்களை விட $amount பின்னால்';
  }

  @override
  String get traditionHindu => 'இந்து';

  @override
  String get traditionSikh => 'சீக்கியர்';

  @override
  String get traditionPlace => 'இடத்தின்படி';

  @override
  String get todayLabelTithi => 'திதி';

  @override
  String get todayLabelNakshatra => 'நட்சத்திரம்';

  @override
  String get todayLabelRahu => 'ராகு காலம்';

  @override
  String get todayLabelAbhijit => 'அபிஜித் முகூர்த்தம்';

  @override
  String get todayLabelHukamnama => 'ஹுக்கம்நாமா';

  @override
  String get todayLabelNitnem => 'நித்நேம் நிலுவை';

  @override
  String get todayLabelGurpurab => 'அடுத்த குருபர்ப்';

  @override
  String get todayLabelFestival => 'உள்ளூர் திருவிழா';

  @override
  String get todayLabelWindow => 'நல்ல நேரம்';

  @override
  String get exampleTag => 'எடுத்துக்காட்டு';

  @override
  String get exampleNote =>
      'எடுத்துக்காட்டு எனக் குறிக்கப்பட்ட மதிப்புகள் இடம்பிடிப்பான்கள்: உண்மையான பஞ்சாங்க தரவு பின்னர் வரும்.';

  @override
  String liveNote(String where) {
    return 'சூரிய உதயமும் அஸ்தமனமும் உங்கள் இடத்திற்காகக் கணக்கிடப்படுகின்றன. $where.';
  }

  @override
  String get greetingMorning => 'காலை வணக்கம்';

  @override
  String get greetingAfternoon => 'மதிய வணக்கம்';

  @override
  String get greetingEvening => 'மாலை வணக்கம்';

  @override
  String get greetingNight => 'இரவு வணக்கம்';

  @override
  String get homeEmptyTitle => 'இன்று உங்கள் முகப்புத் திரையில் எதுவும் இல்லை';

  @override
  String get homeEmptyBody =>
      'காலண்டரில் ஒரு தேதியைக் குறித்து, இங்கே பார்க்க \"உங்கள் முகப்புத் திரையில்\" என்பதைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get pinnedAllDay => 'நாள் முழுவதும் பின் செய்யப்பட்டது';

  @override
  String get swipeToDismiss => 'இன்றைக்கு நீக்க ஸ்வைப் செய்யவும்';

  @override
  String doneForToday(String title) {
    return 'இன்றைக்கு முடிந்தது: $title';
  }

  @override
  String get undoAction => 'செயல்தவிர்';

  @override
  String get doneForTodayLabel => 'இன்றைக்கு முடிந்தது';

  @override
  String get plansTitle => 'பாத் & மந்திரத் திட்டங்கள்';

  @override
  String get addPlan => 'திட்டத்தைச் சேர்';

  @override
  String get dayStreak => 'நாள் தொடர்ச்சி';

  @override
  String activePlanCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'செயலில் உள்ள திட்டங்கள்',
      one: 'செயலில் உள்ள திட்டம்',
    );
    return '$_temp0';
  }

  @override
  String get noPlansYet => 'இன்னும் திட்டங்கள் இல்லை';

  @override
  String get plansEmptyBody =>
      'ஒரு பாத் அல்லது மந்திரத்திற்கு பல நாட்கள் அர்ப்பணிப்புடன் இருந்து ஒவ்வொரு நாளையும் குறிக்கவும். இவற்றில் ஒன்றைத் தொடங்கவும் அல்லது உங்களுடையதைச் சேர்க்கவும்.';

  @override
  String get planOptionsTooltip => 'திட்ட விருப்பங்கள்';

  @override
  String get deletePlanMenuItem => 'திட்டத்தை நீக்கு';

  @override
  String get deletePlanQuestion => 'திட்டத்தை நீக்கவா?';

  @override
  String deletePlanBody(String title) {
    return '$title மற்றும் அதன் முன்னேற்றம் அகற்றப்படும்.';
  }

  @override
  String titledDaysTag(String title, int days) {
    return '$title · $days நாட்கள்';
  }

  @override
  String completedOfDays(int completed, int total) {
    return 'முடிந்தது · $total இல் $completed நாட்கள்';
  }

  @override
  String ofDays(int completed, int total) {
    return '$total இல் $completed நாட்கள்';
  }

  @override
  String get doneTodayButton => 'இன்று முடிந்தது';

  @override
  String get markTodayDone => 'இன்று முடிந்ததாகக் குறி';

  @override
  String get newPlanTitle => 'புதிய திட்டம்';

  @override
  String get newPlanSubtitle =>
      'ஒரு பாத் அல்லது மந்திரத்தைத் தேர்ந்தெடுத்து எத்தனை நாட்கள் தொடர்வீர்கள் என்பதைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get paathOrMantraLabel => 'பாத் அல்லது மந்திரம்';

  @override
  String get giveThePlanAName => 'திட்டத்திற்கு ஒரு பெயர் கொடுங்கள்';

  @override
  String chooseDaysRange(int min, int max) {
    return '$min முதல் $max நாட்களைத் தேர்ந்தெடுக்கவும்';
  }

  @override
  String get forHowManyDays => 'எத்தனை நாட்களுக்கு?';

  @override
  String get daysFieldLabel => 'நாட்கள்';

  @override
  String get startPlanButton => 'திட்டத்தைத் தொடங்கு';

  @override
  String get planKindPaath => 'பாத்';

  @override
  String get planKindMantra => 'மந்திரம்';

  @override
  String get profileTitle => 'சுயவிவரம்';

  @override
  String get sadhanaSettingsTitle => 'சாதனை அமைப்புகள்';

  @override
  String get validEmailError => 'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்';

  @override
  String nameTooLong(int max) {
    return 'இதை $max எழுத்துகளுக்குள் வைக்கவும்';
  }

  @override
  String get enterCurrentPassword => 'உங்கள் தற்போதைய கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String passwordTooShort(int min) {
    return 'குறைந்தது $min எழுத்துகளைப் பயன்படுத்தவும்';
  }

  @override
  String get passwordAlreadyUsed =>
      'நீங்கள் முன்பு பயன்படுத்தாத கடவுச்சொல்லைத் தேர்ந்தெடுக்கவும்';

  @override
  String get passwordsDontMatch => 'இரண்டு கடவுச்சொற்களும் பொருந்தவில்லை';

  @override
  String get changePasswordTitle => 'கடவுச்சொல்லை மாற்று';

  @override
  String get accountsLaterNote =>
      'கணக்குகள் பின்னர் வரும்; அதுவரை இது உங்கள் உள்ளீடுகளை மட்டுமே சரிபார்க்கும், எதையும் மாற்றாது.';

  @override
  String get currentPasswordLabel => 'தற்போதைய கடவுச்சொல்';

  @override
  String get newPasswordLabel => 'புதிய கடவுச்சொல்';

  @override
  String get confirmNewPasswordLabel => 'புதிய கடவுச்சொல்லை உறுதிப்படுத்தவும்';

  @override
  String get showPasswords => 'கடவுச்சொற்களைக் காட்டு';

  @override
  String get updatePasswordButton => 'கடவுச்சொல்லைப் புதுப்பி';

  @override
  String get stepAddName => 'உங்கள் பெயரைச் சேர்';

  @override
  String get stepAddEmail => 'உங்கள் மின்னஞ்சலைச் சேர்';

  @override
  String get stepPickTradition =>
      'முகப்பில் உங்கள் பாரம்பரியத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get stepTurnOnReminder => 'தினசரி நினைவூட்டலை இயக்கு';

  @override
  String get stepStartPlan => 'ஒரு பாத் அல்லது மந்திரத் திட்டத்தைத் தொடங்கு';

  @override
  String get profileCompletionTitle => 'சுயவிவர நிறைவு';

  @override
  String get profileCompleteReward =>
      'சுயவிவரம் முடிந்தது! பிரீமியம் வெளியிடப்படும்போது உங்கள் இலவச பிரீமியம் வெகுமதி காத்திருக்கும்.';

  @override
  String get reachRewardNote =>
      'வெளியிடப்படும்போது இலவச பிரீமியத்தைப் பெற 100% ஐ அடையுங்கள்.';

  @override
  String get aboutTitle => 'பற்றி';

  @override
  String get appLabel => 'செயலி';

  @override
  String get websiteLabel => 'இணையதளம்';

  @override
  String get versionLabel => 'பதிப்பு';

  @override
  String get passwordWillWorkLater =>
      'கணக்குகள் சேர்க்கப்பட்டவுடன் கடவுச்சொல் மாற்றம் செயல்படும்.';

  @override
  String get signedOut => 'வெளியேறியது';

  @override
  String get notSignedInYet =>
      'நீங்கள் இன்னும் உள்நுழையவில்லை: கணக்குகள் பின்னர் வரும். உங்கள் தரவு இந்தச் சாதனத்திலேயே இருக்கும்.';

  @override
  String get accountTitle => 'கணக்கு';

  @override
  String get signOutButton => 'வெளியேறு';

  @override
  String get backupSaved => 'காப்பு சேமிக்கப்பட்டது';

  @override
  String get backupCancelled => 'காப்பு ரத்து செய்யப்பட்டது';

  @override
  String get couldNotSaveBackup =>
      'காப்பைச் சேமிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get backupNotSadho => 'அந்தக் கோப்பு Sadho காப்பு அல்ல.';

  @override
  String get couldNotReadFile => 'அந்தக் கோப்பைப் படிக்க முடியவில்லை.';

  @override
  String get backupDamaged => 'காப்புக் கோப்பு சேதமடைந்துள்ளது.';

  @override
  String get backupTooNew =>
      'இந்தக் காப்பு Sadho இன் புதிய பதிப்பால் உருவாக்கப்பட்டது. முதலில் செயலியைப் புதுப்பிக்கவும்.';

  @override
  String get backupNoData => 'அந்தக் காப்பில் Sadho தரவு இல்லை.';

  @override
  String get backupTooBig =>
      'அந்தக் கோப்பு Sadho காப்பாக இருக்க மிகப் பெரியது.';

  @override
  String madeOnSuffix(String date) {
    return ' $date அன்று உருவாக்கப்பட்டது';
  }

  @override
  String restoreBackupBody(String made, int count) {
    return 'ஒரு காப்பு$made இதில் $count சேமிக்கப்பட்ட உருப்படிகள் உள்ளன. இது இந்தத் தொலைபேசியில் உள்ளவற்றை மாற்றும்: குறிகள், திட்டங்கள், மந்திரங்கள், குரல் பயிற்சி மற்றும் அமைப்புகள்.';
  }

  @override
  String get restoreThisBackup => 'இந்தக் காப்பை மீட்டெடுக்கவா?';

  @override
  String get backupRestoredTitle => 'காப்பு மீட்டெடுக்கப்பட்டது';

  @override
  String get backupRestoredBody =>
      'Sadho உங்கள் மீட்டெடுக்கப்பட்ட தரவுடன் மீண்டும் ஏற்றப்படும்.';

  @override
  String get backupRestoreTitle => 'காப்பு & மீட்டமைப்பு';

  @override
  String get backupExplain =>
      'உங்கள் குறிகள், திட்டங்கள், மந்திரங்கள், குரல் பயிற்சி மற்றும் அமைப்புகளை நீங்கள் தேர்ந்தெடுக்கும் கோப்பில் சேமிக்கவும் (Drive, Files, உங்களுக்கே மின்னஞ்சல் செய்யவும்). இதை இந்த அல்லது வேறு தொலைபேசியில் மீட்டெடுக்கவும்.';

  @override
  String get exportButton => 'ஏற்றுமதி';

  @override
  String get restoreButton => 'மீட்டெடு';

  @override
  String get cloudSyncTitle => 'க்ளவுட் ஒத்திசைவு';

  @override
  String get comingLater => 'பின்னர் வரும்';

  @override
  String get saveBackupDialogTitle => 'உங்கள் Sadho காப்பைச் சேமிக்கவும்';

  @override
  String get chooseBackupDialogTitle => 'ஒரு Sadho காப்பைத் தேர்ந்தெடுக்கவும்';

  @override
  String get areYouSure => 'நீங்கள் உறுதியாக இருக்கிறீர்களா?';

  @override
  String get deleteAccountWarning =>
      'இது உங்கள் கணக்கையும் இந்தத் தொலைபேசியில் சேமிக்கப்பட்ட அனைத்தையும் நீக்கும்: உங்கள் சுயவிவரம், குறிகள், திட்டங்கள், மந்திரங்கள், குரல் பயிற்சி மற்றும் அமைப்புகள். இதைச் செயல்தவிர்க்க முடியாது.';

  @override
  String get yesAction => 'ஆம்';

  @override
  String get noAction => 'இல்லை';

  @override
  String get dangerZoneTitle => 'ஆபத்து மண்டலம்';

  @override
  String get deleteAccountExplain =>
      'உங்கள் கணக்கை நீக்குவது உங்கள் சுயவிவரத்தையும் இந்தத் தொலைபேசியில் சேமிக்கப்பட்ட அனைத்தையும் அழிக்கும். அதைத் திரும்பப் பெற விரும்பினால் முதலில் காப்பை ஏற்றுமதி செய்யவும்.';

  @override
  String get deleteAccountButton => 'கணக்கை நீக்கு';

  @override
  String get profileSaved => 'சுயவிவரம் சேமிக்கப்பட்டது';

  @override
  String get yourDetailsTitle => 'உங்கள் விவரங்கள்';

  @override
  String get nameLabel => 'பெயர்';

  @override
  String get emailLabel => 'மின்னஞ்சல்';

  @override
  String get dailyReminderTitle => 'தினசரி நினைவூட்டல்';

  @override
  String get dailySadhanaReminder => 'தினசரி சாதனை நினைவூட்டல்';

  @override
  String get reminderOff => 'நிறுத்தப்பட்டது';

  @override
  String everyDayAt(String time) {
    return 'ஒவ்வொரு நாளும் $time இல்';
  }

  @override
  String get allowNotificationsForReminder =>
      'நினைவூட்டல் ஒலிக்க அமைப்புகளில் அறிவிப்புகளை இயக்கவும்.';

  @override
  String get timeLabel => 'நேரம்';

  @override
  String get themeTitle => 'தீம்';

  @override
  String get lightMode => 'வெளிர்';

  @override
  String get darkMode => 'இருள்';

  @override
  String get systemMode => 'கணினி';

  @override
  String get coloursTitle => 'வண்ணங்கள்';

  @override
  String paletteSemantic(String name) {
    return '$name வண்ணங்கள்';
  }

  @override
  String get paletteMarigoldName => 'செண்டு';

  @override
  String get paletteMarigoldBlurb => 'சூடான குங்குமப்பூ மற்றும் ஆழமான நீலம்';

  @override
  String get paletteSandalwoodName => 'சந்தனம்';

  @override
  String get paletteSandalwoodBlurb => 'மென்மையான சந்தன பழுப்பு மற்றும் களிமண்';

  @override
  String get paletteTulsiName => 'துளசி பச்சை';

  @override
  String get paletteTulsiBlurb => 'அமைதியான புனித-துளசி பச்சை';

  @override
  String get paletteTwilightName => 'அந்தி நீலம்';

  @override
  String get paletteTwilightBlurb => 'விளக்கு-ஒளி தங்கத்துடன் அந்தி நீலம்';

  @override
  String get paletteLotusName => 'தாமரை இளஞ்சிவப்பு';

  @override
  String get paletteLotusBlurb =>
      'மென்மையான தாமரை இளஞ்சிவப்பு மற்றும் இலை பச்சை';

  @override
  String get sadhanaTimeNotifTitle => '🪔 உங்கள் சாதனை நேரம்';

  @override
  String get sadhanaTimeNotifBody =>
      'உங்கள் பாத் அல்லது மந்திரத்திற்கு சில அமைதியான நிமிடங்களை ஒதுக்குங்கள் 🙏';

  @override
  String get comingSoon => 'விரைவில் வரும்';

  @override
  String get trainAction => 'பயிற்சி செய்';

  @override
  String get onboardingTitle => 'Sadho-க்கு வரவேற்கிறோம்';

  @override
  String get onboardingSubtitle =>
      'தொடங்க உங்கள் மொழி மற்றும் பாரம்பரியத்தைத் தேர்ந்தெடுக்கவும். இரண்டையும் பின்னர் சுயவிவரத்தில் மாற்றலாம்.';

  @override
  String get traditionHeading => 'பாரம்பரியம்';

  @override
  String get continueAction => 'தொடரவும்';

  @override
  String get stopAlert => 'நிறுத்து';

  @override
  String get repeatLabel => 'மீண்டும்';

  @override
  String get repeatOnce => 'ஒருமுறை';

  @override
  String soundRepeatTimes(int times) {
    return '$times முறை';
  }

  @override
  String get repeatUntilStopped => 'நிறுத்தும் வரை';

  @override
  String vibrationRepeatUntilStopped(int seconds) {
    return 'ஒவ்வொரு $seconds வினாடிக்கும், நிறுத்தும் வரை';
  }

  @override
  String get keepScreenOnLabel => 'எண்ணும்போது திரையை இயக்கத்தில் வை';

  @override
  String get keepScreenOnSubtitle =>
      'அமர்வு ஓடும்போது திரை உறங்காது. பவர் பொத்தான் இன்னும் தொலைபேசியைப் பூட்டும்; அப்போது நேர அல்லது தாள அமர்வு முடிந்ததும் அலாரம் போல ஒலிக்கும்.';

  @override
  String get alarmMayBeLate =>
      'அலாரம் சற்று தாமதமாக ஒலிக்கலாம் (துல்லிய அலாரங்கள் முடக்கப்பட்டுள்ளன).';

  @override
  String get exactAlarmNotice =>
      'திரை அணைந்திருந்தாலும் சரியான நேரத்தில் ஒலிக்க, Sadho-க்கு துல்லிய அலாரங்களை அனுமதிக்கவும்.';

  @override
  String get fullScreenNotice =>
      'முடிந்த அமர்வைப் பூட்டுத் திரையில் காட்ட, முழுத்திரை விழிப்பூட்டல்களை அனுமதிக்கவும்.';

  @override
  String get allowAction => 'அனுமதி';

  @override
  String channelSadhanaAlarmName(String sound) {
    return 'சாதனா அலாரம் · $sound';
  }

  @override
  String get channelSadhanaAlarmSilentName => 'சாதனா அலாரம் · அமைதி';

  @override
  String get channelNoVibration => 'அதிர்வு இல்லை';

  @override
  String get channelSadhanaAlarmDesc =>
      'நேர அல்லது தாள அமர்வு முடிந்ததும் ஒலிக்கும்';

  @override
  String get alarmScreenSadhanaTitle => 'சாதனா நிறைவு 🙏';

  @override
  String get alarmScreenTimerTitle => 'டைமர் முடிந்தது';

  @override
  String get alarmScreenSunTitle => 'சூரிய அலாரம்';

  @override
  String get alarmScreenUnlock => 'Sadho-வைத் திறக்கத் திறவுங்கள்';

  @override
  String get alarmScreenUnlockHint =>
      'செயலியின் மற்ற பகுதிகளுக்கு தொலைபேசி திறக்கப்பட்டிருக்க வேண்டும்.';

  @override
  String get alarmsReliabilityTitle => 'அலாரங்கள் & நம்பகத்தன்மை';

  @override
  String get alarmsReliabilityIntro =>
      'திரை அணைந்திருந்தாலும் அலாரங்கள் சரியான நேரத்தில் ஒலிக்க, தொலைபேசி இவற்றை அனுமதிக்க வேண்டும். சரிசெய் சரியான அமைப்புப் பக்கத்தைத் திறக்கும்.';

  @override
  String get alarmsReliabilityAllOk =>
      'அலாரங்கள் சரியான நேரத்தில் ஒலிக்க எல்லாம் தயார்';

  @override
  String get alarmsReliabilityAttention => 'ஏதோ கவனம் தேவை';

  @override
  String get healthOk => 'சரி';

  @override
  String get healthNeedsAttention => 'கவனம் தேவை';

  @override
  String get healthFix => 'சரிசெய்';

  @override
  String get healthNotificationsTitle => 'அறிவிப்புகள் அனுமதிக்கப்பட்டன';

  @override
  String get healthNotificationsBody =>
      'அலாரங்களும் நினைவூட்டல்களும் அறிவிப்புகளாக வரும்.';

  @override
  String get healthExactTitle => 'துல்லிய அலாரங்கள் அனுமதிக்கப்பட்டன';

  @override
  String get healthExactBody => 'சரியான வினாடியில் ஒலிக்கும், தாமதமாக அல்ல.';

  @override
  String get healthFullScreenTitle => 'பூட்டுத் திரையில் அலாரங்களைக் காட்டு';

  @override
  String get healthFullScreenBody =>
      'தொலைபேசி பூட்டியிருந்தாலும் முடிந்த அலாரம் தெரியும்.';

  @override
  String get healthBatteryTitle => 'பேட்டரி: செயலி கட்டுப்படுத்தப்படவில்லை';

  @override
  String get healthBatteryBody =>
      'பேட்டரியில் கட்டுப்பாடற்றது என்பதைத் தேர்வுசெய்யவும் (குறைந்தது கட்டுப்படுத்தப்பட்டது அல்ல), அப்போது தொலைபேசி அலாரங்களைத் தடுக்காது.';

  @override
  String get healthBatterySamsungHint =>
      'Samsung: அமைப்புகள் › பேட்டரி › பின்னணி பயன்பாட்டு வரம்புகளில், Sadho-வை “உறங்கும் செயலிகள்” மற்றும் “ஆழ்ந்து உறங்கும் செயலிகள்” இலிருந்து நீக்கி, பேட்டரி பயன்பாட்டை “கட்டுப்பாடற்றது” என அமைக்கவும்.';

  @override
  String get alarmExplainerOk =>
      'இந்த அமர்வு முடிந்ததும் அலாரம் போல ஒலிக்கும், திரை அல்லது செயலி மூடியிருந்தாலும்.';

  @override
  String get alarmExplainerAttention =>
      'இந்த அமர்வு முடிந்ததும் அலாரம் போல ஒலிக்கும், ஆனால் சரியான நேரத்தில் ஒலிக்க தொலைபேசியில் ஒரு அமைப்பை மாற்ற வேண்டும்.';

  @override
  String get alarmExplainerCheck => 'சரிபார்';

  @override
  String get customTimerName => 'தனிப்பயன் டைமர்';

  @override
  String customChipLabel(String duration) {
    return 'தனிப்பயன் · $duration';
  }

  @override
  String get customTimerTitle => 'தனிப்பயன் கால அளவு';

  @override
  String get customTimerRange =>
      '1 விநாடி முதல் 24 மணிநேரம் வரை தேர்வுசெய்யவும்.';

  @override
  String durationHours(int hours) {
    return '$hours மணி';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes நிமி';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds வி';
  }

  @override
  String collapseSection(String section) {
    return '$section மறை';
  }

  @override
  String expandSection(String section) {
    return '$section காட்டு';
  }

  @override
  String get summaryVibrationOn => 'அதிர்வு இயக்கத்தில்';

  @override
  String get summaryVibrationOff => 'அதிர்வு முடக்கத்தில்';

  @override
  String get summarySoundOff => 'ஒலி முடக்கத்தில்';

  @override
  String get summaryNotSet => 'அமைக்கப்படவில்லை';

  @override
  String get clockToolNotepadTitle => 'குறிப்பேடு';

  @override
  String get clockToolNotepadSubtitle => 'குறிப்புகள், இந்த ஃபோனிலேயே';

  @override
  String get notesSearchHint => 'குறிப்புகளைத் தேடு';

  @override
  String get notesEmpty => 'இன்னும் குறிப்புகள் இல்லை. எழுத + தட்டவும்.';

  @override
  String notesNoMatch(String query) {
    return '“$query” உடன் பொருந்தும் குறிப்பு இல்லை.';
  }

  @override
  String get noteNew => 'புதிய குறிப்பு';

  @override
  String get noteEdit => 'குறிப்பு';

  @override
  String get noteTitleHint => 'தலைப்பு (விருப்பம்)';

  @override
  String get noteTextHint => 'இங்கே எழுதுங்கள்…';

  @override
  String get noteUntitled => 'காலியான குறிப்பு';

  @override
  String noteCreatedAt(String when) {
    return 'உருவாக்கியது $when';
  }

  @override
  String noteEditedAt(String when) {
    return 'திருத்தியது $when';
  }

  @override
  String get noteSavedAsYouType => 'தட்டச்சு செய்யும்போதே சேமிக்கப்படும்';

  @override
  String get noteDelete => 'குறிப்பை நீக்கு';

  @override
  String get noteDeleteQuestion => 'இந்தக் குறிப்பை நீக்கவா?';

  @override
  String noteDeleteBody(String title) {
    return '“$title” இந்த ஃபோனிலிருந்து நீக்கப்படும். இதைத் திரும்பப் பெற முடியாது.';
  }

  @override
  String get paletteHighContrastName => 'உயர் மாறுபாடு';

  @override
  String get paletteHighContrastBlurb => 'அதிகபட்ச வேறுபாடு, எளிதில் படிக்க';

  @override
  String get malaNotificationChannel => 'மாலை கவுண்டர்';

  @override
  String malaNotificationTitle(String count, String target) {
    return 'மாலை · $count / $target';
  }

  @override
  String malaNotificationTitleCount(String count) {
    return 'மாலை · $count';
  }

  @override
  String get malaNotificationRunning =>
      'எண்ண ஒலியளவு விசையை அழுத்தவும், திரை அணைந்திருந்தாலும்.';

  @override
  String get malaNotificationDone => 'இலக்கு நிறைவு 🙏';

  @override
  String get malaRingTitle => '🔔 மாலை நிறைவு';

  @override
  String malaRingBody(int target) {
    return 'நீங்கள் $target என்ற இலக்கை அடைந்தீர்கள் 🙏';
  }

  @override
  String get malaScreenOffUnavailable =>
      'இந்த ஃபோனில் திரை அணைந்த நிலையில் எண்ணுதலைத் தொடங்க முடியவில்லை. Sadho திறந்திருக்கும்போது மட்டுமே ஒலியளவு விசைகள் எண்ணும்.';

  @override
  String get pressVolumeKeysScreenOff =>
      'திரை அணைந்திருந்தாலும் ஒலியளவு விசைகள் எண்ணும்';

  @override
  String get malaScreenOffLabel => 'திரை அணைந்திருந்தாலும் எண்ணு';

  @override
  String get malaScreenOffOnSubtitle =>
      'ஃபோனைப் பூட்டி ஒலியளவு விசையை அழுத்திக்கொண்டே இருங்கள். ஒரு அறிவிப்பு எண்ணிக்கையைக் காட்டி இலக்கில் ஒலிக்கும்.';

  @override
  String get malaScreenOffOffSubtitle =>
      'அணைப்பு: Sadho திறந்து திரை இயங்கும்போது மட்டுமே ஒலியளவு விசைகள் எண்ணும்.';

  @override
  String get modeHelpMalaScreenOff =>
      'Start அழுத்தி, பிறகு எண்ண ஏதேனும் ஒலியளவு விசையை அழுத்தவும், ஃபோன் பூட்டப்பட்டு திரை அணைந்திருந்தாலும். கண்களை மூடியோ ஃபோன் பையில் இருந்தாலோ வசதியானது.';

  @override
  String get malaScreenOffExplainer =>
      'ஃபோனைப் பூட்டி, எண்ண ஒலியளவு விசையை அழுத்தவும். பேட்டரியை \'கட்டுப்பாடற்றது\' ஆக்கவும்.';

  @override
  String get calibrateTitle => 'குரலை அளவீடு செய்';

  @override
  String calibrateIntro(int count) {
    return 'உங்கள் மந்திரத்தை வழக்கம் போல் $count முறை ஜபியுங்கள், ஒவ்வொன்றுக்கும் பின் சிறு இடைவெளி விட்டு. பிறகு Sadho குரல் எவ்வளவு கண்டிப்பாக இருக்க வேண்டும் என அமைக்கும்; அனைத்தும் எண்ணப்படும், அறையின் சத்தம் அல்ல. எதுவும் பதிவு செய்யப்படுவதோ வைக்கப்படுவதோ இல்லை.';
  }

  @override
  String calibrateChantNow(int count) {
    return 'இப்போது உங்கள் மந்திரத்தை $count முறை ஜபியுங்கள்';
  }

  @override
  String calibrateHeard(int heard, int count) {
    return '$count-இல் $heard கேட்டது';
  }

  @override
  String calibrateSkipped(int count) {
    return 'ஒரு ஜபம் அல்லாத $count ஒலிகள் தவிர்க்கப்பட்டன';
  }

  @override
  String get calibrateDone => 'அளவீடு முடிந்தது';

  @override
  String calibrateDoneBody(int count) {
    return 'அனைத்து $count ஜபங்களும் எண்ணப்படும்; அறையின் சத்தம் அல்ல.';
  }

  @override
  String get calibrateStart => 'அளவீட்டைத் தொடங்கு';

  @override
  String get calibrateSave => 'அளவீட்டைச் சேமி';

  @override
  String calibrationSaved(String mantra) {
    return '“$mantra”-க்கான அளவீடு சேமிக்கப்பட்டது';
  }

  @override
  String get calibrateVoice => 'அளவீடு செய்';

  @override
  String get recalibrateVoice => 'மீண்டும் அளவீடு';

  @override
  String get quietModeLabel => 'அமர்வின் போது பிற அறிவிப்புகளை அமைதியாக்கு';

  @override
  String get quietModeSubtitle =>
      'அமர்வு நடக்கும்போது \'தொந்தரவு செய்யாதே\' (அலாரங்கள் மட்டும்) இயக்கப்படும், Sadho அலாரம் ஒலிக்கும். பின்னர் உங்கள் சொந்த அமைப்பு திரும்பும்.';

  @override
  String get quietModeAccessTitle => '\'தொந்தரவு செய்யாதே\' அணுகலை அனுமதி';

  @override
  String get quietModeAccessBody =>
      'சாதனையின் போது பிற அறிவிப்புகளை அமைதியாக்க Sadho-க்கு \'தொந்தரவு செய்யாதே\' அணுகல் தேவை. அடுத்த திரையில் Sadho-வைக் கண்டு அனுமதியுங்கள். அமர்வு நடக்கும்போது மட்டுமே Sadho \'அலாரங்கள் மட்டும்\' பயன்முறையை இயக்கி, பின்னர் உங்கள் அமைப்பைத் திருப்பி வைக்கும்.';

  @override
  String get healthDndTitle => '\'தொந்தரவு செய்யாதே\' அணுகல்';

  @override
  String get healthDndBody =>
      'அமர்வின் போது பிற அறிவிப்புகளை அமைதியாக்கத் தேவை. இது இல்லாமல் Sadho \'தொந்தரவு செய்யாதே\'-ஐத் தொடாது.';

  @override
  String get legalPrivacyPolicy => 'தனியுரிமைக் கொள்கை';

  @override
  String get legalTermsOfUse => 'பயன்பாட்டு விதிமுறைகள்';

  @override
  String get legalContact => 'தொடர்பு & குறைதீர்ப்பு';

  @override
  String get legalDeleteData => 'உங்கள் தரவை நீக்கு';

  @override
  String get legalLicenses => 'திறமூல உரிமங்கள்';

  @override
  String linkOpenFailed(String url) {
    return '$url ஐத் திறக்க முடியவில்லை';
  }

  @override
  String onboardingLegalNotice(String terms, String privacy) {
    return 'உங்கள் சாதனை, நாட்காட்டி, குரல் பயிற்சி மற்றும் இருப்பிடம் இந்த ஃபோனிலேயே இருக்கும். தொடர்வதன் மூலம் நீங்கள் $terms ஏற்கிறீர்கள், $privacy படித்துள்ளீர்கள்.';
  }

  @override
  String get channelSadhanaAlarmV2Name => 'சாதனா அலாரம்';
}
