// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navSadhana => 'Sadhana';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navClock => 'Clock';

  @override
  String get tooltipLanguage => 'Language';

  @override
  String get tooltipProfile => 'Profile';

  @override
  String get tooltipSwitchToLight => 'Switch to light theme';

  @override
  String get tooltipSwitchToDark => 'Switch to dark theme';

  @override
  String get languageSheetTitle => 'Language';

  @override
  String get languageSheetSubtitle =>
      'Your choice is saved and applies right away.';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionSave => 'Save';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionOk => 'OK';

  @override
  String get unitSeconds => 'Seconds';

  @override
  String get unitMinutes => 'Minutes';

  @override
  String get unitHours => 'Hours';

  @override
  String get paceErrorEmpty => 'Enter a pace.';

  @override
  String get paceErrorNotNumber => 'That is not a number.';

  @override
  String paceErrorTooFast(String min) {
    return 'Too fast. The minimum is $min.';
  }

  @override
  String paceErrorTooSlow(String max) {
    return 'Too slow. The maximum is $max.';
  }

  @override
  String get modeTap => 'Tap';

  @override
  String get modeRhythm => 'Rhythm';

  @override
  String get modeVoice => 'Voice';

  @override
  String get modeMala => 'Mala';

  @override
  String get ringtoneTempleBell => 'Temple bell';

  @override
  String get ringtoneSingingBowl => 'Singing bowl';

  @override
  String get ringtoneSoftChime => 'Soft chime';

  @override
  String get ringtoneDeepGong => 'Deep gong';

  @override
  String get msgVoiceUnsupported =>
      'Voice counting works on Android and iOS only';

  @override
  String get msgVoiceNoMic => 'No microphone available on this device';

  @override
  String get msgMalaUnsupported =>
      'Volume-key counting needs a physical device';

  @override
  String trainFirstPrompt(int min, int max) {
    return 'Train your voice for this mantra first: record it $min to $max times.';
  }

  @override
  String get fallbackVoiceDenied =>
      'Microphone permission was denied, so Voice counting cannot listen. Using Tap mode.';

  @override
  String get fallbackVoiceBlocked =>
      'Microphone access is blocked. Allow it in Settings to use Voice counting. Using Tap mode.';

  @override
  String get fallbackVoiceUnsupported =>
      'Voice counting works on Android and iOS only. Using Tap mode.';

  @override
  String get fallbackVoiceNoMic =>
      'No microphone available on this device. Using Tap mode.';

  @override
  String get fallbackMalaUnsupported =>
      'Volume-key counting needs a physical device. Using Tap mode.';

  @override
  String get sadhanaRingTitle => '🔔 Sadhana time complete';

  @override
  String get sadhanaRingBody => 'Your session time is up 🙏';

  @override
  String get voiceTooShort => 'That was too short. Say the whole mantra.';

  @override
  String get voiceRanTooLong =>
      'That ran too long. Say the mantra once, then stop.';

  @override
  String get voiceSoundedDifferent =>
      'That sounded different from the others. Say it the same way again.';

  @override
  String get voiceGotIt => 'Got it. Say it again.';

  @override
  String get voiceDeniedShort =>
      'Microphone permission was denied, so Voice counting cannot listen.';

  @override
  String get voiceBlockedShort =>
      'Microphone access is blocked. Allow it in Settings to use Voice counting.';

  @override
  String get voiceAccessLost =>
      'Microphone access was lost, so voice counting stopped.';

  @override
  String get voiceCouldNotRestart =>
      'The microphone could not restart, so voice counting stopped.';

  @override
  String get mantraLibraryTitle => 'Mantra library';

  @override
  String get addMantra => 'Add mantra';

  @override
  String get searchHint => 'Search title, script or tradition';

  @override
  String noMantrasMatch(String query) {
    return 'No mantras match “$query”.\nTap “Add mantra” to create your own.';
  }

  @override
  String mantraAdded(String title) {
    return 'Added “$title”';
  }

  @override
  String mantraSaved(String title) {
    return 'Saved “$title”';
  }

  @override
  String mantraRestored(String title) {
    return 'Restored “$title” to its default';
  }

  @override
  String get deleteMantraTitle => 'Delete mantra?';

  @override
  String deleteMantraBody(String title) {
    return '“$title” will be removed from your library.';
  }

  @override
  String get retrainVoiceTooltip => 'Re-train voice';

  @override
  String get trainVoice => 'Train voice';

  @override
  String mantraCountTag(int count) {
    return '$count counts';
  }

  @override
  String get editedTag => 'Edited';

  @override
  String get editMantra => 'Edit mantra';

  @override
  String get addAMantra => 'Add a mantra';

  @override
  String get titleLabel => 'Title *';

  @override
  String get titleRequired => 'Enter a title';

  @override
  String get scriptTextLabel => 'Script text';

  @override
  String get transliterationLabel => 'Transliteration';

  @override
  String get traditionLabel => 'Tradition / language';

  @override
  String get traditionHint => 'e.g. Sanskrit · Hindu';

  @override
  String get defaultCountLabel => 'Default count *';

  @override
  String get enterNumberOneOrMore => 'Enter a number, 1 or more';

  @override
  String get tooLarge => 'That is too large';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get saveToLibrary => 'Save to library';

  @override
  String get resetToDefaultButton => 'Reset to default';

  @override
  String get resetToDefaultTitle => 'Reset to default?';

  @override
  String resetToDefaultBody(String title) {
    return 'Your edits to “$title” will be discarded and the built-in text restored.';
  }

  @override
  String switchToMantra(String title) {
    return 'Switch to $title?';
  }

  @override
  String get switchMantraBody => 'Your current count will be reset.';

  @override
  String get keepCurrent => 'Keep current';

  @override
  String get switchAction => 'Switch';

  @override
  String get smallerMantraText => 'Smaller mantra text';

  @override
  String get largerMantraText => 'Larger mantra text';

  @override
  String get libraryButton => 'Library';

  @override
  String get trainYourOwnMantra => 'Train your own mantra';

  @override
  String voiceCountingFrom(String title, int count) {
    return 'Counting “$title” from your $count recordings. Other sounds and words are ignored.';
  }

  @override
  String voiceCountsOnlyTrained(String title, int min, int max) {
    return 'Voice counts only a mantra you have trained. Record “$title” $min to $max times to begin.';
  }

  @override
  String get addMoreSamples => 'Add more samples';

  @override
  String get retrain => 'Re-train';

  @override
  String get clearTraining => 'Clear training';

  @override
  String get voiceBetaNote =>
      'Beta: works on-device and offline. Accuracy improves with more recordings and drops in a noisy room. Pause briefly between repeats. Only your voice counts here; the + and − buttons correct the count.';

  @override
  String get trainVoiceFirstTitle => 'Train your voice first';

  @override
  String trainVoiceFirstBody(String title, int min, int max) {
    return 'Voice counts only your own trained mantra. Record “$title” $min to $max times (about a minute). It stays on this device and works offline.';
  }

  @override
  String get later => 'Later';

  @override
  String get trainNow => 'Train now';

  @override
  String get betaLabel => 'BETA';

  @override
  String get voiceTrained => 'Voice trained';

  @override
  String get voiceNotTrained => 'Voice not trained';

  @override
  String get sensitivityLabel => 'Sensitivity';

  @override
  String get sensitivityStrict => 'Strict';

  @override
  String get sensitivityLenient => 'Lenient';

  @override
  String get sensitivityMedium => 'Medium';

  @override
  String get clearVoiceTrainingTitle => 'Clear voice training?';

  @override
  String clearVoiceTrainingBody(String title) {
    return 'Voice will stop counting “$title” until you train it again.';
  }

  @override
  String get completionTitle => 'Completion';

  @override
  String get vibrationLabel => 'Vibration';

  @override
  String vibrationSubtitle(int n) {
    return 'A buzz every $n counts, and a stronger one at the target.';
  }

  @override
  String intensityLevel(int level) {
    return 'Intensity: level $level of 5';
  }

  @override
  String get testMilestone => 'Test milestone';

  @override
  String get testTarget => 'Test target';

  @override
  String get ringtoneLabel => 'Ringtone';

  @override
  String get ringtoneSubtitle => 'A sound plays when the target is reached.';

  @override
  String get playSound => 'Play sound';

  @override
  String get combined => 'Combined';

  @override
  String get combinedTooltip => 'All four modes add to one shared count';

  @override
  String get separate => 'Separate';

  @override
  String get separateTooltip => 'Each mode keeps its own count';

  @override
  String get countModeSemantic => 'Count mode';

  @override
  String get combinedExplain =>
      'Tap, Voice, Rhythm and Mala all add to one shared count toward one target.';

  @override
  String get separateExplain =>
      'Each mode keeps its own count and its own progress toward the target. Reset and completion apply only to the mode you are in.';

  @override
  String countedLabel(int count) {
    return '$count counted';
  }

  @override
  String ofTarget(int count) {
    return 'of $count';
  }

  @override
  String get removeOneTooltip => 'Remove one';

  @override
  String get undoLabel => 'Undo';

  @override
  String get countLabel => 'Count';

  @override
  String get addOneTooltip => 'Add one';

  @override
  String get focusLabel => 'Focus';

  @override
  String get focusModeTooltip => 'Focus mode';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get start => 'Start';

  @override
  String targetReachedSeparate(String mode) {
    return 'Target reached in $mode 🙏  Reset this mode, switch mode, or raise the target.';
  }

  @override
  String get targetReachedCombined =>
      'Target reached 🙏  Reset, or raise the target.';

  @override
  String resetModeCountTitle(String mode) {
    return 'Reset $mode count?';
  }

  @override
  String get resetSessionTitle => 'Reset this session?';

  @override
  String resetModeCountBody(String mode, int count) {
    return 'Your $mode count of $count will return to zero. The other modes keep their counts.';
  }

  @override
  String resetSessionBody(int count) {
    return 'Your count of $count will return to zero.';
  }

  @override
  String get modeHelpTap =>
      'Tap the ring, or anywhere in Focus mode. Only Tap mode counts screen taps.';

  @override
  String get modeHelpRhythm =>
      'Press Start and the count advances by itself at the pace below.';

  @override
  String get modeHelpVoice =>
      'Press Start, then chant your trained mantra. Each time it is recognised it adds one count, straight away; other sounds are ignored. Needs the microphone; works best in a quiet room.';

  @override
  String get modeHelpMala =>
      'Press Start, then press either volume button to count. Handy with eyes closed or the phone in a pocket. The screen must stay on.';

  @override
  String get countingModeLabel => 'Counting mode';

  @override
  String pacePrefix(String pace) {
    return 'Pace: count $pace';
  }

  @override
  String modeSemanticLabel(String mode) {
    return '$mode mode';
  }

  @override
  String get tapAnywhereToCount => 'Tap anywhere to count';

  @override
  String countingPace(String pace) {
    return 'Counting $pace';
  }

  @override
  String pausedPace(String pace) {
    return 'Paused · $pace';
  }

  @override
  String get listening => 'Listening…';

  @override
  String get startingMicrophone => 'Starting microphone… allow access if asked';

  @override
  String get notTrainedYet =>
      'Not trained yet · train your mantra to use Voice';

  @override
  String get pausedPressStartListen => 'Paused · press Start to listen';

  @override
  String get pressVolumeKeys => 'Press the volume keys to count';

  @override
  String get capturingVolumeKeys => 'Capturing the volume keys…';

  @override
  String get pausedPressStartVolume =>
      'Paused · press Start to use the volume keys';

  @override
  String modeTitleLine(String mode, String own) {
    String _temp0 = intl.Intl.selectLogic(own, {
      'yes': ' · own count',
      'other': '',
    });
    return '$mode mode$_temp0';
  }

  @override
  String voiceCountedMatch(int percent) {
    return 'Counted · $percent% match';
  }

  @override
  String voiceIgnoredMatch(int percent) {
    return 'Ignored · $percent% match (not your mantra)';
  }

  @override
  String get paceFieldLabel => 'Pace';

  @override
  String paceHelpOk(String pace, String range) {
    return 'Counts $pace.  (Allowed: $range)';
  }

  @override
  String paceHelpError(String error, String pace) {
    return '$error Still counting $pace.';
  }

  @override
  String get sankalpLabel => 'Sankalp';

  @override
  String get sankalpHint => 'State your intention for this practice…';

  @override
  String get targetSectionTitle => 'Target';

  @override
  String get byCount => 'By count';

  @override
  String get byTime => 'By time';

  @override
  String customWithValue(String value) {
    return 'Custom · $value';
  }

  @override
  String get custom => 'Custom';

  @override
  String get enterNumberRange => 'Enter a number from 1 to 9,999,999';

  @override
  String get customCountTitle => 'Custom count';

  @override
  String get targetCountLabel => 'Target count';

  @override
  String get setAction => 'Set';

  @override
  String get durationLabel => 'Duration';

  @override
  String get enterDuration => 'Enter a duration of 1 or more.';

  @override
  String get maxDurationCapped =>
      'Maximum is 99 h 59 min 59 s — it will be capped.';

  @override
  String sessionLasts(String duration) {
    return 'Session lasts $duration.';
  }

  @override
  String get targetReachedFocus => 'Target reached 🙏';

  @override
  String screenTapsDoNotCount(String mode) {
    return 'Screen taps do not count in $mode mode. Use + or − to correct.';
  }

  @override
  String holdFingersToExit(int fingers, int seconds) {
    return 'Hold $fingers fingers for $seconds seconds to exit';
  }

  @override
  String get holdToExitFocusMode => 'Hold to exit focus mode';

  @override
  String get holdToExit => 'Hold to exit';

  @override
  String get keepHoldingToExit => 'Keep holding to exit…';

  @override
  String addedRecordingsTo(int added, String title, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'recordings',
      one: 'recording',
    );
    return 'Added $added $_temp0 to “$title” ($total in total)';
  }

  @override
  String voiceTrainedFor(String title, int count) {
    return 'Voice trained for “$title” ($count recordings)';
  }

  @override
  String trainedRecordingsCount(int count) {
    return 'Trained · $count recordings';
  }

  @override
  String get tooFewRecordings =>
      'Too few recordings to count with. Add more, or re-train.';

  @override
  String canCountAddMore(int room) {
    return 'Voice can count this mantra. Add up to $room more recordings to improve accuracy without starting over.';
  }

  @override
  String canCountAtMax(int max) {
    return 'Voice can count this mantra. You have the maximum of $max recordings; re-train to replace them.';
  }

  @override
  String get pausedHeadline => 'Paused';

  @override
  String pausedSub(int recorded) {
    return '$recorded recorded. Continue, or save what you have.';
  }

  @override
  String recordInstructions(int min, int max, int recommended) {
    return 'Record it $min to $max times at your normal chanting speed ($recommended is a good number). Voice will then count only your mantra.';
  }

  @override
  String get openingMicrophone => 'Opening the microphone…';

  @override
  String get stayQuiet => 'Stay quiet for a moment…';

  @override
  String get listeningToRoom =>
      'Listening to the room so background noise is not counted.';

  @override
  String get sayYourMantra => 'Say your mantra…';

  @override
  String recordingXofY(int current, int max) {
    return 'Recording $current of up to $max';
  }

  @override
  String allRecordingsCaptured(int count) {
    return 'All $count recordings captured';
  }

  @override
  String get saveToStartCounting => 'Save them to start counting with Voice.';

  @override
  String get cannotUseMicrophone => 'Cannot use the microphone';

  @override
  String get canSaveNowHint =>
      'You can save now, or keep going for more accuracy.';

  @override
  String minAreEnough(int min) {
    return '$min are enough to start.';
  }

  @override
  String addingToSaved(int count) {
    return 'Adding to your $count saved recordings.';
  }

  @override
  String get tryAgain => 'Try again';

  @override
  String get startRecording => 'Start recording';

  @override
  String get openSettingsAction => 'Open Settings';

  @override
  String saveNRecordings(int count) {
    return 'Save $count recordings';
  }

  @override
  String recordMoreToSave(int n) {
    return 'Record $n more to save';
  }

  @override
  String get recordSampleToSave => 'Record a sample to save';

  @override
  String get undoLast => 'Undo last';

  @override
  String get stop => 'Stop';

  @override
  String get continueRecording => 'Continue recording';

  @override
  String get startOver => 'Start over';

  @override
  String recordedOfMax(int recorded, int max) {
    return '$recorded of up to $max recordings';
  }

  @override
  String voiceBetaNoteTraining(int max) {
    return 'Beta. Everything happens on this device, offline: only numbers describing the sound are saved, never the audio. More recordings make counting more accurate (up to $max); a noisy room makes it less accurate. Say the mantra once, then pause briefly before the next repeat.';
  }

  @override
  String get actionClear => 'Clear';

  @override
  String get today => 'Today';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get markTypeGood => 'Good';

  @override
  String get markTypeCautious => 'Cautious';

  @override
  String get markTypeNeutral => 'Neutral';

  @override
  String get reminderModeNone => 'No time';

  @override
  String get reminderModeOnce => 'One time';

  @override
  String get reminderModeSeveral => 'Several times';

  @override
  String get repeatRuleOnce => 'Once';

  @override
  String get repeatRuleDaily => 'Daily';

  @override
  String get repeatRuleWeekly => 'Weekly';

  @override
  String get repeatRuleMonthly => 'Monthly';

  @override
  String get repeatRuleQuarterly => 'Quarterly';

  @override
  String get repeatRuleHalfYearly => 'Half-yearly';

  @override
  String get repeatRuleYearly => 'Yearly';

  @override
  String get homeModeNone => 'Don\'t show';

  @override
  String get homeModeMorning => 'Once in the morning';

  @override
  String get homeModeAllDay => 'Keep all day';

  @override
  String get markStyleDot => 'Dot';

  @override
  String get markStyleFilled => 'Filled';

  @override
  String get markStyleHighlight => 'Highlight';

  @override
  String get markStyleCircle => 'Circle';

  @override
  String get markStyleSquare => 'Square';

  @override
  String get emojiOm => 'Om';

  @override
  String get emojiKhanda => 'Khanda';

  @override
  String get emojiMala => 'Mala';

  @override
  String get emojiDiya => 'Diya';

  @override
  String get emojiBell => 'Bell';

  @override
  String get emojiSunrise => 'Sunrise';

  @override
  String get emojiStar => 'Star';

  @override
  String get emojiSparkle => 'Sparkle';

  @override
  String get emojiMoney => 'Money';

  @override
  String get emojiHandshake => 'Handshake';

  @override
  String get emojiAvoid => 'Avoid';

  @override
  String get emojiDone => 'Done';

  @override
  String get markTitleGood => 'Good day';

  @override
  String get markTitleCautious => 'Cautious day';

  @override
  String get markTitleNeutral => 'Neutral day';

  @override
  String get reminderBodyGood => 'A good day.';

  @override
  String get reminderBodyCautious => 'Be careful today.';

  @override
  String get reminderBodyNeutral => 'Marked in your calendar.';

  @override
  String get channelCalendarRemindersName => 'Calendar reminders';

  @override
  String get channelCalendarRemindersDesc =>
      'Reminders for the dates you marked in Sadho';

  @override
  String get channelAlarmsName => 'Alarms and timers';

  @override
  String get channelAlarmsDesc => 'The sun-based alarm and finished timers';

  @override
  String get repeatSummaryOnce => 'Once';

  @override
  String get repeatSummaryDaily => 'Every day';

  @override
  String get repeatSummaryWeekly => 'Every week';

  @override
  String get repeatSummaryMonthly => 'Every month';

  @override
  String get repeatSummaryQuarterly => 'Every 3 months';

  @override
  String get repeatSummaryHalfYearly => 'Every 6 months';

  @override
  String get repeatSummaryYearly => 'Every year';

  @override
  String reminderSummaryAt(String times) {
    return 'Remind at $times';
  }

  @override
  String homeSummaryFrom(String time) {
    return 'On Home from $time';
  }

  @override
  String get homeSummaryAllDay => 'On Home all day';

  @override
  String marksInMonth(String month) {
    return 'Marks in $month';
  }

  @override
  String noMarksInMonth(String month) {
    return 'Nothing marked in $month. Tap a date to add a mark.';
  }

  @override
  String get markStyleSectionTitle => 'Mark style';

  @override
  String get markStyleSectionHint =>
      'How marked dates look. Applies to every mark.';

  @override
  String markStyleSemantic(String style) {
    return '$style mark style';
  }

  @override
  String get dayCellToday => ', today';

  @override
  String get dayCellAnd => 'and';

  @override
  String dayCellMarkedSuffix(int count, String kinds) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ', marked $kinds, $count marks',
      one: ', marked $kinds, 1 mark',
    );
    return '$_temp0';
  }

  @override
  String get markEditorNoTimeWarning =>
      'Add at least one time, or choose \"No time\".';

  @override
  String get notificationsOffWarning =>
      'Notifications are off for Sadho, so this reminder will not ring. Turn them on in your phone\'s settings.';

  @override
  String get deleteMarkFallbackTitle => 'this mark';

  @override
  String get deleteMarkQuestion => 'Delete this mark?';

  @override
  String deleteMarkRepeatsBody(String title) {
    return 'Delete $title and all of its repeats? Its reminders are removed too.';
  }

  @override
  String deleteMarkBody(String title) {
    return 'Delete $title? Its reminders are removed too.';
  }

  @override
  String get newMark => 'New mark';

  @override
  String get editMark => 'Edit mark';

  @override
  String repeatFromNotice(String repeatSummary, String date) {
    return '$repeatSummary, from $date. Changes apply to every repeat.';
  }

  @override
  String get markTypeSectionTitle => 'Mark type';

  @override
  String get iconSectionTitle => 'Icon';

  @override
  String get iconNone => 'None';

  @override
  String get labelFieldLabel => 'Label';

  @override
  String get detailsFieldLabel => 'Details / notes';

  @override
  String get remindMeAtSectionTitle => 'Remind me at';

  @override
  String removeTimeTooltip(String time) {
    return 'Remove $time';
  }

  @override
  String get addTime => 'Add time';

  @override
  String get repeatSectionTitle => 'Repeat';

  @override
  String get onHomeScreenSectionTitle => 'On your home screen';

  @override
  String showFromTime(String time) {
    return 'Show from $time';
  }

  @override
  String get homeModeNoneExplain => 'The mark stays on the calendar only.';

  @override
  String get homeModeMorningExplain =>
      'A card appears on Home at that time. Swipe it away when done: it comes back on the next repeat.';

  @override
  String get homeModeAllDayExplain =>
      'A card stays pinned on Home all day (it cannot be swiped away).';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get startAgain => 'Start again';

  @override
  String get settingsAction => 'Settings';

  @override
  String get clockToolClockSubtitle => 'A large, live time and date';

  @override
  String get clockToolSunAlarmTitle => 'Sun-based alarm';

  @override
  String get clockToolSunAlarmSubtitle =>
      'Wake at sunrise or sunset, with an offset';

  @override
  String get clockToolWorldClockTitle => 'World clock';

  @override
  String get clockToolWorldClockSubtitle =>
      'Amritsar, Haridwar, London and more';

  @override
  String get clockToolTimerTitle => 'Sadhana & vrat timer';

  @override
  String get clockToolTimerSubtitle =>
      'Aarti, Chalisa, Path, Havan, or until sunset';

  @override
  String get clockToolStopwatchTitle => 'Paath stopwatch';

  @override
  String get clockToolStopwatchSubtitle => 'Start, stop and lap';

  @override
  String get sunEventSunrise => 'Sunrise';

  @override
  String get sunEventSunset => 'Sunset';

  @override
  String offsetAtEvent(String event) {
    return 'At $event';
  }

  @override
  String offsetMinutesOnly(int m) {
    return '$m min';
  }

  @override
  String offsetHoursOnly(int h) {
    return '$h hr';
  }

  @override
  String offsetHoursMinutes(int h, int m) {
    return '$h hr $m min';
  }

  @override
  String offsetBefore(String amount) {
    return '$amount before';
  }

  @override
  String offsetAfter(String amount) {
    return '$amount after';
  }

  @override
  String get locationSourceDevice => 'Your location';

  @override
  String get locationSourceSaved => 'Your last known location';

  @override
  String get locationSourceFallback => 'Amritsar (default)';

  @override
  String get locSummaryDevice => 'Using your location';

  @override
  String get locSummarySaved => 'Using your last known location';

  @override
  String get locSummaryBlocked =>
      'Using Amritsar. Location is blocked in Settings.';

  @override
  String get locSummaryServiceOff =>
      'Using Amritsar. Turn on location for exact times.';

  @override
  String get locSummaryUnsupported => 'Using Amritsar.';

  @override
  String get locSummaryDefault =>
      'Using Amritsar. Allow location for exact times.';

  @override
  String get presetAarti => 'Aarti';

  @override
  String get presetChalisa => 'Chalisa';

  @override
  String get presetPath => 'Path';

  @override
  String get presetHavan => 'Havan';

  @override
  String get vratToSunset => 'Vrat → sunset';

  @override
  String presetChipLabel(String label, int minutes) {
    return '$label · $minutes min';
  }

  @override
  String get clockNoSunsetHere =>
      'There is no sunset to count down to here right now.';

  @override
  String get clockSunsetPassedTomorrow =>
      'Today\'s sunset has passed: counting to tomorrow\'s.';

  @override
  String timerFinishedTitle(String label) {
    return '🔔 $label finished';
  }

  @override
  String get sunsetArrived => 'Sunset has arrived 🙏';

  @override
  String timerTimeUp(String label) {
    return 'Your $label time is up 🙏';
  }

  @override
  String sunAlarmNotifTitle(String emoji, String event) {
    return '$emoji $event alarm';
  }

  @override
  String sunAlarmNotifBody(String event, String time, String offset) {
    return '$event is at $time · $offset';
  }

  @override
  String get statusOn => 'On';

  @override
  String get finished => 'finished';

  @override
  String get left => 'left';

  @override
  String get paused => 'paused';

  @override
  String get runningStatus => 'Running';

  @override
  String get stoppedStatus => 'Stopped';

  @override
  String get lap => 'Lap';

  @override
  String get lapTime => 'Lap time';

  @override
  String get total => 'Total';

  @override
  String get fastest => 'Fastest';

  @override
  String get slowest => 'Slowest';

  @override
  String get tapLapToMark => 'Tap Lap to mark a lap.';

  @override
  String get startThenTapLap => 'Start, then tap Lap at each round.';

  @override
  String get allowNotificationsForAlarm =>
      'Allow notifications in Settings so the alarm can ring.';

  @override
  String get alarmRingsAt => 'Alarm rings at';

  @override
  String get alarmWouldRingAt => 'Alarm would ring at';

  @override
  String noEventToFollow(String event) {
    return 'No $event to follow here right now.';
  }

  @override
  String get alarmOnLabel => 'Alarm on';

  @override
  String get recalculatedDaily => 'Recalculated every day as the sun moves';

  @override
  String todayHereSunriseSunset(String rise, String set) {
    return 'Today here: sunrise $rise · sunset $set';
  }

  @override
  String get whenLabel => 'When';

  @override
  String get minutesLabel => 'Minutes';

  @override
  String get upTo1440 => 'Up to 1440';

  @override
  String get before => 'Before';

  @override
  String get after => 'After';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get couldNotReadPosition => ' · could not read your position';

  @override
  String get timesUp => 'Time’s up 🙏';

  @override
  String sunsetAtTime(String time) {
    return 'Sunset at $time';
  }

  @override
  String cityInDays(int days) {
    return 'In $days days';
  }

  @override
  String cityDaysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get citySameTime => 'Same time as you';

  @override
  String cityAmountMinutes(int m) {
    return '$m m';
  }

  @override
  String cityAmountHours(int h) {
    return '$h h';
  }

  @override
  String cityAmountHoursMinutes(int h, int m) {
    return '$h h $m m';
  }

  @override
  String cityAheadOfYou(String amount) {
    return '$amount ahead of you';
  }

  @override
  String cityBehindYou(String amount) {
    return '$amount behind you';
  }

  @override
  String get traditionHindu => 'Hindu';

  @override
  String get traditionSikh => 'Sikh';

  @override
  String get traditionPlace => 'By place';

  @override
  String get todayLabelTithi => 'Tithi';

  @override
  String get todayLabelNakshatra => 'Nakshatra';

  @override
  String get todayLabelRahu => 'Rahu Kaal';

  @override
  String get todayLabelAbhijit => 'Abhijit muhurat';

  @override
  String get todayLabelHukamnama => 'Hukamnama';

  @override
  String get todayLabelNitnem => 'Nitnem due';

  @override
  String get todayLabelGurpurab => 'Next Gurpurab';

  @override
  String get todayLabelFestival => 'Local festival';

  @override
  String get todayLabelWindow => 'Auspicious window';

  @override
  String get exampleTag => 'EXAMPLE';

  @override
  String get exampleNote =>
      'Values marked EXAMPLE are placeholders: real panchang data comes in a later phase.';

  @override
  String liveNote(String where) {
    return 'Sunrise and sunset are worked out for your place. $where.';
  }

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingNight => 'Good night';

  @override
  String get homeEmptyTitle => 'Nothing on your home screen today';

  @override
  String get homeEmptyBody =>
      'Mark a date in the Calendar and choose \"On your home screen\" to see it here.';

  @override
  String get pinnedAllDay => 'Pinned all day';

  @override
  String get swipeToDismiss => 'Swipe to dismiss for today';

  @override
  String doneForToday(String title) {
    return 'Done for today: $title';
  }

  @override
  String get undoAction => 'Undo';

  @override
  String get doneForTodayLabel => 'Done for today';

  @override
  String get plansTitle => 'Paath & mantra plans';

  @override
  String get addPlan => 'Add plan';

  @override
  String get dayStreak => 'day streak';

  @override
  String activePlanCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'active plans',
      one: 'active plan',
    );
    return '$_temp0';
  }

  @override
  String get noPlansYet => 'No plans yet';

  @override
  String get plansEmptyBody =>
      'Commit to a paath or mantra for a number of days and tick each day off. Start with one of these, or add your own.';

  @override
  String get planOptionsTooltip => 'Plan options';

  @override
  String get deletePlanMenuItem => 'Delete plan';

  @override
  String get deletePlanQuestion => 'Delete plan?';

  @override
  String deletePlanBody(String title) {
    return '“$title” and its progress will be removed.';
  }

  @override
  String titledDaysTag(String title, int days) {
    return '$title · $days days';
  }

  @override
  String completedOfDays(int completed, int total) {
    return 'Completed · $completed of $total days';
  }

  @override
  String ofDays(int completed, int total) {
    return '$completed of $total days';
  }

  @override
  String get doneTodayButton => 'Done today';

  @override
  String get markTodayDone => 'Mark today done';

  @override
  String get newPlanTitle => 'New plan';

  @override
  String get newPlanSubtitle =>
      'Pick a paath or mantra and how many days you will keep it up.';

  @override
  String get paathOrMantraLabel => 'Paath or mantra';

  @override
  String get giveThePlanAName => 'Give the plan a name';

  @override
  String chooseDaysRange(int min, int max) {
    return 'Choose $min to $max days';
  }

  @override
  String get forHowManyDays => 'For how many days?';

  @override
  String get daysFieldLabel => 'Days';

  @override
  String get startPlanButton => 'Start plan';

  @override
  String get planKindPaath => 'Paath';

  @override
  String get planKindMantra => 'Mantra';

  @override
  String get profileTitle => 'Profile';

  @override
  String get sadhanaSettingsTitle => 'Sadhana settings';

  @override
  String get validEmailError => 'Enter a valid email address';

  @override
  String nameTooLong(int max) {
    return 'Keep it under $max characters';
  }

  @override
  String get enterCurrentPassword => 'Enter your current password';

  @override
  String passwordTooShort(int min) {
    return 'Use at least $min characters';
  }

  @override
  String get passwordAlreadyUsed => 'Choose a password you have not used';

  @override
  String get passwordsDontMatch => 'The two passwords do not match';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get accountsLaterNote =>
      'Accounts arrive in a later phase; until then this only checks your entries and changes nothing.';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmNewPasswordLabel => 'Confirm new password';

  @override
  String get showPasswords => 'Show passwords';

  @override
  String get updatePasswordButton => 'Update password';

  @override
  String get stepAddName => 'Add your name';

  @override
  String get stepAddEmail => 'Add your email';

  @override
  String get stepPickTradition => 'Pick your tradition on Home';

  @override
  String get stepTurnOnReminder => 'Turn on the daily reminder';

  @override
  String get stepStartPlan => 'Start a paath or mantra plan';

  @override
  String get profileCompletionTitle => 'Profile completion';

  @override
  String get profileCompleteReward =>
      'Profile complete! Your free premium reward will be waiting when premium launches.';

  @override
  String get reachRewardNote =>
      'Reach 100% to earn free premium when it launches.';

  @override
  String get aboutTitle => 'About';

  @override
  String get appLabel => 'App';

  @override
  String get websiteLabel => 'Website';

  @override
  String get versionLabel => 'Version';

  @override
  String get passwordWillWorkLater =>
      'Password change will work once accounts are added.';

  @override
  String get signedOut => 'Signed out';

  @override
  String get notSignedInYet =>
      'You are not signed in yet: accounts arrive in a later phase. Your data stays on this phone.';

  @override
  String get accountTitle => 'Account';

  @override
  String get signOutButton => 'Sign out';

  @override
  String get backupSaved => 'Backup saved';

  @override
  String get backupCancelled => 'Backup cancelled';

  @override
  String get couldNotSaveBackup => 'Could not save the backup. Try again.';

  @override
  String get backupNotSadho => 'That file is not a Sadho backup.';

  @override
  String get couldNotReadFile => 'Could not read that file.';

  @override
  String get backupDamaged => 'The backup file is damaged.';

  @override
  String get backupTooNew =>
      'This backup was made by a newer version of Sadho. Update the app first.';

  @override
  String get backupNoData => 'That backup has no Sadho data in it.';

  @override
  String get backupTooBig => 'That file is too big to be a Sadho backup.';

  @override
  String madeOnSuffix(String date) {
    return ' made on $date';
  }

  @override
  String restoreBackupBody(String made, int count) {
    return 'A backup$made with $count saved items. It will replace what is on this phone now: marks, plans, mantras, voice training and settings.';
  }

  @override
  String get restoreThisBackup => 'Restore this backup?';

  @override
  String get backupRestoredTitle => 'Backup restored';

  @override
  String get backupRestoredBody => 'Sadho will reload with your restored data.';

  @override
  String get backupRestoreTitle => 'Backup & restore';

  @override
  String get backupExplain =>
      'Save your marks, plans, mantras, voice training and settings to a file you choose (Drive, Files, email it to yourself). Restore it on this or another phone.';

  @override
  String get exportButton => 'Export';

  @override
  String get restoreButton => 'Restore';

  @override
  String get cloudSyncTitle => 'Cloud sync';

  @override
  String get comingLater => 'Coming later';

  @override
  String get saveBackupDialogTitle => 'Save your Sadho backup';

  @override
  String get chooseBackupDialogTitle => 'Choose a Sadho backup';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get deleteAccountWarning =>
      'This deletes your account and everything saved on this phone: your profile, marks, plans, mantras, voice training and settings. It cannot be undone.';

  @override
  String get yesAction => 'Yes';

  @override
  String get noAction => 'No';

  @override
  String get dangerZoneTitle => 'Danger zone';

  @override
  String get deleteAccountExplain =>
      'Deleting your account erases your profile and everything saved on this phone. Export a backup first if you might want it back.';

  @override
  String get deleteAccountButton => 'Delete account';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get yourDetailsTitle => 'Your details';

  @override
  String get nameLabel => 'Name';

  @override
  String get emailLabel => 'Email';

  @override
  String get dailyReminderTitle => 'Daily reminder';

  @override
  String get dailySadhanaReminder => 'Daily sadhana reminder';

  @override
  String get reminderOff => 'Off';

  @override
  String everyDayAt(String time) {
    return 'Every day at $time';
  }

  @override
  String get allowNotificationsForReminder =>
      'Allow notifications in Settings so the reminder can ring.';

  @override
  String get timeLabel => 'Time';

  @override
  String get themeTitle => 'Theme';

  @override
  String get lightMode => 'Light';

  @override
  String get darkMode => 'Dark';

  @override
  String get systemMode => 'System';

  @override
  String get coloursTitle => 'Colours';

  @override
  String paletteSemantic(String name) {
    return '$name colours';
  }

  @override
  String get paletteMarigoldName => 'Marigold';

  @override
  String get paletteMarigoldBlurb => 'Warm saffron and deep indigo';

  @override
  String get paletteSandalwoodName => 'Sandalwood';

  @override
  String get paletteSandalwoodBlurb => 'Soft sandal brown and clay';

  @override
  String get paletteTulsiName => 'Tulsi green';

  @override
  String get paletteTulsiBlurb => 'Calm holy-basil green';

  @override
  String get paletteTwilightName => 'Twilight indigo';

  @override
  String get paletteTwilightBlurb => 'Dusk indigo with a lamp-glow gold';

  @override
  String get paletteLotusName => 'Lotus rose';

  @override
  String get paletteLotusBlurb => 'Gentle lotus pink and leaf green';

  @override
  String get sadhanaTimeNotifTitle => '🪔 Time for your sadhana';

  @override
  String get sadhanaTimeNotifBody =>
      'Take a few quiet minutes for your paath or mantra 🙏';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get trainAction => 'Train';

  @override
  String get onboardingTitle => 'Welcome to Sadho';

  @override
  String get onboardingSubtitle =>
      'Choose your language and tradition to begin. You can change either later in Profile.';

  @override
  String get traditionHeading => 'Tradition';

  @override
  String get continueAction => 'Continue';

  @override
  String get stopAlert => 'Stop';

  @override
  String get repeatLabel => 'Repeat';

  @override
  String get repeatOnce => 'Once';

  @override
  String soundRepeatTimes(int times) {
    return '$times times';
  }

  @override
  String get repeatUntilStopped => 'Until stopped';

  @override
  String vibrationRepeatUntilStopped(int seconds) {
    return 'Every $seconds s until stopped';
  }

  @override
  String get keepScreenOnLabel => 'Keep screen on while counting';

  @override
  String get keepScreenOnSubtitle =>
      'Stops the screen from sleeping while a session runs. The power button still locks the phone; a timed or Rhythm session then rings like an alarm when it finishes.';

  @override
  String get alarmMayBeLate =>
      'The alarm may ring a little late (exact alarms are off).';

  @override
  String get exactAlarmNotice =>
      'To ring right on time with the screen off, allow Sadho to set exact alarms.';

  @override
  String get fullScreenNotice =>
      'To show the finished session over the lock screen, allow full-screen alerts.';

  @override
  String get allowAction => 'Allow';

  @override
  String channelSadhanaAlarmName(String sound) {
    return 'Sadhana alarm · $sound';
  }

  @override
  String get channelSadhanaAlarmSilentName => 'Sadhana alarm · silent';

  @override
  String get channelNoVibration => 'no vibration';

  @override
  String get channelSadhanaAlarmDesc =>
      'Rings when a timed or Rhythm session finishes';

  @override
  String get alarmScreenSadhanaTitle => 'Sadhana complete 🙏';

  @override
  String get alarmScreenTimerTitle => 'Timer finished';

  @override
  String get alarmScreenSunTitle => 'Sun alarm';

  @override
  String get alarmScreenUnlock => 'Unlock to open Sadho';

  @override
  String get alarmScreenUnlockHint =>
      'The rest of the app needs the phone unlocked.';

  @override
  String get alarmsReliabilityTitle => 'Alarms & reliability';

  @override
  String get alarmsReliabilityIntro =>
      'For alarms to ring on time with the screen off, your phone must allow these. Fix opens the right settings page.';

  @override
  String get alarmsReliabilityAllOk =>
      'Everything is set for alarms to ring on time';

  @override
  String get alarmsReliabilityAttention => 'Something needs attention';

  @override
  String get healthOk => 'OK';

  @override
  String get healthNeedsAttention => 'Needs attention';

  @override
  String get healthFix => 'Fix';

  @override
  String get healthNotificationsTitle => 'Notifications allowed';

  @override
  String get healthNotificationsBody =>
      'Alarms and reminders arrive as notifications.';

  @override
  String get healthExactTitle => 'Exact alarms allowed';

  @override
  String get healthExactBody => 'Rings at the exact second, not a little late.';

  @override
  String get healthFullScreenTitle => 'Show alarms over the lock screen';

  @override
  String get healthFullScreenBody =>
      'A finished alarm appears even while the phone is locked.';

  @override
  String get healthBatteryTitle => 'Battery: app not restricted';

  @override
  String get healthBatteryBody =>
      'In Battery, choose Unrestricted (or at least not Restricted), so the phone does not hold alarms back.';

  @override
  String get healthBatterySamsungHint =>
      'Samsung: in Settings › Battery › Background usage limits, remove Sadho from “Sleeping apps” and “Deep sleeping apps”, and set its battery use to “Unrestricted”.';

  @override
  String get alarmExplainerOk =>
      'This session will ring like an alarm when it finishes, even with the screen off or the app closed.';

  @override
  String get alarmExplainerAttention =>
      'This session will ring like an alarm when it finishes, but your phone needs a setting changed to ring on time.';

  @override
  String get alarmExplainerCheck => 'Check';
}
