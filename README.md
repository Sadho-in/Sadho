# Sadho

A devotional companion app — **Sadho** (sadho.in). The Flutter project folder is
still `advance_calendar`; the Android/iOS display name and the in-app title are
**Sadho**. The package / bundle id is the Flutter default
(`com.example.advance_calendar`) for now.

## Phase 1 — what is delivered

**App shell**
- Material 3, warm devotional theme: marigold `#DE8517`, deep indigo `#4B4691`,
  warm off-white `#FBF7F0`. Full light **and** dark themes, switchable at
  runtime (choice is saved). Fraunces for headings, Karla for body text.
- Bottom navigation: **Clock · Calendar · Sadhana · Home**. Top bar with a
  language button, a light/dark toggle and a profile avatar.
- Clock, Calendar and Home are placeholders ("Coming soon"). Profile is a
  placeholder too, but already hosts **Sadhana settings** (the Count setting below).
- The language button saves your choice (English / हिन्दी / ਪੰਜਾਬੀ); actual
  translations come later.

**Sadhana — Japa & Paath counter**

*Screen layout.* Everything you need to count fits **above the fold** (no
scrolling, checked by tests on 360×640 up to 411×915 phones): a compact **mantra
card** (name, script, transliteration, small tradition and "Voice trained / not
trained" tags, a small *Library* button); directly under it the slim **Count:
Combined | Separate** toggle; the **progress ring**; **one row** of four controls
(Reset, − undo, + count, Focus); and the primary **Start / Pause / Resume**
button with a one-line mode status. The ring shrinks on short screens to make
this fit. **Below, in the scroll area**: the mode selector (with the chosen
mode's own settings right under it: the Rhythm pace only for Rhythm, the Voice
panel only for Voice), target, vibration and ringtone, and the sankalp.

*Features.*
- **Mantra library**: search, pick, and add your own. Seeded with Om Namah
  Shivaya (108), Gayatri Mantra (108), Waheguru (108), Mool Mantar (11). A custom
  entry has title, script, transliteration, tradition tag and default count, and
  is stored locally in Hive (custom entries can be deleted).
- **Target** by *count* (27 / 108 / 1008 / custom) or by *time*
  (seconds / minutes / hours).
- **Sankalp** — an editable intention, saved as you type.
- **Count: Combined | Separate** — a persisted setting that says how the four
  modes relate. It is a slim control under the mantra card, and the same setting
  (with an explanation) is in Settings (Profile tab).
  - **Every mode always keeps its OWN count** (and its own clock, for a time
    target). The setting only decides what is shown and measured against the
    target, so switching it never merges or loses anything:
  - **Combined** (default): all four modes add to **one shared count** toward
    **one target**: the ring shows the *sum* of Tap, Voice, Rhythm and Mala, and
    Reset clears all of them.
  - **Separate**: the ring shows **the active mode's own count** and its own
    progress toward the target. Switching mode shows that mode's count and its
    own Start / Resume state (only the active mode ever runs, so a mode you leave
    is paused). **Reset and completion apply only to the active mode.**
  - **Switching back and forth restores exactly what was there** (Tap 3,
    Rhythm 2 shows 5 in Combined and 3 / 2 in Separate, however often you flip).
    If the target is already reached in the view you switch to, that session
    stops.
  - Stored in Hive with the session (the choice and each mode's count) and
    restored on relaunch. Sessions saved by earlier versions load unchanged (an old
    single shared count becomes the count of the mode that was active).
- **Active mode + status**, always visible under Start (one line) and in Focus
  mode (two lines, with "own count" in Separate): the mode name and what it is
  doing —
  Tap: "Tap anywhere to count"; Rhythm: "Counting every 2s" / "every 5 min" /
  "every 1 hr"; Voice (Beta): "Listening…" with a live "Counted / Ignored" result
  for each utterance (and a prompt to allow the microphone if it is not granted
  yet, or to train your mantra if it has not been trained); Mala: "Press the
  volume keys to count". Modes this device can
  never run say why up front and when chosen: "No microphone available on this
  device", "Voice counting works on Android and iOS only", "Volume-key counting
  needs a physical device".
- **Counting modes** — all four work, chosen with four **round icon buttons in
  one row** (Tap, Voice, Rhythm, Mala). **Only a mode's own input counts in that
  mode**, so nothing double-counts:
  - **Tap** — tap the ring, or anywhere in Focus mode. **A screen tap counts only
    in Tap mode**: in Voice, Rhythm and Mala, tapping the screen (including in
    Focus mode) does nothing, and only that mode's input counts (a voice match,
    the rhythm timer, a volume key). The **+** and **−** buttons work in **every**
    mode, for corrections.
  - **Rhythm** — counts by itself at a **custom pace**: a number plus a unit
    (Seconds / Minutes / Hours), interval = value × unit. Range 0.2 s to 6 hr,
    default 2 s. Invalid or empty input is ignored (the last valid pace stays,
    and the field says why). The pace is shown as "every 2s", "every 5 min",
    "every 1 hr" in the status line and in Focus mode, and is saved with the rest
    of the session. **The pace control appears only while Rhythm is selected**;
    it is never shown under Tap, Voice or Mala (its value is kept for next time).
  - **Voice (Beta)** — **train your own mantra**. Voice counts **only your
    trained mantra**, on-device and offline, and works for **any** mantra,
    custom ones included. See "Voice (Beta): how it works" below.
    - **Train**: for the selected mantra, record it **3 to 7 times** ("Say your
      mantra… Recording 4 of up to 7"; 3 is enough to save, 5 is a good number,
      more is more accurate). You choose when to stop. Each recording is turned
      into feature templates and saved to Hive; the audio is never kept.
    - **Add more samples** appends new recordings to the existing training
      (up to 7 in total) to improve accuracy without redoing it; the saved
      recordings are kept untouched, and Undo / Start over only ever remove the
      new ones. **Re-train** replaces everything; **Clear training** removes it.
    - **Trained status** shows in the library (per mantra), on the mantra card
      and in the Voice panel. Choosing Voice for an untrained mantra asks you to
      train first, and Start refuses until you have. **Add more samples**,
      **Re-train** and **Clear training** are in the Voice panel (shown only while
      Voice is selected) and on the training screen.
    - **Count**: after Start, each time you chant the mantra it adds one count
      **immediately** (no fixed wait); other words, noise and a half-said mantra
      are ignored. A **Sensitivity** slider (Strict ↔ Lenient, default medium)
      trades missed reps against false counts, and takes effect while listening.
    - **Tap mode** is the fallback (switch to it any time); screen taps do not
      count while Voice is selected. The **+ / −** buttons (setup and Focus mode)
      add or remove a rep by hand, in any mode.
    - Mic permission is requested on first use (`permission_handler` on Android);
      if denied or unavailable the app explains why and switches to Tap (with a
      Settings shortcut if it was blocked for good).
  - **Mala** — hardware **volume-button** counter (`volume_button_listener`).
    Press Start, then every volume Up/Down press adds one count. On Android the
    key event is consumed, so the system volume does not change and its volume
    panel is not shown. Keys go back to normal when you pause, finish or switch
    mode. Great for eyes-closed or in-pocket counting.
  - Voice is Android/iOS only and Mala is Android only; on other platforms
    (web, desktop, and iOS for Mala) choosing them shows a clear message and
    stays on Tap.
  - The **Mantra library** lists every mantra with its Trained status; each row
    can be **edited** (built-ins too: stored as an override in Hive with **Reset
    to default**) and trained. Custom mantras can also be deleted (which clears
    their training).
- **Progress ring** showing count / target (or time remaining for a time target),
  with **Reset**, **−**, **+** and **Focus** in one row under it. Tapping the ring
  counts only in Tap mode.
- **Focus mode** — full screen; in Tap mode a tap **anywhere** counts (in the
  other modes screen taps are inert, and **+ / −** buttons are there for
  corrections). Exit only by holding
  **3 fingers for 4 seconds** (a fill/progress indicator shows while holding), or
  by holding the **Hold to exit** button for the same 4 seconds. The system back
  gesture is blocked. It shows the current mode's status (rhythm pace, Listening…,
  volume buttons active) and a Start/Pause button for Rhythm/Voice/Mala/time.
- **Completion settings** — *Vibration* and *Ringtone* are two separate switches:
  - Vibration: 5 intensity levels (Android amplitude via the `vibration`
    package; devices without amplitude control approximate intensity with
    duration). A buzz every 108 counts and a stronger double-pulse at the target.
  - Ringtone: four bundled sounds (temple bell, singing bowl, soft chime, deep
    gong) played with `audioplayers` at the target, on/off independent of
    vibration.
- The in-progress session (count, target, mantra, sankalp, mode, pace) is saved
  and restored on the next launch; it always reopens paused.

Behaviour notes
- Once a target is reached, counting stops (every input is ignored) until you
  reset or raise the target. Raising the target re-opens a finished session. In
  Separate, only the mode that reached the target stops; the others carry on.
- In Tap mode with a time target, the clock starts on the first tap. Rhythm, Voice
  and Mala are armed with **Start/Pause** (also in Focus mode); Voice and Mala do
  nothing — the microphone stays off and the volume keys stay untouched — until
  Start is pressed. Opening voice training pauses a listening session (the
  microphone serves one listener at a time).
- Switching mantra with a count in progress asks first, then starts fresh with the
  new mantra's default count.

## Tech

Flutter (stable) · Dart · Material 3 · `flutter_riverpod` · `hive` /
`hive_flutter` · `vibration` · `audioplayers` · `google_fonts` ·
`record` (PCM16 16 kHz microphone stream) · `fftea` (FFT) ·
`permission_handler` · `volume_button_listener`. MFCC and DTW are implemented in
Dart in this repo (`lib/features/sadhana/voice/`).

**Permissions**: Android `RECORD_AUDIO` (+ `VIBRATE`; `INTERNET` is only for
Google Fonts); iOS `NSMicrophoneUsageDescription`. Voice needs no speech
recognition permission or service.

### Voice (Beta): how it works

Voice is **train your own mantra**, not speech recognition. It never works out
*what* you said; it checks whether a sound *sounds like the recordings you made
of your mantra*. That is why it works for any mantra in any language.

1. **Training** (per mantra, 3 to 7 recordings, and you can add more later). The microphone is read as a PCM16
   16 kHz mono stream. The first ~0.5 s measures the room's noise floor. Each
   recording is found by energy-based voice activity detection (an onset, then
   trailing silence), converted to **MFCC** features (25 ms frames, 10 ms hop,
   26 mel filters, 13 coefficients, mean/variance-normalised per utterance) and
   saved to Hive as float32 **feature templates** (about 5 KB per second of
   chanting). **Raw audio is never stored**, and the templates cannot be turned
   back into speech. A recording that sounds unlike the others is asked to be
   redone.
2. **Counting**. The same front end cuts the live stream into candidate
   utterances (short-time energy onset + ~300 ms of trailing silence, longer for
   long verses; a length cap drops sentences). Each candidate is compared with
   every template using **DTW** (dynamic time warping, so a slightly faster or
   slower chant still matches). If the best distance is under an **adaptive
   threshold** the rep counts **immediately**. The threshold comes from how much
   *your* recordings vary among themselves, scaled by the Sensitivity slider and
   kept inside fixed bounds. Everything runs per utterance on the phone's CPU.
3. **Offline and private**: no network, no cloud, no speech service; the
   microphone is only open while Voice is listening or training.

**Limits — this is a Beta.**
- **Accuracy improves with more recordings** (up to 7; 5 beats 3), and with
  recordings made the way you will actually chant (same speed, same distance from
  the phone). If it misses you, use **Add more samples** rather than starting over.
- **Accuracy degrades in noise**: a noisy room, TV or other people chanting can
  cause missed or false counts. Strict misses more, Lenient counts more strangers.
- **Leave a short pause between repetitions.** Reps are separated by silence, so
  several repeats chanted in one unbroken breath are one utterance and are not
  counted (use Tap, Rhythm or Mala for that).
- It is tuned on synthetic speech-like audio in the tests; real voices, phones
  and rooms vary, so expect to adjust the slider and re-train if it misbehaves.
  Debug builds print each utterance's distance and threshold (`voice: … d= thr=`),
  which helps tuning.
- The microphone needs the app in the foreground (the OS blocks it in the
  background); Voice pauses its listening and re-measures the noise on return.
- If you edit only a mantra's title or text, its training stays valid; training is
  tied to the mantra, not its wording, so re-train if you change what you chant.
- On iOS, if `permission_handler` is ever used there, add
  `PERMISSION_MICROPHONE=1` to the Podfile.

Google Fonts are fetched at runtime on first launch (internet needed once; the
system font is used until then).

```
lib/
  main.dart, app.dart
  core/
    constants/   app name / website
    storage/     Hive setup + KvStore seam (in-memory store for tests)
    theme/       light/dark ThemeData, theme provider
    widgets/     shared widgets (ComingSoon)
  features/
    shell/       app bar, bottom nav, language sheet
    clock/ calendar/ home/ profile/   placeholders
    sadhana/
      data/          Mantra model, seeds, ringtone list
      application/   Riverpod providers: session, library, completion settings,
                     rhythm pace parsing/formatting, session notices
      services/      vibration + ringtone feedback, microphone (PcmInput) and
                     voice counter, volume-button capture
      voice/         MFCC, DTW, utterance detection, match model, voice engine
                     and trainer (pure Dart, no plugins, unit-tested)
      presentation/  Sadhana screen, library, focus mode, widgets
assets/sounds/   generated completion sounds
test/            session logic, focus-mode gestures, real-Hive persistence,
                 voice DSP on synthetic signals, training store and UI
```

## Run

```sh
flutter pub get
flutter run          # Android
flutter test
```

## TODO — later phases

Clearly marked in code as `TODO(phase-2)` / `TODO(later-phase)`.

- [ ] **Backend (Supabase)**: auth, profile, sync of sessions and custom mantras
      (`lib/core/storage/app_storage.dart`).
- [ ] **Voice, future upgrades** (not built; today's Voice is the on-device
      MFCC + DTW matcher above): **Picovoice** Porcupine custom keyword models for
      better accuracy in noise and on short mantras, and counting several reps in
      one breath (subsequence matching). Cloud recognition is deliberately not
      used. See `lib/features/sadhana/services/voice_counter_service.dart`.
- [ ] **Mala, phase 2**: a true **Bluetooth smart-mala (BLE)** integration, and
      counting with the screen off / app in the background via an Android
      **foreground service** — both need the hardware and native work
      (`lib/features/sadhana/services/volume_button_service.dart`).
- [ ] **OCR**: scan a page/gutka to add a mantra or paath to the library.
- [ ] **Home-screen widgets** (Android/iOS).
- [ ] Real **Clock**, **Calendar**, **Home** and **Profile** screens.
- [ ] **Localisation**: wire the language button into `flutter_localizations`.
- [ ] Keep the screen awake during Focus mode (needs a wakelock package).
- [ ] Bundle Noto Sans Devanagari / Gurmukhi so script text renders identically on
      every device (today it uses the system fallback fonts).
- [ ] Session history, streaks and stats.
- [ ] Final package / bundle id, app icon and splash screen with the Sadho brand.
