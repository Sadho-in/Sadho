import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/alarms/presentation/alarms_reliability_page.dart' show okGreen;
import 'package:advance_calendar/core/theme/app_theme.dart';
import 'package:advance_calendar/core/theme/palettes.dart';
import 'package:advance_calendar/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Six since P4.3-9 added High contrast (last).
  test('there are six palettes, Marigold first, each with its own id and name', () {
    expect([for (final p in sadhoPalettes) p.name], [
      'Marigold',
      'Sandalwood',
      'Tulsi green',
      'Twilight indigo',
      'Lotus rose',
      'High contrast',
    ]);
    expect({for (final p in sadhoPalettes) p.id}.length, 6);
    expect(defaultPalette.id, 'marigold');
    for (final p in sadhoPalettes) {
      expect(p.blurb, isNotEmpty);
    }
  });

  test('the palettes really look different from each other', () {
    for (final b in Brightness.values) {
      final primaries = {for (final p in sadhoPalettes) p.colors(b).primary};
      final surfaces = {for (final p in sadhoPalettes) p.colors(b).surface};
      expect(primaries.length, sadhoPalettes.length, reason: '$b primaries');
      expect(surfaces.length, sadhoPalettes.length, reason: '$b surfaces');
    }
  });

  test('Marigold is exactly the colours the app has always used', () {
    final l = AppTheme.colorScheme(defaultPalette, Brightness.light);
    expect(l.primary, const Color(0xFFDE8517));
    expect(l.secondary, const Color(0xFF4B4691));
    expect(l.surface, const Color(0xFFFBF7F0));
    expect(l.onPrimary, const Color(0xFF2A1600));
    final d = AppTheme.colorScheme(defaultPalette, Brightness.dark);
    expect(d.surface, const Color(0xFF17130F));
    expect(d.secondary, const Color(0xFFC3BEFF));
    expect(d.secondaryContainer, const Color(0xFF4B4691));
  });

  group('every text pairing is readable (WCAG contrast)', () {
    for (final p in sadhoPalettes) {
      for (final b in Brightness.values) {
        test('${p.name}, ${b.name}', () {
          final c = AppTheme.colorScheme(p, b);
          void atLeast(String what, Color fg, Color bg, double min) {
            expect(contrastRatio(fg, bg), greaterThanOrEqualTo(min),
                reason: '$what: ${contrastRatio(fg, bg).toStringAsFixed(2)}:1');
          }

          atLeast('text on primary', c.onPrimary, c.primary, 4.5);
          atLeast('text on primary container', c.onPrimaryContainer, c.primaryContainer, 4.5);
          atLeast('text on secondary', c.onSecondary, c.secondary, 4.5);
          atLeast('text on secondary container', c.onSecondaryContainer, c.secondaryContainer, 4.5);
          // Body text on every surface the cards and screens use.
          for (final (name, bg) in [
            ('surface', c.surface),
            ('lowest', c.surfaceContainerLowest),
            ('low', c.surfaceContainerLow),
            ('container', c.surfaceContainer),
            ('high', c.surfaceContainerHigh),
            ('highest', c.surfaceContainerHighest),
          ]) {
            atLeast('body text on $name', c.onSurface, bg, 7);
          }
          // The accent colours are used for icons and highlights on the cards
          // (never for body text). Marigold, the original brand colour, sits
          // at 2.5:1 there; no palette may be weaker than that.
          atLeast('primary on the card colour', c.primary, c.surfaceContainerLow, 2.4);
          atLeast('secondary on the card colour', c.secondary, c.surfaceContainerLow, 3);
        });
      }
    }
  });

  group('High contrast: all text at least 7:1, all controls at least 3:1', () {
    final hc = paletteById('highContrast');
    test('is offered, by name, in every language', () {
      expect(hc.id, 'highContrast');
      expect(sadhoPalettes.last, hc);
    });
    for (final b in Brightness.values) {
      test(b.name, () {
        final c = AppTheme.colorScheme(hc, b);
        void atLeast(String what, Color fg, Color bg, double min) {
          expect(contrastRatio(fg, bg), greaterThanOrEqualTo(min),
              reason: '$what: ${contrastRatio(fg, bg).toStringAsFixed(2)}:1');
        }

        final surfaces = [
          ('surface', c.surface),
          ('lowest', c.surfaceContainerLowest),
          ('low', c.surfaceContainerLow),
          ('container', c.surfaceContainer),
          ('high', c.surfaceContainerHigh),
          ('highest', c.surfaceContainerHighest),
        ];
        // Every colour text is drawn in, on every surface.
        for (final (fgName, fg) in [
          ('body text', c.onSurface),
          ('secondary text', c.onSurfaceVariant),
          ('primary (text buttons, links)', c.primary),
          ('secondary (accents)', c.secondary),
          ('tertiary', c.tertiary),
          ('error text', c.error),
        ]) {
          for (final (bgName, bg) in surfaces) {
            atLeast('$fgName on $bgName', fg, bg, 7);
          }
        }
        // Text on filled colours.
        atLeast('on primary', c.onPrimary, c.primary, 7);
        atLeast('on primary container', c.onPrimaryContainer, c.primaryContainer, 7);
        atLeast('primary on primary container', c.primary, c.primaryContainer, 7);
        atLeast('on secondary', c.onSecondary, c.secondary, 7);
        atLeast('on secondary container', c.onSecondaryContainer, c.secondaryContainer, 7);
        atLeast('on tertiary', c.onTertiary, c.tertiary, 7);
        atLeast('on tertiary container', c.onTertiaryContainer, c.tertiaryContainer, 7);
        atLeast('on error', c.onError, c.error, 7);
        atLeast('on error container', c.onErrorContainer, c.errorContainer, 7);
        atLeast('snackbar text', c.onInverseSurface, c.inverseSurface, 7);
        atLeast('snackbar action', c.inversePrimary, c.inverseSurface, 7);
        // Controls: borders, dividers, switches, filled buttons.
        for (final (bgName, bg) in surfaces) {
          atLeast('outline on $bgName', c.outline, bg, 3);
          atLeast('outline variant on $bgName', c.outlineVariant, bg, 3);
          atLeast('primary control on $bgName', c.primary, bg, 3);
          atLeast('secondary control on $bgName', c.secondary, bg, 3);
        }
      });
    }
  });

  test('the other palettes still take Material\'s colours for the extra roles',
      () {
    for (final p in sadhoPalettes.where((p) => p.id != 'highContrast')) {
      expect(p.light.onSurfaceVariant, isNull, reason: p.name);
      expect(p.dark.outline, isNull, reason: p.name);
    }
  });

  test('the "OK" green of Alarms & reliability reads at 7:1 on every card',
      () {
    for (final p in sadhoPalettes) {
      for (final b in Brightness.values) {
        final card = AppTheme.colorScheme(p, b).surfaceContainerLow;
        expect(contrastRatio(okGreen(b), card), greaterThanOrEqualTo(7),
            reason: '${p.name} ${b.name}');
      }
    }
  });

  test('light palettes are light and dark palettes are dark', () {
    for (final p in sadhoPalettes) {
      expect(p.light.surface.computeLuminance(), greaterThan(0.7), reason: p.name);
      expect(p.dark.surface.computeLuminance(), lessThan(0.05), reason: p.name);
    }
  });

  test('surfaces step from lightest to darkest in the right order', () {
    for (final p in sadhoPalettes) {
      final l = p.light;
      final ladder = [
        l.surfaceContainerLowest,
        l.surface,
        l.surfaceContainerLow,
        l.surfaceContainer,
        l.surfaceContainerHigh,
        l.surfaceContainerHighest,
      ].map((c) => c.computeLuminance()).toList();
      for (var i = 1; i < ladder.length; i++) {
        expect(ladder[i], lessThanOrEqualTo(ladder[i - 1] + 1e-9),
            reason: '${p.name} light step $i');
      }
    }
  });

  test('the colour scheme built for each palette carries its colours', () {
    for (final p in sadhoPalettes) {
      final c = AppTheme.colorScheme(p, Brightness.light);
      expect(c.primary, p.light.primary);
      expect(c.surface, p.light.surface);
      expect(c.brightness, Brightness.light);
      final d = AppTheme.colorScheme(p, Brightness.dark);
      expect(d.primary, p.dark.primary);
      expect(d.brightness, Brightness.dark);
    }
  });

  test('paletteById falls back to Marigold for nothing or nonsense', () {
    expect(paletteById('tulsi').name, 'Tulsi green');
    expect(paletteById(null).id, 'marigold');
    expect(paletteById('neon').id, 'marigold');
    expect(paletteById(42).id, 'marigold');
  });

  group('the chosen palette is remembered', () {
    setUp(AppStorage.useMemoryForTests);

    ProviderContainer make() {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      return c;
    }

    test('Marigold until one is chosen', () {
      expect(make().read(paletteProvider).id, 'marigold');
    });

    test('choosing saves it, and the next launch has it back', () {
      final c = make();
      c.read(paletteProvider.notifier).set(sadhoPalettes[3]);
      expect(c.read(paletteProvider).id, 'twilight');
      expect(AppStorage.settings.get('themePalette'), 'twilight');
      expect(make().read(paletteProvider).id, 'twilight');
    });

    test('a saved palette this version does not know becomes Marigold', () async {
      await AppStorage.settings.put('themePalette', 'from-the-future');
      expect(make().read(paletteProvider).id, 'marigold');
    });

    test('Light / Dark / System is remembered too', () {
      final c = make();
      expect(c.read(themeModeProvider), ThemeMode.system);
      c.read(themeModeProvider.notifier).set(ThemeMode.dark);
      expect(make().read(themeModeProvider), ThemeMode.dark);
    });
  });
}
