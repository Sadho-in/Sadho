package `in`.sadho.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import org.json.JSONObject
import java.util.Calendar

/**
 * Alarm-style finishes that are known in advance (the Sadhana Time/Rhythm
 * alarm, the Clock timer, the sun alarm): set as ALARM CLOCKS
 * (AlarmManager.setAlarmClock), which Doze and battery savers let through on
 * time. When one fires, [AlarmReceiver] starts [AlarmRingService].
 *
 * Every alarm is also kept in SharedPreferences, so a group can be replaced
 * or cancelled at once, and everything is set again after a reboot or an app
 * update ([AlarmBootReceiver]).
 */
object AlarmScheduler {
    private const val TAG = "SadhoAlarms"
    private const val PREFS = "sadho_alarms"

    private fun prefs(c: Context) = c.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    /** Replaces every alarm of [group] with [alarms] (maps from the app). */
    fun replaceGroup(context: Context, group: String, alarms: List<Map<*, *>>) {
        cancelGroup(context, group)
        for (m in alarms) {
            val j = JSONObject(m.mapKeys { it.key.toString() })
            j.put("group", group)
            val id = j.optInt("id")
            prefs(context).edit().putString(key(id), j.toString()).apply()
            set(context, j)
        }
    }

    fun cancelGroup(context: Context, group: String) {
        val p = prefs(context)
        val edit = p.edit()
        for ((k, v) in p.all) {
            val j = (v as? String)?.let { runCatching { JSONObject(it) }.getOrNull() } ?: continue
            if (j.optString("group") != group) continue
            alarmManager(context).cancel(fireIntent(context, j.optInt("id")))
            edit.remove(k)
        }
        edit.apply()
    }

    /** An alarm fired: its spec, and the next day's alarm set if it repeats daily. */
    fun take(context: Context, id: Int): JSONObject? {
        val p = prefs(context)
        val j = p.getString(key(id), null)?.let { runCatching { JSONObject(it) }.getOrNull() } ?: return null
        if (j.optBoolean("daily")) {
            val next = JSONObject(j.toString()).put("at", nextDay(j.optLong("at")))
            p.edit().putString(key(id), next.toString()).apply()
            set(context, next)
        } else {
            p.edit().remove(key(id)).apply()
        }
        return j
    }

    /** After a reboot or an update: sets every stored alarm again. */
    fun restoreAll(context: Context) {
        val now = System.currentTimeMillis()
        val p = prefs(context)
        for ((k, v) in p.all) {
            var j = (v as? String)?.let { runCatching { JSONObject(it) }.getOrNull() } ?: continue
            if (j.optLong("at") < now - 60_000L) {
                if (!j.optBoolean("daily")) {
                    p.edit().remove(k).apply()
                    continue
                }
                var at = j.optLong("at")
                while (at < now) at = nextDay(at)
                j = JSONObject(j.toString()).put("at", at)
                p.edit().putString(k, j.toString()).apply()
            }
            set(context, j)
        }
    }

    fun canScheduleExact(context: Context): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarmManager(context).canScheduleExactAlarms()

    private fun set(context: Context, j: JSONObject) {
        val at = j.optLong("at")
        val id = j.optInt("id")
        val am = alarmManager(context)
        val fire = fireIntent(context, id)
        try {
            if (canScheduleExact(context)) {
                val show = PendingIntent.getActivity(
                    context, id,
                    Intent(context, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                am.setAlarmClock(AlarmManager.AlarmClockInfo(at, show), fire)
            } else {
                // No exact alarms (Android 12 with the permission revoked): a
                // little flexible, and the app says so.
                am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, fire)
            }
        } catch (e: SecurityException) {
            Log.w(TAG, "exact alarm refused; setting a flexible one", e)
            am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, fire)
        }
    }

    private fun fireIntent(context: Context, id: Int): PendingIntent = PendingIntent.getBroadcast(
        context, id,
        Intent(context, AlarmReceiver::class.java).setAction(AlarmReceiver.ACTION_FIRE).putExtra("id", id),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    /** The same wall-clock time tomorrow (daylight saving included). */
    private fun nextDay(at: Long): Long =
        Calendar.getInstance().apply { timeInMillis = at; add(Calendar.DAY_OF_MONTH, 1) }.timeInMillis

    private fun alarmManager(c: Context) = c.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    private fun key(id: Int) = "a_$id"
}
