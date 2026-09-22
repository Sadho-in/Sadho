import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/app_storage.dart';
import '../../../core/storage/kv_store.dart';
import '../../../l10n/l10n.dart';
import '../../../l10n/labels.dart' show currentL10n;

const backupFormat = 'sadho-backup';
const backupVersion = 1;

/// A backup file the app cannot use. [message] is fit to show to the user.
class BackupException implements Exception {
  BackupException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// What a backup file contains (checked, but not yet applied).
class BackupContents {
  BackupContents._(this.boxes, this.exportedAt);

  /// Box name -> key -> value (decoded).
  final Map<String, Map<String, dynamic>> boxes;
  final DateTime? exportedAt;

  int get itemCount => boxes.values.fold(0, (n, b) => n + b.length);
}

// ---- values <-> JSON -------------------------------------------------------

const _bytesTag = '__b64';

/// Hive values are maps, lists, numbers, strings, bools and (for voice
/// training) raw bytes. Bytes become `{"__b64": "..."}`. Anything else cannot
/// be saved in a backup and is left out.
Object? _encode(Object? v) {
  if (v == null || v is bool || v is String) return v;
  if (v is num) return v.isFinite ? v : null;
  if (v is Uint8List) return {_bytesTag: base64Encode(v)};
  if (v is List) return [for (final e in v) _encode(e)];
  if (v is Map) {
    return {for (final e in v.entries) '${e.key}': _encode(e.value)};
  }
  throw BackupException('Cannot save a value of type ${v.runtimeType}');
}

Object? _decode(Object? v, AppLocalizations l) {
  if (v is List) return [for (final e in v) _decode(e, l)];
  if (v is Map) {
    if (v.length == 1 && v[_bytesTag] is String) {
      try {
        return base64Decode(v[_bytesTag] as String);
      } on FormatException {
        throw BackupException(l.backupDamaged);
      }
    }
    return {for (final e in v.entries) '${e.key}': _decode(e.value, l)};
  }
  return v;
}

// ---- export / import -----------------------------------------------------------

/// Everything saved on this phone as one JSON document.
String exportBackup({DateTime? now}) {
  final boxes = <String, Object?>{};
  for (final e in AppStorage.all.entries) {
    final entries = <String, Object?>{};
    for (final k in e.value.keys) {
      try {
        entries[k] = _encode(e.value.get(k));
      } on BackupException catch (err) {
        debugPrint('Backup: skipped $k in ${e.key}: $err');
      }
    }
    boxes[e.key] = entries;
  }
  return const JsonEncoder.withIndent('  ').convert({
    'format': backupFormat,
    'version': backupVersion,
    'app': AppConstants.appName,
    'appVersion': AppConstants.version,
    'exportedAt': (now ?? DateTime.now()).toIso8601String(),
    'boxes': boxes,
  });
}

/// The file name to offer: sadho-backup-2026-09-22.json
String backupFileName(DateTime now) {
  String two(int n) => n.toString().padLeft(2, '0');
  return 'sadho-backup-${now.year}-${two(now.month)}-${two(now.day)}.json';
}

/// Reads and checks a backup without changing anything. Throws a
/// [BackupException] with a plain message (in [l10n], English by default) if
/// it is not a usable Sadho backup.
BackupContents parseBackup(String text, [AppLocalizations? l10n]) {
  final l = l10n ?? englishL10n;
  final Object? doc;
  try {
    doc = jsonDecode(text);
  } on FormatException {
    throw BackupException(l.backupNotSadho);
  }
  if (doc is! Map || doc['format'] != backupFormat) {
    throw BackupException(l.backupNotSadho);
  }
  final version = doc['version'];
  if (version is! int || version < 1) {
    throw BackupException(l.backupDamaged);
  }
  if (version > backupVersion) {
    throw BackupException(l.backupTooNew);
  }
  final boxes = doc['boxes'];
  if (boxes is! Map) throw BackupException(l.backupDamaged);

  final out = <String, Map<String, dynamic>>{};
  final known = AppStorage.all.keys.toSet();
  for (final e in boxes.entries) {
    if (!known.contains(e.key)) continue; // a box this version does not have
    final values = e.value;
    if (values is! Map) throw BackupException(l.backupDamaged);
    out['${e.key}'] = {
      for (final kv in values.entries) '${kv.key}': _decode(kv.value, l),
    };
  }
  if (out.isEmpty) throw BackupException(l.backupNoData);
  return BackupContents._(out, DateTime.tryParse('${doc['exportedAt']}'));
}

/// Replaces what is on this phone with [contents], box by box. Boxes the
/// backup does not mention are left as they are.
Future<void> applyBackup(BackupContents contents) async {
  final stores = AppStorage.all;
  for (final e in contents.boxes.entries) {
    final KvStore store = stores[e.key]!;
    await store.clear();
    for (final kv in e.value.entries) {
      await store.put(kv.key, kv.value);
    }
  }
}

// ---- the file itself -------------------------------------------------------------

/// Saving and picking the file: behind an interface so tests never open a real
/// system dialog.
abstract class BackupFiles {
  /// Asks where to save. False if the user backed out.
  Future<bool> save(String fileName, Uint8List bytes);

  /// Asks for a file. Null if the user backed out.
  Future<Uint8List?> pick();
}

class FilePickerBackupFiles implements BackupFiles {
  /// Backups are small; anything much bigger is not one of ours.
  static const maxBytes = 50 * 1024 * 1024;

  @override
  Future<bool> save(String fileName, Uint8List bytes) async {
    final uri = await FilePicker.saveFile(
      dialogTitle: currentL10n().saveBackupDialogTitle,
      fileName: fileName,
      bytes: bytes,
      mimeType: 'application/json',
    );
    return uri != null;
  }

  @override
  Future<Uint8List?> pick() async {
    final files =
        await FilePicker.pickFiles(dialogTitle: currentL10n().chooseBackupDialogTitle);
    if (files.isEmpty) return null;
    final size = files.first.lengthSync() ?? await files.first.length();
    if (size != null && size > maxBytes) {
      throw BackupException(currentL10n().backupTooBig);
    }
    return files.first.readAsBytes();
  }
}

final backupFilesProvider = Provider<BackupFiles>((ref) => FilePickerBackupFiles());
