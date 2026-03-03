package com.focusguard.app

import android.app.*
import android.app.usage.UsageStatsManager
import android.content.*
import android.content.pm.PackageManager
import android.os.*
import android.provider.Settings
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * App Blocker Foreground Service for FocusGuard Pro.
 *
 * Polls the foreground app every 2 seconds using UsageStatsManager.
 * When a blocked app is detected, launches OverlayActivity.
 */
class AppBlockerService : Service() {

    companion object {
        const val CHANNEL_ID = "focusguard_blocker"
        const val NOTIFICATION_ID = 1001
        const val POLL_INTERVAL_MS = 2000L
        private val blockedPackages = mutableSetOf<String>()
        private var blockCount = 0

        fun updateBlockedApps(packages: List<String>) {
            blockedPackages.clear()
            blockedPackages.addAll(packages)
        }

        fun getBlockCount(): Int = blockCount
    }

    private val handler = Handler(Looper.getMainLooper())
    private var isRunning = false
    private var lastBlockedApp: String? = null

    private val pollRunnable = object : Runnable {
        override fun run() {
            if (!isRunning) return
            checkForegroundApp()
            handler.postDelayed(this, POLL_INTERVAL_MS)
        }
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = buildNotification()
        startForeground(NOTIFICATION_ID, notification)
        isRunning = true
        handler.post(pollRunnable)
        return START_STICKY
    }

    override fun onDestroy() {
        isRunning = false
        handler.removeCallbacks(pollRunnable)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun checkForegroundApp() {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val startTime = endTime - 5000

        val usageStats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY, startTime, endTime
        )

        val currentApp = usageStats
            ?.filter { it.lastTimeUsed > 0 }
            ?.maxByOrNull { it.lastTimeUsed }
            ?.packageName

        if (currentApp != null && blockedPackages.contains(currentApp) && currentApp != lastBlockedApp) {
            lastBlockedApp = currentApp
            blockCount++
            launchOverlay(currentApp)
        } else if (currentApp != null && !blockedPackages.contains(currentApp)) {
            lastBlockedApp = null
        }
    }

    private fun launchOverlay(packageName: String) {
        val intent = Intent(this, OverlayActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("blocked_package", packageName)
            putExtra("block_count", blockCount)
        }
        startActivity(intent)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "FocusGuard Protection",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Monitors and blocks distracting apps"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("FocusGuard is protecting your focus 🛡️")
            .setContentText("${blockedPackages.size} apps blocked • $blockCount blocks today")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
    }
}

/**
 * Overlay Activity — shown when a blocked app is detected.
 */
class OverlayActivity : FlutterActivity() {
    // This activity is displayed when a blocked app is detected.
    // It shows the app name, motivational message, and "Back to Work" button.
    // Implementation is handled by the Flutter overlay screen.
}

/**
 * Boot Receiver — restart blocker service on device reboot.
 */
class AppBlockerReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val serviceIntent = Intent(context, AppBlockerService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
        }
    }
}

/**
 * Flutter MethodChannel handler for the blocker service.
 */
class BlockerMethodChannelHandler(private val context: Context) {
    companion object {
        const val CHANNEL = "com.focusguard/blocker"
    }

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    val intent = Intent(context, AppBlockerService::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        context.startForegroundService(intent)
                    } else {
                        context.startService(intent)
                    }
                    result.success(true)
                }
                "stopService" -> {
                    context.stopService(Intent(context, AppBlockerService::class.java))
                    result.success(true)
                }
                "updateBlockedApps" -> {
                    val packages = call.argument<List<String>>("packages") ?: emptyList()
                    AppBlockerService.updateBlockedApps(packages)
                    result.success(true)
                }
                "hasUsagePermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestUsagePermission" -> {
                    val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    context.startActivity(intent)
                    result.success(true)
                }
                "getCurrentForegroundApp" -> {
                    result.success(getCurrentForegroundApp())
                }
                "getBlockCount" -> {
                    result.success(AppBlockerService.getBlockCount())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as android.app.AppOpsManager
        val mode = appOps.checkOpNoThrow(
            android.app.AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            context.packageName
        )
        return mode == android.app.AppOpsManager.MODE_ALLOWED
    }

    private fun getCurrentForegroundApp(): String? {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val startTime = endTime - 5000
        val usageStats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY, startTime, endTime
        )
        return usageStats?.maxByOrNull { it.lastTimeUsed }?.packageName
    }
}
