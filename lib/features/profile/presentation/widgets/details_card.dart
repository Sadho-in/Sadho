import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../sadhana/presentation/widgets/section_card.dart';
import '../../application/profile_provider.dart';

/// Name and email, saved on the phone.
class DetailsCard extends ConsumerStatefulWidget {
  const DetailsCard({super.key});

  @override
  ConsumerState<DetailsCard> createState() => _DetailsCardState();
}

class _DetailsCardState extends ConsumerState<DetailsCard> {
  late final TextEditingController _name;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    final p = ref.read(profileProvider);
    _name = TextEditingController(text: p.name);
    _email = TextEditingController(text: p.email);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  bool get _dirty {
    final p = ref.read(profileProvider);
    return _name.text.trim() != p.name || _email.text.trim() != p.email;
  }

  bool get _valid =>
      validateName(_name.text) == null && validateEmail(_email.text) == null;

  void _save() {
    if (!ref
        .read(profileProvider.notifier)
        .save(name: _name.text, email: _email.text)) {
      return;
    }
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Profile saved')));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilt when the saved profile changes, so "Save" follows what is saved.
    ref.watch(profileProvider);
    return SectionCard(
      title: 'Your details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const ValueKey('profile-name'),
            controller: _name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: const Icon(Icons.person_outline),
              errorText: validateName(_name.text),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('profile-email'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.mail_outline),
              errorText: validateEmail(_email.text),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (_dirty && _valid) _save();
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              key: const ValueKey('profile-save'),
              onPressed: _dirty && _valid ? _save : null,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
