# Play Console declarations — draft texts and demo-video scripts

Each video: about 30 seconds, screen recording of a real phone (English UI),
uploaded unlisted (e.g. YouTube), link pasted into the declaration.

---

## 1. Exact alarms — `USE_EXACT_ALARM`

**Core functionality:** Alarm clock and calendar reminders.

**Text:**
Sadho is an alarm clock and calendar app for daily devotional practice. Its
core features are a sun-based alarm clock (it rings at sunrise/sunset or a set
offset from it, recalculated every day), timers (the Sadhana & vrat timer and
the Sadhana session timer, which must ring at the exact second the time is up,
with the screen off or the app closed) and calendar event reminders set by the
user for specific times. These are user-set alarms that must fire at an exact
time, so the app uses exact alarms (AlarmManager setAlarmClock). The app does
not use exact alarms for anything else.

**Demo video script (30 s):**
1. (0–8 s) Open Sadho > Clock > Sun-based alarm, switch it on, pick "At sunrise",
   show the computed alarm time.
2. (8–16 s) Clock > Sadhana & vrat timer: choose a 1-minute custom timer, Start,
   lock the phone.
3. (16–24 s) The timer rings at the exact second, full screen over the lock screen.
4. (24–30 s) Calendar: add a reminder "Ekadashi fast" at a time 1 minute ahead;
   show the notification arriving on time.

---

## 2. Full-screen intent — `USE_FULL_SCREEN_INTENT` (Android 14+)

**Use case:** Alarm clock / timer.

**Text:**
Sadho shows a full-screen notification only when an alarm the user set goes
off: the sun-based alarm, a finished timer (Sadhana & vrat timer, Sadhana
session timer) or a Mala target reached with the screen off. Over the lock
screen it shows only a small "finished" screen with Stop and Unlock; the rest
of the app still needs the phone unlocked. No other notification uses a
full-screen intent.

**Demo video script (30 s):**
1. (0–10 s) Start a 1-minute Sadhana session timer (Sadhana > Target: time 1 min > Start).
2. (10–12 s) Lock the phone (screen off).
3. (12–22 s) At the end the screen turns on and shows the full-screen alarm
   ("Sadhana complete", Stop, Unlock) with the ringtone.
4. (22–30 s) Tap Stop: the alarm stops and the phone stays locked.

---

## 3a. Foreground service — `FOREGROUND_SERVICE_SYSTEM_EXEMPTED` (alarm ring, since P5.1)

**Type:** systemExempted. Allowed for apps that hold `USE_EXACT_ALARM` /
`SCHEDULE_EXACT_ALARM` and use a foreground service to continue an alarm.
`AlarmRingService` starts only when one of the user's alarms fires (Sadhana
finish, Clock timer, sun alarm), plays the chosen ringtone on the alarm stream
and vibrates, shows the full-screen alarm with Stop, and stops on Stop,
unlocking, opening the app, or after at most 5 minutes. **[CHECK]** list it in
the Play Console foreground-service declaration with a short video of an alarm
ringing with the screen off and being stopped.

## 3. Foreground service — `FOREGROUND_SERVICE_SPECIAL_USE` (Mala)

**Type:** specialUse. **Subtype (manifest):** "Counts mala repetitions from
hardware volume-key presses while the screen is off, and rings when the user's
target is reached (hands-free japa counter)."

**Text:**
Mala mode is a hands-free japa (mantra repetition) counter: the user presses a
hardware volume key for each repetition, often with eyes closed and the phone
locked or in a pocket. Android delivers volume keys with the screen off only to
an active media session, so while (and only while) the user has started a Mala
session, a foreground service holds a media session with remote volume and
counts each key press. The real volume never changes and no audio is played.
It shows an ongoing notification with the live count ("Mala · 54 / 108") and
Pause/Stop buttons, rings when the target is reached, and stops when the
session is paused, stopped, reset or finished. None of the other foreground
service types covers counting hardware key presses. It is started only from the
app's Start button while the app is on screen.

**Demo video script (30 s):**
1. (0–6 s) Sadhana > Mala mode; "Count with the screen off" is on; target 5; Start.
2. (6–10 s) The ongoing notification "Mala · 0 / 5" appears; lock the phone.
3. (10–20 s) Screen off: press the volume key 5 times (show the hand); the
   volume does not change.
4. (20–26 s) At 5 the phone rings: the "Mala complete" alarm, full screen over
   the lock screen.
5. (26–30 s) Unlock: the counter shows 5 / 5; tap Stop in the notification.

---

## 4. Do Not Disturb access — `ACCESS_NOTIFICATION_POLICY` (quiet mode)

No Play Console declaration is required for this permission (it is a normal
permission; the user grants access on the phone's "Do Not Disturb access"
page). If a reviewer asks: the optional "Silence other notifications during a
session" switch (off by default) sets Do Not Disturb to alarms only while a
session runs and restores the user's own setting afterwards. **[CHECK]** the
Play Console permission list at submission time in case this changes.

**Optional demo (15 s):** Completion card > switch on > allow access > Start a
session: the status bar shows Do Not Disturb (alarms only); Pause: it is off
again.
