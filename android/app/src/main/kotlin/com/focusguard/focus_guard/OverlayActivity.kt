package com.focusguard.focus_guard

import android.app.Activity
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.graphics.Color
import android.view.Gravity
import android.util.TypedValue

/**
 * Full-screen overlay activity shown when a blocked app is detected 
 * in the foreground. This is Play Store compliant — it does NOT kill
 * the blocked app, it simply presents a motivational overlay.
 *
 * User can choose:
 * - "Back to Work" → closes overlay, user returns to launcher
 * - "5 More Minutes" → grants a temporary grace period (tracked)
 */
class OverlayActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Make it full-screen and lock-like
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )

        val blockedApp = intent.getStringExtra("blocked_app") ?: "this app"
        val appName = blockedApp.split(".").lastOrNull()?.replaceFirstChar { it.uppercase() } ?: blockedApp

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#0A0E27"))
            setPadding(64, 64, 64, 64)
        }

        // Shield icon
        val shieldEmoji = TextView(this).apply {
            text = "🛡️"
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 72f)
            gravity = Gravity.CENTER
        }
        layout.addView(shieldEmoji)

        // Title
        val title = TextView(this).apply {
            text = "Time to Focus!"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 32f)
            gravity = Gravity.CENTER
            setPadding(0, 48, 0, 16)
        }
        layout.addView(title)

        // Message
        val message = TextView(this).apply {
            text = "You opened $appName, which is on your blocked list.\n\nStay focused and get back to what matters! 💪"
            setTextColor(Color.parseColor("#9BA4B5"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 64)
        }
        layout.addView(message)

        // Back to Work button
        val backToWorkBtn = Button(this).apply {
            text = "Back to Work"
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.parseColor("#4361EE"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f)
            setPadding(48, 24, 48, 24)
            setOnClickListener {
                finishAffinity()
                moveTaskToBack(true)
            }
        }
        layout.addView(backToWorkBtn)

        val spacer = TextView(this).apply {
            setPadding(0, 24, 0, 0)
        }
        layout.addView(spacer)

        // 5 More Minutes button
        val fiveMoreBtn = Button(this).apply {
            text = "5 More Minutes"
            setTextColor(Color.parseColor("#9BA4B5"))
            setBackgroundColor(Color.TRANSPARENT)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            setOnClickListener {
                // In production: log the grace period, set a 5-minute timer
                // before re-blocking
                finish()
            }
        }
        layout.addView(fiveMoreBtn)

        setContentView(layout)
    }

    override fun onBackPressed() {
        // Prevent dismissing with back button when strict mode is on
        // For now, allow it.
        super.onBackPressed()
    }
}
