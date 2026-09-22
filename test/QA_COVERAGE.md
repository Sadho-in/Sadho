# QA coverage inventory

Every screen, sheet, dialog, full-screen tool, onboarding step and interactive
control in `lib/`, enumerated from a walk of the whole tree. This is the
definition of "done" for the QA suite: every `[ ]` below must end up covered
by an **integration test** (`integration_test/`, marked **IT**), a **golden
test** (`test/**/golden/`, marked **G**), or both, before this file is
considered complete. Checked items name the test(s) that cover them.

Legend: **IT** = integration test (real app, real device/emulator).
**G** = golden/screenshot test (light + dark, 360×640 + 411×915, unless noted).

## 0. App root / shell

- [ ] First launch → onboarding shown, not the app shell — **IT**
- [ ] Bottom navigation: Home · Sadhana · Calendar · Clock, tap each tab — **IT**
- [ ] Tab state preserved when switching away and back (e.g. Sadhana count) — **IT**
- [ ] Top bar: language button opens the language sheet — **IT**
- [ ] Top bar: light/dark toggle flips the whole app's theme — **IT**
- [ ] Top bar: profile avatar opens Profile; back returns to the app — **IT**
- [ ] Session-notice snack bar (e.g. mic permission denied) shows, with its
      action (Settings / Train) where applicable — **IT**
- [ ] System back button, every surface (see §8) — **IT**
- [ ] App shell itself, light + dark — **G**

## 1. Onboarding (`lib/features/onboarding/`)

- [ ] Onboarding screen: title, subtitle, language list (all nine), tradition
      list (Hindu / Sikh / By place), Continue button — **G**
- [ ] Language preselected from the phone's own locale (supported code) — **IT**
- [ ] Language preselected as English (unsupported phone locale) — **IT**
- [ ] Tapping a language radio previews it live (screen re-renders in that
      language immediately) — **IT**
- [ ] Switching to a non-Latin language (e.g. Punjabi) and back to English — **IT**
- [ ] Picking a tradition, then Continue — **IT**
- [ ] Onboarding never reappears after Continue, across a relaunch — **IT**
- [ ] Onboarding reappears after Profile → Delete account clears the phone — **IT**

## 2. Home tab (`lib/features/home/`)

- [ ] Greeting + full date line, rolls over with the clock — **IT**
- [ ] Today card: Hindu / Sikh / By place switch, each showing its own lines — **IT**
- [ ] Today card: EXAMPLE tag on non-real values; sunrise/sunset carry no tag — **IT**
- [ ] Calendar-flagged cards appear on Home (Once in the morning, Keep all day) — **IT**
- [ ] Home card: swipe to dismiss (Once in the morning) + Undo snack bar — **IT**
- [ ] Home card: Keep all day is pinned, cannot be swiped — **IT**
- [ ] Tapping a Home card opens its mark in the Calendar editor — **IT**
- [ ] Paath & mantra plans: streak stat, active-plan-count stat — **IT**
- [ ] Plans: empty state + all six suggestions start a plan in one tap — **IT**
- [ ] Plans: "Add plan" opens the new-plan sheet (see §2a) — **IT**
- [ ] Plan card: Mark today done / undo, progress bar text, Completed state — **IT**
- [ ] Plan card: menu → Delete plan (confirm dialog, Cancel and Delete) — **IT**
- [ ] Home tab, light + dark, empty and populated — **G**

### 2a. New-plan sheet (modal, from Home)

- [ ] Suggestion chips fill in title/kind/days — **IT**
- [ ] Manual title entry, kind switch (Paath/Mantra), day-count chips — **IT**
- [ ] Validation: empty title, out-of-range days — **IT**
- [ ] Start plan button, back button dismisses without saving — **IT**
- [ ] New-plan sheet, light + dark — **G**

## 3. Sadhana tab (`lib/features/sadhana/`)

- [ ] Mantra card: script, transliteration, tradition tag, trained/not-trained
      tag, A−/A+ text-size stepper, Library button — **IT**
- [ ] Mantra text size: A−/A+ steps and two-finger pinch, persists — **IT**
- [ ] Combined | Separate toggle, each mode's own count preserved across it — **IT**
- [ ] Progress ring: Reset, − (undo one), + (add one), Focus — **IT**
- [ ] Mode selector: Tap, Rhythm, Voice, Mala — switching each — **IT**
- [ ] Tap mode: tapping the ring counts; +/− correct it — **IT**
- [ ] Rhythm mode: pace field + unit, counts automatically at that pace — **IT**
- [ ] Rhythm mode: invalid/empty pace input is rejected with a reason — **IT**
- [ ] Voice mode: untrained mantra prompts training before Start — **IT**
- [ ] Voice mode: Start/Pause status line, mic-denied fallback message — **IT**
- [ ] Mala mode: unsupported-platform fallback message (web/desktop) — **IT**
- [ ] Target: by count (27/108/1008/custom), by time (s/min/h) — **IT**
- [ ] Target: COUNT target reached → completion feedback fires, stop counting — **IT**
- [ ] Target: TIME target reached → completion feedback fires — **IT**
- [ ] Target reached: Reset re-opens a finished session; raising target too — **IT**
- [ ] Reset dialog (mode count in Separate, session in Combined) confirm/cancel — **IT**
- [ ] Sankalp field: typing saves the intention — **IT**
- [ ] Completion settings card: Vibration switch + intensity, Ringtone switch
      + choice + Play sound — **IT**
- [ ] Sadhana screen, light + dark, Combined and Separate — **G**

### 3a. Mantra library (`mantra_library_screen.dart`)

- [ ] Search filters the list by title/script/tradition — **IT**
- [ ] Add mantra → form sheet → Save to library, appears in the list — **IT**
- [ ] Edit an existing (including a built-in) mantra, Save changes — **IT**
- [ ] Reset a built-in mantra to default (after editing it) — **IT**
- [ ] Delete a custom mantra (built-ins cannot be deleted) — **IT**
- [ ] Tapping a mantra switches to it; switch-with-progress asks to confirm — **IT**
- [ ] Retrain-voice tooltip/button from the library row — **IT**
- [ ] Mantra library screen, light + dark, empty search and normal — **G**
- [ ] Mantra form sheet (add + edit), light + dark — **G**

### 3b. Voice training (`voice_training_screen.dart`)

- [ ] Train a mantra: record 3–7 samples, Save — **IT**
- [ ] Add more samples to already-trained mantra — **IT**
- [ ] Undo last / Start over while recording — **IT**
- [ ] Re-train (replaces all samples); Clear training (removes it) — **IT**
- [ ] Sensitivity slider (Strict/Medium/Lenient) — **IT**
- [ ] Voice training screen, light + dark, each stage (idle/recording/paused) — **G**

### 3c. Focus mode (`focus_mode_screen.dart`)

- [ ] Enter Focus mode from the main screen — **IT**
- [ ] Tap mode: tapping anywhere in Focus mode counts — **IT**
- [ ] Other modes: screen taps inert in Focus mode; +/− still work — **IT**
- [ ] Exit: hold 3 fingers for 4 seconds — **IT**
- [ ] Exit: hold the "Hold to exit" button for 4 seconds — **IT**
- [ ] System back is refused (stays open, no crash) — **IT**
- [ ] Focus mode, light + dark, Combined and Separate status line — **G**

## 4. Calendar tab (`lib/features/calendar/`)

- [ ] Month grid: previous/next month (arrows + swipe), Today button — **IT**
- [ ] Tap an empty date → New mark; tap a marked date → pick one or New — **IT**
- [ ] Mark type: Good / Cautious / Neutral (colour) — **IT**
- [ ] Icon: each of the 12 emoji, and None — **IT**
- [ ] Label + Details/notes fields — **IT**
- [ ] Reminder mode: No time / One time (time picker) / Several times (add,
      remove, up to 8) — **IT**
- [ ] Repeat: Once, Daily, Weekly, Monthly, Quarterly, Half-yearly, Yearly — **IT**
- [ ] Home-screen option: Don't show / Once in the morning (+ time) / Keep all
      day — **IT**
- [ ] Save → mark appears on the grid and (if flagged) on Home — **IT**
- [ ] Edit an existing mark; editing a repeat affects every occurrence — **IT**
- [ ] Delete a mark: confirm dialog (one-off vs "and all its repeats" text) — **IT**
- [ ] Notifications-off warning shown when permission refused, mark still saved — **IT**
- [ ] Mark style picker: Dot / Filled / Highlight / Circle / Square — **IT**
- [ ] Mark legend + today's accent dot — **IT**
- [ ] Month's mark list (cards) below the grid — **IT**
- [ ] Calendar screen, light + dark, empty and populated month — **G**
- [ ] Mark editor sheet (new + edit), light + dark — **G**
- [ ] Mark style picker, light + dark — **G**

## 5. Clock tab (`lib/features/clock/`)

- [ ] Tool list: five tools, live status line under the active ones — **IT**
- [ ] Each tool opens full-screen and its close button returns to the list — **IT**

### 5a. Clock (`big_clock_page.dart`)

- [ ] Live time updates, correct layout upright vs sideways — **IT**
- [ ] Big Clock screen, light + dark — **G**

### 5b. Sun-based alarm (`sun_alarm_page.dart`)

- [ ] On/off switch (asks notification permission on first enable) — **IT**
- [ ] Sunrise ⟷ Sunset segmented switch — **IT**
- [ ] Quick offsets (each preset) and Custom offset (minutes + Before/After) — **IT**
- [ ] Computed alarm time / today's sunrise+sunset / location line — **IT**
- [ ] "Use my location" button; Settings shortcut when blocked — **IT**
- [ ] Sun-based alarm screen, light + dark, on and off — **G**

### 5c. World clock (`world_clock_page.dart`)

- [ ] All seven cities render with time, day label, relative-time label — **IT**
- [ ] World clock screen, light + dark — **G**

### 5d. Sadhana & vrat timer (`timer_page.dart`)

- [ ] Each preset (Aarti/Chalisa/Path/Havan) + Vrat → sunset — **IT**
- [ ] Start / Pause / Resume / Reset — **IT**
- [ ] Vrat note: sunset time + location; "counting to tomorrow's" case — **IT**
- [ ] Timer reaching zero: completion feedback fires — **IT**
- [ ] Timer screen, light + dark, idle/running/finished — **G**

### 5e. Paath stopwatch (`stopwatch_page.dart`)

- [ ] Start / Stop, Lap (while running) / Reset (while stopped) — **IT**
- [ ] Lap list: newest first, Fastest/Slowest tags from 3+ laps — **IT**
- [ ] Keeps running after leaving and reopening the screen — **IT**
- [ ] Stopwatch screen, light + dark, empty and with laps — **G**

## 6. Profile (`lib/features/profile/`)

- [ ] Profile completion card: percentage, five steps, reward note at 100% — **IT**
- [ ] Your details: edit Name/Email, Save, validation (bad email, long name) — **IT**
- [ ] Theme: five palettes (Marigold/Sandalwood/Tulsi/Twilight/Lotus) — **IT**
- [ ] Theme: Light / Dark / System modes — **IT**
- [ ] Language card: opens the language sheet, shows the current language — **IT**
- [ ] Daily reminder: on/off (asks permission), time picker — **IT**
- [ ] Sadhana settings: Combined/Separate control (same as §3) — **IT**
- [ ] Backup & restore: Export writes a file — **IT**
- [ ] Backup & restore: Restore — bad file, damaged, valid (confirm → applied) — **IT**
- [ ] Cloud sync row shown disabled ("Coming later") — **IT**
- [ ] Account: Change password sheet (validation, submit, "will work later") — **IT**
- [ ] Account: Sign out (no account yet → explanatory message) — **IT**
- [ ] About: app name, website, version — **IT**
- [ ] Danger zone: Delete account → Are you sure? No (cancels) and Yes (wipes,
      reloads to onboarding) — **IT**
- [ ] Profile screen, light + dark, scrolled to top and to Danger zone — **G**
- [ ] Change-password sheet, light + dark — **G**
- [ ] Restore-confirmation dialog, light + dark — **G**
- [ ] Delete-account confirmation dialog, light + dark — **G**

## 7. Language switching (cross-cutting)

- [ ] Switch language via top bar sheet to a non-Latin language, UI re-renders — **IT**
- [ ] Switch language via Profile's Language card — **IT**
- [ ] Switch back to English — **IT**
- [ ] Gurmukhi/Tamil script actually renders (covered already in
      `test/l10n/localization_test.dart`, referenced not duplicated) — **IT**

## 8. System back button (every surface — must never crash)

- [ ] A root tab (Home/Sadhana/Calendar/Clock): standard app-exit behaviour — **IT**
- [ ] The language sheet — **IT**
- [ ] A Clock full-screen tool — **IT**
- [ ] Focus mode (must be refused, stay open) — **IT**
- [ ] A calendar day sheet — **IT**
- [ ] A dialog (e.g. Delete plan?) — **IT**
- [ ] Nested: a sheet opened from a pushed page (Profile → password sheet) — **IT**
- [ ] Mid-async-save (the sheet closes once, not twice) — **IT**

*(§8 already has strong coverage in `test/shell/back_button_test.dart`; the
integration-test pass in Step B adds the same surfaces end-to-end, on the
real app, rather than re-deriving it from scratch.)*
