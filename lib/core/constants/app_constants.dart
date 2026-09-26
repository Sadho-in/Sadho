/// Brand + app-wide constants.
class AppConstants {
  AppConstants._();

  static const appName = 'Sadho';
  static const website = 'sadho.in';

  /// The legal pages on the website (Profile > About, and the first-launch
  /// notice).
  static final privacyUrl = Uri.parse('https://sadho.in/privacy');
  static final termsUrl = Uri.parse('https://sadho.in/terms');
  static final contactUrl = Uri.parse('https://sadho.in/contact');
  static final deleteDataUrl = Uri.parse('https://sadho.in/delete-data');

  /// Keep in step with `version:` in pubspec.yaml (a test checks they match).
  static const version = '1.0.0';
}
