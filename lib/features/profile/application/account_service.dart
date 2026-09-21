import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../../calendar/services/reminder_scheduler.dart';

/// Accounts do not exist yet: there is no sign-in and no server. This is the
/// seam where they plug in, so the Profile screen already behaves correctly.
///
/// TODO(auth): sign out of, and delete, the real account (Supabase) here.
abstract class AccountService {
  /// Signs out. False when there was no account to sign out of.
  Future<bool> signOut();

  /// Deletes the account and everything saved on this phone.
  Future<void> deleteAccount();
}

class LocalAccountService implements AccountService {
  LocalAccountService(this._scheduler);

  final ReminderScheduler _scheduler;

  @override
  Future<bool> signOut() async => false;

  @override
  Future<void> deleteAccount() async {
    // Stop every notification the app scheduled...
    for (final group in alertGroups) {
      await _scheduler.replaceAlerts(group, const []);
    }
    await _scheduler.rescheduleAll(const []);
    // ...then erase the profile, plans, marks, mantras, training and settings.
    await AppStorage.clearAll();
  }
}

final accountServiceProvider = Provider<AccountService>(
    (ref) => LocalAccountService(ref.watch(reminderSchedulerProvider)));
