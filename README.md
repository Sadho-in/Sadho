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
- **Calendar** and **Home** are real screens (below). Clock is still a
  placeholder ("Coming soon"). Profile is a placeholder too, but already hosts
  **Sadhana settings** (the Count setting below).
- The language button saves your choice (English / हिन्दी / ਪੰਜਾਬੀ); actual
  translations come later.

**Calendar**

Local only (Hive, no backend). Marks you make are saved on the phone, restored on
relaunch, and their reminders are rebuilt every time the app starts.
- **Month grid** (`table_calendar`) with previous / next month (arrows or a swipe)
  and a *Today* button. Tap a date to open the editor.
- **Editor** for a date (a date can hold several marks; pick one or *New mark*):
  - **Mark type**: Good / Cautious / Neutral, drawn green / red / amber.
  - **Icon**: 🕉 ☬ 📿 🪔 🔔 🌅 ⭐ ✦ 💰 🤝 🚫 ✅ (or none), shown on the date and on
    the mark's card.
  - **Label** (40 characters) and **Details / notes** (500).
  - **Remind me at**: *No time*, *One time* (a time picker, default 9:00) or
    *Several times* (add and remove up to 8 times).
  - **Repeat**: Once, Daily, Weekly, Monthly, Quarterly, Half-yearly, Yearly. A
    repeat is one mark that comes back (editing or deleting it affects every
    repeat). A monthly mark on the 31st falls on the last day of shorter months;
    a Feb 29 yearly mark falls on Feb 28 in other years.
  - **On your home screen**: *Don't show*, *Once in the morning* (with a time) or
    *Keep all day*.
- **Mark display style** (one choice for every mark, saved): **Dot**, **Filled**
  (the date on a solid circle), **Highlight** (a light tint behind the date),
  **Circle** or **Square**. Each style draws the mark in its own colour WITH a
  darker outline of the same hue. Several marks on one date: Dot shows a dot per
  kind, the other styles use the most severe (Cautious, then Good, then Neutral).
- **Today** is shown separately from marks: a bold number and a small dot in the
  theme's accent (indigo / lavender), which is never a mark colour.
- A legend, and a list of the month's marks as cards (a repeating mark is one card).

**Home**
- Shows today's cards for the marks flagged for the home screen, using the same
  card as the Calendar (emoji, label, notes, tags, colour stripe).
- **Once in the morning** cards appear at their time and **swipe away for the
  day** (with Undo); they come back on the next date the mark repeats.
- **Keep all day** cards are **pinned**: they stay all day and cannot be swiped.
- Tap a card to edit its mark. The clock is watched while the app is open, so a
  card appears at its time and the day rolls over at midnight by itself.

**Reminders** (`flutter_local_notifications` + `timezone` + `flutter_timezone`):
local notifications, no server, working offline.
- Daily and weekly reminders are ONE repeating alarm each (so they keep ringing
  without opening the app, and stay at the same wall-clock time across daylight
  saving). Monthly, quarterly, half-yearly and yearly reminders are scheduled as
  the next dates individually (monthly: the next 12, quarterly 8, half-yearly 6,
  yearly 5) and topped up every time the app starts or the mark changes.
  If you did not open the app for longer than that window, they stop until you do.
- Nothing is ever scheduled in the past or before a mark's first date.
- The notification permission is requested when you first save a reminder. If it
  is refused, the mark is still saved and you are told the reminder will not ring.
- Android rings at the exact minute when exact alarms are allowed for the app and
  otherwise a little flexibly (it falls back on its own). Reminders survive a
  reboot. iOS is configured (permission, notification delegate) but has not been
  built or tried; iOS keeps at most 64 pending notifications in total.

**Sadhana — Japa & Paath counter**

*Screen layout.* Everything you need to count fits **above the fold** (no
scrolling, checked by tests on 360×640 up to 411×915 phones, at the default text
size): a **mantra card** (script, name, transliteration, small tradition and
"Voice trained / not trained" tags, a small *Library* button and an **A− / A+**
text-size stepper); directly under it the slim **Combined | Separate** toggle
(just the two options, no label); the **progress ring**; **one row** of four
controls (Reset, − undo, + count, Focus); and the primary **Start / Pause /
Resume** button with a one-line mode status. The ring shrinks on short screens,
and when the mantra card grows, to make this fit; if the card is very tall (a
long verse at a large size) the ring stays at its minimum and the page simply
scrolls, so nothing overflows. **Below, in the scroll area**: the mode selector (with the chosen
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
- **Mantra text size** — the mantra's script, transliteration and name are drawn
  at 0.8× to 2.0× of their base size (default **1.3×**, comfortably larger than
  the base). Change it with the **A− / A+** buttons on the mantra card (0.1× a
  step) or by **pinching the card with two fingers** (it follows your fingers and
  is saved when you let go; one finger still scrolls the page and a tap still
  opens the Library). The size is saved in Hive and used everywhere the mantra is
  shown: the Sadhana card and **Focus mode** (which now also shows the
  transliteration). The text wraps instead of being cut off, so the card grows
  with it. The tags, buttons and library list keep their size.
- **Combined | Separate** — a persisted setting that says how the four
  modes relate. It is a slim control under the mantra card with just the two
  options, and the same setting (with an explanation) is in Settings (Profile
  tab).
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
  - Vibration: 5 intensity levels. A single-pulse buzz every **108 counts** and
    a stronger completion buzz at the target. On a phone that can set vibration
    *strength* (Android amplitude via the `vibration` package) the level is the
    strength and the completion buzz is a stronger double pulse. Many phones
    (some Samsung models, e.g. the Galaxy A23) cannot: there a level is the
    *length* of the buzz (200 ms at level 1 up to 520 ms at level 5) and the
    completion buzz is three long pulses (about 1.5 to 3.3 s), so it is clearly
    felt and clearly different from a milestone. Vibrations use Android's
    *alarm* usage, so they are not held back by silent mode.
  - Ringtone: four bundled sounds (temple bell, singing bowl, soft chime, deep
    gong) played with `audioplayers` at the target, on/off independent of
    vibration. **The sound plays on the alarm stream**, so it follows the phone's
    *alarm* volume and is not silenced by a muted *media* volume (a phone with
    its media volume at 0 used to play the bell inaudibly). It briefly ducks other
    audio instead of stopping it. If the phone's alarm volume is 0 it is silent.
  - Both fire when a count target OR a time target is reached, in every counting
    mode and in both Combined and Separate (in Separate, when the active mode
    reaches its own target). The milestone counts the count you see: all modes
    together in Combined, the active mode's own in Separate. Tested end to end
    (`test/sadhana/completion_feedback_test.dart`) with a fake vibrator and speaker.
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
`permission_handler` · `volume_button_listener` · `table_calendar` ·
`flutter_local_notifications` · `timezone` · `flutter_timezone`. MFCC and DTW are
implemented in Dart in this repo (`lib/features/sadhana/voice/`).

**Permissions**: Android `RECORD_AUDIO`, `POST_NOTIFICATIONS`,
`RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM` (+ `VIBRATE`; `INTERNET` is only
for Google Fonts); iOS `NSMicrophoneUsageDescription`. Voice needs no speech
recognition permission or service. The Android build enables core-library
desugaring and registers the plugin's alarm and boot receivers (required by
`flutter_local_notifications`).

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
    clock/ profile/   placeholders (Profile hosts the Sadhana settings)
    calendar/    marks (data), Hive store + providers, reminder planner and
                 notification scheduler, month grid, editor, mark styles
    home/        today's cards
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
                 voice DSP on synthetic signals, training store and UI;
                 test/calendar: recurrence, reminder planning, marks store,
                 month grid + styles, editor, Home cards, end-to-end flows
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
- [ ] Real **Clock** and **Profile** screens.
- [ ] **Calendar, later**: sync marks with the backend, an end date for repeats,
      and (if wanted) tithi / panchang data.
- [ ] **Localisation**: wire the language button into `flutter_localizations`.
- [ ] Keep the screen awake during Focus mode (needs a wakelock package).
- [ ] Bundle Noto Sans Devanagari / Gurmukhi so script text renders identically on
      every device (today it uses the system fallback fonts).
- [ ] Session history, streaks and stats.
- [ ] Final package / bundle id, app icon and splash screen with the Sadho brand.
