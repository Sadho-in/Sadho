# Google Play Data safety form — draft answers

Based on what the app does today (P6). **[CHECK]** marks an answer to confirm
before submitting. Google's rule: data processed only on the device and never
sent off it is **not "collected"**; data the user sends somewhere themselves
(their own backup file) is not collected by us either.

## Overview

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **No** |
| Is all of the user data collected by your app encrypted in transit? | Not applicable (nothing is transmitted) |
| Do you provide a way for users to request that their data is deleted? | Not applicable (no data collected). The app still offers Profile > Delete account (wipes everything on the phone) and https://sadho.in/delete-data explains it. |
| Account creation | The app has **no accounts** (no sign-in). |
| Ads | **No ads.** No ads SDK. |
| Analytics / crash reporting | **None.** No analytics or crash SDK, no servers. |

## Why each permission does not mean "collected"

| Permission / data | What the app does | Leaves the phone? |
|---|---|---|
| Microphone (`RECORD_AUDIO`) | Voice counting (Beta) and training: the audio is analysed as it arrives; only MFCC feature numbers of the training recordings are saved (Hive). No audio is stored. | **No** |
| Approximate location (`ACCESS_COARSE_LOCATION`) | Sunrise/sunset for the sun-based alarm and "vrat until sunset"; the last position is saved on the phone. | **No** |
| Notifications (`POST_NOTIFICATIONS`) | Alarms, timers, calendar reminders, the daily reminder, the Mala counter notification. Local notifications only; no push service. | **No** |
| Exact alarms, full screen, boot (`USE_EXACT_ALARM`, `USE_FULL_SCREEN_INTENT`, `RECEIVE_BOOT_COMPLETED`) | Ring alarms on time, over the lock screen, and keep them after a restart. | **No** |
| Foreground service (`FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_SPECIAL_USE`) | Mala counting with the screen off. | **No** |
| Alarm ring service (`FOREGROUND_SERVICE_SYSTEM_EXEMPTED`) | Keeps a scheduled alarm (Sadhana finish, Clock timer, sun alarm) ringing for up to 5 minutes with the screen off. | **No** |
| Do Not Disturb (`ACCESS_NOTIFICATION_POLICY`) | Optional quiet mode during a session. | **No** |
| Vibration, wake lock | Feedback; keep the screen on during a session. | **No** |
| Name and email (Profile) | Optional, typed by the user, stored only on the phone (no account behind it). | **No** |
| Calendar marks, plans, mantras, session data | Stored on the phone (Hive). | **No** |
| Backup (Profile > Backup) | Writes one JSON file **where the user chooses** (system file dialog; could be a cloud folder the user picks). User-initiated; we never receive it. | Only if the user saves it to a cloud location themselves — **[CHECK]** Google treats user-initiated transfers as not collected. |
| `INTERNET` | Still declared; since P6-2 no app code uses the network (fonts are bundled). | **No** — **[CHECK]** consider removing the permission before release. |

## Security practices section

- Data encrypted in transit: N/A (answer "No" is not required when nothing is
  collected; the form skips it). **[CHECK]** the form wording on submission.
- Independent security review: No.
- Committed to the Families policy: No (not designed for children).

## Things that would change these answers later

Supabase accounts/sync (phase 2), any analytics or crash reporting, any ads,
cloud backup run by us, or fetching anything from a server.
