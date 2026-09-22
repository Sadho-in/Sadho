// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get navHome => 'హోమ్';

  @override
  String get navSadhana => 'సాధన';

  @override
  String get navCalendar => 'క్యాలెండర్';

  @override
  String get navClock => 'గడియారం';

  @override
  String get tooltipLanguage => 'భాష';

  @override
  String get tooltipProfile => 'ప్రొఫైల్';

  @override
  String get tooltipSwitchToLight => 'లైట్ థీమ్‌కు మారండి';

  @override
  String get tooltipSwitchToDark => 'డార్క్ థీమ్‌కు మారండి';

  @override
  String get languageSheetTitle => 'భాష';

  @override
  String get languageSheetSubtitle =>
      'మీ ఎంపిక సేవ్ చేయబడి వెంటనే వర్తిస్తుంది.';

  @override
  String get actionCancel => 'రద్దు చేయి';

  @override
  String get actionDelete => 'తొలగించు';

  @override
  String get actionSave => 'సేవ్ చేయి';

  @override
  String get actionReset => 'రీసెట్ చేయి';

  @override
  String get actionEdit => 'సవరించు';

  @override
  String get actionOk => 'సరే';

  @override
  String get unitSeconds => 'సెకన్లు';

  @override
  String get unitMinutes => 'నిమిషాలు';

  @override
  String get unitHours => 'గంటలు';

  @override
  String get paceErrorEmpty => 'వేగాన్ని నమోదు చేయండి.';

  @override
  String get paceErrorNotNumber => 'ఇది సంఖ్య కాదు.';

  @override
  String paceErrorTooFast(String min) {
    return 'చాలా వేగంగా ఉంది. కనిష్టం $min.';
  }

  @override
  String paceErrorTooSlow(String max) {
    return 'చాలా నెమ్మదిగా ఉంది. గరిష్టం $max.';
  }

  @override
  String get modeTap => 'ట్యాప్';

  @override
  String get modeRhythm => 'రిథమ్';

  @override
  String get modeVoice => 'వాయిస్';

  @override
  String get modeMala => 'మాల';

  @override
  String get ringtoneTempleBell => 'గుడి గంట';

  @override
  String get ringtoneSingingBowl => 'సింగింగ్ బౌల్';

  @override
  String get ringtoneSoftChime => 'మృదువైన చైమ్';

  @override
  String get ringtoneDeepGong => 'లోతైన గాంగ్';

  @override
  String get msgVoiceUnsupported =>
      'వాయిస్ కౌంటింగ్ Android మరియు iOSలో మాత్రమే పనిచేస్తుంది';

  @override
  String get msgVoiceNoMic => 'ఈ పరికరంలో మైక్రోఫోన్ అందుబాటులో లేదు';

  @override
  String get msgMalaUnsupported =>
      'వాల్యూమ్-కీ కౌంటింగ్‌కు నిజమైన పరికరం అవసరం';

  @override
  String trainFirstPrompt(int min, int max) {
    return 'ముందుగా ఈ మంత్రం కోసం మీ వాయిస్‌ను శిక్షణ ఇవ్వండి: దీన్ని $min నుండి $max సార్లు రికార్డ్ చేయండి.';
  }

  @override
  String get fallbackVoiceDenied =>
      'మైక్రోఫోన్ అనుమతి తిరస్కరించబడింది, కాబట్టి వాయిస్ కౌంటింగ్ వినలేదు. ట్యాప్ మోడ్ ఉపయోగిస్తోంది.';

  @override
  String get fallbackVoiceBlocked =>
      'మైక్రోఫోన్ యాక్సెస్ నిరోధించబడింది. వాయిస్ కౌంటింగ్ ఉపయోగించడానికి సెట్టింగ్‌లలో అనుమతించండి. ట్యాప్ మోడ్ ఉపయోగిస్తోంది.';

  @override
  String get fallbackVoiceUnsupported =>
      'వాయిస్ కౌంటింగ్ Android మరియు iOSలో మాత్రమే పనిచేస్తుంది. ట్యాప్ మోడ్ ఉపయోగిస్తోంది.';

  @override
  String get fallbackVoiceNoMic =>
      'ఈ పరికరంలో మైక్రోఫోన్ అందుబాటులో లేదు. ట్యాప్ మోడ్ ఉపయోగిస్తోంది.';

  @override
  String get fallbackMalaUnsupported =>
      'వాల్యూమ్-కీ కౌంటింగ్‌కు నిజమైన పరికరం అవసరం. ట్యాప్ మోడ్ ఉపయోగిస్తోంది.';

  @override
  String get sadhanaRingTitle => '🔔 సాధన సమయం పూర్తయింది';

  @override
  String get sadhanaRingBody => 'మీ సెషన్ సమయం ముగిసింది 🙏';

  @override
  String get voiceTooShort =>
      'ఇది చాలా చిన్నదిగా ఉంది. పూర్తి మంత్రం చెప్పండి.';

  @override
  String get voiceRanTooLong =>
      'ఇది చాలా సేపు కొనసాగింది. మంత్రం ఒకసారి చెప్పి ఆగండి.';

  @override
  String get voiceSoundedDifferent =>
      'ఇది ఇతరుల కంటే భిన్నంగా వినిపించింది. అదే విధంగా మళ్ళీ చెప్పండి.';

  @override
  String get voiceGotIt => 'అర్థమైంది. మళ్ళీ చెప్పండి.';

  @override
  String get voiceDeniedShort =>
      'మైక్రోఫోన్ అనుమతి తిరస్కరించబడింది, కాబట్టి వాయిస్ కౌంటింగ్ వినలేదు.';

  @override
  String get voiceBlockedShort =>
      'మైక్రోఫోన్ యాక్సెస్ నిరోధించబడింది. వాయిస్ కౌంటింగ్ ఉపయోగించడానికి సెట్టింగ్‌లలో అనుమతించండి.';

  @override
  String get voiceAccessLost =>
      'మైక్రోఫోన్ యాక్సెస్ కోల్పోయింది, కాబట్టి వాయిస్ కౌంటింగ్ ఆగిపోయింది.';

  @override
  String get voiceCouldNotRestart =>
      'మైక్రోఫోన్ మళ్ళీ ప్రారంభం కాలేదు, కాబట్టి వాయిస్ కౌంటింగ్ ఆగిపోయింది.';

  @override
  String get mantraLibraryTitle => 'మంత్ర లైబ్రరీ';

  @override
  String get addMantra => 'మంత్రం జోడించు';

  @override
  String get searchHint => 'శీర్షిక, లిపి లేదా సంప్రదాయం శోధించండి';

  @override
  String noMantrasMatch(String query) {
    return '“$query”తో ఏ మంత్రం సరిపోలలేదు.\nమీ సొంతం సృష్టించడానికి “మంత్రం జోడించు” నొక్కండి.';
  }

  @override
  String mantraAdded(String title) {
    return '“$title” జోడించబడింది';
  }

  @override
  String mantraSaved(String title) {
    return '“$title” సేవ్ చేయబడింది';
  }

  @override
  String mantraRestored(String title) {
    return '“$title” దాని డిఫాల్ట్‌కు పునరుద్ధరించబడింది';
  }

  @override
  String get deleteMantraTitle => 'మంత్రాన్ని తొలగించాలా?';

  @override
  String deleteMantraBody(String title) {
    return '“$title” మీ లైబ్రరీ నుండి తీసివేయబడుతుంది.';
  }

  @override
  String get retrainVoiceTooltip => 'వాయిస్‌ను మళ్ళీ శిక్షణ ఇవ్వండి';

  @override
  String get trainVoice => 'వాయిస్‌కు శిక్షణ ఇవ్వండి';

  @override
  String mantraCountTag(int count) {
    return '$count లెక్కలు';
  }

  @override
  String get editedTag => 'సవరించబడింది';

  @override
  String get editMantra => 'మంత్రాన్ని సవరించు';

  @override
  String get addAMantra => 'ఒక మంత్రాన్ని జోడించు';

  @override
  String get titleLabel => 'శీర్షిక *';

  @override
  String get titleRequired => 'శీర్షిక నమోదు చేయండి';

  @override
  String get scriptTextLabel => 'లిపి వచనం';

  @override
  String get transliterationLabel => 'లిప్యంతరీకరణ';

  @override
  String get traditionLabel => 'సంప్రదాయం / భాష';

  @override
  String get traditionHint => 'ఉదా. సంస్కృతం · హిందూ';

  @override
  String get defaultCountLabel => 'డిఫాల్ట్ లెక్క *';

  @override
  String get enterNumberOneOrMore =>
      '1 లేదా అంతకంటే ఎక్కువ సంఖ్యను నమోదు చేయండి';

  @override
  String get tooLarge => 'ఇది చాలా పెద్దది';

  @override
  String get saveChanges => 'మార్పులను సేవ్ చేయి';

  @override
  String get saveToLibrary => 'లైబ్రరీలో సేవ్ చేయి';

  @override
  String get resetToDefaultButton => 'డిఫాల్ట్‌కు రీసెట్ చేయి';

  @override
  String get resetToDefaultTitle => 'డిఫాల్ట్‌కు రీసెట్ చేయాలా?';

  @override
  String resetToDefaultBody(String title) {
    return '“$title”కు మీ మార్పులు తీసివేయబడి, అంతర్నిర్మిత వచనం పునరుద్ధరించబడుతుంది.';
  }

  @override
  String switchToMantra(String title) {
    return '$titleకు మారాలా?';
  }

  @override
  String get switchMantraBody => 'మీ ప్రస్తుత లెక్క రీసెట్ చేయబడుతుంది.';

  @override
  String get keepCurrent => 'ప్రస్తుతదాన్ని ఉంచు';

  @override
  String get switchAction => 'మార్చు';

  @override
  String get smallerMantraText => 'చిన్న మంత్ర వచనం';

  @override
  String get largerMantraText => 'పెద్ద మంత్ర వచనం';

  @override
  String get libraryButton => 'లైబ్రరీ';

  @override
  String get trainYourOwnMantra => 'మీ సొంత మంత్రానికి శిక్షణ ఇవ్వండి';

  @override
  String voiceCountingFrom(String title, int count) {
    return 'మీ $count రికార్డింగుల నుండి “$title” లెక్కించబడుతోంది. ఇతర శబ్దాలు, పదాలు పట్టించుకోబడవు.';
  }

  @override
  String voiceCountsOnlyTrained(String title, int min, int max) {
    return 'మీరు శిక్షణ ఇచ్చిన మంత్రాన్ని మాత్రమే వాయిస్ లెక్కిస్తుంది. ప్రారంభించడానికి “$title”ని $min నుండి $max సార్లు రికార్డ్ చేయండి.';
  }

  @override
  String get addMoreSamples => 'మరిన్ని నమూనాలను జోడించు';

  @override
  String get retrain => 'మళ్ళీ శిక్షణ ఇవ్వండి';

  @override
  String get clearTraining => 'శిక్షణను క్లియర్ చేయి';

  @override
  String get voiceBetaNote =>
      'బీటా: ఇది పరికరంలోనే, ఆఫ్‌లైన్‌లో పనిచేస్తుంది. ఎక్కువ రికార్డింగులతో ఖచ్చితత్వం పెరుగుతుంది, శబ్దం ఉన్న గదిలో తగ్గుతుంది. పునరావృతాల మధ్య కొద్దిగా ఆగండి. ఇక్కడ మీ వాయిస్ మాత్రమే లెక్కించబడుతుంది; + మరియు − బటన్లు లెక్కను సరిచేస్తాయి.';

  @override
  String get trainVoiceFirstTitle => 'ముందుగా మీ వాయిస్‌కు శిక్షణ ఇవ్వండి';

  @override
  String trainVoiceFirstBody(String title, int min, int max) {
    return 'మీరు శిక్షణ ఇచ్చిన మంత్రాన్ని మాత్రమే వాయిస్ లెక్కిస్తుంది. “$title”ని $min నుండి $max సార్లు (సుమారు ఒక నిమిషం) రికార్డ్ చేయండి. ఇది ఈ పరికరంలోనే ఉండి ఆఫ్‌లైన్‌లో పనిచేస్తుంది.';
  }

  @override
  String get later => 'తర్వాత';

  @override
  String get trainNow => 'ఇప్పుడు శిక్షణ ఇవ్వండి';

  @override
  String get betaLabel => 'బీటా';

  @override
  String get voiceTrained => 'వాయిస్ శిక్షణ పొందింది';

  @override
  String get voiceNotTrained => 'వాయిస్ శిక్షణ పొందలేదు';

  @override
  String get sensitivityLabel => 'సున్నితత్వం';

  @override
  String get sensitivityStrict => 'కఠినం';

  @override
  String get sensitivityLenient => 'సడలింపు';

  @override
  String get sensitivityMedium => 'మధ్యస్థం';

  @override
  String get clearVoiceTrainingTitle => 'వాయిస్ శిక్షణను క్లియర్ చేయాలా?';

  @override
  String clearVoiceTrainingBody(String title) {
    return 'మీరు దీన్ని మళ్ళీ శిక్షణ ఇచ్చేవరకు వాయిస్ “$title”ని లెక్కించడం ఆపేస్తుంది.';
  }

  @override
  String get completionTitle => 'పూర్తి';

  @override
  String get vibrationLabel => 'వైబ్రేషన్';

  @override
  String vibrationSubtitle(int n) {
    return 'ప్రతి $n లెక్కలకు ఒక కంపనం, లక్ష్యం వద్ద బలమైనది.';
  }

  @override
  String intensityLevel(int level) {
    return 'తీవ్రత: స్థాయి $level లో 5';
  }

  @override
  String get testMilestone => 'టెస్ట్ మైలురాయి';

  @override
  String get testTarget => 'టెస్ట్ లక్ష్యం';

  @override
  String get ringtoneLabel => 'రింగ్‌టోన్';

  @override
  String get ringtoneSubtitle =>
      'లక్ష్యాన్ని చేరుకున్నప్పుడు ఒక శబ్దం మోగుతుంది.';

  @override
  String get playSound => 'శబ్దాన్ని ప్లే చేయి';

  @override
  String get combined => 'కలిపి';

  @override
  String get combinedTooltip =>
      'నాలుగు మోడ్‌లు అన్నీ ఒక ఉమ్మడి లెక్కకు కలుస్తాయి';

  @override
  String get separate => 'వేరుగా';

  @override
  String get separateTooltip => 'ప్రతి మోడ్ దాని స్వంత లెక్కను ఉంచుతుంది';

  @override
  String get countModeSemantic => 'కౌంట్ మోడ్';

  @override
  String get combinedExplain =>
      'ట్యాప్, వాయిస్, రిథమ్ మరియు మాల అన్నీ ఒక లక్ష్యం వైపు ఒక ఉమ్మడి లెక్కలో కలుస్తాయి.';

  @override
  String get separateExplain =>
      'ప్రతి మోడ్ దాని స్వంత లెక్కను, లక్ష్యం వైపు పురోగతిని ఉంచుతుంది. రీసెట్ మరియు పూర్తి మీరు ఉన్న మోడ్‌కు మాత్రమే వర్తిస్తాయి.';

  @override
  String countedLabel(int count) {
    return '$count లెక్కించబడింది';
  }

  @override
  String ofTarget(int count) {
    return '$count లో';
  }

  @override
  String get removeOneTooltip => 'ఒకటి తీసివేయి';

  @override
  String get undoLabel => 'రద్దు చేయి';

  @override
  String get countLabel => 'లెక్క';

  @override
  String get addOneTooltip => 'ఒకటి జోడించు';

  @override
  String get focusLabel => 'ఫోకస్';

  @override
  String get focusModeTooltip => 'ఫోకస్ మోడ్';

  @override
  String get pause => 'పాజ్';

  @override
  String get resume => 'మళ్ళీ ప్రారంభించు';

  @override
  String get start => 'ప్రారంభించు';

  @override
  String targetReachedSeparate(String mode) {
    return '$modeలో లక్ష్యం చేరుకుంది 🙏  ఈ మోడ్‌ను రీసెట్ చేయండి, మోడ్ మార్చండి, లేదా లక్ష్యాన్ని పెంచండి.';
  }

  @override
  String get targetReachedCombined =>
      'లక్ష్యం చేరుకుంది 🙏  రీసెట్ చేయండి, లేదా లక్ష్యాన్ని పెంచండి.';

  @override
  String resetModeCountTitle(String mode) {
    return '$mode లెక్కను రీసెట్ చేయాలా?';
  }

  @override
  String get resetSessionTitle => 'ఈ సెషన్‌ను రీసెట్ చేయాలా?';

  @override
  String resetModeCountBody(String mode, int count) {
    return 'మీ $mode లెక్క $count సున్నాకు తిరిగి వెళ్తుంది. ఇతర మోడ్‌లు తమ లెక్కలను ఉంచుకుంటాయి.';
  }

  @override
  String resetSessionBody(int count) {
    return 'మీ $count లెక్క సున్నాకు తిరిగి వెళ్తుంది.';
  }

  @override
  String get modeHelpTap =>
      'రింగ్‌ను నొక్కండి, లేదా ఫోకస్ మోడ్‌లో ఎక్కడైనా. ట్యాప్ మోడ్ మాత్రమే స్క్రీన్ ట్యాప్‌లను లెక్కిస్తుంది.';

  @override
  String get modeHelpRhythm =>
      'Start నొక్కండి, లెక్క దిగువ వేగంలో దానంతట అదే పెరుగుతుంది.';

  @override
  String get modeHelpVoice =>
      'Start నొక్కి, మీ శిక్షణ పొందిన మంత్రాన్ని జపించండి. ప్రతిసారి గుర్తించినప్పుడు వెంటనే ఒక లెక్క జోడించబడుతుంది; ఇతర శబ్దాలు పట్టించుకోబడవు. మైక్రోఫోన్ అవసరం; నిశ్శబ్ద గదిలో ఉత్తమంగా పనిచేస్తుంది.';

  @override
  String get modeHelpMala =>
      'Start నొక్కి, లెక్కించడానికి ఏదైనా వాల్యూమ్ బటన్‌ను నొక్కండి. కళ్ళు మూసుకున్నప్పుడు లేదా ఫోన్ జేబులో ఉన్నప్పుడు అనుకూలం. స్క్రీన్ ఆన్‌లో ఉండాలి.';

  @override
  String get countingModeLabel => 'కౌంటింగ్ మోడ్';

  @override
  String pacePrefix(String pace) {
    return 'వేగం: లెక్క $pace';
  }

  @override
  String modeSemanticLabel(String mode) {
    return '$mode మోడ్';
  }

  @override
  String get tapAnywhereToCount => 'లెక్కించడానికి ఎక్కడైనా నొక్కండి';

  @override
  String countingPace(String pace) {
    return 'లెక్కింపు $pace';
  }

  @override
  String pausedPace(String pace) {
    return 'పాజ్ చేయబడింది · $pace';
  }

  @override
  String get listening => 'వింటోంది…';

  @override
  String get startingMicrophone =>
      'మైక్రోఫోన్ ప్రారంభమవుతోంది… అడిగితే యాక్సెస్ ఇవ్వండి';

  @override
  String get notTrainedYet =>
      'ఇంకా శిక్షణ పొందలేదు · వాయిస్ ఉపయోగించడానికి మంత్రానికి శిక్షణ ఇవ్వండి';

  @override
  String get pausedPressStartListen =>
      'పాజ్ చేయబడింది · వినడానికి Start నొక్కండి';

  @override
  String get pressVolumeKeys => 'లెక్కించడానికి వాల్యూమ్ కీలను నొక్కండి';

  @override
  String get capturingVolumeKeys => 'వాల్యూమ్ కీలను క్యాప్చర్ చేస్తోంది…';

  @override
  String get pausedPressStartVolume =>
      'పాజ్ చేయబడింది · వాల్యూమ్ కీలను ఉపయోగించడానికి Start నొక్కండి';

  @override
  String modeTitleLine(String mode, String own) {
    String _temp0 = intl.Intl.selectLogic(own, {
      'yes': ' · సొంత లెక్క',
      'other': '',
    });
    return '$mode మోడ్$_temp0';
  }

  @override
  String voiceCountedMatch(int percent) {
    return 'లెక్కించబడింది · $percent% సరిపోలిక';
  }

  @override
  String voiceIgnoredMatch(int percent) {
    return 'పట్టించుకోబడలేదు · $percent% సరిపోలిక (మీ మంత్రం కాదు)';
  }

  @override
  String get paceFieldLabel => 'వేగం';

  @override
  String paceHelpOk(String pace, String range) {
    return '$pace లెక్కిస్తుంది. (అనుమతించబడింది: $range)';
  }

  @override
  String paceHelpError(String error, String pace) {
    return '$error ఇంకా $pace లెక్కిస్తోంది.';
  }

  @override
  String get sankalpLabel => 'సంకల్పం';

  @override
  String get sankalpHint => 'ఈ సాధన కోసం మీ సంకల్పాన్ని చెప్పండి…';

  @override
  String get targetSectionTitle => 'లక్ష్యం';

  @override
  String get byCount => 'లెక్క ప్రకారం';

  @override
  String get byTime => 'సమయం ప్రకారం';

  @override
  String customWithValue(String value) {
    return 'కస్టమ్ · $value';
  }

  @override
  String get custom => 'కస్టమ్';

  @override
  String get enterNumberRange => '1 నుండి 9,999,999 వరకు సంఖ్యను నమోదు చేయండి';

  @override
  String get customCountTitle => 'కస్టమ్ లెక్క';

  @override
  String get targetCountLabel => 'లక్ష్య లెక్క';

  @override
  String get setAction => 'సెట్ చేయి';

  @override
  String get durationLabel => 'వ్యవధి';

  @override
  String get enterDuration => '1 లేదా అంతకంటే ఎక్కువ వ్యవధిని నమోదు చేయండి.';

  @override
  String get maxDurationCapped =>
      'గరిష్టం 99 గం 59 ని 59 సె — దీన్ని పరిమితం చేస్తారు.';

  @override
  String sessionLasts(String duration) {
    return 'సెషన్ $duration వరకు కొనసాగుతుంది.';
  }

  @override
  String get targetReachedFocus => 'లక్ష్యం చేరుకుంది 🙏';

  @override
  String screenTapsDoNotCount(String mode) {
    return '$mode మోడ్‌లో స్క్రీన్ ట్యాప్‌లు లెక్కించబడవు. సరిచేయడానికి + లేదా − ఉపయోగించండి.';
  }

  @override
  String holdFingersToExit(int fingers, int seconds) {
    return 'బయటకు వెళ్ళడానికి $fingers వేళ్లను $seconds సెకన్లు నొక్కి పట్టుకోండి';
  }

  @override
  String get holdToExitFocusMode =>
      'ఫోకస్ మోడ్ నుండి బయటకు వెళ్ళడానికి నొక్కి పట్టుకోండి';

  @override
  String get holdToExit => 'బయటకు వెళ్ళడానికి నొక్కి పట్టుకోండి';

  @override
  String get keepHoldingToExit => 'బయటకు వెళ్ళడానికి నొక్కి ఉంచండి…';

  @override
  String addedRecordingsTo(int added, String title, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'రికార్డింగులు',
      one: 'రికార్డింగ్',
    );
    return '“$title”కు $added $_temp0 జోడించబడ్డాయి (మొత్తం $total)';
  }

  @override
  String voiceTrainedFor(String title, int count) {
    return '“$title” కోసం వాయిస్ శిక్షణ పొందింది ($count రికార్డింగులు)';
  }

  @override
  String trainedRecordingsCount(int count) {
    return 'శిక్షణ పొందింది · $count రికార్డింగులు';
  }

  @override
  String get tooFewRecordings =>
      'లెక్కించడానికి చాలా తక్కువ రికార్డింగులు ఉన్నాయి. మరిన్ని జోడించండి, లేదా మళ్ళీ శిక్షణ ఇవ్వండి.';

  @override
  String canCountAddMore(int room) {
    return 'ఈ మంత్రాన్ని వాయిస్ లెక్కించగలదు. మళ్ళీ మొదలుపెట్టకుండా ఖచ్చితత్వాన్ని మెరుగుపరచడానికి మరో $room రికార్డింగులను జోడించండి.';
  }

  @override
  String canCountAtMax(int max) {
    return 'ఈ మంత్రాన్ని వాయిస్ లెక్కించగలదు. మీ వద్ద గరిష్టంగా $max రికార్డింగులు ఉన్నాయి; వాటిని భర్తీ చేయడానికి మళ్ళీ శిక్షణ ఇవ్వండి.';
  }

  @override
  String get pausedHeadline => 'పాజ్ చేయబడింది';

  @override
  String pausedSub(int recorded) {
    return '$recorded రికార్డ్ చేయబడ్డాయి. కొనసాగించండి, లేదా ఉన్నదాన్ని సేవ్ చేయండి.';
  }

  @override
  String recordInstructions(int min, int max, int recommended) {
    return 'మీ సాధారణ జప వేగంతో దీన్ని $min నుండి $max సార్లు రికార్డ్ చేయండి ($recommended మంచి సంఖ్య). తర్వాత వాయిస్ మీ మంత్రాన్ని మాత్రమే లెక్కిస్తుంది.';
  }

  @override
  String get openingMicrophone => 'మైక్రోఫోన్ తెరవబడుతోంది…';

  @override
  String get stayQuiet => 'కొద్దిసేపు నిశ్శబ్దంగా ఉండండి…';

  @override
  String get listeningToRoom =>
      'నేపథ్య శబ్దం లెక్కించబడకుండా ఉండటానికి గదిని వింటోంది.';

  @override
  String get sayYourMantra => 'మీ మంత్రాన్ని చెప్పండి…';

  @override
  String recordingXofY(int current, int max) {
    return '$current రికార్డ్ అవుతోంది, గరిష్టంగా $max లో';
  }

  @override
  String allRecordingsCaptured(int count) {
    return 'మొత్తం $count రికార్డింగులు క్యాప్చర్ చేయబడ్డాయి';
  }

  @override
  String get saveToStartCounting =>
      'వాయిస్‌తో లెక్కింపు ప్రారంభించడానికి వీటిని సేవ్ చేయండి.';

  @override
  String get cannotUseMicrophone => 'మైక్రోఫోన్‌ను ఉపయోగించలేము';

  @override
  String get canSaveNowHint =>
      'మీరు ఇప్పుడు సేవ్ చేయవచ్చు, లేదా మరింత ఖచ్చితత్వం కోసం కొనసాగించవచ్చు.';

  @override
  String minAreEnough(int min) {
    return 'ప్రారంభించడానికి $min సరిపోతాయి.';
  }

  @override
  String addingToSaved(int count) {
    return 'మీ $count సేవ్ చేసిన రికార్డింగులకు జోడించబడుతోంది.';
  }

  @override
  String get tryAgain => 'మళ్ళీ ప్రయత్నించండి';

  @override
  String get startRecording => 'రికార్డింగ్ ప్రారంభించండి';

  @override
  String get openSettingsAction => 'సెట్టింగ్‌లను తెరవండి';

  @override
  String saveNRecordings(int count) {
    return '$count రికార్డింగులను సేవ్ చేయండి';
  }

  @override
  String recordMoreToSave(int n) {
    return 'సేవ్ చేయడానికి మరో $n రికార్డ్ చేయండి';
  }

  @override
  String get recordSampleToSave => 'సేవ్ చేయడానికి ఒక నమూనాను రికార్డ్ చేయండి';

  @override
  String get undoLast => 'చివరిది రద్దు చేయి';

  @override
  String get stop => 'ఆపు';

  @override
  String get continueRecording => 'రికార్డింగ్ కొనసాగించండి';

  @override
  String get startOver => 'మళ్ళీ ప్రారంభించండి';

  @override
  String recordedOfMax(int recorded, int max) {
    return '$recorded రికార్డ్ చేయబడ్డాయి, గరిష్టంగా $max లో';
  }

  @override
  String voiceBetaNoteTraining(int max) {
    return 'బీటా. ప్రతిదీ ఈ పరికరంలోనే, ఆఫ్‌లైన్‌లో జరుగుతుంది: శబ్దాన్ని వివరించే సంఖ్యలు మాత్రమే సేవ్ చేయబడతాయి, ఆడియో ఎప్పుడూ కాదు. ఎక్కువ రికార్డింగులు లెక్కింపును మరింత ఖచ్చితంగా చేస్తాయి (గరిష్టంగా $max వరకు); శబ్దం ఉన్న గది దాన్ని తక్కువ ఖచ్చితంగా చేస్తుంది. మంత్రాన్ని ఒకసారి చెప్పి, తర్వాతి దానికి ముందు కొద్దిగా ఆగండి.';
  }

  @override
  String get actionClear => 'క్లియర్ చేయి';

  @override
  String get today => 'ఈరోజు';

  @override
  String get previousMonth => 'మునుపటి నెల';

  @override
  String get nextMonth => 'తదుపరి నెల';

  @override
  String get markTypeGood => 'మంచిది';

  @override
  String get markTypeCautious => 'జాగ్రత్త';

  @override
  String get markTypeNeutral => 'తటస్థం';

  @override
  String get reminderModeNone => 'సమయం లేదు';

  @override
  String get reminderModeOnce => 'ఒకసారి';

  @override
  String get reminderModeSeveral => 'అనేక సార్లు';

  @override
  String get repeatRuleOnce => 'ఒకసారి';

  @override
  String get repeatRuleDaily => 'ప్రతిరోజు';

  @override
  String get repeatRuleWeekly => 'వారానికి';

  @override
  String get repeatRuleMonthly => 'నెలవారీ';

  @override
  String get repeatRuleQuarterly => 'త్రైమాసికం';

  @override
  String get repeatRuleHalfYearly => 'అర్ధ-వార్షికం';

  @override
  String get repeatRuleYearly => 'వార్షికం';

  @override
  String get homeModeNone => 'చూపవద్దు';

  @override
  String get homeModeMorning => 'ఉదయం ఒకసారి';

  @override
  String get homeModeAllDay => 'రోజంతా ఉంచు';

  @override
  String get markStyleDot => 'చుక్క';

  @override
  String get markStyleFilled => 'నింపబడింది';

  @override
  String get markStyleHighlight => 'హైలైట్';

  @override
  String get markStyleCircle => 'వృత్తం';

  @override
  String get markStyleSquare => 'చతురస్రం';

  @override
  String get emojiOm => 'ॐ';

  @override
  String get emojiKhanda => 'ఖండా';

  @override
  String get emojiMala => 'మాల';

  @override
  String get emojiDiya => 'దీపం';

  @override
  String get emojiBell => 'గంట';

  @override
  String get emojiSunrise => 'సూర్యోదయం';

  @override
  String get emojiStar => 'నక్షత్రం';

  @override
  String get emojiSparkle => 'మెరుపు';

  @override
  String get emojiMoney => 'డబ్బు';

  @override
  String get emojiHandshake => 'కరచాలనం';

  @override
  String get emojiAvoid => 'నివారించు';

  @override
  String get emojiDone => 'పూర్తయింది';

  @override
  String get markTitleGood => 'మంచి రోజు';

  @override
  String get markTitleCautious => 'జాగ్రత్తగా ఉండాల్సిన రోజు';

  @override
  String get markTitleNeutral => 'తటస్థ రోజు';

  @override
  String get reminderBodyGood => 'మంచి రోజు.';

  @override
  String get reminderBodyCautious => 'ఈరోజు జాగ్రత్తగా ఉండండి.';

  @override
  String get reminderBodyNeutral => 'మీ క్యాలెండర్‌లో గుర్తించబడింది.';

  @override
  String get channelCalendarRemindersName => 'క్యాలెండర్ రిమైండర్‌లు';

  @override
  String get channelCalendarRemindersDesc =>
      'మీరు Sadhoలో గుర్తించిన తేదీల కోసం రిమైండర్‌లు';

  @override
  String get channelAlarmsName => 'అలారం మరియు టైమర్';

  @override
  String get channelAlarmsDesc =>
      'సూర్యుడు ఆధారిత అలారం మరియు పూర్తయిన టైమర్‌లు';

  @override
  String get repeatSummaryOnce => 'ఒకసారి';

  @override
  String get repeatSummaryDaily => 'ప్రతిరోజు';

  @override
  String get repeatSummaryWeekly => 'ప్రతి వారం';

  @override
  String get repeatSummaryMonthly => 'ప్రతి నెల';

  @override
  String get repeatSummaryQuarterly => 'ప్రతి 3 నెలలకు';

  @override
  String get repeatSummaryHalfYearly => 'ప్రతి 6 నెలలకు';

  @override
  String get repeatSummaryYearly => 'ప్రతి సంవత్సరం';

  @override
  String reminderSummaryAt(String times) {
    return '$times వద్ద గుర్తు చేయి';
  }

  @override
  String homeSummaryFrom(String time) {
    return 'హోమ్‌లో $time నుండి';
  }

  @override
  String get homeSummaryAllDay => 'హోమ్‌లో రోజంతా';

  @override
  String marksInMonth(String month) {
    return '$monthలో గుర్తులు';
  }

  @override
  String noMarksInMonth(String month) {
    return '$monthలో ఏమీ గుర్తించబడలేదు. గుర్తును జోడించడానికి తేదీని నొక్కండి.';
  }

  @override
  String get markStyleSectionTitle => 'గుర్తు శైలి';

  @override
  String get markStyleSectionHint =>
      'గుర్తించబడిన తేదీలు ఎలా కనిపిస్తాయి. ప్రతి గుర్తుకు వర్తిస్తుంది.';

  @override
  String markStyleSemantic(String style) {
    return '$style గుర్తు శైలి';
  }

  @override
  String get dayCellToday => ', ఈరోజు';

  @override
  String get dayCellAnd => 'మరియు';

  @override
  String dayCellMarkedSuffix(int count, String kinds) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ', $kinds గుర్తించబడింది, $count గుర్తులు',
      one: ', $kinds గుర్తించబడింది, 1 గుర్తు',
    );
    return '$_temp0';
  }

  @override
  String get markEditorNoTimeWarning =>
      'కనీసం ఒక సమయాన్ని జోడించండి, లేదా \"సమయం లేదు\" ఎంచుకోండి.';

  @override
  String get notificationsOffWarning =>
      'Sadho కోసం నోటిఫికేషన్‌లు ఆఫ్‌లో ఉన్నాయి, కాబట్టి ఈ రిమైండర్ మోగదు. వాటిని మీ ఫోన్ సెట్టింగ్‌లలో ఆన్ చేయండి.';

  @override
  String get deleteMarkFallbackTitle => 'ఈ గుర్తు';

  @override
  String get deleteMarkQuestion => 'ఈ గుర్తును తొలగించాలా?';

  @override
  String deleteMarkRepeatsBody(String title) {
    return '$title మరియు దాని పునరావృత్తులన్నింటినీ తొలగించాలా? దాని రిమైండర్‌లు కూడా తీసివేయబడతాయి.';
  }

  @override
  String deleteMarkBody(String title) {
    return '$titleని తొలగించాలా? దాని రిమైండర్‌లు కూడా తీసివేయబడతాయి.';
  }

  @override
  String get newMark => 'కొత్త గుర్తు';

  @override
  String get editMark => 'గుర్తును సవరించు';

  @override
  String repeatFromNotice(String repeatSummary, String date) {
    return '$repeatSummary, $date నుండి. మార్పులు ప్రతి పునరావృత్తికి వర్తిస్తాయి.';
  }

  @override
  String get markTypeSectionTitle => 'గుర్తు రకం';

  @override
  String get iconSectionTitle => 'చిహ్నం';

  @override
  String get iconNone => 'ఏదీ లేదు';

  @override
  String get labelFieldLabel => 'లేబుల్';

  @override
  String get detailsFieldLabel => 'వివరాలు / గమనికలు';

  @override
  String get remindMeAtSectionTitle => 'నాకు గుర్తు చేయి';

  @override
  String removeTimeTooltip(String time) {
    return '$timeని తీసివేయి';
  }

  @override
  String get addTime => 'సమయాన్ని జోడించు';

  @override
  String get repeatSectionTitle => 'పునరావృత్తం';

  @override
  String get onHomeScreenSectionTitle => 'మీ హోమ్ స్క్రీన్‌లో';

  @override
  String showFromTime(String time) {
    return '$time నుండి చూపించు';
  }

  @override
  String get homeModeNoneExplain => 'గుర్తు క్యాలెండర్‌లో మాత్రమే ఉంటుంది.';

  @override
  String get homeModeMorningExplain =>
      'ఆ సమయంలో హోమ్‌లో ఒక కార్డు కనిపిస్తుంది. పూర్తయిన తర్వాత దాన్ని స్వైప్ చేయండి: తదుపరి పునరావృత్తిలో అది తిరిగి వస్తుంది.';

  @override
  String get homeModeAllDayExplain =>
      'ఒక కార్డు హోమ్‌లో రోజంతా పిన్ చేయబడి ఉంటుంది (దీన్ని స్వైప్ చేయలేరు).';

  @override
  String get tomorrow => 'రేపు';

  @override
  String get yesterday => 'నిన్న';

  @override
  String get startAgain => 'మళ్ళీ ప్రారంభించు';

  @override
  String get settingsAction => 'సెట్టింగ్‌లు';

  @override
  String get clockToolClockSubtitle => 'పెద్ద, లైవ్ సమయం మరియు తేదీ';

  @override
  String get clockToolSunAlarmTitle => 'సూర్యుడు ఆధారిత అలారం';

  @override
  String get clockToolSunAlarmSubtitle =>
      'సూర్యోదయం లేదా సూర్యాస్తమయం వద్ద, ఆఫ్‌సెట్‌తో మేల్కొనండి';

  @override
  String get clockToolWorldClockTitle => 'ప్రపంచ గడియారం';

  @override
  String get clockToolWorldClockSubtitle =>
      'అమృత్‌సర్, హరిద్వార్, లండన్ మరియు మరిన్ని';

  @override
  String get clockToolTimerTitle => 'సాధన & వ్రత టైమర్';

  @override
  String get clockToolTimerSubtitle =>
      'హారతి, చాలీసా, పాఠ్, హవన్, లేదా సూర్యాస్తమయం వరకు';

  @override
  String get clockToolStopwatchTitle => 'పాఠ్ స్టాప్‌వాచ్';

  @override
  String get clockToolStopwatchSubtitle => 'ప్రారంభించు, ఆపు మరియు ల్యాప్ చేయి';

  @override
  String get sunEventSunrise => 'సూర్యోదయం';

  @override
  String get sunEventSunset => 'సూర్యాస్తమయం';

  @override
  String offsetAtEvent(String event) {
    return '$event వద్ద';
  }

  @override
  String offsetMinutesOnly(int m) {
    return '$m నిమిషాలు';
  }

  @override
  String offsetHoursOnly(int h) {
    return '$h గం';
  }

  @override
  String offsetHoursMinutes(int h, int m) {
    return '$h గం $m నిమిషాలు';
  }

  @override
  String offsetBefore(String amount) {
    return '$amount ముందు';
  }

  @override
  String offsetAfter(String amount) {
    return '$amount తర్వాత';
  }

  @override
  String get locationSourceDevice => 'మీ స్థానం';

  @override
  String get locationSourceSaved => 'మీ చివరిగా తెలిసిన స్థానం';

  @override
  String get locationSourceFallback => 'అమృత్‌సర్ (డిఫాల్ట్)';

  @override
  String get locSummaryDevice => 'మీ స్థానాన్ని ఉపయోగిస్తోంది';

  @override
  String get locSummarySaved => 'మీ చివరిగా తెలిసిన స్థానాన్ని ఉపయోగిస్తోంది';

  @override
  String get locSummaryBlocked =>
      'అమృత్‌సర్ ఉపయోగిస్తోంది. సెట్టింగ్‌లలో స్థానం నిరోధించబడింది.';

  @override
  String get locSummaryServiceOff =>
      'అమృత్‌సర్ ఉపయోగిస్తోంది. ఖచ్చితమైన సమయాల కోసం స్థానాన్ని ఆన్ చేయండి.';

  @override
  String get locSummaryUnsupported => 'అమృత్‌సర్ ఉపయోగిస్తోంది.';

  @override
  String get locSummaryDefault =>
      'అమృత్‌సర్ ఉపయోగిస్తోంది. ఖచ్చితమైన సమయాల కోసం స్థానాన్ని అనుమతించండి.';

  @override
  String get presetAarti => 'హారతి';

  @override
  String get presetChalisa => 'చాలీసా';

  @override
  String get presetPath => 'పాఠ్';

  @override
  String get presetHavan => 'హవన్';

  @override
  String get vratToSunset => 'వ్రతం → సూర్యాస్తమయం';

  @override
  String presetChipLabel(String label, int minutes) {
    return '$label · $minutes నిమిషాలు';
  }

  @override
  String get clockNoSunsetHere =>
      'ఇక్కడ ఇప్పుడు లెక్కించడానికి సూర్యాస్తమయం లేదు.';

  @override
  String get clockSunsetPassedTomorrow =>
      'ఈరోజు సూర్యాస్తమయం అయిపోయింది: రేపటి కోసం లెక్కిస్తోంది.';

  @override
  String timerFinishedTitle(String label) {
    return '🔔 $label పూర్తయింది';
  }

  @override
  String get sunsetArrived => 'సూర్యాస్తమయం వచ్చింది 🙏';

  @override
  String timerTimeUp(String label) {
    return 'మీ $label సమయం ముగిసింది 🙏';
  }

  @override
  String sunAlarmNotifTitle(String emoji, String event) {
    return '$emoji $event అలారం';
  }

  @override
  String sunAlarmNotifBody(String event, String time, String offset) {
    return '$event $time వద్ద ఉంది · $offset';
  }

  @override
  String get statusOn => 'ఆన్';

  @override
  String get finished => 'పూర్తయింది';

  @override
  String get left => 'మిగిలింది';

  @override
  String get paused => 'పాజ్';

  @override
  String get runningStatus => 'నడుస్తోంది';

  @override
  String get stoppedStatus => 'ఆగింది';

  @override
  String get lap => 'ల్యాప్';

  @override
  String get lapTime => 'ల్యాప్ సమయం';

  @override
  String get total => 'మొత్తం';

  @override
  String get fastest => 'వేగవంతమైనది';

  @override
  String get slowest => 'నెమ్మదైనది';

  @override
  String get tapLapToMark => 'ల్యాప్‌ను గుర్తించడానికి Lap నొక్కండి.';

  @override
  String get startThenTapLap => 'Start చేసి, ప్రతి రౌండ్‌లో Lap నొక్కండి.';

  @override
  String get allowNotificationsForAlarm =>
      'అలారం మోగడానికి సెట్టింగ్‌లలో నోటిఫికేషన్‌లను ఆన్ చేయండి.';

  @override
  String get alarmRingsAt => 'అలారం మోగుతుంది';

  @override
  String get alarmWouldRingAt => 'అలారం మోగేది';

  @override
  String noEventToFollow(String event) {
    return 'ఇక్కడ ఇప్పుడు అనుసరించడానికి $event లేదు.';
  }

  @override
  String get alarmOnLabel => 'అలారం ఆన్';

  @override
  String get recalculatedDaily =>
      'సూర్యుడు కదులుతున్న కొద్దీ ప్రతిరోజూ మళ్ళీ లెక్కించబడుతుంది';

  @override
  String todayHereSunriseSunset(String rise, String set) {
    return 'ఇక్కడ ఈరోజు: సూర్యోదయం $rise · సూర్యాస్తమయం $set';
  }

  @override
  String get whenLabel => 'ఎప్పుడు';

  @override
  String get minutesLabel => 'నిమిషాలు';

  @override
  String get upTo1440 => '1440 వరకు';

  @override
  String get before => 'ముందు';

  @override
  String get after => 'తర్వాత';

  @override
  String get useMyLocation => 'నా స్థానాన్ని ఉపయోగించు';

  @override
  String get couldNotReadPosition => ' · మీ స్థానాన్ని చదవలేకపోయింది';

  @override
  String get timesUp => 'సమయం ముగిసింది 🙏';

  @override
  String sunsetAtTime(String time) {
    return 'సూర్యాస్తమయం $time వద్ద';
  }

  @override
  String cityInDays(int days) {
    return '$days రోజుల్లో';
  }

  @override
  String cityDaysAgo(int days) {
    return '$days రోజుల క్రితం';
  }

  @override
  String get citySameTime => 'మీలానే అదే సమయం';

  @override
  String cityAmountMinutes(int m) {
    return '$m ని';
  }

  @override
  String cityAmountHours(int h) {
    return '$h గం';
  }

  @override
  String cityAmountHoursMinutes(int h, int m) {
    return '$h గం $m ని';
  }

  @override
  String cityAheadOfYou(String amount) {
    return 'మీ కంటే $amount ముందు';
  }

  @override
  String cityBehindYou(String amount) {
    return 'మీ కంటే $amount వెనుక';
  }

  @override
  String get traditionHindu => 'హిందూ';

  @override
  String get traditionSikh => 'సిక్కు';

  @override
  String get traditionPlace => 'స్థలం ప్రకారం';

  @override
  String get todayLabelTithi => 'తిథి';

  @override
  String get todayLabelNakshatra => 'నక్షత్రం';

  @override
  String get todayLabelRahu => 'రాహు కాలం';

  @override
  String get todayLabelAbhijit => 'అభిజిత్ ముహూర్తం';

  @override
  String get todayLabelHukamnama => 'హుకమ్‌నామా';

  @override
  String get todayLabelNitnem => 'నిత్నేమ్ మిగిలింది';

  @override
  String get todayLabelGurpurab => 'తదుపరి గురుపర్వ్';

  @override
  String get todayLabelFestival => 'స్థానిక పండుగ';

  @override
  String get todayLabelWindow => 'శుభ సమయం';

  @override
  String get exampleTag => 'ఉదాహరణ';

  @override
  String get exampleNote =>
      'ఉదాహరణగా గుర్తించిన విలువలు ప్లేస్‌హోల్డర్‌లు: నిజమైన పంచాంగ డేటా తర్వాతి దశలో వస్తుంది.';

  @override
  String liveNote(String where) {
    return 'సూర్యోదయం మరియు సూర్యాస్తమయం మీ స్థానం కోసం లెక్కించబడ్డాయి. $where.';
  }

  @override
  String get greetingMorning => 'శుభోదయం';

  @override
  String get greetingAfternoon => 'శుభ మధ్యాహ్నం';

  @override
  String get greetingEvening => 'శుభ సాయంత్రం';

  @override
  String get greetingNight => 'శుభ రాత్రి';

  @override
  String get homeEmptyTitle => 'ఈరోజు మీ హోమ్ స్క్రీన్‌లో ఏమీ లేదు';

  @override
  String get homeEmptyBody =>
      'క్యాలెండర్‌లో ఒక తేదీని గుర్తించి, దీన్ని ఇక్కడ చూడటానికి \"మీ హోమ్ స్క్రీన్‌లో\" ఎంచుకోండి.';

  @override
  String get pinnedAllDay => 'రోజంతా పిన్ చేయబడింది';

  @override
  String get swipeToDismiss => 'ఈరోజు కోసం తీసివేయడానికి స్వైప్ చేయండి';

  @override
  String doneForToday(String title) {
    return 'ఈరోజు కోసం పూర్తయింది: $title';
  }

  @override
  String get undoAction => 'రద్దు చేయి';

  @override
  String get doneForTodayLabel => 'ఈరోజు కోసం పూర్తయింది';

  @override
  String get plansTitle => 'పాఠ్ & మంత్ర ప్రణాళికలు';

  @override
  String get addPlan => 'ప్రణాళికను జోడించు';

  @override
  String get dayStreak => 'రోజుల వరుస';

  @override
  String activePlanCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'సక్రియ ప్రణాళికలు',
      one: 'సక్రియ ప్రణాళిక',
    );
    return '$_temp0';
  }

  @override
  String get noPlansYet => 'ఇంకా ప్రణాళికలు లేవు';

  @override
  String get plansEmptyBody =>
      'ఒక పాఠ్ లేదా మంత్రం కోసం చాలా రోజులు కట్టుబడి ప్రతిరోజూ గుర్తించండి. వీటిలో ఒకదానితో ప్రారంభించండి, లేదా మీ సొంతదాన్ని జోడించండి.';

  @override
  String get planOptionsTooltip => 'ప్రణాళిక ఎంపికలు';

  @override
  String get deletePlanMenuItem => 'ప్రణాళికను తొలగించు';

  @override
  String get deletePlanQuestion => 'ప్రణాళికను తొలగించాలా?';

  @override
  String deletePlanBody(String title) {
    return '$title మరియు దాని పురోగతి తీసివేయబడతాయి.';
  }

  @override
  String titledDaysTag(String title, int days) {
    return '$title · $days రోజులు';
  }

  @override
  String completedOfDays(int completed, int total) {
    return 'పూర్తయింది · $total లో $completed రోజులు';
  }

  @override
  String ofDays(int completed, int total) {
    return '$total లో $completed రోజులు';
  }

  @override
  String get doneTodayButton => 'ఈరోజు పూర్తయింది';

  @override
  String get markTodayDone => 'ఈరోజు పూర్తయిందని గుర్తించు';

  @override
  String get newPlanTitle => 'కొత్త ప్రణాళిక';

  @override
  String get newPlanSubtitle =>
      'ఒక పాఠ్ లేదా మంత్రాన్ని ఎంచుకుని, మీరు దీన్ని ఎన్ని రోజులు కొనసాగిస్తారో ఎంచుకోండి.';

  @override
  String get paathOrMantraLabel => 'పాఠ్ లేదా మంత్రం';

  @override
  String get giveThePlanAName => 'ప్రణాళికకు ఒక పేరు పెట్టండి';

  @override
  String chooseDaysRange(int min, int max) {
    return '$min నుండి $max రోజులు ఎంచుకోండి';
  }

  @override
  String get forHowManyDays => 'ఎన్ని రోజుల కోసం?';

  @override
  String get daysFieldLabel => 'రోజులు';

  @override
  String get startPlanButton => 'ప్రణాళికను ప్రారంభించు';

  @override
  String get planKindPaath => 'పాఠ్';

  @override
  String get planKindMantra => 'మంత్రం';

  @override
  String get profileTitle => 'ప్రొఫైల్';

  @override
  String get sadhanaSettingsTitle => 'సాధన సెట్టింగ్‌లు';

  @override
  String get validEmailError =>
      'చెల్లుబాటు అయ్యే ఇమెయిల్ చిరునామాను నమోదు చేయండి';

  @override
  String nameTooLong(int max) {
    return 'దీన్ని $max అక్షరాల కంటే తక్కువగా ఉంచండి';
  }

  @override
  String get enterCurrentPassword => 'మీ ప్రస్తుత పాస్‌వర్డ్‌ను నమోదు చేయండి';

  @override
  String passwordTooShort(int min) {
    return 'కనీసం $min అక్షరాలను ఉపయోగించండి';
  }

  @override
  String get passwordAlreadyUsed =>
      'మీరు ఇంతకుముందు ఉపయోగించని పాస్‌వర్డ్‌ను ఎంచుకోండి';

  @override
  String get passwordsDontMatch => 'రెండు పాస్‌వర్డ్‌లు సరిపోలలేదు';

  @override
  String get changePasswordTitle => 'పాస్‌వర్డ్ మార్చు';

  @override
  String get accountsLaterNote =>
      'ఖాతాలు తర్వాతి దశలో వస్తాయి; అప్పటివరకు ఇది మీ ఎంట్రీలను మాత్రమే తనిఖీ చేస్తుంది, ఏమీ మార్చదు.';

  @override
  String get currentPasswordLabel => 'ప్రస్తుత పాస్‌వర్డ్';

  @override
  String get newPasswordLabel => 'కొత్త పాస్‌వర్డ్';

  @override
  String get confirmNewPasswordLabel => 'కొత్త పాస్‌వర్డ్‌ను నిర్ధారించండి';

  @override
  String get showPasswords => 'పాస్‌వర్డ్‌లను చూపించు';

  @override
  String get updatePasswordButton => 'పాస్‌వర్డ్‌ను అప్‌డేట్ చేయి';

  @override
  String get stepAddName => 'మీ పేరును జోడించండి';

  @override
  String get stepAddEmail => 'మీ ఇమెయిల్‌ను జోడించండి';

  @override
  String get stepPickTradition => 'హోమ్‌లో మీ సంప్రదాయాన్ని ఎంచుకోండి';

  @override
  String get stepTurnOnReminder => 'రోజువారీ రిమైండర్‌ను ఆన్ చేయండి';

  @override
  String get stepStartPlan => 'ఒక పాఠ్ లేదా మంత్ర ప్రణాళికను ప్రారంభించండి';

  @override
  String get profileCompletionTitle => 'ప్రొఫైల్ పూర్తి';

  @override
  String get profileCompleteReward =>
      'ప్రొఫైల్ పూర్తయింది! ప్రీమియం లాంచ్ అయినప్పుడు మీ ఉచిత ప్రీమియం బహుమతి వేచి ఉంటుంది.';

  @override
  String get reachRewardNote =>
      'లాంచ్ అయినప్పుడు ఉచిత ప్రీమియం పొందడానికి 100%కి చేరుకోండి.';

  @override
  String get aboutTitle => 'గురించి';

  @override
  String get appLabel => 'యాప్';

  @override
  String get websiteLabel => 'వెబ్‌సైట్';

  @override
  String get versionLabel => 'వెర్షన్';

  @override
  String get passwordWillWorkLater =>
      'ఖాతాలు జోడించిన తర్వాత పాస్‌వర్డ్ మార్పు పనిచేస్తుంది.';

  @override
  String get signedOut => 'సైన్ అవుట్ అయింది';

  @override
  String get notSignedInYet =>
      'మీరు ఇంకా సైన్ ఇన్ కాలేదు: ఖాతాలు తర్వాతి దశలో వస్తాయి. మీ డేటా ఈ పరికరంలోనే ఉంటుంది.';

  @override
  String get accountTitle => 'ఖాతా';

  @override
  String get signOutButton => 'సైన్ అవుట్ చేయి';

  @override
  String get backupSaved => 'బ్యాకప్ సేవ్ చేయబడింది';

  @override
  String get backupCancelled => 'బ్యాకప్ రద్దు చేయబడింది';

  @override
  String get couldNotSaveBackup =>
      'బ్యాకప్‌ను సేవ్ చేయలేకపోయింది. మళ్ళీ ప్రయత్నించండి.';

  @override
  String get backupNotSadho => 'ఆ ఫైల్ Sadho బ్యాకప్ కాదు.';

  @override
  String get couldNotReadFile => 'ఆ ఫైల్‌ను చదవలేకపోయింది.';

  @override
  String get backupDamaged => 'బ్యాకప్ ఫైల్ దెబ్బతిన్నది.';

  @override
  String get backupTooNew =>
      'ఈ బ్యాకప్ Sadho యొక్క కొత్త వెర్షన్ ద్వారా సృష్టించబడింది. ముందుగా యాప్‌ను అప్‌డేట్ చేయండి.';

  @override
  String get backupNoData => 'ఆ బ్యాకప్‌లో Sadho డేటా లేదు.';

  @override
  String get backupTooBig => 'ఆ ఫైల్ Sadho బ్యాకప్‌గా ఉండటానికి చాలా పెద్దది.';

  @override
  String madeOnSuffix(String date) {
    return ' $date న సృష్టించబడింది';
  }

  @override
  String restoreBackupBody(String made, int count) {
    return 'ఒక బ్యాకప్$made దీనిలో $count సేవ్ చేసిన అంశాలు ఉన్నాయి. ఇది ఈ ఫోన్‌లో ఉన్నదాన్ని భర్తీ చేస్తుంది: గుర్తులు, ప్రణాళికలు, మంత్రాలు, వాయిస్ శిక్షణ మరియు సెట్టింగ్‌లు.';
  }

  @override
  String get restoreThisBackup => 'ఈ బ్యాకప్‌ను పునరుద్ధరించాలా?';

  @override
  String get backupRestoredTitle => 'బ్యాకప్ పునరుద్ధరించబడింది';

  @override
  String get backupRestoredBody =>
      'Sadho మీ పునరుద్ధరించిన డేటాతో మళ్ళీ లోడ్ అవుతుంది.';

  @override
  String get backupRestoreTitle => 'బ్యాకప్ & పునరుద్ధరణ';

  @override
  String get backupExplain =>
      'మీ గుర్తులు, ప్రణాళికలు, మంత్రాలు, వాయిస్ శిక్షణ మరియు సెట్టింగ్‌లను మీరు ఎంచుకున్న ఫైల్‌లో సేవ్ చేయండి (Drive, Files, మీకే ఇమెయిల్ చేయండి). దీన్ని ఈ లేదా మరొక ఫోన్‌లో పునరుద్ధరించండి.';

  @override
  String get exportButton => 'ఎగుమతి';

  @override
  String get restoreButton => 'పునరుద్ధరించు';

  @override
  String get cloudSyncTitle => 'క్లౌడ్ సింక్';

  @override
  String get comingLater => 'తర్వాత వస్తుంది';

  @override
  String get saveBackupDialogTitle => 'మీ Sadho బ్యాకప్‌ను సేవ్ చేయండి';

  @override
  String get chooseBackupDialogTitle => 'ఒక Sadho బ్యాకప్‌ను ఎంచుకోండి';

  @override
  String get areYouSure => 'మీరు ఖచ్చితంగా ఉన్నారా?';

  @override
  String get deleteAccountWarning =>
      'ఇది మీ ఖాతాను మరియు ఈ ఫోన్‌లో సేవ్ చేసిన ప్రతిదాన్ని తొలగిస్తుంది: మీ ప్రొఫైల్, గుర్తులు, ప్రణాళికలు, మంత్రాలు, వాయిస్ శిక్షణ మరియు సెట్టింగ్‌లు. దీన్ని రద్దు చేయలేరు.';

  @override
  String get yesAction => 'అవును';

  @override
  String get noAction => 'కాదు';

  @override
  String get dangerZoneTitle => 'ప్రమాద జోన్';

  @override
  String get deleteAccountExplain =>
      'మీ ఖాతాను తొలగించడం వలన మీ ప్రొఫైల్ మరియు ఈ ఫోన్‌లో సేవ్ చేసిన ప్రతిదీ తుడిచిపెట్టుకుపోతుంది. మీకు అది తిరిగి కావాలంటే ముందుగా బ్యాకప్‌ను ఎగుమతి చేయండి.';

  @override
  String get deleteAccountButton => 'ఖాతాను తొలగించు';

  @override
  String get profileSaved => 'ప్రొఫైల్ సేవ్ చేయబడింది';

  @override
  String get yourDetailsTitle => 'మీ వివరాలు';

  @override
  String get nameLabel => 'పేరు';

  @override
  String get emailLabel => 'ఇమెయిల్';

  @override
  String get dailyReminderTitle => 'రోజువారీ రిమైండర్';

  @override
  String get dailySadhanaReminder => 'రోజువారీ సాధన రిమైండర్';

  @override
  String get reminderOff => 'ఆఫ్';

  @override
  String everyDayAt(String time) {
    return 'ప్రతిరోజూ $time వద్ద';
  }

  @override
  String get allowNotificationsForReminder =>
      'రిమైండర్ మోగడానికి సెట్టింగ్‌లలో నోటిఫికేషన్‌లను ఆన్ చేయండి.';

  @override
  String get timeLabel => 'సమయం';

  @override
  String get themeTitle => 'థీమ్';

  @override
  String get lightMode => 'లైట్';

  @override
  String get darkMode => 'డార్క్';

  @override
  String get systemMode => 'సిస్టమ్';

  @override
  String get coloursTitle => 'రంగులు';

  @override
  String paletteSemantic(String name) {
    return '$name రంగులు';
  }

  @override
  String get paletteMarigoldName => 'బంతి పువ్వు';

  @override
  String get paletteMarigoldBlurb => 'వెచ్చని కుంకుమపువ్వు మరియు లోతైన నీలం';

  @override
  String get paletteSandalwoodName => 'గంధం';

  @override
  String get paletteSandalwoodBlurb => 'మృదువైన గంధం గోధుమ మరియు మట్టి';

  @override
  String get paletteTulsiName => 'తులసి ఆకుపచ్చ';

  @override
  String get paletteTulsiBlurb => 'ప్రశాంతమైన పవిత్ర-తులసి ఆకుపచ్చ';

  @override
  String get paletteTwilightName => 'సంధ్యా నీలం';

  @override
  String get paletteTwilightBlurb => 'దీపం-కాంతి బంగారంతో సంధ్యా నీలం';

  @override
  String get paletteLotusName => 'పద్మం గులాబీ';

  @override
  String get paletteLotusBlurb => 'సున్నితమైన పద్మం గులాబీ మరియు ఆకు ఆకుపచ్చ';

  @override
  String get sadhanaTimeNotifTitle => '🪔 మీ సాధన సమయం';

  @override
  String get sadhanaTimeNotifBody =>
      'మీ పాఠ్ లేదా మంత్రం కోసం కొన్ని నిశ్శబ్ద నిమిషాలు తీసుకోండి 🙏';

  @override
  String get comingSoon => 'త్వరలో వస్తుంది';

  @override
  String get trainAction => 'శిక్షణ ఇవ్వండి';

  @override
  String get onboardingTitle => 'Sadhoకు స్వాగతం';

  @override
  String get onboardingSubtitle =>
      'ప్రారంభించడానికి మీ భాష మరియు సంప్రదాయాన్ని ఎంచుకోండి. మీరు రెండింటినీ తర్వాత ప్రొఫైల్‌లో మార్చుకోవచ్చు.';

  @override
  String get traditionHeading => 'సంప్రదాయం';

  @override
  String get continueAction => 'కొనసాగించు';
}
