import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/palettes.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../l10n/l10n.dart';
import '../../../../l10n/labels.dart';
import '../../../sadhana/presentation/widgets/section_card.dart';

/// Colour palette (five soothing choices) and Light / Dark / System. Both are
/// saved and applied across the whole app at once.
class ThemeCard extends ConsumerWidget {
  const ThemeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final mode = ref.watch(themeModeProvider);
    final selected = ref.watch(paletteProvider);

    return SectionCard(
      title: l.themeTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<ThemeMode>(
            key: const ValueKey('theme-mode'),
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode_outlined),
                  label: Text(l.lightMode)),
              ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode_outlined),
                  label: Text(l.darkMode)),
              ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.brightness_auto_outlined),
                  label: Text(l.systemMode)),
            ],
            selected: {mode},
            onSelectionChanged: (v) =>
                ref.read(themeModeProvider.notifier).set(v.first),
          ),
          const SizedBox(height: 16),
          Text(l.coloursTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final p in sadhoPalettes)
                _PaletteTile(
                  palette: p,
                  selected: p.id == selected.id,
                  onTap: () => ref.read(paletteProvider.notifier).set(p),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            selected.localizedBlurb(l),
            key: const ValueKey('palette-blurb'),
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _PaletteTile extends StatelessWidget {
  const _PaletteTile({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final SadhoPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;
    final c = palette.colors(theme.brightness);
    return Semantics(
      button: true,
      selected: selected,
      label: l.paletteSemantic(palette.localizedName(l)),
      child: InkWell(
        key: ValueKey('palette-${palette.id}'),
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 96,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: selected ? scheme.primaryContainer.withValues(alpha: 0.5) : null,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipOval(
                      child: Row(
                        children: [
                          Expanded(child: ColoredBox(color: c.primary, child: const SizedBox.expand())),
                          Expanded(child: ColoredBox(color: c.secondary, child: const SizedBox.expand())),
                        ],
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_circle, color: c.onPrimary, size: 22),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                palette.localizedName(l),
                textAlign: TextAlign.center,
                maxLines: 2,
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
