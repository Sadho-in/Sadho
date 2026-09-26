import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/sadho_logo.dart';
import '../../clock/application/clock_source.dart';
import '../../profile/presentation/widgets/about_card.dart' show openLink;
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

  @override
  void initState() {
    super.initState();
    // The privacy / terms notice below Continue is on screen from now.
    LegalNotice.markShown(ref.read(clockNowProvider)());
  }

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
    LegalNotice.markAccepted(ref.read(clockNowProvider)());
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
                const SizedBox(height: 12),
                const _LegalNoticeText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Your practice ... stay on this phone. By continuing you agree to the Terms
/// of use and have read the Privacy policy.", with both as links.
class _LegalNoticeText extends ConsumerStatefulWidget {
  const _LegalNoticeText();

  @override
  ConsumerState<_LegalNoticeText> createState() => _LegalNoticeTextState();
}

class _LegalNoticeTextState extends ConsumerState<_LegalNoticeText> {
  late final _terms = TapGestureRecognizer()
    ..onTap = () => openLink(context, ref, AppConstants.termsUrl);
  late final _privacy = TapGestureRecognizer()
    ..onTap = () => openLink(context, ref, AppConstants.privacyUrl);

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final linkStyle = style?.copyWith(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );
    // The sentence is translated as a whole; the two link names are put in
    // where the translation places them.
    const termsMark = '\u0001', privacyMark = '\u0002';
    final sentence = l.onboardingLegalNotice(termsMark, privacyMark);
    final spans = <InlineSpan>[];
    for (final part in sentence.split(RegExp('(?=[\u0001\u0002])|(?<=[\u0001\u0002])'))) {
      if (part == termsMark) {
        spans.add(TextSpan(text: l.legalTermsOfUse, style: linkStyle, recognizer: _terms));
      } else if (part == privacyMark) {
        spans.add(TextSpan(
            text: l.legalPrivacyPolicy, style: linkStyle, recognizer: _privacy));
      } else if (part.isNotEmpty) {
        spans.add(TextSpan(text: part));
      }
    }
    return Text.rich(
      TextSpan(style: style, children: spans),
      key: const ValueKey('onboarding-legal-notice'),
    );
  }
}
