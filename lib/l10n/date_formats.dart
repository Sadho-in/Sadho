import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Loads intl's month and weekday names and date patterns for every app
/// language. The data is bundled with the app, so this takes effect at once;
/// calling it again does nothing.
void initAppDateFormatting() {
  if (_ready) return;
  // Synchronous in effect: the local data is installed before it returns.
  initializeDateFormatting();
  _ready = true;
}

bool _ready = false;

/// Dates and times in the app's language (month and weekday names, word
/// order, AM/PM, and that language's usual digits). Every date or time the
/// app shows goes through this or [MaterialLocalizations] (which follows the
/// same locale), never a bare [DateFormat].
class AppDates {
  AppDates(Locale locale) : tag = locale.toString() {
    initAppDateFormatting();
  }

  /// The locale of the screen [context] is on (the app's language).
  AppDates.of(BuildContext context) : this(Localizations.localeOf(context));

  /// The intl locale, e.g. "pa".
  final String tag;

  /// A clock time: "5:05 PM", or "17:05" with [use24].
  String time(DateTime t, {bool use24 = false}) =>
      (use24 ? DateFormat('HH:mm', tag) : DateFormat.jm(tag)).format(t);

  /// Hours and minutes without AM/PM: "5:05", or "17:05" with [use24].
  String hoursMinutes(DateTime t, {bool use24 = false}) =>
      DateFormat(use24 ? 'HH:mm' : 'h:mm', tag).format(t);

  /// The seconds, two digits: "09".
  String seconds(DateTime t) => DateFormat('ss', tag).format(t);

  /// AM or PM in this language.
  String period(DateTime t) => DateFormat('a', tag).format(t);

  /// The whole date: "Monday, 21 September 2026".
  String fullDate(DateTime d) => DateFormat('EEEE, d MMMM y', tag).format(d);

  /// A short day and date: "Mon, Sep 21".
  String shortDayDate(DateTime d) => DateFormat.MMMEd(tag).format(d);

  /// A date with the year: "Sep 21, 2026".
  String mediumDate(DateTime d) => DateFormat.yMMMd(tag).format(d);

  /// A date and a clock time: "Sep 21, 2026 5:05 PM".
  String dateTime(DateTime d) => DateFormat.yMMMd(tag).add_jm().format(d);

  /// The month and year: "September 2026".
  String monthYear(DateTime d) => DateFormat.yMMMM(tag).format(d);
}
