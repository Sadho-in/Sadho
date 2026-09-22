import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/sadhana_session_provider.dart';
import 'section_card.dart';
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
    return SectionCard(
      title: context.l10n.sankalpLabel,
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
