import 'package:advance_calendar/features/onboarding/application/onboarding_provider.dart';
import 'package:advance_calendar/features/onboarding/presentation/onboarding_screen.dart';
import 'package:advance_calendar/features/shell/language_provider.dart';
import 'package:advance_calendar/features/shell/presentation/language_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../profile/profile_support.dart';

/// P4.2: on a small, real phone screen — not the artificially tall virtual
/// viewport other widget tests use to fit a whole tab without scrolling —
/// with a large system font on top, all nine languages must still be
/// reachable by scrolling, on both language pickers: first-launch onboarding
/// and the Profile → Language sheet.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false); // no network in tests

  void useSmallScreenWithLargeFont(WidgetTester tester) {
    phoneScreen(tester, width: 360, height: 640);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  testWidgets(
      'onboarding: all 9 languages are reachable by scrolling and tappable',
      (tester) async {
    final rig = profileRig(extra: [
      devicePlatformLocaleProvider.overrideWithValue(const Locale('en')),
    ]);
    useSmallScreenWithLargeFont(tester);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: rig.container,
      child: const MaterialApp(home: OnboardingScreen()),
    ));
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    for (final lang in appLanguages) {
      final finder = find.byKey(ValueKey('onboarding-lang-${lang.code}'));
      await tester.scrollUntilVisible(finder, 100, scrollable: scrollable);
      await tester.pumpAndSettle();
      expect(finder, findsOneWidget, reason: lang.code);
    }

    // The last one scrolled to (Kannada) is not just present — it actually
    // responds to a tap, the same as any of the others.
    await tester.tap(find.byKey(const ValueKey('onboarding-lang-kn')));
    await tester.pump();
    expect(rig.container.read(languageProvider), 'kn');
  });

  testWidgets(
      'Profile language sheet: all 9 languages are reachable by scrolling '
      'and tappable', (tester) async {
    final rig = profileRig();
    useSmallScreenWithLargeFont(tester);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: rig.container,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showLanguageSheet(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    for (final lang in appLanguages) {
      final finder = find.byKey(ValueKey('language-sheet-${lang.code}'));
      await tester.scrollUntilVisible(finder, 100, scrollable: scrollable);
      await tester.pumpAndSettle();
      expect(finder, findsOneWidget, reason: lang.code);
    }

    // Kannada (the last one scrolled to) actually responds to a tap.
    await tester.tap(find.byKey(const ValueKey('language-sheet-kn')));
    await tester.pumpAndSettle();
    expect(rig.container.read(languageProvider), 'kn');
  });
}
