import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mantra.dart';
import 'mantra_library_provider.dart';
import 'sadhana_session_provider.dart';

/// The mantra of the current session. Falls back to the first library entry
/// if the saved one has since been deleted.
final selectedMantraProvider = Provider<Mantra>((ref) {
  final library = ref.watch(mantraLibraryProvider);
  final id = ref.watch(sadhanaSessionProvider.select((s) => s.mantraId));
  return library.firstWhere((m) => m.id == id, orElse: () => library.first);
});
