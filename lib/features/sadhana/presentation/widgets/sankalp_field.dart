import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/sadhana_session_provider.dart';
import 'section_card.dart';
import '../../application/collapsed_cards_provider.dart';
import '../../../../l10n/l10n.dart';

/// Editable sankalp (intention) for the session; saved as you type.
class SankalpField extends ConsumerStatefulWidget {
  const SankalpField({super.key});

  @override
  ConsumerState<SankalpField> createState() => _SankalpFieldState();
}

class _SankalpFieldState extends ConsumerState<SankalpField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(sadhanaSessionProvider).sankalp,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final sankalp = ref.watch(sadhanaSessionProvider.select((s) => s.sankalp));
    // The first words, on one line (the summary ellipsises the rest).
    final firstLine = sankalp.trim().split('\n').first.trim();
    return CollapsibleSectionCard(
      id: SadhanaCard.sankalp,
      title: l.sankalpLabel,
      summary: firstLine.isEmpty ? l.summaryNotSet : firstLine,
      child: TextField(
        controller: _controller,
        minLines: 2,
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: context.l10n.sankalpHint,
        ),
        onChanged: ref.read(sadhanaSessionProvider.notifier).setSankalp,
      ),
    );
  }
}
