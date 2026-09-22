import 'package:advance_calendar/features/home/presentation/home_screen.dart';
import 'package:advance_calendar/features/onboarding/presentation/onboarding_screen.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  setUpIntegrationTest();

  testWidgets('the real app launches, shows onboarding, and Continue reveals Home',
      (tester) async {
    await pumpFreshApp(tester);
    expect(find.byType(OnboardingScreen), findsOneWidget);

    await tester.scrollUntilVisible(byKey('onboarding-continue'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(byKey('onboarding-continue'));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
