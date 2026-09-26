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
import 'package:integration_test/integration_test.dart';

/// Call once per test file, before `main()`'s tests run.
void setUpIntegrationTest() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
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

/// `tester.tap`, retried on the rare `StateError: Bad state: No element`
/// thrown from inside WidgetController's own ancestor-View lookup
/// (`_maybeViewOf`) — a transient framework race, not anything about the
/// target widget: seen only in a long run of rapid repeated taps (e.g.
/// tapping "+" dozens of times) on a real device, at an unpredictable
/// iteration each time, never at the same one twice. A short pump before
/// retrying lets whatever was mid-rebuild finish.
Future<void> safeTap(WidgetTester tester, Finder finder, {int retries = 3}) async {
  for (var attempt = 0; ; attempt++) {
    try {
      await tester.tap(finder);
      return;
    } on StateError {
      if (attempt >= retries) rethrow;
      await tester.pump(const Duration(milliseconds: 50));
    }
  }
}

/// Taps the named bottom-nav tab (Home / Sadhana / Calendar / Clock).
Future<void> gotoTab(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(
      of: find.byType(NavigationBar), matching: find.text(label)));
  await tester.pumpAndSettle();
}

/// Scrolls [scrollable] (the first Scrollable by default) until [finder] is
/// found, then settles. A real (normal-height) screen is genuinely lazy —
/// most Sadho screens are a ListView — so a widget below the fold does not
/// exist in the tree at all until scrolled near it; use this immediately
/// before asserting on, or interacting with, anything that might be low on
/// the page.
///
/// Written as a manual step-and-check loop, not `scrollUntilVisible`: that
/// helper can flicker on a real device (it finds the target once, then loses
/// it again by the next frame, because the drag's own fling/ballistic motion
/// keeps the list moving after the "found" check) and throws "No element"
/// even though the widget is genuinely reachable.
Future<void> scrollTo(WidgetTester tester, Finder finder,
    {Finder? scrollable, int maxSteps = 40}) async {
  final view = scrollable ?? find.byType(Scrollable).first;
  // A `.first`/`.last`-suffixed finder throws out of evaluate() (rather than
  // just returning empty) when nothing matches yet at all — guard against
  // that so scrollTo works the same whether or not the caller's finder is
  // narrowed that way.
  bool nothingYet() {
    try {
      return finder.evaluate().isEmpty;
    } on StateError {
      return true;
    }
  }

  for (var i = 0; i < maxSteps && nothingYet(); i++) {
    await tester.drag(view, const Offset(0, -150), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 50));
  }
  // Only ONE real settle, now that the target is confirmed found — this is
  // what was flickering it away when called on every step of the search
  // loop above instead.
  await tester.pumpAndSettle();
  expect(finder, findsWidgets,
      reason: 'scrollTo: target never appeared within $maxSteps scroll steps');

  // "Found" only means the element is mounted (the ListView's ~250px
  // cacheExtent mounts it before it's actually on screen), and even once
  // painted, a widget that just scrolled into view sits right at the bottom
  // edge of the viewport — on a real device that low band reliably eats taps
  // (they silently land on whatever's fixed there, e.g. the NavigationBar,
  // instead of the intended widget; confirmed by the hit-test warning's own
  // dump naming a NavigationBar destination as the actual hit). Keep
  // scrolling in small steps until the target's center is comfortably above
  // that band (the screen's upper 60%) before treating it as interactable.
  //
  // Deliberately NOT `tester.ensureVisible`: it drives its own animated
  // Scrollable.position.ensureVisible, which — pumped to settle here while a
  // dialog/route transition from the *previous* interaction is still mid-way
  // — reliably produced framework-internal crashes on this screen (disposed
  // TextEditingController, a `_dependents.isEmpty` InheritedElement
  // assertion). Plain drags have none of that machinery.
  final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
  final safeBelow = screenHeight * 0.6;
  for (var i = 0; i < 10 && finder.evaluate().isNotEmpty; i++) {
    if (tester.getCenter(finder).dy <= safeBelow) break;
    await tester.drag(view, const Offset(0, -100), warnIfMissed: false);
    await tester.pumpAndSettle();
  }
}

/// One large drag back to the top of the first Scrollable, rather than
/// iterative scroll-and-check (which can flicker a widget in and out of the
/// lazily-built range right as it's inspected).
Future<void> scrollToTop(WidgetTester tester, {Finder? scrollable}) async {
  await tester.drag(scrollable ?? find.byType(Scrollable).first, const Offset(0, 3000));
  await tester.pumpAndSettle();
}
