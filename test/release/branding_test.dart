import 'dart:io';

import 'package:advance_calendar/app.dart';
import 'package:advance_calendar/core/widgets/sadho_logo.dart';
import 'package:advance_calendar/features/calendar/services/local_notifications_scheduler.dart';
import 'package:advance_calendar/features/onboarding/presentation/onboarding_screen.dart';
import 'package:advance_calendar/features/profile/presentation/widgets/about_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import '../profile/profile_support.dart';

/// P6-1: the app icon, the notification icon and the logo in the app, all
/// driven from the four files in assets/branding/.
void main() {

  String read(String path) => File(path).readAsStringSync();
  img.Image png(String path) => img.decodePng(File(path).readAsBytesSync())!;
  const res = 'android/app/src/main/res';

  group('the four logo files', () {
    test('are there, square, with transparency where it is needed', () {
      final icon = png('assets/branding/icon-1024.png');
      expect(icon.width, 1024);
      expect(icon.height, 1024);
      for (final f in ['icon-foreground', 'icon-monochrome', 'notification-icon']) {
        final i = png('assets/branding/$f.png');
        expect(i.width, i.height, reason: f);
        expect(i.hasAlpha, isTrue, reason: '$f needs a transparent background');
        expect(i.getPixel(0, 0).a, 0, reason: '$f corner is transparent');
      }
    });

    test('the adaptive foreground stays inside the safe zone (middle 66%)', () {
      final i = png('assets/branding/icon-foreground.png');
      final lo = i.width * 0.17, hi = i.width * 0.83;
      for (var y = 0; y < i.height; y += 8) {
        for (var x = 0; x < i.width; x += 8) {
          if (i.getPixel(x, y).a > 0) {
            expect(x > lo && x < hi && y > lo && y < hi, isTrue,
                reason: 'opaque pixel at $x,$y');
          }
        }
      }
    });
  });

  group('launcher icon (flutter_launcher_icons)', () {
    test('is configured from assets/branding/', () {
      final pubspec = read('pubspec.yaml');
      expect(pubspec, contains('flutter_launcher_icons:'));
      expect(pubspec, contains('image_path: "assets/branding/icon-1024.png"'));
      expect(pubspec, contains('adaptive_icon_background: "#4B4691"'));
      expect(pubspec,
          contains('adaptive_icon_foreground: "assets/branding/icon-foreground.png"'));
      expect(pubspec,
          contains('adaptive_icon_monochrome: "assets/branding/icon-monochrome.png"'));
      expect(pubspec, contains('remove_alpha_ios: true'));
    });

    test('Android: legacy, adaptive and Android 13 themed icon', () {
      for (final d in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
        expect(File('$res/mipmap-$d/ic_launcher.png').existsSync(), isTrue);
      }
      final adaptive = read('$res/mipmap-anydpi-v26/ic_launcher.xml');
      expect(adaptive, contains('@color/ic_launcher_background'));
      expect(adaptive, contains('@drawable/ic_launcher_foreground'));
      expect(adaptive, contains('<monochrome>'));
      expect(read('$res/values/colors.xml'), contains('#4B4691'));
    });

    test('iOS: the 1024 icon has no alpha channel (App Store rule)', () {
      final i = png('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png');
      expect(i.width, 1024);
      expect(i.hasAlpha, isFalse);
    });
  });

  group('notification icon', () {
    const sizes = {'mdpi': 24, 'hdpi': 36, 'xhdpi': 48, 'xxhdpi': 72, 'xxxhdpi': 96};

    test('ic_stat_sadho at every density: white, shaped by its alpha', () {
      for (final e in sizes.entries) {
        final i = png('$res/drawable-${e.key}/ic_stat_sadho.png');
        expect(i.width, e.value);
        expect(i.hasAlpha, isTrue);
        var opaque = 0;
        for (final p in i) {
          if (p.a > 0) {
            opaque++;
            expect([p.r, p.g, p.b], [255, 255, 255]);
          }
        }
        expect(opaque, greaterThan(0));
        expect(i.getPixel(0, 0).a, 0);
      }
    });

    test('every notification uses it, with the saffron accent', () {
      expect(notificationIcon, 'ic_stat_sadho');
      expect(notificationAccent, const Color(0xFFFF9933));
      final dart = read('lib/features/calendar/services/local_notifications_scheduler.dart');
      expect(dart, contains('AndroidInitializationSettings(notificationIcon)'));
      final details = 'AndroidNotificationDetails('.allMatches(dart).length;
      expect('icon: notificationIcon,'.allMatches(dart).length, details);
      expect('color: notificationAccent,'.allMatches(dart).length, details);
      // Nothing else in lib/ builds a notification of its own.
      for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart') || f.path.contains('local_notifications_scheduler')) {
          continue;
        }
        expect(f.readAsStringSync(), isNot(contains('AndroidNotificationDetails(')),
            reason: f.path);
      }
      // The Mala service (and its target ring) in Kotlin.
      final kotlin = read('android/app/src/main/kotlin/in/sadho/app/MalaCounterService.kt');
      final builders = 'NotificationCompat.Builder('.allMatches(kotlin).length;
      expect(builders, greaterThan(0));
      expect('setSmallIcon(R.drawable.ic_stat_sadho)'.allMatches(kotlin).length, builders);
      expect('setColor(NOTIFICATION_ACCENT)'.allMatches(kotlin).length, builders);
      expect(kotlin, contains('0xFFFF9933'));
      expect(kotlin, isNot(contains('R.mipmap.ic_launcher')));
    });

    test('resource shrinking keeps it (it is named only from Dart)', () {
      expect(read('$res/raw/keep.xml'), contains('@drawable/ic_stat_sadho'));
    });
  });

  group('the logo in the app', () {
    testWidgets('on the onboarding screen, above the title', (tester) async {
      final rig = profileRig();
      phoneScreen(tester, height: 2400);
      await tester.pumpWidget(UncontrolledProviderScope(
          container: rig.container, child: const SadhoApp()));
      await tester.pump();
      expect(find.byType(OnboardingScreen), findsOneWidget);
      final logo = find.byType(SadhoLogo);
      expect(logo, findsOneWidget);
      final title = find.text('Welcome to Sadho');
      expect(title, findsOneWidget);
      expect(tester.getTopLeft(logo).dy, lessThan(tester.getTopLeft(title).dy));
      expect(find.bySemanticsLabel('Sadho'), findsWidgets);
    });

    testWidgets('in Profile > About', (tester) async {
      await tester.pumpWidget(const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: AboutCard()))));
      expect(find.byType(SadhoLogo), findsOneWidget);
      final image = tester.widget<Image>(find.byKey(const ValueKey('sadho-logo')));
      expect((image.image as AssetImage).assetName, SadhoLogo.asset);
    });

    test('the logo is a bundled asset', () {
      expect(read('pubspec.yaml'), contains('- assets/branding/icon-1024.png'));
    });
  });
}
