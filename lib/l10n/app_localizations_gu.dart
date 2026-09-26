// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get navHome => 'હોમ';

  @override
  String get navSadhana => 'સાધના';

  @override
  String get navCalendar => 'કેલેન્ડર';

  @override
  String get navClock => 'ઘડિયાળ';

  @override
  String get tooltipLanguage => 'ભાષા';

  @override
  String get tooltipProfile => 'પ્રોફાઇલ';

  @override
  String get tooltipSwitchToLight => 'લાઇટ થીમ પર જાઓ';

  @override
  String get tooltipSwitchToDark => 'ડાર્ક થીમ પર જાઓ';

  @override
  String get languageSheetTitle => 'ભાષા';

  @override
  String get languageSheetSubtitle =>
      'તમારી પસંદગી સાચવવામાં આવે છે અને તરત જ લાગુ થાય છે.';

  @override
  String get actionCancel => 'રદ કરો';

  @override
  String get actionDelete => 'કાઢી નાખો';

  @override
  String get actionSave => 'સાચવો';

  @override
  String get actionReset => 'રીસેટ કરો';

  @override
  String get actionEdit => 'સંપાદિત કરો';

  @override
  String get actionOk => 'બરાબર';

  @override
  String get unitSeconds => 'સેકન્ડ';

  @override
  String get unitMinutes => 'મિનિટ';

  @override
  String get unitHours => 'કલાક';

  @override
  String get paceErrorEmpty => 'ગતિ દાખલ કરો.';

  @override
  String get paceErrorNotNumber => 'આ સંખ્યા નથી.';

  @override
  String paceErrorTooFast(String min) {
    return 'ખૂબ ઝડપી. લઘુત્તમ $min છે.';
  }

  @override
  String paceErrorTooSlow(String max) {
    return 'ખૂબ ધીમું. મહત્તમ $max છે.';
  }

  @override
  String get modeTap => 'ટેપ';

  @override
  String get modeRhythm => 'રિધમ';

  @override
  String get modeVoice => 'અવાજ';

  @override
  String get modeMala => 'માળા';

  @override
  String get ringtoneTempleBell => 'મંદિરની ઘંટડી';

  @override
  String get ringtoneSingingBowl => 'સિંગિંગ બાઉલ';

  @override
  String get ringtoneSoftChime => 'હળવો રણકાર';

  @override
  String get ringtoneDeepGong => 'ઊંડો ગોંગ';

  @override
  String get msgVoiceUnsupported =>
      'અવાજ ગણતરી ફક્ત Android અને iOS પર કામ કરે છે';

  @override
  String get msgVoiceNoMic => 'આ ડિવાઇસ પર કોઈ માઇક્રોફોન ઉપલબ્ધ નથી';

  @override
  String get msgMalaUnsupported =>
      'વોલ્યુમ-કી ગણતરી માટે વાસ્તવિક ડિવાઇસ જરૂરી છે';

  @override
  String trainFirstPrompt(int min, int max) {
    return 'પહેલા આ મંત્ર માટે તમારો અવાજ તાલીમ આપો: તેને $min થી $max વખત રેકોર્ડ કરો.';
  }

  @override
  String get fallbackVoiceDenied =>
      'માઇક્રોફોન પરવાનગી નકારવામાં આવી, તેથી અવાજ ગણતરી સાંભળી શકતી નથી. ટેપ મોડનો ઉપયોગ કરી રહ્યા છીએ.';

  @override
  String get fallbackVoiceBlocked =>
      'માઇક્રોફોન ઍક્સેસ અવરોધિત છે. અવાજ ગણતરીનો ઉપયોગ કરવા સેટિંગ્સમાં પરવાનગી આપો. ટેપ મોડનો ઉપયોગ કરી રહ્યા છીએ.';

  @override
  String get fallbackVoiceUnsupported =>
      'અવાજ ગણતરી ફક્ત Android અને iOS પર કામ કરે છે. ટેપ મોડનો ઉપયોગ કરી રહ્યા છીએ.';

  @override
  String get fallbackVoiceNoMic =>
      'આ ડિવાઇસ પર કોઈ માઇક્રોફોન ઉપલબ્ધ નથી. ટેપ મોડનો ઉપયોગ કરી રહ્યા છીએ.';

  @override
  String get fallbackMalaUnsupported =>
      'વોલ્યુમ-કી ગણતરી માટે વાસ્તવિક ડિવાઇસ જરૂરી છે. ટેપ મોડનો ઉપયોગ કરી રહ્યા છીએ.';

  @override
  String get sadhanaRingTitle => '🔔 સાધનાનો સમય પૂરો થયો';

  @override
  String get sadhanaRingBody => 'તમારા સત્રનો સમય પૂરો થયો છે 🙏';

  @override
  String get voiceTooShort => 'આ ખૂબ ટૂંકું હતું. આખો મંત્ર બોલો.';

  @override
  String get voiceRanTooLong =>
      'આ ખૂબ લાંબું ચાલ્યું. મંત્ર એક વાર બોલો, પછી અટકો.';

  @override
  String get voiceSoundedDifferent =>
      'આ બીજાઓથી અલગ સંભળાયું. તે જ રીતે ફરીથી બોલો.';

  @override
  String get voiceGotIt => 'સમજાઈ ગયું. ફરીથી બોલો.';

  @override
  String get voiceDeniedShort =>
      'માઇક્રોફોન પરવાનગી નકારવામાં આવી, તેથી અવાજ ગણતરી સાંભળી શકતી નથી.';

  @override
  String get voiceBlockedShort =>
      'માઇક્રોફોન ઍક્સેસ અવરોધિત છે. અવાજ ગણતરીનો ઉપયોગ કરવા સેટિંગ્સમાં પરવાનગી આપો.';

  @override
  String get voiceAccessLost =>
      'માઇક્રોફોન ઍક્સેસ ગુમાવ્યો, તેથી અવાજ ગણતરી બંધ થઈ.';

  @override
  String get voiceCouldNotRestart =>
      'માઇક્રોફોન ફરી શરૂ થઈ શક્યો નહીં, તેથી અવાજ ગણતરી બંધ થઈ.';

  @override
  String get mantraLibraryTitle => 'મંત્ર લાઇબ્રેરી';

  @override
  String get addMantra => 'મંત્ર ઉમેરો';

  @override
  String get searchHint => 'શીર્ષક, લિપિ અથવા પરંપરા શોધો';

  @override
  String noMantrasMatch(String query) {
    return '“$query” સાથે કોઈ મંત્ર મેળ ખાતો નથી.\nતમારો પોતાનો બનાવવા “મંત્ર ઉમેરો” ટેપ કરો.';
  }

  @override
  String mantraAdded(String title) {
    return '“$title” ઉમેરાયું';
  }

  @override
  String mantraSaved(String title) {
    return '“$title” સાચવ્યું';
  }

  @override
  String mantraRestored(String title) {
    return '“$title” તેના મૂળભૂત પર પુનઃસ્થાપિત';
  }

  @override
  String get deleteMantraTitle => 'મંત્ર કાઢી નાખવો?';

  @override
  String deleteMantraBody(String title) {
    return '“$title” તમારી લાઇબ્રેરીમાંથી દૂર કરવામાં આવશે.';
  }

  @override
  String get retrainVoiceTooltip => 'અવાજ ફરીથી તાલીમ આપો';

  @override
  String get trainVoice => 'અવાજ તાલીમ આપો';

  @override
  String mantraCountTag(int count) {
    return '$count ગણતરી';
  }

  @override
  String get editedTag => 'સંપાદિત';

  @override
  String get editMantra => 'મંત્ર સંપાદિત કરો';

  @override
  String get addAMantra => 'એક મંત્ર ઉમેરો';

  @override
  String get titleLabel => 'શીર્ષક *';

  @override
  String get titleRequired => 'શીર્ષક દાખલ કરો';

  @override
  String get scriptTextLabel => 'લિપિ ટેક્સ્ટ';

  @override
  String get transliterationLabel => 'લિવ્યંતરણ';

  @override
  String get traditionLabel => 'પરંપરા / ભાષા';

  @override
  String get traditionHint => 'દા.ત. સંસ્કૃત · હિંદુ';

  @override
  String get defaultCountLabel => 'મૂળભૂત ગણતરી *';

  @override
  String get enterNumberOneOrMore => '1 અથવા વધુ સંખ્યા દાખલ કરો';

  @override
  String get tooLarge => 'આ ખૂબ મોટું છે';

  @override
  String get saveChanges => 'ફેરફારો સાચવો';

  @override
  String get saveToLibrary => 'લાઇબ્રેરીમાં સાચવો';

  @override
  String get resetToDefaultButton => 'મૂળભૂત પર રીસેટ કરો';

  @override
  String get resetToDefaultTitle => 'મૂળભૂત પર રીસેટ કરવું છે?';

  @override
  String resetToDefaultBody(String title) {
    return '“$title” માંના તમારા ફેરફારો કાઢી નાખવામાં આવશે અને મૂળ ટેક્સ્ટ પુનઃસ્થાપિત થશે.';
  }

  @override
  String switchToMantra(String title) {
    return '$title પર સ્વિચ કરવું છે?';
  }

  @override
  String get switchMantraBody => 'તમારી હાલની ગણતરી રીસેટ થશે.';

  @override
  String get keepCurrent => 'હાલનું રાખો';

  @override
  String get switchAction => 'સ્વિચ કરો';

  @override
  String get smallerMantraText => 'નાનો મંત્ર ટેક્સ્ટ';

  @override
  String get largerMantraText => 'મોટો મંત્ર ટેક્સ્ટ';

  @override
  String get libraryButton => 'લાઇબ્રેરી';

  @override
  String get trainYourOwnMantra => 'તમારો પોતાનો મંત્ર તાલીમ આપો';

  @override
  String voiceCountingFrom(String title, int count) {
    return 'તમારા $count રેકોર્ડિંગમાંથી “$title” ગણવામાં આવે છે. અન્ય અવાજો અને શબ્દો અવગણવામાં આવે છે.';
  }

  @override
  String voiceCountsOnlyTrained(String title, int min, int max) {
    return 'અવાજ ફક્ત તમે તાલીમ આપેલા મંત્રને ગણે છે. શરૂ કરવા “$title” $min થી $max વખત રેકોર્ડ કરો.';
  }

  @override
  String get addMoreSamples => 'વધુ નમૂના ઉમેરો';

  @override
  String get retrain => 'ફરીથી તાલીમ આપો';

  @override
  String get clearTraining => 'તાલીમ સાફ કરો';

  @override
  String get voiceBetaNote =>
      'બીટા: આ ડિવાઇસ પર અને ઑફલાઇન કામ કરે છે. વધુ રેકોર્ડિંગથી ચોકસાઈ વધે છે અને ઘોંઘાટવાળા રૂમમાં ઘટે છે. પુનરાવર્તનો વચ્ચે થોડું અટકો. અહીં ફક્ત તમારો અવાજ ગણાય છે; + અને − બટન ગણતરી સુધારે છે.';

  @override
  String get trainVoiceFirstTitle => 'પહેલા તમારો અવાજ તાલીમ આપો';

  @override
  String trainVoiceFirstBody(String title, int min, int max) {
    return 'અવાજ ફક્ત તમે તાલીમ આપેલા મંત્રને ગણે છે. “$title” $min થી $max વખત (લગભગ એક મિનિટ) રેકોર્ડ કરો. તે આ ડિવાઇસ પર જ રહે છે અને ઑફલાઇન કામ કરે છે.';
  }

  @override
  String get later => 'પછી';

  @override
  String get trainNow => 'હવે તાલીમ આપો';

  @override
  String get betaLabel => 'બીટા';

  @override
  String get voiceTrained => 'અવાજ તાલીમ પામેલ';

  @override
  String get voiceNotTrained => 'અવાજ તાલીમ પામેલ નથી';

  @override
  String get sensitivityLabel => 'સંવેદનશીલતા';

  @override
  String get sensitivityStrict => 'કડક';

  @override
  String get sensitivityLenient => 'હળવું';

  @override
  String get sensitivityMedium => 'મધ્યમ';

  @override
  String get clearVoiceTrainingTitle => 'અવાજ તાલીમ સાફ કરવી છે?';

  @override
  String clearVoiceTrainingBody(String title) {
    return 'તમે તેને ફરીથી તાલીમ ન આપો ત્યાં સુધી અવાજ “$title” ગણવાનું બંધ કરશે.';
  }

  @override
  String get completionTitle => 'પૂર્ણતા';

  @override
  String get vibrationLabel => 'કંપન';

  @override
  String vibrationSubtitle(int n) {
    return 'દર $n ગણતરીએ એક બઝ, અને લક્ષ્ય પર વધુ મજબૂત.';
  }

  @override
  String intensityLevel(int level) {
    return 'તીવ્રતા: સ્તર $level માંથી 5';
  }

  @override
  String get testMilestone => 'ટેસ્ટ માઇલસ્ટોન';

  @override
  String get testTarget => 'ટેસ્ટ લક્ષ્ય';

  @override
  String get ringtoneLabel => 'રિંગટોન';

  @override
  String get ringtoneSubtitle => 'લક્ષ્ય પર પહોંચતા એક અવાજ વાગે છે.';

  @override
  String get playSound => 'અવાજ વગાડો';

  @override
  String get combined => 'સંયુક્ત';

  @override
  String get combinedTooltip => 'ચારેય મોડ એક શેર કરેલી ગણતરીમાં ઉમેરાય છે';

  @override
  String get separate => 'અલગ';

  @override
  String get separateTooltip => 'દરેક મોડ પોતાની ગણતરી રાખે છે';

  @override
  String get countModeSemantic => 'ગણતરી મોડ';

  @override
  String get combinedExplain =>
      'ટેપ, અવાજ, રિધમ અને માળા બધા એક લક્ષ્ય તરફ એક શેર કરેલી ગણતરીમાં ઉમેરાય છે.';

  @override
  String get separateExplain =>
      'દરેક મોડ પોતાની ગણતરી અને લક્ષ્ય તરફ પોતાની પ્રગતિ રાખે છે. રીસેટ અને પૂર્ણતા ફક્ત તમે જે મોડમાં છો તેને જ લાગુ પડે છે.';

  @override
  String countedLabel(int count) {
    return '$count ગણાયું';
  }

  @override
  String ofTarget(int count) {
    return '$count માંથી';
  }

  @override
  String get removeOneTooltip => 'એક દૂર કરો';

  @override
  String get undoLabel => 'પૂર્વવત્ કરો';

  @override
  String get countLabel => 'ગણતરી';

  @override
  String get addOneTooltip => 'એક ઉમેરો';

  @override
  String get focusLabel => 'ફોકસ';

  @override
  String get focusModeTooltip => 'ફોકસ મોડ';

  @override
  String get pause => 'થોભાવો';

  @override
  String get resume => 'ફરી શરૂ કરો';

  @override
  String get start => 'શરૂ કરો';

  @override
  String targetReachedSeparate(String mode) {
    return '$mode માં લક્ષ્ય પૂર્ણ થયું 🙏  આ મોડ રીસેટ કરો, મોડ બદલો, અથવા લક્ષ્ય વધારો.';
  }

  @override
  String get targetReachedCombined =>
      'લક્ષ્ય પૂર્ણ થયું 🙏  રીસેટ કરો, અથવા લક્ષ્ય વધારો.';

  @override
  String resetModeCountTitle(String mode) {
    return '$mode ગણતરી રીસેટ કરવી છે?';
  }

  @override
  String get resetSessionTitle => 'આ સત્ર રીસેટ કરવું છે?';

  @override
  String resetModeCountBody(String mode, int count) {
    return 'તમારી $mode ગણતરી $count શૂન્ય પર પાછી આવશે. અન્ય મોડ પોતાની ગણતરી રાખે છે.';
  }

  @override
  String resetSessionBody(int count) {
    return 'તમારી $count ગણતરી શૂન્ય પર પાછી આવશે.';
  }

  @override
  String get modeHelpTap =>
      'રિંગ પર ટેપ કરો, અથવા ફોકસ મોડમાં ગમે ત્યાં. ફક્ત ટેપ મોડ સ્ક્રીન ટેપ ગણે છે.';

  @override
  String get modeHelpRhythm =>
      'Start દબાવો અને ગણતરી નીચે આપેલી ગતિએ આપમેળે વધે છે.';

  @override
  String get modeHelpVoice =>
      'Start દબાવો, પછી તમારો તાલીમ પામેલ મંત્ર જપો. દર વખતે ઓળખાય ત્યારે તે તરત એક ગણતરી ઉમેરે છે; અન્ય અવાજો અવગણવામાં આવે છે. માઇક્રોફોન જરૂરી; શાંત રૂમમાં શ્રેષ્ઠ કામ કરે છે.';

  @override
  String get modeHelpMala =>
      'Start દબાવો, પછી ગણવા માટે કોઈપણ વોલ્યુમ બટન દબાવો. આંખો બંધ હોય અથવા ફોન ખિસ્સામાં હોય ત્યારે અનુકૂળ. સ્ક્રીન ચાલુ રહેવી જોઈએ.';

  @override
  String get countingModeLabel => 'ગણતરી મોડ';

  @override
  String pacePrefix(String pace) {
    return 'ગતિ: ગણતરી $pace';
  }

  @override
  String modeSemanticLabel(String mode) {
    return '$mode મોડ';
  }

  @override
  String get tapAnywhereToCount => 'ગણવા માટે ગમે ત્યાં ટેપ કરો';

  @override
  String countingPace(String pace) {
    return 'ગણતરી $pace';
  }

  @override
  String pausedPace(String pace) {
    return 'થોભાયેલ · $pace';
  }

  @override
  String get listening => 'સાંભળી રહ્યું છે…';

  @override
  String get startingMicrophone =>
      'માઇક્રોફોન શરૂ થઈ રહ્યું છે… પૂછવામાં આવે તો ઍક્સેસ આપો';

  @override
  String get notTrainedYet =>
      'હજુ તાલીમ પામેલ નથી · અવાજ વાપરવા મંત્ર તાલીમ આપો';

  @override
  String get pausedPressStartListen => 'થોભાયેલ · સાંભળવા Start દબાવો';

  @override
  String get pressVolumeKeys => 'ગણવા વોલ્યુમ કી દબાવો';

  @override
  String get capturingVolumeKeys => 'વોલ્યુમ કી કેપ્ચર કરી રહ્યું છે…';

  @override
  String get pausedPressStartVolume =>
      'થોભાયેલ · વોલ્યુમ કી વાપરવા Start દબાવો';

  @override
  String modeTitleLine(String mode, String own) {
    String _temp0 = intl.Intl.selectLogic(own, {
      'yes': ' · પોતાની ગણતરી',
      'other': '',
    });
    return '$mode મોડ$_temp0';
  }

  @override
  String voiceCountedMatch(int percent) {
    return 'ગણાયું · $percent% મેળ';
  }

  @override
  String voiceIgnoredMatch(int percent) {
    return 'અવગણાયું · $percent% મેળ (તમારો મંત્ર નથી)';
  }

  @override
  String get paceFieldLabel => 'ગતિ';

  @override
  String paceHelpOk(String pace, String range) {
    return '$pace ગણે છે. (મંજૂર: $range)';
  }

  @override
  String paceHelpError(String error, String pace) {
    return '$error હજુ પણ $pace ગણી રહ્યું છે.';
  }

  @override
  String get sankalpLabel => 'સંકલ્પ';

  @override
  String get sankalpHint => 'આ અભ્યાસ માટે તમારો સંકલ્પ જણાવો…';

  @override
  String get targetSectionTitle => 'લક્ષ્ય';

  @override
  String get byCount => 'ગણતરી પ્રમાણે';

  @override
  String get byTime => 'સમય પ્રમાણે';

  @override
  String customWithValue(String value) {
    return 'કસ્ટમ · $value';
  }

  @override
  String get custom => 'કસ્ટમ';

  @override
  String get enterNumberRange => '1 થી 9,999,999 સુધીની સંખ્યા દાખલ કરો';

  @override
  String get customCountTitle => 'કસ્ટમ ગણતરી';

  @override
  String get targetCountLabel => 'લક્ષ્ય ગણતરી';

  @override
  String get setAction => 'સેટ કરો';

  @override
  String get durationLabel => 'સમયગાળો';

  @override
  String get enterDuration => '1 અથવા વધુનો સમયગાળો દાખલ કરો.';

  @override
  String get maxDurationCapped =>
      'મહત્તમ 99 ક 59 મિ 59 સે છે — તેને મર્યાદિત કરવામાં આવશે.';

  @override
  String sessionLasts(String duration) {
    return 'સત્ર $duration સુધી ચાલે છે.';
  }

  @override
  String get targetReachedFocus => 'લક્ષ્ય પૂર્ણ થયું 🙏';

  @override
  String screenTapsDoNotCount(String mode) {
    return '$mode મોડમાં સ્ક્રીન ટેપ ગણાતા નથી. સુધારવા + અથવા − વાપરો.';
  }

  @override
  String holdFingersToExit(int fingers, int seconds) {
    return 'બહાર નીકળવા $fingers આંગળીઓ $seconds સેકન્ડ દબાવી રાખો';
  }

  @override
  String get holdToExitFocusMode => 'ફોકસ મોડમાંથી બહાર નીકળવા દબાવી રાખો';

  @override
  String get holdToExit => 'બહાર નીકળવા દબાવી રાખો';

  @override
  String get keepHoldingToExit => 'બહાર નીકળવા દબાવી રાખો…';

  @override
  String addedRecordingsTo(int added, String title, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'રેકોર્ડિંગ્સ',
      one: 'રેકોર્ડિંગ',
    );
    return '“$title” માં $added $_temp0 ઉમેરાયા (કુલ $total)';
  }

  @override
  String voiceTrainedFor(String title, int count) {
    return '“$title” માટે અવાજ તાલીમ પામેલ ($count રેકોર્ડિંગ્સ)';
  }

  @override
  String trainedRecordingsCount(int count) {
    return 'તાલીમ પામેલ · $count રેકોર્ડિંગ્સ';
  }

  @override
  String get tooFewRecordings =>
      'ગણવા માટે ખૂબ ઓછા રેકોર્ડિંગ્સ. વધુ ઉમેરો, અથવા ફરીથી તાલીમ આપો.';

  @override
  String canCountAddMore(int room) {
    return 'અવાજ આ મંત્રને ગણી શકે છે. ચોકસાઈ સુધારવા નવેસરથી શરૂ કર્યા વિના $room વધુ રેકોર્ડિંગ્સ ઉમેરો.';
  }

  @override
  String canCountAtMax(int max) {
    return 'અવાજ આ મંત્રને ગણી શકે છે. તમારી પાસે મહત્તમ $max રેકોર્ડિંગ્સ છે; તેમને બદલવા ફરીથી તાલીમ આપો.';
  }

  @override
  String get pausedHeadline => 'થોભાયેલ';

  @override
  String pausedSub(int recorded) {
    return '$recorded રેકોર્ડ કરાયા. ચાલુ રાખો, અથવા જે છે તે સાચવો.';
  }

  @override
  String recordInstructions(int min, int max, int recommended) {
    return 'તમારી સામાન્ય જાપ ગતિએ તેને $min થી $max વખત રેકોર્ડ કરો ($recommended સારી સંખ્યા છે). પછી અવાજ ફક્ત તમારો મંત્ર ગણશે.';
  }

  @override
  String get openingMicrophone => 'માઇક્રોફોન ખોલવામાં આવી રહ્યું છે…';

  @override
  String get stayQuiet => 'એક ક્ષણ શાંત રહો…';

  @override
  String get listeningToRoom =>
      'પૃષ્ઠભૂમિ અવાજ ગણાય નહીં તે માટે રૂમ સાંભળવામાં આવે છે.';

  @override
  String get sayYourMantra => 'તમારો મંત્ર બોલો…';

  @override
  String recordingXofY(int current, int max) {
    return '$current રેકોર્ડ થઈ રહ્યું છે, મહત્તમ $max માંથી';
  }

  @override
  String allRecordingsCaptured(int count) {
    return 'બધા $count રેકોર્ડિંગ્સ કેપ્ચર થયા';
  }

  @override
  String get saveToStartCounting => 'અવાજથી ગણતરી શરૂ કરવા તેમને સાચવો.';

  @override
  String get cannotUseMicrophone => 'માઇક્રોફોનનો ઉપયોગ કરી શકાતો નથી';

  @override
  String get canSaveNowHint =>
      'તમે અત્યારે સાચવી શકો છો, અથવા વધુ ચોકસાઈ માટે ચાલુ રાખી શકો છો.';

  @override
  String minAreEnough(int min) {
    return 'શરૂ કરવા $min પૂરતા છે.';
  }

  @override
  String addingToSaved(int count) {
    return 'તમારા $count સાચવેલા રેકોર્ડિંગ્સમાં ઉમેરાઈ રહ્યું છે.';
  }

  @override
  String get tryAgain => 'ફરી પ્રયાસ કરો';

  @override
  String get startRecording => 'રેકોર્ડિંગ શરૂ કરો';

  @override
  String get openSettingsAction => 'સેટિંગ્સ ખોલો';

  @override
  String saveNRecordings(int count) {
    return '$count રેકોર્ડિંગ્સ સાચવો';
  }

  @override
  String recordMoreToSave(int n) {
    return 'સાચવવા $n વધુ રેકોર્ડ કરો';
  }

  @override
  String get recordSampleToSave => 'સાચવવા એક નમૂનો રેકોર્ડ કરો';

  @override
  String get undoLast => 'છેલ્લું પૂર્વવત્ કરો';

  @override
  String get stop => 'રોકો';

  @override
  String get continueRecording => 'રેકોર્ડિંગ ચાલુ રાખો';

  @override
  String get startOver => 'ફરીથી શરૂ કરો';

  @override
  String recordedOfMax(int recorded, int max) {
    return '$recorded રેકોર્ડ થયા, મહત્તમ $max માંથી';
  }

  @override
  String voiceBetaNoteTraining(int max) {
    return 'બીટા. બધું આ ડિવાઇસ પર, ઑફલાઇન થાય છે: ફક્ત અવાજનું વર્ણન કરતી સંખ્યાઓ સાચવવામાં આવે છે, ક્યારેય ઑડિયો નહીં. વધુ રેકોર્ડિંગ્સ ગણતરીને વધુ સચોટ બનાવે છે (મહત્તમ $max સુધી); ઘોંઘાટવાળો રૂમ તેને ઓછું સચોટ બનાવે છે. મંત્ર એક વાર બોલો, પછી આગલા પહેલાં થોડું અટકો.';
  }

  @override
  String get actionClear => 'સાફ કરો';

  @override
  String get today => 'આજે';

  @override
  String get previousMonth => 'પાછલો મહિનો';

  @override
  String get nextMonth => 'આગલો મહિનો';

  @override
  String get markTypeGood => 'સારું';

  @override
  String get markTypeCautious => 'સાવચેત';

  @override
  String get markTypeNeutral => 'તટસ્થ';

  @override
  String get reminderModeNone => 'કોઈ સમય નથી';

  @override
  String get reminderModeOnce => 'એક વાર';

  @override
  String get reminderModeSeveral => 'ઘણી વખત';

  @override
  String get repeatRuleOnce => 'એક વાર';

  @override
  String get repeatRuleDaily => 'દૈનિક';

  @override
  String get repeatRuleWeekly => 'સાપ્તાહિક';

  @override
  String get repeatRuleMonthly => 'માસિક';

  @override
  String get repeatRuleQuarterly => 'ત્રિમાસિક';

  @override
  String get repeatRuleHalfYearly => 'અર્ધ-વાર્ષિક';

  @override
  String get repeatRuleYearly => 'વાર્ષિક';

  @override
  String get homeModeNone => 'બતાવશો નહીં';

  @override
  String get homeModeMorning => 'સવારે એક વાર';

  @override
  String get homeModeAllDay => 'આખો દિવસ રાખો';

  @override
  String get markStyleDot => 'બિંદુ';

  @override
  String get markStyleFilled => 'ભરેલું';

  @override
  String get markStyleHighlight => 'હાઇલાઇટ';

  @override
  String get markStyleCircle => 'વર્તુળ';

  @override
  String get markStyleSquare => 'ચોરસ';

  @override
  String get emojiOm => 'ॐ';

  @override
  String get emojiKhanda => 'ખંડા';

  @override
  String get emojiMala => 'માળા';

  @override
  String get emojiDiya => 'દીવો';

  @override
  String get emojiBell => 'ઘંટડી';

  @override
  String get emojiSunrise => 'સૂર્યોદય';

  @override
  String get emojiStar => 'તારો';

  @override
  String get emojiSparkle => 'ચમક';

  @override
  String get emojiMoney => 'પૈસા';

  @override
  String get emojiHandshake => 'હાથ મિલાવવો';

  @override
  String get emojiAvoid => 'ટાળો';

  @override
  String get emojiDone => 'પૂર્ણ';

  @override
  String get markTitleGood => 'સારો દિવસ';

  @override
  String get markTitleCautious => 'સાવચેત દિવસ';

  @override
  String get markTitleNeutral => 'તટસ્થ દિવસ';

  @override
  String get reminderBodyGood => 'એક સારો દિવસ.';

  @override
  String get reminderBodyCautious => 'આજે સાવચેત રહો.';

  @override
  String get reminderBodyNeutral => 'તમારા કેલેન્ડરમાં ચિહ્નિત.';

  @override
  String get channelCalendarRemindersName => 'કેલેન્ડર રિમાઇન્ડર';

  @override
  String get channelCalendarRemindersDesc =>
      'તમે Sadho માં ચિહ્નિત કરેલી તારીખો માટે રિમાઇન્ડર';

  @override
  String get channelAlarmsName => 'એલાર્મ અને ટાઇમર';

  @override
  String get channelAlarmsDesc => 'સૂર્ય-આધારિત એલાર્મ અને પૂર્ણ થયેલા ટાઇમર';

  @override
  String get repeatSummaryOnce => 'એક વાર';

  @override
  String get repeatSummaryDaily => 'દરરોજ';

  @override
  String get repeatSummaryWeekly => 'દર અઠવાડિયે';

  @override
  String get repeatSummaryMonthly => 'દર મહિને';

  @override
  String get repeatSummaryQuarterly => 'દર 3 મહિને';

  @override
  String get repeatSummaryHalfYearly => 'દર 6 મહિને';

  @override
  String get repeatSummaryYearly => 'દર વર્ષે';

  @override
  String reminderSummaryAt(String times) {
    return '$times વાગ્યે યાદ કરાવો';
  }

  @override
  String homeSummaryFrom(String time) {
    return 'હોમ પર $time થી';
  }

  @override
  String get homeSummaryAllDay => 'હોમ પર આખો દિવસ';

  @override
  String marksInMonth(String month) {
    return '$month માં નિશાન';
  }

  @override
  String noMarksInMonth(String month) {
    return '$month માં કંઈ ચિહ્નિત નથી. નિશાન ઉમેરવા તારીખ પર ટેપ કરો.';
  }

  @override
  String get markStyleSectionTitle => 'નિશાન શૈલી';

  @override
  String get markStyleSectionHint =>
      'ચિહ્નિત તારીખો કેવી દેખાય છે. દરેક નિશાનને લાગુ પડે છે.';

  @override
  String markStyleSemantic(String style) {
    return '$style નિશાન શૈલી';
  }

  @override
  String get dayCellToday => ', આજે';

  @override
  String get dayCellAnd => 'અને';

  @override
  String dayCellMarkedSuffix(int count, String kinds) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ', $kinds ચિહ્નિત, $count નિશાન',
      one: ', $kinds ચિહ્નિત, 1 નિશાન',
    );
    return '$_temp0';
  }

  @override
  String get markEditorNoTimeWarning =>
      'ઓછામાં ઓછો એક સમય ઉમેરો, અથવા \"કોઈ સમય નથી\" પસંદ કરો.';

  @override
  String get notificationsOffWarning =>
      'Sadho માટે સૂચનાઓ બંધ છે, તેથી આ રિમાઇન્ડર વાગશે નહીં. તમારા ફોનની સેટિંગ્સમાં તેમને ચાલુ કરો.';

  @override
  String get deleteMarkFallbackTitle => 'આ નિશાન';

  @override
  String get deleteMarkQuestion => 'આ નિશાન કાઢી નાખવું છે?';

  @override
  String deleteMarkRepeatsBody(String title) {
    return '$title અને તેના બધા પુનરાવર્તનો કાઢી નાખવા છે? તેના રિમાઇન્ડર પણ દૂર થશે.';
  }

  @override
  String deleteMarkBody(String title) {
    return '$title કાઢી નાખવું છે? તેના રિમાઇન્ડર પણ દૂર થશે.';
  }

  @override
  String get newMark => 'નવું નિશાન';

  @override
  String get editMark => 'નિશાન સંપાદિત કરો';

  @override
  String repeatFromNotice(String repeatSummary, String date) {
    return '$repeatSummary, $date થી. ફેરફારો દરેક પુનરાવર્તનને લાગુ પડે છે.';
  }

  @override
  String get markTypeSectionTitle => 'નિશાન પ્રકાર';

  @override
  String get iconSectionTitle => 'આઇકોન';

  @override
  String get iconNone => 'કોઈ નહીં';

  @override
  String get labelFieldLabel => 'લેબલ';

  @override
  String get detailsFieldLabel => 'વિગતો / નોંધ';

  @override
  String get remindMeAtSectionTitle => 'મને યાદ કરાવો';

  @override
  String removeTimeTooltip(String time) {
    return '$time દૂર કરો';
  }

  @override
  String get addTime => 'સમય ઉમેરો';

  @override
  String get repeatSectionTitle => 'પુનરાવર્તન';

  @override
  String get onHomeScreenSectionTitle => 'તમારી હોમ સ્ક્રીન પર';

  @override
  String showFromTime(String time) {
    return '$time થી બતાવો';
  }

  @override
  String get homeModeNoneExplain => 'નિશાન ફક્ત કેલેન્ડર પર જ રહે છે.';

  @override
  String get homeModeMorningExplain =>
      'તે સમયે હોમ પર એક કાર્ડ દેખાય છે. પૂર્ણ થાય ત્યારે તેને સ્વાઇપ કરો: તે આગલા પુનરાવર્તન પર પાછું આવે છે.';

  @override
  String get homeModeAllDayExplain =>
      'એક કાર્ડ હોમ પર આખો દિવસ પિન રહે છે (તેને સ્વાઇપ કરી શકાતું નથી).';

  @override
  String get tomorrow => 'આવતીકાલે';

  @override
  String get yesterday => 'ગઈકાલે';

  @override
  String get startAgain => 'ફરીથી શરૂ કરો';

  @override
  String get settingsAction => 'સેટિંગ્સ';

  @override
  String get clockToolClockSubtitle => 'એક મોટો, લાઇવ સમય અને તારીખ';

  @override
  String get clockToolSunAlarmTitle => 'સૂર્ય-આધારિત એલાર્મ';

  @override
  String get clockToolSunAlarmSubtitle =>
      'સૂર્યોદય કે સૂર્યાસ્ત વખતે, ઓફસેટ સાથે જાગો';

  @override
  String get clockToolWorldClockTitle => 'વિશ્વ ઘડિયાળ';

  @override
  String get clockToolWorldClockSubtitle => 'અમૃતસર, હરિદ્વાર, લંડન અને વધુ';

  @override
  String get clockToolTimerTitle => 'સાધના અને વ્રત ટાઇમર';

  @override
  String get clockToolTimerSubtitle =>
      'આરતી, ચાલીસા, પાઠ, હવન, અથવા સૂર્યાસ્ત સુધી';

  @override
  String get clockToolStopwatchTitle => 'પાઠ સ્ટોપવોચ';

  @override
  String get clockToolStopwatchSubtitle => 'શરૂ કરો, રોકો અને લેપ કરો';

  @override
  String get sunEventSunrise => 'સૂર્યોદય';

  @override
  String get sunEventSunset => 'સૂર્યાસ્ત';

  @override
  String offsetAtEvent(String event) {
    return '$event વખતે';
  }

  @override
  String offsetMinutesOnly(int m) {
    return '$m મિનિટ';
  }

  @override
  String offsetHoursOnly(int h) {
    return '$h કલાક';
  }

  @override
  String offsetHoursMinutes(int h, int m) {
    return '$h કલાક $m મિનિટ';
  }

  @override
  String offsetBefore(String amount) {
    return '$amount પહેલાં';
  }

  @override
  String offsetAfter(String amount) {
    return '$amount પછી';
  }

  @override
  String get locationSourceDevice => 'તમારું સ્થાન';

  @override
  String get locationSourceSaved => 'તમારું છેલ્લું જાણીતું સ્થાન';

  @override
  String get locationSourceFallback => 'અમૃતસર (મૂળભૂત)';

  @override
  String get locSummaryDevice => 'તમારું સ્થાન વાપરી રહ્યા છીએ';

  @override
  String get locSummarySaved => 'તમારું છેલ્લું જાણીતું સ્થાન વાપરી રહ્યા છીએ';

  @override
  String get locSummaryBlocked =>
      'અમૃતસર વાપરી રહ્યા છીએ. સેટિંગ્સમાં સ્થાન અવરોધિત છે.';

  @override
  String get locSummaryServiceOff =>
      'અમૃતસર વાપરી રહ્યા છીએ. ચોક્કસ સમય માટે સ્થાન ચાલુ કરો.';

  @override
  String get locSummaryUnsupported => 'અમૃતસર વાપરી રહ્યા છીએ.';

  @override
  String get locSummaryDefault =>
      'અમૃતસર વાપરી રહ્યા છીએ. ચોક્કસ સમય માટે સ્થાનની પરવાનગી આપો.';

  @override
  String get presetAarti => 'આરતી';

  @override
  String get presetChalisa => 'ચાલીસા';

  @override
  String get presetPath => 'પાઠ';

  @override
  String get presetHavan => 'હવન';

  @override
  String get vratToSunset => 'વ્રત → સૂર્યાસ્ત';

  @override
  String presetChipLabel(String label, int minutes) {
    return '$label · $minutes મિનિટ';
  }

  @override
  String get clockNoSunsetHere => 'અહીં અત્યારે ગણવા માટે કોઈ સૂર્યાસ્ત નથી.';

  @override
  String get clockSunsetPassedTomorrow =>
      'આજનો સૂર્યાસ્ત થઈ ગયો છે: આવતીકાલ માટે ગણાઈ રહ્યું છે.';

  @override
  String timerFinishedTitle(String label) {
    return '🔔 $label પૂર્ણ થયું';
  }

  @override
  String get sunsetArrived => 'સૂર્યાસ્ત થયો 🙏';

  @override
  String timerTimeUp(String label) {
    return 'તમારો $label સમય પૂરો થયો છે 🙏';
  }

  @override
  String sunAlarmNotifTitle(String emoji, String event) {
    return '$emoji $event એલાર્મ';
  }

  @override
  String sunAlarmNotifBody(String event, String time, String offset) {
    return '$event $time વાગ્યે છે · $offset';
  }

  @override
  String get statusOn => 'ચાલુ';

  @override
  String get finished => 'પૂર્ણ થયું';

  @override
  String get left => 'બાકી';

  @override
  String get paused => 'થોભાયેલ';

  @override
  String get runningStatus => 'ચાલી રહ્યું છે';

  @override
  String get stoppedStatus => 'અટકી ગયું';

  @override
  String get lap => 'લેપ';

  @override
  String get lapTime => 'લેપ સમય';

  @override
  String get total => 'કુલ';

  @override
  String get fastest => 'સૌથી ઝડપી';

  @override
  String get slowest => 'સૌથી ધીમું';

  @override
  String get tapLapToMark => 'લેપ ચિહ્નિત કરવા Lap ટેપ કરો.';

  @override
  String get startThenTapLap => 'Start કરો, પછી દરેક રાઉન્ડમાં Lap ટેપ કરો.';

  @override
  String get allowNotificationsForAlarm =>
      'એલાર્મ વાગવા સેટિંગ્સમાં સૂચનાઓ ચાલુ કરો.';

  @override
  String get alarmRingsAt => 'એલાર્મ વાગશે';

  @override
  String get alarmWouldRingAt => 'એલાર્મ વાગત';

  @override
  String noEventToFollow(String event) {
    return 'અહીં અત્યારે અનુસરવા માટે કોઈ $event નથી.';
  }

  @override
  String get alarmOnLabel => 'એલાર્મ ચાલુ';

  @override
  String get recalculatedDaily =>
      'સૂર્યની ગતિ પ્રમાણે દરરોજ ફરીથી ગણતરી થાય છે';

  @override
  String todayHereSunriseSunset(String rise, String set) {
    return 'અહીં આજે: સૂર્યોદય $rise · સૂર્યાસ્ત $set';
  }

  @override
  String get whenLabel => 'ક્યારે';

  @override
  String get minutesLabel => 'મિનિટ';

  @override
  String get upTo1440 => '1440 સુધી';

  @override
  String get before => 'પહેલાં';

  @override
  String get after => 'પછી';

  @override
  String get useMyLocation => 'મારું સ્થાન વાપરો';

  @override
  String get couldNotReadPosition => ' · તમારી સ્થિતિ વાંચી શકાયું નહીં';

  @override
  String get timesUp => 'સમય પૂરો થયો 🙏';

  @override
  String sunsetAtTime(String time) {
    return 'સૂર્યાસ્ત $time વાગ્યે';
  }

  @override
  String cityInDays(int days) {
    return '$days દિવસમાં';
  }

  @override
  String cityDaysAgo(int days) {
    return '$days દિવસ પહેલાં';
  }

  @override
  String get citySameTime => 'તમારા જેવો જ સમય';

  @override
  String cityAmountMinutes(int m) {
    return '$m મિ';
  }

  @override
  String cityAmountHours(int h) {
    return '$h ક';
  }

  @override
  String cityAmountHoursMinutes(int h, int m) {
    return '$h ક $m મિ';
  }

  @override
  String cityAheadOfYou(String amount) {
    return 'તમારા કરતાં $amount આગળ';
  }

  @override
  String cityBehindYou(String amount) {
    return 'તમારા કરતાં $amount પાછળ';
  }

  @override
  String get traditionHindu => 'હિંદુ';

  @override
  String get traditionSikh => 'શીખ';

  @override
  String get traditionPlace => 'સ્થળ પ્રમાણે';

  @override
  String get todayLabelTithi => 'તિથિ';

  @override
  String get todayLabelNakshatra => 'નક્ષત્ર';

  @override
  String get todayLabelRahu => 'રાહુ કાળ';

  @override
  String get todayLabelAbhijit => 'અભિજિત મુહૂર્ત';

  @override
  String get todayLabelHukamnama => 'હુકમનામા';

  @override
  String get todayLabelNitnem => 'નિત્નેમ બાકી';

  @override
  String get todayLabelGurpurab => 'આગલું ગુરુપર્વ';

  @override
  String get todayLabelFestival => 'સ્થાનિક તહેવાર';

  @override
  String get todayLabelWindow => 'શુભ સમય';

  @override
  String get exampleTag => 'ઉદાહરણ';

  @override
  String get exampleNote =>
      'ઉદાહરણ ચિહ્નિત મૂલ્યો પ્લેસહોલ્ડર છે: વાસ્તવિક પંચાંગ ડેટા પછીના તબક્કામાં આવશે.';

  @override
  String liveNote(String where) {
    return 'સૂર્યોદય અને સૂર્યાસ્ત તમારા સ્થાન માટે કાઢવામાં આવ્યા છે. $where.';
  }

  @override
  String get greetingMorning => 'શુભ સવાર';

  @override
  String get greetingAfternoon => 'શુભ બપોર';

  @override
  String get greetingEvening => 'શુભ સાંજ';

  @override
  String get greetingNight => 'શુભ રાત્રિ';

  @override
  String get homeEmptyTitle => 'આજે તમારી હોમ સ્ક્રીન પર કંઈ નથી';

  @override
  String get homeEmptyBody =>
      'કેલેન્ડરમાં તારીખ ચિહ્નિત કરો અને તેને અહીં જોવા \"તમારી હોમ સ્ક્રીન પર\" પસંદ કરો.';

  @override
  String get pinnedAllDay => 'આખો દિવસ પિન કરેલ';

  @override
  String get swipeToDismiss => 'આજ માટે દૂર કરવા સ્વાઇપ કરો';

  @override
  String doneForToday(String title) {
    return 'આજ માટે પૂર્ણ: $title';
  }

  @override
  String get undoAction => 'પૂર્વવત્ કરો';

  @override
  String get doneForTodayLabel => 'આજ માટે પૂર્ણ';

  @override
  String get plansTitle => 'પાઠ અને મંત્ર યોજનાઓ';

  @override
  String get addPlan => 'યોજના ઉમેરો';

  @override
  String get dayStreak => 'દિવસની સતત શ્રેણી';

  @override
  String activePlanCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'સક્રિય યોજનાઓ',
      one: 'સક્રિય યોજના',
    );
    return '$_temp0';
  }

  @override
  String get noPlansYet => 'હજુ કોઈ યોજના નથી';

  @override
  String get plansEmptyBody =>
      'એક પાઠ કે મંત્ર માટે અમુક દિવસો પ્રતિબદ્ધ રહો અને દરરોજ ચિહ્નિત કરો. આમાંથી એકથી શરૂ કરો, અથવા તમારો પોતાનો બનાવો.';

  @override
  String get planOptionsTooltip => 'યોજના વિકલ્પો';

  @override
  String get deletePlanMenuItem => 'યોજના કાઢી નાખો';

  @override
  String get deletePlanQuestion => 'યોજના કાઢી નાખવી છે?';

  @override
  String deletePlanBody(String title) {
    return '$title અને તેની પ્રગતિ દૂર કરવામાં આવશે.';
  }

  @override
  String titledDaysTag(String title, int days) {
    return '$title · $days દિવસ';
  }

  @override
  String completedOfDays(int completed, int total) {
    return 'પૂર્ણ · $total માંથી $completed દિવસ';
  }

  @override
  String ofDays(int completed, int total) {
    return '$total માંથી $completed દિવસ';
  }

  @override
  String get doneTodayButton => 'આજ પૂર્ણ';

  @override
  String get markTodayDone => 'આજ પૂર્ણ ચિહ્નિત કરો';

  @override
  String get newPlanTitle => 'નવી યોજના';

  @override
  String get newPlanSubtitle =>
      'એક પાઠ કે મંત્ર પસંદ કરો અને તમે તેને કેટલા દિવસ ચાલુ રાખશો.';

  @override
  String get paathOrMantraLabel => 'પાઠ કે મંત્ર';

  @override
  String get giveThePlanAName => 'યોજનાને એક નામ આપો';

  @override
  String chooseDaysRange(int min, int max) {
    return '$min થી $max દિવસ પસંદ કરો';
  }

  @override
  String get forHowManyDays => 'કેટલા દિવસ માટે?';

  @override
  String get daysFieldLabel => 'દિવસ';

  @override
  String get startPlanButton => 'યોજના શરૂ કરો';

  @override
  String get planKindPaath => 'પાઠ';

  @override
  String get planKindMantra => 'મંત્ર';

  @override
  String get profileTitle => 'પ્રોફાઇલ';

  @override
  String get sadhanaSettingsTitle => 'સાધના સેટિંગ્સ';

  @override
  String get validEmailError => 'માન્ય ઇમેઇલ સરનામું દાખલ કરો';

  @override
  String nameTooLong(int max) {
    return 'તેને $max અક્ષરોથી ઓછું રાખો';
  }

  @override
  String get enterCurrentPassword => 'તમારો હાલનો પાસવર્ડ દાખલ કરો';

  @override
  String passwordTooShort(int min) {
    return 'ઓછામાં ઓછા $min અક્ષરો વાપરો';
  }

  @override
  String get passwordAlreadyUsed => 'તમે પહેલા ન વાપરેલો પાસવર્ડ પસંદ કરો';

  @override
  String get passwordsDontMatch => 'બંને પાસવર્ડ મેળ ખાતા નથી';

  @override
  String get changePasswordTitle => 'પાસવર્ડ બદલો';

  @override
  String get accountsLaterNote =>
      'ખાતાઓ પછીના તબક્કામાં આવશે; ત્યાં સુધી આ ફક્ત તમારી એન્ટ્રીઓ ચકાસે છે અને કંઈ બદલતું નથી.';

  @override
  String get currentPasswordLabel => 'હાલનો પાસવર્ડ';

  @override
  String get newPasswordLabel => 'નવો પાસવર્ડ';

  @override
  String get confirmNewPasswordLabel => 'નવા પાસવર્ડની પુષ્ટિ કરો';

  @override
  String get showPasswords => 'પાસવર્ડ બતાવો';

  @override
  String get updatePasswordButton => 'પાસવર્ડ અપડેટ કરો';

  @override
  String get stepAddName => 'તમારું નામ ઉમેરો';

  @override
  String get stepAddEmail => 'તમારો ઇમેઇલ ઉમેરો';

  @override
  String get stepPickTradition => 'હોમ પર તમારી પરંપરા પસંદ કરો';

  @override
  String get stepTurnOnReminder => 'દૈનિક રિમાઇન્ડર ચાલુ કરો';

  @override
  String get stepStartPlan => 'એક પાઠ કે મંત્ર યોજના શરૂ કરો';

  @override
  String get profileCompletionTitle => 'પ્રોફાઇલ પૂર્ણતા';

  @override
  String get profileCompleteReward =>
      'પ્રોફાઇલ પૂર્ણ! પ્રીમિયમ લોન્ચ થાય ત્યારે તમારું મફત પ્રીમિયમ ઇનામ રાહ જોશે.';

  @override
  String get reachRewardNote =>
      'લોન્ચ થાય ત્યારે મફત પ્રીમિયમ મેળવવા 100% સુધી પહોંચો.';

  @override
  String get aboutTitle => 'વિશે';

  @override
  String get appLabel => 'એપ';

  @override
  String get websiteLabel => 'વેબસાઇટ';

  @override
  String get versionLabel => 'સંસ્કરણ';

  @override
  String get passwordWillWorkLater =>
      'ખાતા ઉમેરાયા પછી પાસવર્ડ બદલવો કામ કરશે.';

  @override
  String get signedOut => 'સાઇન આઉટ થયું';

  @override
  String get notSignedInYet =>
      'તમે હજુ સાઇન ઇન નથી: ખાતાઓ પછીના તબક્કામાં આવશે. તમારો ડેટા આ ફોન પર જ રહે છે.';

  @override
  String get accountTitle => 'ખાતું';

  @override
  String get signOutButton => 'સાઇન આઉટ કરો';

  @override
  String get backupSaved => 'બેકઅપ સાચવ્યું';

  @override
  String get backupCancelled => 'બેકઅપ રદ થયું';

  @override
  String get couldNotSaveBackup => 'બેકઅપ સાચવી શકાયું નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get backupNotSadho => 'તે ફાઇલ Sadho બેકઅપ નથી.';

  @override
  String get couldNotReadFile => 'તે ફાઇલ વાંચી શકાઈ નહીં.';

  @override
  String get backupDamaged => 'બેકઅપ ફાઇલ ખરાબ છે.';

  @override
  String get backupTooNew =>
      'આ બેકઅપ Sadho ના નવા સંસ્કરણ દ્વારા બનાવવામાં આવ્યું હતું. પહેલા એપ અપડેટ કરો.';

  @override
  String get backupNoData => 'તે બેકઅપમાં કોઈ Sadho ડેટા નથી.';

  @override
  String get backupTooBig => 'તે ફાઇલ Sadho બેકઅપ હોવા માટે ખૂબ મોટી છે.';

  @override
  String madeOnSuffix(String date) {
    return ' $date ના રોજ બનાવેલ';
  }

  @override
  String restoreBackupBody(String made, int count) {
    return 'એક બેકઅપ$made જેમાં $count સાચવેલી વસ્તુઓ છે. તે આ ફોન પરની વસ્તુઓની જગ્યા લેશે: નિશાન, યોજનાઓ, મંત્રો, અવાજ તાલીમ અને સેટિંગ્સ.';
  }

  @override
  String get restoreThisBackup => 'આ બેકઅપ પુનઃસ્થાપિત કરવું છે?';

  @override
  String get backupRestoredTitle => 'બેકઅપ પુનઃસ્થાપિત થયું';

  @override
  String get backupRestoredBody =>
      'Sadho તમારા પુનઃસ્થાપિત ડેટા સાથે ફરી લોડ થશે.';

  @override
  String get backupRestoreTitle => 'બેકઅપ અને પુનઃસ્થાપન';

  @override
  String get backupExplain =>
      'તમારા નિશાન, યોજનાઓ, મંત્રો, અવાજ તાલીમ અને સેટિંગ્સને તમારી પસંદની ફાઇલમાં સાચવો (Drive, Files, પોતાને ઇમેઇલ કરો). તેને આ અથવા બીજા ફોન પર પુનઃસ્થાપિત કરો.';

  @override
  String get exportButton => 'એક્સપોર્ટ';

  @override
  String get restoreButton => 'પુનઃસ્થાપિત કરો';

  @override
  String get cloudSyncTitle => 'ક્લાઉડ સિંક';

  @override
  String get comingLater => 'પછી આવશે';

  @override
  String get saveBackupDialogTitle => 'તમારો Sadho બેકઅપ સાચવો';

  @override
  String get chooseBackupDialogTitle => 'એક Sadho બેકઅપ પસંદ કરો';

  @override
  String get areYouSure => 'શું તમે ખાતરી છો?';

  @override
  String get deleteAccountWarning =>
      'આ તમારું ખાતું અને આ ફોન પર સાચવેલું બધું જ કાઢી નાખે છે: તમારી પ્રોફાઇલ, નિશાન, યોજનાઓ, મંત્રો, અવાજ તાલીમ અને સેટિંગ્સ. તેને પૂર્વવત્ કરી શકાતું નથી.';

  @override
  String get yesAction => 'હા';

  @override
  String get noAction => 'ના';

  @override
  String get dangerZoneTitle => 'જોખમી ક્ષેત્ર';

  @override
  String get deleteAccountExplain =>
      'તમારું ખાતું કાઢી નાખવાથી તમારી પ્રોફાઇલ અને આ ફોન પર સાચવેલું બધું ભૂંસાઈ જાય છે. જો તમને તે પાછું જોઈતું હોય તો પહેલા બેકઅપ એક્સપોર્ટ કરો.';

  @override
  String get deleteAccountButton => 'ખાતું કાઢી નાખો';

  @override
  String get profileSaved => 'પ્રોફાઇલ સાચવાઈ';

  @override
  String get yourDetailsTitle => 'તમારી વિગતો';

  @override
  String get nameLabel => 'નામ';

  @override
  String get emailLabel => 'ઇમેઇલ';

  @override
  String get dailyReminderTitle => 'દૈનિક રિમાઇન્ડર';

  @override
  String get dailySadhanaReminder => 'દૈનિક સાધના રિમાઇન્ડર';

  @override
  String get reminderOff => 'બંધ';

  @override
  String everyDayAt(String time) {
    return 'દરરોજ $time વાગ્યે';
  }

  @override
  String get allowNotificationsForReminder =>
      'રિમાઇન્ડર વાગવા સેટિંગ્સમાં સૂચનાઓ ચાલુ કરો.';

  @override
  String get timeLabel => 'સમય';

  @override
  String get themeTitle => 'થીમ';

  @override
  String get lightMode => 'લાઇટ';

  @override
  String get darkMode => 'ડાર્ક';

  @override
  String get systemMode => 'સિસ્ટમ';

  @override
  String get coloursTitle => 'રંગો';

  @override
  String paletteSemantic(String name) {
    return '$name રંગો';
  }

  @override
  String get paletteMarigoldName => 'ગલગોટા';

  @override
  String get paletteMarigoldBlurb => 'ગરમ કેસરી અને ઊંડો ઇન્ડિગો';

  @override
  String get paletteSandalwoodName => 'ચંદન';

  @override
  String get paletteSandalwoodBlurb => 'નરમ ચંદન બ્રાઉન અને માટી';

  @override
  String get paletteTulsiName => 'તુલસી લીલો';

  @override
  String get paletteTulsiBlurb => 'શાંત પવિત્ર-તુલસી લીલો';

  @override
  String get paletteTwilightName => 'સંધ્યા ઇન્ડિગો';

  @override
  String get paletteTwilightBlurb => 'દીવા-ચમક સોનેરી સાથે સંધ્યા ઇન્ડિગો';

  @override
  String get paletteLotusName => 'કમળ ગુલાબી';

  @override
  String get paletteLotusBlurb => 'કોમળ કમળ ગુલાબી અને પર્ણ લીલો';

  @override
  String get sadhanaTimeNotifTitle => '🪔 તમારી સાધનાનો સમય';

  @override
  String get sadhanaTimeNotifBody =>
      'તમારા પાઠ કે મંત્ર માટે થોડી શાંત મિનિટો કાઢો 🙏';

  @override
  String get comingSoon => 'જલ્દી આવી રહ્યું છે';

  @override
  String get trainAction => 'તાલીમ આપો';

  @override
  String get onboardingTitle => 'Sadho માં તમારું સ્વાગત છે';

  @override
  String get onboardingSubtitle =>
      'શરૂ કરવા તમારી ભાષા અને પરંપરા પસંદ કરો. તમે બંનેને પછી પ્રોફાઇલમાં બદલી શકો છો.';

  @override
  String get traditionHeading => 'પરંપરા';

  @override
  String get continueAction => 'ચાલુ રાખો';

  @override
  String get stopAlert => 'બંધ કરો';

  @override
  String get repeatLabel => 'પુનરાવર્તન';

  @override
  String get repeatOnce => 'એક વાર';

  @override
  String soundRepeatTimes(int times) {
    return '$times વાર';
  }

  @override
  String get repeatUntilStopped => 'બંધ કરો ત્યાં સુધી';

  @override
  String vibrationRepeatUntilStopped(int seconds) {
    return 'દર $seconds સેકન્ડે, બંધ કરો ત્યાં સુધી';
  }

  @override
  String get keepScreenOnLabel => 'ગણતરી દરમિયાન સ્ક્રીન ચાલુ રાખો';

  @override
  String get keepScreenOnSubtitle =>
      'સત્ર ચાલુ હોય ત્યારે સ્ક્રીન બંધ થતી નથી. પાવર બટનથી ફોન તોય લૉક થાય છે; ત્યારે સમય કે લય વાળું સત્ર પૂરું થતાં એલાર્મની જેમ વાગે છે.';

  @override
  String get alarmMayBeLate =>
      'એલાર્મ થોડું મોડું વાગી શકે છે (ચોક્કસ એલાર્મ બંધ છે).';

  @override
  String get exactAlarmNotice =>
      'સ્ક્રીન બંધ હોય ત્યારે પણ સમયસર વગાડવા, Sadho ને ચોક્કસ એલાર્મની મંજૂરી આપો.';

  @override
  String get fullScreenNotice =>
      'પૂરું થયેલું સત્ર લૉક સ્ક્રીન પર બતાવવા, ફુલ-સ્ક્રીન સૂચનાઓની મંજૂરી આપો.';

  @override
  String get allowAction => 'મંજૂરી આપો';

  @override
  String channelSadhanaAlarmName(String sound) {
    return 'સાધના એલાર્મ · $sound';
  }

  @override
  String get channelSadhanaAlarmSilentName => 'સાધના એલાર્મ · શાંત';

  @override
  String get channelNoVibration => 'કંપન નહીં';

  @override
  String get channelSadhanaAlarmDesc =>
      'સમય કે લય વાળું સત્ર પૂરું થતાં વાગે છે';

  @override
  String get alarmScreenSadhanaTitle => 'સાધના પૂર્ણ 🙏';

  @override
  String get alarmScreenTimerTitle => 'ટાઇમર પૂરું થયું';

  @override
  String get alarmScreenSunTitle => 'સૂર્ય એલાર્મ';

  @override
  String get alarmScreenUnlock => 'Sadho ખોલવા માટે અનલૉક કરો';

  @override
  String get alarmScreenUnlockHint =>
      'ઍપના બાકીના ભાગ માટે ફોન અનલૉક હોવો જોઈએ.';

  @override
  String get alarmsReliabilityTitle => 'એલાર્મ અને વિશ્વસનીયતા';

  @override
  String get alarmsReliabilityIntro =>
      'સ્ક્રીન બંધ હોય ત્યારે પણ એલાર્મ સમયસર વાગે તે માટે ફોને આ મંજૂરીઓ આપવી પડશે. સુધારો સાચું સેટિંગ પેજ ખોલે છે.';

  @override
  String get alarmsReliabilityAllOk =>
      'એલાર્મ સમયસર વાગે તે માટે બધું તૈયાર છે';

  @override
  String get alarmsReliabilityAttention => 'કંઈક ધ્યાન માગે છે';

  @override
  String get healthOk => 'બરાબર';

  @override
  String get healthNeedsAttention => 'ધ્યાન આપો';

  @override
  String get healthFix => 'સુધારો';

  @override
  String get healthNotificationsTitle => 'સૂચનાઓની મંજૂરી';

  @override
  String get healthNotificationsBody =>
      'એલાર્મ અને રિમાઇન્ડર સૂચના તરીકે આવે છે.';

  @override
  String get healthExactTitle => 'ચોક્કસ એલાર્મની મંજૂરી';

  @override
  String get healthExactBody => 'બરાબર એ જ સેકન્ડે વાગે છે, મોડું નહીં.';

  @override
  String get healthFullScreenTitle => 'લૉક સ્ક્રીન પર એલાર્મ બતાવો';

  @override
  String get healthFullScreenBody =>
      'ફોન લૉક હોય ત્યારે પણ પૂરું થયેલું એલાર્મ દેખાય છે.';

  @override
  String get healthBatteryTitle => 'બૅટરી: ઍપ પ્રતિબંધિત નથી';

  @override
  String get healthBatteryBody =>
      'બૅટરીમાં અપ્રતિબંધિત પસંદ કરો (અથવા ઓછામાં ઓછું પ્રતિબંધિત નહીં), જેથી ફોન એલાર્મ રોકે નહીં.';

  @override
  String get healthBatterySamsungHint =>
      'Samsung: સેટિંગ્સ › બૅટરી › બૅકગ્રાઉન્ડ વપરાશ મર્યાદામાં, Sadho ને “સ્લીપિંગ ઍપ્સ” અને “ડીપ સ્લીપિંગ ઍપ્સ” માંથી દૂર કરો, અને બૅટરી વપરાશ “અપ્રતિબંધિત” કરો.';

  @override
  String get alarmExplainerOk =>
      'આ સત્ર પૂરું થતાં એલાર્મની જેમ વાગશે, સ્ક્રીન કે ઍપ બંધ હોય તોય.';

  @override
  String get alarmExplainerAttention =>
      'આ સત્ર પૂરું થતાં એલાર્મની જેમ વાગશે, પણ સમયસર વાગવા માટે ફોનનું એક સેટિંગ બદલવું પડશે.';

  @override
  String get alarmExplainerCheck => 'તપાસો';

  @override
  String get customTimerName => 'કસ્ટમ ટાઈમર';

  @override
  String customChipLabel(String duration) {
    return 'કસ્ટમ · $duration';
  }

  @override
  String get customTimerTitle => 'પોતાનો સમયગાળો';

  @override
  String get customTimerRange => '1 સેકન્ડથી 24 કલાક સુધી પસંદ કરો.';

  @override
  String durationHours(int hours) {
    return '$hours કલાક';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes મિનિટ';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds સેકન્ડ';
  }

  @override
  String collapseSection(String section) {
    return '$section છુપાવો';
  }

  @override
  String expandSection(String section) {
    return '$section બતાવો';
  }

  @override
  String get summaryVibrationOn => 'કંપન ચાલુ';

  @override
  String get summaryVibrationOff => 'કંપન બંધ';

  @override
  String get summarySoundOff => 'અવાજ બંધ';

  @override
  String get summaryNotSet => 'નક્કી નથી';

  @override
  String get clockToolNotepadTitle => 'નોટપેડ';

  @override
  String get clockToolNotepadSubtitle => 'નોંધો, આ જ ફોન પર સાચવેલી';

  @override
  String get notesSearchHint => 'નોંધો શોધો';

  @override
  String get notesEmpty => 'હજી કોઈ નોંધ નથી. લખવા માટે + દબાવો.';

  @override
  String notesNoMatch(String query) {
    return '“$query” સાથે કોઈ નોંધ મેળ ખાતી નથી.';
  }

  @override
  String get noteNew => 'નવી નોંધ';

  @override
  String get noteEdit => 'નોંધ';

  @override
  String get noteTitleHint => 'શીર્ષક (વૈકલ્પિક)';

  @override
  String get noteTextHint => 'અહીં લખો…';

  @override
  String get noteUntitled => 'ખાલી નોંધ';

  @override
  String noteCreatedAt(String when) {
    return 'બનાવી $when';
  }

  @override
  String noteEditedAt(String when) {
    return 'બદલી $when';
  }

  @override
  String get noteSavedAsYouType => 'લખતાં જ સચવાય છે';

  @override
  String get noteDelete => 'નોંધ કાઢી નાખો';

  @override
  String get noteDeleteQuestion => 'આ નોંધ કાઢી નાખવી છે?';

  @override
  String noteDeleteBody(String title) {
    return '“$title” આ ફોન પરથી દૂર થશે. આ પાછું લાવી શકાશે નહીં.';
  }

  @override
  String get paletteHighContrastName => 'ઉચ્ચ કૉન્ટ્રાસ્ટ';

  @override
  String get paletteHighContrastBlurb => 'સૌથી વધુ તફાવત, સરળ વાંચન માટે';

  @override
  String get malaNotificationChannel => 'માળા કાઉન્ટર';

  @override
  String malaNotificationTitle(String count, String target) {
    return 'માળા · $count / $target';
  }

  @override
  String malaNotificationTitleCount(String count) {
    return 'માળા · $count';
  }

  @override
  String get malaNotificationRunning =>
      'ગણવા માટે વોલ્યુમ કી દબાવો, સ્ક્રીન બંધ હોય ત્યારે પણ.';

  @override
  String get malaNotificationDone => 'લક્ષ્ય પૂર્ણ 🙏';

  @override
  String get malaRingTitle => '🔔 માળા પૂર્ણ';

  @override
  String malaRingBody(int target) {
    return 'તમે $targetનું લક્ષ્ય પૂરું કર્યું 🙏';
  }

  @override
  String get malaScreenOffUnavailable =>
      'આ ફોન પર સ્ક્રીન બંધ હોય ત્યારે ગણતરી શરૂ થઈ શકી નહીં. Sadho ખુલ્લું હોય ત્યારે જ વોલ્યુમ કી ગણશે.';

  @override
  String get pressVolumeKeysScreenOff =>
      'વોલ્યુમ કી ગણે છે, સ્ક્રીન બંધ હોય ત્યારે પણ';

  @override
  String get malaScreenOffLabel => 'સ્ક્રીન બંધ હોય ત્યારે પણ ગણો';

  @override
  String get malaScreenOffOnSubtitle =>
      'ફોન લૉક કરો અને વોલ્યુમ કી દબાવતા રહો. એક સૂચના ગણતરી બતાવે છે અને લક્ષ્ય પર વાગે છે.';

  @override
  String get malaScreenOffOffSubtitle =>
      'બંધ: Sadho ખુલ્લું હોય અને સ્ક્રીન ચાલુ હોય ત્યારે જ વોલ્યુમ કી ગણે છે.';

  @override
  String get modeHelpMalaScreenOff =>
      'Start દબાવો, પછી ગણવા માટે કોઈપણ વોલ્યુમ કી દબાવો, ફોન લૉક અને સ્ક્રીન બંધ હોય ત્યારે પણ. આંખો બંધ કરીને કે ફોન ખિસ્સામાં હોય ત્યારે ઉપયોગી.';

  @override
  String get malaScreenOffExplainer =>
      'ફોન લૉક કરો, ગણવા વોલ્યુમ કી દબાવો. બૅટરી \'અપ્રતિબંધિત\' કરો.';

  @override
  String get calibrateTitle => 'અવાજ કેલિબ્રેટ કરો';

  @override
  String calibrateIntro(int count) {
    return 'તમારો મંત્ર $count વાર જપો, જેમ તમે સામાન્ય રીતે કરો છો, દરેક પછી થોડું અટકીને. પછી Sadho નક્કી કરે છે કે અવાજ કેટલો કડક હોય, જેથી બધા ગણાય અને રૂમનો અવાજ નહીં. કંઈ રેકોર્ડ કે રાખવામાં આવતું નથી.';
  }

  @override
  String calibrateChantNow(int count) {
    return 'હવે તમારો મંત્ર $count વાર જપો';
  }

  @override
  String calibrateHeard(int heard, int count) {
    return '$countમાંથી $heard સાંભળ્યા';
  }

  @override
  String calibrateSkipped(int count) {
    return 'એક જાપ ન હોય તેવા $count અવાજ છોડી દીધા';
  }

  @override
  String get calibrateDone => 'કેલિબ્રેટ થયું';

  @override
  String calibrateDoneBody(int count) {
    return 'બધા $count જાપ ગણાશે; રૂમનો અવાજ નહીં.';
  }

  @override
  String get calibrateStart => 'કેલિબ્રેશન શરૂ કરો';

  @override
  String get calibrateSave => 'કેલિબ્રેશન સાચવો';

  @override
  String calibrationSaved(String mantra) {
    return '“$mantra” માટે કેલિબ્રેશન સાચવ્યું';
  }

  @override
  String get calibrateVoice => 'કેલિબ્રેટ કરો';

  @override
  String get recalibrateVoice => 'ફરી કેલિબ્રેટ કરો';

  @override
  String get quietModeLabel => 'સત્ર દરમિયાન અન્ય સૂચનાઓ શાંત કરો';

  @override
  String get quietModeSubtitle =>
      'સત્ર ચાલે ત્યારે \'ખલેલ પાડશો નહીં\' (ફક્ત એલાર્મ) ચાલુ કરે છે, જેથી Sadhoનો એલાર્મ તો પણ વાગે. પછી તમારી પોતાની સેટિંગ પાછી આવે છે.';

  @override
  String get quietModeAccessTitle => '\'ખલેલ પાડશો નહીં\' ઍક્સેસ આપો';

  @override
  String get quietModeAccessBody =>
      'સાધના દરમિયાન અન્ય સૂચનાઓ શાંત કરવા Sadhoને \'ખલેલ પાડશો નહીં\' ઍક્સેસ જોઈએ. આગલી સ્ક્રીન પર Sadho શોધો અને મંજૂરી આપો. Sadho ફક્ત સત્ર ચાલે ત્યારે \'ફક્ત એલાર્મ\' મોડ ચાલુ કરે છે અને પછી તમારી સેટિંગ પાછી મૂકે છે.';

  @override
  String get healthDndTitle => '\'ખલેલ પાડશો નહીં\' ઍક્સેસ';

  @override
  String get healthDndBody =>
      'સત્ર દરમિયાન અન્ય સૂચનાઓ શાંત કરવા જરૂરી. તેના વિના Sadho \'ખલેલ પાડશો નહીં\'ને અડતું નથી.';

  @override
  String get legalPrivacyPolicy => 'ગોપનીયતા નીતિ';

  @override
  String get legalTermsOfUse => 'ઉપયોગની શરતો';

  @override
  String get legalContact => 'સંપર્ક અને ફરિયાદ';

  @override
  String get legalDeleteData => 'તમારો ડેટા કાઢી નાખો';

  @override
  String get legalLicenses => 'ઓપન-સોર્સ લાઇસન્સ';

  @override
  String linkOpenFailed(String url) {
    return '$url ખોલી શકાયું નહીં';
  }

  @override
  String onboardingLegalNotice(String terms, String privacy) {
    return 'તમારી સાધના, કૅલેન્ડર, અવાજ તાલીમ અને સ્થાન આ જ ફોન પર રહે છે. આગળ વધીને તમે $terms સાથે સંમત થાઓ છો અને $privacy વાંચી છે.';
  }

  @override
  String get channelSadhanaAlarmV2Name => 'સાધના એલાર્મ';

  @override
  String get healthChannelTitle => 'એલાર્મ સૂચનાઓ: \'અલર્ટ\' પર રાખો';

  @override
  String get healthChannelBody =>
      '“સાધના એલાર્મ” અને “એલાર્મ અને ટાઇમર” સૂચનાઓ સ્ક્રીન પર દેખાવી જોઈએ, નહીં તો એલાર્મ સ્ક્રીન લૉક સ્ક્રીન પર દેખાઈ શકતી નથી.';

  @override
  String get healthFixManualTitle => 'સેટિંગ્સ જાતે ખોલો';

  @override
  String get healthFixManualBody =>
      'ફોને આ પેજ ખોલ્યું નહીં. Samsung ફોન પર:\n1. સેટિંગ્સ › ઍપ્સ › Sadho ખોલો.\n2. સૂચનાઓ: મંજૂરી આપો, અને “સાધના એલાર્મ” તથા “એલાર્મ અને ટાઇમર” \'અલર્ટ\' પર રાખો.\n3. એલાર્મ અને રિમાઇન્ડર: મંજૂરી આપો.\n4. બૅટરી: અપ્રતિબંધિત.\n5. પૂર્ણ-સ્ક્રીન સૂચનાઓ: સેટિંગ્સ › ઍપ્સ › ⋮ › વિશેષ ઍક્સેસ › Sadhoને મંજૂરી આપો.\n6. \'ખલેલ પાડશો નહીં\' ઍક્સેસ: સેટિંગ્સ › સૂચનાઓ › ખલેલ પાડશો નહીં › ઍપ ઍક્સેસ (ફક્ત શાંત મોડ માટે).';
}
