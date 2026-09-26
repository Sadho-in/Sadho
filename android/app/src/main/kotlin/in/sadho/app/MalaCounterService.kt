package `in`.sadho.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.SystemClock
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.media.VolumeProviderCompat

/**
 * Mala counting with the screen off (hands-free japa).
 *
 * A foreground service that runs ONLY while a Mala session is running. It
 * holds an active MediaSession set to "playing" with REMOTE playback through a
 * [VolumeProviderCompat]: Android then sends the hardware volume keys to it,
 * even with the screen off, instead of changing a volume. Each press is one
 * count ([VolumeProviderCompat.onAdjustVolume]). The phone's real volume never
 * changes and no audio is played.
 *
 * While it runs, this service owns the live Mala count (it keeps counting when
 * Flutter is paused or its engine is gone). Everything is kept in
 * SharedPreferences ([PREFS]) so the app catches up on return or relaunch.
 * Feedback: while the app is on screen the app plays it (milestone buzz,
 * completion alert, the after-target tick), told so through the event; in the
 * background the service does it itself (vibration, and the alarm-style
 * notification at the target). One of the two, never both.
 */
class MalaCounterService : Service() {
    private val main = Handler(Looper.getMainLooper())
    private var session: MediaSessionCompat? = null
    private lateinit var prefs: SharedPreferences

    // Debouncing (see onVolumeKey).
    private var lastEventAt = 0L
    private var lastCountAt = 0L
    private var released = true
    private var upEventsSeen = false

    private val autoStop = Runnable { stopCounting() }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        prefs = getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        instance = this
    }

    override fun onDestroy() {
        releaseSession()
        main.removeCallbacks(autoStop)
        if (instance === this) instance = null
        super.onDestroy()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                // startForeground must come first (within 5 s of the start).
                goForeground()
                setStatus(STATUS_RUNNING)
                if (prefs.getBoolean(K_REACHED, false)) scheduleAutoStop()
                activateSession()
                emit("started")
            }
            ACTION_PAUSE -> pauseCounting()
            ACTION_RESUME -> resumeCounting()
            ACTION_STOP -> stopCounting()
            else -> {
                // Restarted by the system without an intent: nothing to count for.
                stopCounting()
            }
        }
        return START_NOT_STICKY
    }

    // ---- control (from the app or the notification) ------------------------

    fun pauseCounting() {
        if (status() == STATUS_STOPPED) return
        setStatus(STATUS_PAUSED)
        releaseSession()
        refreshNotification()
        emit("paused")
    }

    fun resumeCounting() {
        if (status() == STATUS_STOPPED) return
        setStatus(STATUS_RUNNING)
        activateSession()
        refreshNotification()
        emit("resumed")
    }

    fun stopCounting() {
        // Stop in the counter's notification also silences the Mala ring.
        if (AlarmRinger.ringingGroup(this) == MALA_GROUP) {
            AlarmRinger.stop(this, AlarmRinger.REASON_USER)
        }
        setStatus(STATUS_STOPPED)
        releaseSession()
        main.removeCallbacks(autoStop)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        emit("stopped")
        stopSelf()
    }

    /** The app changed the count, the target or the settings mid-session. */
    fun reload() {
        val reached = prefs.getBoolean(K_REACHED, false)
        if (reached) scheduleAutoStop() else main.removeCallbacks(autoStop)
        refreshNotification()
    }

    /** True while volume keys are counted (or ticked, after the target). */
    val isCounting: Boolean
        get() = status() == STATUS_RUNNING

    // ---- volume keys --------------------------------------------------------

    private fun activateSession() {
        if (session != null) return
        val s = MediaSessionCompat(this, "SadhoMala")
        s.setPlaybackToRemote(object : VolumeProviderCompat(
            VOLUME_CONTROL_RELATIVE, 100, 50,
        ) {
            override fun onAdjustVolume(direction: Int) {
                main.post { onVolumeKey(direction) }
            }
        })
        s.setPlaybackState(
            PlaybackStateCompat.Builder()
                .setState(PlaybackStateCompat.STATE_PLAYING, 0, 1f)
                .setActions(0)
                .build(),
        )
        s.isActive = true
        session = s
    }

    private fun releaseSession() {
        session?.let {
            it.isActive = false
            it.release()
        }
        session = null
    }

    /**
     * One volume-key event from the system. direction 0 is a key release (on
     * phones that report it). A held key auto-repeats: it counts once, and the
     * next count needs the key released (or, on phones that never report a
     * release, a pause in the repeats). Counts are always at least
     * [MIN_GAP_MS] apart.
     */
    private fun onVolumeKey(direction: Int) {
        val now = SystemClock.elapsedRealtime()
        if (direction == 0) {
            released = true
            upEventsSeen = true
            return
        }
        val gap = now - lastEventAt
        lastEventAt = now
        val fresh = if (upEventsSeen) released else gap >= MIN_GAP_MS
        released = false
        if (!fresh || now - lastCountAt < MIN_GAP_MS) return
        lastCountAt = now
        press()
    }

    /** A volume key while the app is on screen (MainActivity takes it). */
    fun onForegroundKey() {
        val now = SystemClock.elapsedRealtime()
        if (now - lastCountAt < MIN_GAP_MS) return
        lastCountAt = now
        press()
    }

    private fun press() {
        if (status() != STATUS_RUNNING) return
        if (prefs.getBoolean(K_REACHED, false)) {
            // After the target: a short tick only, the count stays.
            feedback("ack") { vibrate(prefs.getInt(K_ACK_MS, 60), prefs.getInt(K_ACK_AMP, -1)) }
            return
        }
        val count = prefs.getInt(K_COUNT, 0) + 1
        val base = prefs.getInt(K_BASE, 0)
        val target = prefs.getInt(K_TARGET, 108)
        val shown = base + count
        val reached = shown >= target
        prefs.edit().putInt(K_COUNT, count).putBoolean(K_REACHED, reached)
            .putLong(K_UPDATED_AT, System.currentTimeMillis()).apply()
        if (reached) {
            onTargetReached()
        } else {
            val every = prefs.getInt(K_MILESTONE_EVERY, 108)
            if (every > 0 && shown % every == 0) {
                feedback("milestone") {
                    vibrate(prefs.getInt(K_MILESTONE_MS, 180), prefs.getInt(K_MILESTONE_AMP, -1))
                }
            } else {
                emit("count")
            }
        }
        refreshNotification()
    }

    /**
     * Plays [kind] feedback: in the app when it is on screen (the event says
     * so), otherwise here with [native].
     */
    private fun feedback(kind: String, native: () -> Unit) {
        if (appInForeground) {
            emit("count", kind)
        } else {
            if (prefs.getBoolean(K_VIBRATION, true)) native()
            emit("count")
        }
    }

    private fun onTargetReached() {
        scheduleAutoStop()
        if (appInForeground) {
            emit("count", "ring")
            return
        }
        if (prefs.getBoolean(K_RANG, false)) {
            emit("count")
            return
        }
        prefs.edit().putBoolean(K_RANG, true).apply()
        postRing()
        emit("count")
    }

    /** Gives the volume keys back a while after the target, if nobody stops it. */
    private fun scheduleAutoStop() {
        main.removeCallbacks(autoStop)
        main.postDelayed(autoStop, AUTO_STOP_AFTER_TARGET_MS)
    }

    // ---- feedback ---------------------------------------------------------

    private fun vibrate(ms: Int, amplitude: Int) {
        try {
            val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                (getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager)
                    .defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }
            if (!vibrator.hasVibrator()) return
            val attrs = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .build()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val amp = if (amplitude in 1..255 && vibrator.hasAmplitudeControl()) {
                    amplitude
                } else {
                    VibrationEffect.DEFAULT_AMPLITUDE
                }
                @Suppress("DEPRECATION")
                vibrator.vibrate(VibrationEffect.createOneShot(ms.toLong(), amp), attrs)
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(ms.toLong(), attrs)
            }
        } catch (_: Exception) {
            // No vibrator, or not allowed: counting goes on.
        }
    }

    /**
     * The target was reached with the app in the background: rung at once,
     * here, through the same ring as every other alarm ([AlarmRinger]: the
     * chosen ringtone on the ALARM stream, the long alarm vibration, the
     * full-screen alarm screen). No round trip through Flutter.
     */
    private fun postRing() {
        val insistent = prefs.getBoolean(K_ALARM_INSISTENT, false)
        val spec = RingSpec(
            key = "mala:${prefs.getString(K_SESSION, null) ?: ""}:${prefs.getInt(K_TARGET, 108)}",
            group = MALA_GROUP,
            title = prefs.getString(K_RING_TITLE, null) ?: "Sadhana complete",
            body = prefs.getString(K_RING_BODY, null) ?: "",
            sound = prefs.getString(K_ALARM_SOUND, null),
            vibrate = prefs.getBoolean(K_ALARM_VIBRATE, true),
            soundRepeat = prefs.getString(K_ALARM_SOUND_REPEAT, null)
                ?: if (insistent) "until" else "once",
            vibrationRepeat = prefs.getString(K_ALARM_VIBRATION_REPEAT, null)
                ?: if (insistent) "until" else "once",
            stopLabel = prefs.getString(K_TEXT_STOP, null) ?: "Stop",
        )
        AlarmRinger.start(this, spec)
    }

    // ---- the ongoing notification -------------------------------------------

    private fun goForeground() {
        ensureCounterChannel()
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID, notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun ensureCounterChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            COUNTER_CHANNEL,
            prefs.getString(K_TEXT_CHANNEL, null) ?: "Mala counter",
            NotificationManager.IMPORTANCE_LOW,
        )
        channel.setSound(null, null)
        channel.enableVibration(false)
        channel.setShowBadge(false)
        manager.createNotificationChannel(channel)
    }

    private fun refreshNotification() {
        if (status() == STATUS_STOPPED) return
        try {
            NotificationManagerCompat.from(this).notify(NOTIFICATION_ID, buildNotification())
        } catch (_: SecurityException) {
            // Notifications refused: counting still works.
        }
    }

    private fun buildNotification(): Notification {
        val count = prefs.getInt(K_COUNT, 0)
        val shown = prefs.getInt(K_BASE, 0) + count
        val target = prefs.getInt(K_TARGET, 108)
        val paused = status() == STATUS_PAUSED
        val title = (prefs.getString(K_TEXT_TITLE, null) ?: "Mala · {count} / {target}")
            .replace("{count}", shown.toString())
            .replace("{target}", target.toString())
        val text = when {
            prefs.getBoolean(K_REACHED, false) -> prefs.getString(K_TEXT_DONE, null)
            paused -> prefs.getString(K_TEXT_PAUSED, null)
            else -> prefs.getString(K_TEXT_RUNNING, null)
        } ?: ""
        val open = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val builder = NotificationCompat.Builder(this, COUNTER_CHANNEL)
            .setSmallIcon(R.drawable.ic_stat_sadho)
            .setColor(NOTIFICATION_ACCENT)
            .setContentTitle(title)
            .setContentText(text)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setShowWhen(false)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentIntent(open)
            .setProgress(target, shown.coerceAtMost(target), false)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            builder.setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
        }
        if (paused) {
            builder.addAction(0, prefs.getString(K_TEXT_RESUME, null) ?: "Resume", action(ACTION_RESUME))
        } else if (!prefs.getBoolean(K_REACHED, false)) {
            builder.addAction(0, prefs.getString(K_TEXT_PAUSE, null) ?: "Pause", action(ACTION_PAUSE))
        }
        builder.addAction(0, prefs.getString(K_TEXT_STOP, null) ?: "Stop", action(ACTION_STOP))
        return builder.build()
    }

    private fun action(name: String): PendingIntent = PendingIntent.getService(
        this, name.hashCode(),
        Intent(this, MalaCounterService::class.java).setAction(name),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    // ---- state --------------------------------------------------------------

    private fun status(): String = prefs.getString(K_STATUS, STATUS_STOPPED) ?: STATUS_STOPPED

    private fun setStatus(status: String) {
        prefs.edit().putString(K_STATUS, status)
            .putLong(K_UPDATED_AT, System.currentTimeMillis()).apply()
    }

    /** Tells the app (if its engine is attached) what happened, with the state. */
    private fun emit(event: String, appFeedback: String? = null) {
        val l = listener ?: return
        val map = readState(this).toMutableMap()
        map["event"] = event
        map["feedback"] = appFeedback
        main.post { l(map) }
    }

    companion object {
        const val ACTION_START = "in.sadho.app.mala.START"
        const val ACTION_PAUSE = "in.sadho.app.mala.PAUSE"
        const val ACTION_RESUME = "in.sadho.app.mala.RESUME"
        const val ACTION_STOP = "in.sadho.app.mala.STOP"

        const val PREFS = "sadho_mala"
        const val NOTIFICATION_ID = 71080
        /** The target ring's notification (the shared alarm ring's). */
        const val RING_NOTIFICATION_ID = AlarmRinger.NOTIFICATION_ID
        private const val COUNTER_CHANNEL = "mala_counter"

        /** The alarm group of the target ring (see alarm_screen_provider.dart). */
        const val MALA_GROUP = "mala"

        const val MIN_GAP_MS = 120L
        const val AUTO_STOP_AFTER_TARGET_MS = 10 * 60 * 1000L

        /** Saffron, from the logo's bead (as notificationAccent in Dart). */
        private const val NOTIFICATION_ACCENT = 0xFFFF9933.toInt()

        const val STATUS_RUNNING = "running"
        const val STATUS_PAUSED = "paused"
        const val STATUS_STOPPED = "stopped"

        // Live state.
        const val K_SESSION = "sessionId"
        const val K_COUNT = "count"
        const val K_BASE = "base"
        const val K_TARGET = "target"
        const val K_STATUS = "status"
        const val K_REACHED = "reached"
        const val K_RANG = "rang"
        const val K_UPDATED_AT = "updatedAt"

        // Feedback settings.
        const val K_VIBRATION = "vibration"
        const val K_MILESTONE_EVERY = "milestoneEvery"
        const val K_MILESTONE_MS = "milestoneMs"
        const val K_MILESTONE_AMP = "milestoneAmplitude"
        const val K_ACK_MS = "ackMs"
        const val K_ACK_AMP = "ackAmplitude"

        // The target alarm (same channel as the Sadhana finish alarm).
        const val K_ALARM_CHANNEL = "alarmChannelId"
        const val K_ALARM_CHANNEL_NAME = "alarmChannelName"
        const val K_ALARM_CHANNEL_DESC = "alarmChannelDescription"
        const val K_ALARM_SOUND = "alarmSound"
        const val K_ALARM_VIBRATE = "alarmVibrate"
        const val K_ALARM_INSISTENT = "alarmInsistent"
        const val K_ALARM_SOUND_REPEAT = "alarmSoundRepeat"
        const val K_ALARM_VIBRATION_REPEAT = "alarmVibrationRepeat"
        const val K_RING_TITLE = "ringTitle"
        const val K_RING_BODY = "ringBody"

        // Notification text, in the app's language.
        const val K_TEXT_CHANNEL = "textChannel"
        const val K_TEXT_TITLE = "textTitle"
        const val K_TEXT_RUNNING = "textRunning"
        const val K_TEXT_PAUSED = "textPaused"
        const val K_TEXT_DONE = "textDone"
        const val K_TEXT_PAUSE = "textPause"
        const val K_TEXT_RESUME = "textResume"
        const val K_TEXT_STOP = "textStop"

        private val INT_KEYS = setOf(
            K_COUNT, K_BASE, K_TARGET, K_MILESTONE_EVERY, K_MILESTONE_MS,
            K_MILESTONE_AMP, K_ACK_MS, K_ACK_AMP,
        )
        private val BOOL_KEYS = setOf(
            K_REACHED, K_RANG, K_VIBRATION, K_ALARM_VIBRATE, K_ALARM_INSISTENT,
        )
        private val STRING_KEYS = setOf(
            K_SESSION, K_ALARM_CHANNEL, K_ALARM_CHANNEL_NAME, K_ALARM_CHANNEL_DESC,
            K_ALARM_SOUND, K_ALARM_SOUND_REPEAT, K_ALARM_VIBRATION_REPEAT, K_RING_TITLE, K_RING_BODY, K_TEXT_CHANNEL, K_TEXT_TITLE,
            K_TEXT_RUNNING, K_TEXT_PAUSED, K_TEXT_DONE, K_TEXT_PAUSE, K_TEXT_RESUME,
            K_TEXT_STOP,
        )

        /** The running service, if any (same process as the app). */
        @Volatile
        var instance: MalaCounterService? = null

        /** Receives every event while the app's engine is attached. */
        @Volatile
        var listener: ((Map<String, Any?>) -> Unit)? = null

        /** The app's activity is resumed (set by MainActivity). */
        @Volatile
        var appInForeground = false

        /**
         * Stores what the app sent (the count, target, session and settings).
         * [fresh]: a new start, so the "rang" and "reached" marks are reset.
         */
        fun writeConfig(context: Context, args: Map<*, *>, fresh: Boolean) {
            val edit = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            for ((k, v) in args) {
                val key = k as? String ?: continue
                when {
                    key in INT_KEYS && v is Number -> edit.putInt(key, v.toInt())
                    key in BOOL_KEYS && v is Boolean -> edit.putBoolean(key, v)
                    key in STRING_KEYS && v is String -> edit.putString(key, v)
                    key in STRING_KEYS && v == null -> edit.remove(key)
                }
            }
            if (fresh) edit.putBoolean(K_RANG, false)
            edit.putLong(K_UPDATED_AT, System.currentTimeMillis())
            edit.apply()
            // Whether the target is reached follows from the numbers; a raised
            // target re-opens the session (and it may ring again later).
            val p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val reached = p.getInt(K_BASE, 0) + p.getInt(K_COUNT, 0) >= p.getInt(K_TARGET, 108)
            val again = p.edit().putBoolean(K_REACHED, reached)
            if (!reached) again.putBoolean(K_RANG, false)
            again.apply()
        }

        /** The live state, as the app reads it (also after a relaunch). */
        fun readState(context: Context): Map<String, Any?> {
            val p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val running = instance != null
            val status = p.getString(K_STATUS, STATUS_STOPPED)
            return mapOf(
                K_SESSION to p.getString(K_SESSION, null),
                K_COUNT to p.getInt(K_COUNT, 0),
                K_BASE to p.getInt(K_BASE, 0),
                K_TARGET to p.getInt(K_TARGET, 108),
                // A service that is gone (process killed) is stopped, whatever
                // the last saved status said.
                K_STATUS to if (running) status else STATUS_STOPPED,
                K_REACHED to p.getBoolean(K_REACHED, false),
                K_RANG to p.getBoolean(K_RANG, false),
                K_UPDATED_AT to p.getLong(K_UPDATED_AT, 0L),
            )
        }

        /** Marks the state stopped when there is no service to tell. */
        fun markStopped(context: Context) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                .putString(K_STATUS, STATUS_STOPPED).apply()
        }
    }
}
