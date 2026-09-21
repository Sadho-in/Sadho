import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_restart.dart';
import '../../../sadhana/presentation/widgets/section_card.dart';
import '../../application/backup_service.dart';

/// Backup and restore: everything saved on the phone, to a file you choose.
///
/// TODO(phase-2): cloud sync (Supabase) so this happens by itself.
class BackupCard extends ConsumerWidget {
  const BackupCard({super.key});

  void _say(BuildContext context, String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    try {
      final now = DateTime.now();
      final bytes = Uint8List.fromList(utf8.encode(exportBackup(now: now)));
      final saved = await ref
          .read(backupFilesProvider)
          .save(backupFileName(now), bytes);
      if (context.mounted) {
        _say(context, saved ? 'Backup saved' : 'Backup cancelled');
      }
    } catch (e) {
      if (context.mounted) _say(context, 'Could not save the backup. Try again.');
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final BackupContents contents;
    try {
      final bytes = await ref.read(backupFilesProvider).pick();
      if (bytes == null) return; // backed out
      contents = parseBackup(utf8.decode(bytes, allowMalformed: false));
    } on BackupException catch (e) {
      if (context.mounted) _say(context, e.message);
      return;
    } on FormatException {
      if (context.mounted) _say(context, 'That file is not a Sadho backup.');
      return;
    } catch (e) {
      if (context.mounted) _say(context, 'Could not read that file.');
      return;
    }
    if (!context.mounted) return;

    final made = contents.exportedAt == null
        ? ''
        : ' made on ${DateFormat.yMMMd().format(contents.exportedAt!)}';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore this backup?'),
        content: Text('A backup$made with ${contents.itemCount} saved items. '
            'It will replace what is on this phone now: marks, plans, '
            'mantras, voice training and settings.'),
        actions: [
          TextButton(
            key: const ValueKey('restore-cancel'),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const ValueKey('restore-confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    await applyBackup(contents);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Backup restored'),
        content: const Text('Sadho will reload with your restored data.'),
        actions: [
          FilledButton(
            key: const ValueKey('restore-done'),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (context.mounted) AppRestart.of(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Backup & restore',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Save your marks, plans, mantras, voice training and settings to a '
            'file you choose (Drive, Files, email it to yourself). Restore it '
            'on this or another phone.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  key: const ValueKey('backup-export'),
                  onPressed: () => _export(context, ref),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Export'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  key: const ValueKey('backup-restore'),
                  onPressed: () => _restore(context, ref),
                  icon: const Icon(Icons.download),
                  label: const Text('Restore'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListTile(
            key: const ValueKey('cloud-sync'),
            contentPadding: EdgeInsets.zero,
            enabled: false,
            leading: const Icon(Icons.cloud_outlined),
            title: const Text('Cloud sync'),
            subtitle: const Text('Coming later'),
          ),
        ],
      ),
    );
  }
}
