import 'package:flutter/material.dart';

/// Rules for a new password.
const minPasswordLength = 8;

String? validateCurrentPassword(String v) =>
    v.isEmpty ? 'Enter your current password' : null;

String? validateNewPassword(String v, String current) {
  if (v.length < minPasswordLength) {
    return 'Use at least $minPasswordLength characters';
  }
  if (v == current) return 'Choose a password you have not used';
  return null;
}

String? validateConfirmPassword(String v, String next) =>
    v == next ? null : 'The two passwords do not match';

/// The change-password form. It only checks the entries: there are no accounts
/// yet, so nothing is stored or sent anywhere.
///
/// TODO(auth): call the auth service here once accounts exist.
class PasswordSheet extends StatefulWidget {
  const PasswordSheet({super.key});

  @override
  State<PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends State<PasswordSheet> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _show = false;
  bool _tried = false;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? get _e1 => validateCurrentPassword(_current.text);
  String? get _e2 => validateNewPassword(_new.text, _current.text);
  String? get _e3 => validateConfirmPassword(_confirm.text, _new.text);

  void _submit() {
    setState(() => _tried = true);
    if (_e1 != null || _e2 != null || _e3 != null) return;
    // Closes with true: the caller explains that this is UI-only for now.
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget field(String key, String label, TextEditingController c, String? error) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            key: ValueKey(key),
            controller: c,
            obscureText: !_show,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: label,
              errorText: _tried ? error : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
        );

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change password', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Accounts arrive in a later phase; until then this only checks '
              'your entries and changes nothing.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            field('pw-current', 'Current password', _current, _e1),
            field('pw-new', 'New password', _new, _e2),
            field('pw-confirm', 'Confirm new password', _confirm, _e3),
            CheckboxListTile(
              key: const ValueKey('pw-show'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Show passwords'),
              value: _show,
              onChanged: (v) => setState(() => _show = v ?? false),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const ValueKey('pw-submit'),
                onPressed: _submit,
                child: const Text('Update password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
