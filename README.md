# Sadho

A devotional companion app — **Sadho** (sadho.in). The Flutter project folder
and Dart package are still `advance_calendar` (that name is internal only); the
Android/iOS display name and the in-app title are **Sadho**.

> **The app ID is permanent: `in.sadho.app`.** It is the Android
> `applicationId` (android/app/build.gradle.kts) and the iOS bundle identifier
> (ios/Runner.xcodeproj). Once the app is uploaded to Google Play or the App
> Store it can NEVER change: a different ID is a different app, with no
> updates, reviews or installs carried over. Do not rename it. The Kotlin
> package (android/app/src/main/kotlin/in/sadho/app) and the Android
> `namespace` match it; the Dart package name does not need to.

## App icon

Everything comes from four files in `assets/branding/`:
`icon-1024.png` (full icon, iOS and legacy Android), `icon-foreground.png`
(adaptive foreground, artwork inside the safe zone, transparent),
`icon-monochrome.png` (silhouette for the Android 13 themed icon, transparent)
and `notification-icon.png` (white silhouette, transparent). The adaptive
background colour is indigo `#4B4691` (the `flutter_launcher_icons:` block in
`pubspec.yaml`); notifications use the saffron accent `#FF9933`.

**To change the logo: replace the 4 files in assets/branding/, run
`dart run flutter_launcher_icons`**, then `dart run tool/notification_icon.dart`
for the notification small icon (`res/drawable-*/ic_stat_sadho.png`, used by
every notification). `flutter_launcher_icons` also edits
`ios/Runner.xcodeproj/project.pbxproj` (it changes
`ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS` to `AppIcon`);
discard that change with `git checkout ios/Runner.xcodeproj/project.pbxproj`.
The same logo is shown on the first-launch screen and in Profile > About.

## Phase 1 — what is delivered

**App shell**
- Material 3, warm devotional theme: marigold `#DE8517`, deep indigo `#4B4691`,
  warm off-white `#FBF7F0`. Full light **and** dark themes, switchable at
  runtime (choice is saved). Fraunces for headings, Karla for body text.
- Bottom navigation: **Home · Sadhana · Calendar · Clock** (Home leftmost, and
  the screen the app opens on). Top bar with a
  language button, a light/dark toggle and a profile avatar.
- **Home**, **Calendar** and **Clock** are real screens (below), and so is
  **Profile** (opened from the avatar in the top bar; it shows your initial once
  you have set a name).
- The language button offers all nine supported languages and applies your
  choice across the whole app immediately (see Localization below).

**Clock**

A list of five tools; each opens **full-screen** (a full-screen dialog route with
a close button).
- **Clock** — a large live time (seconds, AM/PM or 24-hour following the phone),
  the full date and the zone name. Upright, the hours and minutes fill the width
  and the seconds sit beneath; sideways it is one line.
- **Sun-based alarm** — an on/off switch, a **Sunrise ⟷ Sunset** switch, quick
  offsets (*1 hr / 45 / 30 / 15 min before, At sunrise|sunset, 15 / 30 min after*)
  and a **Custom** offset (any minutes, 0–1440, before or after). The screen shows
  the computed alarm time (and which day), today's sunrise and sunset, and where
  they are measured. Turning it on asks for notification permission.
  - *Sun times* are computed on the device with the NOAA solar algorithm
    (`lib/features/clock/data/sun_times.dart`, pure Dart), checked against known
    sunrise/sunset times for London, New York, Sydney, Delhi and Mumbai (within
    about 3-4 minutes). No network, no API.
  - *Location*: `geolocator` (approximate/low accuracy is enough). Without
    permission the app uses **Amritsar** and says so ("Using Amritsar. Allow
    location for exact times."). Permission is only asked when you press **Use my
    location** (never by surprise); the last position is saved and used next
    time; if location is blocked in Settings the button opens Settings.
  - *Recomputed daily*: the alarm follows the sun, so its time changes every day.
    The app schedules the next **30 days** as one local notification each (via
    `flutter_local_notifications`, alarm-category channel `alarms_timers`) and
    schedules them again whenever it opens or returns to the front, and when the
    setting or the location changes. Beyond 30 days without opening the app the
    alarm stops until the app is opened once.
- **World clock** — a fixed example list (Amritsar, Haridwar, London, Dubai, New
  York, Toronto, Sydney) with each city's time, "Today / Tomorrow / Yesterday" and
  how far ahead/behind you it is. Uses IANA zones, so daylight saving is right.
- **Sadhana & vrat timer** — presets **Aarti 5 min, Chalisa 11, Path 21, Havan
  30**, and **Vrat → sunset**, which counts down to the next sunset at your
  location (today's, or tomorrow's with a note once it has passed). Start / Pause
  / Resume / Reset. It runs on a fixed end time, so it stays right in the
  background. At zero it **vibrates and rings** through the same completion
  feedback as Sadhana (Completion settings, alarm stream). A notification is also
  scheduled for the end, so it rings if the app is closed; when the screen sees
  zero it cancels that notification so there is only one ring.
- **Paath stopwatch** — Start / Stop / Lap / Reset with hundredths, and a lap
  list (newest first, lap time and total; fastest/slowest marked from 3 laps). It
  keeps running when you leave the screen.

The list shows a live one-liner under a tool that is doing something (alarm on,
timer counting, stopwatch running).

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

**Home** (the dashboard)
- **Greeting and today line**: "Good morning, Asha" (by the hour; your first name
  once you have set one in Profile) and the full date. The clock is watched while
  the app is open, so the greeting and the day roll over by themselves.
- **Today card** with a **Hindu / Sikh / By place** switch (saved). Hindu shows
  tithi, nakshatra, Rahu Kaal and Abhijit muhurat; Sikh shows the Hukamnama
  (Ang), Nitnem due, sunrise and the next Gurpurab; By place shows sunrise,
  sunset, a local festival and an auspicious window.
  **Only sunrise and sunset are real** (worked out on the phone for its place, as
  in the Clock tab). **Everything else is an EXAMPLE value**, tagged EXAMPLE on
  screen and listed in `ExampleValues` (`lib/features/home/data/tradition.dart`).
  TODO(later-phase): wire real panchang, Hukamnama, Nitnem, Gurpurab and festival
  data.
- **Calendar cards**: today's cards for the marks flagged for the home screen,
  using the same card as the Calendar (emoji, label, notes, tags, colour stripe).
  **Once in the morning** cards appear at their time and **swipe away for the
  day** (with Undo); **Keep all day** cards are **pinned** and cannot be swiped.
  Tap a card to edit its mark.
- **Paath & mantra plans**: set a paath or mantra for N days (1 to 365), from a
  suggestion (Hanuman Chalisa 40 days, Japji Sahib 40, Sukhmani Sahib 11, Gayatri
  Mantra 21, Om Namah Shivaya 108, Waheguru 21) or your own name, kind and number
  of days. Each plan has a progress bar ("3 of 21 days"), a **Mark today done**
  button (tap again to undo) and a delete option (asks first). A finished plan
  says Completed and takes no more days. A **daily streak** counts the days in a
  row on which at least one plan was marked done (it stays alive until the day
  ends, so it does not show 0 first thing in the morning), next to the number of
  **active plans**. Saved in Hive. Days are marked by hand for now;
  TODO(later-phase): count a day automatically from Sadhana sessions.

**Profile** (avatar in the top bar)
- **Profile completion**: a percentage in five equal steps (name, a valid email,
  a tradition picked on Home, the daily reminder on, a first plan), the steps
  still missing, and a note: at 100% "your free premium reward will be waiting
  when premium launches". There is no premium yet; nothing is unlocked.
- **Your details**: editable Name and Email (email optional, checked if given),
  saved on the phone. TODO(auth): they come from the account once sign-in exists.
- **Theme**: five soothing colour palettes, each with a light and a dark form,
  chosen so all text stays readable (contrast is tested): **Marigold** (the
  original), **Sandalwood**, **Tulsi green**, **Twilight indigo**, **Lotus rose**;
  plus **Light / Dark / System**. Both are saved and apply to the whole app at
  once (`lib/core/theme/palettes.dart`).
- **Language**: the same chooser as the top bar, all nine supported languages;
  the choice is saved and applied right away (see Localization below).
- **Daily reminder**: a switch and a time (default 6:00 AM). It is ONE repeating
  local notification (an ordinary, not alarm-loud, one), scheduled again every
  time the app starts. Turning it on asks for the notification permission.
- **Sadhana settings**: the Combined / Separate count setting.
- **Backup & restore**: *Export* writes one JSON file with everything saved on the
  phone (marks, plans, custom and edited mantras, voice-training numbers, profile
  and settings) to a place you choose; *Restore* reads such a file, checks it
  first (a file that is not a Sadho backup, is damaged, or comes from a newer
  Sadho is refused with a plain message and nothing changes), asks to confirm,
  replaces the phone's data and reloads the app. Uses the system file dialogs
  (`file_picker`). **Cloud sync** is shown as "Coming later" (TODO phase-2).
- **Account**: *Change password* checks your entries but does nothing yet, and
  says so; *Sign out* says there is no account to sign out of yet.
  TODO(auth): both become real with accounts (Supabase).
- **About**: Sadho, sadho.in, version (kept equal to `pubspec.yaml`; a test
  checks it).
- **Danger zone** (red, at the bottom): **Delete account** asks "Are you sure?
  Yes / No". Only Yes does anything: it erases everything saved on this phone
  (profile, plans, marks, mantras, voice training, settings), cancels every
  scheduled notification and reloads the app. There is no server account to
  delete yet (TODO(auth)).

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
"Voice trained / not trained" tags, the **A− / A+** text-size stepper in the
**top-right** corner and a small *Library* button in the **bottom-right** corner,
with a gap between them); directly under it the slim **Combined | Separate** toggle
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
  - **Mala** — hardware **volume-button** counter. Press Start, then every
    volume Up/Down press adds one count; the volume never changes. On Android
    it **counts with the screen off** (see "Mala with the screen off" below);
    elsewhere, or with that switched off, `volume_button_listener` counts while
    the app is on screen. Keys go back to normal when you pause, finish or
    switch mode. Great for eyes-closed or in-pocket counting.
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
    (`test/sadhana/completion_feedback_test.dart`, `time_target_test.dart`) with a
    fake vibrator and speaker.
  - **Time targets** are measured against the real clock, not just against the
    app's one-second timer, because a phone with the screen off can stop that
    timer for minutes. When the target time is reached with the app running, it
    vibrates and rings once. If the phone was locked, a notification (alarm
    channel, set just after the end time) rings instead, and the session catches
    up as soon as the app is back; the app then stays quiet so it never rings
    twice. If the notification could not be set (permission refused) the app
    rings when it is back, unless that is hours later. Turning on a time target
    run asks for the notification permission the first time.
  - **Tap after the target**: in Tap mode every extra tap still gives a short
    vibration tick (50 ms at level 1 up to 90 ms at level 5; no sound), on every
    tap, while Vibration is on, and the count stays at the target. Other modes'
    inputs are ignored silently.
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

## Localization

The whole app (shell, Sadhana, Calendar, Clock, Home, Profile, first-launch
onboarding) is localized via `flutter_localizations` + `intl`, generated with
`flutter gen-l10n` from ARB files in `lib/l10n/`. Generated output
(`app_localizations*.dart`) is committed to git — `flutter analyze`/`flutter
test` do not regenerate it, so run `flutter gen-l10n` by hand after any ARB
edit.

- `app_en.arb` is the template and the source of truth: every key, with a
  `description` for translators. English is written and reviewed directly in
  this file, not translated.
- `app_hi.arb`, `app_pa.arb`, `app_mr.arb`, `app_bn.arb`, `app_gu.arb`,
  `app_ta.arb`, `app_te.arb`, `app_kn.arb` (Hindi, Punjabi, Marathi, Bengali,
  Gujarati, Tamil, Telugu, Kannada) are a **first-pass machine translation**,
  generated in one pass for i18n Step 4. **They have not been reviewed by a
  native speaker of each language** — treat every one as needing review before
  depending on it in production. Each file marks itself as such in an
  `"@@x-machine-translation"` note at the top (an informational `@@` key gen-l10n
  ignores; it is not part of the generated API).
- Mantra/Gurbani script, transliteration text, plan-suggestion titles and the
  Home tab's EXAMPLE panchang placeholder values are deliberately **not**
  translated anywhere — they are proper-noun/scripture content, not UI chrome.
- First launch shows a language + tradition picker
  (`lib/features/onboarding/`); the language preselects the phone's own locale
  when it is one of the nine, else English. Both choices can be changed again
  later in Profile.

## Tech

Flutter (stable) · Dart · Material 3 · `flutter_riverpod` · `hive` /
`hive_flutter` · `vibration` · `audioplayers` · `google_fonts` ·
`record` (PCM16 16 kHz microphone stream) · `fftea` (FFT) ·
`permission_handler` · `volume_button_listener` · `table_calendar` ·
`flutter_local_notifications` · `timezone` · `flutter_timezone` · `geolocator` ·
`intl` · `file_picker`. MFCC and DTW are
implemented in Dart in this repo (`lib/features/sadhana/voice/`).

**Permissions**: Android `RECORD_AUDIO`, `ACCESS_COARSE_LOCATION`, `POST_NOTIFICATIONS`,
`RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM` (+ `VIBRATE`; `INTERNET` is only
for Google Fonts), `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_SPECIAL_USE` (Mala
with the screen off), `ACCESS_NOTIFICATION_POLICY` (quiet mode); iOS `NSMicrophoneUsageDescription` and `NSLocationWhenInUseUsageDescription`. Voice needs no speech
recognition permission or service. The Android build enables core-library
desugaring and registers the plugin's alarm and boot receivers (required by
`flutter_local_notifications`).

### Mala with the screen off (Android)

Lock the phone and keep pressing a volume key: every press counts, and the
phone rings at your target.

- **How it works.** Start in Mala mode starts a native **foreground service**
  (`MalaCounterService.kt`) that runs only while that Mala session runs. It
  holds an active `MediaSession` set to "playing" with **remote playback**
  through a `VolumeProviderCompat` (relative volume). Android then sends the
  hardware volume keys to it, even with the screen off, and each key press is
  one count. The real volume never changes, no audio is played (no silent-audio
  trick), and with the app on screen the keys go straight to the service, so
  no volume panel appears.
- **The service owns the count while it runs** (it works even if Flutter is
  paused or its engine is gone): count, target, session id and the Mala bucket
  are kept in SharedPreferences. A held key counts once (auto-repeat is
  ignored) and counts are at least 120 ms apart. An ongoing notification shows
  "Mala · 54 / 108" live, with Pause/Resume and Stop.
- **It is the ONLY Mala counter** while it runs (screen on or off), so nothing
  counts twice. Counts go to the Mala bucket in Combined and Separate. The 108
  milestone buzz still comes (from the service's own vibration when the app is
  in the background). Pause, Reset, another mode or mantra, and a raised target
  stop it; the notification's Pause/Stop update the app. On return or relaunch
  the app catches up from the service, capped at the target.
- **At the target**: with the app in the background the service posts the same
  alarm-style notification as the Sadhana finish alarm (its channel, ringtone,
  vibration, "Until stopped" = insistent, full screen over the lock screen,
  opening the small "finished" screen, alarm group `mala`). With the app on
  screen the in-app alert plays instead. It never rings twice. After the target
  a press only gives a short tick, and the service gives the keys back 10
  minutes later if nobody stops it.
- **Settings**: "Count with the screen off" in the Mala panel (on by default,
  Android only). The first screen-off session explains it once, with a button
  to Alarms & reliability. If the service cannot start, the app says so once
  and counts with `volume_button_listener` while it is on screen.
- **Limits.** Set Sadho's battery use to **Unrestricted** (some phones, Samsung
  especially, stop background work otherwise). Music or a video playing at the
  same time takes the volume keys back (it is the more recent media session),
  and some phones show a small volume panel when the screen is on and another
  app is in front. The service starts only while Sadho is on screen (Android 12+
  rule); if the phone kills Sadho completely, counting stops, and the count so
  far is kept. Not available on iPhone (iOS cannot receive volume keys in the
  background); no Bluetooth malas yet.

### Quiet mode during sadhana (Android)

"Silence other notifications during a session" in the Completion card (off by
default). When on, starting a session sets the phone's Do Not Disturb to
**alarms only**, so Sadho's own completion alarm still rings. Pausing,
finishing, resetting, leaving the Sadhana screen or switching it off puts the
user's own setting back; the setting is saved before it is changed, so if Sadho
is killed mid-session it is restored at the next start. It needs **Do Not
Disturb access** (Notification Policy access): turning the switch on without it
explains why once and opens the phone's page to allow it, and Alarms &
reliability shows a row for it while the switch is on. Sadho never changes Do Not
Disturb without that access, leaves it alone if you were already on alarms only
or total silence, and does not undo a change you made yourself during the
session. It applies to sessions that are started (Rhythm, Voice, Mala and time
targets); a Tap count target has no Start, so it is not silenced.

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
   long verses; a length cap drops sentences). **Voice-activity detection**: a
   loud frame can start an utterance only if it also sounds like voice (few
   zero crossings and a peaky, harmonic spectrum: low spectral flatness), so
   breaths, a clatter or a fan never start one; the noise floor adapts to the
   room (it follows quiet frames and rises slowly under steady non-voice
   noise). Each candidate is **loudness-normalised** before MFCC, and matched on
   MFCCs **plus deltas and delta-deltas** (how the sound is changing), with
   cepstral mean (and variance) normalisation per utterance; the quiet lead-in
   and tail are trimmed so only the voiced part is compared. Templates are
   still stored as the 13 static MFCCs, so older trainings keep working. Each candidate is compared with
   every template using **DTW** (dynamic time warping, so a slightly faster or
   slower chant still matches). If the best distance is under an **adaptive
   threshold** the rep counts **immediately**. The threshold comes from how much
   *your* recordings vary among themselves, scaled by the Sensitivity slider and
   kept inside fixed bounds. Everything runs per utterance on the phone's CPU.
   **Several repetitions in one breath**: when an utterance is about N times the
   trained length (N = 2 to 4) and is not one match, it is cut into N parts at
   its quietest moments near the expected boundaries, and if every part matches,
   N counts are made.
   **Calibration**: right after training (and any time from the Voice panel,
   *Calibrate*), "Chant your mantra 11 times now". Sadho first listens to 2 s of
   room sound, then shows each repetition as it is heard, and sets the threshold
   so all 11 count and the room's noise does not (a third of the way from the
   loudest repeat toward the nearest noise). It is saved with the training and
   cleared when the recordings change; the Strict ↔ Lenient slider moves it,
   with the middle exactly at the calibrated value. No audio is kept.
3. **Offline and private**: no network, no cloud, no speech service; the
   microphone is only open while Voice is listening or training.

**Limits — this is a Beta.**
- **Accuracy improves with more recordings** (up to 7; 5 beats 3), and with
  recordings made the way you will actually chant (same speed, same distance from
  the phone). If it misses you, use **Add more samples** rather than starting over.
- **Accuracy degrades in noise**: a noisy room, TV or other people chanting can
  cause missed or false counts. Strict misses more, Lenient counts more strangers.
- **Leave a short pause between repetitions** where you can. Up to 4 repeats in
  one breath are split and counted; more than that in one unbroken breath is
  dropped as too long (use Tap, Rhythm or Mala for very fast japa).
- **Calibrate** in the room and at the pace you will actually chant; re-run it
  if the room or the phone changes.
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
    shell/       app bar, bottom nav (Home · Sadhana · Calendar · Clock), language sheet
    profile/     name/email, completion, theme, reminder, backup/restore,
                 account and danger-zone screens + their providers/services
    clock/       data/ (sun times, sun alarm, tools, cities, timer presets),
                 application/ (location, sun alarm, timer, stopwatch, clock
                 source), services/ (location, time zones), presentation/
                 (tool list + the five full-screen tools)
    calendar/    marks (data), Hive store + providers, reminder planner and
                 notification scheduler, month grid, editor, mark styles
    home/        dashboard: greeting, Today card (tradition), calendar cards,
                 paath & mantra plans
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
                 month grid + styles, editor, Home cards, end-to-end flows;
                 test/clock: sun maths, sun alarm, location, timer, stopwatch,
                 world clock and every Clock screen (run in several time zones);
                 test/home, test/profile, test/shell: dashboard, plans and streak,
                 palettes (contrast), profile screen, backup, delete, tab order
```

## Run

```sh
flutter pub get
flutter run          # Android
flutter test
```

## Release notes (Play Console)

**Foreground service (specialUse) declaration — Mala with the screen off.**
The manifest declares `MalaCounterService` with
`foregroundServiceType="specialUse"` and the subtype
"Counts mala repetitions from hardware volume-key presses while the screen is
off, and rings when the user's target is reached (hands-free japa counter)."
Before uploading a build with it, in Play Console → App content → **Foreground
service permissions**:
1. Tick **Special use** and paste the same description.
2. Explain the user benefit: hands-free counting of japa/mala repetitions with
   the phone locked (eyes closed, phone in a pocket); it runs only while the user
   has started a Mala session, shows an ongoing notification with the count and
   Pause/Stop, and stops when the session is paused, reset or finished.
3. Add a **demo video** (a short screen recording, e.g. unlisted YouTube): choose
   Mala, press Start, lock the phone, press a volume key several times, unlock and
   show the count and the notification "Mala · n / target", then reach a small
   target (e.g. 5) with the screen off and show it ringing.

**Do Not Disturb (quiet mode)** uses `ACCESS_NOTIFICATION_POLICY`, a normal
permission the user grants on the phone's "Do Not Disturb access" page; no Play
Console declaration is needed for it.

## QA

integration_test/ is parked and not run. QA is device-free (flutter test only).

## TODO — later phases

Clearly marked in code as `TODO(phase-2)` / `TODO(later-phase)`.

- [ ] **Backend (Supabase)**: auth, profile, sync of sessions and custom mantras
      (`lib/core/storage/app_storage.dart`).
- [ ] **Voice, future upgrades** (not built; today's Voice is the on-device
      MFCC + DTW matcher above): **Picovoice** Porcupine custom keyword models for
      better accuracy in noise and on short mantras, and counting several reps in
      one breath (subsequence matching). Cloud recognition is deliberately not
      used. See `lib/features/sadhana/services/voice_counter_service.dart`.
- [ ] **Mala, phase 2**: a true **Bluetooth smart-mala (BLE)** integration
      (needs the hardware). Screen-off counting on Android is done (P5).
- [ ] **OCR**: scan a page/gutka to add a mantra or paath to the library.
- [ ] **Home-screen widgets** (Android/iOS).
- [ ] **Profile, later**: real accounts (sign-in, working sign-out, change
      password, delete on the server) and premium; the profile fields then come
      from the account.
- [ ] **Home, later**: real panchang and Sikh calendar data, and counting a
      plan's day automatically from Sadhana sessions.
- [ ] **Clock, later**: a user-editable world-clock city list, a sun alarm that
      keeps ringing past 30 days without opening the app (a background job), an
      immersive/keep-awake big clock, and stopwatch/timer in a notification.
- [ ] **Calendar, later**: sync marks with the backend, an end date for repeats,
      and (if wanted) tithi / panchang data.
- [ ] **Localisation**: native-speaker review of the 8 machine-translated
      languages (see Localization section below); onboarding tradition options
      for non-Hindu/Sikh traditions.
- [ ] Keep the screen awake during Focus mode (needs a wakelock package).
- [ ] Bundle Noto Sans Devanagari / Gurmukhi so script text renders identically on
      every device (today it uses the system fallback fonts).
- [ ] Session history, streaks and stats.
- [ ] Final package / bundle id, app icon and splash screen with the Sadho brand.
