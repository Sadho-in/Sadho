import 'package:advance_calendar/features/home/presentation/home_screen.dart';
import 'package:advance_calendar/features/onboarding/presentation/onboarding_screen.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// §1 of test/QA_COVERAGE.md: the first-launch language + tradition screen.
///
/// Unlike the widget-test coverage in test/onboarding/onboarding_screen_test.dart
/// (which pumps a very tall virtual viewport so the whole ListView fits), a
/// real phone screen is normal-height, so most of this screen is offscreen
/// and its slivers are genuinely lazy: an item scrolled far out of view is
/// unmounted again, not just unpainted. Every check below scrolls to the
/// item right before asserting on it, rather than scrolling once and
/// checking several keys afterwards.
void main() {
  setUpIntegrationTest();

  Future<void> scrollTo(WidgetTester tester, Finder finder) =>
      tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first);

  /// One large drag back to the top, rather than iterative
  /// scroll-and-check-for-a-widget (scrollUntilVisible can flicker: a widget
  /// found right at the edge of the lazy-built range can be gone again by
  /// the time the next frame is inspected).
  Future<void> scrollToTop(WidgetTester tester) async {
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the title, all nine languages and all three traditions',
      (tester) async {
    await pumpFreshApp(tester);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Welcome to Sadho'), findsOneWidget);

    for (final code in ['en', 'hi', 'pa', 'mr', 'bn', 'gu', 'ta', 'te', 'kn']) {
      final finder = byKey('onboarding-lang-$code');
      await scrollTo(tester, finder);
      expect(finder, findsOneWidget, reason: code);
    }
    for (final t in ['hindu', 'sikh', 'place']) {
      final finder = byKey('onboarding-tradition-$t');
      await scrollTo(tester, finder);
      expect(finder, findsOneWidget, reason: t);
    }
    await scrollTo(tester, byKey('onboarding-continue'));
    expect(byKey('onboarding-continue'), findsOneWidget);
  });

  testWidgets('picking a language previews it live, right there on the screen',
      (tester) async {
    await pumpFreshApp(tester);

    await scrollTo(tester, byKey('onboarding-lang-pa'));
    await tester.tap(byKey('onboarding-lang-pa'));
    await tester.pumpAndSettle();
    // The screen's own title re-renders in the chosen language right away —
    // scroll back up to it (tapping the radio scrolled it out of the lazy
    // list's built range).
    await scrollToTop(tester);
    expect(find.text('Sadho ਵਿੱਚ ਤੁਹਾਡਾ ਸਵਾਗਤ ਹੈ'), findsOneWidget);
    expect(find.text('Welcome to Sadho'), findsNothing);

    await scrollTo(tester, byKey('onboarding-lang-en'));
    await tester.tap(byKey('onboarding-lang-en'));
    await tester.pumpAndSettle();
    await scrollToTop(tester);
    expect(find.text('Welcome to Sadho'), findsOneWidget);
  });

  testWidgets(
      'picking a tradition and Continue lands on Home, and onboarding never '
      'shows again — including after the app is fully restarted',
      (tester) async {
    await pumpFreshApp(tester);
    await scrollTo(tester, byKey('onboarding-tradition-sikh'));
    await tester.tap(byKey('onboarding-tradition-sikh'));
    await tester.pumpAndSettle();
    await scrollTo(tester, byKey('onboarding-continue'));
    await tester.tap(byKey('onboarding-continue'));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);

    // A full restart: a brand new widget tree, same (real) phone storage.
    await pumpFreshApp(tester);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(AppShell), findsOneWidget);
  });
}
