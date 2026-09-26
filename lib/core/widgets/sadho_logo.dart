import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// The Sadho logo (the app icon's artwork, assets/branding/icon-1024.png), in
/// a rounded square like the launcher icon. Change the logo by replacing the
/// files in assets/branding/ (see README "App icon").
class SadhoLogo extends StatelessWidget {
  const SadhoLogo({super.key, this.size = 72});

  static const asset = 'assets/branding/icon-1024.png';

  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
        image: true,
        label: AppConstants.appName,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.22),
          child: Image.asset(
            asset,
            key: const ValueKey('sadho-logo'),
            width: size,
            height: size,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
        ),
      );
}
