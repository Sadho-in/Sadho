import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/sadhana_session_provider.dart';
import 'section_card.dart';

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
      title: 'Sankalp',
      child: TextField(
        controller: _controller,
        minLines: 2,
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'State your intention for this practice…',
        ),
        onChanged: ref.read(sadhanaSessionProvider.notifier).setSankalp,
      ),
    );
  }
}
