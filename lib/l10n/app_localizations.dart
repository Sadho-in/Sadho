import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

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
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
