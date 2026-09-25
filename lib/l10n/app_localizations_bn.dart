// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get navHome => 'হোম';

  @override
  String get navSadhana => 'সাধনা';

  @override
  String get navCalendar => 'ক্যালেন্ডার';

  @override
  String get navClock => 'ঘড়ি';

  @override
  String get tooltipLanguage => 'ভাষা';

  @override
  String get tooltipProfile => 'প্রোফাইল';

  @override
  String get tooltipSwitchToLight => 'লাইট থিমে যান';

  @override
  String get tooltipSwitchToDark => 'ডার্ক থিমে যান';

  @override
  String get languageSheetTitle => 'ভাষা';

  @override
  String get languageSheetSubtitle =>
      'আপনার পছন্দ সংরক্ষিত হয় এবং সাথে সাথে প্রয়োগ হয়।';

  @override
  String get actionCancel => 'বাতিল করুন';

  @override
  String get actionDelete => 'মুছুন';

  @override
  String get actionSave => 'সংরক্ষণ করুন';

  @override
  String get actionReset => 'রিসেট করুন';

  @override
  String get actionEdit => 'সম্পাদনা করুন';

  @override
  String get actionOk => 'ঠিক আছে';

  @override
  String get unitSeconds => 'সেকেন্ড';

  @override
  String get unitMinutes => 'মিনিট';

  @override
  String get unitHours => 'ঘণ্টা';

  @override
  String get paceErrorEmpty => 'গতি লিখুন।';

  @override
  String get paceErrorNotNumber => 'এটি একটি সংখ্যা নয়।';

  @override
  String paceErrorTooFast(String min) {
    return 'খুব দ্রুত। সর্বনিম্ন $min।';
  }

  @override
  String paceErrorTooSlow(String max) {
    return 'খুব ধীর। সর্বোচ্চ $max।';
  }

  @override
  String get modeTap => 'ট্যাপ';

  @override
  String get modeRhythm => 'রিদম';

  @override
  String get modeVoice => 'কণ্ঠস্বর';

  @override
  String get modeMala => 'মালা';

  @override
  String get ringtoneTempleBell => 'মন্দিরের ঘণ্টা';

  @override
  String get ringtoneSingingBowl => 'সিঙ্গিং বোল';

  @override
  String get ringtoneSoftChime => 'নরম চাইম';

  @override
  String get ringtoneDeepGong => 'গভীর গং';

  @override
  String get msgVoiceUnsupported =>
      'কণ্ঠস্বর গণনা শুধুমাত্র Android এবং iOS এ কাজ করে';

  @override
  String get msgVoiceNoMic => 'এই ডিভাইসে কোনো মাইক্রোফোন উপলব্ধ নেই';

  @override
  String get msgMalaUnsupported =>
      'ভলিউম-কী গণনার জন্য একটি প্রকৃত ডিভাইস প্রয়োজন';

  @override
  String trainFirstPrompt(int min, int max) {
    return 'প্রথমে এই মন্ত্রের জন্য আপনার কণ্ঠস্বর প্রশিক্ষণ দিন: এটি $min থেকে $max বার রেকর্ড করুন।';
  }

  @override
  String get fallbackVoiceDenied =>
      'মাইক্রোফোন অনুমতি প্রত্যাখ্যান করা হয়েছে, তাই কণ্ঠস্বর গণনা শুনতে পারছে না। ট্যাপ মোড ব্যবহার করা হচ্ছে।';

  @override
  String get fallbackVoiceBlocked =>
      'মাইক্রোফোন অ্যাক্সেস অবরুদ্ধ। কণ্ঠস্বর গণনা ব্যবহার করতে সেটিংসে অনুমতি দিন। ট্যাপ মোড ব্যবহার করা হচ্ছে।';

  @override
  String get fallbackVoiceUnsupported =>
      'কণ্ঠস্বর গণনা শুধুমাত্র Android এবং iOS এ কাজ করে। ট্যাপ মোড ব্যবহার করা হচ্ছে।';

  @override
  String get fallbackVoiceNoMic =>
      'এই ডিভাইসে কোনো মাইক্রোফোন উপলব্ধ নেই। ট্যাপ মোড ব্যবহার করা হচ্ছে।';

  @override
  String get fallbackMalaUnsupported =>
      'ভলিউম-কী গণনার জন্য একটি প্রকৃত ডিভাইস প্রয়োজন। ট্যাপ মোড ব্যবহার করা হচ্ছে।';

  @override
  String get sadhanaRingTitle => '🔔 সাধনার সময় সম্পূর্ণ';

  @override
  String get sadhanaRingBody => 'আপনার সেশনের সময় শেষ হয়ে গেছে 🙏';

  @override
  String get voiceTooShort => 'এটি খুব ছোট ছিল। সম্পূর্ণ মন্ত্র বলুন।';

  @override
  String get voiceRanTooLong =>
      'এটি অনেক দীর্ঘ হয়েছে। মন্ত্র একবার বলুন, তারপর থামুন।';

  @override
  String get voiceSoundedDifferent =>
      'এটি অন্যদের থেকে আলাদা শোনালো। একই ভাবে আবার বলুন।';

  @override
  String get voiceGotIt => 'বুঝেছি। আবার বলুন।';

  @override
  String get voiceDeniedShort =>
      'মাইক্রোফোন অনুমতি প্রত্যাখ্যান করা হয়েছে, তাই কণ্ঠস্বর গণনা শুনতে পারছে না।';

  @override
  String get voiceBlockedShort =>
      'মাইক্রোফোন অ্যাক্সেস অবরুদ্ধ। কণ্ঠস্বর গণনা ব্যবহার করতে সেটিংসে অনুমতি দিন।';

  @override
  String get voiceAccessLost =>
      'মাইক্রোফোন অ্যাক্সেস হারিয়ে গেছে, তাই কণ্ঠস্বর গণনা বন্ধ হয়ে গেছে।';

  @override
  String get voiceCouldNotRestart =>
      'মাইক্রোফোন পুনরায় চালু করা যায়নি, তাই কণ্ঠস্বর গণনা বন্ধ হয়ে গেছে।';

  @override
  String get mantraLibraryTitle => 'মন্ত্র লাইব্রেরি';

  @override
  String get addMantra => 'মন্ত্র যোগ করুন';

  @override
  String get searchHint => 'শিরোনাম, লিপি বা ঐতিহ্য খুঁজুন';

  @override
  String noMantrasMatch(String query) {
    return '“$query” এর সাথে কোনো মন্ত্র মেলে না।\nনিজের তৈরি করতে “মন্ত্র যোগ করুন” ট্যাপ করুন।';
  }

  @override
  String mantraAdded(String title) {
    return '“$title” যোগ করা হয়েছে';
  }

  @override
  String mantraSaved(String title) {
    return '“$title” সংরক্ষিত হয়েছে';
  }

  @override
  String mantraRestored(String title) {
    return '“$title” তার ডিফল্টে পুনরুদ্ধার করা হয়েছে';
  }

  @override
  String get deleteMantraTitle => 'মন্ত্র মুছবেন?';

  @override
  String deleteMantraBody(String title) {
    return '“$title” আপনার লাইব্রেরি থেকে সরানো হবে।';
  }

  @override
  String get retrainVoiceTooltip => 'কণ্ঠস্বর পুনরায় প্রশিক্ষণ দিন';

  @override
  String get trainVoice => 'কণ্ঠস্বর প্রশিক্ষণ দিন';

  @override
  String mantraCountTag(int count) {
    return '$count গণনা';
  }

  @override
  String get editedTag => 'সম্পাদিত';

  @override
  String get editMantra => 'মন্ত্র সম্পাদনা করুন';

  @override
  String get addAMantra => 'একটি মন্ত্র যোগ করুন';

  @override
  String get titleLabel => 'শিরোনাম *';

  @override
  String get titleRequired => 'একটি শিরোনাম লিখুন';

  @override
  String get scriptTextLabel => 'লিপি টেক্সট';

  @override
  String get transliterationLabel => 'প্রতিবর্ণীকরণ';

  @override
  String get traditionLabel => 'ঐতিহ্য / ভাষা';

  @override
  String get traditionHint => 'যেমন সংস্কৃত · হিন্দু';

  @override
  String get defaultCountLabel => 'ডিফল্ট গণনা *';

  @override
  String get enterNumberOneOrMore => '1 বা তার বেশি একটি সংখ্যা লিখুন';

  @override
  String get tooLarge => 'এটি খুব বড়';

  @override
  String get saveChanges => 'পরিবর্তন সংরক্ষণ করুন';

  @override
  String get saveToLibrary => 'লাইব্রেরিতে সংরক্ষণ করুন';

  @override
  String get resetToDefaultButton => 'ডিফল্টে রিসেট করুন';

  @override
  String get resetToDefaultTitle => 'ডিফল্টে রিসেট করবেন?';

  @override
  String resetToDefaultBody(String title) {
    return '“$title” এ আপনার পরিবর্তনগুলি বাতিল করা হবে এবং মূল টেক্সট পুনরুদ্ধার করা হবে।';
  }

  @override
  String switchToMantra(String title) {
    return '$title এ স্যুইচ করবেন?';
  }

  @override
  String get switchMantraBody => 'আপনার বর্তমান গণনা রিসেট হবে।';

  @override
  String get keepCurrent => 'বর্তমানটি রাখুন';

  @override
  String get switchAction => 'স্যুইচ করুন';

  @override
  String get smallerMantraText => 'ছোট মন্ত্র টেক্সট';

  @override
  String get largerMantraText => 'বড় মন্ত্র টেক্সট';

  @override
  String get libraryButton => 'লাইব্রেরি';

  @override
  String get trainYourOwnMantra => 'আপনার নিজের মন্ত্র প্রশিক্ষণ দিন';

  @override
  String voiceCountingFrom(String title, int count) {
    return 'আপনার $countটি রেকর্ডিং থেকে “$title” গণনা করা হচ্ছে। অন্যান্য শব্দ ও কথা উপেক্ষা করা হয়।';
  }

  @override
  String voiceCountsOnlyTrained(String title, int min, int max) {
    return 'কণ্ঠস্বর শুধুমাত্র আপনার প্রশিক্ষিত মন্ত্র গণনা করে। শুরু করতে “$title” $min থেকে $max বার রেকর্ড করুন।';
  }

  @override
  String get addMoreSamples => 'আরও নমুনা যোগ করুন';

  @override
  String get retrain => 'পুনরায় প্রশিক্ষণ দিন';

  @override
  String get clearTraining => 'প্রশিক্ষণ মুছুন';

  @override
  String get voiceBetaNote =>
      'বিটা: এটি ডিভাইসে এবং অফলাইনে কাজ করে। বেশি রেকর্ডিংয়ে নির্ভুলতা বাড়ে এবং কোলাহলপূর্ণ ঘরে কমে। পুনরাবৃত্তির মাঝে একটু থামুন। এখানে শুধু আপনার কণ্ঠস্বর গণনা হয়; + এবং − বোতাম গণনা ঠিক করে।';

  @override
  String get trainVoiceFirstTitle => 'প্রথমে আপনার কণ্ঠস্বর প্রশিক্ষণ দিন';

  @override
  String trainVoiceFirstBody(String title, int min, int max) {
    return 'কণ্ঠস্বর শুধুমাত্র আপনার প্রশিক্ষিত মন্ত্র গণনা করে। “$title” $min থেকে $max বার (প্রায় এক মিনিট) রেকর্ড করুন। এটি এই ডিভাইসেই থাকে এবং অফলাইনে কাজ করে।';
  }

  @override
  String get later => 'পরে';

  @override
  String get trainNow => 'এখনই প্রশিক্ষণ দিন';

  @override
  String get betaLabel => 'বিটা';

  @override
  String get voiceTrained => 'কণ্ঠস্বর প্রশিক্ষিত';

  @override
  String get voiceNotTrained => 'কণ্ঠস্বর প্রশিক্ষিত নয়';

  @override
  String get sensitivityLabel => 'সংবেদনশীলতা';

  @override
  String get sensitivityStrict => 'কঠোর';

  @override
  String get sensitivityLenient => 'শিথিল';

  @override
  String get sensitivityMedium => 'মাঝারি';

  @override
  String get clearVoiceTrainingTitle => 'কণ্ঠস্বর প্রশিক্ষণ মুছবেন?';

  @override
  String clearVoiceTrainingBody(String title) {
    return 'আপনি এটি আবার প্রশিক্ষণ না দেওয়া পর্যন্ত কণ্ঠস্বর “$title” গণনা বন্ধ করবে।';
  }

  @override
  String get completionTitle => 'সমাপ্তি';

  @override
  String get vibrationLabel => 'কম্পন';

  @override
  String vibrationSubtitle(int n) {
    return 'প্রতি $n গণনায় একটি কম্পন, এবং লক্ষ্যে আরও শক্তিশালী একটি।';
  }

  @override
  String intensityLevel(int level) {
    return 'তীব্রতা: স্তর $level এর মধ্যে 5';
  }

  @override
  String get testMilestone => 'টেস্ট মাইলস্টোন';

  @override
  String get testTarget => 'টেস্ট লক্ষ্য';

  @override
  String get ringtoneLabel => 'রিংটোন';

  @override
  String get ringtoneSubtitle => 'লক্ষ্যে পৌঁছালে একটি শব্দ বাজে।';

  @override
  String get playSound => 'শব্দ চালান';

  @override
  String get combined => 'সম্মিলিত';

  @override
  String get combinedTooltip => 'সব চারটি মোড একটি ভাগ করা গণনায় যোগ হয়';

  @override
  String get separate => 'পৃথক';

  @override
  String get separateTooltip => 'প্রতিটি মোড নিজস্ব গণনা রাখে';

  @override
  String get countModeSemantic => 'গণনা মোড';

  @override
  String get combinedExplain =>
      'ট্যাপ, কণ্ঠস্বর, রিদম এবং মালা সবই একটি লক্ষ্যের দিকে একটি ভাগ করা গণনায় যোগ হয়।';

  @override
  String get separateExplain =>
      'প্রতিটি মোড নিজস্ব গণনা এবং লক্ষ্যের দিকে নিজস্ব অগ্রগতি রাখে। রিসেট এবং সমাপ্তি শুধুমাত্র আপনি যে মোডে আছেন তাতে প্রযোজ্য।';

  @override
  String countedLabel(int count) {
    return '$count গণনা করা হয়েছে';
  }

  @override
  String ofTarget(int count) {
    return '$count এর মধ্যে';
  }

  @override
  String get removeOneTooltip => 'একটি সরান';

  @override
  String get undoLabel => 'পূর্বাবস্থায় ফেরান';

  @override
  String get countLabel => 'গণনা';

  @override
  String get addOneTooltip => 'একটি যোগ করুন';

  @override
  String get focusLabel => 'ফোকাস';

  @override
  String get focusModeTooltip => 'ফোকাস মোড';

  @override
  String get pause => 'বিরতি দিন';

  @override
  String get resume => 'আবার শুরু করুন';

  @override
  String get start => 'শুরু করুন';

  @override
  String targetReachedSeparate(String mode) {
    return '$mode-এ লক্ষ্য পূরণ হয়েছে 🙏  এই মোড রিসেট করুন, মোড পরিবর্তন করুন, বা লক্ষ্য বাড়ান।';
  }

  @override
  String get targetReachedCombined =>
      'লক্ষ্য পূরণ হয়েছে 🙏  রিসেট করুন, বা লক্ষ্য বাড়ান।';

  @override
  String resetModeCountTitle(String mode) {
    return '$mode গণনা রিসেট করবেন?';
  }

  @override
  String get resetSessionTitle => 'এই সেশন রিসেট করবেন?';

  @override
  String resetModeCountBody(String mode, int count) {
    return 'আপনার $mode গণনা $count শূন্যে ফিরে যাবে। অন্যান্য মোড তাদের গণনা রাখে।';
  }

  @override
  String resetSessionBody(int count) {
    return 'আপনার $count গণনা শূন্যে ফিরে যাবে।';
  }

  @override
  String get modeHelpTap =>
      'রিং-এ ট্যাপ করুন, বা ফোকাস মোডে যেকোনো জায়গায়। শুধুমাত্র ট্যাপ মোড স্ক্রিন ট্যাপ গণনা করে।';

  @override
  String get modeHelpRhythm =>
      'Start চাপুন এবং গণনা নিচের গতিতে নিজে থেকে বাড়ে।';

  @override
  String get modeHelpVoice =>
      'Start চাপুন, তারপর আপনার প্রশিক্ষিত মন্ত্র জপ করুন। প্রতিবার শনাক্ত হলে এটি সাথে সাথে একটি গণনা যোগ করে; অন্যান্য শব্দ উপেক্ষা করা হয়। মাইক্রোফোন প্রয়োজন; শান্ত ঘরে সবচেয়ে ভালো কাজ করে।';

  @override
  String get modeHelpMala =>
      'Start চাপুন, তারপর গণনা করতে যেকোনো ভলিউম বোতাম চাপুন। চোখ বন্ধ থাকলে বা ফোন পকেটে থাকলে সুবিধাজনক। স্ক্রিন চালু থাকা আবশ্যক।';

  @override
  String get countingModeLabel => 'গণনা মোড';

  @override
  String pacePrefix(String pace) {
    return 'গতি: গণনা $pace';
  }

  @override
  String modeSemanticLabel(String mode) {
    return '$mode মোড';
  }

  @override
  String get tapAnywhereToCount => 'গণনা করতে যেকোনো জায়গায় ট্যাপ করুন';

  @override
  String countingPace(String pace) {
    return 'গণনা $pace';
  }

  @override
  String pausedPace(String pace) {
    return 'বিরতি · $pace';
  }

  @override
  String get listening => 'শুনছে…';

  @override
  String get startingMicrophone =>
      'মাইক্রোফোন চালু হচ্ছে… জিজ্ঞাসা করা হলে অ্যাক্সেস দিন';

  @override
  String get notTrainedYet =>
      'এখনও প্রশিক্ষিত নয় · কণ্ঠস্বর ব্যবহার করতে মন্ত্র প্রশিক্ষণ দিন';

  @override
  String get pausedPressStartListen => 'বিরতি · শুনতে Start চাপুন';

  @override
  String get pressVolumeKeys => 'গণনা করতে ভলিউম কী চাপুন';

  @override
  String get capturingVolumeKeys => 'ভলিউম কী ক্যাপচার করা হচ্ছে…';

  @override
  String get pausedPressStartVolume =>
      'বিরতি · ভলিউম কী ব্যবহার করতে Start চাপুন';

  @override
  String modeTitleLine(String mode, String own) {
    String _temp0 = intl.Intl.selectLogic(own, {
      'yes': ' · নিজস্ব গণনা',
      'other': '',
    });
    return '$mode মোড$_temp0';
  }

  @override
  String voiceCountedMatch(int percent) {
    return 'গণনা করা হয়েছে · $percent% মিল';
  }

  @override
  String voiceIgnoredMatch(int percent) {
    return 'উপেক্ষা করা হয়েছে · $percent% মিল (আপনার মন্ত্র নয়)';
  }

  @override
  String get paceFieldLabel => 'গতি';

  @override
  String paceHelpOk(String pace, String range) {
    return '$pace গণনা করে। (অনুমোদিত: $range)';
  }

  @override
  String paceHelpError(String error, String pace) {
    return '$error এখনও $pace গণনা করছে।';
  }

  @override
  String get sankalpLabel => 'সংকল্প';

  @override
  String get sankalpHint => 'এই অনুশীলনের জন্য আপনার সংকল্প বলুন…';

  @override
  String get targetSectionTitle => 'লক্ষ্য';

  @override
  String get byCount => 'গণনা অনুযায়ী';

  @override
  String get byTime => 'সময় অনুযায়ী';

  @override
  String customWithValue(String value) {
    return 'কাস্টম · $value';
  }

  @override
  String get custom => 'কাস্টম';

  @override
  String get enterNumberRange => '1 থেকে 9,999,999 পর্যন্ত একটি সংখ্যা লিখুন';

  @override
  String get customCountTitle => 'কাস্টম গণনা';

  @override
  String get targetCountLabel => 'লক্ষ্য গণনা';

  @override
  String get setAction => 'সেট করুন';

  @override
  String get durationLabel => 'সময়কাল';

  @override
  String get enterDuration => '1 বা তার বেশি সময়কাল লিখুন।';

  @override
  String get maxDurationCapped =>
      'সর্বোচ্চ 99 ঘ 59 মি 59 সে — এটি সীমাবদ্ধ করা হবে।';

  @override
  String sessionLasts(String duration) {
    return 'সেশন $duration স্থায়ী হয়।';
  }

  @override
  String get targetReachedFocus => 'লক্ষ্য পূরণ হয়েছে 🙏';

  @override
  String screenTapsDoNotCount(String mode) {
    return '$mode মোডে স্ক্রিন ট্যাপ গণনা করা হয় না। ঠিক করতে + বা − ব্যবহার করুন।';
  }

  @override
  String holdFingersToExit(int fingers, int seconds) {
    return 'বের হতে $fingersটি আঙুল $seconds সেকেন্ড ধরে রাখুন';
  }

  @override
  String get holdToExitFocusMode => 'ফোকাস মোড থেকে বের হতে ধরে রাখুন';

  @override
  String get holdToExit => 'বের হতে ধরে রাখুন';

  @override
  String get keepHoldingToExit => 'বের হতে ধরে রাখুন…';

  @override
  String addedRecordingsTo(int added, String title, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'রেকর্ডিং',
      one: 'রেকর্ডিং',
    );
    return '“$title”-এ $addedটি $_temp0 যোগ করা হয়েছে (মোট $total)';
  }

  @override
  String voiceTrainedFor(String title, int count) {
    return '“$title”-এর জন্য কণ্ঠস্বর প্রশিক্ষিত ($countটি রেকর্ডিং)';
  }

  @override
  String trainedRecordingsCount(int count) {
    return 'প্রশিক্ষিত · $countটি রেকর্ডিং';
  }

  @override
  String get tooFewRecordings =>
      'গণনা করতে খুব কম রেকর্ডিং। আরও যোগ করুন, বা পুনরায় প্রশিক্ষণ দিন।';

  @override
  String canCountAddMore(int room) {
    return 'কণ্ঠস্বর এই মন্ত্র গণনা করতে পারে। নির্ভুলতা উন্নত করতে নতুন করে শুরু না করেই $roomটি আরও রেকর্ডিং যোগ করুন।';
  }

  @override
  String canCountAtMax(int max) {
    return 'কণ্ঠস্বর এই মন্ত্র গণনা করতে পারে। আপনার কাছে সর্বোচ্চ $maxটি রেকর্ডিং আছে; সেগুলি প্রতিস্থাপন করতে পুনরায় প্রশিক্ষণ দিন।';
  }

  @override
  String get pausedHeadline => 'বিরতি';

  @override
  String pausedSub(int recorded) {
    return '$recordedটি রেকর্ড করা হয়েছে। চালিয়ে যান, বা যা আছে তা সংরক্ষণ করুন।';
  }

  @override
  String recordInstructions(int min, int max, int recommended) {
    return 'আপনার স্বাভাবিক জপ গতিতে এটি $min থেকে $max বার রেকর্ড করুন ($recommendedটি একটি ভালো সংখ্যা)। তারপর কণ্ঠস্বর শুধু আপনার মন্ত্র গণনা করবে।';
  }

  @override
  String get openingMicrophone => 'মাইক্রোফোন খোলা হচ্ছে…';

  @override
  String get stayQuiet => 'একটু চুপ থাকুন…';

  @override
  String get listeningToRoom =>
      'পটভূমির শব্দ যাতে গণনা না হয় তাই ঘর শোনা হচ্ছে।';

  @override
  String get sayYourMantra => 'আপনার মন্ত্র বলুন…';

  @override
  String recordingXofY(int current, int max) {
    return '$current রেকর্ড হচ্ছে, সর্বোচ্চ $maxটির মধ্যে';
  }

  @override
  String allRecordingsCaptured(int count) {
    return 'সবগুলো $count রেকর্ডিং ক্যাপচার হয়েছে';
  }

  @override
  String get saveToStartCounting =>
      'কণ্ঠস্বর দিয়ে গণনা শুরু করতে এগুলি সংরক্ষণ করুন।';

  @override
  String get cannotUseMicrophone => 'মাইক্রোফোন ব্যবহার করা যাচ্ছে না';

  @override
  String get canSaveNowHint =>
      'আপনি এখনই সংরক্ষণ করতে পারেন, বা আরও নির্ভুলতার জন্য চালিয়ে যেতে পারেন।';

  @override
  String minAreEnough(int min) {
    return 'শুরু করতে $minটি যথেষ্ট।';
  }

  @override
  String addingToSaved(int count) {
    return 'আপনার $countটি সংরক্ষিত রেকর্ডিংয়ে যোগ করা হচ্ছে।';
  }

  @override
  String get tryAgain => 'আবার চেষ্টা করুন';

  @override
  String get startRecording => 'রেকর্ডিং শুরু করুন';

  @override
  String get openSettingsAction => 'সেটিংস খুলুন';

  @override
  String saveNRecordings(int count) {
    return '$countটি রেকর্ডিং সংরক্ষণ করুন';
  }

  @override
  String recordMoreToSave(int n) {
    return 'সংরক্ষণ করতে আরও $nটি রেকর্ড করুন';
  }

  @override
  String get recordSampleToSave => 'সংরক্ষণ করতে একটি নমুনা রেকর্ড করুন';

  @override
  String get undoLast => 'শেষটি পূর্বাবস্থায় ফেরান';

  @override
  String get stop => 'থামুন';

  @override
  String get continueRecording => 'রেকর্ডিং চালিয়ে যান';

  @override
  String get startOver => 'নতুন করে শুরু করুন';

  @override
  String recordedOfMax(int recorded, int max) {
    return '$recordedটি রেকর্ড হয়েছে, সর্বোচ্চ $maxটির মধ্যে';
  }

  @override
  String voiceBetaNoteTraining(int max) {
    return 'বিটা। সবকিছু এই ডিভাইসে, অফলাইনে ঘটে: শুধু শব্দ বর্ণনাকারী সংখ্যা সংরক্ষিত হয়, কখনো অডিও নয়। বেশি রেকর্ডিং গণনাকে আরও নির্ভুল করে (সর্বোচ্চ $max পর্যন্ত); কোলাহলপূর্ণ ঘর এটিকে কম নির্ভুল করে। মন্ত্র একবার বলুন, তারপর পরেরটির আগে একটু থামুন।';
  }

  @override
  String get actionClear => 'মুছুন';

  @override
  String get today => 'আজ';

  @override
  String get previousMonth => 'আগের মাস';

  @override
  String get nextMonth => 'পরের মাস';

  @override
  String get markTypeGood => 'ভালো';

  @override
  String get markTypeCautious => 'সতর্ক';

  @override
  String get markTypeNeutral => 'নিরপেক্ষ';

  @override
  String get reminderModeNone => 'কোনো সময় নয়';

  @override
  String get reminderModeOnce => 'একবার';

  @override
  String get reminderModeSeveral => 'কয়েকবার';

  @override
  String get repeatRuleOnce => 'একবার';

  @override
  String get repeatRuleDaily => 'প্রতিদিন';

  @override
  String get repeatRuleWeekly => 'সাপ্তাহিক';

  @override
  String get repeatRuleMonthly => 'মাসিক';

  @override
  String get repeatRuleQuarterly => 'ত্রৈমাসিক';

  @override
  String get repeatRuleHalfYearly => 'অর্ধ-বার্ষিক';

  @override
  String get repeatRuleYearly => 'বার্ষিক';

  @override
  String get homeModeNone => 'দেখাবেন না';

  @override
  String get homeModeMorning => 'সকালে একবার';

  @override
  String get homeModeAllDay => 'সারাদিন রাখুন';

  @override
  String get markStyleDot => 'ডট';

  @override
  String get markStyleFilled => 'পূর্ণ';

  @override
  String get markStyleHighlight => 'হাইলাইট';

  @override
  String get markStyleCircle => 'বৃত্ত';

  @override
  String get markStyleSquare => 'বর্গ';

  @override
  String get emojiOm => 'ॐ';

  @override
  String get emojiKhanda => 'খণ্ডা';

  @override
  String get emojiMala => 'মালা';

  @override
  String get emojiDiya => 'প্রদীপ';

  @override
  String get emojiBell => 'ঘণ্টা';

  @override
  String get emojiSunrise => 'সূর্যোদয়';

  @override
  String get emojiStar => 'তারা';

  @override
  String get emojiSparkle => 'ঝিলিক';

  @override
  String get emojiMoney => 'টাকা';

  @override
  String get emojiHandshake => 'করমর্দন';

  @override
  String get emojiAvoid => 'এড়িয়ে চলুন';

  @override
  String get emojiDone => 'সম্পন্ন';

  @override
  String get markTitleGood => 'ভালো দিন';

  @override
  String get markTitleCautious => 'সতর্ক দিন';

  @override
  String get markTitleNeutral => 'নিরপেক্ষ দিন';

  @override
  String get reminderBodyGood => 'একটি ভালো দিন।';

  @override
  String get reminderBodyCautious => 'আজ সতর্ক থাকুন।';

  @override
  String get reminderBodyNeutral => 'আপনার ক্যালেন্ডারে চিহ্নিত।';

  @override
  String get channelCalendarRemindersName => 'ক্যালেন্ডার রিমাইন্ডার';

  @override
  String get channelCalendarRemindersDesc =>
      'আপনি Sadho তে চিহ্নিত করা তারিখগুলির জন্য রিমাইন্ডার';

  @override
  String get channelAlarmsName => 'অ্যালার্ম এবং টাইমার';

  @override
  String get channelAlarmsDesc => 'সূর্য-ভিত্তিক অ্যালার্ম এবং সম্পন্ন টাইমার';

  @override
  String get repeatSummaryOnce => 'একবার';

  @override
  String get repeatSummaryDaily => 'প্রতিদিন';

  @override
  String get repeatSummaryWeekly => 'প্রতি সপ্তাহে';

  @override
  String get repeatSummaryMonthly => 'প্রতি মাসে';

  @override
  String get repeatSummaryQuarterly => 'প্রতি 3 মাসে';

  @override
  String get repeatSummaryHalfYearly => 'প্রতি 6 মাসে';

  @override
  String get repeatSummaryYearly => 'প্রতি বছর';

  @override
  String reminderSummaryAt(String times) {
    return '$times এ মনে করিয়ে দিন';
  }

  @override
  String homeSummaryFrom(String time) {
    return 'হোমে $time থেকে';
  }

  @override
  String get homeSummaryAllDay => 'হোমে সারাদিন';

  @override
  String marksInMonth(String month) {
    return '$month এ চিহ্ন';
  }

  @override
  String noMarksInMonth(String month) {
    return '$month এ কিছুই চিহ্নিত নেই। চিহ্ন যোগ করতে একটি তারিখ ট্যাপ করুন।';
  }

  @override
  String get markStyleSectionTitle => 'চিহ্ন শৈলী';

  @override
  String get markStyleSectionHint =>
      'চিহ্নিত তারিখগুলি কেমন দেখায়। প্রতিটি চিহ্নে প্রযোজ্য।';

  @override
  String markStyleSemantic(String style) {
    return '$style চিহ্ন শৈলী';
  }

  @override
  String get dayCellToday => ', আজ';

  @override
  String get dayCellAnd => 'এবং';

  @override
  String dayCellMarkedSuffix(int count, String kinds) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ', $kinds চিহ্নিত, $countটি চিহ্ন',
      one: ', $kinds চিহ্নিত, 1টি চিহ্ন',
    );
    return '$_temp0';
  }

  @override
  String get markEditorNoTimeWarning =>
      'কমপক্ষে একটি সময় যোগ করুন, বা \"কোনো সময় নয়\" বেছে নিন।';

  @override
  String get notificationsOffWarning =>
      'Sadho-এর জন্য বিজ্ঞপ্তি বন্ধ আছে, তাই এই রিমাইন্ডার বাজবে না। আপনার ফোনের সেটিংসে সেগুলো চালু করুন।';

  @override
  String get deleteMarkFallbackTitle => 'এই চিহ্ন';

  @override
  String get deleteMarkQuestion => 'এই চিহ্ন মুছবেন?';

  @override
  String deleteMarkRepeatsBody(String title) {
    return '$title এবং এর সমস্ত পুনরাবৃত্তি মুছবেন? এর রিমাইন্ডারও সরানো হবে।';
  }

  @override
  String deleteMarkBody(String title) {
    return '$title মুছবেন? এর রিমাইন্ডারও সরানো হবে।';
  }

  @override
  String get newMark => 'নতুন চিহ্ন';

  @override
  String get editMark => 'চিহ্ন সম্পাদনা করুন';

  @override
  String repeatFromNotice(String repeatSummary, String date) {
    return '$repeatSummary, $date থেকে। পরিবর্তনগুলি প্রতিটি পুনরাবৃত্তিতে প্রযোজ্য।';
  }

  @override
  String get markTypeSectionTitle => 'চিহ্নের ধরন';

  @override
  String get iconSectionTitle => 'আইকন';

  @override
  String get iconNone => 'কোনোটিই না';

  @override
  String get labelFieldLabel => 'লেবেল';

  @override
  String get detailsFieldLabel => 'বিবরণ / নোট';

  @override
  String get remindMeAtSectionTitle => 'আমাকে মনে করিয়ে দিন';

  @override
  String removeTimeTooltip(String time) {
    return '$time সরান';
  }

  @override
  String get addTime => 'সময় যোগ করুন';

  @override
  String get repeatSectionTitle => 'পুনরাবৃত্তি';

  @override
  String get onHomeScreenSectionTitle => 'আপনার হোম স্ক্রিনে';

  @override
  String showFromTime(String time) {
    return '$time থেকে দেখান';
  }

  @override
  String get homeModeNoneExplain => 'চিহ্ন শুধু ক্যালেন্ডারে থাকে।';

  @override
  String get homeModeMorningExplain =>
      'সেই সময়ে হোমে একটি কার্ড দেখা যায়। শেষ হলে সোয়াইপ করুন: এটি পরের পুনরাবৃত্তিতে ফিরে আসে।';

  @override
  String get homeModeAllDayExplain =>
      'একটি কার্ড হোমে সারাদিন পিন করা থাকে (এটি সোয়াইপ করা যায় না)।';

  @override
  String get tomorrow => 'আগামীকাল';

  @override
  String get yesterday => 'গতকাল';

  @override
  String get startAgain => 'আবার শুরু করুন';

  @override
  String get settingsAction => 'সেটিংস';

  @override
  String get clockToolClockSubtitle => 'একটি বড়, লাইভ সময় এবং তারিখ';

  @override
  String get clockToolSunAlarmTitle => 'সূর্য-ভিত্তিক অ্যালার্ম';

  @override
  String get clockToolSunAlarmSubtitle =>
      'সূর্যোদয় বা সূর্যাস্তে, অফসেট সহ জাগুন';

  @override
  String get clockToolWorldClockTitle => 'বিশ্ব ঘড়ি';

  @override
  String get clockToolWorldClockSubtitle => 'অমৃতসর, হরিদ্বার, লন্ডন এবং আরও';

  @override
  String get clockToolTimerTitle => 'সাধনা ও ব্রত টাইমার';

  @override
  String get clockToolTimerSubtitle =>
      'আরতি, চালিসা, পাঠ, হবন, বা সূর্যাস্ত পর্যন্ত';

  @override
  String get clockToolStopwatchTitle => 'পাঠ স্টপওয়াচ';

  @override
  String get clockToolStopwatchSubtitle => 'শুরু করুন, থামান এবং ল্যাপ করুন';

  @override
  String get sunEventSunrise => 'সূর্যোদয়';

  @override
  String get sunEventSunset => 'সূর্যাস্ত';

  @override
  String offsetAtEvent(String event) {
    return '$event এ';
  }

  @override
  String offsetMinutesOnly(int m) {
    return '$m মিনিট';
  }

  @override
  String offsetHoursOnly(int h) {
    return '$h ঘ';
  }

  @override
  String offsetHoursMinutes(int h, int m) {
    return '$h ঘ $m মিনিট';
  }

  @override
  String offsetBefore(String amount) {
    return '$amount আগে';
  }

  @override
  String offsetAfter(String amount) {
    return '$amount পরে';
  }

  @override
  String get locationSourceDevice => 'আপনার অবস্থান';

  @override
  String get locationSourceSaved => 'আপনার সর্বশেষ জানা অবস্থান';

  @override
  String get locationSourceFallback => 'অমৃতসর (ডিফল্ট)';

  @override
  String get locSummaryDevice => 'আপনার অবস্থান ব্যবহার করা হচ্ছে';

  @override
  String get locSummarySaved => 'আপনার সর্বশেষ জানা অবস্থান ব্যবহার করা হচ্ছে';

  @override
  String get locSummaryBlocked =>
      'অমৃতসর ব্যবহার করা হচ্ছে। সেটিংসে অবস্থান অবরুদ্ধ।';

  @override
  String get locSummaryServiceOff =>
      'অমৃতসর ব্যবহার করা হচ্ছে। সঠিক সময়ের জন্য অবস্থান চালু করুন।';

  @override
  String get locSummaryUnsupported => 'অমৃতসর ব্যবহার করা হচ্ছে।';

  @override
  String get locSummaryDefault =>
      'অমৃতসর ব্যবহার করা হচ্ছে। সঠিক সময়ের জন্য অবস্থানের অনুমতি দিন।';

  @override
  String get presetAarti => 'আরতি';

  @override
  String get presetChalisa => 'চালিসা';

  @override
  String get presetPath => 'পাঠ';

  @override
  String get presetHavan => 'হবন';

  @override
  String get vratToSunset => 'ব্রত → সূর্যাস্ত';

  @override
  String presetChipLabel(String label, int minutes) {
    return '$label · $minutes মিনিট';
  }

  @override
  String get clockNoSunsetHere => 'এখানে এখন গণনা করার মতো কোনো সূর্যাস্ত নেই।';

  @override
  String get clockSunsetPassedTomorrow =>
      'আজকের সূর্যাস্ত পার হয়ে গেছে: আগামীকালের জন্য গণনা হচ্ছে।';

  @override
  String timerFinishedTitle(String label) {
    return '🔔 $label সম্পন্ন';
  }

  @override
  String get sunsetArrived => 'সূর্যাস্ত হয়েছে 🙏';

  @override
  String timerTimeUp(String label) {
    return 'আপনার $label সময় শেষ হয়ে গেছে 🙏';
  }

  @override
  String sunAlarmNotifTitle(String emoji, String event) {
    return '$emoji $event অ্যালার্ম';
  }

  @override
  String sunAlarmNotifBody(String event, String time, String offset) {
    return '$event $time এ · $offset';
  }

  @override
  String get statusOn => 'চালু';

  @override
  String get finished => 'সম্পন্ন';

  @override
  String get left => 'বাকি';

  @override
  String get paused => 'বিরতি';

  @override
  String get runningStatus => 'চলছে';

  @override
  String get stoppedStatus => 'থেমেছে';

  @override
  String get lap => 'ল্যাপ';

  @override
  String get lapTime => 'ল্যাপ সময়';

  @override
  String get total => 'মোট';

  @override
  String get fastest => 'দ্রুততম';

  @override
  String get slowest => 'সবচেয়ে ধীর';

  @override
  String get tapLapToMark => 'ল্যাপ চিহ্নিত করতে Lap ট্যাপ করুন।';

  @override
  String get startThenTapLap =>
      'Start করুন, তারপর প্রতি রাউন্ডে Lap ট্যাপ করুন।';

  @override
  String get allowNotificationsForAlarm =>
      'অ্যালার্ম বাজতে সেটিংসে বিজ্ঞপ্তি চালু করুন।';

  @override
  String get alarmRingsAt => 'অ্যালার্ম বাজবে';

  @override
  String get alarmWouldRingAt => 'অ্যালার্ম বাজত';

  @override
  String noEventToFollow(String event) {
    return 'এখানে এখন অনুসরণ করার মতো কোনো $event নেই।';
  }

  @override
  String get alarmOnLabel => 'অ্যালার্ম চালু';

  @override
  String get recalculatedDaily =>
      'সূর্যের চলাচলের সাথে প্রতিদিন পুনর্গণনা করা হয়';

  @override
  String todayHereSunriseSunset(String rise, String set) {
    return 'এখানে আজ: সূর্যোদয় $rise · সূর্যাস্ত $set';
  }

  @override
  String get whenLabel => 'কখন';

  @override
  String get minutesLabel => 'মিনিট';

  @override
  String get upTo1440 => '1440 পর্যন্ত';

  @override
  String get before => 'আগে';

  @override
  String get after => 'পরে';

  @override
  String get useMyLocation => 'আমার অবস্থান ব্যবহার করুন';

  @override
  String get couldNotReadPosition => ' · আপনার অবস্থান পড়া যায়নি';

  @override
  String get timesUp => 'সময় শেষ 🙏';

  @override
  String sunsetAtTime(String time) {
    return 'সূর্যাস্ত $time এ';
  }

  @override
  String cityInDays(int days) {
    return '$days দিনে';
  }

  @override
  String cityDaysAgo(int days) {
    return '$days দিন আগে';
  }

  @override
  String get citySameTime => 'আপনার মতো একই সময়';

  @override
  String cityAmountMinutes(int m) {
    return '$m মি';
  }

  @override
  String cityAmountHours(int h) {
    return '$h ঘ';
  }

  @override
  String cityAmountHoursMinutes(int h, int m) {
    return '$h ঘ $m মি';
  }

  @override
  String cityAheadOfYou(String amount) {
    return 'আপনার চেয়ে $amount এগিয়ে';
  }

  @override
  String cityBehindYou(String amount) {
    return 'আপনার চেয়ে $amount পিছিয়ে';
  }

  @override
  String get traditionHindu => 'হিন্দু';

  @override
  String get traditionSikh => 'শিখ';

  @override
  String get traditionPlace => 'স্থান অনুযায়ী';

  @override
  String get todayLabelTithi => 'তিথি';

  @override
  String get todayLabelNakshatra => 'নক্ষত্র';

  @override
  String get todayLabelRahu => 'রাহু কাল';

  @override
  String get todayLabelAbhijit => 'অভিজিৎ মুহূর্ত';

  @override
  String get todayLabelHukamnama => 'হুকুমনামা';

  @override
  String get todayLabelNitnem => 'নিত্নেম বাকি';

  @override
  String get todayLabelGurpurab => 'পরবর্তী গুরুপরব';

  @override
  String get todayLabelFestival => 'স্থানীয় উৎসব';

  @override
  String get todayLabelWindow => 'শুভ সময়';

  @override
  String get exampleTag => 'উদাহরণ';

  @override
  String get exampleNote =>
      'উদাহরণ চিহ্নিত মানগুলি প্লেসহোল্ডার: প্রকৃত পঞ্জিকা ডেটা পরের ধাপে আসবে।';

  @override
  String liveNote(String where) {
    return 'সূর্যোদয় এবং সূর্যাস্ত আপনার অবস্থানের জন্য বের করা হয়েছে। $where.';
  }

  @override
  String get greetingMorning => 'শুভ সকাল';

  @override
  String get greetingAfternoon => 'শুভ অপরাহ্ন';

  @override
  String get greetingEvening => 'শুভ সন্ধ্যা';

  @override
  String get greetingNight => 'শুভ রাত্রি';

  @override
  String get homeEmptyTitle => 'আজ আপনার হোম স্ক্রিনে কিছু নেই';

  @override
  String get homeEmptyBody =>
      'ক্যালেন্ডারে একটি তারিখ চিহ্নিত করুন এবং এখানে দেখতে \"আপনার হোম স্ক্রিনে\" বেছে নিন।';

  @override
  String get pinnedAllDay => 'সারাদিন পিন করা';

  @override
  String get swipeToDismiss => 'আজকের জন্য সরাতে সোয়াইপ করুন';

  @override
  String doneForToday(String title) {
    return 'আজকের জন্য সম্পন্ন: $title';
  }

  @override
  String get undoAction => 'পূর্বাবস্থায় ফেরান';

  @override
  String get doneForTodayLabel => 'আজকের জন্য সম্পন্ন';

  @override
  String get plansTitle => 'পাঠ ও মন্ত্র পরিকল্পনা';

  @override
  String get addPlan => 'পরিকল্পনা যোগ করুন';

  @override
  String get dayStreak => 'দিনের ধারাবাহিকতা';

  @override
  String activePlanCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'সক্রিয় পরিকল্পনা',
      one: 'সক্রিয় পরিকল্পনা',
    );
    return '$_temp0';
  }

  @override
  String get noPlansYet => 'এখনো কোনো পরিকল্পনা নেই';

  @override
  String get plansEmptyBody =>
      'একটি পাঠ বা মন্ত্রের জন্য কয়েক দিন প্রতিশ্রুতিবদ্ধ থাকুন এবং প্রতিদিন চিহ্নিত করুন। এর মধ্যে একটি দিয়ে শুরু করুন, বা নিজের তৈরি করুন।';

  @override
  String get planOptionsTooltip => 'পরিকল্পনার বিকল্প';

  @override
  String get deletePlanMenuItem => 'পরিকল্পনা মুছুন';

  @override
  String get deletePlanQuestion => 'পরিকল্পনা মুছবেন?';

  @override
  String deletePlanBody(String title) {
    return '$title এবং এর অগ্রগতি সরানো হবে।';
  }

  @override
  String titledDaysTag(String title, int days) {
    return '$title · $days দিন';
  }

  @override
  String completedOfDays(int completed, int total) {
    return 'সম্পন্ন · $total এর মধ্যে $completed দিন';
  }

  @override
  String ofDays(int completed, int total) {
    return '$total এর মধ্যে $completed দিন';
  }

  @override
  String get doneTodayButton => 'আজ সম্পন্ন';

  @override
  String get markTodayDone => 'আজ সম্পন্ন চিহ্নিত করুন';

  @override
  String get newPlanTitle => 'নতুন পরিকল্পনা';

  @override
  String get newPlanSubtitle =>
      'একটি পাঠ বা মন্ত্র বেছে নিন এবং আপনি এটি কত দিন চালিয়ে যাবেন।';

  @override
  String get paathOrMantraLabel => 'পাঠ বা মন্ত্র';

  @override
  String get giveThePlanAName => 'পরিকল্পনাকে একটি নাম দিন';

  @override
  String chooseDaysRange(int min, int max) {
    return '$min থেকে $max দিন বেছে নিন';
  }

  @override
  String get forHowManyDays => 'কত দিনের জন্য?';

  @override
  String get daysFieldLabel => 'দিন';

  @override
  String get startPlanButton => 'পরিকল্পনা শুরু করুন';

  @override
  String get planKindPaath => 'পাঠ';

  @override
  String get planKindMantra => 'মন্ত্র';

  @override
  String get profileTitle => 'প্রোফাইল';

  @override
  String get sadhanaSettingsTitle => 'সাধনা সেটিংস';

  @override
  String get validEmailError => 'একটি বৈধ ইমেইল ঠিকানা লিখুন';

  @override
  String nameTooLong(int max) {
    return 'এটি $max অক্ষরের কম রাখুন';
  }

  @override
  String get enterCurrentPassword => 'আপনার বর্তমান পাসওয়ার্ড লিখুন';

  @override
  String passwordTooShort(int min) {
    return 'কমপক্ষে $minটি অক্ষর ব্যবহার করুন';
  }

  @override
  String get passwordAlreadyUsed =>
      'এমন একটি পাসওয়ার্ড বেছে নিন যা আপনি আগে ব্যবহার করেননি';

  @override
  String get passwordsDontMatch => 'দুটি পাসওয়ার্ড মেলে না';

  @override
  String get changePasswordTitle => 'পাসওয়ার্ড পরিবর্তন করুন';

  @override
  String get accountsLaterNote =>
      'অ্যাকাউন্ট পরের ধাপে আসবে; ততক্ষণ এটি শুধু আপনার এন্ট্রি পরীক্ষা করে এবং কিছু পরিবর্তন করে না।';

  @override
  String get currentPasswordLabel => 'বর্তমান পাসওয়ার্ড';

  @override
  String get newPasswordLabel => 'নতুন পাসওয়ার্ড';

  @override
  String get confirmNewPasswordLabel => 'নতুন পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get showPasswords => 'পাসওয়ার্ড দেখান';

  @override
  String get updatePasswordButton => 'পাসওয়ার্ড আপডেট করুন';

  @override
  String get stepAddName => 'আপনার নাম যোগ করুন';

  @override
  String get stepAddEmail => 'আপনার ইমেইল যোগ করুন';

  @override
  String get stepPickTradition => 'হোমে আপনার ঐতিহ্য বেছে নিন';

  @override
  String get stepTurnOnReminder => 'দৈনিক রিমাইন্ডার চালু করুন';

  @override
  String get stepStartPlan => 'একটি পাঠ বা মন্ত্র পরিকল্পনা শুরু করুন';

  @override
  String get profileCompletionTitle => 'প্রোফাইল সমাপ্তি';

  @override
  String get profileCompleteReward =>
      'প্রোফাইল সম্পূর্ণ! প্রিমিয়াম চালু হলে আপনার ফ্রি প্রিমিয়াম পুরস্কার অপেক্ষা করবে।';

  @override
  String get reachRewardNote => 'চালু হলে ফ্রি প্রিমিয়াম পেতে 100% এ পৌঁছান।';

  @override
  String get aboutTitle => 'সম্পর্কে';

  @override
  String get appLabel => 'অ্যাপ';

  @override
  String get websiteLabel => 'ওয়েবসাইট';

  @override
  String get versionLabel => 'সংস্করণ';

  @override
  String get passwordWillWorkLater =>
      'অ্যাকাউন্ট যুক্ত হওয়ার পর পাসওয়ার্ড পরিবর্তন কাজ করবে।';

  @override
  String get signedOut => 'সাইন আউট হয়েছে';

  @override
  String get notSignedInYet =>
      'আপনি এখনো সাইন ইন করেননি: অ্যাকাউন্ট পরের ধাপে আসবে। আপনার ডেটা এই ফোনেই থাকে।';

  @override
  String get accountTitle => 'অ্যাকাউন্ট';

  @override
  String get signOutButton => 'সাইন আউট করুন';

  @override
  String get backupSaved => 'ব্যাকআপ সংরক্ষিত হয়েছে';

  @override
  String get backupCancelled => 'ব্যাকআপ বাতিল হয়েছে';

  @override
  String get couldNotSaveBackup =>
      'ব্যাকআপ সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get backupNotSadho => 'সেই ফাইলটি Sadho ব্যাকআপ নয়।';

  @override
  String get couldNotReadFile => 'সেই ফাইল পড়া যায়নি।';

  @override
  String get backupDamaged => 'ব্যাকআপ ফাইল ক্ষতিগ্রস্ত।';

  @override
  String get backupTooNew =>
      'এই ব্যাকআপ Sadho এর নতুন সংস্করণ দিয়ে তৈরি হয়েছিল। প্রথমে অ্যাপ আপডেট করুন।';

  @override
  String get backupNoData => 'সেই ব্যাকআপে কোনো Sadho ডেটা নেই।';

  @override
  String get backupTooBig => 'সেই ফাইলটি Sadho ব্যাকআপ হওয়ার জন্য খুব বড়।';

  @override
  String madeOnSuffix(String date) {
    return ' $date এ তৈরি';
  }

  @override
  String restoreBackupBody(String made, int count) {
    return 'একটি ব্যাকআপ$made যাতে $countটি সংরক্ষিত আইটেম আছে। এটি এই ফোনে থাকা জিনিস প্রতিস্থাপন করবে: চিহ্ন, পরিকল্পনা, মন্ত্র, কণ্ঠস্বর প্রশিক্ষণ এবং সেটিংস।';
  }

  @override
  String get restoreThisBackup => 'এই ব্যাকআপ পুনরুদ্ধার করবেন?';

  @override
  String get backupRestoredTitle => 'ব্যাকআপ পুনরুদ্ধার হয়েছে';

  @override
  String get backupRestoredBody =>
      'Sadho আপনার পুনরুদ্ধার করা ডেটা সহ আবার লোড হবে।';

  @override
  String get backupRestoreTitle => 'ব্যাকআপ ও পুনরুদ্ধার';

  @override
  String get backupExplain =>
      'আপনার চিহ্ন, পরিকল্পনা, মন্ত্র, কণ্ঠস্বর প্রশিক্ষণ এবং সেটিংস আপনার পছন্দের ফাইলে সংরক্ষণ করুন (Drive, Files, নিজেকে ইমেইল করুন)। এটি এই বা অন্য ফোনে পুনরুদ্ধার করুন।';

  @override
  String get exportButton => 'এক্সপোর্ট';

  @override
  String get restoreButton => 'পুনরুদ্ধার করুন';

  @override
  String get cloudSyncTitle => 'ক্লাউড সিঙ্ক';

  @override
  String get comingLater => 'পরে আসছে';

  @override
  String get saveBackupDialogTitle => 'আপনার Sadho ব্যাকআপ সংরক্ষণ করুন';

  @override
  String get chooseBackupDialogTitle => 'একটি Sadho ব্যাকআপ বেছে নিন';

  @override
  String get areYouSure => 'আপনি কি নিশ্চিত?';

  @override
  String get deleteAccountWarning =>
      'এটি আপনার অ্যাকাউন্ট এবং এই ফোনে সংরক্ষিত সবকিছু মুছে দেয়: আপনার প্রোফাইল, চিহ্ন, পরিকল্পনা, মন্ত্র, কণ্ঠস্বর প্রশিক্ষণ এবং সেটিংস। এটি পূর্বাবস্থায় ফেরানো যায় না।';

  @override
  String get yesAction => 'হ্যাঁ';

  @override
  String get noAction => 'না';

  @override
  String get dangerZoneTitle => 'বিপদ অঞ্চল';

  @override
  String get deleteAccountExplain =>
      'আপনার অ্যাকাউন্ট মুছে ফেললে আপনার প্রোফাইল এবং এই ফোনে সংরক্ষিত সবকিছু মুছে যায়। আপনি যদি এটি ফেরত চান তাহলে প্রথমে ব্যাকআপ এক্সপোর্ট করুন।';

  @override
  String get deleteAccountButton => 'অ্যাকাউন্ট মুছুন';

  @override
  String get profileSaved => 'প্রোফাইল সংরক্ষিত হয়েছে';

  @override
  String get yourDetailsTitle => 'আপনার বিবরণ';

  @override
  String get nameLabel => 'নাম';

  @override
  String get emailLabel => 'ইমেইল';

  @override
  String get dailyReminderTitle => 'দৈনিক রিমাইন্ডার';

  @override
  String get dailySadhanaReminder => 'দৈনিক সাধনা রিমাইন্ডার';

  @override
  String get reminderOff => 'বন্ধ';

  @override
  String everyDayAt(String time) {
    return 'প্রতিদিন $time';
  }

  @override
  String get allowNotificationsForReminder =>
      'রিমাইন্ডার বাজতে সেটিংসে বিজ্ঞপ্তি চালু করুন।';

  @override
  String get timeLabel => 'সময়';

  @override
  String get themeTitle => 'থিম';

  @override
  String get lightMode => 'লাইট';

  @override
  String get darkMode => 'ডার্ক';

  @override
  String get systemMode => 'সিস্টেম';

  @override
  String get coloursTitle => 'রং';

  @override
  String paletteSemantic(String name) {
    return '$name রং';
  }

  @override
  String get paletteMarigoldName => 'গাঁদা';

  @override
  String get paletteMarigoldBlurb => 'উষ্ণ জাফরান এবং গাঢ় নীল';

  @override
  String get paletteSandalwoodName => 'চন্দন';

  @override
  String get paletteSandalwoodBlurb => 'নরম চন্দন বাদামী এবং মাটি';

  @override
  String get paletteTulsiName => 'তুলসী সবুজ';

  @override
  String get paletteTulsiBlurb => 'শান্ত পবিত্র-তুলসী সবুজ';

  @override
  String get paletteTwilightName => 'গোধূলি নীল';

  @override
  String get paletteTwilightBlurb => 'প্রদীপ-দীপ্তি সোনালী সহ গোধূলি নীল';

  @override
  String get paletteLotusName => 'পদ্ম গোলাপি';

  @override
  String get paletteLotusBlurb => 'কোমল পদ্ম গোলাপি এবং পাতা সবুজ';

  @override
  String get sadhanaTimeNotifTitle => '🪔 আপনার সাধনার সময়';

  @override
  String get sadhanaTimeNotifBody =>
      'আপনার পাঠ বা মন্ত্রের জন্য কিছু শান্ত মিনিট নিন 🙏';

  @override
  String get comingSoon => 'শীঘ্রই আসছে';

  @override
  String get trainAction => 'প্রশিক্ষণ দিন';

  @override
  String get onboardingTitle => 'Sadho তে আপনাকে স্বাগতম';

  @override
  String get onboardingSubtitle =>
      'শুরু করতে আপনার ভাষা এবং ঐতিহ্য বেছে নিন। আপনি উভয়ই পরে প্রোফাইলে পরিবর্তন করতে পারেন।';

  @override
  String get traditionHeading => 'ঐতিহ্য';

  @override
  String get continueAction => 'চালিয়ে যান';

  @override
  String get stopAlert => 'থামান';

  @override
  String get repeatLabel => 'পুনরাবৃত্তি';

  @override
  String get repeatOnce => 'একবার';

  @override
  String soundRepeatTimes(int times) {
    return '$times বার';
  }

  @override
  String get repeatUntilStopped => 'থামানো পর্যন্ত';

  @override
  String vibrationRepeatUntilStopped(int seconds) {
    return 'প্রতি $seconds সেকেন্ডে, থামানো পর্যন্ত';
  }

  @override
  String get keepScreenOnLabel => 'গণনার সময় স্ক্রিন চালু রাখুন';

  @override
  String get keepScreenOnSubtitle =>
      'সেশন চলার সময় স্ক্রিন ঘুমিয়ে পড়ে না। পাওয়ার বোতামে ফোন তবুও লক হয়; তখন সময় বা ছন্দের সেশন শেষ হলে অ্যালার্মের মতো বাজে।';

  @override
  String get alarmMayBeLate =>
      'অ্যালার্ম একটু দেরিতে বাজতে পারে (সঠিক অ্যালার্ম বন্ধ)।';

  @override
  String get exactAlarmNotice =>
      'স্ক্রিন বন্ধ থাকলেও ঠিক সময়ে বাজাতে, Sadho-কে সঠিক অ্যালার্মের অনুমতি দিন।';

  @override
  String get fullScreenNotice =>
      'শেষ হওয়া সেশন লক স্ক্রিনে দেখাতে, ফুল-স্ক্রিন সতর্কতার অনুমতি দিন।';

  @override
  String get allowAction => 'অনুমতি দিন';

  @override
  String channelSadhanaAlarmName(String sound) {
    return 'সাধনা অ্যালার্ম · $sound';
  }

  @override
  String get channelSadhanaAlarmSilentName => 'সাধনা অ্যালার্ম · নীরব';

  @override
  String get channelNoVibration => 'কম্পন নেই';

  @override
  String get channelSadhanaAlarmDesc => 'সময় বা ছন্দের সেশন শেষ হলে বাজে';

  @override
  String get alarmScreenSadhanaTitle => 'সাধনা সম্পূর্ণ 🙏';

  @override
  String get alarmScreenTimerTitle => 'টাইমার শেষ';

  @override
  String get alarmScreenSunTitle => 'সূর্য অ্যালার্ম';

  @override
  String get alarmScreenUnlock => 'Sadho খুলতে আনলক করুন';

  @override
  String get alarmScreenUnlockHint =>
      'অ্যাপের বাকি অংশের জন্য ফোন আনলক থাকতে হবে।';

  @override
  String get alarmsReliabilityTitle => 'অ্যালার্ম ও নির্ভরযোগ্যতা';

  @override
  String get alarmsReliabilityIntro =>
      'স্ক্রিন বন্ধ থাকলেও অ্যালার্ম ঠিক সময়ে বাজাতে ফোনকে এগুলো অনুমতি দিতে হবে। ঠিক করুন সঠিক সেটিংস পাতা খোলে।';

  @override
  String get alarmsReliabilityAllOk =>
      'অ্যালার্ম ঠিক সময়ে বাজার জন্য সব প্রস্তুত';

  @override
  String get alarmsReliabilityAttention => 'কিছু মনোযোগ দরকার';

  @override
  String get healthOk => 'ঠিক আছে';

  @override
  String get healthNeedsAttention => 'মনোযোগ দিন';

  @override
  String get healthFix => 'ঠিক করুন';

  @override
  String get healthNotificationsTitle => 'বিজ্ঞপ্তির অনুমতি';

  @override
  String get healthNotificationsBody =>
      'অ্যালার্ম ও রিমাইন্ডার বিজ্ঞপ্তি হিসেবে আসে।';

  @override
  String get healthExactTitle => 'সঠিক অ্যালার্মের অনুমতি';

  @override
  String get healthExactBody => 'ঠিক সেই সেকেন্ডে বাজে, একটু দেরিতে নয়।';

  @override
  String get healthFullScreenTitle => 'লক স্ক্রিনে অ্যালার্ম দেখান';

  @override
  String get healthFullScreenBody =>
      'ফোন লক থাকলেও শেষ হওয়া অ্যালার্ম দেখা যায়।';

  @override
  String get healthBatteryTitle => 'ব্যাটারি: অ্যাপ সীমাবদ্ধ নয়';

  @override
  String get healthBatteryBody =>
      'ব্যাটারিতে অসীমাবদ্ধ বেছে নিন (অন্তত সীমাবদ্ধ নয়), যাতে ফোন অ্যালার্ম আটকে না রাখে।';

  @override
  String get healthBatterySamsungHint =>
      'Samsung: সেটিংস › ব্যাটারি › ব্যাকগ্রাউন্ড ব্যবহারের সীমায়, Sadho-কে “স্লিপিং অ্যাপস” ও “ডিপ স্লিপিং অ্যাপস” থেকে সরান, এবং ব্যাটারি ব্যবহার “অসীমাবদ্ধ” করুন।';

  @override
  String get alarmExplainerOk =>
      'এই সেশন শেষ হলে অ্যালার্মের মতো বাজবে, স্ক্রিন বা অ্যাপ বন্ধ থাকলেও।';

  @override
  String get alarmExplainerAttention =>
      'এই সেশন শেষ হলে অ্যালার্মের মতো বাজবে, তবে ঠিক সময়ে বাজাতে ফোনের একটি সেটিং বদলাতে হবে।';

  @override
  String get alarmExplainerCheck => 'দেখুন';

  @override
  String get customTimerName => 'কাস্টম টাইমার';

  @override
  String customChipLabel(String duration) {
    return 'কাস্টম · $duration';
  }

  @override
  String get customTimerTitle => 'নিজের সময়কাল';

  @override
  String get customTimerRange => '1 সেকেন্ড থেকে 24 ঘণ্টার মধ্যে বেছে নিন।';

  @override
  String durationHours(int hours) {
    return '$hours ঘণ্টা';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes মিনিট';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds সেকেন্ড';
  }

  @override
  String collapseSection(String section) {
    return '$section লুকান';
  }

  @override
  String expandSection(String section) {
    return '$section দেখান';
  }

  @override
  String get summaryVibrationOn => 'কম্পন চালু';

  @override
  String get summaryVibrationOff => 'কম্পন বন্ধ';

  @override
  String get summarySoundOff => 'শব্দ বন্ধ';

  @override
  String get summaryNotSet => 'ঠিক করা নেই';

  @override
  String get clockToolNotepadTitle => 'নোটপ্যাড';

  @override
  String get clockToolNotepadSubtitle => 'নোট, এই ফোনেই রাখা';

  @override
  String get notesSearchHint => 'নোট খুঁজুন';

  @override
  String get notesEmpty => 'এখনও কোনো নোট নেই। লিখতে + চাপুন।';

  @override
  String notesNoMatch(String query) {
    return '“$query” এর সাথে কোনো নোট মেলেনি।';
  }

  @override
  String get noteNew => 'নতুন নোট';

  @override
  String get noteEdit => 'নোট';

  @override
  String get noteTitleHint => 'শিরোনাম (ঐচ্ছিক)';

  @override
  String get noteTextHint => 'এখানে লিখুন…';

  @override
  String get noteUntitled => 'খালি নোট';

  @override
  String noteCreatedAt(String when) {
    return 'তৈরি $when';
  }

  @override
  String noteEditedAt(String when) {
    return 'সম্পাদিত $when';
  }

  @override
  String get noteSavedAsYouType => 'লেখার সময়ই সংরক্ষিত হয়';

  @override
  String get noteDelete => 'নোট মুছুন';

  @override
  String get noteDeleteQuestion => 'এই নোটটি মুছবেন?';

  @override
  String noteDeleteBody(String title) {
    return '“$title” এই ফোন থেকে মুছে যাবে। এটি ফেরানো যাবে না।';
  }

  @override
  String get paletteHighContrastName => 'উচ্চ কনট্রাস্ট';

  @override
  String get paletteHighContrastBlurb =>
      'সবচেয়ে স্পষ্ট পার্থক্য, সহজে পড়ার জন্য';

  @override
  String get malaNotificationChannel => 'মালা কাউন্টার';

  @override
  String malaNotificationTitle(String count, String target) {
    return 'মালা · $count / $target';
  }

  @override
  String malaNotificationTitleCount(String count) {
    return 'মালা · $count';
  }

  @override
  String get malaNotificationRunning =>
      'গণনা করতে ভলিউম কী চাপুন, স্ক্রিন বন্ধ থাকলেও।';

  @override
  String get malaNotificationDone => 'লক্ষ্য পূর্ণ 🙏';

  @override
  String get malaRingTitle => '🔔 মালা সম্পূর্ণ';

  @override
  String malaRingBody(int target) {
    return 'আপনি $target-এর লক্ষ্য পূরণ করেছেন 🙏';
  }

  @override
  String get malaScreenOffUnavailable =>
      'এই ফোনে স্ক্রিন বন্ধ অবস্থায় গণনা শুরু করা যায়নি। Sadho খোলা থাকলেই কেবল ভলিউম কী গুনবে।';

  @override
  String get pressVolumeKeysScreenOff => 'ভলিউম কী গোনে, স্ক্রিন বন্ধ থাকলেও';

  @override
  String get malaScreenOffLabel => 'স্ক্রিন বন্ধ থাকলেও গুনুন';

  @override
  String get malaScreenOffOnSubtitle =>
      'ফোন লক করুন এবং ভলিউম কী চাপতে থাকুন। একটি বিজ্ঞপ্তি গণনা দেখায় এবং লক্ষ্যে বাজে।';

  @override
  String get malaScreenOffOffSubtitle =>
      'বন্ধ: Sadho খোলা ও স্ক্রিন চালু থাকলেই কেবল ভলিউম কী গোনে।';

  @override
  String get modeHelpMalaScreenOff =>
      'Start চাপুন, তারপর গুনতে যেকোনো ভলিউম কী চাপুন, ফোন লক ও স্ক্রিন বন্ধ থাকলেও। চোখ বন্ধ করে বা ফোন পকেটে রেখে সুবিধাজনক।';

  @override
  String get malaScreenOffExplainer =>
      'ফোন লক করে গুনতে ভলিউম কী চাপুন। ব্যাটারি \'অপ্রতিবন্ধিত\' করুন।';

  @override
  String get calibrateTitle => 'কণ্ঠ ক্যালিব্রেট করুন';

  @override
  String calibrateIntro(int count) {
    return 'আপনার মন্ত্র $count বার জপ করুন, যেমন সাধারণত করেন, প্রতিবার একটু থেমে। তারপর Sadho ঠিক করে কণ্ঠ কতটা কঠোর হবে, যাতে সবগুলো গোনা হয় আর ঘরের আওয়াজ নয়। কিছুই রেকর্ড বা রাখা হয় না।';
  }

  @override
  String calibrateChantNow(int count) {
    return 'এখন আপনার মন্ত্র $count বার জপ করুন';
  }

  @override
  String calibrateHeard(int heard, int count) {
    return '$count-এর মধ্যে $heard শোনা হয়েছে';
  }

  @override
  String calibrateSkipped(int count) {
    return 'এক জপ নয় এমন $countটি শব্দ বাদ দেওয়া হয়েছে';
  }

  @override
  String get calibrateDone => 'ক্যালিব্রেট হয়েছে';

  @override
  String calibrateDoneBody(int count) {
    return 'সব $countটি জপ গোনা হবে; ঘরের আওয়াজ নয়।';
  }

  @override
  String get calibrateStart => 'ক্যালিব্রেশন শুরু করুন';

  @override
  String get calibrateSave => 'ক্যালিব্রেশন সংরক্ষণ করুন';

  @override
  String calibrationSaved(String mantra) {
    return '“$mantra”-এর ক্যালিব্রেশন সংরক্ষিত';
  }

  @override
  String get calibrateVoice => 'ক্যালিব্রেট করুন';

  @override
  String get recalibrateVoice => 'আবার ক্যালিব্রেট করুন';
}
