import 'package:timezone/data/latest_all.dart' as tzdata;

bool _ready = false;

/// Loads the IANA time-zone database once (world clock, reminders). Safe to
/// call as often as you like.
void ensureTimeZonesLoaded() {
  if (_ready) return;
  tzdata.initializeTimeZones();
  _ready = true;
}
