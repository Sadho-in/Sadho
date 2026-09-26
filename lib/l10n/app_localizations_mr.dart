// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get navHome => 'होम';

  @override
  String get navSadhana => 'साधना';

  @override
  String get navCalendar => 'कॅलेंडर';

  @override
  String get navClock => 'घड्याळ';

  @override
  String get tooltipLanguage => 'भाषा';

  @override
  String get tooltipProfile => 'प्रोफाइल';

  @override
  String get tooltipSwitchToLight => 'लाइट थीमवर जा';

  @override
  String get tooltipSwitchToDark => 'डार्क थीमवर जा';

  @override
  String get languageSheetTitle => 'भाषा';

  @override
  String get languageSheetSubtitle =>
      'तुमची निवड जतन केली जाते आणि लगेच लागू होते.';

  @override
  String get actionCancel => 'रद्द करा';

  @override
  String get actionDelete => 'हटवा';

  @override
  String get actionSave => 'जतन करा';

  @override
  String get actionReset => 'रीसेट करा';

  @override
  String get actionEdit => 'संपादित करा';

  @override
  String get actionOk => 'ठीक आहे';

  @override
  String get unitSeconds => 'सेकंद';

  @override
  String get unitMinutes => 'मिनिटे';

  @override
  String get unitHours => 'तास';

  @override
  String get paceErrorEmpty => 'गती प्रविष्ट करा.';

  @override
  String get paceErrorNotNumber => 'ही संख्या नाही.';

  @override
  String paceErrorTooFast(String min) {
    return 'खूप वेगवान. किमान $min आहे.';
  }

  @override
  String paceErrorTooSlow(String max) {
    return 'खूप संथ. कमाल $max आहे.';
  }

  @override
  String get modeTap => 'टॅप';

  @override
  String get modeRhythm => 'ताल';

  @override
  String get modeVoice => 'आवाज';

  @override
  String get modeMala => 'माळ';

  @override
  String get ringtoneTempleBell => 'मंदिराची घंटा';

  @override
  String get ringtoneSingingBowl => 'सिंगिंग बाऊल';

  @override
  String get ringtoneSoftChime => 'मंद किणकिण';

  @override
  String get ringtoneDeepGong => 'गहिरा घंटानाद';

  @override
  String get msgVoiceUnsupported => 'आवाज मोजणी फक्त Android आणि iOS वर चालते';

  @override
  String get msgVoiceNoMic => 'या डिव्हाइसवर मायक्रोफोन उपलब्ध नाही';

  @override
  String get msgMalaUnsupported =>
      'व्हॉल्यूम-की मोजणीसाठी प्रत्यक्ष डिव्हाइस आवश्यक आहे';

  @override
  String trainFirstPrompt(int min, int max) {
    return 'आधी या मंत्रासाठी तुमचा आवाज प्रशिक्षित करा: तो $min ते $max वेळा रेकॉर्ड करा.';
  }

  @override
  String get fallbackVoiceDenied =>
      'मायक्रोफोन परवानगी नाकारली गेली, त्यामुळे आवाज मोजणी ऐकू शकत नाही. टॅप मोड वापरत आहे.';

  @override
  String get fallbackVoiceBlocked =>
      'मायक्रोफोन प्रवेश अवरोधित आहे. आवाज मोजणी वापरण्यासाठी सेटिंग्जमध्ये परवानगी द्या. टॅप मोड वापरत आहे.';

  @override
  String get fallbackVoiceUnsupported =>
      'आवाज मोजणी फक्त Android आणि iOS वर चालते. टॅप मोड वापरत आहे.';

  @override
  String get fallbackVoiceNoMic =>
      'या डिव्हाइसवर मायक्रोफोन उपलब्ध नाही. टॅप मोड वापरत आहे.';

  @override
  String get fallbackMalaUnsupported =>
      'व्हॉल्यूम-की मोजणीसाठी प्रत्यक्ष डिव्हाइस आवश्यक आहे. टॅप मोड वापरत आहे.';

  @override
  String get sadhanaRingTitle => '🔔 साधनेची वेळ पूर्ण झाली';

  @override
  String get sadhanaRingBody => 'तुमच्या सत्राची वेळ संपली आहे 🙏';

  @override
  String get voiceTooShort => 'हे खूप लहान होते. संपूर्ण मंत्र म्हणा.';

  @override
  String get voiceRanTooLong => 'हे खूप लांबले. मंत्र एकदा म्हणा, मग थांबा.';

  @override
  String get voiceSoundedDifferent =>
      'हे इतरांपेक्षा वेगळे वाटले. तेच पुन्हा त्याच प्रकारे म्हणा.';

  @override
  String get voiceGotIt => 'समजले. पुन्हा म्हणा.';

  @override
  String get voiceDeniedShort =>
      'मायक्रोफोन परवानगी नाकारली गेली, त्यामुळे आवाज मोजणी ऐकू शकत नाही.';

  @override
  String get voiceBlockedShort =>
      'मायक्रोफोन प्रवेश अवरोधित आहे. आवाज मोजणी वापरण्यासाठी सेटिंग्जमध्ये परवानगी द्या.';

  @override
  String get voiceAccessLost =>
      'मायक्रोफोन प्रवेश गमावला, त्यामुळे आवाज मोजणी थांबली.';

  @override
  String get voiceCouldNotRestart =>
      'मायक्रोफोन पुन्हा सुरू होऊ शकला नाही, त्यामुळे आवाज मोजणी थांबली.';

  @override
  String get mantraLibraryTitle => 'मंत्र ग्रंथालय';

  @override
  String get addMantra => 'मंत्र जोडा';

  @override
  String get searchHint => 'शीर्षक, लिपी किंवा परंपरा शोधा';

  @override
  String noMantrasMatch(String query) {
    return '“$query” शी कोणताही मंत्र जुळत नाही.\nस्वतःचा तयार करण्यासाठी “मंत्र जोडा” टॅप करा.';
  }

  @override
  String mantraAdded(String title) {
    return '“$title” जोडले';
  }

  @override
  String mantraSaved(String title) {
    return '“$title” जतन केले';
  }

  @override
  String mantraRestored(String title) {
    return '“$title” त्याच्या मूळ स्थितीत पुनर्संचयित केले';
  }

  @override
  String get deleteMantraTitle => 'मंत्र हटवायचा?';

  @override
  String deleteMantraBody(String title) {
    return '“$title” तुमच्या ग्रंथालयातून काढले जाईल.';
  }

  @override
  String get retrainVoiceTooltip => 'आवाज पुन्हा प्रशिक्षित करा';

  @override
  String get trainVoice => 'आवाज प्रशिक्षित करा';

  @override
  String mantraCountTag(int count) {
    return '$count मोजणी';
  }

  @override
  String get editedTag => 'संपादित';

  @override
  String get editMantra => 'मंत्र संपादित करा';

  @override
  String get addAMantra => 'एक मंत्र जोडा';

  @override
  String get titleLabel => 'शीर्षक *';

  @override
  String get titleRequired => 'शीर्षक प्रविष्ट करा';

  @override
  String get scriptTextLabel => 'लिपी मजकूर';

  @override
  String get transliterationLabel => 'लिप्यंतरण';

  @override
  String get traditionLabel => 'परंपरा / भाषा';

  @override
  String get traditionHint => 'उदा. संस्कृत · हिंदू';

  @override
  String get defaultCountLabel => 'मूळ मोजणी *';

  @override
  String get enterNumberOneOrMore => '1 किंवा त्याहून अधिक संख्या प्रविष्ट करा';

  @override
  String get tooLarge => 'हे खूप मोठे आहे';

  @override
  String get saveChanges => 'बदल जतन करा';

  @override
  String get saveToLibrary => 'ग्रंथालयात जतन करा';

  @override
  String get resetToDefaultButton => 'मूळ स्थितीत रीसेट करा';

  @override
  String get resetToDefaultTitle => 'मूळ स्थितीत रीसेट करायचे?';

  @override
  String resetToDefaultBody(String title) {
    return '“$title” मधील तुमचे बदल टाकून दिले जातील आणि मूळ मजकूर पुनर्संचयित केला जाईल.';
  }

  @override
  String switchToMantra(String title) {
    return '$title वर स्विच करायचे?';
  }

  @override
  String get switchMantraBody => 'तुमची सध्याची मोजणी रीसेट होईल.';

  @override
  String get keepCurrent => 'सध्याचे ठेवा';

  @override
  String get switchAction => 'स्विच करा';

  @override
  String get smallerMantraText => 'मंत्र मजकूर लहान करा';

  @override
  String get largerMantraText => 'मंत्र मजकूर मोठा करा';

  @override
  String get libraryButton => 'ग्रंथालय';

  @override
  String get trainYourOwnMantra => 'तुमचा स्वतःचा मंत्र प्रशिक्षित करा';

  @override
  String voiceCountingFrom(String title, int count) {
    return 'तुमच्या $count रेकॉर्डिंगवरून “$title” मोजले जात आहे. इतर आवाज आणि शब्द दुर्लक्षित केले जातात.';
  }

  @override
  String voiceCountsOnlyTrained(String title, int min, int max) {
    return 'आवाज फक्त तुम्ही प्रशिक्षित केलेला मंत्र मोजते. सुरू करण्यासाठी “$title” $min ते $max वेळा रेकॉर्ड करा.';
  }

  @override
  String get addMoreSamples => 'आणखी नमुने जोडा';

  @override
  String get retrain => 'पुन्हा प्रशिक्षित करा';

  @override
  String get clearTraining => 'प्रशिक्षण साफ करा';

  @override
  String get voiceBetaNote =>
      'बीटा: हे डिव्हाइसवर आणि ऑफलाइन चालते. अधिक रेकॉर्डिंगने अचूकता वाढते आणि गोंगाटाच्या खोलीत कमी होते. पुनरावृत्तींमध्ये थोडे थांबा. इथे फक्त तुमचा आवाज मोजला जातो; + आणि − बटणे मोजणी दुरुस्त करतात.';

  @override
  String get trainVoiceFirstTitle => 'आधी तुमचा आवाज प्रशिक्षित करा';

  @override
  String trainVoiceFirstBody(String title, int min, int max) {
    return 'आवाज फक्त तुमचा प्रशिक्षित मंत्र मोजते. “$title” $min ते $max वेळा (सुमारे एक मिनिट) रेकॉर्ड करा. हे या डिव्हाइसवरच राहते आणि ऑफलाइन चालते.';
  }

  @override
  String get later => 'नंतर';

  @override
  String get trainNow => 'आता प्रशिक्षित करा';

  @override
  String get betaLabel => 'बीटा';

  @override
  String get voiceTrained => 'आवाज प्रशिक्षित';

  @override
  String get voiceNotTrained => 'आवाज प्रशिक्षित नाही';

  @override
  String get sensitivityLabel => 'संवेदनशीलता';

  @override
  String get sensitivityStrict => 'कडक';

  @override
  String get sensitivityLenient => 'सौम्य';

  @override
  String get sensitivityMedium => 'मध्यम';

  @override
  String get clearVoiceTrainingTitle => 'आवाज प्रशिक्षण साफ करायचे?';

  @override
  String clearVoiceTrainingBody(String title) {
    return 'तुम्ही तो पुन्हा प्रशिक्षित करेपर्यंत आवाज “$title” मोजणे थांबवेल.';
  }

  @override
  String get completionTitle => 'पूर्णता';

  @override
  String get vibrationLabel => 'कंपन';

  @override
  String vibrationSubtitle(int n) {
    return 'प्रत्येक $n मोजणीला एक कंपन, आणि लक्ष्यावर एक जोरदार कंपन.';
  }

  @override
  String intensityLevel(int level) {
    return 'तीव्रता: पातळी $level पैकी 5';
  }

  @override
  String get testMilestone => 'टेस्ट माइलस्टोन';

  @override
  String get testTarget => 'टेस्ट लक्ष्य';

  @override
  String get ringtoneLabel => 'रिंगटोन';

  @override
  String get ringtoneSubtitle => 'लक्ष्य गाठल्यावर एक आवाज वाजतो.';

  @override
  String get playSound => 'आवाज वाजवा';

  @override
  String get combined => 'एकत्रित';

  @override
  String get combinedTooltip => 'सर्व चार मोड एका सामायिक मोजणीत जोडले जातात';

  @override
  String get separate => 'स्वतंत्र';

  @override
  String get separateTooltip => 'प्रत्येक मोड स्वतःची मोजणी ठेवतो';

  @override
  String get countModeSemantic => 'मोजणी मोड';

  @override
  String get combinedExplain =>
      'टॅप, आवाज, ताल आणि माळ सर्व एका लक्ष्याकडे एका सामायिक मोजणीत जोडले जातात.';

  @override
  String get separateExplain =>
      'प्रत्येक मोड स्वतःची मोजणी आणि लक्ष्याकडे स्वतःची प्रगती ठेवतो. रीसेट आणि पूर्णता फक्त तुम्ही ज्या मोडमध्ये आहात त्यालाच लागू होते.';

  @override
  String countedLabel(int count) {
    return '$count मोजले';
  }

  @override
  String ofTarget(int count) {
    return '$count पैकी';
  }

  @override
  String get removeOneTooltip => 'एक काढा';

  @override
  String get undoLabel => 'पूर्ववत करा';

  @override
  String get countLabel => 'मोजणी';

  @override
  String get addOneTooltip => 'एक जोडा';

  @override
  String get focusLabel => 'फोकस';

  @override
  String get focusModeTooltip => 'फोकस मोड';

  @override
  String get pause => 'थांबवा';

  @override
  String get resume => 'पुन्हा सुरू करा';

  @override
  String get start => 'सुरू करा';

  @override
  String targetReachedSeparate(String mode) {
    return '$mode मध्ये लक्ष्य पूर्ण झाले 🙏  हा मोड रीसेट करा, मोड बदला, किंवा लक्ष्य वाढवा.';
  }

  @override
  String get targetReachedCombined =>
      'लक्ष्य पूर्ण झाले 🙏  रीसेट करा, किंवा लक्ष्य वाढवा.';

  @override
  String resetModeCountTitle(String mode) {
    return '$mode मोजणी रीसेट करायची?';
  }

  @override
  String get resetSessionTitle => 'हे सत्र रीसेट करायचे?';

  @override
  String resetModeCountBody(String mode, int count) {
    return 'तुमची $mode मोजणी $count शून्यावर परत येईल. इतर मोड त्यांची मोजणी कायम ठेवतात.';
  }

  @override
  String resetSessionBody(int count) {
    return 'तुमची $count मोजणी शून्यावर परत येईल.';
  }

  @override
  String get modeHelpTap =>
      'रिंगवर टॅप करा, किंवा फोकस मोडमध्ये कुठेही. फक्त टॅप मोड स्क्रीन टॅप मोजतो.';

  @override
  String get modeHelpRhythm => 'Start दाबा आणि मोजणी खालील गतीने आपोआप वाढते.';

  @override
  String get modeHelpVoice =>
      'Start दाबा, मग तुमचा प्रशिक्षित मंत्र जपा. दरवेळी ओळखल्यावर तो लगेच एक मोजणी जोडतो; इतर आवाज दुर्लक्षित केले जातात. मायक्रोफोन आवश्यक; शांत खोलीत उत्तम काम करतो.';

  @override
  String get modeHelpMala =>
      'Start दाबा, मग मोजण्यासाठी कोणतेही व्हॉल्यूम बटण दाबा. डोळे मिटलेले असताना किंवा फोन खिशात असताना सोयीस्कर. स्क्रीन चालू राहिली पाहिजे.';

  @override
  String get countingModeLabel => 'मोजणी मोड';

  @override
  String pacePrefix(String pace) {
    return 'गती: मोजणी $pace';
  }

  @override
  String modeSemanticLabel(String mode) {
    return '$mode मोड';
  }

  @override
  String get tapAnywhereToCount => 'मोजण्यासाठी कुठेही टॅप करा';

  @override
  String countingPace(String pace) {
    return 'मोजणी $pace';
  }

  @override
  String pausedPace(String pace) {
    return 'थांबले · $pace';
  }

  @override
  String get listening => 'ऐकत आहे…';

  @override
  String get startingMicrophone =>
      'मायक्रोफोन सुरू होत आहे… विचारल्यास प्रवेश द्या';

  @override
  String get notTrainedYet =>
      'अजून प्रशिक्षित नाही · आवाज वापरण्यासाठी मंत्र प्रशिक्षित करा';

  @override
  String get pausedPressStartListen => 'थांबले · ऐकण्यासाठी Start दाबा';

  @override
  String get pressVolumeKeys => 'मोजण्यासाठी व्हॉल्यूम की दाबा';

  @override
  String get capturingVolumeKeys => 'व्हॉल्यूम की कॅप्चर करत आहे…';

  @override
  String get pausedPressStartVolume =>
      'थांबले · व्हॉल्यूम की वापरण्यासाठी Start दाबा';

  @override
  String modeTitleLine(String mode, String own) {
    String _temp0 = intl.Intl.selectLogic(own, {
      'yes': ' · स्वतःची मोजणी',
      'other': '',
    });
    return '$mode मोड$_temp0';
  }

  @override
  String voiceCountedMatch(int percent) {
    return 'मोजले · $percent% जुळले';
  }

  @override
  String voiceIgnoredMatch(int percent) {
    return 'दुर्लक्षित · $percent% जुळले (तुमचा मंत्र नाही)';
  }

  @override
  String get paceFieldLabel => 'गती';

  @override
  String paceHelpOk(String pace, String range) {
    return '$pace मोजतो. (परवानगी: $range)';
  }

  @override
  String paceHelpError(String error, String pace) {
    return '$error तरीही $pace मोजत आहे.';
  }

  @override
  String get sankalpLabel => 'संकल्प';

  @override
  String get sankalpHint => 'या सरावासाठी तुमचा संकल्प सांगा…';

  @override
  String get targetSectionTitle => 'लक्ष्य';

  @override
  String get byCount => 'मोजणीनुसार';

  @override
  String get byTime => 'वेळेनुसार';

  @override
  String customWithValue(String value) {
    return 'कस्टम · $value';
  }

  @override
  String get custom => 'कस्टम';

  @override
  String get enterNumberRange => '1 ते 9,999,999 पर्यंतची संख्या प्रविष्ट करा';

  @override
  String get customCountTitle => 'कस्टम मोजणी';

  @override
  String get targetCountLabel => 'लक्ष्य मोजणी';

  @override
  String get setAction => 'सेट करा';

  @override
  String get durationLabel => 'कालावधी';

  @override
  String get enterDuration => '1 किंवा अधिकचा कालावधी प्रविष्ट करा.';

  @override
  String get maxDurationCapped =>
      'कमाल 99 तास 59 मि 59 से आहे — ते मर्यादित केले जाईल.';

  @override
  String sessionLasts(String duration) {
    return 'सत्र $duration पर्यंत चालते.';
  }

  @override
  String get targetReachedFocus => 'लक्ष्य पूर्ण झाले 🙏';

  @override
  String screenTapsDoNotCount(String mode) {
    return '$mode मोडमध्ये स्क्रीन टॅप मोजले जात नाहीत. दुरुस्त करण्यासाठी + किंवा − वापरा.';
  }

  @override
  String holdFingersToExit(int fingers, int seconds) {
    return 'बाहेर पडण्यासाठी $fingers बोटे $seconds सेकंद दाबून ठेवा';
  }

  @override
  String get holdToExitFocusMode => 'फोकस मोडमधून बाहेर पडण्यासाठी दाबून ठेवा';

  @override
  String get holdToExit => 'बाहेर पडण्यासाठी दाबून ठेवा';

  @override
  String get keepHoldingToExit => 'बाहेर पडण्यासाठी दाबून ठेवा…';

  @override
  String addedRecordingsTo(int added, String title, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'रेकॉर्डिंग्ज',
      one: 'रेकॉर्डिंग',
    );
    return '“$title” मध्ये $added $_temp0 जोडल्या (एकूण $total)';
  }

  @override
  String voiceTrainedFor(String title, int count) {
    return '“$title” साठी आवाज प्रशिक्षित ($count रेकॉर्डिंग्ज)';
  }

  @override
  String trainedRecordingsCount(int count) {
    return 'प्रशिक्षित · $count रेकॉर्डिंग्ज';
  }

  @override
  String get tooFewRecordings =>
      'मोजण्यासाठी खूप कमी रेकॉर्डिंग्ज. आणखी जोडा, किंवा पुन्हा प्रशिक्षित करा.';

  @override
  String canCountAddMore(int room) {
    return 'आवाज हा मंत्र मोजू शकते. अचूकता सुधारण्यासाठी पुन्हा सुरुवात न करता $room अधिक रेकॉर्डिंग्ज जोडा.';
  }

  @override
  String canCountAtMax(int max) {
    return 'आवाज हा मंत्र मोजू शकते. तुमच्याकडे कमाल $max रेकॉर्डिंग्ज आहेत; त्या बदलण्यासाठी पुन्हा प्रशिक्षित करा.';
  }

  @override
  String get pausedHeadline => 'थांबले';

  @override
  String pausedSub(int recorded) {
    return '$recorded रेकॉर्ड केल्या. सुरू ठेवा, किंवा जे आहे ते जतन करा.';
  }

  @override
  String recordInstructions(int min, int max, int recommended) {
    return 'तुमच्या नेहमीच्या जप गतीने ते $min ते $max वेळा रेकॉर्ड करा ($recommended ही चांगली संख्या आहे). मग आवाज फक्त तुमचा मंत्र मोजेल.';
  }

  @override
  String get openingMicrophone => 'मायक्रोफोन उघडत आहे…';

  @override
  String get stayQuiet => 'क्षणभर शांत रहा…';

  @override
  String get listeningToRoom =>
      'पार्श्वभूमी आवाज मोजला जाऊ नये म्हणून खोली ऐकली जात आहे.';

  @override
  String get sayYourMantra => 'तुमचा मंत्र म्हणा…';

  @override
  String recordingXofY(int current, int max) {
    return '$current ची रेकॉर्डिंग होत आहे, कमाल $max पैकी';
  }

  @override
  String allRecordingsCaptured(int count) {
    return 'सर्व $count रेकॉर्डिंग्ज कॅप्चर झाल्या';
  }

  @override
  String get saveToStartCounting => 'आवाजने मोजणी सुरू करण्यासाठी ती जतन करा.';

  @override
  String get cannotUseMicrophone => 'मायक्रोफोन वापरता येत नाही';

  @override
  String get canSaveNowHint =>
      'तुम्ही आता जतन करू शकता, किंवा अधिक अचूकतेसाठी सुरू ठेवू शकता.';

  @override
  String minAreEnough(int min) {
    return 'सुरुवात करण्यासाठी $min पुरेसे आहेत.';
  }

  @override
  String addingToSaved(int count) {
    return 'तुमच्या $count जतन केलेल्या रेकॉर्डिंग्जमध्ये जोडत आहे.';
  }

  @override
  String get tryAgain => 'पुन्हा प्रयत्न करा';

  @override
  String get startRecording => 'रेकॉर्डिंग सुरू करा';

  @override
  String get openSettingsAction => 'सेटिंग्ज उघडा';

  @override
  String saveNRecordings(int count) {
    return '$count रेकॉर्डिंग्ज जतन करा';
  }

  @override
  String recordMoreToSave(int n) {
    return 'जतन करण्यासाठी आणखी $n रेकॉर्ड करा';
  }

  @override
  String get recordSampleToSave => 'जतन करण्यासाठी एक नमुना रेकॉर्ड करा';

  @override
  String get undoLast => 'शेवटचे पूर्ववत करा';

  @override
  String get stop => 'थांबवा';

  @override
  String get continueRecording => 'रेकॉर्डिंग सुरू ठेवा';

  @override
  String get startOver => 'पुन्हा सुरुवात करा';

  @override
  String recordedOfMax(int recorded, int max) {
    return '$recorded रेकॉर्ड केल्या, कमाल $max पैकी';
  }

  @override
  String voiceBetaNoteTraining(int max) {
    return 'बीटा. सर्व काही या डिव्हाइसवर, ऑफलाइन घडते: फक्त आवाजाचे वर्णन करणारे आकडे जतन केले जातात, ऑडिओ कधीच नाही. अधिक रेकॉर्डिंग्जमुळे मोजणी अधिक अचूक होते (कमाल $max पर्यंत); गोंगाटाची खोली ती कमी अचूक करते. मंत्र एकदा म्हणा, मग पुढच्या आधी थोडे थांबा.';
  }

  @override
  String get actionClear => 'साफ करा';

  @override
  String get today => 'आज';

  @override
  String get previousMonth => 'मागील महिना';

  @override
  String get nextMonth => 'पुढील महिना';

  @override
  String get markTypeGood => 'चांगला';

  @override
  String get markTypeCautious => 'सावध';

  @override
  String get markTypeNeutral => 'तटस्थ';

  @override
  String get reminderModeNone => 'वेळ नाही';

  @override
  String get reminderModeOnce => 'एकदा';

  @override
  String get reminderModeSeveral => 'अनेक वेळा';

  @override
  String get repeatRuleOnce => 'एकदा';

  @override
  String get repeatRuleDaily => 'दररोज';

  @override
  String get repeatRuleWeekly => 'साप्ताहिक';

  @override
  String get repeatRuleMonthly => 'मासिक';

  @override
  String get repeatRuleQuarterly => 'त्रैमासिक';

  @override
  String get repeatRuleHalfYearly => 'सहामाही';

  @override
  String get repeatRuleYearly => 'वार्षिक';

  @override
  String get homeModeNone => 'दाखवू नका';

  @override
  String get homeModeMorning => 'सकाळी एकदा';

  @override
  String get homeModeAllDay => 'संपूर्ण दिवस ठेवा';

  @override
  String get markStyleDot => 'ठिपका';

  @override
  String get markStyleFilled => 'भरलेला';

  @override
  String get markStyleHighlight => 'हायलाइट';

  @override
  String get markStyleCircle => 'वर्तुळ';

  @override
  String get markStyleSquare => 'चौरस';

  @override
  String get emojiOm => 'ॐ';

  @override
  String get emojiKhanda => 'खंडा';

  @override
  String get emojiMala => 'माळ';

  @override
  String get emojiDiya => 'दिवा';

  @override
  String get emojiBell => 'घंटा';

  @override
  String get emojiSunrise => 'सूर्योदय';

  @override
  String get emojiStar => 'तारा';

  @override
  String get emojiSparkle => 'चमक';

  @override
  String get emojiMoney => 'पैसा';

  @override
  String get emojiHandshake => 'हस्तांदोलन';

  @override
  String get emojiAvoid => 'टाळा';

  @override
  String get emojiDone => 'पूर्ण';

  @override
  String get markTitleGood => 'चांगला दिवस';

  @override
  String get markTitleCautious => 'सावध दिवस';

  @override
  String get markTitleNeutral => 'तटस्थ दिवस';

  @override
  String get reminderBodyGood => 'एक चांगला दिवस.';

  @override
  String get reminderBodyCautious => 'आज सावध रहा.';

  @override
  String get reminderBodyNeutral => 'तुमच्या कॅलेंडरमध्ये चिन्हांकित.';

  @override
  String get channelCalendarRemindersName => 'कॅलेंडर स्मरणपत्रे';

  @override
  String get channelCalendarRemindersDesc =>
      'तुम्ही Sadho मध्ये चिन्हांकित केलेल्या तारखांसाठी स्मरणपत्रे';

  @override
  String get channelAlarmsName => 'अलार्म आणि टायमर';

  @override
  String get channelAlarmsDesc =>
      'सूर्यावर आधारित अलार्म आणि पूर्ण झालेले टायमर';

  @override
  String get repeatSummaryOnce => 'एकदा';

  @override
  String get repeatSummaryDaily => 'दररोज';

  @override
  String get repeatSummaryWeekly => 'दर आठवड्याला';

  @override
  String get repeatSummaryMonthly => 'दर महिन्याला';

  @override
  String get repeatSummaryQuarterly => 'दर 3 महिन्यांनी';

  @override
  String get repeatSummaryHalfYearly => 'दर 6 महिन्यांनी';

  @override
  String get repeatSummaryYearly => 'दर वर्षी';

  @override
  String reminderSummaryAt(String times) {
    return '$times वाजता आठवण करा';
  }

  @override
  String homeSummaryFrom(String time) {
    return 'होमवर $time पासून';
  }

  @override
  String get homeSummaryAllDay => 'होमवर संपूर्ण दिवस';

  @override
  String marksInMonth(String month) {
    return '$month मधील खुणा';
  }

  @override
  String noMarksInMonth(String month) {
    return '$month मध्ये काहीही चिन्हांकित नाही. खूण जोडण्यासाठी तारखेवर टॅप करा.';
  }

  @override
  String get markStyleSectionTitle => 'खूण शैली';

  @override
  String get markStyleSectionHint =>
      'चिन्हांकित तारखा कशा दिसतात. प्रत्येक खुणेला लागू होते.';

  @override
  String markStyleSemantic(String style) {
    return '$style खूण शैली';
  }

  @override
  String get dayCellToday => ', आज';

  @override
  String get dayCellAnd => 'आणि';

  @override
  String dayCellMarkedSuffix(int count, String kinds) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ', $kinds चिन्हांकित, $count खुणा',
      one: ', $kinds चिन्हांकित, 1 खूण',
    );
    return '$_temp0';
  }

  @override
  String get markEditorNoTimeWarning =>
      'किमान एक वेळ जोडा, किंवा \"वेळ नाही\" निवडा.';

  @override
  String get notificationsOffWarning =>
      'Sadho साठी सूचना बंद आहेत, त्यामुळे हे स्मरणपत्र वाजणार नाही. त्या तुमच्या फोनच्या सेटिंग्जमध्ये चालू करा.';

  @override
  String get deleteMarkFallbackTitle => 'ही खूण';

  @override
  String get deleteMarkQuestion => 'ही खूण हटवायची?';

  @override
  String deleteMarkRepeatsBody(String title) {
    return '$title आणि त्याच्या सर्व पुनरावृत्ती हटवायच्या? त्याची स्मरणपत्रेही काढली जातील.';
  }

  @override
  String deleteMarkBody(String title) {
    return '$title हटवायचे? त्याची स्मरणपत्रेही काढली जातील.';
  }

  @override
  String get newMark => 'नवीन खूण';

  @override
  String get editMark => 'खूण संपादित करा';

  @override
  String repeatFromNotice(String repeatSummary, String date) {
    return '$repeatSummary, $date पासून. बदल प्रत्येक पुनरावृत्तीला लागू होतात.';
  }

  @override
  String get markTypeSectionTitle => 'खूण प्रकार';

  @override
  String get iconSectionTitle => 'चिन्ह';

  @override
  String get iconNone => 'काहीही नाही';

  @override
  String get labelFieldLabel => 'लेबल';

  @override
  String get detailsFieldLabel => 'तपशील / नोंदी';

  @override
  String get remindMeAtSectionTitle => 'मला आठवण करा';

  @override
  String removeTimeTooltip(String time) {
    return '$time काढा';
  }

  @override
  String get addTime => 'वेळ जोडा';

  @override
  String get repeatSectionTitle => 'पुनरावृत्ती';

  @override
  String get onHomeScreenSectionTitle => 'तुमच्या होम स्क्रीनवर';

  @override
  String showFromTime(String time) {
    return '$time पासून दाखवा';
  }

  @override
  String get homeModeNoneExplain => 'खूण फक्त कॅलेंडरवर राहते.';

  @override
  String get homeModeMorningExplain =>
      'त्या वेळी होमवर एक कार्ड दिसते. पूर्ण झाल्यावर ते स्वाइप करा: ते पुढच्या पुनरावृत्तीला परत येते.';

  @override
  String get homeModeAllDayExplain =>
      'एक कार्ड होमवर संपूर्ण दिवस पिन राहते (ते स्वाइप करता येत नाही).';

  @override
  String get tomorrow => 'उद्या';

  @override
  String get yesterday => 'काल';

  @override
  String get startAgain => 'पुन्हा सुरू करा';

  @override
  String get settingsAction => 'सेटिंग्ज';

  @override
  String get clockToolClockSubtitle => 'मोठी, थेट वेळ आणि तारीख';

  @override
  String get clockToolSunAlarmTitle => 'सूर्यावर आधारित अलार्म';

  @override
  String get clockToolSunAlarmSubtitle =>
      'सूर्योदय किंवा सूर्यास्ताला, ऑफसेटसह जागे व्हा';

  @override
  String get clockToolWorldClockTitle => 'जागतिक घड्याळ';

  @override
  String get clockToolWorldClockSubtitle => 'अमृतसर, हरिद्वार, लंडन आणि इतर';

  @override
  String get clockToolTimerTitle => 'साधना आणि व्रत टायमर';

  @override
  String get clockToolTimerSubtitle =>
      'आरती, चालीसा, पाठ, हवन, किंवा सूर्यास्तापर्यंत';

  @override
  String get clockToolStopwatchTitle => 'पाठ स्टॉपवॉच';

  @override
  String get clockToolStopwatchSubtitle => 'सुरू करा, थांबवा आणि लॅप करा';

  @override
  String get sunEventSunrise => 'सूर्योदय';

  @override
  String get sunEventSunset => 'सूर्यास्त';

  @override
  String offsetAtEvent(String event) {
    return '$event वेळी';
  }

  @override
  String offsetMinutesOnly(int m) {
    return '$m मिनिटे';
  }

  @override
  String offsetHoursOnly(int h) {
    return '$h तास';
  }

  @override
  String offsetHoursMinutes(int h, int m) {
    return '$h तास $m मिनिटे';
  }

  @override
  String offsetBefore(String amount) {
    return '$amount आधी';
  }

  @override
  String offsetAfter(String amount) {
    return '$amount नंतर';
  }

  @override
  String get locationSourceDevice => 'तुमचे स्थान';

  @override
  String get locationSourceSaved => 'तुमचे शेवटचे ज्ञात स्थान';

  @override
  String get locationSourceFallback => 'अमृतसर (मूळ)';

  @override
  String get locSummaryDevice => 'तुमचे स्थान वापरत आहे';

  @override
  String get locSummarySaved => 'तुमचे शेवटचे ज्ञात स्थान वापरत आहे';

  @override
  String get locSummaryBlocked =>
      'अमृतसर वापरत आहे. सेटिंग्जमध्ये स्थान अवरोधित आहे.';

  @override
  String get locSummaryServiceOff =>
      'अमृतसर वापरत आहे. अचूक वेळेसाठी स्थान चालू करा.';

  @override
  String get locSummaryUnsupported => 'अमृतसर वापरत आहे.';

  @override
  String get locSummaryDefault =>
      'अमृतसर वापरत आहे. अचूक वेळेसाठी स्थानाला परवानगी द्या.';

  @override
  String get presetAarti => 'आरती';

  @override
  String get presetChalisa => 'चालीसा';

  @override
  String get presetPath => 'पाठ';

  @override
  String get presetHavan => 'हवन';

  @override
  String get vratToSunset => 'व्रत → सूर्यास्त';

  @override
  String presetChipLabel(String label, int minutes) {
    return '$label · $minutes मिनिटे';
  }

  @override
  String get clockNoSunsetHere => 'इथे आत्ता मोजण्यासाठी सूर्यास्त नाही.';

  @override
  String get clockSunsetPassedTomorrow =>
      'आजचा सूर्यास्त झाला आहे: उद्यासाठी मोजत आहे.';

  @override
  String timerFinishedTitle(String label) {
    return '🔔 $label पूर्ण झाले';
  }

  @override
  String get sunsetArrived => 'सूर्यास्त झाला 🙏';

  @override
  String timerTimeUp(String label) {
    return 'तुमची $label वेळ संपली आहे 🙏';
  }

  @override
  String sunAlarmNotifTitle(String emoji, String event) {
    return '$emoji $event अलार्म';
  }

  @override
  String sunAlarmNotifBody(String event, String time, String offset) {
    return '$event $time वाजता आहे · $offset';
  }

  @override
  String get statusOn => 'चालू';

  @override
  String get finished => 'पूर्ण झाले';

  @override
  String get left => 'शिल्लक';

  @override
  String get paused => 'थांबले';

  @override
  String get runningStatus => 'सुरू आहे';

  @override
  String get stoppedStatus => 'थांबले';

  @override
  String get lap => 'लॅप';

  @override
  String get lapTime => 'लॅप वेळ';

  @override
  String get total => 'एकूण';

  @override
  String get fastest => 'सर्वात वेगवान';

  @override
  String get slowest => 'सर्वात संथ';

  @override
  String get tapLapToMark => 'लॅप चिन्हांकित करण्यासाठी Lap टॅप करा.';

  @override
  String get startThenTapLap => 'Start करा, मग प्रत्येक फेरीत Lap टॅप करा.';

  @override
  String get allowNotificationsForAlarm =>
      'अलार्म वाजण्यासाठी सेटिंग्जमध्ये सूचना चालू करा.';

  @override
  String get alarmRingsAt => 'अलार्म वाजेल';

  @override
  String get alarmWouldRingAt => 'अलार्म वाजले असते';

  @override
  String noEventToFollow(String event) {
    return 'इथे आत्ता अनुसरण करण्यासाठी $event नाही.';
  }

  @override
  String get alarmOnLabel => 'अलार्म चालू';

  @override
  String get recalculatedDaily =>
      'सूर्याच्या हालचालीनुसार दररोज पुन्हा गणना केली जाते';

  @override
  String todayHereSunriseSunset(String rise, String set) {
    return 'इथे आज: सूर्योदय $rise · सूर्यास्त $set';
  }

  @override
  String get whenLabel => 'केव्हा';

  @override
  String get minutesLabel => 'मिनिटे';

  @override
  String get upTo1440 => '1440 पर्यंत';

  @override
  String get before => 'आधी';

  @override
  String get after => 'नंतर';

  @override
  String get useMyLocation => 'माझे स्थान वापरा';

  @override
  String get couldNotReadPosition => ' · तुमची स्थिती वाचता आली नाही';

  @override
  String get timesUp => 'वेळ संपली 🙏';

  @override
  String sunsetAtTime(String time) {
    return 'सूर्यास्त $time वाजता';
  }

  @override
  String cityInDays(int days) {
    return '$days दिवसांत';
  }

  @override
  String cityDaysAgo(int days) {
    return '$days दिवसांपूर्वी';
  }

  @override
  String get citySameTime => 'तुमच्यासारखीच वेळ';

  @override
  String cityAmountMinutes(int m) {
    return '$m मि';
  }

  @override
  String cityAmountHours(int h) {
    return '$h तास';
  }

  @override
  String cityAmountHoursMinutes(int h, int m) {
    return '$h तास $m मि';
  }

  @override
  String cityAheadOfYou(String amount) {
    return 'तुमच्यापेक्षा $amount पुढे';
  }

  @override
  String cityBehindYou(String amount) {
    return 'तुमच्यापेक्षा $amount मागे';
  }

  @override
  String get traditionHindu => 'हिंदू';

  @override
  String get traditionSikh => 'शीख';

  @override
  String get traditionPlace => 'स्थानानुसार';

  @override
  String get todayLabelTithi => 'तिथी';

  @override
  String get todayLabelNakshatra => 'नक्षत्र';

  @override
  String get todayLabelRahu => 'राहू काळ';

  @override
  String get todayLabelAbhijit => 'अभिजीत मुहूर्त';

  @override
  String get todayLabelHukamnama => 'हुकमनामा';

  @override
  String get todayLabelNitnem => 'नित्नेम बाकी';

  @override
  String get todayLabelGurpurab => 'पुढील गुरुपर्व';

  @override
  String get todayLabelFestival => 'स्थानिक सण';

  @override
  String get todayLabelWindow => 'शुभ वेळ';

  @override
  String get exampleTag => 'उदाहरण';

  @override
  String get exampleNote =>
      'उदाहरण चिन्हांकित मूल्ये प्लेसहोल्डर आहेत: खरा पंचांग डेटा नंतरच्या टप्प्यात येईल.';

  @override
  String liveNote(String where) {
    return 'सूर्योदय आणि सूर्यास्त तुमच्या स्थानासाठी काढले आहेत. $where.';
  }

  @override
  String get greetingMorning => 'सुप्रभात';

  @override
  String get greetingAfternoon => 'शुभ दुपार';

  @override
  String get greetingEvening => 'शुभ संध्याकाळ';

  @override
  String get greetingNight => 'शुभ रात्री';

  @override
  String get homeEmptyTitle => 'आज तुमच्या होम स्क्रीनवर काहीही नाही';

  @override
  String get homeEmptyBody =>
      'कॅलेंडरमध्ये तारीख चिन्हांकित करा आणि ती इथे पाहण्यासाठी \"तुमच्या होम स्क्रीनवर\" निवडा.';

  @override
  String get pinnedAllDay => 'संपूर्ण दिवस पिन केले';

  @override
  String get swipeToDismiss => 'आजसाठी काढण्यासाठी स्वाइप करा';

  @override
  String doneForToday(String title) {
    return 'आजसाठी पूर्ण झाले: $title';
  }

  @override
  String get undoAction => 'पूर्ववत करा';

  @override
  String get doneForTodayLabel => 'आजसाठी पूर्ण झाले';

  @override
  String get plansTitle => 'पाठ आणि मंत्र योजना';

  @override
  String get addPlan => 'योजना जोडा';

  @override
  String get dayStreak => 'दिवसांची सलग मालिका';

  @override
  String activePlanCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सक्रिय योजना',
      one: 'सक्रिय योजना',
    );
    return '$_temp0';
  }

  @override
  String get noPlansYet => 'अजून योजना नाही';

  @override
  String get plansEmptyBody =>
      'एका पाठ किंवा मंत्रासाठी अनेक दिवस बांधील रहा आणि प्रत्येक दिवस चिन्हांकित करा. यापैकी एकाने सुरुवात करा, किंवा स्वतःचा तयार करा.';

  @override
  String get planOptionsTooltip => 'योजना पर्याय';

  @override
  String get deletePlanMenuItem => 'योजना हटवा';

  @override
  String get deletePlanQuestion => 'योजना हटवायची?';

  @override
  String deletePlanBody(String title) {
    return '$title आणि तिची प्रगती काढली जाईल.';
  }

  @override
  String titledDaysTag(String title, int days) {
    return '$title · $days दिवस';
  }

  @override
  String completedOfDays(int completed, int total) {
    return 'पूर्ण · $total पैकी $completed दिवस';
  }

  @override
  String ofDays(int completed, int total) {
    return '$total पैकी $completed दिवस';
  }

  @override
  String get doneTodayButton => 'आज पूर्ण झाले';

  @override
  String get markTodayDone => 'आज पूर्ण झाले चिन्हांकित करा';

  @override
  String get newPlanTitle => 'नवीन योजना';

  @override
  String get newPlanSubtitle =>
      'एक पाठ किंवा मंत्र निवडा आणि तुम्ही तो किती दिवस सुरू ठेवाल.';

  @override
  String get paathOrMantraLabel => 'पाठ किंवा मंत्र';

  @override
  String get giveThePlanAName => 'योजनेला नाव द्या';

  @override
  String chooseDaysRange(int min, int max) {
    return '$min ते $max दिवस निवडा';
  }

  @override
  String get forHowManyDays => 'किती दिवसांसाठी?';

  @override
  String get daysFieldLabel => 'दिवस';

  @override
  String get startPlanButton => 'योजना सुरू करा';

  @override
  String get planKindPaath => 'पाठ';

  @override
  String get planKindMantra => 'मंत्र';

  @override
  String get profileTitle => 'प्रोफाइल';

  @override
  String get sadhanaSettingsTitle => 'साधना सेटिंग्ज';

  @override
  String get validEmailError => 'वैध ईमेल पत्ता प्रविष्ट करा';

  @override
  String nameTooLong(int max) {
    return 'हे $max अक्षरांपेक्षा कमी ठेवा';
  }

  @override
  String get enterCurrentPassword => 'तुमचा सध्याचा पासवर्ड प्रविष्ट करा';

  @override
  String passwordTooShort(int min) {
    return 'किमान $min अक्षरे वापरा';
  }

  @override
  String get passwordAlreadyUsed => 'तुम्ही आधी न वापरलेला पासवर्ड निवडा';

  @override
  String get passwordsDontMatch => 'दोन्ही पासवर्ड जुळत नाहीत';

  @override
  String get changePasswordTitle => 'पासवर्ड बदला';

  @override
  String get accountsLaterNote =>
      'खाती नंतरच्या टप्प्यात येतील; तोपर्यंत हे फक्त तुमच्या नोंदी तपासते आणि काहीही बदलत नाही.';

  @override
  String get currentPasswordLabel => 'सध्याचा पासवर्ड';

  @override
  String get newPasswordLabel => 'नवीन पासवर्ड';

  @override
  String get confirmNewPasswordLabel => 'नवीन पासवर्डची पुष्टी करा';

  @override
  String get showPasswords => 'पासवर्ड दाखवा';

  @override
  String get updatePasswordButton => 'पासवर्ड अपडेट करा';

  @override
  String get stepAddName => 'तुमचे नाव जोडा';

  @override
  String get stepAddEmail => 'तुमचा ईमेल जोडा';

  @override
  String get stepPickTradition => 'होमवर तुमची परंपरा निवडा';

  @override
  String get stepTurnOnReminder => 'दैनिक स्मरणपत्र चालू करा';

  @override
  String get stepStartPlan => 'पाठ किंवा मंत्र योजना सुरू करा';

  @override
  String get profileCompletionTitle => 'प्रोफाइल पूर्णता';

  @override
  String get profileCompleteReward =>
      'प्रोफाइल पूर्ण! प्रीमियम लाँच झाल्यावर तुमचे मोफत प्रीमियम बक्षीस वाट पाहत असेल.';

  @override
  String get reachRewardNote =>
      'लाँच झाल्यावर मोफत प्रीमियम मिळवण्यासाठी 100% पर्यंत पोहोचा.';

  @override
  String get aboutTitle => 'विषयी';

  @override
  String get appLabel => 'अ‍ॅप';

  @override
  String get websiteLabel => 'वेबसाइट';

  @override
  String get versionLabel => 'आवृत्ती';

  @override
  String get passwordWillWorkLater =>
      'खाती जोडल्यानंतर पासवर्ड बदलणे कार्य करेल.';

  @override
  String get signedOut => 'साइन आउट झाले';

  @override
  String get notSignedInYet =>
      'तुम्ही अजून साइन इन केलेले नाही: खाती नंतरच्या टप्प्यात येतील. तुमचा डेटा या फोनवरच राहतो.';

  @override
  String get accountTitle => 'खाते';

  @override
  String get signOutButton => 'साइन आउट करा';

  @override
  String get backupSaved => 'बॅकअप जतन केले';

  @override
  String get backupCancelled => 'बॅकअप रद्द केले';

  @override
  String get couldNotSaveBackup =>
      'बॅकअप जतन करता आले नाही. पुन्हा प्रयत्न करा.';

  @override
  String get backupNotSadho => 'ती फाइल Sadho बॅकअप नाही.';

  @override
  String get couldNotReadFile => 'ती फाइल वाचता आली नाही.';

  @override
  String get backupDamaged => 'बॅकअप फाइल खराब आहे.';

  @override
  String get backupTooNew =>
      'हा बॅकअप Sadho च्या नवीन आवृत्तीने तयार केला होता. आधी अ‍ॅप अपडेट करा.';

  @override
  String get backupNoData => 'त्या बॅकअपमध्ये Sadho डेटा नाही.';

  @override
  String get backupTooBig => 'ती फाइल Sadho बॅकअप असण्यासाठी खूप मोठी आहे.';

  @override
  String madeOnSuffix(String date) {
    return ' $date रोजी तयार केले';
  }

  @override
  String restoreBackupBody(String made, int count) {
    return 'एक बॅकअप$made ज्यात $count जतन केलेल्या वस्तू आहेत. हे या फोनवरील गोष्टींची जागा घेईल: खुणा, योजना, मंत्र, आवाज प्रशिक्षण आणि सेटिंग्ज.';
  }

  @override
  String get restoreThisBackup => 'हा बॅकअप पुनर्संचयित करायचा?';

  @override
  String get backupRestoredTitle => 'बॅकअप पुनर्संचयित केले';

  @override
  String get backupRestoredBody =>
      'Sadho तुमच्या पुनर्संचयित डेटासह पुन्हा लोड होईल.';

  @override
  String get backupRestoreTitle => 'बॅकअप आणि पुनर्संचयन';

  @override
  String get backupExplain =>
      'तुमच्या खुणा, योजना, मंत्र, आवाज प्रशिक्षण आणि सेटिंग्ज तुमच्या आवडीच्या फाइलमध्ये जतन करा (Drive, Files, स्वतःला ईमेल करा). ती या किंवा दुसऱ्या फोनवर पुनर्संचयित करा.';

  @override
  String get exportButton => 'एक्सपोर्ट';

  @override
  String get restoreButton => 'पुनर्संचयित करा';

  @override
  String get cloudSyncTitle => 'क्लाउड सिंक';

  @override
  String get comingLater => 'नंतर येईल';

  @override
  String get saveBackupDialogTitle => 'तुमचा Sadho बॅकअप जतन करा';

  @override
  String get chooseBackupDialogTitle => 'एक Sadho बॅकअप निवडा';

  @override
  String get areYouSure => 'तुम्हाला खात्री आहे का?';

  @override
  String get deleteAccountWarning =>
      'हे तुमचे खाते आणि या फोनवर जतन केलेले सर्व काही हटवते: तुमची प्रोफाइल, खुणा, योजना, मंत्र, आवाज प्रशिक्षण आणि सेटिंग्ज. हे पूर्ववत करता येत नाही.';

  @override
  String get yesAction => 'होय';

  @override
  String get noAction => 'नाही';

  @override
  String get dangerZoneTitle => 'धोक्याचे क्षेत्र';

  @override
  String get deleteAccountExplain =>
      'तुमचे खाते हटवल्याने तुमची प्रोफाइल आणि या फोनवर जतन केलेले सर्व काही मिटते. तुम्हाला ते परत हवे असल्यास आधी बॅकअप एक्सपोर्ट करा.';

  @override
  String get deleteAccountButton => 'खाते हटवा';

  @override
  String get profileSaved => 'प्रोफाइल जतन केली';

  @override
  String get yourDetailsTitle => 'तुमचे तपशील';

  @override
  String get nameLabel => 'नाव';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get dailyReminderTitle => 'दैनिक स्मरणपत्र';

  @override
  String get dailySadhanaReminder => 'दैनिक साधना स्मरणपत्र';

  @override
  String get reminderOff => 'बंद';

  @override
  String everyDayAt(String time) {
    return 'दररोज $time वाजता';
  }

  @override
  String get allowNotificationsForReminder =>
      'स्मरणपत्र वाजण्यासाठी सेटिंग्जमध्ये सूचना चालू करा.';

  @override
  String get timeLabel => 'वेळ';

  @override
  String get themeTitle => 'थीम';

  @override
  String get lightMode => 'लाइट';

  @override
  String get darkMode => 'डार्क';

  @override
  String get systemMode => 'सिस्टम';

  @override
  String get coloursTitle => 'रंग';

  @override
  String paletteSemantic(String name) {
    return '$name रंग';
  }

  @override
  String get paletteMarigoldName => 'गेंदा';

  @override
  String get paletteMarigoldBlurb => 'उबदार केशरी आणि गडद नील';

  @override
  String get paletteSandalwoodName => 'चंदन';

  @override
  String get paletteSandalwoodBlurb => 'मऊ चंदन तपकिरी आणि माती';

  @override
  String get paletteTulsiName => 'तुळस हिरवा';

  @override
  String get paletteTulsiBlurb => 'शांत पवित्र-तुळस हिरवा';

  @override
  String get paletteTwilightName => 'संधिप्रकाश नील';

  @override
  String get paletteTwilightBlurb => 'दिवा-चमक सोनेरीसह संधिप्रकाश नील';

  @override
  String get paletteLotusName => 'कमळ गुलाबी';

  @override
  String get paletteLotusBlurb => 'सौम्य कमळ गुलाबी आणि पान हिरवा';

  @override
  String get sadhanaTimeNotifTitle => '🪔 तुमच्या साधनेची वेळ';

  @override
  String get sadhanaTimeNotifBody =>
      'तुमच्या पाठासाठी किंवा मंत्रासाठी काही शांत मिनिटे काढा 🙏';

  @override
  String get comingSoon => 'लवकरच येत आहे';

  @override
  String get trainAction => 'प्रशिक्षित करा';

  @override
  String get onboardingTitle => 'Sadho मध्ये आपले स्वागत आहे';

  @override
  String get onboardingSubtitle =>
      'सुरुवात करण्यासाठी तुमची भाषा आणि परंपरा निवडा. तुम्ही दोन्ही नंतर प्रोफाइलमध्ये बदलू शकता.';

  @override
  String get traditionHeading => 'परंपरा';

  @override
  String get continueAction => 'सुरू ठेवा';

  @override
  String get stopAlert => 'थांबवा';

  @override
  String get repeatLabel => 'पुनरावृत्ती';

  @override
  String get repeatOnce => 'एकदा';

  @override
  String soundRepeatTimes(int times) {
    return '$times वेळा';
  }

  @override
  String get repeatUntilStopped => 'थांबवेपर्यंत';

  @override
  String vibrationRepeatUntilStopped(int seconds) {
    return 'दर $seconds सेकंदांनी, थांबवेपर्यंत';
  }

  @override
  String get keepScreenOnLabel => 'मोजणी करताना स्क्रीन चालू ठेवा';

  @override
  String get keepScreenOnSubtitle =>
      'सत्र चालू असताना स्क्रीन बंद होत नाही. पॉवर बटणाने फोन तरीही लॉक होतो; तेव्हा वेळ किंवा लय असलेले सत्र पूर्ण झाल्यावर अलार्मसारखे वाजते.';

  @override
  String get alarmMayBeLate =>
      'अलार्म थोडा उशिरा वाजू शकतो (अचूक अलार्म बंद आहेत).';

  @override
  String get exactAlarmNotice =>
      'स्क्रीन बंद असतानाही वेळेवर वाजण्यासाठी, Sadho ला अचूक अलार्मची परवानगी द्या.';

  @override
  String get fullScreenNotice =>
      'पूर्ण झालेले सत्र लॉक स्क्रीनवर दाखवण्यासाठी, फुल-स्क्रीन सूचनांची परवानगी द्या.';

  @override
  String get allowAction => 'परवानगी द्या';

  @override
  String channelSadhanaAlarmName(String sound) {
    return 'साधना अलार्म · $sound';
  }

  @override
  String get channelSadhanaAlarmSilentName => 'साधना अलार्म · शांत';

  @override
  String get channelNoVibration => 'कंपन नाही';

  @override
  String get channelSadhanaAlarmDesc =>
      'वेळ किंवा लय असलेले सत्र पूर्ण झाल्यावर वाजते';

  @override
  String get alarmScreenSadhanaTitle => 'साधना पूर्ण 🙏';

  @override
  String get alarmScreenTimerTitle => 'टायमर संपला';

  @override
  String get alarmScreenSunTitle => 'सूर्य अलार्म';

  @override
  String get alarmScreenUnlock => 'Sadho उघडण्यासाठी अनलॉक करा';

  @override
  String get alarmScreenUnlockHint =>
      'अ‍ॅपच्या उर्वरित भागासाठी फोन अनलॉक असावा लागतो.';

  @override
  String get alarmsReliabilityTitle => 'अलार्म आणि विश्वसनीयता';

  @override
  String get alarmsReliabilityIntro =>
      'स्क्रीन बंद असतानाही अलार्म वेळेवर वाजण्यासाठी फोनने या परवानग्या द्याव्या लागतील. दुरुस्त करा योग्य सेटिंग पान उघडते.';

  @override
  String get alarmsReliabilityAllOk =>
      'अलार्म वेळेवर वाजण्यासाठी सर्व तयार आहे';

  @override
  String get alarmsReliabilityAttention => 'काहीतरी लक्ष देण्याजोगे आहे';

  @override
  String get healthOk => 'ठीक';

  @override
  String get healthNeedsAttention => 'लक्ष द्या';

  @override
  String get healthFix => 'दुरुस्त करा';

  @override
  String get healthNotificationsTitle => 'सूचनांना परवानगी';

  @override
  String get healthNotificationsBody =>
      'अलार्म आणि स्मरणपत्रे सूचना म्हणून येतात.';

  @override
  String get healthExactTitle => 'अचूक अलार्मना परवानगी';

  @override
  String get healthExactBody => 'अगदी त्याच सेकंदाला वाजतो, उशिरा नाही.';

  @override
  String get healthFullScreenTitle => 'लॉक स्क्रीनवर अलार्म दाखवा';

  @override
  String get healthFullScreenBody =>
      'फोन लॉक असतानाही पूर्ण झालेला अलार्म दिसतो.';

  @override
  String get healthBatteryTitle => 'बॅटरी: अ‍ॅप प्रतिबंधित नाही';

  @override
  String get healthBatteryBody =>
      'बॅटरीमध्ये अप्रतिबंधित निवडा (किमान प्रतिबंधित नको), म्हणजे फोन अलार्म रोखणार नाही.';

  @override
  String get healthBatterySamsungHint =>
      'Samsung: सेटिंग्ज › बॅटरी › बॅकग्राउंड वापर मर्यादा मध्ये, Sadho ला “स्लीपिंग अ‍ॅप्स” आणि “डीप स्लीपिंग अ‍ॅप्स” मधून काढा, आणि बॅटरी वापर “अप्रतिबंधित” करा.';

  @override
  String get alarmExplainerOk =>
      'हे सत्र पूर्ण झाल्यावर अलार्मसारखे वाजेल, स्क्रीन किंवा अ‍ॅप बंद असले तरी.';

  @override
  String get alarmExplainerAttention =>
      'हे सत्र पूर्ण झाल्यावर अलार्मसारखे वाजेल, पण वेळेवर वाजण्यासाठी फोनचे एक सेटिंग बदलावे लागेल.';

  @override
  String get alarmExplainerCheck => 'तपासा';

  @override
  String get customTimerName => 'कस्टम टायमर';

  @override
  String customChipLabel(String duration) {
    return 'कस्टम · $duration';
  }

  @override
  String get customTimerTitle => 'स्वतःचा कालावधी';

  @override
  String get customTimerRange => '1 सेकंद ते 24 तास यामध्ये निवडा.';

  @override
  String durationHours(int hours) {
    return '$hours तास';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes मि';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds से';
  }

  @override
  String collapseSection(String section) {
    return '$section लपवा';
  }

  @override
  String expandSection(String section) {
    return '$section दाखवा';
  }

  @override
  String get summaryVibrationOn => 'कंपन सुरू';

  @override
  String get summaryVibrationOff => 'कंपन बंद';

  @override
  String get summarySoundOff => 'आवाज बंद';

  @override
  String get summaryNotSet => 'ठरवलेले नाही';

  @override
  String get clockToolNotepadTitle => 'नोटपॅड';

  @override
  String get clockToolNotepadSubtitle => 'नोंदी, याच फोनवर जतन';

  @override
  String get notesSearchHint => 'नोंदी शोधा';

  @override
  String get notesEmpty => 'अजून कोणतीही नोंद नाही. लिहिण्यासाठी + दाबा.';

  @override
  String notesNoMatch(String query) {
    return '“$query” शी जुळणारी नोंद नाही.';
  }

  @override
  String get noteNew => 'नवीन नोंद';

  @override
  String get noteEdit => 'नोंद';

  @override
  String get noteTitleHint => 'शीर्षक (ऐच्छिक)';

  @override
  String get noteTextHint => 'इथे लिहा…';

  @override
  String get noteUntitled => 'रिकामी नोंद';

  @override
  String noteCreatedAt(String when) {
    return 'तयार $when';
  }

  @override
  String noteEditedAt(String when) {
    return 'बदल $when';
  }

  @override
  String get noteSavedAsYouType => 'लिहिताना जतन होते';

  @override
  String get noteDelete => 'नोंद हटवा';

  @override
  String get noteDeleteQuestion => 'ही नोंद हटवायची?';

  @override
  String noteDeleteBody(String title) {
    return '“$title” या फोनवरून काढली जाईल. हे परत करता येणार नाही.';
  }

  @override
  String get paletteHighContrastName => 'उच्च कॉन्ट्रास्ट';

  @override
  String get paletteHighContrastBlurb => 'सर्वाधिक ठळक फरक, सहज वाचनासाठी';

  @override
  String get malaNotificationChannel => 'माळ काउंटर';

  @override
  String malaNotificationTitle(String count, String target) {
    return 'माळ · $count / $target';
  }

  @override
  String malaNotificationTitleCount(String count) {
    return 'माळ · $count';
  }

  @override
  String get malaNotificationRunning =>
      'मोजण्यासाठी व्हॉल्यूम की दाबा, स्क्रीन बंद असतानाही.';

  @override
  String get malaNotificationDone => 'लक्ष्य पूर्ण 🙏';

  @override
  String get malaRingTitle => '🔔 माळ पूर्ण';

  @override
  String malaRingBody(int target) {
    return 'तुम्ही $target चे लक्ष्य पूर्ण केले 🙏';
  }

  @override
  String get malaScreenOffUnavailable =>
      'या फोनवर स्क्रीन बंद असताना मोजणी सुरू होऊ शकली नाही. Sadho उघडे असतानाच व्हॉल्यूम की मोजतील.';

  @override
  String get pressVolumeKeysScreenOff =>
      'व्हॉल्यूम की मोजतात, स्क्रीन बंद असतानाही';

  @override
  String get malaScreenOffLabel => 'स्क्रीन बंद असतानाही मोजा';

  @override
  String get malaScreenOffOnSubtitle =>
      'फोन लॉक करा आणि व्हॉल्यूम की दाबत राहा. एक सूचना मोजणी दाखवते आणि लक्ष्यावर वाजते.';

  @override
  String get malaScreenOffOffSubtitle =>
      'बंद: Sadho उघडे असताना आणि स्क्रीन चालू असतानाच व्हॉल्यूम की मोजतात.';

  @override
  String get modeHelpMalaScreenOff =>
      'Start दाबा, मग मोजण्यासाठी कोणतीही व्हॉल्यूम की दाबा, फोन लॉक आणि स्क्रीन बंद असतानाही. डोळे मिटून किंवा फोन खिशात असताना उपयुक्त.';

  @override
  String get malaScreenOffExplainer =>
      'फोन लॉक करा, मोजण्यासाठी व्हॉल्यूम की दाबा. बॅटरी \'अप्रतिबंधित\' करा.';

  @override
  String get calibrateTitle => 'आवाज कॅलिब्रेट करा';

  @override
  String calibrateIntro(int count) {
    return 'तुमचा मंत्र $count वेळा जपा, नेहमीप्रमाणे, प्रत्येक वेळी थोडे थांबून. मग Sadho आवाज किती काटेकोर असावा ते ठरवते, जेणेकरून सर्व मोजले जातील आणि खोलीतील आवाज नाही. काहीही रेकॉर्ड किंवा ठेवले जात नाही.';
  }

  @override
  String calibrateChantNow(int count) {
    return 'आता तुमचा मंत्र $count वेळा जपा';
  }

  @override
  String calibrateHeard(int heard, int count) {
    return '$count पैकी $heard ऐकले';
  }

  @override
  String calibrateSkipped(int count) {
    return 'एक जप नसलेले $count आवाज वगळले';
  }

  @override
  String get calibrateDone => 'कॅलिब्रेट झाले';

  @override
  String calibrateDoneBody(int count) {
    return 'सर्व $count जप मोजले जातील; खोलीतील आवाज नाही.';
  }

  @override
  String get calibrateStart => 'कॅलिब्रेशन सुरू करा';

  @override
  String get calibrateSave => 'कॅलिब्रेशन जतन करा';

  @override
  String calibrationSaved(String mantra) {
    return '“$mantra” साठी कॅलिब्रेशन जतन झाले';
  }

  @override
  String get calibrateVoice => 'कॅलिब्रेट करा';

  @override
  String get recalibrateVoice => 'पुन्हा कॅलिब्रेट करा';

  @override
  String get quietModeLabel => 'सत्रादरम्यान इतर सूचना शांत करा';

  @override
  String get quietModeSubtitle =>
      'सत्र सुरू असताना \'व्यत्यय आणू नका\' (फक्त अलार्म) सुरू करते, जेणेकरून Sadho चा अलार्म तरीही वाजेल. नंतर तुमची स्वतःची सेटिंग परत येते.';

  @override
  String get quietModeAccessTitle => '\'व्यत्यय आणू नका\' प्रवेश द्या';

  @override
  String get quietModeAccessBody =>
      'साधनेदरम्यान इतर सूचना शांत करण्यासाठी Sadho ला \'व्यत्यय आणू नका\' प्रवेश हवा. पुढील स्क्रीनवर Sadho शोधा आणि परवानगी द्या. Sadho फक्त सत्र सुरू असताना \'फक्त अलार्म\' मोड सुरू करते आणि नंतर तुमची सेटिंग परत करते.';

  @override
  String get healthDndTitle => '\'व्यत्यय आणू नका\' प्रवेश';

  @override
  String get healthDndBody =>
      'सत्रादरम्यान इतर सूचना शांत करण्यासाठी आवश्यक. याशिवाय Sadho \'व्यत्यय आणू नका\' ला हात लावत नाही.';

  @override
  String get legalPrivacyPolicy => 'गोपनीयता धोरण';

  @override
  String get legalTermsOfUse => 'वापराच्या अटी';

  @override
  String get legalContact => 'संपर्क आणि तक्रार';

  @override
  String get legalDeleteData => 'तुमचा डेटा हटवा';

  @override
  String get legalLicenses => 'ओपन-सोर्स परवाने';

  @override
  String linkOpenFailed(String url) {
    return '$url उघडता आले नाही';
  }

  @override
  String onboardingLegalNotice(String terms, String privacy) {
    return 'तुमची साधना, कॅलेंडर, आवाज प्रशिक्षण आणि स्थान याच फोनवर राहतात. पुढे जाऊन तुम्ही $terms मान्य करता आणि $privacy वाचले आहे.';
  }

  @override
  String get channelSadhanaAlarmV2Name => 'साधना अलार्म';

  @override
  String get healthChannelTitle => 'अलार्म सूचना: \'अलर्ट\' वर ठेवा';

  @override
  String get healthChannelBody =>
      '“साधना अलार्म” आणि “अलार्म आणि टायमर” सूचना स्क्रीनवर दिसल्या पाहिजेत, नाहीतर अलार्म स्क्रीन लॉक स्क्रीनवर दिसू शकत नाही.';

  @override
  String get healthFixManualTitle => 'सेटिंग्ज स्वतः उघडा';

  @override
  String get healthFixManualBody =>
      'फोनने हे पान उघडले नाही. Samsung फोनवर:\n1. सेटिंग्ज › ॲप्स › Sadho उघडा.\n2. सूचना: परवानगी द्या, आणि “साधना अलार्म” व “अलार्म आणि टायमर” \'अलर्ट\' वर ठेवा.\n3. अलार्म आणि रिमाइंडर: परवानगी द्या.\n4. बॅटरी: अप्रतिबंधित.\n5. फुल-स्क्रीन सूचना: सेटिंग्ज › ॲप्स › ⋮ › विशेष प्रवेश › Sadho ला परवानगी द्या.\n6. \'व्यत्यय आणू नका\' प्रवेश: सेटिंग्ज › सूचना › व्यत्यय आणू नका › ॲप प्रवेश (फक्त शांत मोडसाठी).';

  @override
  String get quietModeFailed =>
      'शांत मोड \'व्यत्यय आणू नका\' सुरू करू शकला नाही';

  @override
  String get quietModeChip => 'शांत मोड सुरू';
}
