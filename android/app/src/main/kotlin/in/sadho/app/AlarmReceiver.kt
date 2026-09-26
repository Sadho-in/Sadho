package `in`.sadho.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.content.ContextCompat

/**
 * A scheduled alarm fired ([ACTION_FIRE]): starts [AlarmRingService]. The
 * alarm notification's Stop, or swiping it away ([ACTION_STOP]): stops the
 * ring and acknowledges it.
 */
class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_FIRE -> {
                val id = intent.getIntExtra("id", 0)
                val j = AlarmScheduler.take(context, id) ?: return
                val spec = RingSpec.fromJson(
                    j.put("key", "alarm:$id:${j.optLong("at")}"),
                )
                try {
                    // Allowed from the background: an alarm-clock alarm just fired.
                    ContextCompat.startForegroundService(context, AlarmRingService.intent(context, spec))
                } catch (e: Exception) {
                    Log.w("SadhoRing", "cannot start the ring service; ringing from here", e)
                    AlarmRinger.start(context, spec)
                }
            }
            ACTION_STOP -> AlarmRinger.stop(context, AlarmRinger.REASON_USER)
        }
    }

    companion object {
        const val ACTION_FIRE = "in.sadho.app.alarm.FIRE"
        const val ACTION_STOP = "in.sadho.app.alarm.STOP"
    }
}

/** A reboot or an app update clears AlarmManager: every stored alarm is set again. */
class AlarmBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            "android.intent.action.QUICKBOOT_POWERON",
            -> AlarmScheduler.restoreAll(context)
        }
    }
}
