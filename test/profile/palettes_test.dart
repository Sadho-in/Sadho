import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/core/theme/app_theme.dart';
import 'package:advance_calendar/core/theme/palettes.dart';
import 'package:advance_calendar/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('there are five palettes, Marigold first, each with its own id and name', () {
    expect([for (final p in sadhoPalettes) p.name],
        ['Marigold', 'Sandalwood', 'Tulsi green', 'Twilight indigo', 'Lotus rose']);
    expect({for (final p in sadhoPalettes) p.id}.length, 5);
    expect(defaultPalette.id, 'marigold');
    for (final p in sadhoPalettes) {
      expect(p.blurb, isNotEmpty);
    }
  });

  test('the palettes really look different from each other', () {
    for (final b in Brightness.values) {
      final primaries = {for (final p in sadhoPalettes) p.colors(b).primary};
      final surfaces = {for (final p in sadhoPalettes) p.colors(b).surface};
      expect(primaries.length, 5, reason: '$b primaries');
      expect(surfaces.length, 5, reason: '$b surfaces');
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
