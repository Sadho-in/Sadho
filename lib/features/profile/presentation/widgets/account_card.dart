import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/l10n.dart';
import '../../../sadhana/presentation/widgets/section_card.dart';
import '../../application/account_service.dart';
import 'password_sheet.dart';

/// Change password and sign out.
///
/// TODO(auth): both become real once accounts exist.
class AccountCard extends ConsumerWidget {
  const AccountCard({super.key});

  void _say(BuildContext context, String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  Future<void> _changePassword(BuildContext context) async {
    final l = context.l10n;
    final done = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const PasswordSheet(),
    );
    if (done == true && context.mounted) {
      _say(context, l.passwordWillWorkLater);
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final hadAccount = await ref.read(accountServiceProvider).signOut();
    if (!context.mounted) return;
    _say(context, hadAccount ? l.signedOut : l.notSignedInYet);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return SectionCard(
      title: l.accountTitle,
      child: Column(
        children: [
          ListTile(
            key: const ValueKey('change-password'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_outline),
            title: Text(l.changePasswordTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _changePassword(context),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const ValueKey('sign-out'),
              onPressed: () => _signOut(context, ref),
              icon: const Icon(Icons.logout),
              label: Text(l.signOutButton),
            ),
          ),
        ],
      ),
    );
  }
}
