package com.focusguard.focus_guard

import android.app.*
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import androidx.core.app.NotificationCompat

/**
 * Foreground service that monitors the foreground app and triggers
 * an overlay when a blocked app is detected.
 *
 * Uses UsageStatsManager to poll the foreground app every 2 seconds.
 * Fully Play Store compliant — does NOT kill apps, only overlays them.
 */
class AppBlockerService : Service() {

    companion object {
        const val CHANNEL_ID = "focusguard_blocker"
        const val NOTIFICATION_ID = 1001
        const val ACTION_START = "com.focusguard.START_BLOCKING"
        const val ACTION_STOP = "com.focusguard.STOP_BLOCKING"
        const val ACTION_UPDATE = "com.focusguard.UPDATE_APPS"
        const val EXTRA_PACKAGES = "blocked_packages"

        private var blockedPackages = mutableSetOf<String>()
        private var isRunning = false

        fun isServiceRunning() = isRunning
    }

    private var monitorThread: Thread? = null
    private var shouldMonitor = false

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                val packages = intent.getStringArrayListExtra(EXTRA_PACKAGES) ?: arrayListOf()
                blockedPackages.clear()
                blockedPackages.addAll(packages)
                startForegroundMonitoring()
            }
            ACTION_UPDATE -> {
                val packages = intent.getStringArrayListExtra(EXTRA_PACKAGES) ?: arrayListOf()
                blockedPackages.clear()
                blockedPackages.addAll(packages)
            }
            ACTION_STOP -> {
                stopMonitoring()
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
        }
        return START_STICKY
    }

    private fun startForegroundMonitoring() {
        val notification = buildNotification()
        startForeground(NOTIFICATION_ID, notification)
        isRunning = true
        shouldMonitor = true

        monitorThread = Thread {
            while (shouldMonitor) {
                try {
                    val foregroundApp = getForegroundApp()
                    if (foregroundApp != null && blockedPackages.contains(foregroundApp)) {
                        showBlockOverlay(foregroundApp)
                    }
                    Thread.sleep(2000) // Poll every 2 seconds
                } catch (e: InterruptedException) {
                    break
                }
            }
        }.apply { start() }
    }

    private fun stopMonitoring() {
        shouldMonitor = false
        isRunning = false
        monitorThread?.interrupt()
        monitorThread = null
    }

    private fun getForegroundApp(): String? {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return null

        val endTime = System.currentTimeMillis()
        val beginTime = endTime - 5000 // Last 5 seconds

        val usageStats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY, beginTime, endTime
        )

        if (usageStats.isNullOrEmpty()) return null

        return usageStats
            .filter { it.lastTimeUsed > 0 }
            .maxByOrNull { it.lastTimeUsed }
            ?.packageName
    }

    private fun showBlockOverlay(blockedApp: String) {
        if (!Settings.canDrawOverlays(this)) return

        val intent = Intent(this, OverlayActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            putExtra("blocked_app", blockedApp)
        }
        startActivity(intent)
    }

    private fun buildNotification(): Notification {
        val pendingIntent = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("FocusGuard is protecting your focus")
            .setContentText("${blockedPackages.size} apps blocked")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "App Blocker Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps FocusGuard running to block distracting apps"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        stopMonitoring()
        super.onDestroy()
    }
}
