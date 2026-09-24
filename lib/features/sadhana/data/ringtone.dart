/// Completion sounds bundled in assets/sounds (synthesised WAVs).
enum Ringtone {
  templeBell('Temple bell', 'sounds/temple_bell.wav'),
  singingBowl('Singing bowl', 'sounds/singing_bowl.wav'),
  softChime('Soft chime', 'sounds/soft_chime.wav'),
  deepGong('Deep gong', 'sounds/deep_gong.wav');

  const Ringtone(this.label, this.asset);
  final String label;

  /// Path relative to `assets/`, as audioplayers' AssetSource expects.
  final String asset;

  /// The same sound's Android raw resource (android/app/src/main/res/raw),
  /// which the completion alarm notification plays: e.g. `temple_bell`.
  String get rawName => asset.split('/').last.split('.').first;
}
