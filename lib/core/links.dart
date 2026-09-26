import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a web page in the phone's browser. A seam, so tests check which
/// page would open without a browser.
abstract class LinkLauncher {
  /// True if the browser opened it.
  Future<bool> open(Uri url);
}

class BrowserLinkLauncher implements LinkLauncher {
  const BrowserLinkLauncher();

  @override
  Future<bool> open(Uri url) async {
    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not open $url: $e');
      return false;
    }
  }
}

final linkLauncherProvider =
    Provider<LinkLauncher>((ref) => const BrowserLinkLauncher());
