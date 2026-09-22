// Shared setup for every integration test file: these run on a real device
// (or emulator), driving the actual compiled app — not a fake Hive box or a
// stand-in scheduler, the real ones. Each file wipes the phone's storage
// before every test, so tests are independent of whatever ran before them
// even though the "phone" is real and persists between tests otherwise.
import 'package:advance_calendar/app.dart';
import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';

/// Call once per test file, before `main()`'s tests run.
void setUpIntegrationTest() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false; // no network on a test run
  setUpAll(() async {
    await AppStorage.init();
  });
  setUp(() async {
    await AppStorage.clearAll();
  });
}

/// Pumps the real app from a clean phone (onboarding will show) and settles.
Future<void> pumpFreshApp(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: SadhoApp()));
  await tester.pumpAndSettle();
}

/// Pumps the real app already past onboarding (English, Hindu), landing
/// straight on Home — for tests about something other than onboarding
/// itself. Mirrors exactly what completing onboarding does.
Future<void> pumpOnboardedApp(WidgetTester tester) async {
  AppStorage.settings.put('language', 'en');
  AppStorage.settings.put('home.tradition', 'hindu');
  AppStorage.settings.put('onboarding.done', true);
  await tester.pumpWidget(const ProviderScope(child: SadhoApp()));
  await tester.pumpAndSettle();
}

/// The Android/iOS system back button, delivered the way the platform
/// actually delivers it (`handlePopRoute`) — not a direct `Navigator.pop()`,
/// so this exercises real back-button handling (`PopScope`, nested
/// navigators) exactly like `test/shell/back_button_test.dart` does, and
/// returns any exception the framework reported while handling it (null if
/// none).
Future<Object?> pressSystemBack(WidgetTester tester) async {
  Object? caught;
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    caught ??= details.exception;
    previous?.call(details);
  };
  try {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  } finally {
    FlutterError.onError = previous;
  }
  return caught;
}

Finder byKey(String key) => find.byKey(ValueKey(key));
