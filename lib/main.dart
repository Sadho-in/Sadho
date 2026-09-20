import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/storage/app_storage.dart';

// TODO(phase-2): initialise Supabase (auth + sync) here.
// TODO(later-phase): Android/iOS home-screen widgets, voice engine, OCR.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.init();
  runApp(const ProviderScope(child: SadhoApp()));
}
