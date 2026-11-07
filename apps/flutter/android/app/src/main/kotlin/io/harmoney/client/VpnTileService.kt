package io.harmoney.client

import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat

@RequiresApi(Build.VERSION_CODES.N)
class VpnTileService : TileService() {
    companion object {
        fun updateTile(context: Context) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                runCatching {
                    requestListeningState(context, ComponentName(context, VpnTileService::class.java))
                }
            }
        }
    }

    override fun onStartListening() {
        super.onStartListening()
        qsTile?.apply {
            state = if (HarmoneyVpnService.tunnelRunning) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
            label = "Harmoney"
            updateTile()
        }
    }

    override fun onClick() {
        super.onClick()
        if (HarmoneyVpnService.tunnelRunning) {
            startService(Intent(this, HarmoneyVpnService::class.java).setAction(HarmoneyVpnService.STOP))
            return
        }
        if (VpnService.prepare(this) != null) {
            val intent = Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                val pending = PendingIntent.getActivity(this, 0, intent,
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
                startActivityAndCollapse(pending)
            } else {
                @Suppress("DEPRECATION")
                startActivityAndCollapse(intent)
            }
            return
        }
        ContextCompat.startForegroundService(this,
            Intent(this, HarmoneyVpnService::class.java)
                .setAction(HarmoneyVpnService.START)
                .putExtra("pattern", "auto")
                .putExtra("flowLine", ""))
    }
}
