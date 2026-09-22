import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../../../l10n/l10n.dart';
import '../../../l10n/locale_provider.dart';
import '../../home/application/plans_provider.dart';
import '../../home/application/tradition_provider.dart';
import 'daily_reminder_provider.dart';

const maxNameLength = 60;

/// "Enter a valid email address", or null if [v] is fine. An empty email is
/// allowed (it is optional).
String? validateEmail(String v, [AppLocalizations? l10n]) {
  final s = v.trim();
  if (s.isEmpty) return null;
  final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@.]{2,}$').hasMatch(s);
  return ok ? null : (l10n ?? englishL10n).validEmailError;
}

String? validateName(String v, [AppLocalizations? l10n]) => v.trim().length > maxNameLength
    ? (l10n ?? englishL10n).nameTooLong(maxNameLength)
    : null;

class UserProfile {
  const UserProfile({this.name = '', this.email = ''});

  final String name;
  final String email;

  bool get hasName => name.trim().isNotEmpty;
  bool get hasEmail => email.trim().isNotEmpty && validateEmail(email) == null;

  /// "A" for Asha; empty when there is no name yet.
  String get initial => hasName
      ? String.fromCharCode(name.trim().runes.first).toUpperCase()
      : '';

  /// The first word of the name, for the greeting.
  String get firstName => hasName ? name.trim().split(RegExp(r'\s+')).first : '';
}

/// The user's name and email, saved on the phone (Hive) for now.
///
/// TODO(auth): these come from the account once sign-in exists.
class ProfileNotifier extends Notifier<UserProfile> {
  static const _key = 'profile';

  @override
  UserProfile build() {
    final raw = AppStorage.settings.get(_key);
    if (raw is! Map) return const UserProfile();
    return UserProfile(
      name: raw['name'] is String ? raw['name'] as String : '',
      email: raw['email'] is String ? raw['email'] as String : '',
    );
  }

  /// Saves both fields. False (and nothing saved) if either is invalid.
  bool save({required String name, required String email}) {
    if (validateName(name) != null || validateEmail(email) != null) return false;
    state = UserProfile(name: name.trim(), email: email.trim());
    AppStorage.settings.put(_key, {'name': state.name, 'email': state.email});
    return true;
  }
}

final profileProvider =
    NotifierProvider<ProfileNotifier, UserProfile>(ProfileNotifier.new);

/// One step towards a complete profile.
class CompletionStep {
  const CompletionStep(this.id, this.label, this.done);
  final String id;
  final String label;
  final bool done;
}

class ProfileCompletion {
  const ProfileCompletion(this.steps);

  final List<CompletionStep> steps;

  int get doneCount => steps.where((s) => s.done).length;

  /// 0 to 100, in equal steps.
  int get percent => steps.isEmpty ? 0 : (doneCount * 100 / steps.length).round();

  bool get complete => doneCount == steps.length;

  List<CompletionStep> get missing => [for (final s in steps) if (!s.done) s];
}

/// How much of the profile is filled in: name, email, a tradition picked on
/// Home, the daily reminder on, and a first plan started.
final profileCompletionProvider = Provider<ProfileCompletion>((ref) {
  final profile = ref.watch(profileProvider);
  final tradition = ref.watch(traditionProvider);
  final reminder = ref.watch(dailyReminderProvider);
  final plans = ref.watch(plansProvider);
  final l = ref.watch(l10nProvider);
  return ProfileCompletion([
    CompletionStep('name', l.stepAddName, profile.hasName),
    CompletionStep('email', l.stepAddEmail, profile.hasEmail),
    CompletionStep('tradition', l.stepPickTradition, tradition != null),
    CompletionStep('reminder', l.stepTurnOnReminder, reminder.enabled),
    CompletionStep('plan', l.stepStartPlan, plans.isNotEmpty),
  ]);
});
