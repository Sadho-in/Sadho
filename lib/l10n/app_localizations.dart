import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('mr'),
    Locale('pa'),
    Locale('ta'),
    Locale('te'),
  ];

  /// Bottom navigation: the Home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation: the Sadhana tab
  ///
  /// In en, this message translates to:
  /// **'Sadhana'**
  String get navSadhana;

  /// Bottom navigation: the Calendar tab
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// Bottom navigation: the Clock tab
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get navClock;

  /// Top bar icon button: opens the language picker
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get tooltipLanguage;

  /// Top bar avatar: opens the Profile page
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tooltipProfile;

  /// Top bar icon button, shown while in dark mode
  ///
  /// In en, this message translates to:
  /// **'Switch to light theme'**
  String get tooltipSwitchToLight;

  /// Top bar icon button, shown while in light mode
  ///
  /// In en, this message translates to:
  /// **'Switch to dark theme'**
  String get tooltipSwitchToDark;

  /// Heading of the language-picker sheet
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSheetTitle;

  /// Explanation under the language-picker heading
  ///
  /// In en, this message translates to:
  /// **'Your choice is saved and applies right away.'**
  String get languageSheetSubtitle;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @unitSeconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get unitSeconds;

  /// No description provided for @unitMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get unitMinutes;

  /// No description provided for @unitHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get unitHours;

  /// No description provided for @paceErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a pace.'**
  String get paceErrorEmpty;

  /// No description provided for @paceErrorNotNumber.
  ///
  /// In en, this message translates to:
  /// **'That is not a number.'**
  String get paceErrorNotNumber;

  /// No description provided for @paceErrorTooFast.
  ///
  /// In en, this message translates to:
  /// **'Too fast. The minimum is {min}.'**
  String paceErrorTooFast(String min);

  /// No description provided for @paceErrorTooSlow.
  ///
  /// In en, this message translates to:
  /// **'Too slow. The maximum is {max}.'**
  String paceErrorTooSlow(String max);

  /// No description provided for @modeTap.
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get modeTap;

  /// No description provided for @modeRhythm.
  ///
  /// In en, this message translates to:
  /// **'Rhythm'**
  String get modeRhythm;

  /// No description provided for @modeVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get modeVoice;

  /// No description provided for @modeMala.
  ///
  /// In en, this message translates to:
  /// **'Mala'**
  String get modeMala;

  /// No description provided for @ringtoneTempleBell.
  ///
  /// In en, this message translates to:
  /// **'Temple bell'**
  String get ringtoneTempleBell;

  /// No description provided for @ringtoneSingingBowl.
  ///
  /// In en, this message translates to:
  /// **'Singing bowl'**
  String get ringtoneSingingBowl;

  /// No description provided for @ringtoneSoftChime.
  ///
  /// In en, this message translates to:
  /// **'Soft chime'**
  String get ringtoneSoftChime;

  /// No description provided for @ringtoneDeepGong.
  ///
  /// In en, this message translates to:
  /// **'Deep gong'**
  String get ringtoneDeepGong;

  /// No description provided for @msgVoiceUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Voice counting works on Android and iOS only'**
  String get msgVoiceUnsupported;

  /// No description provided for @msgVoiceNoMic.
  ///
  /// In en, this message translates to:
  /// **'No microphone available on this device'**
  String get msgVoiceNoMic;

  /// No description provided for @msgMalaUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Volume-key counting needs a physical device'**
  String get msgMalaUnsupported;

  /// No description provided for @trainFirstPrompt.
  ///
  /// In en, this message translates to:
  /// **'Train your voice for this mantra first: record it {min} to {max} times.'**
  String trainFirstPrompt(int min, int max);

  /// No description provided for @fallbackVoiceDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission was denied, so Voice counting cannot listen. Using Tap mode.'**
  String get fallbackVoiceDenied;

  /// No description provided for @fallbackVoiceBlocked.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is blocked. Allow it in Settings to use Voice counting. Using Tap mode.'**
  String get fallbackVoiceBlocked;

  /// No description provided for @fallbackVoiceUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Voice counting works on Android and iOS only. Using Tap mode.'**
  String get fallbackVoiceUnsupported;

  /// No description provided for @fallbackVoiceNoMic.
  ///
  /// In en, this message translates to:
  /// **'No microphone available on this device. Using Tap mode.'**
  String get fallbackVoiceNoMic;

  /// No description provided for @fallbackMalaUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Volume-key counting needs a physical device. Using Tap mode.'**
  String get fallbackMalaUnsupported;

  /// No description provided for @sadhanaRingTitle.
  ///
  /// In en, this message translates to:
  /// **'🔔 Sadhana time complete'**
  String get sadhanaRingTitle;

  /// No description provided for @sadhanaRingBody.
  ///
  /// In en, this message translates to:
  /// **'Your session time is up 🙏'**
  String get sadhanaRingBody;

  /// No description provided for @voiceTooShort.
  ///
  /// In en, this message translates to:
  /// **'That was too short. Say the whole mantra.'**
  String get voiceTooShort;

  /// No description provided for @voiceRanTooLong.
  ///
  /// In en, this message translates to:
  /// **'That ran too long. Say the mantra once, then stop.'**
  String get voiceRanTooLong;

  /// No description provided for @voiceSoundedDifferent.
  ///
  /// In en, this message translates to:
  /// **'That sounded different from the others. Say it the same way again.'**
  String get voiceSoundedDifferent;

  /// No description provided for @voiceGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it. Say it again.'**
  String get voiceGotIt;

  /// No description provided for @voiceDeniedShort.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission was denied, so Voice counting cannot listen.'**
  String get voiceDeniedShort;

  /// No description provided for @voiceBlockedShort.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is blocked. Allow it in Settings to use Voice counting.'**
  String get voiceBlockedShort;

  /// No description provided for @voiceAccessLost.
  ///
  /// In en, this message translates to:
  /// **'Microphone access was lost, so voice counting stopped.'**
  String get voiceAccessLost;

  /// No description provided for @voiceCouldNotRestart.
  ///
  /// In en, this message translates to:
  /// **'The microphone could not restart, so voice counting stopped.'**
  String get voiceCouldNotRestart;

  /// No description provided for @mantraLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Mantra library'**
  String get mantraLibraryTitle;

  /// No description provided for @addMantra.
  ///
  /// In en, this message translates to:
  /// **'Add mantra'**
  String get addMantra;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search title, script or tradition'**
  String get searchHint;

  /// No description provided for @noMantrasMatch.
  ///
  /// In en, this message translates to:
  /// **'No mantras match “{query}”.\nTap “Add mantra” to create your own.'**
  String noMantrasMatch(String query);

  /// No description provided for @mantraAdded.
  ///
  /// In en, this message translates to:
  /// **'Added “{title}”'**
  String mantraAdded(String title);

  /// No description provided for @mantraSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved “{title}”'**
  String mantraSaved(String title);

  /// No description provided for @mantraRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored “{title}” to its default'**
  String mantraRestored(String title);

  /// No description provided for @deleteMantraTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete mantra?'**
  String get deleteMantraTitle;

  /// No description provided for @deleteMantraBody.
  ///
  /// In en, this message translates to:
  /// **'“{title}” will be removed from your library.'**
  String deleteMantraBody(String title);

  /// No description provided for @retrainVoiceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Re-train voice'**
  String get retrainVoiceTooltip;

  /// No description provided for @trainVoice.
  ///
  /// In en, this message translates to:
  /// **'Train voice'**
  String get trainVoice;

  /// No description provided for @mantraCountTag.
  ///
  /// In en, this message translates to:
  /// **'{count} counts'**
  String mantraCountTag(int count);

  /// No description provided for @editedTag.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get editedTag;

  /// No description provided for @editMantra.
  ///
  /// In en, this message translates to:
  /// **'Edit mantra'**
  String get editMantra;

  /// No description provided for @addAMantra.
  ///
  /// In en, this message translates to:
  /// **'Add a mantra'**
  String get addAMantra;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get titleLabel;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get titleRequired;

  /// No description provided for @scriptTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Script text'**
  String get scriptTextLabel;

  /// No description provided for @transliterationLabel.
  ///
  /// In en, this message translates to:
  /// **'Transliteration'**
  String get transliterationLabel;

  /// No description provided for @traditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Tradition / language'**
  String get traditionLabel;

  /// No description provided for @traditionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sanskrit · Hindu'**
  String get traditionHint;

  /// No description provided for @defaultCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Default count *'**
  String get defaultCountLabel;

  /// No description provided for @enterNumberOneOrMore.
  ///
  /// In en, this message translates to:
  /// **'Enter a number, 1 or more'**
  String get enterNumberOneOrMore;

  /// No description provided for @tooLarge.
  ///
  /// In en, this message translates to:
  /// **'That is too large'**
  String get tooLarge;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @saveToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Save to library'**
  String get saveToLibrary;

  /// No description provided for @resetToDefaultButton.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get resetToDefaultButton;

  /// No description provided for @resetToDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset to default?'**
  String get resetToDefaultTitle;

  /// No description provided for @resetToDefaultBody.
  ///
  /// In en, this message translates to:
  /// **'Your edits to “{title}” will be discarded and the built-in text restored.'**
  String resetToDefaultBody(String title);

  /// No description provided for @switchToMantra.
  ///
  /// In en, this message translates to:
  /// **'Switch to {title}?'**
  String switchToMantra(String title);

  /// No description provided for @switchMantraBody.
  ///
  /// In en, this message translates to:
  /// **'Your current count will be reset.'**
  String get switchMantraBody;

  /// No description provided for @keepCurrent.
  ///
  /// In en, this message translates to:
  /// **'Keep current'**
  String get keepCurrent;

  /// No description provided for @switchAction.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchAction;

  /// No description provided for @smallerMantraText.
  ///
  /// In en, this message translates to:
  /// **'Smaller mantra text'**
  String get smallerMantraText;

  /// No description provided for @largerMantraText.
  ///
  /// In en, this message translates to:
  /// **'Larger mantra text'**
  String get largerMantraText;

  /// No description provided for @libraryButton.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryButton;

  /// No description provided for @trainYourOwnMantra.
  ///
  /// In en, this message translates to:
  /// **'Train your own mantra'**
  String get trainYourOwnMantra;

  /// No description provided for @voiceCountingFrom.
  ///
  /// In en, this message translates to:
  /// **'Counting “{title}” from your {count} recordings. Other sounds and words are ignored.'**
  String voiceCountingFrom(String title, int count);

  /// No description provided for @voiceCountsOnlyTrained.
  ///
  /// In en, this message translates to:
  /// **'Voice counts only a mantra you have trained. Record “{title}” {min} to {max} times to begin.'**
  String voiceCountsOnlyTrained(String title, int min, int max);

  /// No description provided for @addMoreSamples.
  ///
  /// In en, this message translates to:
  /// **'Add more samples'**
  String get addMoreSamples;

  /// No description provided for @retrain.
  ///
  /// In en, this message translates to:
  /// **'Re-train'**
  String get retrain;

  /// No description provided for @clearTraining.
  ///
  /// In en, this message translates to:
  /// **'Clear training'**
  String get clearTraining;

  /// No description provided for @voiceBetaNote.
  ///
  /// In en, this message translates to:
  /// **'Beta: works on-device and offline. Accuracy improves with more recordings and drops in a noisy room. Pause briefly between repeats. Only your voice counts here; the + and − buttons correct the count.'**
  String get voiceBetaNote;

  /// No description provided for @trainVoiceFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Train your voice first'**
  String get trainVoiceFirstTitle;

  /// No description provided for @trainVoiceFirstBody.
  ///
  /// In en, this message translates to:
  /// **'Voice counts only your own trained mantra. Record “{title}” {min} to {max} times (about a minute). It stays on this device and works offline.'**
  String trainVoiceFirstBody(String title, int min, int max);

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @trainNow.
  ///
  /// In en, this message translates to:
  /// **'Train now'**
  String get trainNow;

  /// No description provided for @betaLabel.
  ///
  /// In en, this message translates to:
  /// **'BETA'**
  String get betaLabel;

  /// No description provided for @voiceTrained.
  ///
  /// In en, this message translates to:
  /// **'Voice trained'**
  String get voiceTrained;

  /// No description provided for @voiceNotTrained.
  ///
  /// In en, this message translates to:
  /// **'Voice not trained'**
  String get voiceNotTrained;

  /// No description provided for @sensitivityLabel.
  ///
  /// In en, this message translates to:
  /// **'Sensitivity'**
  String get sensitivityLabel;

  /// No description provided for @sensitivityStrict.
  ///
  /// In en, this message translates to:
  /// **'Strict'**
  String get sensitivityStrict;

  /// No description provided for @sensitivityLenient.
  ///
  /// In en, this message translates to:
  /// **'Lenient'**
  String get sensitivityLenient;

  /// No description provided for @sensitivityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get sensitivityMedium;

  /// No description provided for @clearVoiceTrainingTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear voice training?'**
  String get clearVoiceTrainingTitle;

  /// No description provided for @clearVoiceTrainingBody.
  ///
  /// In en, this message translates to:
  /// **'Voice will stop counting “{title}” until you train it again.'**
  String clearVoiceTrainingBody(String title);

  /// No description provided for @completionTitle.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get completionTitle;

  /// No description provided for @vibrationLabel.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibrationLabel;

  /// No description provided for @vibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A buzz every {n} counts, and a stronger one at the target.'**
  String vibrationSubtitle(int n);

  /// No description provided for @intensityLevel.
  ///
  /// In en, this message translates to:
  /// **'Intensity: level {level} of 5'**
  String intensityLevel(int level);

  /// No description provided for @testMilestone.
  ///
  /// In en, this message translates to:
  /// **'Test milestone'**
  String get testMilestone;

  /// No description provided for @testTarget.
  ///
  /// In en, this message translates to:
  /// **'Test target'**
  String get testTarget;

  /// No description provided for @ringtoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Ringtone'**
  String get ringtoneLabel;

  /// No description provided for @ringtoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A sound plays when the target is reached.'**
  String get ringtoneSubtitle;

  /// No description provided for @playSound.
  ///
  /// In en, this message translates to:
  /// **'Play sound'**
  String get playSound;

  /// No description provided for @combined.
  ///
  /// In en, this message translates to:
  /// **'Combined'**
  String get combined;

  /// No description provided for @combinedTooltip.
  ///
  /// In en, this message translates to:
  /// **'All four modes add to one shared count'**
  String get combinedTooltip;

  /// No description provided for @separate.
  ///
  /// In en, this message translates to:
  /// **'Separate'**
  String get separate;

  /// No description provided for @separateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Each mode keeps its own count'**
  String get separateTooltip;

  /// No description provided for @countModeSemantic.
  ///
  /// In en, this message translates to:
  /// **'Count mode'**
  String get countModeSemantic;

  /// No description provided for @combinedExplain.
  ///
  /// In en, this message translates to:
  /// **'Tap, Voice, Rhythm and Mala all add to one shared count toward one target.'**
  String get combinedExplain;

  /// No description provided for @separateExplain.
  ///
  /// In en, this message translates to:
  /// **'Each mode keeps its own count and its own progress toward the target. Reset and completion apply only to the mode you are in.'**
  String get separateExplain;

  /// No description provided for @countedLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} counted'**
  String countedLabel(int count);

  /// No description provided for @ofTarget.
  ///
  /// In en, this message translates to:
  /// **'of {count}'**
  String ofTarget(int count);

  /// No description provided for @removeOneTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove one'**
  String get removeOneTooltip;

  /// No description provided for @undoLabel.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoLabel;

  /// No description provided for @countLabel.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get countLabel;

  /// No description provided for @addOneTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add one'**
  String get addOneTooltip;

  /// No description provided for @focusLabel.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focusLabel;

  /// No description provided for @focusModeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Focus mode'**
  String get focusModeTooltip;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @targetReachedSeparate.
  ///
  /// In en, this message translates to:
  /// **'Target reached in {mode} 🙏  Reset this mode, switch mode, or raise the target.'**
  String targetReachedSeparate(String mode);

  /// No description provided for @targetReachedCombined.
  ///
  /// In en, this message translates to:
  /// **'Target reached 🙏  Reset, or raise the target.'**
  String get targetReachedCombined;

  /// No description provided for @resetModeCountTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset {mode} count?'**
  String resetModeCountTitle(String mode);

  /// No description provided for @resetSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset this session?'**
  String get resetSessionTitle;

  /// No description provided for @resetModeCountBody.
  ///
  /// In en, this message translates to:
  /// **'Your {mode} count of {count} will return to zero. The other modes keep their counts.'**
  String resetModeCountBody(String mode, int count);

  /// No description provided for @resetSessionBody.
  ///
  /// In en, this message translates to:
  /// **'Your count of {count} will return to zero.'**
  String resetSessionBody(int count);

  /// No description provided for @modeHelpTap.
  ///
  /// In en, this message translates to:
  /// **'Tap the ring, or anywhere in Focus mode. Only Tap mode counts screen taps.'**
  String get modeHelpTap;

  /// No description provided for @modeHelpRhythm.
  ///
  /// In en, this message translates to:
  /// **'Press Start and the count advances by itself at the pace below.'**
  String get modeHelpRhythm;

  /// No description provided for @modeHelpVoice.
  ///
  /// In en, this message translates to:
  /// **'Press Start, then chant your trained mantra. Each time it is recognised it adds one count, straight away; other sounds are ignored. Needs the microphone; works best in a quiet room.'**
  String get modeHelpVoice;

  /// No description provided for @modeHelpMala.
  ///
  /// In en, this message translates to:
  /// **'Press Start, then press either volume button to count. Handy with eyes closed or the phone in a pocket. The screen must stay on.'**
  String get modeHelpMala;

  /// No description provided for @countingModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Counting mode'**
  String get countingModeLabel;

  /// No description provided for @pacePrefix.
  ///
  /// In en, this message translates to:
  /// **'Pace: count {pace}'**
  String pacePrefix(String pace);

  /// No description provided for @modeSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'{mode} mode'**
  String modeSemanticLabel(String mode);

  /// No description provided for @tapAnywhereToCount.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to count'**
  String get tapAnywhereToCount;

  /// No description provided for @countingPace.
  ///
  /// In en, this message translates to:
  /// **'Counting {pace}'**
  String countingPace(String pace);

  /// No description provided for @pausedPace.
  ///
  /// In en, this message translates to:
  /// **'Paused · {pace}'**
  String pausedPace(String pace);

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get listening;

  /// No description provided for @startingMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Starting microphone… allow access if asked'**
  String get startingMicrophone;

  /// No description provided for @notTrainedYet.
  ///
  /// In en, this message translates to:
  /// **'Not trained yet · train your mantra to use Voice'**
  String get notTrainedYet;

  /// No description provided for @pausedPressStartListen.
  ///
  /// In en, this message translates to:
  /// **'Paused · press Start to listen'**
  String get pausedPressStartListen;

  /// No description provided for @pressVolumeKeys.
  ///
  /// In en, this message translates to:
  /// **'Press the volume keys to count'**
  String get pressVolumeKeys;

  /// No description provided for @capturingVolumeKeys.
  ///
  /// In en, this message translates to:
  /// **'Capturing the volume keys…'**
  String get capturingVolumeKeys;

  /// No description provided for @pausedPressStartVolume.
  ///
  /// In en, this message translates to:
  /// **'Paused · press Start to use the volume keys'**
  String get pausedPressStartVolume;

  /// No description provided for @modeTitleLine.
  ///
  /// In en, this message translates to:
  /// **'{mode} mode{own, select, yes{ · own count} other{}}'**
  String modeTitleLine(String mode, String own);

  /// No description provided for @voiceCountedMatch.
  ///
  /// In en, this message translates to:
  /// **'Counted · {percent}% match'**
  String voiceCountedMatch(int percent);

  /// No description provided for @voiceIgnoredMatch.
  ///
  /// In en, this message translates to:
  /// **'Ignored · {percent}% match (not your mantra)'**
  String voiceIgnoredMatch(int percent);

  /// No description provided for @paceFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get paceFieldLabel;

  /// No description provided for @paceHelpOk.
  ///
  /// In en, this message translates to:
  /// **'Counts {pace}.  (Allowed: {range})'**
  String paceHelpOk(String pace, String range);

  /// No description provided for @paceHelpError.
  ///
  /// In en, this message translates to:
  /// **'{error} Still counting {pace}.'**
  String paceHelpError(String error, String pace);

  /// No description provided for @sankalpLabel.
  ///
  /// In en, this message translates to:
  /// **'Sankalp'**
  String get sankalpLabel;

  /// No description provided for @sankalpHint.
  ///
  /// In en, this message translates to:
  /// **'State your intention for this practice…'**
  String get sankalpHint;

  /// No description provided for @targetSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get targetSectionTitle;

  /// No description provided for @byCount.
  ///
  /// In en, this message translates to:
  /// **'By count'**
  String get byCount;

  /// No description provided for @byTime.
  ///
  /// In en, this message translates to:
  /// **'By time'**
  String get byTime;

  /// No description provided for @customWithValue.
  ///
  /// In en, this message translates to:
  /// **'Custom · {value}'**
  String customWithValue(String value);

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @enterNumberRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a number from 1 to 9,999,999'**
  String get enterNumberRange;

  /// No description provided for @customCountTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom count'**
  String get customCountTitle;

  /// No description provided for @targetCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Target count'**
  String get targetCountLabel;

  /// No description provided for @setAction.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get setAction;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @enterDuration.
  ///
  /// In en, this message translates to:
  /// **'Enter a duration of 1 or more.'**
  String get enterDuration;

  /// No description provided for @maxDurationCapped.
  ///
  /// In en, this message translates to:
  /// **'Maximum is 99 h 59 min 59 s — it will be capped.'**
  String get maxDurationCapped;

  /// No description provided for @sessionLasts.
  ///
  /// In en, this message translates to:
  /// **'Session lasts {duration}.'**
  String sessionLasts(String duration);

  /// No description provided for @targetReachedFocus.
  ///
  /// In en, this message translates to:
  /// **'Target reached 🙏'**
  String get targetReachedFocus;

  /// No description provided for @screenTapsDoNotCount.
  ///
  /// In en, this message translates to:
  /// **'Screen taps do not count in {mode} mode. Use + or − to correct.'**
  String screenTapsDoNotCount(String mode);

  /// No description provided for @holdFingersToExit.
  ///
  /// In en, this message translates to:
  /// **'Hold {fingers} fingers for {seconds} seconds to exit'**
  String holdFingersToExit(int fingers, int seconds);

  /// No description provided for @holdToExitFocusMode.
  ///
  /// In en, this message translates to:
  /// **'Hold to exit focus mode'**
  String get holdToExitFocusMode;

  /// No description provided for @holdToExit.
  ///
  /// In en, this message translates to:
  /// **'Hold to exit'**
  String get holdToExit;

  /// No description provided for @keepHoldingToExit.
  ///
  /// In en, this message translates to:
  /// **'Keep holding to exit…'**
  String get keepHoldingToExit;

  /// No description provided for @addedRecordingsTo.
  ///
  /// In en, this message translates to:
  /// **'Added {added} {added, plural, one{recording} other{recordings}} to “{title}” ({total} in total)'**
  String addedRecordingsTo(int added, String title, int total);

  /// No description provided for @voiceTrainedFor.
  ///
  /// In en, this message translates to:
  /// **'Voice trained for “{title}” ({count} recordings)'**
  String voiceTrainedFor(String title, int count);

  /// No description provided for @trainedRecordingsCount.
  ///
  /// In en, this message translates to:
  /// **'Trained · {count} recordings'**
  String trainedRecordingsCount(int count);

  /// No description provided for @tooFewRecordings.
  ///
  /// In en, this message translates to:
  /// **'Too few recordings to count with. Add more, or re-train.'**
  String get tooFewRecordings;

  /// No description provided for @canCountAddMore.
  ///
  /// In en, this message translates to:
  /// **'Voice can count this mantra. Add up to {room} more recordings to improve accuracy without starting over.'**
  String canCountAddMore(int room);

  /// No description provided for @canCountAtMax.
  ///
  /// In en, this message translates to:
  /// **'Voice can count this mantra. You have the maximum of {max} recordings; re-train to replace them.'**
  String canCountAtMax(int max);

  /// No description provided for @pausedHeadline.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pausedHeadline;

  /// No description provided for @pausedSub.
  ///
  /// In en, this message translates to:
  /// **'{recorded} recorded. Continue, or save what you have.'**
  String pausedSub(int recorded);

  /// No description provided for @recordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Record it {min} to {max} times at your normal chanting speed ({recommended} is a good number). Voice will then count only your mantra.'**
  String recordInstructions(int min, int max, int recommended);

  /// No description provided for @openingMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Opening the microphone…'**
  String get openingMicrophone;

  /// No description provided for @stayQuiet.
  ///
  /// In en, this message translates to:
  /// **'Stay quiet for a moment…'**
  String get stayQuiet;

  /// No description provided for @listeningToRoom.
  ///
  /// In en, this message translates to:
  /// **'Listening to the room so background noise is not counted.'**
  String get listeningToRoom;

  /// No description provided for @sayYourMantra.
  ///
  /// In en, this message translates to:
  /// **'Say your mantra…'**
  String get sayYourMantra;

  /// No description provided for @recordingXofY.
  ///
  /// In en, this message translates to:
  /// **'Recording {current} of up to {max}'**
  String recordingXofY(int current, int max);

  /// No description provided for @allRecordingsCaptured.
  ///
  /// In en, this message translates to:
  /// **'All {count} recordings captured'**
  String allRecordingsCaptured(int count);

  /// No description provided for @saveToStartCounting.
  ///
  /// In en, this message translates to:
  /// **'Save them to start counting with Voice.'**
  String get saveToStartCounting;

  /// No description provided for @cannotUseMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Cannot use the microphone'**
  String get cannotUseMicrophone;

  /// No description provided for @canSaveNowHint.
  ///
  /// In en, this message translates to:
  /// **'You can save now, or keep going for more accuracy.'**
  String get canSaveNowHint;

  /// No description provided for @minAreEnough.
  ///
  /// In en, this message translates to:
  /// **'{min} are enough to start.'**
  String minAreEnough(int min);

  /// No description provided for @addingToSaved.
  ///
  /// In en, this message translates to:
  /// **'Adding to your {count} saved recordings.'**
  String addingToSaved(int count);

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get startRecording;

  /// No description provided for @openSettingsAction.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettingsAction;

  /// No description provided for @saveNRecordings.
  ///
  /// In en, this message translates to:
  /// **'Save {count} recordings'**
  String saveNRecordings(int count);

  /// No description provided for @recordMoreToSave.
  ///
  /// In en, this message translates to:
  /// **'Record {n} more to save'**
  String recordMoreToSave(int n);

  /// No description provided for @recordSampleToSave.
  ///
  /// In en, this message translates to:
  /// **'Record a sample to save'**
  String get recordSampleToSave;

  /// No description provided for @undoLast.
  ///
  /// In en, this message translates to:
  /// **'Undo last'**
  String get undoLast;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @continueRecording.
  ///
  /// In en, this message translates to:
  /// **'Continue recording'**
  String get continueRecording;

  /// No description provided for @startOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get startOver;

  /// No description provided for @recordedOfMax.
  ///
  /// In en, this message translates to:
  /// **'{recorded} of up to {max} recordings'**
  String recordedOfMax(int recorded, int max);

  /// No description provided for @voiceBetaNoteTraining.
  ///
  /// In en, this message translates to:
  /// **'Beta. Everything happens on this device, offline: only numbers describing the sound are saved, never the audio. More recordings make counting more accurate (up to {max}); a noisy room makes it less accurate. Say the mantra once, then pause briefly before the next repeat.'**
  String voiceBetaNoteTraining(int max);

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// A button/label meaning today's date
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Semantic label: calendar header chevron
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// Semantic label: calendar header chevron
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// A marked date's kind: a good day
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get markTypeGood;

  /// A marked date's kind: a cautious day
  ///
  /// In en, this message translates to:
  /// **'Cautious'**
  String get markTypeCautious;

  /// A marked date's kind: a neutral day
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get markTypeNeutral;

  /// When to be reminded: not at all
  ///
  /// In en, this message translates to:
  /// **'No time'**
  String get reminderModeNone;

  /// When to be reminded: a single time
  ///
  /// In en, this message translates to:
  /// **'One time'**
  String get reminderModeOnce;

  /// When to be reminded: several times
  ///
  /// In en, this message translates to:
  /// **'Several times'**
  String get reminderModeSeveral;

  /// How a mark repeats: not at all
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get repeatRuleOnce;

  /// How a mark repeats: every day
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatRuleDaily;

  /// How a mark repeats: every week
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatRuleWeekly;

  /// How a mark repeats: every month
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get repeatRuleMonthly;

  /// How a mark repeats: every 3 months
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get repeatRuleQuarterly;

  /// How a mark repeats: every 6 months
  ///
  /// In en, this message translates to:
  /// **'Half-yearly'**
  String get repeatRuleHalfYearly;

  /// How a mark repeats: every year
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get repeatRuleYearly;

  /// Whether a mark appears on Home: it doesn't
  ///
  /// In en, this message translates to:
  /// **'Don\'t show'**
  String get homeModeNone;

  /// Whether a mark appears on Home: once, in the morning
  ///
  /// In en, this message translates to:
  /// **'Once in the morning'**
  String get homeModeMorning;

  /// Whether a mark appears on Home: pinned all day
  ///
  /// In en, this message translates to:
  /// **'Keep all day'**
  String get homeModeAllDay;

  /// How marked dates are drawn: a small dot
  ///
  /// In en, this message translates to:
  /// **'Dot'**
  String get markStyleDot;

  /// How marked dates are drawn: the whole cell filled
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get markStyleFilled;

  /// How marked dates are drawn: a soft highlight
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get markStyleHighlight;

  /// How marked dates are drawn: an outlined circle
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get markStyleCircle;

  /// How marked dates are drawn: an outlined square
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get markStyleSquare;

  /// Name of an icon offered for a mark
  ///
  /// In en, this message translates to:
  /// **'Om'**
  String get emojiOm;

  /// Name of an icon offered for a mark
  ///
  /// In en, this message translates to:
  /// **'Khanda'**
  String get emojiKhanda;

  /// Name of an icon offered for a mark
  ///
  /// In en, this message translates to:
  /// **'Mala'**
  String get emojiMala;

  /// Name of an icon offered for a mark
  ///
  /// In en, this message translates to:
  /// **'Diya'**
  String get emojiDiya;

  /// Name of an icon offered for a mark
  ///
  /// In en, this message translates to:
  /// **'Bell'**
  String get emojiBell;

  /// Name of an icon offered for a mark
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get emojiSunrise;

  /// Name of an icon offered for a mark
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get emojiStar;

  /// Name of an icon offered for a mark
  ///
  /// In en, this message translates to:
  /// **'Sparkle'**
  String get emojiSparkle;

  /// Name of an icon offered for a mark
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get emojiMoney;

  /// Name of an icon offered for a mark
  ///
  /// In en, this message translates to:
  /// **'Handshake'**
  String get emojiHandshake;

  /// Name of an icon offered for a mark
  ///
  /// In en, this message translates to:
  /// **'Avoid'**
  String get emojiAvoid;

  /// Name of an icon offered for a mark
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get emojiDone;

  /// Default title of an unlabelled good mark
  ///
  /// In en, this message translates to:
  /// **'Good day'**
  String get markTitleGood;

  /// Default title of an unlabelled cautious mark
  ///
  /// In en, this message translates to:
  /// **'Cautious day'**
  String get markTitleCautious;

  /// Default title of an unlabelled neutral mark
  ///
  /// In en, this message translates to:
  /// **'Neutral day'**
  String get markTitleNeutral;

  /// Notification body when a good mark has no details
  ///
  /// In en, this message translates to:
  /// **'A good day.'**
  String get reminderBodyGood;

  /// Notification body when a cautious mark has no details
  ///
  /// In en, this message translates to:
  /// **'Be careful today.'**
  String get reminderBodyCautious;

  /// Notification body when a neutral mark has no details
  ///
  /// In en, this message translates to:
  /// **'Marked in your calendar.'**
  String get reminderBodyNeutral;

  /// Android notification channel name
  ///
  /// In en, this message translates to:
  /// **'Calendar reminders'**
  String get channelCalendarRemindersName;

  /// Android notification channel description
  ///
  /// In en, this message translates to:
  /// **'Reminders for the dates you marked in Sadho'**
  String get channelCalendarRemindersDesc;

  /// Android notification channel name
  ///
  /// In en, this message translates to:
  /// **'Alarms and timers'**
  String get channelAlarmsName;

  /// Android notification channel description
  ///
  /// In en, this message translates to:
  /// **'The sun-based alarm and finished timers'**
  String get channelAlarmsDesc;

  /// Summary of a mark's repeat, shown on its card
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get repeatSummaryOnce;

  /// Summary of a mark's repeat, shown on its card
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get repeatSummaryDaily;

  /// Summary of a mark's repeat, shown on its card
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get repeatSummaryWeekly;

  /// Summary of a mark's repeat, shown on its card
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get repeatSummaryMonthly;

  /// Summary of a mark's repeat, shown on its card
  ///
  /// In en, this message translates to:
  /// **'Every 3 months'**
  String get repeatSummaryQuarterly;

  /// Summary of a mark's repeat, shown on its card
  ///
  /// In en, this message translates to:
  /// **'Every 6 months'**
  String get repeatSummaryHalfYearly;

  /// Summary of a mark's repeat, shown on its card
  ///
  /// In en, this message translates to:
  /// **'Every year'**
  String get repeatSummaryYearly;

  /// Summary tag on a mark's card
  ///
  /// In en, this message translates to:
  /// **'Remind at {times}'**
  String reminderSummaryAt(String times);

  /// Summary tag on a mark's card
  ///
  /// In en, this message translates to:
  /// **'On Home from {time}'**
  String homeSummaryFrom(String time);

  /// Summary tag on a mark's card
  ///
  /// In en, this message translates to:
  /// **'On Home all day'**
  String get homeSummaryAllDay;

  /// Heading above the month's list of marks
  ///
  /// In en, this message translates to:
  /// **'Marks in {month}'**
  String marksInMonth(String month);

  /// Shown when a month has no marks
  ///
  /// In en, this message translates to:
  /// **'Nothing marked in {month}. Tap a date to add a mark.'**
  String noMarksInMonth(String month);

  /// Heading of the mark-style picker card
  ///
  /// In en, this message translates to:
  /// **'Mark style'**
  String get markStyleSectionTitle;

  /// Subtitle of the mark-style picker card
  ///
  /// In en, this message translates to:
  /// **'How marked dates look. Applies to every mark.'**
  String get markStyleSectionHint;

  /// Screen-reader label for a mark-style choice
  ///
  /// In en, this message translates to:
  /// **'{style} mark style'**
  String markStyleSemantic(String style);

  /// Appended to a calendar day's screen-reader label when it is today
  ///
  /// In en, this message translates to:
  /// **', today'**
  String get dayCellToday;

  /// Joins two or more mark kinds in a calendar day's screen-reader label
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get dayCellAnd;

  /// Appended to a calendar day's screen-reader label listing what it is marked as
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{, marked {kinds}, 1 mark} other{, marked {kinds}, {count} marks}}'**
  String dayCellMarkedSuffix(int count, String kinds);

  /// Shown when Several times is chosen with no time added
  ///
  /// In en, this message translates to:
  /// **'Add at least one time, or choose \"No time\".'**
  String get markEditorNoTimeWarning;

  /// No description provided for @notificationsOffWarning.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for Sadho, so this reminder will not ring. Turn them on in your phone\'s settings.'**
  String get notificationsOffWarning;

  /// Stands in for an unlabelled mark's title in the delete confirmation
  ///
  /// In en, this message translates to:
  /// **'this mark'**
  String get deleteMarkFallbackTitle;

  /// Title of the delete-mark confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete this mark?'**
  String get deleteMarkQuestion;

  /// Body of the delete-mark confirmation dialog, for a repeating mark
  ///
  /// In en, this message translates to:
  /// **'Delete {title} and all of its repeats? Its reminders are removed too.'**
  String deleteMarkRepeatsBody(String title);

  /// Body of the delete-mark confirmation dialog, for a one-off mark
  ///
  /// In en, this message translates to:
  /// **'Delete {title}? Its reminders are removed too.'**
  String deleteMarkBody(String title);

  /// Title of the mark editor when creating, and the chip to start a new one
  ///
  /// In en, this message translates to:
  /// **'New mark'**
  String get newMark;

  /// Title of the mark editor when editing an existing mark
  ///
  /// In en, this message translates to:
  /// **'Edit mark'**
  String get editMark;

  /// Notice shown when editing a repeating mark
  ///
  /// In en, this message translates to:
  /// **'{repeatSummary}, from {date}. Changes apply to every repeat.'**
  String repeatFromNotice(String repeatSummary, String date);

  /// Heading of the mark-type chips in the editor
  ///
  /// In en, this message translates to:
  /// **'Mark type'**
  String get markTypeSectionTitle;

  /// Heading of the icon chips in the editor
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconSectionTitle;

  /// The no-icon choice in the editor
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get iconNone;

  /// Label of the mark's text field
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get labelFieldLabel;

  /// Label of the mark's notes field
  ///
  /// In en, this message translates to:
  /// **'Details / notes'**
  String get detailsFieldLabel;

  /// Heading of the reminder section in the editor
  ///
  /// In en, this message translates to:
  /// **'Remind me at'**
  String get remindMeAtSectionTitle;

  /// Tooltip on a reminder time's delete button
  ///
  /// In en, this message translates to:
  /// **'Remove {time}'**
  String removeTimeTooltip(String time);

  /// Button that adds another reminder time
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get addTime;

  /// Heading of the repeat chips in the editor
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatSectionTitle;

  /// Heading of the Home-card section in the editor
  ///
  /// In en, this message translates to:
  /// **'On your home screen'**
  String get onHomeScreenSectionTitle;

  /// Button showing when a Home card starts
  ///
  /// In en, this message translates to:
  /// **'Show from {time}'**
  String showFromTime(String time);

  /// Explains the Don't show Home option
  ///
  /// In en, this message translates to:
  /// **'The mark stays on the calendar only.'**
  String get homeModeNoneExplain;

  /// Explains the Once in the morning Home option
  ///
  /// In en, this message translates to:
  /// **'A card appears on Home at that time. Swipe it away when done: it comes back on the next repeat.'**
  String get homeModeMorningExplain;

  /// Explains the Keep all day Home option
  ///
  /// In en, this message translates to:
  /// **'A card stays pinned on Home all day (it cannot be swiped away).'**
  String get homeModeAllDayExplain;

  /// A relative day label
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// A relative day label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Button: restarts a finished timer
  ///
  /// In en, this message translates to:
  /// **'Start again'**
  String get startAgain;

  /// Button that opens the phone's system Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsAction;

  /// Clock tool card subtitle
  ///
  /// In en, this message translates to:
  /// **'A large, live time and date'**
  String get clockToolClockSubtitle;

  /// Clock tool card title
  ///
  /// In en, this message translates to:
  /// **'Sun-based alarm'**
  String get clockToolSunAlarmTitle;

  /// Clock tool card subtitle
  ///
  /// In en, this message translates to:
  /// **'Wake at sunrise or sunset, with an offset'**
  String get clockToolSunAlarmSubtitle;

  /// Clock tool card title
  ///
  /// In en, this message translates to:
  /// **'World clock'**
  String get clockToolWorldClockTitle;

  /// Clock tool card subtitle
  ///
  /// In en, this message translates to:
  /// **'Amritsar, Haridwar, London and more'**
  String get clockToolWorldClockSubtitle;

  /// Clock tool card title
  ///
  /// In en, this message translates to:
  /// **'Sadhana & vrat timer'**
  String get clockToolTimerTitle;

  /// Clock tool card subtitle
  ///
  /// In en, this message translates to:
  /// **'Aarti, Chalisa, Path, Havan, or until sunset'**
  String get clockToolTimerSubtitle;

  /// Clock tool card title
  ///
  /// In en, this message translates to:
  /// **'Paath stopwatch'**
  String get clockToolStopwatchTitle;

  /// Clock tool card subtitle
  ///
  /// In en, this message translates to:
  /// **'Start, stop and lap'**
  String get clockToolStopwatchSubtitle;

  /// Which sun event the alarm follows
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunEventSunrise;

  /// Which sun event the alarm follows
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunEventSunset;

  /// e.g. At sunrise
  ///
  /// In en, this message translates to:
  /// **'At {event}'**
  String offsetAtEvent(String event);

  /// An offset of only minutes
  ///
  /// In en, this message translates to:
  /// **'{m} min'**
  String offsetMinutesOnly(int m);

  /// An offset of only hours
  ///
  /// In en, this message translates to:
  /// **'{h} hr'**
  String offsetHoursOnly(int h);

  /// An offset of hours and minutes
  ///
  /// In en, this message translates to:
  /// **'{h} hr {m} min'**
  String offsetHoursMinutes(int h, int m);

  /// e.g. 30 min before
  ///
  /// In en, this message translates to:
  /// **'{amount} before'**
  String offsetBefore(String amount);

  /// e.g. 30 min after
  ///
  /// In en, this message translates to:
  /// **'{amount} after'**
  String offsetAfter(String amount);

  /// Where a place came from: read from the phone
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get locationSourceDevice;

  /// Where a place came from: a saved past reading
  ///
  /// In en, this message translates to:
  /// **'Your last known location'**
  String get locationSourceSaved;

  /// Where a place came from: nothing known
  ///
  /// In en, this message translates to:
  /// **'Amritsar (default)'**
  String get locationSourceFallback;

  /// One-line explanation of the place used for sun times
  ///
  /// In en, this message translates to:
  /// **'Using your location'**
  String get locSummaryDevice;

  /// One-line explanation of the place used for sun times
  ///
  /// In en, this message translates to:
  /// **'Using your last known location'**
  String get locSummarySaved;

  /// One-line explanation of the place used for sun times
  ///
  /// In en, this message translates to:
  /// **'Using Amritsar. Location is blocked in Settings.'**
  String get locSummaryBlocked;

  /// One-line explanation of the place used for sun times
  ///
  /// In en, this message translates to:
  /// **'Using Amritsar. Turn on location for exact times.'**
  String get locSummaryServiceOff;

  /// One-line explanation of the place used for sun times
  ///
  /// In en, this message translates to:
  /// **'Using Amritsar.'**
  String get locSummaryUnsupported;

  /// One-line explanation of the place used for sun times
  ///
  /// In en, this message translates to:
  /// **'Using Amritsar. Allow location for exact times.'**
  String get locSummaryDefault;

  /// A devotional-practice timer preset
  ///
  /// In en, this message translates to:
  /// **'Aarti'**
  String get presetAarti;

  /// A devotional-practice timer preset
  ///
  /// In en, this message translates to:
  /// **'Chalisa'**
  String get presetChalisa;

  /// A devotional-practice timer preset
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get presetPath;

  /// A devotional-practice timer preset
  ///
  /// In en, this message translates to:
  /// **'Havan'**
  String get presetHavan;

  /// The timer option that counts down to sunset
  ///
  /// In en, this message translates to:
  /// **'Vrat → sunset'**
  String get vratToSunset;

  /// A timer preset choice, e.g. Aarti · 5 min
  ///
  /// In en, this message translates to:
  /// **'{label} · {minutes} min'**
  String presetChipLabel(String label, int minutes);

  /// Shown when Vrat → sunset has no sunset to target (polar day/night)
  ///
  /// In en, this message translates to:
  /// **'There is no sunset to count down to here right now.'**
  String get clockNoSunsetHere;

  /// Shown when the vrat timer starts after today's sunset
  ///
  /// In en, this message translates to:
  /// **'Today\'s sunset has passed: counting to tomorrow\'s.'**
  String get clockSunsetPassedTomorrow;

  /// Notification title when a timer ends
  ///
  /// In en, this message translates to:
  /// **'🔔 {label} finished'**
  String timerFinishedTitle(String label);

  /// Notification body when the vrat timer ends
  ///
  /// In en, this message translates to:
  /// **'Sunset has arrived 🙏'**
  String get sunsetArrived;

  /// Notification body when a preset timer ends
  ///
  /// In en, this message translates to:
  /// **'Your {label} time is up 🙏'**
  String timerTimeUp(String label);

  /// Notification title for the sun-based alarm
  ///
  /// In en, this message translates to:
  /// **'{emoji} {event} alarm'**
  String sunAlarmNotifTitle(String emoji, String event);

  /// Notification body for the sun-based alarm
  ///
  /// In en, this message translates to:
  /// **'{event} is at {time} · {offset}'**
  String sunAlarmNotifBody(String event, String time, String offset);

  /// Status line prefix: the sun alarm is on
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get statusOn;

  /// Status line suffix: a timer has ended
  ///
  /// In en, this message translates to:
  /// **'finished'**
  String get finished;

  /// Status line suffix: time remaining on a running timer
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get left;

  /// Status line suffix: a timer is paused
  ///
  /// In en, this message translates to:
  /// **'paused'**
  String get paused;

  /// Status line: the stopwatch is running
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get runningStatus;

  /// Status line: the stopwatch is stopped
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get stoppedStatus;

  /// Button and column header: records/labels a stopwatch lap
  ///
  /// In en, this message translates to:
  /// **'Lap'**
  String get lap;

  /// Column header on the stopwatch's lap list
  ///
  /// In en, this message translates to:
  /// **'Lap time'**
  String get lapTime;

  /// Column header on the stopwatch's lap list: running total
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Tag on the stopwatch's quickest lap
  ///
  /// In en, this message translates to:
  /// **'Fastest'**
  String get fastest;

  /// Tag on the stopwatch's slowest lap
  ///
  /// In en, this message translates to:
  /// **'Slowest'**
  String get slowest;

  /// Empty state before the stopwatch has any laps
  ///
  /// In en, this message translates to:
  /// **'Tap Lap to mark a lap.'**
  String get tapLapToMark;

  /// Empty state before the stopwatch has started
  ///
  /// In en, this message translates to:
  /// **'Start, then tap Lap at each round.'**
  String get startThenTapLap;

  /// Shown when notification permission was refused for the sun alarm
  ///
  /// In en, this message translates to:
  /// **'Allow notifications in Settings so the alarm can ring.'**
  String get allowNotificationsForAlarm;

  /// Heading above the computed alarm time, when the alarm is on
  ///
  /// In en, this message translates to:
  /// **'Alarm rings at'**
  String get alarmRingsAt;

  /// Heading above the computed alarm time, when the alarm is off
  ///
  /// In en, this message translates to:
  /// **'Alarm would ring at'**
  String get alarmWouldRingAt;

  /// Shown when there is no sunrise/sunset to compute (polar day/night)
  ///
  /// In en, this message translates to:
  /// **'No {event} to follow here right now.'**
  String noEventToFollow(String event);

  /// The sun alarm's on/off switch label
  ///
  /// In en, this message translates to:
  /// **'Alarm on'**
  String get alarmOnLabel;

  /// Subtitle under the sun alarm's on/off switch
  ///
  /// In en, this message translates to:
  /// **'Recalculated every day as the sun moves'**
  String get recalculatedDaily;

  /// Today's sunrise and sunset at the chosen place
  ///
  /// In en, this message translates to:
  /// **'Today here: sunrise {rise} · sunset {set}'**
  String todayHereSunriseSunset(String rise, String set);

  /// Heading above the offset choices
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get whenLabel;

  /// Label of the custom-offset minutes field
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutesLabel;

  /// Helper text under the custom-offset minutes field
  ///
  /// In en, this message translates to:
  /// **'Up to 1440'**
  String get upTo1440;

  /// Direction: the offset is before the sun event
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get before;

  /// Direction: the offset is after the sun event
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get after;

  /// Button that asks for the phone's location
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// Appended when the phone allowed location but gave no position
  ///
  /// In en, this message translates to:
  /// **' · could not read your position'**
  String get couldNotReadPosition;

  /// Shown on the timer's face once it reaches zero
  ///
  /// In en, this message translates to:
  /// **'Time’s up 🙏'**
  String get timesUp;

  /// The vrat timer's target time
  ///
  /// In en, this message translates to:
  /// **'Sunset at {time}'**
  String sunsetAtTime(String time);

  /// A city's date, days ahead of the viewer's
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String cityInDays(int days);

  /// A city's date, days behind the viewer's
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String cityDaysAgo(int days);

  /// A city that is in the same time zone as the viewer
  ///
  /// In en, this message translates to:
  /// **'Same time as you'**
  String get citySameTime;

  /// A time difference of only minutes
  ///
  /// In en, this message translates to:
  /// **'{m} m'**
  String cityAmountMinutes(int m);

  /// A time difference of only hours
  ///
  /// In en, this message translates to:
  /// **'{h} h'**
  String cityAmountHours(int h);

  /// A time difference of hours and minutes
  ///
  /// In en, this message translates to:
  /// **'{h} h {m} m'**
  String cityAmountHoursMinutes(int h, int m);

  /// e.g. 5 h 30 m ahead of you
  ///
  /// In en, this message translates to:
  /// **'{amount} ahead of you'**
  String cityAheadOfYou(String amount);

  /// e.g. 4 h behind you
  ///
  /// In en, this message translates to:
  /// **'{amount} behind you'**
  String cityBehindYou(String amount);

  /// The Today card's tradition switch
  ///
  /// In en, this message translates to:
  /// **'Hindu'**
  String get traditionHindu;

  /// The Today card's tradition switch
  ///
  /// In en, this message translates to:
  /// **'Sikh'**
  String get traditionSikh;

  /// The Today card's tradition switch
  ///
  /// In en, this message translates to:
  /// **'By place'**
  String get traditionPlace;

  /// A line on the Today card (Hindu)
  ///
  /// In en, this message translates to:
  /// **'Tithi'**
  String get todayLabelTithi;

  /// A line on the Today card (Hindu)
  ///
  /// In en, this message translates to:
  /// **'Nakshatra'**
  String get todayLabelNakshatra;

  /// A line on the Today card (Hindu)
  ///
  /// In en, this message translates to:
  /// **'Rahu Kaal'**
  String get todayLabelRahu;

  /// A line on the Today card (Hindu)
  ///
  /// In en, this message translates to:
  /// **'Abhijit muhurat'**
  String get todayLabelAbhijit;

  /// A line on the Today card (Sikh)
  ///
  /// In en, this message translates to:
  /// **'Hukamnama'**
  String get todayLabelHukamnama;

  /// A line on the Today card (Sikh)
  ///
  /// In en, this message translates to:
  /// **'Nitnem due'**
  String get todayLabelNitnem;

  /// A line on the Today card (Sikh)
  ///
  /// In en, this message translates to:
  /// **'Next Gurpurab'**
  String get todayLabelGurpurab;

  /// A line on the Today card (By place)
  ///
  /// In en, this message translates to:
  /// **'Local festival'**
  String get todayLabelFestival;

  /// A line on the Today card (By place)
  ///
  /// In en, this message translates to:
  /// **'Auspicious window'**
  String get todayLabelWindow;

  /// Tag on a placeholder panchang value
  ///
  /// In en, this message translates to:
  /// **'EXAMPLE'**
  String get exampleTag;

  /// Explains the EXAMPLE tags on the Today card
  ///
  /// In en, this message translates to:
  /// **'Values marked EXAMPLE are placeholders: real panchang data comes in a later phase.'**
  String get exampleNote;

  /// Explains that sunrise/sunset are real, unlike the EXAMPLE values
  ///
  /// In en, this message translates to:
  /// **'Sunrise and sunset are worked out for your place. {where}.'**
  String liveNote(String where);

  /// Home screen greeting, by time of day
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// Home screen greeting, by time of day
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// Home screen greeting, by time of day
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// Home screen greeting, by time of day
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get greetingNight;

  /// Shown when no calendar mark is flagged for Home
  ///
  /// In en, this message translates to:
  /// **'Nothing on your home screen today'**
  String get homeEmptyTitle;

  /// Explains how to get a card onto Home
  ///
  /// In en, this message translates to:
  /// **'Mark a date in the Calendar and choose \"On your home screen\" to see it here.'**
  String get homeEmptyBody;

  /// Hint on a Home card that cannot be swiped away
  ///
  /// In en, this message translates to:
  /// **'Pinned all day'**
  String get pinnedAllDay;

  /// Hint on a Home card that can be swiped away
  ///
  /// In en, this message translates to:
  /// **'Swipe to dismiss for today'**
  String get swipeToDismiss;

  /// Snack bar shown after swiping away a Home card
  ///
  /// In en, this message translates to:
  /// **'Done for today: {title}'**
  String doneForToday(String title);

  /// Snack bar action that restores a dismissed Home card
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoAction;

  /// Revealed behind a Home card while swiping it away
  ///
  /// In en, this message translates to:
  /// **'Done for today'**
  String get doneForTodayLabel;

  /// Heading of the plans section
  ///
  /// In en, this message translates to:
  /// **'Paath & mantra plans'**
  String get plansTitle;

  /// Button that opens the new-plan sheet
  ///
  /// In en, this message translates to:
  /// **'Add plan'**
  String get addPlan;

  /// Stat label: consecutive days with a plan marked done
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get dayStreak;

  /// Stat label: how many plans are still in progress
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{active plan} other{active plans}}'**
  String activePlanCount(int count);

  /// Empty state before any plan is started
  ///
  /// In en, this message translates to:
  /// **'No plans yet'**
  String get noPlansYet;

  /// Explains plans, shown with the suggestions
  ///
  /// In en, this message translates to:
  /// **'Commit to a paath or mantra for a number of days and tick each day off. Start with one of these, or add your own.'**
  String get plansEmptyBody;

  /// Tooltip on a plan card's menu button
  ///
  /// In en, this message translates to:
  /// **'Plan options'**
  String get planOptionsTooltip;

  /// Menu item that deletes a plan
  ///
  /// In en, this message translates to:
  /// **'Delete plan'**
  String get deletePlanMenuItem;

  /// Title of the delete-plan confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete plan?'**
  String get deletePlanQuestion;

  /// Body of the delete-plan confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'“{title}” and its progress will be removed.'**
  String deletePlanBody(String title);

  /// e.g. Paath · 40 days, or a suggestion's name and length
  ///
  /// In en, this message translates to:
  /// **'{title} · {days} days'**
  String titledDaysTag(String title, int days);

  /// A finished plan's progress line
  ///
  /// In en, this message translates to:
  /// **'Completed · {completed} of {total} days'**
  String completedOfDays(int completed, int total);

  /// An in-progress plan's progress line
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} days'**
  String ofDays(int completed, int total);

  /// Button shown once today is marked done on a plan
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get doneTodayButton;

  /// Button that marks today done on a plan
  ///
  /// In en, this message translates to:
  /// **'Mark today done'**
  String get markTodayDone;

  /// Title of the new-plan sheet
  ///
  /// In en, this message translates to:
  /// **'New plan'**
  String get newPlanTitle;

  /// Subtitle of the new-plan sheet
  ///
  /// In en, this message translates to:
  /// **'Pick a paath or mantra and how many days you will keep it up.'**
  String get newPlanSubtitle;

  /// Label of the plan title field
  ///
  /// In en, this message translates to:
  /// **'Paath or mantra'**
  String get paathOrMantraLabel;

  /// Validation error: the plan title field is empty
  ///
  /// In en, this message translates to:
  /// **'Give the plan a name'**
  String get giveThePlanAName;

  /// Validation error: the days field is out of range
  ///
  /// In en, this message translates to:
  /// **'Choose {min} to {max} days'**
  String chooseDaysRange(int min, int max);

  /// Heading above the day-count choices
  ///
  /// In en, this message translates to:
  /// **'For how many days?'**
  String get forHowManyDays;

  /// Label of the plan length field
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get daysFieldLabel;

  /// Button that creates the new plan
  ///
  /// In en, this message translates to:
  /// **'Start plan'**
  String get startPlanButton;

  /// A plan's kind: a paath
  ///
  /// In en, this message translates to:
  /// **'Paath'**
  String get planKindPaath;

  /// A plan's kind: a mantra
  ///
  /// In en, this message translates to:
  /// **'Mantra'**
  String get planKindMantra;

  /// The Profile page's app bar title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Section heading on Profile
  ///
  /// In en, this message translates to:
  /// **'Sadhana settings'**
  String get sadhanaSettingsTitle;

  /// Validation error for the email field
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validEmailError;

  /// Validation error for the name field
  ///
  /// In en, this message translates to:
  /// **'Keep it under {max} characters'**
  String nameTooLong(int max);

  /// Validation error: current password is empty
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// Validation error: new password is too short
  ///
  /// In en, this message translates to:
  /// **'Use at least {min} characters'**
  String passwordTooShort(int min);

  /// Validation error: new password equals the current one
  ///
  /// In en, this message translates to:
  /// **'Choose a password you have not used'**
  String get passwordAlreadyUsed;

  /// Validation error: confirm password mismatch
  ///
  /// In en, this message translates to:
  /// **'The two passwords do not match'**
  String get passwordsDontMatch;

  /// Title of the change-password sheet, and the Account card's menu item
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// Explains that the password form does not really change anything yet
  ///
  /// In en, this message translates to:
  /// **'Accounts arrive in a later phase; until then this only checks your entries and changes nothing.'**
  String get accountsLaterNote;

  /// Label of the current-password field
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// Label of the new-password field
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// Label of the confirm-password field
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPasswordLabel;

  /// Checkbox that reveals the password fields
  ///
  /// In en, this message translates to:
  /// **'Show passwords'**
  String get showPasswords;

  /// Button that submits the change-password form
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePasswordButton;

  /// A profile-completion step
  ///
  /// In en, this message translates to:
  /// **'Add your name'**
  String get stepAddName;

  /// A profile-completion step
  ///
  /// In en, this message translates to:
  /// **'Add your email'**
  String get stepAddEmail;

  /// A profile-completion step
  ///
  /// In en, this message translates to:
  /// **'Pick your tradition on Home'**
  String get stepPickTradition;

  /// A profile-completion step
  ///
  /// In en, this message translates to:
  /// **'Turn on the daily reminder'**
  String get stepTurnOnReminder;

  /// A profile-completion step
  ///
  /// In en, this message translates to:
  /// **'Start a paath or mantra plan'**
  String get stepStartPlan;

  /// Heading of the profile-completion card
  ///
  /// In en, this message translates to:
  /// **'Profile completion'**
  String get profileCompletionTitle;

  /// Shown once every profile-completion step is done
  ///
  /// In en, this message translates to:
  /// **'Profile complete! Your free premium reward will be waiting when premium launches.'**
  String get profileCompleteReward;

  /// Shown while the profile is not yet fully complete
  ///
  /// In en, this message translates to:
  /// **'Reach 100% to earn free premium when it launches.'**
  String get reachRewardNote;

  /// Section heading: app info
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// Row label: the app's name
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get appLabel;

  /// Row label: the app's website
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get websiteLabel;

  /// Row label: the app's version number
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// Shown after closing the change-password sheet
  ///
  /// In en, this message translates to:
  /// **'Password change will work once accounts are added.'**
  String get passwordWillWorkLater;

  /// Shown after signing out of a real account
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get signedOut;

  /// Shown after tapping Sign out with no account
  ///
  /// In en, this message translates to:
  /// **'You are not signed in yet: accounts arrive in a later phase. Your data stays on this phone.'**
  String get notSignedInYet;

  /// Section heading: sign-in and password
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// Button that signs out
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutButton;

  /// Shown after a successful export
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get backupSaved;

  /// Shown when the user backs out of saving
  ///
  /// In en, this message translates to:
  /// **'Backup cancelled'**
  String get backupCancelled;

  /// Shown when export fails
  ///
  /// In en, this message translates to:
  /// **'Could not save the backup. Try again.'**
  String get couldNotSaveBackup;

  /// Shown when the chosen file is not valid JSON or not a Sadho backup
  ///
  /// In en, this message translates to:
  /// **'That file is not a Sadho backup.'**
  String get backupNotSadho;

  /// Shown when restore fails for an unexpected reason
  ///
  /// In en, this message translates to:
  /// **'Could not read that file.'**
  String get couldNotReadFile;

  /// Shown when a backup's structure is unusable
  ///
  /// In en, this message translates to:
  /// **'The backup file is damaged.'**
  String get backupDamaged;

  /// Shown when a backup's version is newer than this app understands
  ///
  /// In en, this message translates to:
  /// **'This backup was made by a newer version of Sadho. Update the app first.'**
  String get backupTooNew;

  /// Shown when a backup has no boxes this app knows
  ///
  /// In en, this message translates to:
  /// **'That backup has no Sadho data in it.'**
  String get backupNoData;

  /// Shown when the chosen file exceeds the size limit
  ///
  /// In en, this message translates to:
  /// **'That file is too big to be a Sadho backup.'**
  String get backupTooBig;

  /// Appended to the restore prompt when the backup's date is known
  ///
  /// In en, this message translates to:
  /// **' made on {date}'**
  String madeOnSuffix(String date);

  /// Body of the restore confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'A backup{made} with {count} saved items. It will replace what is on this phone now: marks, plans, mantras, voice training and settings.'**
  String restoreBackupBody(String made, int count);

  /// Title of the restore confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Restore this backup?'**
  String get restoreThisBackup;

  /// Title of the dialog shown after a successful restore
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get backupRestoredTitle;

  /// Body of the dialog shown after a successful restore
  ///
  /// In en, this message translates to:
  /// **'Sadho will reload with your restored data.'**
  String get backupRestoredBody;

  /// Section heading: export/import
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupRestoreTitle;

  /// Explains what Export/Restore do
  ///
  /// In en, this message translates to:
  /// **'Save your marks, plans, mantras, voice training and settings to a file you choose (Drive, Files, email it to yourself). Restore it on this or another phone.'**
  String get backupExplain;

  /// Button that saves a backup file
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportButton;

  /// Button that opens a backup file
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreButton;

  /// A disabled row: automatic backup, not built yet
  ///
  /// In en, this message translates to:
  /// **'Cloud sync'**
  String get cloudSyncTitle;

  /// Subtitle of the disabled Cloud sync row
  ///
  /// In en, this message translates to:
  /// **'Coming later'**
  String get comingLater;

  /// Native file-picker dialog title when exporting
  ///
  /// In en, this message translates to:
  /// **'Save your Sadho backup'**
  String get saveBackupDialogTitle;

  /// Native file-picker dialog title when restoring
  ///
  /// In en, this message translates to:
  /// **'Choose a Sadho backup'**
  String get chooseBackupDialogTitle;

  /// Title of the delete-account confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// Body of the delete-account confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This deletes your account and everything saved on this phone: your profile, marks, plans, mantras, voice training and settings. It cannot be undone.'**
  String get deleteAccountWarning;

  /// Confirms a destructive action
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesAction;

  /// Declines a destructive action
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noAction;

  /// Heading of the account-deletion section
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get dangerZoneTitle;

  /// Explains account deletion, above the Delete account button
  ///
  /// In en, this message translates to:
  /// **'Deleting your account erases your profile and everything saved on this phone. Export a backup first if you might want it back.'**
  String get deleteAccountExplain;

  /// Button that starts account deletion
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountButton;

  /// Shown after saving name/email
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// Section heading: name and email
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get yourDetailsTitle;

  /// Label of the name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// Label of the email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Section heading: the daily sadhana reminder
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get dailyReminderTitle;

  /// The daily reminder switch's title, and the time picker's heading
  ///
  /// In en, this message translates to:
  /// **'Daily sadhana reminder'**
  String get dailySadhanaReminder;

  /// Shown when the daily reminder is off
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get reminderOff;

  /// Shown when the daily reminder is on
  ///
  /// In en, this message translates to:
  /// **'Every day at {time}'**
  String everyDayAt(String time);

  /// Shown when notification permission was refused for the daily reminder
  ///
  /// In en, this message translates to:
  /// **'Allow notifications in Settings so the reminder can ring.'**
  String get allowNotificationsForReminder;

  /// Row label: the daily reminder's time
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// Section heading: appearance
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// Theme mode choice
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// Theme mode choice
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// Theme mode choice
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemMode;

  /// Heading above the palette picker
  ///
  /// In en, this message translates to:
  /// **'Colours'**
  String get coloursTitle;

  /// Screen-reader label for a palette choice
  ///
  /// In en, this message translates to:
  /// **'{name} colours'**
  String paletteSemantic(String name);

  /// A colour palette's name
  ///
  /// In en, this message translates to:
  /// **'Marigold'**
  String get paletteMarigoldName;

  /// A colour palette's description
  ///
  /// In en, this message translates to:
  /// **'Warm saffron and deep indigo'**
  String get paletteMarigoldBlurb;

  /// A colour palette's name
  ///
  /// In en, this message translates to:
  /// **'Sandalwood'**
  String get paletteSandalwoodName;

  /// A colour palette's description
  ///
  /// In en, this message translates to:
  /// **'Soft sandal brown and clay'**
  String get paletteSandalwoodBlurb;

  /// A colour palette's name
  ///
  /// In en, this message translates to:
  /// **'Tulsi green'**
  String get paletteTulsiName;

  /// A colour palette's description
  ///
  /// In en, this message translates to:
  /// **'Calm holy-basil green'**
  String get paletteTulsiBlurb;

  /// A colour palette's name
  ///
  /// In en, this message translates to:
  /// **'Twilight indigo'**
  String get paletteTwilightName;

  /// A colour palette's description
  ///
  /// In en, this message translates to:
  /// **'Dusk indigo with a lamp-glow gold'**
  String get paletteTwilightBlurb;

  /// A colour palette's name
  ///
  /// In en, this message translates to:
  /// **'Lotus rose'**
  String get paletteLotusName;

  /// A colour palette's description
  ///
  /// In en, this message translates to:
  /// **'Gentle lotus pink and leaf green'**
  String get paletteLotusBlurb;

  /// Notification title for the daily reminder
  ///
  /// In en, this message translates to:
  /// **'🪔 Time for your sadhana'**
  String get sadhanaTimeNotifTitle;

  /// Notification body for the daily reminder
  ///
  /// In en, this message translates to:
  /// **'Take a few quiet minutes for your paath or mantra 🙏'**
  String get sadhanaTimeNotifBody;

  /// Placeholder body for a tab that is not built yet
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// Snack bar action: opens voice training for a mantra
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get trainAction;

  /// First-launch screen heading
  ///
  /// In en, this message translates to:
  /// **'Welcome to Sadho'**
  String get onboardingTitle;

  /// First-launch screen explanation
  ///
  /// In en, this message translates to:
  /// **'Choose your language and tradition to begin. You can change either later in Profile.'**
  String get onboardingSubtitle;

  /// Heading above the tradition choices on first launch
  ///
  /// In en, this message translates to:
  /// **'Tradition'**
  String get traditionHeading;

  /// Button that finishes the first-launch screen
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// Button that silences the completion ringtone and vibration
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopAlert;

  /// No description provided for @repeatLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatLabel;

  /// No description provided for @repeatOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get repeatOnce;

  /// No description provided for @soundRepeatTimes.
  ///
  /// In en, this message translates to:
  /// **'{times} times'**
  String soundRepeatTimes(int times);

  /// No description provided for @repeatUntilStopped.
  ///
  /// In en, this message translates to:
  /// **'Until stopped'**
  String get repeatUntilStopped;

  /// No description provided for @vibrationRepeatUntilStopped.
  ///
  /// In en, this message translates to:
  /// **'Every {seconds} s until stopped'**
  String vibrationRepeatUntilStopped(int seconds);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'bn',
    'en',
    'gu',
    'hi',
    'kn',
    'mr',
    'pa',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'mr':
      return AppLocalizationsMr();
    case 'pa':
      return AppLocalizationsPa();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
