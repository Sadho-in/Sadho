import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The bundled fonts, their licence file, and the families it covers. They
/// are shown on the open-source licences page (Profile > About).
const bundledFontLicenses = {
  'assets/fonts/OFL-Fraunces.txt': ['Fraunces'],
  'assets/fonts/OFL-Karla.txt': ['Karla'],
  'assets/fonts/OFL-NotoSans.txt': [
    'Noto Sans Devanagari',
    'Noto Sans Gurmukhi',
    'Noto Sans Bengali',
    'Noto Sans Gujarati',
    'Noto Sans Tamil',
    'Noto Sans Telugu',
    'Noto Sans Kannada',
  ],
};

bool _registered = false;

/// Adds the fonts' SIL Open Font License texts to [LicenseRegistry]. Call once
/// from `main()`; later calls do nothing.
void registerFontLicenses({AssetBundle? bundle}) {
  if (_registered) return;
  _registered = true;
  LicenseRegistry.addLicense(() async* {
    final b = bundle ?? rootBundle;
    for (final e in bundledFontLicenses.entries) {
      yield LicenseEntryWithLineBreaks(e.value, await b.loadString(e.key));
    }
  });
}
