import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/sadho_logo.dart';
import '../../../l10n/l10n.dart';
import '../../../l10n/labels.dart';
import '../../home/application/tradition_provider.dart';
import '../../home/data/tradition.dart';
import '../../shell/language_provider.dart';
import '../application/onboarding_provider.dart';

/// Shown once, on first launch only: pick a language and a tradition, then
/// "Continue". Both are saved (and can be changed again later, in Profile);
/// this screen never shows again unless the phone's data is cleared.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late String _languageCode =
      initialLanguageCode(ref.read(devicePlatformLocaleProvider));
  Tradition _tradition = Tradition.hindu;

  void _selectLanguage(String? code) {
    if (code == null) return;
    setState(() => _languageCode = code);
    // Live preview, exactly like the in-app language picker: the rest of
    // this screen re-renders in the chosen language right away.
    ref.read(languageProvider.notifier).set(code);
  }

  void _continue() {
    // The language may only have been previewed, not tapped (the guessed
    // default was left as-is): make sure it is actually saved.
    ref.read(languageProvider.notifier).set(_languageCode);
    ref.read(traditionProvider.notifier).set(_tradition);
    ref.read(onboardingCompleteProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SadhoLogo(size: 72),
                ),
                const SizedBox(height: 16),
                Text(l.onboardingTitle, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  l.onboardingSubtitle,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                Text(l.languageSheetTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                RadioGroup<String>(
                  groupValue: _languageCode,
                  onChanged: _selectLanguage,
                  child: Column(
                    children: [
                      for (final lang in appLanguages)
                        RadioListTile<String>(
                          key: ValueKey('onboarding-lang-${lang.code}'),
                          value: lang.code,
                          title: Text(lang.nativeName),
                          subtitle: Text(lang.name),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(l.traditionHeading, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                RadioGroup<Tradition>(
                  groupValue: _tradition,
                  onChanged: (t) {
                    if (t != null) setState(() => _tradition = t);
                  },
                  child: Column(
                    children: [
                      for (final t in Tradition.values)
                        RadioListTile<Tradition>(
                          key: ValueKey('onboarding-tradition-${t.name}'),
                          value: t,
                          title: Text(t.localized(l)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const ValueKey('onboarding-continue'),
                    onPressed: _continue,
                    child: Text(l.continueAction),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
