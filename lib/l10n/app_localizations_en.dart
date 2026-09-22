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
}
