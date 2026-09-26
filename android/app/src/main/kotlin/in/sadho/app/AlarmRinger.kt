package `in`.sadho.app

import android.annotation.SuppressLint
import android.app.KeyguardManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.os.VibrationAttributes
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import org.json.JSONObject

/**
 * What one alarm rings with. The same for every alarm-style finish: the
 * Sadhana Time/Rhythm alarm, the Mala target, the Clock timer and the sun
 * alarm. Only the texts (and the chosen sound) differ.
 */
data class RingSpec(
    /** Identifies one finish: the same key never rings twice. */
    val key: String,
    /** The alert group (sadhana-timer, mala, timer, sun-alarm). */
    val group: String,
    val title: String,
    val body: String,
    /** A raw resource name (temple_bell), [SOUND_DEFAULT_ALARM], or null for silent. */
    val sound: String?,
    val vibrate: Boolean,
    /** once | repeat | until */
    val soundRepeat: String,
    /** once | until */
    val vibrationRepeat: String,
    val stopLabel: String,
) {
    fun toJson(): JSONObject = JSONObject()
        .put("key", key).put("group", group).put("title", title).put("body", body)
        .put("sound", sound ?: JSONObject.NULL).put("vibrate", vibrate)
        .put("soundRepeat", soundRepeat).put("vibrationRepeat", vibrationRepeat)
        .put("stopLabel", stopLabel)

    /** Sadhana and Mala ring on one channel; the Clock timer and sun alarm on another. */
    val isSadhana: Boolean get() = group == GROUP_SADHANA_TIMER || group == GROUP_MALA

    companion object {
        const val SOUND_DEFAULT_ALARM = "default"
        const val GROUP_SADHANA_TIMER = "sadhana-timer"
        const val GROUP_MALA = "mala"

        fun fromJson(j: JSONObject): RingSpec = RingSpec(
            key = j.optString("key"),
            group = j.optString("group"),
            title = j.optString("title"),
            body = j.optString("body"),
            sound = if (j.isNull("sound")) null else j.optString("sound"),
            vibrate = j.optBoolean("vibrate", true),
            soundRepeat = j.optString("soundRepeat", "once"),
            vibrationRepeat = j.optString("vibrationRepeat", "once"),
            stopLabel = j.optString("stopLabel", "Stop"),
        )

        fun fromMap(m: Map<*, *>): RingSpec = fromJson(JSONObject(m.mapKeys { it.key.toString() }))
    }
}

/**
 * THE alarm ring. Every alarm-style finish ends up here, whether it was
 * scheduled (AlarmManager.setAlarmClock -> [AlarmReceiver] -> [AlarmRingService])
 * or reached live (the Mala target in [MalaCounterService]).
 *
 * - Sound: the chosen ringtone through MediaPlayer with USAGE_ALARM, so it
 *   plays at the phone's ALARM volume, also on silent / vibrate and in "alarms
 *   only" Do Not Disturb. (A notification channel's sound plays at the
 *   notification volume unless the channel was created with alarm attributes,
 *   and Android never changes an existing channel; that is what made the old
 *   ring quiet.)
 * - Vibration: a long repeating 800 ms on / 400 ms off pattern with alarm
 *   usage (no amplitude control needed).
 * - "Once" = one full play of the ringtone, at least [MIN_ONCE_MS]; "Until
 *   stopped" = until Stop, unlocking, opening the app, or [MAX_RING_MS].
 * - A partial wake lock keeps it going with the screen off, and the screen is
 *   turned on.
 * - The full-screen alarm notification (on a `_v2` channel) carries Stop; when
 *   the phone is off or locked, the alarm screen is also launched directly.
 *
 * Its state (ringing, unacknowledged) is kept in SharedPreferences, so the app
 * can read it back after its activity or process was recreated.
 */
object AlarmRinger {
    private const val TAG = "SadhoRing"
    const val NOTIFICATION_ID = 71090
    const val CHANNEL_SADHANA = "sadhana_alarm_v2"
    const val CHANNEL_ALARMS = "alarms_timers_v2"

    const val MIN_ONCE_MS = 5_000L
    const val MAX_RING_MS = 5 * 60 * 1000L
    private val VIBRATION = longArrayOf(0, 800, 400)

    private const val PREFS = "sadho_ring"
    private const val K_RINGING = "ringing"
    private const val K_UNACK = "unacknowledged"
    private const val K_GROUP = "group"
    private const val K_TITLE = "title"
    private const val K_BODY = "body"
    private const val K_STARTED_AT = "startedAt"
    private const val K_LAST_KEY = "lastKey"

    /** flutter_local_notifications' action and extra for opening the app (see MainActivity). */
    const val SELECT_NOTIFICATION = "SELECT_NOTIFICATION"
    const val PAYLOAD = "payload"

    private val main = Handler(Looper.getMainLooper())
    private var player: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private var cpuLock: PowerManager.WakeLock? = null
    private var unlockReceiver: BroadcastReceiver? = null
    private var soundDone = true
    private var current: RingSpec? = null
    private var vibrationDone = true

    /** Told when a ring ends (the service stops itself). */
    var onEnded: (() -> Unit)? = null

    /** Receives the ring state on every change while the app's engine is attached. */
    @Volatile
    var listener: ((Map<String, Any?>) -> Unit)? = null

    private val cap = Runnable { stop(appContext ?: return@Runnable, REASON_TIMEOUT) }
    private val endSound = Runnable { soundDone = true; stopPlayer(); maybeDone() }
    private val endVibration = Runnable { vibrationDone = true; stopVibrator(); maybeDone() }
    private var appContext: Context? = null

    const val REASON_USER = "user"
    const val REASON_UNLOCK = "unlock"
    const val REASON_TIMEOUT = "timeout"
    const val REASON_APP = "app"
    const val REASON_DONE = "done"

    private fun prefs(c: Context): SharedPreferences =
        c.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    /**
     * Rings [spec]. False if this finish already rang (never twice for one
     * target). Must run on the main thread.
     */
    fun start(context: Context, spec: RingSpec): Boolean {
        val app = context.applicationContext
        appContext = app
        val p = prefs(app)
        if (spec.key.isNotEmpty() && p.getString(K_LAST_KEY, null) == spec.key) {
            Log.i(TAG, "already rang for ${spec.key}")
            return false
        }
        // Another alarm still ringing: this one replaces it.
        silence(app)
        current = spec
        p.edit()
            .putString(K_LAST_KEY, spec.key)
            .putBoolean(K_RINGING, true)
            .putBoolean(K_UNACK, true)
            .putString(K_GROUP, spec.group)
            .putString(K_TITLE, spec.title)
            .putString(K_BODY, spec.body)
            .putLong(K_STARTED_AT, System.currentTimeMillis())
            .apply()

        acquireWakeLocks(app)
        ensureChannels(app)
        try {
            NotificationManagerCompat.from(app).notify(NOTIFICATION_ID, buildNotification(app, spec))
        } catch (e: SecurityException) {
            Log.w(TAG, "notifications not allowed: the ring still sounds", e)
        }

        val soundMs = playSound(app, spec)
        soundDone = soundMs == 0L
        if (soundMs > 0) main.postDelayed(endSound, soundMs)

        val vibrationMs = if (spec.vibrate) {
            if (spec.vibrationRepeat == "until") MAX_RING_MS else maxOf(soundMs, MIN_ONCE_MS)
        } else {
            0L
        }
        vibrationDone = vibrationMs == 0L || !startVibrator(app)
        if (!vibrationDone && vibrationMs < MAX_RING_MS) main.postDelayed(endVibration, vibrationMs)

        main.postDelayed(cap, MAX_RING_MS)
        listenForUnlock(app)
        launchAlarmScreen(app, spec.group)
        emit(app)
        if (soundDone && vibrationDone) maybeDone()
        return true
    }

    /**
     * Stops the sound, the vibration and the notification. [REASON_USER] (a
     * Stop button) also acknowledges the finish; the others (unlock, opening
     * the app, the 5-minute cap) only silence it, and the app keeps a Stop
     * control on screen until the user acknowledges.
     */
    fun stop(context: Context, reason: String) {
        val app = context.applicationContext
        val p = prefs(app)
        val wasRinging = p.getBoolean(K_RINGING, false)
        silence(app)
        val edit = p.edit().putBoolean(K_RINGING, false)
        if (reason == REASON_USER) edit.putBoolean(K_UNACK, false)
        edit.apply()
        Log.i(TAG, "stop ($reason), was ringing: $wasRinging")
        emit(app)
        onEnded?.invoke()
    }

    /** The user saw the finish (Stop in the app): nothing left to show. */
    fun acknowledge(context: Context) {
        val p = prefs(context)
        if (p.getBoolean(K_RINGING, false)) {
            stop(context, REASON_USER)
        } else {
            p.edit().putBoolean(K_UNACK, false).apply()
            emit(context.applicationContext)
        }
    }

    /** Silences a ring of [group] if the phone is unlocked (the app was opened). */
    fun silenceIfUnlocked(context: Context, group: String?) {
        val p = prefs(context)
        if (!p.getBoolean(K_RINGING, false)) return
        if (group != null && p.getString(K_GROUP, null) != group) return
        val keyguard = context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        if (keyguard.isKeyguardLocked) return // the alarm screen is showing: its Stop decides
        stop(context, REASON_APP)
    }

    fun isRinging(context: Context): Boolean = prefs(context).getBoolean(K_RINGING, false)

    fun ringingGroup(context: Context): String? =
        prefs(context).let { if (it.getBoolean(K_RINGING, false)) it.getString(K_GROUP, null) else null }

    /** The ring state as the app reads it (also after a recreate or relaunch). */
    fun state(context: Context): Map<String, Any?> {
        val p = prefs(context)
        // A process that died mid-ring left "ringing" behind: nothing plays now.
        val ringing = p.getBoolean(K_RINGING, false) && (player != null || vibrator != null)
        if (p.getBoolean(K_RINGING, false) && !ringing) {
            p.edit().putBoolean(K_RINGING, false).apply()
        }
        return mapOf(
            "ringing" to ringing,
            "unacknowledged" to p.getBoolean(K_UNACK, false),
            "group" to p.getString(K_GROUP, null),
            "title" to p.getString(K_TITLE, null),
            "body" to p.getString(K_BODY, null),
            "startedAt" to p.getLong(K_STARTED_AT, 0L),
        )
    }

    // ---- internals -----------------------------------------------------------

    private fun maybeDone() {
        if (!soundDone || !vibrationDone) return
        val app = appContext ?: return
        // "Once" has played out: quiet now, but the finish stays unacknowledged
        // (the notification stays, without sound, so the result is still seen).
        releaseWakeLocks()
        unlisten(app)
        main.removeCallbacks(cap)
        prefs(app).edit().putBoolean(K_RINGING, false).apply()
        current?.let {
            try {
                NotificationManagerCompat.from(app)
                    .notify(NOTIFICATION_ID, buildNotification(app, it, ringing = false))
            } catch (_: SecurityException) {
            }
        }
        emit(app)
        onEnded?.invoke()
    }

    private fun silence(app: Context) {
        main.removeCallbacks(cap)
        main.removeCallbacks(endSound)
        main.removeCallbacks(endVibration)
        stopPlayer()
        stopVibrator()
        soundDone = true
        vibrationDone = true
        releaseWakeLocks()
        unlisten(app)
        NotificationManagerCompat.from(app).cancel(NOTIFICATION_ID)
    }

    private val alarmAudio: AudioAttributes
        get() = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

    private fun soundUri(app: Context, sound: String): Uri {
        if (sound == RingSpec.SOUND_DEFAULT_ALARM) {
            return RingtoneManager.getActualDefaultRingtoneUri(app, RingtoneManager.TYPE_ALARM)
                ?: Settings.System.DEFAULT_ALARM_ALERT_URI
                ?: rawUri(app, "temple_bell")
        }
        return rawUri(app, sound)
    }

    private fun rawUri(app: Context, name: String): Uri =
        Uri.parse("android.resource://${app.packageName}/raw/$name")

    /** Starts the ringtone; returns how long it should play (ms), or 0 if silent. */
    private fun playSound(app: Context, spec: RingSpec): Long {
        val sound = spec.sound ?: return 0L
        val mp = prepare(app, soundUri(app, sound))
            ?: (if (sound == RingSpec.SOUND_DEFAULT_ALARM) prepare(app, rawUri(app, "temple_bell")) else null)
            ?: return 0L
        val length = mp.duration.toLong().takeIf { it > 0 } ?: 3_000L
        // Whole plays only, and at least 5 s (a short chime loops until then).
        val plays = when (spec.soundRepeat) {
            "until" -> 0L
            "repeat" -> maxOf(3L, ceilDiv(MIN_ONCE_MS, length))
            else -> ceilDiv(MIN_ONCE_MS, length)
        }
        mp.isLooping = true
        mp.start()
        player = mp
        return if (plays == 0L) MAX_RING_MS else plays * length
    }

    private fun ceilDiv(a: Long, b: Long): Long = (a + b - 1) / b

    private fun prepare(app: Context, uri: Uri): MediaPlayer? = try {
        MediaPlayer().apply {
            setAudioAttributes(alarmAudio)
            setDataSource(app, uri)
            prepare()
        }
    } catch (e: Exception) {
        Log.w(TAG, "cannot play $uri", e)
        null
    }

    private fun stopPlayer() {
        player?.let {
            try {
                if (it.isPlaying) it.stop()
            } catch (_: IllegalStateException) {
            }
            it.release()
        }
        player = null
    }

    private fun startVibrator(app: Context): Boolean {
        return try {
            val v = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                (app.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager).defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                app.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }
            if (!v.hasVibrator()) return false
            when {
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU -> v.vibrate(
                    VibrationEffect.createWaveform(VIBRATION, 1),
                    VibrationAttributes.createForUsage(VibrationAttributes.USAGE_ALARM),
                )
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.O -> {
                    @Suppress("DEPRECATION")
                    v.vibrate(VibrationEffect.createWaveform(VIBRATION, 1), alarmAudio)
                }
                else -> {
                    @Suppress("DEPRECATION")
                    v.vibrate(VIBRATION, 1, alarmAudio)
                }
            }
            vibrator = v
            true
        } catch (e: Exception) {
            Log.w(TAG, "vibration unavailable", e)
            false
        }
    }

    private fun stopVibrator() {
        try {
            vibrator?.cancel()
        } catch (_: Exception) {
        }
        vibrator = null
    }

    @SuppressLint("WakelockTimeout")
    private fun acquireWakeLocks(app: Context) {
        val power = app.getSystemService(Context.POWER_SERVICE) as PowerManager
        cpuLock = power.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "Sadho:ring").apply {
            setReferenceCounted(false)
            acquire(MAX_RING_MS + 10_000L)
        }
        // Turns the screen on (the alarm screen's own turnScreenOn does it too).
        try {
            @Suppress("DEPRECATION")
            power.newWakeLock(
                PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP or
                    PowerManager.ON_AFTER_RELEASE,
                "Sadho:ring-screen",
            ).acquire(10_000L)
        } catch (e: Exception) {
            Log.w(TAG, "cannot turn the screen on", e)
        }
    }

    private fun releaseWakeLocks() {
        cpuLock?.let { if (it.isHeld) it.release() }
        cpuLock = null
    }

    /** Unlocking the phone (PIN, fingerprint...) silences the ring. */
    private fun listenForUnlock(app: Context) {
        if (unlockReceiver != null) return
        val r = object : BroadcastReceiver() {
            override fun onReceive(c: Context, i: Intent) {
                if (i.action == Intent.ACTION_USER_PRESENT) stop(c, REASON_UNLOCK)
            }
        }
        ContextCompat.registerReceiver(
            app, r, IntentFilter(Intent.ACTION_USER_PRESENT), ContextCompat.RECEIVER_NOT_EXPORTED,
        )
        unlockReceiver = r
    }

    private fun unlisten(app: Context) {
        unlockReceiver?.let {
            try {
                app.unregisterReceiver(it)
            } catch (_: IllegalArgumentException) {
            }
        }
        unlockReceiver = null
    }

    /** Opens the app's alarm screen (MainActivity shows ONLY that over the lock screen). */
    fun alarmScreenIntent(app: Context, group: String): Intent =
        Intent(app, MainActivity::class.java)
            .setAction(SELECT_NOTIFICATION)
            .putExtra(PAYLOAD, group)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)

    /**
     * With the screen off or the phone locked, starts the alarm screen itself
     * as well as through the full-screen notification, so it shows every time.
     * Only when full-screen alarms are allowed (Android 14+ lets users refuse).
     */
    private fun launchAlarmScreen(app: Context, group: String) {
        val power = app.getSystemService(Context.POWER_SERVICE) as PowerManager
        val keyguard = app.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        if (power.isInteractive && !keyguard.isKeyguardLocked) return // heads-up is enough
        if (!canUseFullScreen(app)) return
        try {
            app.startActivity(alarmScreenIntent(app, group))
        } catch (e: Exception) {
            // Background start refused: the full-screen notification still does it.
            Log.w(TAG, "cannot start the alarm screen directly", e)
        }
    }

    fun canUseFullScreen(app: Context): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE ||
            (app.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                .canUseFullScreenIntent()

    fun buildNotification(app: Context, spec: RingSpec, ringing: Boolean = true): Notification {
        val open = PendingIntent.getActivity(
            app, NOTIFICATION_ID, alarmScreenIntent(app, spec.group),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val stop = PendingIntent.getBroadcast(
            app, NOTIFICATION_ID,
            Intent(app, AlarmReceiver::class.java).setAction(AlarmReceiver.ACTION_STOP),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val b = NotificationCompat.Builder(app, if (spec.isSadhana) CHANNEL_SADHANA else CHANNEL_ALARMS)
            .setSmallIcon(R.drawable.ic_stat_sadho)
            .setColor(NOTIFICATION_ACCENT)
            .setContentTitle(spec.title)
            .setContentText(spec.body)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            // The service plays the sound: the notification itself is silent.
            .setSilent(true)
            .setOngoing(ringing)
            .setAutoCancel(false)
            .setContentIntent(open)
            .setDeleteIntent(stop)
            .addAction(0, spec.stopLabel, stop)
        if (ringing) b.setFullScreenIntent(open, true)
        val n = b.build()
        n.extras.putString(PAYLOAD, spec.group)
        return n
    }

    /**
     * The alarm channels, NEW ids (`_v2`): Android never changes an existing
     * channel's sound or importance, so the old ones (which could be on the
     * notification volume) are deleted. They are silent (the ring plays through
     * MediaPlayer on the alarm stream) and HIGH importance, which full-screen
     * alarms need; their audio attributes are the alarm's all the same.
     */
    fun ensureChannels(app: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = app.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        for (old in nm.notificationChannels) {
            val id = old.id
            if (id == "alarms_timers" || (id.startsWith("sadhana_alarm_") && id != CHANNEL_SADHANA)) {
                nm.deleteNotificationChannel(id)
            }
        }
        val names = app.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        fun make(id: String, name: String) {
            val ch = NotificationChannel(id, name, NotificationManager.IMPORTANCE_HIGH)
            ch.setSound(null, alarmAudio)
            ch.enableVibration(false)
            ch.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            ch.setBypassDnd(true)
            nm.createNotificationChannel(ch)
        }
        make(CHANNEL_SADHANA, names.getString("channelSadhana", null) ?: "Sadhana alarm")
        make(CHANNEL_ALARMS, names.getString("channelAlarms", null) ?: "Alarms & timers")
    }

    /** The channel names in the app's language (shown in the phone's settings). */
    fun setChannelNames(context: Context, sadhana: String?, alarms: String?) {
        prefs(context).edit().putString("channelSadhana", sadhana).putString("channelAlarms", alarms).apply()
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        // Renaming an existing channel is allowed (only its sound etc. are fixed).
        if (sadhana != null) nm.getNotificationChannel(CHANNEL_SADHANA)?.let { it.name = sadhana; nm.createNotificationChannel(it) }
        if (alarms != null) nm.getNotificationChannel(CHANNEL_ALARMS)?.let { it.name = alarms; nm.createNotificationChannel(it) }
    }

    private fun emit(app: Context) {
        val l = listener ?: return
        val s = state(app)
        main.post { l(s) }
    }

    private const val NOTIFICATION_ACCENT = 0xFFFF9933.toInt()
}
