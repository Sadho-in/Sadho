// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get navHome => 'होम';

  @override
  String get navSadhana => 'साधना';

  @override
  String get navCalendar => 'कैलेंडर';

  @override
  String get navClock => 'घड़ी';

  @override
  String get tooltipLanguage => 'भाषा';

  @override
  String get tooltipProfile => 'प्रोफ़ाइल';

  @override
  String get tooltipSwitchToLight => 'लाइट थीम पर जाएं';

  @override
  String get tooltipSwitchToDark => 'डार्क थीम पर जाएं';

  @override
  String get languageSheetTitle => 'भाषा';

  @override
  String get languageSheetSubtitle =>
      'आपकी पसंद सहेज ली जाती है और तुरंत लागू होती है।';

  @override
  String get actionCancel => 'रद्द करें';

  @override
  String get actionDelete => 'हटाएं';

  @override
  String get actionSave => 'सहेजें';

  @override
  String get actionReset => 'रीसेट करें';

  @override
  String get actionEdit => 'संपादित करें';

  @override
  String get actionOk => 'ठीक है';

  @override
  String get unitSeconds => 'सेकंड';

  @override
  String get unitMinutes => 'मिनट';

  @override
  String get unitHours => 'घंटे';

  @override
  String get paceErrorEmpty => 'गति दर्ज करें।';

  @override
  String get paceErrorNotNumber => 'यह एक संख्या नहीं है।';

  @override
  String paceErrorTooFast(String min) {
    return 'बहुत तेज़। न्यूनतम $min है।';
  }

  @override
  String paceErrorTooSlow(String max) {
    return 'बहुत धीमा। अधिकतम $max है।';
  }

  @override
  String get modeTap => 'टैप';

  @override
  String get modeRhythm => 'रिदम';

  @override
  String get modeVoice => 'आवाज़';

  @override
  String get modeMala => 'माला';

  @override
  String get ringtoneTempleBell => 'मंदिर की घंटी';

  @override
  String get ringtoneSingingBowl => 'सिंगिंग बाउल';

  @override
  String get ringtoneSoftChime => 'हल्की घंटी';

  @override
  String get ringtoneDeepGong => 'गहरा गोंग';

  @override
  String get msgVoiceUnsupported =>
      'आवाज़ गिनती केवल Android और iOS पर काम करती है';

  @override
  String get msgVoiceNoMic => 'इस डिवाइस पर कोई माइक्रोफ़ोन उपलब्ध नहीं है';

  @override
  String get msgMalaUnsupported =>
      'वॉल्यूम-की गिनती के लिए एक वास्तविक डिवाइस चाहिए';

  @override
  String trainFirstPrompt(int min, int max) {
    return 'पहले इस मंत्र के लिए अपनी आवाज़ को प्रशिक्षित करें: इसे $min से $max बार रिकॉर्ड करें।';
  }

  @override
  String get fallbackVoiceDenied =>
      'माइक्रोफ़ोन अनुमति अस्वीकार कर दी गई, इसलिए आवाज़ गिनती सुन नहीं सकती। टैप मोड का उपयोग कर रहे हैं।';

  @override
  String get fallbackVoiceBlocked =>
      'माइक्रोफ़ोन एक्सेस अवरुद्ध है। आवाज़ गिनती उपयोग करने के लिए सेटिंग्स में इसे अनुमति दें। टैप मोड का उपयोग कर रहे हैं।';

  @override
  String get fallbackVoiceUnsupported =>
      'आवाज़ गिनती केवल Android और iOS पर काम करती है। टैप मोड का उपयोग कर रहे हैं।';

  @override
  String get fallbackVoiceNoMic =>
      'इस डिवाइस पर कोई माइक्रोफ़ोन उपलब्ध नहीं है। टैप मोड का उपयोग कर रहे हैं।';

  @override
  String get fallbackMalaUnsupported =>
      'वॉल्यूम-की गिनती के लिए एक वास्तविक डिवाइस चाहिए। टैप मोड का उपयोग कर रहे हैं।';

  @override
  String get sadhanaRingTitle => '🔔 साधना का समय पूरा हुआ';

  @override
  String get sadhanaRingBody => 'आपके सत्र का समय पूरा हो गया है 🙏';

  @override
  String get voiceTooShort => 'यह बहुत छोटा था। पूरा मंत्र बोलें।';

  @override
  String get voiceRanTooLong =>
      'यह बहुत लंबा चला। मंत्र एक बार बोलें, फिर रुकें।';

  @override
  String get voiceSoundedDifferent =>
      'यह दूसरों से अलग सुनाई दिया। इसे उसी तरह फिर से बोलें।';

  @override
  String get voiceGotIt => 'समझ गया। फिर से बोलें।';

  @override
  String get voiceDeniedShort =>
      'माइक्रोफ़ोन अनुमति अस्वीकार कर दी गई, इसलिए आवाज़ गिनती सुन नहीं सकती।';

  @override
  String get voiceBlockedShort =>
      'माइक्रोफ़ोन एक्सेस अवरुद्ध है। आवाज़ गिनती उपयोग करने के लिए सेटिंग्स में इसे अनुमति दें।';

  @override
  String get voiceAccessLost =>
      'माइक्रोफ़ोन एक्सेस खो गया, इसलिए आवाज़ गिनती रुक गई।';

  @override
  String get voiceCouldNotRestart =>
      'माइक्रोफ़ोन फिर से शुरू नहीं हो सका, इसलिए आवाज़ गिनती रुक गई।';

  @override
  String get mantraLibraryTitle => 'मंत्र लाइब्रेरी';

  @override
  String get addMantra => 'मंत्र जोड़ें';

  @override
  String get searchHint => 'शीर्षक, लिपि या परंपरा खोजें';

  @override
  String noMantrasMatch(String query) {
    return '“$query” से कोई मंत्र मेल नहीं खाता।\nअपना खुद बनाने के लिए “मंत्र जोड़ें” टैप करें।';
  }

  @override
  String mantraAdded(String title) {
    return '“$title” जोड़ा गया';
  }

  @override
  String mantraSaved(String title) {
    return '“$title” सहेजा गया';
  }

  @override
  String mantraRestored(String title) {
    return '“$title” को उसके डिफ़ॉल्ट पर पुनर्स्थापित किया गया';
  }

  @override
  String get deleteMantraTitle => 'मंत्र हटाएं?';

  @override
  String deleteMantraBody(String title) {
    return '“$title” आपकी लाइब्रेरी से हटा दिया जाएगा।';
  }

  @override
  String get retrainVoiceTooltip => 'आवाज़ फिर से प्रशिक्षित करें';

  @override
  String get trainVoice => 'आवाज़ प्रशिक्षित करें';

  @override
  String mantraCountTag(int count) {
    return '$count गिनती';
  }

  @override
  String get editedTag => 'संपादित';

  @override
  String get editMantra => 'मंत्र संपादित करें';

  @override
  String get addAMantra => 'एक मंत्र जोड़ें';

  @override
  String get titleLabel => 'शीर्षक *';

  @override
  String get titleRequired => 'एक शीर्षक दर्ज करें';

  @override
  String get scriptTextLabel => 'लिपि पाठ';

  @override
  String get transliterationLabel => 'लिप्यंतरण';

  @override
  String get traditionLabel => 'परंपरा / भाषा';

  @override
  String get traditionHint => 'उदा. संस्कृत · हिंदू';

  @override
  String get defaultCountLabel => 'डिफ़ॉल्ट गिनती *';

  @override
  String get enterNumberOneOrMore => '1 या उससे अधिक संख्या दर्ज करें';

  @override
  String get tooLarge => 'यह बहुत बड़ा है';

  @override
  String get saveChanges => 'बदलाव सहेजें';

  @override
  String get saveToLibrary => 'लाइब्रेरी में सहेजें';

  @override
  String get resetToDefaultButton => 'डिफ़ॉल्ट पर रीसेट करें';

  @override
  String get resetToDefaultTitle => 'डिफ़ॉल्ट पर रीसेट करें?';

  @override
  String resetToDefaultBody(String title) {
    return '“$title” में आपके बदलाव हटा दिए जाएंगे और मूल पाठ बहाल किया जाएगा।';
  }

  @override
  String switchToMantra(String title) {
    return '$title पर स्विच करें?';
  }

  @override
  String get switchMantraBody => 'आपकी वर्तमान गिनती रीसेट हो जाएगी।';

  @override
  String get keepCurrent => 'मौजूदा रखें';

  @override
  String get switchAction => 'स्विच करें';

  @override
  String get smallerMantraText => 'छोटा मंत्र पाठ';

  @override
  String get largerMantraText => 'बड़ा मंत्र पाठ';

  @override
  String get libraryButton => 'लाइब्रेरी';

  @override
  String get trainYourOwnMantra => 'अपना मंत्र प्रशिक्षित करें';

  @override
  String voiceCountingFrom(String title, int count) {
    return 'आपकी $count रिकॉर्डिंग से “$title” गिना जा रहा है। अन्य आवाज़ें और शब्द अनदेखा किए जाते हैं।';
  }

  @override
  String voiceCountsOnlyTrained(String title, int min, int max) {
    return 'आवाज़ केवल आपके द्वारा प्रशिक्षित मंत्र को गिनती है। शुरू करने के लिए “$title” को $min से $max बार रिकॉर्ड करें।';
  }

  @override
  String get addMoreSamples => 'अधिक नमूने जोड़ें';

  @override
  String get retrain => 'फिर से प्रशिक्षित करें';

  @override
  String get clearTraining => 'प्रशिक्षण साफ़ करें';

  @override
  String get voiceBetaNote =>
      'बीटा: यह डिवाइस पर और ऑफ़लाइन काम करता है। अधिक रिकॉर्डिंग से सटीकता बढ़ती है और शोरगुल वाले कमरे में घटती है। दोहराव के बीच थोड़ा रुकें। केवल आपकी आवाज़ यहां गिनी जाती है; + और − बटन गिनती ठीक करते हैं।';

  @override
  String get trainVoiceFirstTitle => 'पहले अपनी आवाज़ प्रशिक्षित करें';

  @override
  String trainVoiceFirstBody(String title, int min, int max) {
    return 'आवाज़ केवल आपके प्रशिक्षित मंत्र को गिनती है। “$title” को $min से $max बार (लगभग एक मिनट) रिकॉर्ड करें। यह इस डिवाइस पर रहता है और ऑफ़लाइन काम करता है।';
  }

  @override
  String get later => 'बाद में';

  @override
  String get trainNow => 'अभी प्रशिक्षित करें';

  @override
  String get betaLabel => 'बीटा';

  @override
  String get voiceTrained => 'आवाज़ प्रशिक्षित';

  @override
  String get voiceNotTrained => 'आवाज़ प्रशिक्षित नहीं';

  @override
  String get sensitivityLabel => 'संवेदनशीलता';

  @override
  String get sensitivityStrict => 'सख्त';

  @override
  String get sensitivityLenient => 'ढीला';

  @override
  String get sensitivityMedium => 'मध्यम';

  @override
  String get clearVoiceTrainingTitle => 'आवाज़ प्रशिक्षण साफ़ करें?';

  @override
  String clearVoiceTrainingBody(String title) {
    return 'जब तक आप इसे फिर से प्रशिक्षित नहीं करते, आवाज़ “$title” गिनना बंद कर देगी।';
  }

  @override
  String get completionTitle => 'पूर्णता';

  @override
  String get vibrationLabel => 'कंपन';

  @override
  String vibrationSubtitle(int n) {
    return 'हर $n गिनती पर एक बज़, और लक्ष्य पर एक मज़बूत बज़।';
  }

  @override
  String intensityLevel(int level) {
    return 'तीव्रता: स्तर $level में से 5';
  }

  @override
  String get testMilestone => 'टेस्ट माइलस्टोन';

  @override
  String get testTarget => 'टेस्ट लक्ष्य';

  @override
  String get ringtoneLabel => 'रिंगटोन';

  @override
  String get ringtoneSubtitle => 'लक्ष्य तक पहुंचने पर एक ध्वनि बजती है।';

  @override
  String get playSound => 'ध्वनि चलाएं';

  @override
  String get combined => 'संयुक्त';

  @override
  String get combinedTooltip => 'सभी चार मोड एक साझा गिनती में जुड़ते हैं';

  @override
  String get separate => 'अलग';

  @override
  String get separateTooltip => 'प्रत्येक मोड अपनी खुद की गिनती रखता है';

  @override
  String get countModeSemantic => 'गिनती मोड';

  @override
  String get combinedExplain =>
      'टैप, आवाज़, रिदम और माला सभी एक लक्ष्य की ओर एक साझा गिनती में जुड़ते हैं।';

  @override
  String get separateExplain =>
      'प्रत्येक मोड अपनी खुद की गिनती और लक्ष्य की ओर अपनी प्रगति रखता है। रीसेट और पूर्णता केवल उस मोड पर लागू होती है जिसमें आप हैं।';

  @override
  String countedLabel(int count) {
    return '$count गिना गया';
  }

  @override
  String ofTarget(int count) {
    return '$count में से';
  }

  @override
  String get removeOneTooltip => 'एक हटाएं';

  @override
  String get undoLabel => 'पूर्ववत करें';

  @override
  String get countLabel => 'गिनती';

  @override
  String get addOneTooltip => 'एक जोड़ें';

  @override
  String get focusLabel => 'फोकस';

  @override
  String get focusModeTooltip => 'फोकस मोड';

  @override
  String get pause => 'रोकें';

  @override
  String get resume => 'फिर शुरू करें';

  @override
  String get start => 'शुरू करें';

  @override
  String targetReachedSeparate(String mode) {
    return '$mode में लक्ष्य पूरा हुआ 🙏  इस मोड को रीसेट करें, मोड बदलें, या लक्ष्य बढ़ाएं।';
  }

  @override
  String get targetReachedCombined =>
      'लक्ष्य पूरा हुआ 🙏  रीसेट करें, या लक्ष्य बढ़ाएं।';

  @override
  String resetModeCountTitle(String mode) {
    return '$mode गिनती रीसेट करें?';
  }

  @override
  String get resetSessionTitle => 'इस सत्र को रीसेट करें?';

  @override
  String resetModeCountBody(String mode, int count) {
    return 'आपकी $mode गिनती $count शून्य पर वापस आ जाएगी। अन्य मोड अपनी गिनती बनाए रखते हैं।';
  }

  @override
  String resetSessionBody(int count) {
    return 'आपकी $count गिनती शून्य पर वापस आ जाएगी।';
  }

  @override
  String get modeHelpTap =>
      'रिंग पर टैप करें, या फोकस मोड में कहीं भी। केवल टैप मोड स्क्रीन टैप गिनता है।';

  @override
  String get modeHelpRhythm =>
      'Start दबाएं और गिनती नीचे दी गई गति पर अपने आप बढ़ती है।';

  @override
  String get modeHelpVoice =>
      'Start दबाएं, फिर अपना प्रशिक्षित मंत्र जपें। हर बार पहचाने जाने पर यह तुरंत एक गिनती जोड़ता है; अन्य ध्वनियां अनदेखी की जाती हैं। माइक्रोफ़ोन चाहिए; शांत कमरे में सबसे अच्छा काम करता है।';

  @override
  String get modeHelpMala =>
      'Start दबाएं, फिर गिनने के लिए किसी भी वॉल्यूम बटन को दबाएं। आंखें बंद होने पर या फोन जेब में होने पर सुविधाजनक। स्क्रीन चालू रहनी चाहिए।';

  @override
  String get countingModeLabel => 'गिनती मोड';

  @override
  String pacePrefix(String pace) {
    return 'गति: गिनती $pace';
  }

  @override
  String modeSemanticLabel(String mode) {
    return '$mode मोड';
  }

  @override
  String get tapAnywhereToCount => 'गिनने के लिए कहीं भी टैप करें';

  @override
  String countingPace(String pace) {
    return 'गिनती $pace';
  }

  @override
  String pausedPace(String pace) {
    return 'रुका हुआ · $pace';
  }

  @override
  String get listening => 'सुन रहा है…';

  @override
  String get startingMicrophone =>
      'माइक्रोफ़ोन शुरू हो रहा है… पूछे जाने पर एक्सेस दें';

  @override
  String get notTrainedYet =>
      'अभी तक प्रशिक्षित नहीं · आवाज़ उपयोग करने के लिए मंत्र प्रशिक्षित करें';

  @override
  String get pausedPressStartListen => 'रुका हुआ · सुनने के लिए Start दबाएं';

  @override
  String get pressVolumeKeys => 'गिनने के लिए वॉल्यूम कीज़ दबाएं';

  @override
  String get capturingVolumeKeys => 'वॉल्यूम कीज़ कैप्चर कर रहा है…';

  @override
  String get pausedPressStartVolume =>
      'रुका हुआ · वॉल्यूम कीज़ उपयोग करने के लिए Start दबाएं';

  @override
  String modeTitleLine(String mode, String own) {
    String _temp0 = intl.Intl.selectLogic(own, {
      'yes': ' · अपनी गिनती',
      'other': '',
    });
    return '$mode मोड$_temp0';
  }

  @override
  String voiceCountedMatch(int percent) {
    return 'गिना गया · $percent% मेल';
  }

  @override
  String voiceIgnoredMatch(int percent) {
    return 'अनदेखा किया गया · $percent% मेल (आपका मंत्र नहीं)';
  }

  @override
  String get paceFieldLabel => 'गति';

  @override
  String paceHelpOk(String pace, String range) {
    return '$pace गिनता है। (अनुमत: $range)';
  }

  @override
  String paceHelpError(String error, String pace) {
    return '$error अभी भी $pace गिन रहा है।';
  }

  @override
  String get sankalpLabel => 'संकल्प';

  @override
  String get sankalpHint => 'इस अभ्यास के लिए अपना संकल्प बताएं…';

  @override
  String get targetSectionTitle => 'लक्ष्य';

  @override
  String get byCount => 'गिनती के अनुसार';

  @override
  String get byTime => 'समय के अनुसार';

  @override
  String customWithValue(String value) {
    return 'कस्टम · $value';
  }

  @override
  String get custom => 'कस्टम';

  @override
  String get enterNumberRange => '1 से 9,999,999 तक की संख्या दर्ज करें';

  @override
  String get customCountTitle => 'कस्टम गिनती';

  @override
  String get targetCountLabel => 'लक्ष्य गिनती';

  @override
  String get setAction => 'सेट करें';

  @override
  String get durationLabel => 'अवधि';

  @override
  String get enterDuration => '1 या अधिक की अवधि दर्ज करें।';

  @override
  String get maxDurationCapped =>
      'अधिकतम 99 घं 59 मि 59 से है — इसे सीमित किया जाएगा।';

  @override
  String sessionLasts(String duration) {
    return 'सत्र $duration तक चलता है।';
  }

  @override
  String get targetReachedFocus => 'लक्ष्य पूरा हुआ 🙏';

  @override
  String screenTapsDoNotCount(String mode) {
    return '$mode मोड में स्क्रीन टैप नहीं गिने जाते। ठीक करने के लिए + या − का उपयोग करें।';
  }

  @override
  String holdFingersToExit(int fingers, int seconds) {
    return 'बाहर निकलने के लिए $fingers उंगलियां $seconds सेकंड तक दबाए रखें';
  }

  @override
  String get holdToExitFocusMode => 'फोकस मोड से बाहर निकलने के लिए दबाए रखें';

  @override
  String get holdToExit => 'बाहर निकलने के लिए दबाए रखें';

  @override
  String get keepHoldingToExit => 'बाहर निकलने के लिए दबाए रखें…';

  @override
  String addedRecordingsTo(int added, String title, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'रिकॉर्डिंग्स',
      one: 'रिकॉर्डिंग',
    );
    return '“$title” में $added $_temp0 जोड़ी गईं (कुल $total)';
  }

  @override
  String voiceTrainedFor(String title, int count) {
    return '“$title” के लिए आवाज़ प्रशिक्षित ($count रिकॉर्डिंग)';
  }

  @override
  String trainedRecordingsCount(int count) {
    return 'प्रशिक्षित · $count रिकॉर्डिंग्स';
  }

  @override
  String get tooFewRecordings =>
      'गिनने के लिए बहुत कम रिकॉर्डिंग्स। अधिक जोड़ें, या फिर से प्रशिक्षित करें।';

  @override
  String canCountAddMore(int room) {
    return 'आवाज़ इस मंत्र को गिन सकती है। सटीकता सुधारने के लिए शुरुआत किए बिना $room और रिकॉर्डिंग्स जोड़ें।';
  }

  @override
  String canCountAtMax(int max) {
    return 'आवाज़ इस मंत्र को गिन सकती है। आपके पास अधिकतम $max रिकॉर्डिंग्स हैं; उन्हें बदलने के लिए फिर से प्रशिक्षित करें।';
  }

  @override
  String get pausedHeadline => 'रुका हुआ';

  @override
  String pausedSub(int recorded) {
    return '$recorded रिकॉर्ड की गईं। जारी रखें, या जो है उसे सहेजें।';
  }

  @override
  String recordInstructions(int min, int max, int recommended) {
    return 'इसे अपनी सामान्य जप गति पर $min से $max बार रिकॉर्ड करें ($recommended एक अच्छी संख्या है)। फिर आवाज़ केवल आपका मंत्र गिनेगी।';
  }

  @override
  String get openingMicrophone => 'माइक्रोफ़ोन खोला जा रहा है…';

  @override
  String get stayQuiet => 'एक पल के लिए शांत रहें…';

  @override
  String get listeningToRoom =>
      'पृष्ठभूमि शोर न गिना जाए इसलिए कमरे को सुना जा रहा है।';

  @override
  String get sayYourMantra => 'अपना मंत्र बोलें…';

  @override
  String recordingXofY(int current, int max) {
    return '$current की रिकॉर्डिंग हो रही है, अधिकतम $max में से';
  }

  @override
  String allRecordingsCaptured(int count) {
    return 'सभी $count रिकॉर्डिंग्स कैप्चर हो गईं';
  }

  @override
  String get saveToStartCounting =>
      'आवाज़ से गिनती शुरू करने के लिए इन्हें सहेजें।';

  @override
  String get cannotUseMicrophone => 'माइक्रोफ़ोन का उपयोग नहीं किया जा सकता';

  @override
  String get canSaveNowHint =>
      'आप अभी सहेज सकते हैं, या अधिक सटीकता के लिए जारी रख सकते हैं।';

  @override
  String minAreEnough(int min) {
    return 'शुरू करने के लिए $min पर्याप्त हैं।';
  }

  @override
  String addingToSaved(int count) {
    return 'आपकी $count सहेजी गई रिकॉर्डिंग्स में जोड़ा जा रहा है।';
  }

  @override
  String get tryAgain => 'फिर से कोशिश करें';

  @override
  String get startRecording => 'रिकॉर्डिंग शुरू करें';

  @override
  String get openSettingsAction => 'सेटिंग्स खोलें';

  @override
  String saveNRecordings(int count) {
    return '$count रिकॉर्डिंग्स सहेजें';
  }

  @override
  String recordMoreToSave(int n) {
    return 'सहेजने के लिए $n और रिकॉर्ड करें';
  }

  @override
  String get recordSampleToSave => 'सहेजने के लिए एक नमूना रिकॉर्ड करें';

  @override
  String get undoLast => 'आखिरी पूर्ववत करें';

  @override
  String get stop => 'रोकें';

  @override
  String get continueRecording => 'रिकॉर्डिंग जारी रखें';

  @override
  String get startOver => 'फिर से शुरू करें';

  @override
  String recordedOfMax(int recorded, int max) {
    return '$recorded रिकॉर्ड की गईं, अधिकतम $max में से';
  }

  @override
  String voiceBetaNoteTraining(int max) {
    return 'बीटा। सब कुछ इस डिवाइस पर, ऑफ़लाइन होता है: केवल ध्वनि का वर्णन करने वाले नंबर सहेजे जाते हैं, कभी ऑडियो नहीं। अधिक रिकॉर्डिंग्स गिनती को अधिक सटीक बनाती हैं (अधिकतम $max तक); शोरगुल वाला कमरा इसे कम सटीक बनाता है। मंत्र एक बार बोलें, फिर अगली बार से पहले थोड़ा रुकें।';
  }

  @override
  String get actionClear => 'साफ़ करें';

  @override
  String get today => 'आज';

  @override
  String get previousMonth => 'पिछला महीना';

  @override
  String get nextMonth => 'अगला महीना';

  @override
  String get markTypeGood => 'अच्छा';

  @override
  String get markTypeCautious => 'सावधान';

  @override
  String get markTypeNeutral => 'तटस्थ';

  @override
  String get reminderModeNone => 'कोई समय नहीं';

  @override
  String get reminderModeOnce => 'एक बार';

  @override
  String get reminderModeSeveral => 'कई बार';

  @override
  String get repeatRuleOnce => 'एक बार';

  @override
  String get repeatRuleDaily => 'दैनिक';

  @override
  String get repeatRuleWeekly => 'साप्ताहिक';

  @override
  String get repeatRuleMonthly => 'मासिक';

  @override
  String get repeatRuleQuarterly => 'त्रैमासिक';

  @override
  String get repeatRuleHalfYearly => 'अर्ध-वार्षिक';

  @override
  String get repeatRuleYearly => 'वार्षिक';

  @override
  String get homeModeNone => 'मत दिखाओ';

  @override
  String get homeModeMorning => 'सुबह एक बार';

  @override
  String get homeModeAllDay => 'पूरा दिन रखें';

  @override
  String get markStyleDot => 'बिंदु';

  @override
  String get markStyleFilled => 'भरा हुआ';

  @override
  String get markStyleHighlight => 'हाइलाइट';

  @override
  String get markStyleCircle => 'वृत्त';

  @override
  String get markStyleSquare => 'वर्ग';

  @override
  String get emojiOm => 'ॐ';

  @override
  String get emojiKhanda => 'खंडा';

  @override
  String get emojiMala => 'माला';

  @override
  String get emojiDiya => 'दीया';

  @override
  String get emojiBell => 'घंटी';

  @override
  String get emojiSunrise => 'सूर्योदय';

  @override
  String get emojiStar => 'तारा';

  @override
  String get emojiSparkle => 'चमक';

  @override
  String get emojiMoney => 'पैसा';

  @override
  String get emojiHandshake => 'हाथ मिलाना';

  @override
  String get emojiAvoid => 'बचें';

  @override
  String get emojiDone => 'पूर्ण';

  @override
  String get markTitleGood => 'अच्छा दिन';

  @override
  String get markTitleCautious => 'सावधान दिन';

  @override
  String get markTitleNeutral => 'तटस्थ दिन';

  @override
  String get reminderBodyGood => 'एक अच्छा दिन।';

  @override
  String get reminderBodyCautious => 'आज सावधान रहें।';

  @override
  String get reminderBodyNeutral => 'आपके कैलेंडर में चिह्नित।';

  @override
  String get channelCalendarRemindersName => 'कैलेंडर रिमाइंडर';

  @override
  String get channelCalendarRemindersDesc =>
      'आपके द्वारा Sadho में चिह्नित तिथियों के लिए रिमाइंडर';

  @override
  String get channelAlarmsName => 'अलार्म और टाइमर';

  @override
  String get channelAlarmsDesc => 'सूर्य-आधारित अलार्म और पूर्ण टाइमर';

  @override
  String get repeatSummaryOnce => 'एक बार';

  @override
  String get repeatSummaryDaily => 'हर दिन';

  @override
  String get repeatSummaryWeekly => 'हर हफ्ते';

  @override
  String get repeatSummaryMonthly => 'हर महीने';

  @override
  String get repeatSummaryQuarterly => 'हर 3 महीने';

  @override
  String get repeatSummaryHalfYearly => 'हर 6 महीने';

  @override
  String get repeatSummaryYearly => 'हर साल';

  @override
  String reminderSummaryAt(String times) {
    return '$times पर याद दिलाएं';
  }

  @override
  String homeSummaryFrom(String time) {
    return 'होम पर $time से';
  }

  @override
  String get homeSummaryAllDay => 'होम पर पूरा दिन';

  @override
  String marksInMonth(String month) {
    return '$month में निशान';
  }

  @override
  String noMarksInMonth(String month) {
    return '$month में कुछ भी चिह्नित नहीं। निशान जोड़ने के लिए एक तारीख टैप करें।';
  }

  @override
  String get markStyleSectionTitle => 'निशान शैली';

  @override
  String get markStyleSectionHint =>
      'चिह्नित तारीखें कैसी दिखती हैं। हर निशान पर लागू होता है।';

  @override
  String markStyleSemantic(String style) {
    return '$style निशान शैली';
  }

  @override
  String get dayCellToday => ', आज';

  @override
  String get dayCellAnd => 'और';

  @override
  String dayCellMarkedSuffix(int count, String kinds) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ', $kinds चिह्नित, $count निशान',
      one: ', $kinds चिह्नित, 1 निशान',
    );
    return '$_temp0';
  }

  @override
  String get markEditorNoTimeWarning =>
      'कम से कम एक समय जोड़ें, या \"कोई समय नहीं\" चुनें।';

  @override
  String get notificationsOffWarning =>
      'Sadho के लिए सूचनाएं बंद हैं, इसलिए यह रिमाइंडर नहीं बजेगा। इन्हें अपने फ़ोन की सेटिंग्स में चालू करें।';

  @override
  String get deleteMarkFallbackTitle => 'यह निशान';

  @override
  String get deleteMarkQuestion => 'यह निशान हटाएं?';

  @override
  String deleteMarkRepeatsBody(String title) {
    return '$title और इसकी सभी पुनरावृत्तियां हटाएं? इसके रिमाइंडर भी हटा दिए जाएंगे।';
  }

  @override
  String deleteMarkBody(String title) {
    return '$title हटाएं? इसके रिमाइंडर भी हटा दिए जाएंगे।';
  }

  @override
  String get newMark => 'नया निशान';

  @override
  String get editMark => 'निशान संपादित करें';

  @override
  String repeatFromNotice(String repeatSummary, String date) {
    return '$repeatSummary, $date से। बदलाव हर पुनरावृत्ति पर लागू होते हैं।';
  }

  @override
  String get markTypeSectionTitle => 'निशान प्रकार';

  @override
  String get iconSectionTitle => 'आइकन';

  @override
  String get iconNone => 'कोई नहीं';

  @override
  String get labelFieldLabel => 'लेबल';

  @override
  String get detailsFieldLabel => 'विवरण / नोट्स';

  @override
  String get remindMeAtSectionTitle => 'मुझे याद दिलाएं';

  @override
  String removeTimeTooltip(String time) {
    return '$time हटाएं';
  }

  @override
  String get addTime => 'समय जोड़ें';

  @override
  String get repeatSectionTitle => 'पुनरावृत्ति';

  @override
  String get onHomeScreenSectionTitle => 'आपकी होम स्क्रीन पर';

  @override
  String showFromTime(String time) {
    return '$time से दिखाएं';
  }

  @override
  String get homeModeNoneExplain => 'निशान केवल कैलेंडर पर रहता है।';

  @override
  String get homeModeMorningExplain =>
      'उस समय होम पर एक कार्ड दिखाई देता है। पूरा होने पर उसे स्वाइप करें: यह अगली पुनरावृत्ति पर वापस आता है।';

  @override
  String get homeModeAllDayExplain =>
      'एक कार्ड होम पर पूरे दिन पिन रहता है (इसे स्वाइप नहीं किया जा सकता)।';

  @override
  String get tomorrow => 'कल';

  @override
  String get yesterday => 'बीता कल';

  @override
  String get startAgain => 'फिर से शुरू करें';

  @override
  String get settingsAction => 'सेटिंग्स';

  @override
  String get clockToolClockSubtitle => 'एक बड़ा, लाइव समय और तारीख';

  @override
  String get clockToolSunAlarmTitle => 'सूर्य-आधारित अलार्म';

  @override
  String get clockToolSunAlarmSubtitle =>
      'सूर्योदय या सूर्यास्त पर, ऑफ़सेट के साथ जागें';

  @override
  String get clockToolWorldClockTitle => 'विश्व घड़ी';

  @override
  String get clockToolWorldClockSubtitle => 'अमृतसर, हरिद्वार, लंदन और अधिक';

  @override
  String get clockToolTimerTitle => 'साधना और व्रत टाइमर';

  @override
  String get clockToolTimerSubtitle =>
      'आरती, चालीसा, पाठ, हवन, या सूर्यास्त तक';

  @override
  String get clockToolStopwatchTitle => 'पाठ स्टॉपवॉच';

  @override
  String get clockToolStopwatchSubtitle => 'शुरू करें, रोकें और लैप करें';

  @override
  String get sunEventSunrise => 'सूर्योदय';

  @override
  String get sunEventSunset => 'सूर्यास्त';

  @override
  String offsetAtEvent(String event) {
    return '$event पर';
  }

  @override
  String offsetMinutesOnly(int m) {
    return '$m मिनट';
  }

  @override
  String offsetHoursOnly(int h) {
    return '$h घं';
  }

  @override
  String offsetHoursMinutes(int h, int m) {
    return '$h घं $m मिनट';
  }

  @override
  String offsetBefore(String amount) {
    return '$amount पहले';
  }

  @override
  String offsetAfter(String amount) {
    return '$amount बाद';
  }

  @override
  String get locationSourceDevice => 'आपका स्थान';

  @override
  String get locationSourceSaved => 'आपका आखिरी ज्ञात स्थान';

  @override
  String get locationSourceFallback => 'अमृतसर (डिफ़ॉल्ट)';

  @override
  String get locSummaryDevice => 'आपका स्थान उपयोग हो रहा है';

  @override
  String get locSummarySaved => 'आपका आखिरी ज्ञात स्थान उपयोग हो रहा है';

  @override
  String get locSummaryBlocked =>
      'अमृतसर उपयोग हो रहा है। सेटिंग्स में स्थान अवरुद्ध है।';

  @override
  String get locSummaryServiceOff =>
      'अमृतसर उपयोग हो रहा है। सटीक समय के लिए स्थान चालू करें।';

  @override
  String get locSummaryUnsupported => 'अमृतसर उपयोग हो रहा है।';

  @override
  String get locSummaryDefault =>
      'अमृतसर उपयोग हो रहा है। सटीक समय के लिए स्थान की अनुमति दें।';

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
    return '$label · $minutes मिनट';
  }

  @override
  String get clockNoSunsetHere =>
      'यहां अभी गिनने के लिए कोई सूर्यास्त नहीं है।';

  @override
  String get clockSunsetPassedTomorrow =>
      'आज का सूर्यास्त बीत चुका है: कल के लिए गिना जा रहा है।';

  @override
  String timerFinishedTitle(String label) {
    return '🔔 $label पूरा हुआ';
  }

  @override
  String get sunsetArrived => 'सूर्यास्त हो गया 🙏';

  @override
  String timerTimeUp(String label) {
    return 'आपका $label समय पूरा हो गया है 🙏';
  }

  @override
  String sunAlarmNotifTitle(String emoji, String event) {
    return '$emoji $event अलार्म';
  }

  @override
  String sunAlarmNotifBody(String event, String time, String offset) {
    return '$event $time पर है · $offset';
  }

  @override
  String get statusOn => 'चालू';

  @override
  String get finished => 'पूरा हुआ';

  @override
  String get left => 'बचा';

  @override
  String get paused => 'रुका';

  @override
  String get runningStatus => 'चल रहा है';

  @override
  String get stoppedStatus => 'रुक गया';

  @override
  String get lap => 'लैप';

  @override
  String get lapTime => 'लैप समय';

  @override
  String get total => 'कुल';

  @override
  String get fastest => 'सबसे तेज़';

  @override
  String get slowest => 'सबसे धीमा';

  @override
  String get tapLapToMark => 'लैप चिह्नित करने के लिए Lap टैप करें।';

  @override
  String get startThenTapLap => 'Start करें, फिर हर राउंड पर Lap टैप करें।';

  @override
  String get allowNotificationsForAlarm =>
      'अलार्म बजने के लिए सेटिंग्स में सूचनाएं चालू करें।';

  @override
  String get alarmRingsAt => 'अलार्म बजेगा';

  @override
  String get alarmWouldRingAt => 'अलार्म बजता';

  @override
  String noEventToFollow(String event) {
    return 'यहां अभी अनुसरण करने के लिए कोई $event नहीं है।';
  }

  @override
  String get alarmOnLabel => 'अलार्म चालू';

  @override
  String get recalculatedDaily =>
      'सूरज के चलने के साथ हर दिन फिर से गणना की जाती है';

  @override
  String todayHereSunriseSunset(String rise, String set) {
    return 'यहां आज: सूर्योदय $rise · सूर्यास्त $set';
  }

  @override
  String get whenLabel => 'कब';

  @override
  String get minutesLabel => 'मिनट';

  @override
  String get upTo1440 => '1440 तक';

  @override
  String get before => 'पहले';

  @override
  String get after => 'बाद में';

  @override
  String get useMyLocation => 'मेरा स्थान उपयोग करें';

  @override
  String get couldNotReadPosition => ' · आपकी स्थिति नहीं पढ़ सका';

  @override
  String get timesUp => 'समय पूरा हुआ 🙏';

  @override
  String sunsetAtTime(String time) {
    return 'सूर्यास्त $time पर';
  }

  @override
  String cityInDays(int days) {
    return '$days दिनों में';
  }

  @override
  String cityDaysAgo(int days) {
    return '$days दिन पहले';
  }

  @override
  String get citySameTime => 'आपके समान समय';

  @override
  String cityAmountMinutes(int m) {
    return '$m मि';
  }

  @override
  String cityAmountHours(int h) {
    return '$h घं';
  }

  @override
  String cityAmountHoursMinutes(int h, int m) {
    return '$h घं $m मि';
  }

  @override
  String cityAheadOfYou(String amount) {
    return 'आपसे $amount आगे';
  }

  @override
  String cityBehindYou(String amount) {
    return 'आपसे $amount पीछे';
  }

  @override
  String get traditionHindu => 'हिंदू';

  @override
  String get traditionSikh => 'सिख';

  @override
  String get traditionPlace => 'स्थान के अनुसार';

  @override
  String get todayLabelTithi => 'तिथि';

  @override
  String get todayLabelNakshatra => 'नक्षत्र';

  @override
  String get todayLabelRahu => 'राहु काल';

  @override
  String get todayLabelAbhijit => 'अभिजित मुहूर्त';

  @override
  String get todayLabelHukamnama => 'हुकमनामा';

  @override
  String get todayLabelNitnem => 'नित्नेम बाकी';

  @override
  String get todayLabelGurpurab => 'अगला गुरुपर्व';

  @override
  String get todayLabelFestival => 'स्थानीय त्योहार';

  @override
  String get todayLabelWindow => 'शुभ समय';

  @override
  String get exampleTag => 'उदाहरण';

  @override
  String get exampleNote =>
      'उदाहरण चिह्नित मान प्लेसहोल्डर हैं: वास्तविक पंचांग डेटा बाद के चरण में आएगा।';

  @override
  String liveNote(String where) {
    return 'सूर्योदय और सूर्यास्त आपके स्थान के लिए निकाले गए हैं। $where.';
  }

  @override
  String get greetingMorning => 'सुप्रभात';

  @override
  String get greetingAfternoon => 'शुभ दोपहर';

  @override
  String get greetingEvening => 'शुभ संध्या';

  @override
  String get greetingNight => 'शुभ रात्रि';

  @override
  String get homeEmptyTitle => 'आज आपकी होम स्क्रीन पर कुछ नहीं है';

  @override
  String get homeEmptyBody =>
      'कैलेंडर में एक तारीख चिह्नित करें और इसे यहां देखने के लिए \"आपकी होम स्क्रीन पर\" चुनें।';

  @override
  String get pinnedAllDay => 'पूरे दिन पिन किया गया';

  @override
  String get swipeToDismiss => 'आज के लिए हटाने हेतु स्वाइप करें';

  @override
  String doneForToday(String title) {
    return 'आज के लिए पूरा हुआ: $title';
  }

  @override
  String get undoAction => 'पूर्ववत करें';

  @override
  String get doneForTodayLabel => 'आज के लिए पूरा हुआ';

  @override
  String get plansTitle => 'पाठ और मंत्र योजनाएं';

  @override
  String get addPlan => 'योजना जोड़ें';

  @override
  String get dayStreak => 'दिन की लगातार श्रृंखला';

  @override
  String activePlanCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सक्रिय योजनाएं',
      one: 'सक्रिय योजना',
    );
    return '$_temp0';
  }

  @override
  String get noPlansYet => 'अभी तक कोई योजना नहीं';

  @override
  String get plansEmptyBody =>
      'एक पाठ या मंत्र के लिए कई दिनों तक प्रतिबद्ध रहें और हर दिन चिह्नित करें। इनमें से किसी एक से शुरू करें, या अपना खुद बनाएं।';

  @override
  String get planOptionsTooltip => 'योजना विकल्प';

  @override
  String get deletePlanMenuItem => 'योजना हटाएं';

  @override
  String get deletePlanQuestion => 'योजना हटाएं?';

  @override
  String deletePlanBody(String title) {
    return '$title और इसकी प्रगति हटा दी जाएगी।';
  }

  @override
  String titledDaysTag(String title, int days) {
    return '$title · $days दिन';
  }

  @override
  String completedOfDays(int completed, int total) {
    return 'पूर्ण · $total में से $completed दिन';
  }

  @override
  String ofDays(int completed, int total) {
    return '$total में से $completed दिन';
  }

  @override
  String get doneTodayButton => 'आज पूरा हुआ';

  @override
  String get markTodayDone => 'आज पूरा हुआ चिह्नित करें';

  @override
  String get newPlanTitle => 'नई योजना';

  @override
  String get newPlanSubtitle =>
      'एक पाठ या मंत्र चुनें और आप इसे कितने दिनों तक जारी रखेंगे।';

  @override
  String get paathOrMantraLabel => 'पाठ या मंत्र';

  @override
  String get giveThePlanAName => 'योजना को एक नाम दें';

  @override
  String chooseDaysRange(int min, int max) {
    return '$min से $max दिन चुनें';
  }

  @override
  String get forHowManyDays => 'कितने दिनों के लिए?';

  @override
  String get daysFieldLabel => 'दिन';

  @override
  String get startPlanButton => 'योजना शुरू करें';

  @override
  String get planKindPaath => 'पाठ';

  @override
  String get planKindMantra => 'मंत्र';

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String get sadhanaSettingsTitle => 'साधना सेटिंग्स';

  @override
  String get validEmailError => 'एक मान्य ईमेल पता दर्ज करें';

  @override
  String nameTooLong(int max) {
    return 'इसे $max अक्षरों से कम रखें';
  }

  @override
  String get enterCurrentPassword => 'अपना वर्तमान पासवर्ड दर्ज करें';

  @override
  String passwordTooShort(int min) {
    return 'कम से कम $min अक्षरों का उपयोग करें';
  }

  @override
  String get passwordAlreadyUsed =>
      'ऐसा पासवर्ड चुनें जो आपने पहले उपयोग न किया हो';

  @override
  String get passwordsDontMatch => 'दोनों पासवर्ड मेल नहीं खाते';

  @override
  String get changePasswordTitle => 'पासवर्ड बदलें';

  @override
  String get accountsLaterNote =>
      'खाते बाद के चरण में आएंगे; तब तक यह केवल आपकी प्रविष्टियां जांचता है और कुछ नहीं बदलता।';

  @override
  String get currentPasswordLabel => 'वर्तमान पासवर्ड';

  @override
  String get newPasswordLabel => 'नया पासवर्ड';

  @override
  String get confirmNewPasswordLabel => 'नए पासवर्ड की पुष्टि करें';

  @override
  String get showPasswords => 'पासवर्ड दिखाएं';

  @override
  String get updatePasswordButton => 'पासवर्ड अपडेट करें';

  @override
  String get stepAddName => 'अपना नाम जोड़ें';

  @override
  String get stepAddEmail => 'अपना ईमेल जोड़ें';

  @override
  String get stepPickTradition => 'होम पर अपनी परंपरा चुनें';

  @override
  String get stepTurnOnReminder => 'दैनिक रिमाइंडर चालू करें';

  @override
  String get stepStartPlan => 'एक पाठ या मंत्र योजना शुरू करें';

  @override
  String get profileCompletionTitle => 'प्रोफ़ाइल पूर्णता';

  @override
  String get profileCompleteReward =>
      'प्रोफ़ाइल पूर्ण! प्रीमियम लॉन्च होने पर आपका मुफ़्त प्रीमियम इनाम इंतज़ार कर रहा होगा।';

  @override
  String get reachRewardNote =>
      'लॉन्च होने पर मुफ़्त प्रीमियम पाने के लिए 100% तक पहुंचें।';

  @override
  String get aboutTitle => 'बारे में';

  @override
  String get appLabel => 'ऐप';

  @override
  String get websiteLabel => 'वेबसाइट';

  @override
  String get versionLabel => 'संस्करण';

  @override
  String get passwordWillWorkLater =>
      'खाते जुड़ने के बाद पासवर्ड बदलना काम करेगा।';

  @override
  String get signedOut => 'साइन आउट हो गया';

  @override
  String get notSignedInYet =>
      'आप अभी साइन इन नहीं हैं: खाते बाद के चरण में आएंगे। आपका डेटा इस फ़ोन पर रहता है।';

  @override
  String get accountTitle => 'खाता';

  @override
  String get signOutButton => 'साइन आउट करें';

  @override
  String get backupSaved => 'बैकअप सहेजा गया';

  @override
  String get backupCancelled => 'बैकअप रद्द किया गया';

  @override
  String get couldNotSaveBackup => 'बैकअप सहेज नहीं सका। फिर से कोशिश करें।';

  @override
  String get backupNotSadho => 'वह फ़ाइल Sadho बैकअप नहीं है।';

  @override
  String get couldNotReadFile => 'वह फ़ाइल पढ़ नहीं सका।';

  @override
  String get backupDamaged => 'बैकअप फ़ाइल खराब है।';

  @override
  String get backupTooNew =>
      'यह बैकअप Sadho के नए संस्करण द्वारा बनाया गया था। पहले ऐप अपडेट करें।';

  @override
  String get backupNoData => 'उस बैकअप में कोई Sadho डेटा नहीं है।';

  @override
  String get backupTooBig => 'वह फ़ाइल Sadho बैकअप होने के लिए बहुत बड़ी है।';

  @override
  String madeOnSuffix(String date) {
    return ' $date को बनाया गया';
  }

  @override
  String restoreBackupBody(String made, int count) {
    return 'एक बैकअप$made जिसमें $count सहेजी गई वस्तुएं हैं। यह इस फ़ोन पर मौजूद चीज़ों की जगह लेगा: निशान, योजनाएं, मंत्र, आवाज़ प्रशिक्षण और सेटिंग्स।';
  }

  @override
  String get restoreThisBackup => 'यह बैकअप पुनर्स्थापित करें?';

  @override
  String get backupRestoredTitle => 'बैकअप पुनर्स्थापित किया गया';

  @override
  String get backupRestoredBody =>
      'Sadho आपके पुनर्स्थापित डेटा के साथ फिर से लोड होगा।';

  @override
  String get backupRestoreTitle => 'बैकअप और पुनर्स्थापना';

  @override
  String get backupExplain =>
      'अपने निशान, योजनाएं, मंत्र, आवाज़ प्रशिक्षण और सेटिंग्स को अपनी पसंद की फ़ाइल में सहेजें (Drive, Files, खुद को ईमेल करें)। इसे इस या किसी अन्य फ़ोन पर पुनर्स्थापित करें।';

  @override
  String get exportButton => 'एक्सपोर्ट';

  @override
  String get restoreButton => 'पुनर्स्थापित करें';

  @override
  String get cloudSyncTitle => 'क्लाउड सिंक';

  @override
  String get comingLater => 'बाद में आएगा';

  @override
  String get saveBackupDialogTitle => 'अपना Sadho बैकअप सहेजें';

  @override
  String get chooseBackupDialogTitle => 'एक Sadho बैकअप चुनें';

  @override
  String get areYouSure => 'क्या आप निश्चित हैं?';

  @override
  String get deleteAccountWarning =>
      'यह आपका खाता और इस फ़ोन पर सहेजा गया सब कुछ हटाता है: आपकी प्रोफ़ाइल, निशान, योजनाएं, मंत्र, आवाज़ प्रशिक्षण और सेटिंग्स। इसे पूर्ववत नहीं किया जा सकता।';

  @override
  String get yesAction => 'हां';

  @override
  String get noAction => 'नहीं';

  @override
  String get dangerZoneTitle => 'खतरा क्षेत्र';

  @override
  String get deleteAccountExplain =>
      'अपना खाता हटाने से आपकी प्रोफ़ाइल और इस फ़ोन पर सहेजा गया सब कुछ मिट जाता है। यदि आप इसे वापस चाहते हैं तो पहले बैकअप निर्यात करें।';

  @override
  String get deleteAccountButton => 'खाता हटाएं';

  @override
  String get profileSaved => 'प्रोफ़ाइल सहेजी गई';

  @override
  String get yourDetailsTitle => 'आपका विवरण';

  @override
  String get nameLabel => 'नाम';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get dailyReminderTitle => 'दैनिक रिमाइंडर';

  @override
  String get dailySadhanaReminder => 'दैनिक साधना रिमाइंडर';

  @override
  String get reminderOff => 'बंद';

  @override
  String everyDayAt(String time) {
    return 'हर दिन $time बजे';
  }

  @override
  String get allowNotificationsForReminder =>
      'रिमाइंडर बजने के लिए सेटिंग्स में सूचनाएं चालू करें।';

  @override
  String get timeLabel => 'समय';

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
  String get paletteMarigoldBlurb => 'गर्म केसरिया और गहरा नील';

  @override
  String get paletteSandalwoodName => 'चंदन';

  @override
  String get paletteSandalwoodBlurb => 'मुलायम चंदन भूरा और मिट्टी';

  @override
  String get paletteTulsiName => 'तुलसी हरा';

  @override
  String get paletteTulsiBlurb => 'शांत पवित्र-तुलसी हरा';

  @override
  String get paletteTwilightName => 'गोधूलि नील';

  @override
  String get paletteTwilightBlurb => 'दीपक-चमक सुनहरे के साथ संध्या नील';

  @override
  String get paletteLotusName => 'कमल गुलाबी';

  @override
  String get paletteLotusBlurb => 'कोमल कमल गुलाबी और पत्ती हरा';

  @override
  String get sadhanaTimeNotifTitle => '🪔 आपकी साधना का समय';

  @override
  String get sadhanaTimeNotifBody =>
      'अपने पाठ या मंत्र के लिए कुछ शांत मिनट निकालें 🙏';

  @override
  String get comingSoon => 'जल्द आ रहा है';

  @override
  String get trainAction => 'प्रशिक्षित करें';

  @override
  String get onboardingTitle => 'Sadho में आपका स्वागत है';

  @override
  String get onboardingSubtitle =>
      'शुरू करने के लिए अपनी भाषा और परंपरा चुनें। आप दोनों को बाद में प्रोफ़ाइल में बदल सकते हैं।';

  @override
  String get traditionHeading => 'परंपरा';

  @override
  String get continueAction => 'जारी रखें';

  @override
  String get stopAlert => 'रोकें';

  @override
  String get repeatLabel => 'दोहराएं';

  @override
  String get repeatOnce => 'एक बार';

  @override
  String soundRepeatTimes(int times) {
    return '$times बार';
  }

  @override
  String get repeatUntilStopped => 'रोकने तक';

  @override
  String vibrationRepeatUntilStopped(int seconds) {
    return 'हर $seconds सेकंड, रोकने तक';
  }

  @override
  String get keepScreenOnLabel => 'गिनती के दौरान स्क्रीन चालू रखें';

  @override
  String get keepScreenOnSubtitle =>
      'सत्र चलते समय स्क्रीन बंद नहीं होती। पावर बटन से फ़ोन फिर भी लॉक होता है; तब समय या लय वाला सत्र पूरा होने पर अलार्म की तरह बजता है।';

  @override
  String get alarmMayBeLate =>
      'अलार्म थोड़ी देर से बज सकता है (सटीक अलार्म बंद हैं)।';

  @override
  String get exactAlarmNotice =>
      'स्क्रीन बंद होने पर भी ठीक समय पर बजने के लिए, Sadho को सटीक अलार्म की अनुमति दें।';

  @override
  String get fullScreenNotice =>
      'पूरा सत्र लॉक स्क्रीन पर दिखाने के लिए, फ़ुल-स्क्रीन सूचनाओं की अनुमति दें।';

  @override
  String get allowAction => 'अनुमति दें';

  @override
  String channelSadhanaAlarmName(String sound) {
    return 'साधना अलार्म · $sound';
  }

  @override
  String get channelSadhanaAlarmSilentName => 'साधना अलार्म · मौन';

  @override
  String get channelNoVibration => 'कंपन नहीं';

  @override
  String get channelSadhanaAlarmDesc =>
      'समय या लय वाला सत्र पूरा होने पर बजता है';

  @override
  String get alarmScreenSadhanaTitle => 'साधना पूर्ण 🙏';

  @override
  String get alarmScreenTimerTitle => 'टाइमर पूरा हुआ';

  @override
  String get alarmScreenSunTitle => 'सूर्य अलार्म';

  @override
  String get alarmScreenUnlock => 'Sadho खोलने के लिए अनलॉक करें';

  @override
  String get alarmScreenUnlockHint =>
      'ऐप के बाकी हिस्से के लिए फ़ोन अनलॉक होना चाहिए।';

  @override
  String get alarmsReliabilityTitle => 'अलार्म और विश्वसनीयता';

  @override
  String get alarmsReliabilityIntro =>
      'स्क्रीन बंद होने पर भी अलार्म समय पर बजें, इसके लिए फ़ोन को ये अनुमतियाँ देनी होंगी। ठीक करें सही सेटिंग पेज खोलता है।';

  @override
  String get alarmsReliabilityAllOk => 'अलार्म समय पर बजने के लिए सब तैयार है';

  @override
  String get alarmsReliabilityAttention => 'कुछ ध्यान देने योग्य है';

  @override
  String get healthOk => 'ठीक है';

  @override
  String get healthNeedsAttention => 'ध्यान दें';

  @override
  String get healthFix => 'ठीक करें';

  @override
  String get healthNotificationsTitle => 'सूचनाओं की अनुमति';

  @override
  String get healthNotificationsBody =>
      'अलार्म और रिमाइंडर सूचना के रूप में आते हैं।';

  @override
  String get healthExactTitle => 'सटीक अलार्म की अनुमति';

  @override
  String get healthExactBody => 'ठीक उसी सेकंड बजता है, थोड़ी देर से नहीं।';

  @override
  String get healthFullScreenTitle => 'लॉक स्क्रीन पर अलार्म दिखाएँ';

  @override
  String get healthFullScreenBody =>
      'फ़ोन लॉक होने पर भी पूरा हुआ अलार्म दिखता है।';

  @override
  String get healthBatteryTitle => 'बैटरी: ऐप प्रतिबंधित नहीं';

  @override
  String get healthBatteryBody =>
      'बैटरी में अप्रतिबंधित चुनें (या कम से कम प्रतिबंधित नहीं), ताकि फ़ोन अलार्म न रोके।';

  @override
  String get healthBatterySamsungHint =>
      'Samsung: सेटिंग्स › बैटरी › बैकग्राउंड उपयोग सीमाएँ में, Sadho को “स्लीपिंग ऐप्स” और “डीप स्लीपिंग ऐप्स” से हटाएँ, और बैटरी उपयोग “अप्रतिबंधित” करें।';

  @override
  String get alarmExplainerOk =>
      'यह सत्र पूरा होने पर अलार्म की तरह बजेगा, स्क्रीन बंद हो या ऐप बंद हो तब भी।';

  @override
  String get alarmExplainerAttention =>
      'यह सत्र पूरा होने पर अलार्म की तरह बजेगा, पर समय पर बजने के लिए फ़ोन की एक सेटिंग बदलनी होगी।';

  @override
  String get alarmExplainerCheck => 'जाँचें';

  @override
  String get customTimerName => 'कस्टम टाइमर';

  @override
  String customChipLabel(String duration) {
    return 'कस्टम · $duration';
  }

  @override
  String get customTimerTitle => 'अपनी अवधि';

  @override
  String get customTimerRange => '1 सेकंड से 24 घंटे तक चुनें।';

  @override
  String durationHours(int hours) {
    return '$hours घंटे';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes मिनट';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds सेकंड';
  }

  @override
  String collapseSection(String section) {
    return '$section छिपाएँ';
  }

  @override
  String expandSection(String section) {
    return '$section दिखाएँ';
  }

  @override
  String get summaryVibrationOn => 'कंपन चालू';

  @override
  String get summaryVibrationOff => 'कंपन बंद';

  @override
  String get summarySoundOff => 'ध्वनि बंद';

  @override
  String get summaryNotSet => 'तय नहीं';
}
