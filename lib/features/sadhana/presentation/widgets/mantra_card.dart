import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/sadhana_session_provider.dart';
import '../../application/selected_mantra_provider.dart';
import '../../data/mantra.dart';
import '../mantra_library_screen.dart';
import 'script_text.dart';
import 'voice_widgets.dart';

/// Opens the library and applies the choice, confirming first if it would
/// discard a count in progress.
Future<void> pickMantra(BuildContext context, WidgetRef ref) async {
  final picked = await Navigator.of(context).push<Mantra>(
    MaterialPageRoute(builder: (_) => const MantraLibraryScreen()),
  );
  if (picked == null || !context.mounted) return;

  final session = ref.read(sadhanaSessionProvider);
  if (picked.id == session.mantraId) return;

  if (session.count > 0 || session.elapsedSeconds > 0) {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Switch to ${picked.title}?'),
        content: const Text('Your current count will be reset.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep current')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Switch')),
        ],
      ),
    );
    if (ok != true) return;
  }
  ref
      .read(sadhanaSessionProvider.notifier)
      .selectMantra(picked.id, picked.defaultCount);
}

/// The selected mantra, kept SMALL so the counter fits above the fold: script,
/// name and transliteration on one line each, small tags (tradition, whether
/// its voice is trained) and a compact Library button.
class MantraCard extends ConsumerWidget {
  const MantraCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mantra = ref.watch(selectedMantraProvider);
    final onCard = scheme.onSecondaryContainer;

    return Card(
      color: scheme.secondaryContainer.withValues(alpha: 0.55),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => pickMantra(context, ref),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (mantra.script.isNotEmpty)
                      ScriptText(
                        mantra.script,
                        maxLines: 1,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: onCard),
                      ),
                    Text(
                      mantra.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: onCard,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (mantra.transliteration.isNotEmpty &&
                        mantra.transliteration != mantra.title)
                      Text(
                        mantra.transliteration,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: onCard.withValues(alpha: 0.8),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 10,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (mantra.tradition.isNotEmpty)
                          Text(
                            mantra.tradition,
                            style: theme.textTheme.labelMedium
                                ?.copyWith(color: onCard.withValues(alpha: 0.85)),
                          ),
                        // Voice counts only a trained mantra: say whether this is.
                        VoiceTrainedTag(mantra.id),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => pickMantra(context, ref),
                icon: const Icon(Icons.library_music_outlined, size: 16),
                label: const Text('Library'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
