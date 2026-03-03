package com.focusguard.focus_guard

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Boot receiver that restarts the AppBlockerService when the device reboots.
 * Only restarts if blocking was active before the reboot.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            // Check shared preferences to see if blocking was active
            val prefs = context.getSharedPreferences("focusguard_prefs", Context.MODE_PRIVATE)
            val wasBlocking = prefs.getBoolean("was_blocking", false)
            val blockedApps = prefs.getStringSet("blocked_apps", emptySet()) ?: emptySet()

            if (wasBlocking && blockedApps.isNotEmpty()) {
                val serviceIntent = Intent(context, AppBlockerService::class.java).apply {
                    action = AppBlockerService.ACTION_START
                    putStringArrayListExtra(
                        AppBlockerService.EXTRA_PACKAGES,
                        ArrayList(blockedApps)
                    )
                }
                context.startForegroundService(serviceIntent)
            }
        }
    }
}
