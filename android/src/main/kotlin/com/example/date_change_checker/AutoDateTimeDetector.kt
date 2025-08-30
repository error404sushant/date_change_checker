package com.example.date_change_checker

import android.content.Context
import android.provider.Settings

/**
 * Android implementation for detecting automatic date/time settings
 */
class AutoDateTimeDetector {
    
    companion object {
        /**
         * Checks if automatic date/time is enabled on Android device
         *
         * This method uses Settings.Global.AUTO_TIME to determine if the device
         * is set to automatically update its date/time settings.
         *
         * @param context The Android context
         * @return true if auto date/time is enabled, false otherwise
         */
        fun isAutoDateTimeEnabled(context: Context): Boolean {
            return try {
                val autoTime = Settings.Global.getInt(
                    context.contentResolver,
                    Settings.Global.AUTO_TIME
                )
                autoTime == 1
            } catch (e: Settings.SettingNotFoundException) {
                // If setting is not found, assume it's disabled
                false
            }
        }
    }
}