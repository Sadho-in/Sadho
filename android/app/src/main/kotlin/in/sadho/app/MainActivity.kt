package `in`.sadho.app

import android.app.ActivityManager
import android.app.KeyguardManager
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * The app never shows over the lock screen, EXCEPT when an alarm opens it
 * (the Sadhana completion alarm, the Clock timer or the sun alarm). Then, and
 * only then, it shows over the lock screen and turns the screen on, and the
 * Dart side shows nothing but a small "finished" screen. Leaving that screen
 * switches it off again, so the rest of the app needs the phone unlocked.
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null

    /** The alarm group this activity was just opened for (until Dart takes it). */
    private var alarmLaunch: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        // Before the activity resumes: turnScreenOn only applies on resume.
        takeAlarmIntent(intent)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val group = takeAlarmIntent(intent)
        if (group != null) channel?.invokeMethod("alarmOpened", group)
    }

    /**
     * If [intent] is an alarm notification opening the app (a tap, or the
     * full-screen intent), shows the activity over the lock screen and returns
     * its group. Reopening the app from Recents replays the old intent, which
     * must not count.
     */
    private fun takeAlarmIntent(intent: Intent?): String? {
        if (intent == null || intent.action != SELECT_NOTIFICATION) return null
        if (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0) return null
        val group = intent.getStringExtra(PAYLOAD) ?: return null
        if (group !in ALARM_GROUPS) return null
        alarmLaunch = group
        showOverLockScreen(true)
        return group
    }

    private fun showOverLockScreen(on: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(on)
            setTurnScreenOn(on)
        } else {
            @Suppress("DEPRECATION")
            val flags = WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            if (on) window.addFlags(flags) else window.clearFlags(flags)
        }
    }

    private val keyguard: KeyguardManager
        get() = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sadho/alarm")
        channel = ch
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                // Whether a Sadhana alarm may show full screen (Android 14+ lets
                // the user turn this off). Asking must not open the settings.
                "canUseFullScreenIntent" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                        val manager = getSystemService(Context.NOTIFICATION_SERVICE)
                            as NotificationManager
                        result.success(manager.canUseFullScreenIntent())
                    } else {
                        result.success(true)
                    }
                }
                // The alarm group the app was opened for, once.
                "takeAlarmLaunch" -> {
                    result.success(alarmLaunch)
                    alarmLaunch = null
                }
                "setShowOverLockScreen" -> {
                    showOverLockScreen(call.arguments == true)
                    result.success(null)
                }
                "isLocked" -> result.success(keyguard.isKeyguardLocked)
                // Asks the user to unlock (PIN, fingerprint...). True if unlocked.
                "requestUnlock" -> {
                    if (!keyguard.isKeyguardLocked) {
                        result.success(true)
                    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        keyguard.requestDismissKeyguard(
                            this,
                            object : KeyguardManager.KeyguardDismissCallback() {
                                override fun onDismissSucceeded() = result.success(true)
                                override fun onDismissCancelled() = result.success(false)
                                override fun onDismissError() = result.success(false)
                            },
                        )
                    } else {
                        result.success(false)
                    }
                }
                // Battery: "Restricted" (background use blocked) holds alarms
                // back; "Unrestricted" = exempt from battery optimisation. Only
                // READ here; the app never asks to be exempted (Play restricts
                // that), it only opens the settings.
                "batteryStatus" -> {
                    val power = getSystemService(Context.POWER_SERVICE) as PowerManager
                    val restricted = Build.VERSION.SDK_INT >= Build.VERSION_CODES.P &&
                        (getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager)
                            .isBackgroundRestricted
                    result.success(
                        mapOf(
                            "restricted" to restricted,
                            "unrestricted" to power.isIgnoringBatteryOptimizations(packageName),
                            "samsung" to Build.MANUFACTURER.equals("samsung", ignoreCase = true),
                        ),
                    )
                }
                // The app's own info page, where Battery is one tap away.
                "openBatterySettings" -> {
                    startActivity(
                        Intent(
                            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                            Uri.parse("package:$packageName"),
                        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                    )
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    companion object {
        /** flutter_local_notifications' action and extra for a notification opening the app. */
        private const val SELECT_NOTIFICATION = "SELECT_NOTIFICATION"
        private const val PAYLOAD = "payload"

        /** The alert groups that are alarms (see reminder_scheduler.dart). */
        private val ALARM_GROUPS = setOf("sadhana-timer", "timer", "sun-alarm")
    }
}
