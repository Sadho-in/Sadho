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
}
