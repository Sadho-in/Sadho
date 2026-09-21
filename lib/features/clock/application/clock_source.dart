import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "What time is it now?" for the Clock tools. A seam so tests can move time
/// forward without waiting; in the app it is simply the system clock.
final clockNowProvider = Provider<DateTime Function()>((ref) => DateTime.now);
