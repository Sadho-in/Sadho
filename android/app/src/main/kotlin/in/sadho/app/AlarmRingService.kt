package `in`.sadho.app

import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.ServiceCompat
import org.json.JSONObject

/**
 * A short-lived foreground service that keeps a scheduled alarm ringing
 * ([AlarmRinger]) with the screen off and the app closed. Started by
 * [AlarmReceiver] when AlarmManager fires; stops itself when the ring ends.
 *
 * Foreground-service type: `systemExempted`. The Android docs allow it for
 * "apps that hold SCHEDULE_EXACT_ALARM or USE_EXACT_ALARM and use a foreground
 * service to continue alarms in the background, including haptics-only
 * alarms", which is exactly this (Sadho holds USE_EXACT_ALARM on Android 13+).
 * `mediaPlayback` would also fit the sound, but it is meant for media the user
 * started, and it would be wrong for a vibration-only alarm. Types are only
 * enforced from Android 14, where USE_EXACT_ALARM is always granted.
 */
class AlarmRingService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val json = intent?.getStringExtra(EXTRA_SPEC)
        val spec = try {
            json?.let { RingSpec.fromJson(JSONObject(it)) }
        } catch (e: Exception) {
            null
        }
        if (spec == null) {
            stopSelf()
            return START_NOT_STICKY
        }
        // startForeground first (within seconds of the start).
        AlarmRinger.ensureChannels(this)
        val notification = AlarmRinger.buildNotification(this, spec)
        try {
            ServiceCompat.startForeground(
                this, AlarmRinger.NOTIFICATION_ID, notification,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_SYSTEM_EXEMPTED
                } else {
                    0
                },
            )
        } catch (e: Exception) {
            Log.w("SadhoRing", "cannot run in the foreground; ringing anyway", e)
        }
        AlarmRinger.onEnded = { finish() }
        if (!AlarmRinger.start(this, spec)) finish()
        return START_NOT_STICKY
    }

    private fun finish() {
        AlarmRinger.onEnded = null
        // DETACH: a "Once" ring leaves its (quiet) notification showing the result.
        ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_DETACH)
        stopSelf()
    }

    companion object {
        const val EXTRA_SPEC = "spec"

        fun intent(context: Context, spec: RingSpec): Intent =
            Intent(context, AlarmRingService::class.java).putExtra(EXTRA_SPEC, spec.toJson().toString())
    }
}
