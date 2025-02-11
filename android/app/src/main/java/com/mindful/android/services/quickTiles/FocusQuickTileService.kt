package com.mindful.android.services.quickTiles

import android.annotation.SuppressLint
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.util.Log
import com.mindful.android.R
import com.mindful.android.helpers.storage.SharedPrefsHelper
import com.mindful.android.services.timer.FocusSessionService
import com.mindful.android.utils.Utils


class FocusQuickTileService : TileService() {
    private val TAG = "Mindful.FocusQuickTileService"

    override fun onStartListening() {
        try {
            /// Check focus session status
            val isFocusActive = Utils.isServiceRunning(this, FocusSessionService::class.java)
            val tile = qsTile


            tile.state = if (isFocusActive) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                tile.subtitle =
                    getString(
                        if (isFocusActive) R.string.focus_quick_tile_status_active
                        else R.string.app_name
                    )
            }

            tile.updateTile()
        } catch (e: Exception) {
            Log.e(TAG, "onStartListening: Failed to update focus quick tile", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this, e)
        }

        super.onStartListening()
    }


    @SuppressLint("StartActivityAndCollapseDeprecated")
    override fun onClick() {
        unlockAndRun {
            try {
                /// Check focus session status
                val isFocusActive = Utils.isServiceRunning(this, FocusSessionService::class.java)
                val uriString = if (isFocusActive) "com.mindful.android://open/activeSession"
                else "com.mindful.android://open/focus"


                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                    startActivityAndCollapse(
                        Utils.getPendingIntentForMindfulUri(this, uriString)
                    )
                } else {
                    startActivityAndCollapse(
                        Utils.getIntentForMindfulUri(this, uriString)
                    )
                }
            } catch (e: Exception) {
                Log.e(TAG, "onClick: Failed to launch activity", e)
                SharedPrefsHelper.insertCrashLogToPrefs(this, e)
            }
        }

        super.onClick()
    }
}