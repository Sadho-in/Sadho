package `in`.sadho.app

import android.app.ActivityManager
import android.app.KeyguardManager
import android.app.NotificationManager
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.view.KeyEvent
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
    private var malaChannel: MethodChannel? = null
    private var ringChannel: MethodChannel? = null

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

    override fun onResume() {
        super.onResume()
        MalaCounterService.appInForeground = true
    }

    override fun onPause() {
        MalaCounterService.appInForeground = false
        super.onPause()
    }

    override fun onDestroy() {
        MalaCounterService.listener = null
        AlarmRinger.listener = null
        super.onDestroy()
    }

    /**
     * While the Mala service counts, a volume key pressed with the app on
     * screen goes straight to it (one count per press, not per auto-repeat),
     * so the system never shows its volume panel and the volume never changes.
     */
    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        val service = MalaCounterService.instance
        val volumeKey = event.keyCode == KeyEvent.KEYCODE_VOLUME_UP ||
            event.keyCode == KeyEvent.KEYCODE_VOLUME_DOWN
        if (volumeKey && service != null && service.isCounting) {
            if (event.action == KeyEvent.ACTION_DOWN && event.repeatCount == 0) {
                service.onForegroundKey()
            }
            return true
        }
        return super.dispatchKeyEvent(event)
    }

    /** "sadho/mala": start, pause, resume, stop and read the Mala service. */
    private fun configureMala(flutterEngine: FlutterEngine) {
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sadho/mala")
        malaChannel = ch
        MalaCounterService.listener = { event -> ch.invokeMethod("event", event) }
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                // Only ever called with the app on screen (the user pressed Start).
                "start" -> {
                    val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any?>()
                    try {
                        MalaCounterService.writeConfig(this, args, fresh = true)
                        val intent = Intent(this, MalaCounterService::class.java)
                            .setAction(MalaCounterService.ACTION_START)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        // E.g. ForegroundServiceStartNotAllowedException.
                        MalaCounterService.markStopped(this)
                        result.success(false)
                    }
                }
                "update" -> {
                    val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any?>()
                    MalaCounterService.writeConfig(this, args, fresh = false)
                    MalaCounterService.instance?.reload()
                    result.success(null)
                }
                "pause" -> {
                    MalaCounterService.instance?.pauseCounting()
                    result.success(null)
                }
                "resume" -> {
                    MalaCounterService.instance?.resumeCounting()
                    result.success(null)
                }
                "stop" -> {
                    val service = MalaCounterService.instance
                    if (service != null) service.stopCounting() else MalaCounterService.markStopped(this)
                    result.success(null)
                }
                "currentState" -> result.success(MalaCounterService.readState(this))
                // The app is back: a Mala ring still sounding stops (unless
                // the phone is locked and the alarm screen shows it).
                "dismissRing" -> {
                    AlarmRinger.silenceIfUnlocked(this, MalaCounterService.MALA_GROUP)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * "sadho/ring": the one alarm ring (AlarmRinger) and the alarms that
     * start it (AlarmScheduler). Its state lives natively, so the app reads it
     * back after its activity or process was recreated.
     */
    private fun configureRing(flutterEngine: FlutterEngine) {
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sadho/ring")
        ringChannel = ch
        AlarmRinger.listener = { state -> ch.invokeMethod("ringChanged", state) }
        AlarmRinger.ensureChannels(this)
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "replaceGroup" -> {
                    val args = call.arguments as? Map<*, *>
                    val group = args?.get("group") as? String
                    val alarms = (args?.get("alarms") as? List<*>)?.filterIsInstance<Map<*, *>>()
                    if (group == null || alarms == null) {
                        result.success(false)
                    } else {
                        AlarmScheduler.replaceGroup(this, group, alarms)
                        result.success(true)
                    }
                }
                "canScheduleExact" -> result.success(AlarmScheduler.canScheduleExact(this))
                "state" -> result.success(AlarmRinger.state(this))
                // A Stop button in the app: silences and acknowledges.
                "stop" -> {
                    AlarmRinger.acknowledge(this)
                    result.success(null)
                }
                "silenceIfUnlocked" -> {
                    AlarmRinger.silenceIfUnlocked(this, call.arguments as? String)
                    result.success(null)
                }
                "setChannelNames" -> {
                    val args = call.arguments as? Map<*, *>
                    AlarmRinger.setChannelNames(
                        this, args?.get("sadhana") as? String, args?.get("alarms") as? String,
                    )
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private val keyguard: KeyguardManager
        get() = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        configureMala(flutterEngine)
        configureRing(flutterEngine)
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
                // Quiet mode (Do Not Disturb). Only ever changed with the
                // user's Notification Policy access; never asked otherwise.
                "dndStatus" -> {
                    val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        result.success(
                            mapOf(
                                "access" to nm.isNotificationPolicyAccessGranted,
                                "filter" to nm.currentInterruptionFilter,
                            ),
                        )
                    } else {
                        result.success(mapOf("access" to false, "filter" to 0))
                    }
                }
                "dndSetFilter" -> {
                    val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    val filter = (call.arguments as? Number)?.toInt()
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                        filter != null && filter > 0 &&
                        nm.isNotificationPolicyAccessGranted
                    ) {
                        try {
                            nm.setInterruptionFilter(filter)
                            result.success(true)
                        } catch (e: SecurityException) {
                            result.success(false)
                        }
                    } else {
                        result.success(false)
                    }
                }
                "openDndSettings" -> result.success(openSettings("dnd"))
                // The alarm channels must still alert (heads-up / full screen):
                // the first one the user turned down, or null if all is well.
                "alarmChannelProblem" -> {
                    var bad: String? = null
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                        AlarmRinger.ensureChannels(this)
                        for (id in listOf(AlarmRinger.CHANNEL_SADHANA, AlarmRinger.CHANNEL_ALARMS)) {
                            val ch = nm.getNotificationChannel(id) ?: continue
                            if (ch.importance < NotificationManager.IMPORTANCE_HIGH) {
                                bad = id
                                break
                            }
                        }
                    }
                    result.success(bad)
                }
                // A Fix button: the specific settings page, then the app's
                // notification settings, then the app's details page. True
                // if one opened (false: the app shows written steps).
                "openSettings" -> result.success(openSettings(call.arguments as? String ?: ""))
                // The app's own info page, where Battery is one tap away.
                "openBatterySettings" -> result.success(openSettings("battery"))
                else -> result.notImplemented()
            }
        }
    }

    private fun pkgUri(): Uri = Uri.parse("package:$packageName")

    /** The page a Fix button should open first, for [kind]. */
    private fun specificSettings(kind: String): Intent? = when {
        kind == "notifications" && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ->
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
        kind == "exact" && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S ->
            Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, pkgUri())
        kind == "fullscreen" && Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE ->
            Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT, pkgUri())
        kind.startsWith("channel:") && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ->
            Intent(Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS)
                .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                .putExtra(Settings.EXTRA_CHANNEL_ID, kind.removePrefix("channel:"))
        kind == "dnd" && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M ->
            Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
        kind == "battery" -> Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, pkgUri())
        else -> null
    }

    /**
     * Opens [kind]'s settings page, falling back to the app's notification
     * settings and then the app's details page. Every failure is caught and
     * logged; never silent: false means nothing opened.
     */
    private fun openSettings(kind: String): Boolean {
        val chain = listOfNotNull(
            specificSettings(kind),
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                    .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            } else {
                null
            },
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, pkgUri()),
        )
        for (intent in chain) {
            try {
                startActivity(intent)
                android.util.Log.i("SadhoFix", "$kind: opened ${intent.action}")
                return true
            } catch (e: ActivityNotFoundException) {
                android.util.Log.w("SadhoFix", "$kind: no page for ${intent.action}")
            } catch (e: SecurityException) {
                android.util.Log.w("SadhoFix", "$kind: not allowed to open ${intent.action}")
            }
        }
        return false
    }

    companion object {
        /** flutter_local_notifications' action and extra for a notification opening the app. */
        private const val SELECT_NOTIFICATION = "SELECT_NOTIFICATION"
        private const val PAYLOAD = "payload"

        /** The alert groups that are alarms (see reminder_scheduler.dart). */
        private val ALARM_GROUPS = setOf("sadhana-timer", "timer", "sun-alarm", "mala")
    }
}
