import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_restart.dart';
import '../../../../l10n/l10n.dart';
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
    final l = context.l10n;
    try {
      final now = DateTime.now();
      final bytes = Uint8List.fromList(utf8.encode(exportBackup(now: now)));
      final saved = await ref
          .read(backupFilesProvider)
          .save(backupFileName(now), bytes);
      if (context.mounted) {
        _say(context, saved ? l.backupSaved : l.backupCancelled);
      }
    } catch (e) {
      if (context.mounted) _say(context, l.couldNotSaveBackup);
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final BackupContents contents;
    try {
      final bytes = await ref.read(backupFilesProvider).pick();
      if (bytes == null) return; // backed out
      contents = parseBackup(utf8.decode(bytes, allowMalformed: false), l);
    } on BackupException catch (e) {
      if (context.mounted) _say(context, e.message);
      return;
    } on FormatException {
      if (context.mounted) _say(context, l.backupNotSadho);
      return;
    } catch (e) {
      if (context.mounted) _say(context, l.couldNotReadFile);
      return;
    }
    if (!context.mounted) return;

    final made = contents.exportedAt == null
        ? ''
        : l.madeOnSuffix(DateFormat.yMMMd().format(contents.exportedAt!));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.restoreThisBackup),
        content: Text(l.restoreBackupBody(made, contents.itemCount)),
        actions: [
          TextButton(
            key: const ValueKey('restore-cancel'),
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            key: const ValueKey('restore-confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.restoreButton),
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
        title: Text(l.backupRestoredTitle),
        content: Text(l.backupRestoredBody),
        actions: [
          FilledButton(
            key: const ValueKey('restore-done'),
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.actionOk),
          ),
        ],
      ),
    );
    if (context.mounted) AppRestart.of(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = context.l10n;
    return SectionCard(
      title: l.backupRestoreTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.backupExplain,
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
                  label: Text(l.exportButton),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  key: const ValueKey('backup-restore'),
                  onPressed: () => _restore(context, ref),
                  icon: const Icon(Icons.download),
                  label: Text(l.restoreButton),
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
            title: Text(l.cloudSyncTitle),
            subtitle: Text(l.comingLater),
          ),
        ],
      ),
    );
  }
}
