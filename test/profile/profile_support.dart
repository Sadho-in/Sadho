import 'dart:typed_data';

import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/profile/application/account_service.dart';
import 'package:advance_calendar/features/profile/application/backup_service.dart';
import 'package:advance_calendar/features/profile/presentation/profile_screen.dart';
import 'package:advance_calendar/features/sadhana/services/pcm_input.dart';
import 'package:advance_calendar/features/sadhana/services/voice_counter_service.dart';
import 'package:advance_calendar/features/sadhana/services/volume_button_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:advance_calendar/features/clock/services/location_service.dart';

import '../clock/clock_support.dart';
import '../sadhana/test_support.dart' show FakePcmInput, FakeVoice, FakeVolume;

export '../clock/clock_support.dart';

/// Stand-in for the system file dialogs.
class FakeBackupFiles implements BackupFiles {
  /// What "Save" was asked to write, if anything.
  String? savedName;
  Uint8List? savedBytes;
  bool saveAccepted = true;

  /// What "Choose a file" returns (null = the user backed out).
  Uint8List? toPick;
  Object? pickError;
  int picks = 0;

  String? get savedText => savedBytes == null ? null : String.fromCharCodes(savedBytes!);

  @override
  Future<bool> save(String fileName, Uint8List bytes) async {
    if (!saveAccepted) return false;
    savedName = fileName;
    savedBytes = bytes;
    return true;
  }

  @override
  Future<Uint8List?> pick() async {
    picks++;
    if (pickError != null) throw pickError!;
    return toPick;
  }
}

/// Counts what the account service was asked, and really wipes like the real
/// one when [delegate] is true.
class SpyAccountService implements AccountService {
  SpyAccountService(this.inner);
  final AccountService inner;
  int signOuts = 0;
  int deletes = 0;

  @override
  Future<bool> signOut() {
    signOuts++;
    return inner.signOut();
  }

  @override
  Future<void> deleteAccount() {
    deletes++;
    return inner.deleteAccount();
  }
}

/// A container for the Home / Profile providers (fresh storage).
class ProfileRig {
  ProfileRig(this.container, this.clock, this.scheduler, this.files, this.location);

  final ProviderContainer container;
  final FakeClock clock;
  final FakeScheduler scheduler;
  final FakeBackupFiles files;
  final FakeLocationService location;
}

ProfileRig profileRig({
  DateTime? now,
  FakeScheduler? scheduler,
  FakeBackupFiles? files,
  FakeLocationService? location,
  Map<String, Object?> saved = const {},
  List<Override> extra = const [],
}) {
  final clock = FakeClock(now ?? clockTestNow());
  final sched = scheduler ?? FakeScheduler();
  final f = files ?? FakeBackupFiles();
  final phone = location ?? FakeLocationService(state: LocationAccess.denied);
  final container = clockContainer(
    clock: clock,
    scheduler: sched,
    location: phone,
    saved: saved,
    extra: [
      backupFilesProvider.overrideWithValue(f),
      // The Profile page shows a Sadhana setting, which builds the session and
      // with it the microphone and volume-button services.
      pcmInputProvider.overrideWithValue(FakePcmInput()),
      voiceCounterServiceProvider.overrideWithValue(FakeVoice()),
      volumeButtonServiceProvider.overrideWithValue(FakeVolume()),
      ...extra,
    ],
  );
  return ProfileRig(container, clock, sched, f, phone);
}

/// Pumps [child] under [rig]'s container, on a phone-sized screen.
Future<void> pumpProfile(
  WidgetTester tester,
  ProfileRig rig,
  Widget child, {
  double width = 411,
  double height = 6000,
  Brightness brightness = Brightness.light,
  bool page = false,
}) async {
  phoneScreen(tester, width: width, height: height);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: rig.container,
    child: MaterialApp(
      theme: calendarTestTheme(brightness),
      home: page ? child : Scaffold(body: child),
    ),
  ));
  await tester.pump();
}

/// The whole Profile screen.
Future<ProfileRig> openProfile(
  WidgetTester tester, {
  ProfileRig? rig,
  double width = 411,
  double height = 6000,
  Brightness brightness = Brightness.light,
}) async {
  final r = rig ?? profileRig();
  await pumpProfile(tester, r, const ProfilePage(),
      width: width, height: height, brightness: brightness, page: true);
  return r;
}

/// Everything in Hive-like storage, for comparing before/after.
Map<String, Map<String, dynamic>> snapshot() => {
      for (final e in AppStorage.all.entries)
        e.key: {for (final k in e.value.keys) k: e.value.get(k)},
    };
